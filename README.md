# Neovim Config (`Panudetingai/nvim-config`)

Neovim 0.11+ สไตล์ **Cursor / VS Code** — ธีม Kanagawa Dark ปรับแต่งพิเศษ, AI Autocomplete (Supermaven), LSP (Rust / TypeScript / Tailwind / HTML / CSS), รองรับเมาส์ + แท็บ + File Explorer + **รองรับคีย์ลัดแป้นภาษาไทย (Kedmanee) อัตโนมัติ**

---

## ติดตั้งด่วน (One-Line Install)

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/Panudetingai/nvim-config/main/install.sh | bash
```

หรือ clone เอง:

```bash
git clone https://github.com/Panudetingai/nvim-config.git ~/.config/nvim
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Panudetingai/nvim-config/main/install.ps1 | iex
```

หรือ clone เอง:

```powershell
git clone https://github.com/Panudetingai/nvim-config.git "$env:LOCALAPPDATA\nvim"
```

---

## สิ่งที่แนะนำให้มีในเครื่อง (Prerequisites)

### macOS (Homebrew)

```bash
brew install neovim fzf ripgrep node
brew install --cask font-jetbrains-mono-nerd-font
```

### LSP Servers (ตามภาษาที่ใช้)

- **Rust**:
  ```bash
  rustup component add rust-analyzer clippy
  ```
- **Web (TypeScript / Tailwind / HTML / CSS)**:
  ทำงานผ่าน `npx` อัตโนมัติ หรือลง global ไว้ให้โหลดไวขึ้น:
  ```bash
  npm i -g typescript typescript-language-server vscode-langservers-extracted @tailwindcss/language-server
  ```

### เปิดใช้ Supermaven (AI Autocomplete) ครั้งแรก

เปิด `nvim` แล้วพิมพ์:

```vim
:SupermavenUseFree
```

---

## คีย์ลัดหลัก (Keymaps)

> **รองรับแป้นภาษาไทย (Kedmanee)**: สามารถกดคีย์ลัดในโหมด Normal/Visual หรือพิมพ์ `:ๆฟ` (`:qa`), `:ไ` (`:w`), `:ๆ` (`:q`) ได้ทันทีโดยไม่ต้องสลับภาษา

| คีย์ลัด | การทำงาน |
|---|---|
| `Ctrl + P` | ค้นหาและเปิดไฟล์ด่วน (fzf-lua) |
| `Space + p` | Command Palette |
| `Space + g` | ค้นหาข้อความทั้งโปรเจกต์ (Live Grep) |
| `Space + b` | สลับไฟล์ที่เปิดอยู่ (Buffers) |
| `Space + s` | ค้นหา Symbols ในไฟล์ |
| `Ctrl + B` / `Space + fe` | เปิด/ปิดแถบ File Explorer (Neo-tree) |
| `Shift + L` / `Shift + H` | สลับไปแท็บถัดไป / แท็บก่อนหน้า |
| `Space + x` | ปิดแท็บปัจจุบัน |
| `Ctrl + \` | เปิด/ปิด Terminal ด้านล่าง |
| `Ctrl + S` | บันทึกไฟล์ |
| `Ctrl + Z` / `Ctrl + Y` | Undo / Redo |
| `Ctrl + /` | คอมเมนต์บรรทัด / บล็อกที่เลือก |
| `Ctrl + D` | เลือกคำซ้ำถัดไป (Multi-cursor แบบ VS Code) |
| `Option + D` | คลุมเฉพาะคำที่ติดกัน (พิมพ์ทับได้ทันที) |
| `Option + Left / Right` | คลุมข้อความทีละคำไปทางซ้าย/ขวา |
| `Option + Up / Down` (`Alt+J/K`) | ย้ายบรรทัดขึ้น / ลง |
| `Space + Space` / `Option + i` / `F1` | ดูข้อมูลโค้ด (Hover) หรือเรียกเมนู Suggestion |
| `Tab` | ยืนยัน AI Suggestion (Supermaven) |
| `Enter` | ยืนยันรายการ Autocomplete (Blink.cmp) |
| `gd` / `Ctrl + Click` | ไปที่ Definition |
| `gr` | หา References |
| `F2` | เปลี่ยนชื่อตัวแปร/ฟังก์ชัน (Rename) |
| `Space + a` | Code Action |
| `Space + F` | จัดรูปแบบโค้ด (Format) |

---

## การอัปเดต Config ระหว่างเครื่อง

- **ดึง config ล่าสุดลงเครื่อง**:
  ```bash
  git -C ~/.config/nvim pull
  ```
- **อัปเดตเมื่อแก้ไข config บนเครื่อง**:
  ```bash
  cd ~/.config/nvim
  git add -A && git commit -m "update nvim config" && git push
  ```
