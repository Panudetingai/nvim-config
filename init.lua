-- Neovim 0.11+ : terminal editor ที่ใกล้ Cursor/VS Code (Supermaven + LSP + เมาส์ + แท็บ + file explorer)
-- วางที่ ~/.config/nvim/init.lua
-- ต้องใช้ Nerd Font ใน terminal เพื่อให้ไอคอนแสดงถูกต้อง (เช่น JetBrainsMono Nerd Font)

vim.g.mapleader = " "

-- ===== พื้นฐาน + เมาส์ =====
local o = vim.o
o.mouse = "a"                    -- คลิก ลากเลือก เลื่อน ดับเบิลคลิกเลือกคำ
o.mousemodel = "popup_setpos"    -- คลิกขวาเปิดเมนู Cut/Copy/Paste
o.mousescroll = "ver:3,hor:6"
o.number = true
o.relativenumber = false         -- เลขบรรทัดปกติเหมือน Cursor
o.cursorline = true
o.termguicolors = true
o.signcolumn = "yes"
o.clipboard = "unnamedplus"      -- copy/paste ร่วมกับระบบ
o.ignorecase = true
o.smartcase = true
o.updatetime = 200
o.scrolloff = 8
o.undofile = true
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.wrap = false
-- ไฟล์ JS/TS/เว็บ ใช้ 2 ช่อง (ตาม Prettier ของโปรเจกต์) กัน gg=G จัดเพี้ยนเป็น 4 ช่อง
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "css", "scss", "html", "yaml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})
o.splitright = true
o.splitbelow = true
o.showmode = false
o.laststatus = 3
o.selectmode = "mouse,key"       -- ลากเมาส์หรือกด Shift+ลูกศร เข้า Select mode (พิมพ์ทับได้เลยเหมือน VS Code)
o.keymodel = "startsel"          -- ห้ามใส่ stopsel เพราะจะทำให้คำสั่งคลุมข้อความ (vg_ / v^) หลุดทันที!

-- ===== รองรับคีย์ลัดเมื่อแป้นพิมพ์เป็นภาษาไทย (Thai Kedmanee) =====
-- ทำให้กดปุ่มคำสั่งในโหมด Normal/Visual ได้ทันทีแม้ลืมสลับภาษาเป็นอังกฤษ
vim.opt.langmap = table.concat({
  "ๅ1,/2,-3,ภ4,ถ5,ุ6,ึ7,ค8,ต9,จ0,ข-,ช=",
  "+!,๑@,๒#,๓$,๔%,ู^,฿&,๕*,๖(,๗),๘_,๙+",
  "ๆq,ไw,ำe,พr,ะt,ัy,ีu,รi,นo,ยp,บ[,ล],ฃ\\\\",
  '๐Q,\\"W,ฎE,ฑR,ธT,ํY,๊U,ณI,ฯO,ญP,ฐ{,\\,},ฅ|',
  "ฟa,หs,กd,ดf,เg,้h,่j,าk,สl,ว\\;,ง'",
  "ฤA,ฆS,ฏD,โF,ฌG,็H,๋J,ษK,ศL,ซ:,\\.\"",
  "ผz,ปx,แc,อv,ิb,ืn,ทm,ม\\,,ใ.,ฝ/",
  "(Z,)X,ฉC,ฮV,ฺB,์N,?M,ฒ<,ฬ>,ฦ?",
}, ",")

-- ===== lazy.nvim (ตัวจัดการปลั๊กอิน) =====
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

---Quick open แบบ VS Code — ต้องมี `fzf` ใน PATH (macOS: brew install fzf)
local function fzf_open_files()
  if vim.fn.executable("fzf") ~= 1 then
    vim.notify("ติดตั้ง fzf ในเครื่องก่อน: brew install fzf", vim.log.levels.WARN, { title = "nvim" })
    return
  end
  require("fzf-lua").files({})
end

require("lazy").setup({
  -- ธีม Kanagawa (rebelot/kanagawa.nvim) — โทนญี่ปุ่น นุ่มตา คมชัด
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000,
    config = function()
      require("kanagawa").setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,
        dimInactive = false,
        terminalColors = true,
        theme = "wave", -- "wave" (สีโค้ดสดชัด) + ปรับพื้นหลังให้เข้มลึกขึ้นด้านล่าง
        background = { dark = "wave", light = "lotus" },
        colors = {
          theme = {
            all = {
              ui = {
                bg = "#111218",        -- พื้นหลัง editor เข้มลึก (เดิม #1f1f28)
                bg_dim = "#0d0e13",    -- พื้นหลังหน้าต่างข้างเคียง/sidebar
                bg_gutter = "none",    -- แถบเลขบรรทัดกลืนเป็นเนื้อเดียวกับพื้นหลัง editor
                bg_m3 = "#0d0e13",
                bg_m2 = "#0f1016",
                bg_m1 = "#14161e",
                bg_p1 = "#191b24",     -- บรรทัดเคอร์เซอร์ / popup เข้มกำลังดี
                bg_p2 = "#222532",     -- แถบที่ถูกเลือกในเมนู
              },
            },
          },
        },
        overrides = function(colors)
          local theme = colors.theme
          return {
            -- พื้นหลัง editor และขอบหน้าต่างเข้มลึก คอนทราสต์กับสีโค้ดชัดเจน
            Normal = { fg = theme.ui.fg, bg = "#111218" },
            NormalNC = { fg = theme.ui.fg_dim, bg = "#111218" },
            SignColumn = { bg = "#111218" },
            LineNr = { fg = "#54546d", bg = "#111218" },
            CursorLine = { bg = "#191b24" },
            CursorLineNr = { fg = theme.diag.warning, bg = "#191b24", bold = true },
            WinSeparator = { fg = "#1f2230", bg = "#111218" },
            -- ปรับเมนู/popup และ Neo-tree ให้เข้ากับพื้นหลังเข้ม
            NormalFloat = { bg = "#161821" },
            FloatBorder = { fg = "#363a4f", bg = "#161821" },
            FloatTitle = { fg = theme.syn.fun, bold = true, bg = "#161821" },
            BlinkCmpMenu = { fg = theme.ui.fg, bg = "#161821" },
            BlinkCmpMenuBorder = { fg = "#2a2e3f", bg = "#161821" },
            BlinkCmpMenuSelection = { fg = "NONE", bg = "#24283b", bold = true },
            NeoTreeNormal = { fg = theme.ui.fg_dim, bg = "#0d0e13" },
            NeoTreeNormalNC = { fg = theme.ui.fg_dim, bg = "#0d0e13" },
            NeoTreeEndOfBuffer = { fg = "#0d0e13", bg = "#0d0e13" },
            NeoTreeFileIcon = { fg = theme.ui.special },
            NeoTreeDirectoryIcon = { fg = theme.syn.fun },
            NeoTreeDirectoryName = { fg = theme.syn.fun, bold = true },
            NeoTreeRootName = { fg = theme.syn.keyword, bold = true },
            WhichKeyNormal = { bg = "#0d0e13" },
            WhichKeyBorder = { fg = "#2a2e3f", bg = "#0d0e13" },
            WhichKeyTitle = { fg = theme.syn.fun, bg = "#0d0e13", bold = true },
          }
        end,
      })
      vim.cmd.colorscheme("kanagawa")
    end },

  -- โหลดก่อน neo-tree/fzf-lua — หลังเปลี่ยน colorscheme ต้อง refresh ไม่งั้นไอคอนสีไม่ติด
  { "nvim-tree/nvim-web-devicons", lazy = false, priority = 900,
    config = function()
      require("nvim-web-devicons").setup({
        default = true,
        color_icons = true,
        variant = "dark",
      })
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          pcall(function()
            require("nvim-web-devicons").refresh()
          end)
        end,
      })
    end },

  -- ไฮไลต์โค้ด
  { "nvim-treesitter/nvim-treesitter", branch = "master", build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "rust", "lua", "toml", "markdown", "python", "javascript", "typescript", "json", "bash", "css", "html", "tsx", "scss" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end },

  -- แถบ file explorer ด้านซ้าย (Ctrl+B) ดับเบิลคลิกเปิดไฟล์ได้ — ตั้งให้ใกล้ VS Code / ใช้ง่าย
  { "nvim-neo-tree/neo-tree.nvim", branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = true,
      window = {
        position = "left",
        width = 36,
        mappings = {
          ["<space>"] = "none",
          ["h"] = "close_node",
          ["l"] = "open",
          ["<cr>"] = "open",
          ["s"] = "open_split",
          ["v"] = "open_vsplit",
          ["a"] = { "add", config = { show_path = "none" } },
          ["A"] = "add_directory",
          ["d"] = "delete",
          ["r"] = "rename",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["c"] = "copy",
          ["m"] = "move",
          ["R"] = "refresh",
          ["."] = "toggle_hidden",
          ["<bs>"] = "navigate_up",
          ["q"] = "close_window",
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        bind_to_cwd = false,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
      buffers = { follow_current_file = { enabled = true } },
    } },

  -- แท็บไฟล์ด้านบน คลิกเพื่อสลับ คลิก x เพื่อปิด
  { "akinsho/bufferline.nvim", version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          diagnostics = "nvim_lsp",
          show_buffer_close_icons = true,
          show_buffer_icons = true,
          color_icons = true,
          separator_style = "thin",
          offsets = { { filetype = "neo-tree", text = "Explorer", highlight = "Directory", separator = true } },
        },
      })
    end },

  -- ปิดไฟล์โดยไม่ทำให้หน้าต่างพัง
  { "echasnovski/mini.bufremove", version = "*", opts = {} },

  -- terminal ในตัว (Ctrl+\)
  { "akinsho/toggleterm.nvim", version = "*",
    opts = { open_mapping = [[<C-\>]], direction = "horizontal", size = 15 } },

  -- แถบสถานะ + สัญลักษณ์ git
  { "nvim-lualine/lualine.nvim", opts = { options = { theme = "auto", globalstatus = true } } },
  { "lewis6991/gitsigns.nvim", opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- เมนูช่วยจำคีย์ (กด Space แล้วรอ) — แสดงเป็นแถบด้านล่างสวยงาม ไม่ลอยบังโค้ดตรงเคอร์เซอร์
  { "folke/which-key.nvim", event = "VeryLazy",
    opts = {
      preset = "classic",
      delay = 150,
      win = {
        no_overlap = true,
        border = "rounded",
        width = 1.0,
        height = { min = 4, max = 9 },
        col = 0,
        row = math.huge,
        padding = { 1, 2 },
        title = true,
        title_pos = "center",
      },
      layout = {
        width = { min = 22, max = 45 },
        spacing = 4,
      },
      spec = {
        { "<leader>p", desc = "Command Palette" },
        { "<leader>g", desc = "ค้นหาข้อความทั้งโปรเจกต์" },
        { "<leader>b", desc = "สลับไฟล์ (Buffers)" },
        { "<leader>s", desc = "ค้นหา Symbols ในไฟล์" },
        { "<leader>fe", desc = "เปิด/ปิด File Explorer" },
        { "<leader>x", desc = "ปิดแท็บปัจจุบัน" },
        { "<leader>a", desc = "Code Action (LSP)" },
        { "<leader>df", desc = "ดูรายละเอียด Error" },
        { "<leader>F", desc = "จัดรูปแบบโค้ด (Format)" },
      },
    } },

  -- Multi-cursor แบบ VS Code: Ctrl+D เลือกคำซ้ำถัดไป, Ctrl+Shift+L เลือกคำซ้ำทั้งหมด
  { "brenton-leighton/multiple-cursors.nvim", version = "*",
    opts = {
      custom_key_maps = {
        { { "n", "i" }, "<C-s>", function() vim.cmd("w") end },
        { { "n", "i" }, "<C-/>", function() vim.cmd("normal gcc") end },
      },
    },
    keys = {
      { "<C-d>", "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = { "n", "x" }, desc = "เลือกคำซ้ำถัดไป (Ctrl+D แบบ VS Code)" },
      { "<C-S-l>", "<Cmd>MultipleCursorsAddMatches<CR>", mode = { "n", "x" }, desc = "เลือกคำซ้ำทั้งหมด" },
      { "<Leader>d", "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = { "n", "x" }, desc = "เลือกคำซ้ำถัดไป (สำรอง)" },
      { "<Leader>D", "<Cmd>MultipleCursorsAddMatches<CR>", mode = { "n", "x" }, desc = "เลือกคำซ้ำทั้งหมด (สำรอง)" },
    } },

  -- ค้นหา (Ctrl+P ค้นไฟล์, Space+p command palette)
  { "ibhagwan/fzf-lua", dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({
        file_icons = true,
        git_icons = true,
        color_icons = true,
        formatter = "path.filename_first",
        fzf_opts = { ["--layout"] = "reverse" },
      })
    end },

  -- เมนู autocomplete จาก LSP (Enter เพื่อยืนยัน) ไม่ใช้ Tab เพื่อไม่ให้ชนกับ Supermaven
  -- ป็อปอัพกรอบมน สวยแบบ VS Code ไม่ใช่สี่เหลี่ยมกลางจอ
  { "saghen/blink.cmp", version = "1.*",
    opts = {
      keymap = {
        preset = "none",
        ["<CR>"] = { "accept", "fallback" },
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-@>"] = { "show", "show_documentation", "hide_documentation" },
        -- ไม่ใช้ Option+Space เพราะชนกับ Raycast — ใช้ Fn+F1 (<F1>), Option+i (<A-i>/ˆ), Option+. (≥) แทน
        ["<F1>"] = { "show", "show_documentation", "hide_documentation" },
        ["<A-i>"] = { "show", "show_documentation", "hide_documentation" },
        ["<M-i>"] = { "show", "show_documentation", "hide_documentation" },
        ["ˆ"] = { "show", "show_documentation", "hide_documentation" },
        ["<A-.>"] = { "show", "show_documentation", "hide_documentation" },
        ["<M-.>"] = { "show", "show_documentation", "hide_documentation" },
        ["≥"] = { "show", "show_documentation", "hide_documentation" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        -- ห้ามใช้ <C-p> ที่นี่ — จะไปชนกับ Quick open (fzf-lua files) แบบ VS Code
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-l>"] = { "snippet_forward", "fallback" },
        ["<C-h>"] = { "snippet_backward", "fallback" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },  -- lsp = suggestion ตามภาษา (ts_ls, rust_analyzer ฯลฯ)
      },
      completion = {
        ghost_text = { enabled = false },   -- ให้ Supermaven เป็นคนแสดง ghost text
        documentation = { auto_show = true },
        menu = {
          border = "rounded",      -- กรอบมน
          winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
          max_height = 20,
          max_width = 100,
          min_width = 40,
          padding = 1,
          draw = {
            padding = 1,
            gap = 1,
          },
        },
        list = { max_items = 20 },
      },
      -- เมนู Auto-complete / Suggestion ตอนพิมพ์คำสั่ง : (เช่น :qa, :w, :Lazy) เด้งขึ้นมาให้เลือกอัตโนมัติ
      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<Tab>"] = { "show_and_insert", "select_next", "fallback" },
          ["<S-Tab>"] = { "show_and_insert", "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<Up>"] = { "select_prev", "fallback" },
          ["<C-n>"] = { "select_next", "fallback" },
          ["<C-p>"] = { "select_prev", "fallback" },
          ["<CR>"] = { "accept_and_enter", "fallback" },
        },
        completion = {
          list = {
            selection = {
              preselect = false,   -- พิมพ์ :qa แล้วกด Enter ได้ทันที หรือกด Tab/ลูกศรลงเพื่อเลือกจากเมนู
              auto_insert = true,
            },
          },
          menu = {
            auto_show = function(_ctx)
              return vim.fn.getcmdtype() == ":" or vim.fn.getcmdtype() == "/" or vim.fn.getcmdtype() == "?"
            end,
          },
          ghost_text = { enabled = true },
        },
      },
      signature = { enabled = true, window = { border = "rounded" } },
    } },

  -- Supermaven: AI autocomplete (กด Tab รับคำแนะนำ เหมือน Cursor)
  -- ครั้งแรกรัน :SupermavenUseFree แล้วทำตามลิงก์ที่ขึ้นมาเพื่อล็อกอิน
  { "supermaven-inc/supermaven-nvim",
    lazy = false, -- โหลดตั้งแต่เริ่ม: สี ghost text ไม่หลุดเมื่อ lazy load (ดู README ปลั๊กอิน)
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        color = { suggestion_color = "#727169", cterm = 244 }, -- fujiGray ใน Kanagawa
        log_level = "info",
        ignore_filetypes = {
          neo_tree = true,
          ["neo-tree"] = true,
          ["neo-tree-popup"] = true,
          fzf = true,
        },
      })
    end },
})

-- ===== LSP: rust-analyzer =====
-- ติดตั้งก่อน: rustup component add rust-analyzer
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  settings = {
    ["rust-analyzer"] = {
      check = { command = "clippy" },
      cargo = { allFeatures = true },
    },
  },
})
vim.lsp.enable("rust_analyzer")

-- ===== LSP เจาะจงไฟล์ Tailwind (globals.css) =====
-- ต้องติดตั้ง vscode-langservers อย่างเดียวก็พอ ใช้ npx ได้
vim.lsp.config("cssls", {
  cmd = { "npx", "--yes", "vscode-langservers", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_markers = { "package.json", ".git" },
  settings = {
    css = { validate = true, lint = { unknownAtRules = "ignore" } },
    scss = { validate = true, lint = { unknownAtRules = "ignore" } },
    less = { validate = true },
  },
})
vim.lsp.config("tailwindcss", {
  cmd = { "npx", "--yes", "tailwindcss-language-server", "--stdio" },
  filetypes = { "css", "scss", "less", "html", "javascript", "typescript", "javascriptreact", "typescriptreact" },
  root_markers = { "package.json", "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", ".git" },
  settings = {
    tailwindCSS = { validate = true, lint = { invalidAtRule = "ignore" }, includeLanguages = { css = "css", scss = "css" } },
  },
})
vim.lsp.config("html", {
  cmd = { "npx", "--yes", "vscode-langservers", "--stdio" },
  filetypes = { "html", "erb" },
  root_markers = { "package.json", ".git" },
})
vim.lsp.config("ts_ls", {
  cmd = { "npx", "--yes", "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", ".git" },
})
for _, srv in ipairs({ "cssls", "tailwindcss", "html", "ts_ls" }) do
  local ok, _ = pcall(vim.lsp.enable, srv)
  if not ok then
    vim.notify("LSP '" .. srv .. "' ยังไม่พร้อม ให้รัน: npx --yes vscode-langservers --stdio", vim.log.levels.WARN)
  end
end

-- ===== เมนู :คำสั่ง autocomplete + popup สวย =====
-- ใช้ blink.cmp cmdline แสดงรายการคำสั่งอัตโนมัติ (เช่น พิมพ์ :qa จะขึ้นรายการให้เลือกทันที)
vim.o.wildmenu = true
vim.opt.wildmode = { "longest:full", "full" }
vim.opt.wildoptions = { "pum" }
vim.o.pumheight = 15
vim.opt.completeopt = { "menu", "menuone", "noselect", "noinsert", "preview" }
vim.opt.wildignorecase = true

-- หน้าต่าง :help ให้เปิดเป็นแถบด้านล่างสุด (ไม่ผ่าครึ่งจอบนทับโค้ด)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "help",
  callback = function()
    vim.cmd("wincmd J")
    vim.cmd("resize 12")
  end,
})

-- ===== error/warning ท้ายบรรทัด =====
vim.diagnostic.config({
  virtual_text = { prefix = "■", spacing = 4 },
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  signs = true,
  float = { border = "rounded" },
})

-- ตารางเทียบปุ่มอังกฤษ -> ไทย (Kedmanee) สำหรับสร้างคีย์ลัดคู่ขนานอัตโนมัติ
local en_to_th = {
  q = "ๆ", w = "ไ", e = "ำ", r = "พ", t = "ะ", y = "ั", u = "ี", i = "ร", o = "น", p = "ย",
  a = "ฟ", s = "ห", d = "ก", f = "ด", g = "เ", h = "้", j = "่", k = "า", l = "ส",
  z = "ผ", x = "ป", c = "แ", v = "อ", b = "ิ", n = "ื", m = "ท",
  Q = "๐", W = '"', E = "ฎ", R = "ฑ", T = "ธ", Y = "ํ", U = "๊", I = "ณ", O = "ฯ", P = "ญ",
  A = "ฤ", S = "ฆ", D = "ฏ", F = "โ", G = "ฌ", H = "็", J = "๋", K = "ษ", L = "ศ",
  Z = "(", X = ")", C = "ฉ", V = "ฮ", B = "ฺ", N = "์", M = "?",
  [":"] = "ซ", ["/"] = "ฝ", ["."] = "ใ", [";"] = "ว", [","] = "ม",
  ["["] = "บ", ["]"] = "ล", ["{"] = "ฐ", ["}"] = ",",
}

-- ผูกปุ่มภาษาไทยทุกตัวในโหมด Normal, Visual, Operator-pending ให้ทำงานเหมือนปุ่มอังกฤษ 100%
for en, th in pairs(en_to_th) do
  pcall(vim.keymap.set, { "n", "x", "o" }, th, en, { remap = true, silent = true })
end

-- ถ้าเผลอพิมพ์คำสั่ง : ตอนแป้นเป็นภาษาไทย เช่น :ๆฟ (:qa), :ไ (:w), :ๆ (:q), :ไๆ (:wq) ให้แปลงเป็นอังกฤษอัตโนมัติ
vim.cmd([[
  cnoreabbrev <expr> ๆฟ (getcmdtype() == ':' && getcmdline() == 'ๆฟ') ? 'qa' : 'ๆฟ'
  cnoreabbrev <expr> ๆฟ+ (getcmdtype() == ':' && getcmdline() == 'ๆฟ+') ? 'qa!' : 'ๆฟ+'
  cnoreabbrev <expr> ๆ (getcmdtype() == ':' && getcmdline() == 'ๆ') ? 'q' : 'ๆ'
  cnoreabbrev <expr> ไ (getcmdtype() == ':' && getcmdline() == 'ไ') ? 'w' : 'ไ'
  cnoreabbrev <expr> ไๆ (getcmdtype() == ':' && getcmdline() == 'ไๆ') ? 'wq' : 'ไๆ'
]])

local function to_thai_lhs(lhs)
  -- แปลง <leader>abc -> <leader>ฟิแ
  if lhs:match("^<[lL]eader>[a-zA-Z]+$") then
    local prefix, rest = lhs:match("^(<[lL]eader>)(.+)$")
    local th = rest:gsub(".", function(ch) return en_to_th[ch] or ch end)
    if th ~= rest then return prefix .. th end
  end
  -- แปลง <C-x>, <A-x>, <M-x>, <S-x> -> คู่ปุ่มไทย
  local mod, ch = lhs:match("^<([CAMS])-([a-zA-Z])>$")
  if mod and ch and en_to_th[ch] then
    return "<" .. mod .. "-" .. en_to_th[ch] .. ">"
  end
  -- แปลงคำสั่ง 2 ตัวอักษร เช่น gd, gr
  if lhs:match("^[a-zA-Z][a-zA-Z]$") then
    local th = lhs:gsub(".", function(c) return en_to_th[c] or c end)
    if th ~= lhs then return th end
  end
  return nil
end

local function map(modes, lhs, rhs, opts)
  vim.keymap.set(modes, lhs, rhs, opts)
  local th_lhs = to_thai_lhs(lhs)
  if th_lhs then
    local th_opts = vim.tbl_extend("force", opts or {}, { silent = true })
    pcall(vim.keymap.set, modes, th_lhs, rhs, th_opts)
  end
end

-- ===== คีย์ลัด LSP =====
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local bmap = function(keys, fn, desc)
      map("n", keys, fn, { buffer = ev.buf, desc = desc })
    end
    bmap("gd", vim.lsp.buf.definition, "ไปที่ definition")
    bmap("<C-LeftMouse>", vim.lsp.buf.definition, "Ctrl+click ไปที่ definition (แบบ VS Code)")
    bmap("gr", vim.lsp.buf.references, "หา references")
    bmap("K", vim.lsp.buf.hover, "ดูเอกสาร")
    bmap("<F12>", vim.lsp.buf.definition, "ไปที่ definition")
    bmap("<F2>", vim.lsp.buf.rename, "เปลี่ยนชื่อ")
    bmap("<leader>a", vim.lsp.buf.code_action, "code action")
    bmap("<leader>df", vim.diagnostic.open_float, "ดู error / diagnostic (popup)")
    bmap("<leader>F", function() vim.lsp.buf.format({ async = true }) end, "จัดรูปแบบโค้ด")
  end,
})

-- ===== คีย์ลัดแบบ VS Code / Cursor =====
-- หมายเหตุ: terminal ส่วนใหญ่แยก Ctrl+Shift+<ตัวอักษร> ไม่ได้ จึงใช้ Space (leader) แทน
local fzf = function(fn) return function() require("fzf-lua")[fn]() end end

-- โชว์ Suggestion / ข้อมูลของโค้ดตรงเคอร์เซอร์ (ไม่ใช้ Option+Space เพราะชนกับ Raycast)
-- ใช้ได้ทั้ง:
--   1) Fn + F1 (หรือ F1)
--   2) Option + i (⌥ + i = IntelliSense / Info)
--   3) Option + . (⌥ + . เหมือน VS Code)
--   4) Space + Space (เคาะ Space 2 ครั้งในโหมดปกติ)
local function trigger_code_suggestion()
  local ok, blink = pcall(require, "blink.cmp")
  if vim.fn.mode() ~= "i" then
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients > 0 then
      vim.lsp.buf.hover()
      return
    end
    vim.cmd("startinsert")
  end
  if ok then
    vim.schedule(function()
      blink.show()
      blink.show_documentation()
      blink.show_signature()
    end)
  end
end

map("n", "<leader><space>", trigger_code_suggestion, { desc = "โชว์ข้อมูลโค้ด / Suggestion" })
for _, k in ipairs({ "<F1>", "<A-i>", "<M-i>", "ˆ", "<A-ร>", "<M-ร>", "<A-.>", "<M-.>", "≥", "<C-Space>", "<C-@>" }) do
  map("n", k, trigger_code_suggestion, { desc = "โชว์ข้อมูลโค้ด / Suggestion" })
  map("i", k, function()
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
      blink.show()
      blink.show_documentation()
      blink.show_signature()
    end
  end, { desc = "โชว์เมนู Suggestion ของโค้ด" })
end

-- บันทึก / undo / redo / เลือกทั้งหมด
map({ "n", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "บันทึก" })
map("i", "<C-s>", "<esc><cmd>w<cr>", { desc = "บันทึก" })
map("n", "<C-z>", "u", { desc = "undo" })
map("i", "<C-z>", "<C-o>u", { desc = "undo" })
map("n", "<C-y>", "<C-r>", { desc = "redo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "redo" })
map("n", "<C-a>", "ggVG", { desc = "เลือกทั้งหมด" })

-- copy / cut ตอนเลือกข้อความ (รองรับทั้ง Visual mode และ Select mode)
map("x", "<C-c>", "y", { desc = "copy" })
map("s", "<C-c>", "<C-g>y", { desc = "copy" })
map("x", "<C-x>", "d", { desc = "cut" })
map("s", "<C-x>", "<C-g>d", { desc = "cut" })

-- ค้นหา (Ctrl+P ทุกโหมดหลัก — ใน insert จะออกจาก insert แล้วเปิด fzf)
map("n", "<C-p>", fzf_open_files, { desc = "ค้นหาไฟล์" })
map("i", "<C-p>", function()
  vim.cmd("stopinsert")
  fzf_open_files()
end, { desc = "ค้นหาไฟล์" })
map("x", "<C-p>", function()
  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "n", false)
  vim.schedule(fzf_open_files)
end, { desc = "ค้นหาไฟล์" })
map("n", "<leader>p", fzf("commands"), { desc = "command palette" })
map("n", "<leader>g", fzf("live_grep"), { desc = "ค้นหาข้อความทั้งโปรเจกต์" })
map("n", "<leader>b", fzf("buffers"), { desc = "buffers" })
map("n", "<leader>s", fzf("lsp_document_symbols"), { desc = "symbols ในไฟล์" })

-- file explorer / terminal / แท็บ
map({ "n", "i" }, "<C-b>", "<cmd>Neotree toggle position=left<cr>", { desc = "เปิด/ปิด Explorer" })
map("n", "<leader>fe", "<cmd>Neotree toggle position=left<cr>", { desc = "เปิด/ปิด Explorer (สำรอง)" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "แท็บถัดไป" })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "แท็บก่อนหน้า" })
map("n", "<leader>x", function() require("mini.bufremove").delete(0, false) end, { desc = "ปิดแท็บ" })

-- คอมเมนต์บรรทัด (Ctrl+/ ; บาง terminal ส่งเป็น Ctrl+_)
map("n", "<C-/>", "gcc", { remap = true, desc = "คอมเมนต์" })
map("n", "<C-_>", "gcc", { remap = true, desc = "คอมเมนต์" })
map("x", "<C-/>", "gc", { remap = true, desc = "คอมเมนต์" })
map("x", "<C-_>", "gc", { remap = true, desc = "คอมเมนต์" })
map("s", "<C-/>", "<C-g>gc", { remap = true, desc = "คอมเมนต์" })
map("s", "<C-_>", "<C-g>gc", { remap = true, desc = "คอมเมนต์" })

-- Option + d (Alt+d / ∂ บน Mac / แป้นไทย): คลุมเฉพาะคำที่ติดกัน (word) แบบพิมพ์ทับได้ ไม่ใช่ทั้งแถว!
for _, k in ipairs({ "<A-d>", "<M-d>", "∂", "<A-ก>", "<M-ก>" }) do
  map("n", k, "viw<C-g>", { desc = "คลุมเฉพาะคำที่ติดกัน (พิมพ์ทับได้)" })
  map("i", k, "<Esc>viw<C-g>", { desc = "คลุมเฉพาะคำที่ติดกัน (พิมพ์ทับได้)" })
  map("x", k, "<Esc>viw<C-g>", { desc = "คลุมเฉพาะคำที่ติดกัน (พิมพ์ทับได้)" })
  map("s", k, "<Esc>viw<C-g>", { desc = "คลุมเฉพาะคำที่ติดกัน (พิมพ์ทับได้)" })
end

-- ย้ายบรรทัดขึ้น/ลง (Alt+j/k, Alt+ลูกศร, Alt+Shift+ลูกศร/J/K + ตัวอักษร Option บน Mac ∆/˚)
for _, k in ipairs({ "<A-j>", "<M-j>", "∆", "<A-Down>", "<A-S-j>", "<A-S-Down>" }) do
  map("n", k, "<cmd>m .+1<cr>==", { desc = "ย้ายบรรทัดลง" })
  map("i", k, "<esc><cmd>m .+1<cr>==gi", { desc = "ย้ายบรรทัดลง" })
  map("x", k, ":m '>+1<cr>gv=gv", { desc = "ย้ายบรรทัดลง" })
  map("s", k, "<C-g>:m '>+1<cr>gv=gv<C-g>", { desc = "ย้ายบรรทัดลง" })
end
for _, k in ipairs({ "<A-k>", "<M-k>", "˚", "<A-Up>", "<A-S-k>", "<A-S-Up>" }) do
  map("n", k, "<cmd>m .-2<cr>==", { desc = "ย้ายบรรทัดขึ้น" })
  map("i", k, "<esc><cmd>m .-2<cr>==gi", { desc = "ย้ายบรรทัดขึ้น" })
  map("x", k, ":m '<-2<cr>gv=gv", { desc = "ย้ายบรรทัดขึ้น" })
  map("s", k, "<C-g>:m '<-2<cr>gv=gv<C-g>", { desc = "ย้ายบรรทัดขึ้น" })
end

-- ย้ายเคอร์เซอร์ไปหน้าสุด / ท้ายสุดของโค้ดในบรรทัด (ไม่คลุมข้อความ)
-- Home / Ctrl+A (insert) / gh = หน้าสุดของโค้ดในบรรทัด (ข้ามช่องว่างย่อหน้า)
-- End  / Ctrl+E (insert) / gl = ท้ายสุดของโค้ดในบรรทัด
map("n", "<Home>", "^", { desc = "ไปหน้าสุดของโค้ดในบรรทัด" })
map("i", "<Home>", "<C-o>^", { desc = "ไปหน้าสุดของโค้ดในบรรทัด" })
map("n", "<End>", "$", { desc = "ไปท้ายสุดของโค้ดในบรรทัด" })
map("i", "<End>", "<End>", { desc = "ไปท้ายสุดของโค้ดในบรรทัด" })
map({ "n", "x" }, "gh", "^", { desc = "ไปหน้าสุดของโค้ดในบรรทัด" })
map({ "n", "x" }, "gl", "g_", { desc = "ไปท้ายสุดของโค้ดในบรรทัด" })
map("n", "<C-e>", "$", { desc = "ไปท้ายสุดของโค้ดในบรรทัด" })
map("i", "<C-e>", "<End>", { desc = "ไปท้ายสุดของโค้ดในบรรทัด" })
map("i", "<C-a>", "<C-o>^", { desc = "ไปหน้าสุดของโค้ดในบรรทัด" })

-- Option + ซ้าย/ขวา: คลุมข้อความทีละคำ/ทีละท่อน (ไม่คลุมทั้งแถว!) กดซ้ำเพื่อคลุมคำถัดไปต่อได้เรื่อยๆ
for _, k in ipairs({ "<A-Right>", "<M-Right>", "<A-S-Right>", "<M-S-Right>", "<M-f>", "<A-f>" }) do
  map("n", k, "ve<C-g>", { desc = "คลุมคำถัดไปทางขวา (พิมพ์ทับได้)" })
  map("i", k, "<C-o>ve<C-g>", { desc = "คลุมคำถัดไปทางขวา (พิมพ์ทับได้)" })
  map("x", k, "e<C-g>", { desc = "ขยายคลุมคำถัดไปทางขวา" })
  map("s", k, "<C-g>e<C-g>", { desc = "ขยายคลุมคำถัดไปทางขวา" })
end
for _, k in ipairs({ "<A-Left>", "<M-Left>", "<A-S-Left>", "<M-S-Left>", "<M-b>", "<A-b>" }) do
  map("n", k, "vb<C-g>", { desc = "คลุมคำก่อนหน้าทางซ้าย (พิมพ์ทับได้)" })
  map("i", k, "<Esc>vb<C-g>", { desc = "คลุมคำก่อนหน้าทางซ้าย (พิมพ์ทับได้)" })
  map("x", k, "b<C-g>", { desc = "ขยายคลุมคำก่อนหน้าทางซ้าย" })
  map("s", k, "<C-g>b<C-g>", { desc = "ขยายคลุมคำก่อนหน้าทางซ้าย" })
end

-- ตอนคลุมข้อความอยู่ กด Backspace หรือ Delete ให้ลบที่คลุมแล้วเข้าโหมดพิมพ์ต่อทันที (เหมือน VS Code)
map("x", "<BS>", '"_c', { desc = "ลบที่คลุมแล้วพิมพ์ต่อ" })
map("x", "<Del>", '"_c', { desc = "ลบที่คลุมแล้วพิมพ์ต่อ" })
map("s", "<BS>", "<C-g>\"_c", { desc = "ลบที่คลุมแล้วพิมพ์ต่อ" })
map("s", "<Del>", "<C-g>\"_c", { desc = "ลบที่คลุมแล้วพิมพ์ต่อ" })

-- ตอนคลุมข้อความใน Select mode ถ้ากดลูกศรธรรมดา ให้ยกเลิกการคลุมแล้วย้ายเคอร์เซอร์เหมือน VS Code
for _, arrow in ipairs({ "<Left>", "<Right>", "<Up>", "<Down>" }) do
  map("s", arrow, "<Esc>" .. arrow, { desc = "ยกเลิกคลุมแล้วย้ายเคอร์เซอร์" })
end

map("n", "<esc>", "<cmd>nohlsearch<cr>")

-- Shift+Delete ลบบรรทัดทั้งบรรทัด (แบบ VS Code) + Ctrl+Shift+K สำรอง
-- (บาง terminal ดัก Shift+Delete ไว้เป็น Cut เอง ถ้าไม่ติดให้ใช้ Ctrl+Shift+K แทน)
for _, k in ipairs({ "<S-Del>", "<C-S-k>" }) do
  map("n", k, "dd", { desc = "ลบบรรทัดทั้งบรรทัด" })
  map("i", k, "<C-o>dd", { desc = "ลบบรรทัดทั้งบรรทัด" })
  map("x", k, "d", { desc = "ลบบรรทัดที่เลือก" })
  map("s", k, "<C-g>d", { desc = "ลบบรรทัดที่เลือก" })
end

-- Ctrl+D ตอนนี้คือเลือกคำซ้ำแบบ VS Code ผ่าน multiple-cursors.nvim (ดู keys ใน plugin spec ด้านบน)
-- เลือกทั้งบรรทัดใช้ V แทน

-- :CargoCheck - รัน cargo check แบบไม่บล็อกหน้าจอ (เปิด terminal ล่าง)
-- Windows: ต้องโหลด vcvars64 ก่อน ไม่งั้นหา cl.exe ไม่เจอ
-- macOS/Linux: รัน cargo check ตรง ๆ ได้เลย (ใช้ clang จาก Xcode CLT / gcc)
vim.api.nvim_create_user_command("CargoCheck", function()
  vim.cmd("split | terminal")
  if vim.fn.has("win32") == 1 then
    local vcvars = "C:\\Program Files\\Microsoft Visual Studio\\18\\Community\\VC\\Auxiliary\\Build\\vcvars64.bat"
    vim.cmd("call term_sendkeys(bufnr('%'), 'call \"' .. vcvars .. '\" >nul && cargo check\\<CR>')")
  else
    vim.cmd("call term_sendkeys(bufnr('%'), 'cargo check\\<CR>')")
  end
end, { desc = "cargo check" })
