#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/LucasAndrew0120/Nginx-X-AddAplineOS.git"
REPO_BRANCH="test-installer-alpine-support"
INSTALL_DIR="/opt/Nginx-X"
TARGET_BIN="/usr/local/bin/nx"

SUDO=""
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  SUDO="sudo"
fi

install_git_if_needed() {
  if command -v git >/dev/null 2>&1; then
    return 0
  fi

  echo "[INFO] 未检测到 git，正在安装..."
  if command -v apt-get >/dev/null 2>&1; then
    ${SUDO} apt-get update
    ${SUDO} apt-get install -y git
  elif command -v dnf >/dev/null 2>&1; then
    ${SUDO} dnf install -y git
  elif command -v yum >/dev/null 2>&1; then
    ${SUDO} yum install -y git
  elif command -v apk >/dev/null 2>&1; then
    ${SUDO} apk add git
  elif command -v opkg >/dev/null 2>&1; then
    ${SUDO} opkg update
    ${SUDO} opkg install git
  else
    echo "[ERROR] 无法自动安装 git，请手动安装后重试。"
    exit 1
  fi
}

echo "[INFO] 安装 Nginx-X 测试版：${REPO_URL} (${REPO_BRANCH})"
install_git_if_needed

if [[ -d "$INSTALL_DIR/.git" ]]; then
  ${SUDO} git -C "$INSTALL_DIR" remote set-url origin "$REPO_URL"
  ${SUDO} git -C "$INSTALL_DIR" fetch origin "$REPO_BRANCH"
  ${SUDO} git -C "$INSTALL_DIR" checkout -B "$REPO_BRANCH" "origin/$REPO_BRANCH"
elif [[ -e "$INSTALL_DIR" ]]; then
  echo "[WARN] 目标目录已存在但不是 Git 仓库，将移动备份。"
  ${SUDO} mv "$INSTALL_DIR" "${INSTALL_DIR}.bak.$(date +%s)"
  ${SUDO} git clone -b "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"
else
  ${SUDO} git clone -b "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

${SUDO} install -m 0755 "$INSTALL_DIR/nx.sh" "$TARGET_BIN"
${SUDO} install -m 0755 "$INSTALL_DIR/install.sh" "$INSTALL_DIR/install.sh"

echo "[OK] 测试版已安装。运行：nx"
