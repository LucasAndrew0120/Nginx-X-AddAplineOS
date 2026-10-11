#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034,SC2317
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/fixtures/test-environment.sh"
cd "$(dirname "$0")/.."
root="$NX_TEST_ENV_ROOT"
bash tools/build-bundle.sh "$root/bundle"
for entry in "$PWD/nx.sh" "$root/bundle"; do
  cat > "$root/driver" <<'SH'
set -euo pipefail
source "$1"
ensure_runtime_dependencies() { :; }
ensure_dirs() { :; }
ensure_websocket_map() { :; }
nx_migrate_certificate_renewal() { :; }
banner() { echo MAIN; }
clear() { :; }
pause() { echo PAUSE; read -r _ || return 0; }
install_or_upgrade_nginx() { echo INSTALL; return "${ACTION_RC:-0}"; }
update_script() {
  [[ "${NX_IN_MENU:-0}" == 1 ]] || return 99
  echo UPDATE
  if [[ "${HUP_TEST:-0}" == 1 ]]; then NX_UPDATE_HUP=1; return 129; fi
  return "${ACTION_RC:-0}"
}
uninstall_menu() { echo UNINSTALL; }
main
SH
  python3 - "$entry" "$root/driver" <<'PY'
import os, pty, subprocess, sys
entry, driver = sys.argv[1:]
def run(data, **extra):
    result = subprocess.run(['bash', driver, entry], input=data, text=True, capture_output=True,
                            env=dict(os.environ, **extra), timeout=10)
    return result.returncode, result.stdout + result.stderr
for rc in ('0', '1'):
    code, out = run('1\n1\n\n0\n5\n0\n', ACTION_RC=rc)
    assert code == 0 and out.count('\nINSTALL\n') == 1 and '\nUPDATE\n' not in out, out
    assert out.count('\nPAUSE\n') == 1 and out.count('\nUNINSTALL\n') == 1, out
    code, out = run('1\n2\n5\n0\n', ACTION_RC=rc)
    assert code == 0 and '\nUPDATE\n' in out and 'UNINSTALL' not in out, out
    assert out.count('MAIN\n') == 1 and '\nPAUSE\n' not in out, out
code, out = run('1\n2\n5\n0\n', HUP_TEST='1')
assert code == 129 and out.count('MAIN\n') == 1 and 'UNINSTALL' not in out, out
for data in ('', '1\n'):
    code, out = run(data)
    assert code == 0 and out.count('MAIN\n') == 1 and '\nPAUSE\n' not in out, out
code, out = run('6\n\n1\n9\n\n0\n0\n')
assert code == 0 and out.count('\nPAUSE\n') == 2 and '0-5' in out and '0-2' in out, out
# Real PTY: update failure/no-change returns to submenu with exactly one pause.
for rc in ('0', '1'):
    master, slave = pty.openpty()
    proc = subprocess.Popen(['bash', driver, entry], stdin=slave, stdout=slave, stderr=slave,
                            env=dict(os.environ, ACTION_RC=rc))
    os.close(slave)
    os.write(master, b'1\n2\n\n0\n5\n0\n')
    output = bytearray()
    import select, time
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        if select.select([master], [], [], .1)[0]:
            try: chunk = os.read(master, 65536)
            except OSError: break
            if not chunk: break
            output.extend(chunk)
        elif proc.poll() is not None: break
    if proc.poll() is None: proc.kill()
    assert proc.wait() == 0, output
    os.close(master)
    text = output.decode().replace('\r', '')
    assert text.count('\nUPDATE\n') == 1 and text.count('\nPAUSE\n') == 1, text
    assert text.count('UNINSTALL\n') == 1 and '\nINSTALL\n' not in text, text
print('PASS merged menu source/bundle routes, failures, EOF, PTY and HUP')
PY
done
