# Panudetingai's Neovim Config (`nvim-config`)

Neovim **0.11+** ที่ตั้งค่าให้ใช้งานง่ายและคุ้นมือเหมือน **Cursor / VS Code** พร้อมใช้ทันทีใน Terminal
มาพร้อมธีม **Kanagawa Dark (Custom Deep Background)**, **Supermaven AI Autocomplete**, **LSP ในตัว**, **File Explorer (Neo-tree)**, **Fuzzy Finder (`fzf-lua`)**, **Multi-cursor**, และ **ระบบรองรับคีย์ลัดแป้นพิมพ์ภาษาไทย (Kedmanee) อัตโนมัติ**

- **GitHub Repository**: [https://github.com/Panudetingai/nvim-config](https://github.com/Panudetingai/nvim-config)
- **สำหรับ AI / LLM Agent**: ดูไฟล์ [`llm.txt`](./llm.txt) เพื่อรันคำสั่งติดตั้งอัตโนมัติแบบ Step-by-Step

---

## สารบัญ

1. [ความต้องการของระบบ (Prerequisites)](#1-ความต้องการของระบบ-prerequisites)
2. [วิธีการติดตั้ง (Installation)](#2-วิธีการติดตั้ง-installation)
   - [วิธีที่ 1: ติดตั้งอัตโนมัติในบรรทัดเดียว (แนะนำ)](#วิธีที่-1-ติดตั้งอัตโนมัติในบรรทัดเดียว-แนะนำ)
   - [วิธีที่ 2: ติดตั้งแบบ Manual (`git clone`)](#วิธีที่-2-ติดตั้งแบบ-manual-git-clone)
   - [วิธีที่ 3: ให้ AI Agent ติดตั้งให้ (`llm.txt`)](#วิธีที่-3-ให้-ai-agent-ติดตั้งให้-llmtxt)
3. [การตั้งค่าหลังติดตั้งครั้งแรก (Post-Installation)](#3-การตั้งค่าหลังติดตั้งครั้งแรก-post-installation)
4. [การติดตั้ง Language Server (LSP)](#4-การติดตั้ง-language-server-lsp)
5. [ตารางคีย์ลัดทั้งหมด (Keymaps)](#5-ตารางคีย์ลัดทั้งหมด-keymaps)
6. [การซิงก์และอัปเดตระหว่างเครื่อง](#6-การซิงก์และอัปเดตระหว่างเครื่อง)
7. [การแก้ไขปัญหาที่พบบ่อย (Troubleshooting)](#7-การแก้ไขปัญหาที่พบบ่อย-troubleshooting)

---

## 1. ความต้องการของระบบ (Prerequisites)

ก่อนลง Config แนะนำให้ติดตั้งโปรแกรมพื้นฐานเหล่านี้เพื่อให้ฟีเจอร์ทั้งหมด (ค้นหาไฟล์, ไอคอน, คอมไพล์ Treesitter, LSP) ทำงานได้ครบ 100%:

- **Neovim `>= 0.11.0`** (จำเป็น เพราะใช้ `vim.lsp.config` / `vim.lsp.enable` แบบใหม่ของ Neovim 0.11+)
- **Git** (สำหรับโหลดปลั๊กอินผ่าน `lazy.nvim`)
- **fzf** และ **ripgrep (`rg`)** (สำหรับ `Ctrl+P` ค้นหาไฟล์ และ `Space+g` ค้นหาข้อความทั้งโปรเจกต์)
- **C Compiler (`clang` / `gcc`)** (สำหรับคอมไพล์ `nvim-treesitter` parsers)
- **Node.js & `npx`** (สำหรับรัน Web LSP: TypeScript, Tailwind CSS, HTML, CSS)
- **Nerd Font** (เช่น **JetBrainsMono Nerd Font** เพื่อให้แสดงไอคอนไฟล์และโฟลเดอร์ได้ถูกต้อง)

### ติดตั้งเครื่องมือพื้นฐานตามระบบปฏิบัติการ

#### macOS (Homebrew)
```bash
brew install neovim git fzf ripgrep node
brew install --cask font-jetbrains-mono-nerd-font
```

#### Ubuntu / Debian
```bash
# ติดตั้งเครื่องมือพื้นฐาน
sudo apt update && sudo apt install -y git curl unzip build-essential fzf ripgrep nodejs npm

# ติดตั้ง Neovim 0.11+ (หาก apt เป็นเวอร์ชันเก่า แนะนำใช้ tarball ทางการหรือ PPA/Homebrew)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim && sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
```

#### Arch Linux
```bash
sudo pacman -S neovim git base-devel fzf ripgrep nodejs npm ttf-jetbrains-mono-nerd
```

#### Windows (Winget / Scoop)
```powershell
winget install Neovim.Neovim Git.Git junegunn.fzf BurntSushi.ripgrep.MSVC OpenJS.NodeJS.LTS DEVCOM.JetBrainsMonoNerdFont
```

---

## 2. วิธีการติดตั้ง (Installation)

### วิธีที่ 1: ติดตั้งอัตโนมัติในบรรทัดเดียว (แนะนำ)

สคริปต์จะทำการ **Backup โฟลเดอร์ `nvim` เดิมให้อัตโนมัติ** (ถ้ามี), โคลนโปรเจกต์นี้ลงเครื่อง, เช็กเครื่องมือที่ขาด และสั่ง `lazy.nvim` ติดตั้งปลั๊กอินทั้งหมดให้ทันที

#### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/Panudetingai/nvim-config/main/install.sh | bash
```

#### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/Panudetingai/nvim-config/main/install.ps1 | iex
```

---

### วิธีที่ 2: ติดตั้งแบบ Manual (`git clone`)

#### macOS / Linux
```bash
# 1. สำรอง config เดิม (ถ้ามี)
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)

# 2. โคลน repo ไปที่ ~/.config/nvim
git clone https://github.com/Panudetingai/nvim-config.git ~/.config/nvim

# 3. ติดตั้งปลั๊กอินทั้งหมดแบบไร้หน้าต่าง (หรือเปิด nvim ตรงๆ ก็ได้)
nvim --headless "+Lazy! sync" +qa
```

#### Windows (PowerShell)
```powershell
# 1. สำรอง config เดิม (ถ้ามี)
if (Test-Path "$env:LOCALAPPDATA\nvim") {
    Move-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
}

# 2. โคลน repo ไปที่ %LOCALAPPDATA%\nvim
git clone https://github.com/Panudetingai/nvim-config.git "$env:LOCALAPPDATA\nvim"

# 3. ติดตั้งปลั๊กอินทั้งหมด
nvim --headless "+Lazy! sync" +qa
```

---

### วิธีที่ 3: ให้ AI Agent ติดตั้งให้ (`llm.txt`)

หากใช้งาน Claude Code, Cursor, Codex หรือ AI CLI บนเครื่องใหม่ สามารถสั่ง AI ด้วยประโยคนี้ได้เลย:

```text
อ่านไฟล์ https://raw.githubusercontent.com/Panudetingai/nvim-config/main/llm.txt แล้วติดตั้ง Neovim config ให้เครื่องนี้จนเสร็จสมบูรณ์
```

---

## 3. การตั้งค่าหลังติดตั้งครั้งแรก (Post-Installation)

1. **ตั้งค่าฟอนต์ใน Terminal (iTerm2 / Ghostty / WezTerm / Alacritty / Kitty / Windows Terminal)**
   - เลือกฟอนต์เป็น `JetBrainsMono Nerd Font` (หรือ Nerd Font ตัวอื่น) เพื่อให้ไอคอนใน Neo-tree และ Bufferline แสดงผลสวยงาม
2. **เปิดใช้งาน Supermaven AI Autocomplete (ครั้งแรกครั้งเดียว)**
   - เปิด `nvim` แล้วพิมพ์คำสั่ง:
     ```vim
     :SupermavenUseFree
     ```
   - เปิดลิงก์ที่แสดงขึ้นมาเพื่อ Login บัญชี Supermaven (หรือใช้ `:SupermavenUsePro` หากมี Pro)
3. **อัปเดต Treesitter Parsers (ถ้ายังไม่ครบ)**
   - พิมพ์ `:TSUpdate` ใน Neovim

---

## 4. การติดตั้ง Language Server (LSP)

Config นี้ตั้งค่า LSP ไว้พร้อมใช้งานแล้วสำหรับภาษายอดนิยม:

### Rust (`rust_analyzer`)
```bash
rustup component add rust-analyzer clippy
```

### TypeScript / JavaScript / Tailwind CSS / HTML / CSS
Config นี้เรียกผ่าน `npx --yes` ให้อัตโนมัติ แต่ถ้าต้องการให้เปิดไฟล์แล้ว LSP ทำงานได้ทันทีโดยไม่ต้องรอ `npx` เช็กแพ็กเกจ แนะนำให้ลงแบบ Global:
```bash
npm install -g typescript typescript-language-server vscode-langservers-extracted @tailwindcss/language-server
```

---

## 5. ตารางคีย์ลัดทั้งหมด (Keymaps)

> **ฟีเจอร์พิเศษสำหรับคนไทย**: รองรับปุ่มภาษาไทย (Kedmanee) ทุกปุ่มในโหมด Normal/Visual/Operator-pending รวมถึงคำสั่ง `:` เช่น `:ๆฟ` (`:qa`), `:ไ` (`:w`), `:ๆ` (`:q`), `:ไๆ` (`:wq`) โดยไม่ต้องสลับแป้นพิมพ์กลับเป็นภาษาอังกฤษ

### การจัดการไฟล์และค้นหา
| คีย์ลัด | การทำงาน |
|---|---|
| `Ctrl + P` | ค้นหาและเปิดไฟล์ด่วน (Quick Open แบบ VS Code) |
| `Space + p` | เปิด Command Palette |
| `Space + g` | ค้นหาข้อความทั้งโปรเจกต์ (Live Grep) |
| `Space + b` | สลับไฟล์ที่เปิดอยู่ (Buffers) |
| `Space + s` | ค้นหา Symbols (ฟังก์ชัน/ตัวแปร) ในไฟล์ปัจจุบัน |
| `Ctrl + B` หรือ `Space + fe` | เปิด/ปิด แถบ File Explorer ด้านซ้าย (Neo-tree) |
| `Shift + L` / `Shift + H` | สลับไปแท็บถัดไป / แท็บก่อนหน้า |
| `Space + x` | ปิดแท็บปัจจุบัน (โดยไม่ทำให้ Layout หน้าต่างพัง) |
| `Ctrl + \` | เปิด/ปิด Terminal ด้านล่าง |

### การแก้ไขโค้ด (สไตล์ VS Code / Cursor)
| คีย์ลัด | การทำงาน |
|---|---|
| `Ctrl + S` | บันทึกไฟล์ (ใช้ได้ทุกโหมด) |
| `Ctrl + Z` / `Ctrl + Y` | Undo / Redo (ใช้ได้ทั้งโหมดปกติและตอนพิมพ์) |
| `Ctrl + A` | เลือกข้อความทั้งหมดในไฟล์ (`Normal mode`) / ไปต้นบรรทัดโค้ด (`Insert mode`) |
| `Ctrl + C` / `Ctrl + X` | Copy / Cut ข้อความที่คลุมอยู่ |
| `Ctrl + /` | คอมเมนต์ / เลิกคอมเมนต์บรรทัดที่เลือก |
| `Ctrl + D` | เลือกคำซ้ำถัดไป (Multi-cursor แบบ VS Code) |
| `Ctrl + Shift + L` | เลือกคำซ้ำทั้งหมดในไฟล์ (Multi-cursor) |
| `Option + D` (`Alt + D`) | คลุมเฉพาะคำที่เคอร์เซอร์วางอยู่ (พิมพ์ทับได้ทันที) |
| `Option + Left / Right` | คลุมข้อความทีละคำไปทางซ้าย/ขวา (กดซ้ำเพื่อขยายคำถัดไปได้เรื่อยๆ) |
| `Option + Up / Down` (`Alt + J/K`) | ย้ายบรรทัด (หรือบล็อกที่คลุม) ขึ้น / ลง |
| `Shift + Delete` / `Ctrl + Shift + K` | ลบบรรทัดทั้งบรรทัดทันที |
| `gh` / `Home` | ไปหน้าสุดของโค้ดในบรรทัด |
| `gl` / `End` / `Ctrl + E` | ไปท้ายสุดของโค้ดในบรรทัด |

### AI & LSP (Code Intelligence)
| คีย์ลัด | การทำงาน |
|---|---|
| `Tab` | ยืนยัน AI Ghost Text Suggestion (Supermaven) |
| `Ctrl + J` | รับ AI Suggestion ทีละคำ (Supermaven Accept Word) |
| `Ctrl + ]` | ล้าง AI Suggestion ที่แสดงอยู่ |
| `Enter` | ยืนยันรายการจากเมนู Autocomplete (`blink.cmp`) |
| `Space + Space` / `Option + i` / `F1` | ดูเอกสารโค้ด (Hover) หรือเปิดเมนู Suggestion |
| `gd` / `F12` / `Ctrl + Click` | ไปที่ Definition |
| `gr` | ค้นหา References ทั้งหมด |
| `K` | ดู Hover Documentation |
| `F2` | เปลี่ยนชื่อตัวแปร/ฟังก์ชันทั้งโปรเจกต์ (Rename) |
| `Space + a` | เรียก Code Action |
| `Space + df` | เปิด Popup ดูรายละเอียด Error / Warning |
| `Space + F` | จัดรูปแบบโค้ด (Format ไฟล์ปัจจุบัน) |
| `:CargoCheck` | เปิด Terminal ด้านล่างและรัน `cargo check` ให้ทันที |

---

## 6. การซิงก์และอัปเดตระหว่างเครื่อง

### ดึง Config ล่าสุดลงเครื่อง
```bash
git -C ~/.config/nvim pull
nvim --headless "+Lazy! sync" +qa
```

### อัปเดตเมื่อแก้ไข Config แล้วต้องการแชร์ไปเครื่องอื่น
```bash
cd ~/.config/nvim
git add -A
git commit -m "chore: update nvim config"
git push
```

---

## 7. การแก้ไขปัญหาที่พบบ่อย (Troubleshooting)

- **กด `Ctrl + P` แล้วขึ้นแจ้งเตือนให้ติดตั้ง `fzf`**:
  - รัน `brew install fzf ripgrep` (macOS) หรือติดตั้ง `fzf` ลงใน `PATH` ของระบบ
- **ไอคอนเป็นสี่เหลี่ยม `[?]` หรือเพี้ยน**:
  - ติดตั้ง `JetBrainsMono Nerd Font` แล้วไปตั้งค่า Font ในโปรแกรม Terminal ที่ใช้งานอยู่
- **เปิดไฟล์แล้วขึ้น Error เกี่ยวกับ `vim.lsp.config` is nil**:
  - เวอร์ชันของ Neovim เก่ากว่า `0.11` ให้ตรวจสอบด้วย `nvim --version` และอัปเกรดเป็น Neovim `0.11+`
- **Option + ปุ่มบน macOS พิมพ์เป็นอักขระพิเศษหรือกดไม่ติด**:
  - Config นี้รองรับทั้ง `<A-...>`, `<M-...>` และอักขระพิเศษของ macOS (`∂`, `∆`, `˚`, `ˆ`, `≥`) ไว้ให้แล้ว แต่หากตั้งค่า Terminal ให้ `Option as Meta / Esc+` ก็จะยิ่งทำงานได้สมบูรณ์กับทุกปุ่ม
