#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

TMPDIR_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_ROOT"' EXIT

MOCK_BIN="$TMPDIR_ROOT/bin"
mkdir -p "$MOCK_BIN"
cat > "$MOCK_BIN/nginx" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$MOCK_BIN/systemctl" <<'EOF'
#!/usr/bin/env bash
case "$1" in
  is-active) exit 1 ;;
  start|reload) exit 0 ;;
  *) exit 0 ;;
esac
EOF
chmod +x "$MOCK_BIN/nginx" "$MOCK_BIN/systemctl"
export PATH="$MOCK_BIN:$PATH"

# shellcheck disable=SC1091,SC1090
source <(sed '$d' nx.sh)

# shellcheck disable=SC2034
SUDO=""
CONF_DIR="$TMPDIR_ROOT/conf.d"
SSL_DIR="$TMPDIR_ROOT/ssl"
mkdir -p "$CONF_DIR" "$SSL_DIR/example.com"
: > "$SSL_DIR/example.com/fullchain.pem"
: > "$SSL_DIR/example.com/privkey.pem"

out="$TMPDIR_ROOT/example-443.conf"
build_external_proxy_conf \
  "example.com" \
  "443" \
  "https://upstream.example.com" \
  "normal" \
  "$out" \
  "1"

grep -q '^# https_enabled=true$' "$out"
grep -q 'listen 443 ssl' "$out"
# shellcheck disable=SC2016
grep -Fq 'return 301 https://$host$request_uri;' "$out"
grep -q "ssl_certificate     ${SSL_DIR}/example.com/fullchain.pem;" "$out"
grep -q "ssl_certificate_key ${SSL_DIR}/example.com/privkey.pem;" "$out"

http_conf="$TMPDIR_ROOT/http-80.conf"
cat > "$http_conf" <<'EOF'
# managed_by=Nginx-X
# domain=example.com
# listen_port=80
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://127.0.0.1:3000;
    }
}
EOF

enable_https_for_conf_file "example.com" "$http_conf"
grep -q '^# listen_port=443$' "$http_conf"
grep -q 'listen 443 ssl' "$http_conf"
# shellcheck disable=SC2016
grep -Fq 'return 301 https://$host$request_uri;' "$http_conf"

bad_conf="$TMPDIR_ROOT/bad.conf"
cat > "$bad_conf" <<'EOF'
server {
    listen 443 ssl;
    server_name broken.example.com;
}
EOF

if ensure_ssl_directives_present "$bad_conf"; then
  echo "expected ensure_ssl_directives_present to fail for incomplete ssl config" >&2
  exit 1
fi

echo "ok"
