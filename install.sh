#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Panudetingai/nvim-config.git"
NVIM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

echo "==> Installing Panudetingai Neovim Config..."

# 1. Backup existing config if present and not already this repo
if [ -d "$NVIM_DIR" ]; then
  if [ -d "$NVIM_DIR/.git" ] && git -C "$NVIM_DIR" remote get-url origin 2>/dev/null | grep -q "Panudetingai/nvim-config"; then
    echo "==> Existing nvim-config repo found. Pulling latest changes..."
    git -C "$NVIM_DIR" pull --ff-only
  else
    BACKUP_DIR="${NVIM_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "==> Backing up existing $NVIM_DIR to $BACKUP_DIR"
    mv "$NVIM_DIR" "$BACKUP_DIR"
    git clone "$REPO_URL" "$NVIM_DIR"
  fi
else
  mkdir -p "$(dirname "$NVIM_DIR")"
  git clone "$REPO_URL" "$NVIM_DIR"
fi

# 2. Check recommended CLI tools
missing_tools=()
for cmd in nvim fzf rg git; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing_tools+=("$cmd")
  fi
done

if [ ${#missing_tools[@]} -gt 0 ]; then
  echo ""
  echo "⚠️  ยังไม่ได้ติดตั้งเครื่องมือบางตัว: ${missing_tools[*]}"
  if command -v brew >/dev/null 2>&1; then
    echo "   แนะนำให้รัน: brew install neovim fzf ripgrep"
  fi
fi

# 3. Sync Lazy.nvim plugins headlessly
if command -v nvim >/dev/null 2>&1; then
  echo "==> Syncing plugins with lazy.nvim..."
  nvim --headless "+Lazy! sync" +qa || true
fi

echo ""
echo "✅ ติดตั้ง Neovim config เรียบร้อยแล้ว!"
echo "   - เปิดใช้งานด้วยคำสั่ง: nvim"
echo "   - ครั้งแรกสำหรับ AI Autocomplete ให้พิมพ์ใน nvim: :SupermavenUseFree"
