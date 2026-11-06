$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/Panudetingai/nvim-config.git"
$NvimDir = Join-Path $env:LOCALAPPDATA "nvim"

Write-Host "==> Installing Panudetingai Neovim Config..." -ForegroundColor Cyan

if (Test-Path $NvimDir) {
    $GitDir = Join-Path $NvimDir ".git"
    if (Test-Path $GitDir) {
        Write-Host "==> Pulling latest changes in $NvimDir..." -ForegroundColor Yellow
        git -C $NvimDir pull --ff-only
    } else {
        $Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $BackupDir = "$NvimDir.backup.$Stamp"
        Write-Host "==> Backing up existing $NvimDir to $BackupDir" -ForegroundColor Yellow
        Move-Item $NvimDir $BackupDir
        git clone $RepoUrl $NvimDir
    }
} else {
    git clone $RepoUrl $NvimDir
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Write-Host "==> Syncing plugins with lazy.nvim..." -ForegroundColor Cyan
    nvim --headless "+Lazy! sync" +qa
}

Write-Host ""
Write-Host "✅ ติดตั้ง Neovim config เรียบร้อยแล้ว!" -ForegroundColor Green
Write-Host "   - เปิดใช้งานด้วยคำสั่ง: nvim"
Write-Host "   - ครั้งแรกสำหรับ AI Autocomplete ให้พิมพ์ใน nvim: :SupermavenUseFree"
