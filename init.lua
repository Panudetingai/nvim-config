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
                bg = "#1f1f1f",        -- พื้นหลัง editor เข้มลึก (เดิม #1f1f28)
                bg_dim = "#181818",    -- พื้นหลังหน้าต่างข้างเคียง/sidebar
                bg_gutter = "none",    -- แถบเลขบรรทัดกลืนเป็นเนื้อเดียวกับพื้นหลัง editor
                bg_m3 = "#181818",
                bg_m2 = "#1b1b1b",
                bg_m1 = "#202020",
                bg_p1 = "#282828",     -- บรรทัดเคอร์เซอร์ / popup เข้มกำลังดี
                bg_p2 = "#313131",     -- แถบที่ถูกเลือกในเมนู
              },
            },
          },
        },
        overrides = function(colors)
          local theme = colors.theme
          return {
            -- พื้นหลัง editor และขอบหน้าต่างเข้มลึก คอนทราสต์กับสีโค้ดชัดเจน
            Normal = { fg = theme.ui.fg, bg = "#1f1f1f" },
            NormalNC = { fg = theme.ui.fg_dim, bg = "#1f1f1f" },
            SignColumn = { bg = "#1f1f1f" },
            LineNr = { fg = "#6e7681", bg = "#1f1f1f" },
            CursorLine = { bg = "#282828" },
            CursorLineNr = { fg = theme.diag.warning, bg = "#282828", bold = true },
            WinSeparator = { fg = "#2b2b2b", bg = "#1f1f1f" },
            -- ปรับเมนู/popup และ Neo-tree ให้เข้ากับพื้นหลังเข้ม
            NormalFloat = { bg = "#202020" },
            FloatBorder = { fg = "#3c3c3c", bg = "#202020" },
            FloatTitle = { fg = theme.syn.fun, bold = true, bg = "#202020" },
            BlinkCmpMenu = { fg = theme.ui.fg, bg = "#202020" },
            BlinkCmpMenuBorder = { fg = "#2b2b2b", bg = "#202020" },
            BlinkCmpMenuSelection = { fg = "NONE", bg = "#313131", bold = true },
            NeoTreeNormal = { fg = theme.ui.fg_dim, bg = "#181818" },
            NeoTreeNormalNC = { fg = theme.ui.fg_dim, bg = "#181818" },
            NeoTreeEndOfBuffer = { fg = "#181818", bg = "#181818" },
            NeoTreeFileIcon = { fg = theme.ui.special },
            NeoTreeDirectoryIcon = { fg = theme.syn.fun },
            NeoTreeDirectoryName = { fg = theme.syn.fun, bold = true },
            NeoTreeRootName = { fg = theme.syn.keyword, bold = true },
            -- สีโค้ดชุด Claude: keyword ส้ม / string เขียว / function ฟ้า / type ทอง / number ม่วง
            Normal = { fg = "#cccccc", bg = "#1f1f1f" },
            Keyword = { fg = "#569cd6" }, Statement = { fg = "#c586c0" },
            Conditional = { fg = "#c586c0" }, Repeat = { fg = "#c586c0" }, Include = { fg = "#569cd6" },
            ["@keyword"] = { fg = "#569cd6" }, ["@keyword.function"] = { fg = "#569cd6" },
            ["@keyword.import"] = { fg = "#569cd6" }, ["@keyword.modifier"] = { fg = "#569cd6" },
            ["@keyword.storage"] = { fg = "#569cd6" }, ["@keyword.type"] = { fg = "#569cd6" },
            ["@keyword.conditional"] = { fg = "#c586c0" }, ["@keyword.repeat"] = { fg = "#c586c0" },
            ["@keyword.return"] = { fg = "#c586c0" }, ["@keyword.exception"] = { fg = "#c586c0" },
            String = { fg = "#ce9178" }, ["@string"] = { fg = "#ce9178" }, ["@string.escape"] = { fg = "#d7ba7d" },
            Function = { fg = "#dcdcaa" }, ["@function"] = { fg = "#dcdcaa" }, ["@function.call"] = { fg = "#dcdcaa" },
            ["@function.method"] = { fg = "#dcdcaa" }, ["@function.method.call"] = { fg = "#dcdcaa" },
            ["@function.macro"] = { fg = "#dcdcaa" },
            Type = { fg = "#4ec9b0" }, ["@type"] = { fg = "#4ec9b0" }, ["@type.builtin"] = { fg = "#569cd6" },
            ["@constructor"] = { fg = "#4ec9b0" }, ["@module"] = { fg = "#9cdcfe" },
            Constant = { fg = "#4fc1ff" }, ["@constant"] = { fg = "#4fc1ff" },
            Number = { fg = "#b5cea8" }, Float = { fg = "#b5cea8" }, Boolean = { fg = "#569cd6" },
            ["@number"] = { fg = "#b5cea8" }, ["@boolean"] = { fg = "#569cd6" },
            Comment = { fg = "#6a9955" }, ["@comment"] = { fg = "#6a9955" }, ["@comment.documentation"] = { fg = "#6a9955" },
            ["@variable"] = { fg = "#9cdcfe" }, ["@variable.parameter"] = { fg = "#9cdcfe" },
            ["@property"] = { fg = "#9cdcfe" }, ["@variable.member"] = { fg = "#9cdcfe" },
            ["@variable.builtin"] = { fg = "#569cd6" }, ["@lifetime"] = { fg = "#569cd6" },
            ["@punctuation.bracket"] = { fg = "#ffd700" }, ["@punctuation.delimiter"] = { fg = "#cccccc" },
            ["@operator"] = { fg = "#cccccc" }, Operator = { fg = "#cccccc" },
            ["@attribute"] = { fg = "#4ec9b0" },
            -- โทนส้ม Claude Code (#d97757)
            CursorLineNr = { fg = "#d97757", bg = "#282828", bold = true },
            Visual = { bg = "#264f78" },
            Search = { fg = "#1f1f1f", bg = "#d97757" },
            IncSearch = { fg = "#1f1f1f", bg = "#e8a07f" },
            PmenuSel = { bg = "#313131", bold = true },
            BlinkCmpMenuSelection = { bg = "#3a2f29", bold = true },
            NeoTreeDirectoryName = { fg = "#d97757", bold = true },
            NeoTreeDirectoryIcon = { fg = "#d97757" },
            NeoTreeRootName = { fg = "#e8a07f", bold = true },
            BufferLineBufferSelected = { fg = "#d97757", bold = true },
            WhichKeyNormal = { bg = "#181818" },
            WhichKeyBorder = { fg = "#2b2b2b", bg = "#181818" },
            WhichKeyTitle = { fg = theme.syn.fun, bg = "#181818", bold = true },
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
  -- branch main: master พังกับ Neovim 0.12 (error "attempt to call method 'range'"); ต้องมี tree-sitter CLI
  { "nvim-treesitter/nvim-treesitter", branch = "main", lazy = false, build = ":TSUpdate",
    config = function()
      local langs = { "rust", "lua", "toml", "markdown", "python", "javascript", "typescript", "json", "bash", "css", "html", "tsx", "scss" }
      require("nvim-treesitter").install(langs)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "rust", "lua", "toml", "markdown", "python", "javascript", "typescript", "typescriptreact", "javascriptreact", "json", "sh", "bash", "css", "html", "scss" },
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
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
          ["<C-n>"] = { "add", config = { show_path = "none" } }, -- ลงท้ายด้วย / = สร้างโฟลเดอร์
          ["a"] = { "add", config = { show_path = "none" } },
          ["<F2>"] = "rename",
          ["<Del>"] = "delete",
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
        highlights = {
          fill = { bg = "#181818" },
          background = { fg = "#6e7681", bg = "#181818" },
          buffer_selected = { fg = "#e8e6dc", bg = "#1f1f1f", bold = true, italic = false },
          buffer_visible = { fg = "#9a9890", bg = "#181818" },
          separator = { fg = "#181818", bg = "#181818" },
          separator_selected = { fg = "#181818", bg = "#1f1f1f" },
          separator_visible = { fg = "#181818", bg = "#181818" },
          indicator_selected = { fg = "#d97757", bg = "#1f1f1f" },
          modified = { fg = "#d97757", bg = "#181818" },
          modified_selected = { fg = "#d97757", bg = "#1f1f1f" },
          close_button_selected = { fg = "#d97757", bg = "#1f1f1f" },
          offset_separator = { fg = "#181818", bg = "#181818" },
        },
        options = {
          mode = "buffers",
          style_preset = require("bufferline").style_preset.no_italic,
          indicator = { style = "underline" },
          -- ซ่อนบัฟเฟอร์ไร้ชื่อ ([No Name]) ไม่ให้โผล่เป็นแท็บ
          custom_filter = function(b)
            return not (vim.bo[b].buftype == "" and vim.api.nvim_buf_get_name(b) == "")
          end,
          diagnostics = "nvim_lsp",
          show_buffer_close_icons = true,
          show_buffer_icons = true,
          color_icons = true,
          separator_style = "slant",
          offsets = { { filetype = "neo-tree", text = function() return "  " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") end, highlight = "Directory", separator = true } },
        },
      })
    end },

  -- ปิดไฟล์โดยไม่ทำให้หน้าต่างพัง
  { "echasnovski/mini.bufremove", version = "*", opts = {} },

  -- terminal ในตัว (Ctrl+\)
  { "akinsho/toggleterm.nvim", version = "*",
    opts = { open_mapping = [[<C-\>]], direction = "horizontal", size = 15 } },

  -- แถบสถานะ + สัญลักษณ์ git
  -- สีโหมดชัดเจน: NORMAL ส้ม / INSERT เขียว / VISUAL ฟ้า
  { "nvim-lualine/lualine.nvim",
    opts = function()
      local bg = "#1f1f1f"
      local function mode(c) return { a = { fg = bg, bg = c, gui = "bold" }, b = { fg = c, bg = "#282828" }, c = { fg = "#c2c0b6", bg = bg } } end
      return { sections = {
        lualine_b = { "branch", "diagnostics" },
        -- โฟลเดอร์โปรเจกต์ (cwd) + path ของไฟล์ที่เปิดอยู่ (relative)
        lualine_c = {
          { function() return "  " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") end, color = { fg = "#d97757", gui = "bold" } },
          { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "" } },
        },
      }, options = { globalstatus = true, theme = {
        normal = mode("#d97757"), insert = mode("#8fb573"), visual = mode("#6a9bcc"),
        replace = mode("#c15f5f"), command = mode("#e8c26b"), terminal = mode("#8fb573"),
        inactive = mode("#6e7681"),
      } } }
    end },
  { "lewis6991/gitsigns.nvim", opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- วงเล็บหลายสีแบบ VS Code (เหลือง / ม่วง / ฟ้า)
  { "HiPhish/rainbow-delimiters.nvim", event = "BufReadPost",
    config = function()
      local hl = { RainbowDelimiterYellow = "#ffd700", RainbowDelimiterViolet = "#da70d6", RainbowDelimiterBlue = "#179fff" }
      local function set() for g, c in pairs(hl) do vim.api.nvim_set_hl(0, g, { fg = c }) end end
      set()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set })
      require("rainbow-delimiters.setup").setup({
        highlight = { "RainbowDelimiterYellow", "RainbowDelimiterViolet", "RainbowDelimiterBlue" },
      })
    end },

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
        { "<leader>s", desc = "ฟังก์ชัน/คลาสในไฟล์นี้" },
        { "<leader>sw", desc = "ฟังก์ชันทั้งโปรเจกต์ (workspace)" },
        { "<leader>fe", desc = "เปิด/ปิด File Explorer" },
        { "<leader>x", desc = "ปิดแท็บปัจจุบัน" },
        { "<leader>a", desc = "Code Action (LSP)" },
        { "<leader>df", desc = "ดูรายละเอียด Error" },
        { "<leader>F", desc = "จัดรูปแบบโค้ด (Format)" },
      },
    } },

  -- Multi-cursor แบบ VS Code: Ctrl+D เลือกคำซ้ำถัดไป, Ctrl+Shift+L เลือกคำซ้ำทั้งหมด
  { "brenton-leighton/multiple-cursors.nvim", version = "*",
    config = function(_, opts)
      require("multiple-cursors").setup(opts)
      -- workaround: สลับแท็บตอน multi-cursor ค้างอยู่ ปลั๊กอินลบ keymap ที่ไม่มีแล้วพ่น E31 → ให้ข้ามตัวที่ไม่มี
      local km = require("multiple-cursors.key_maps")
      local orig = km.delete
      km.delete = function(...)
        local del = vim.keymap.del
        vim.keymap.del = function(...) pcall(del, ...) end
        local ok, err = pcall(orig, ...)
        vim.keymap.del = del
        if not ok then error(err) end
      end
    end,
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
      fuzzy = { implementation = "prefer_rust_with_warning" },
      keymap = {
        preset = "none",
        ["<CR>"] = { "accept", "fallback" },
        -- กด Ctrl+Space = เปิดเมนู suggestion (ไม่สลับปิด docs แบบ default preset)
        ["<C-space>"] = { "show", "show_documentation", "show_signature" },
        ["<C-@>"] = { "show", "show_documentation", "show_signature" },
        -- ไม่ใช้ Option+Space เพราะชนกับ Raycast — ใช้ Fn+F1 (<F1>), Option+i (<A-i>/ˆ), Option+. (≥) แทน
        ["<F1>"] = { "show", "show_documentation", "show_signature" },
        ["<A-i>"] = { "show", "show_documentation", "show_signature" },
        ["<M-i>"] = { "show", "show_documentation", "show_signature" },
        ["ˆ"] = { "show", "show_documentation", "show_signature" },
        ["<A-.>"] = { "show", "show_documentation", "show_signature" },
        ["<M-.>"] = { "show", "show_documentation", "show_signature" },
        ["≥"] = { "show", "show_documentation", "show_signature" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
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
        providers = {
          lsp = {
            -- กด Ctrl+Space แม้ยังไม่พิมพ์คำ → ยังโชว์รายการ method/function ได้
            min_keyword_length = function(ctx)
              return ctx.trigger.kind == "manual" and 0 or 1
            end,
          },
        },
      },
      completion = {
        ghost_text = { enabled = false },   -- ให้ Supermaven เป็นคนแสดง ghost text
        documentation = { auto_show = true },
        trigger = {
          show_on_trigger_character = true,
          show_on_insert_on_trigger_character = true,
          show_in_snippet = true,
        },
        menu = {
          auto_show = true,
          auto_show_delay_ms = 150,
          border = "rounded",      -- กรอบมน
          winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
          max_height = 24,
          max_width = 100,
          min_width = 40,
          padding = 1,
          draw = {
            padding = 1,
            gap = 1,
            treesitter_lsp = true,
          },
        },
        list = { max_items = 50, cycle = { from_top = true, from_bottom = true } },
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
              -- ไม่โชว์เมนูเมื่อพิมพ์ :! (shell) — เมนูจะค้างทับผลลัพธ์คำสั่ง
              if vim.fn.getcmdline():match("^%s*!") then return false end
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
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luacheckrc", ".git" },
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      completion = { callSnippet = "Both", keywordSnippet = "Both" },
    },
  },
})
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
  settings = { python = { analysis = { typeCheckingMode = "basic", autoSearchPaths = true, useLibraryCodeForTypes = true } } },
})
for _, srv in ipairs({ "cssls", "tailwindcss", "html", "ts_ls", "lua_ls", "pyright" }) do
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
local function blink_suggest()
  local ok, blink = pcall(require, "blink.cmp")
  if not ok then return end
  vim.schedule(function()
    blink.show()
    blink.show_documentation()
    blink.show_signature()
  end)
end

-- โหมด Normal: Ctrl+Space → เข้า Insert แล้วเปิดเมนู suggestion ของ LSP
local function trigger_code_suggestion()
  if vim.fn.mode() == "i" then
    blink_suggest()
    return
  end
  if vim.fn.mode() == "n" then
    vim.cmd("startinsert!")
  end
  blink_suggest()
end

map("n", "<leader><space>", trigger_code_suggestion, { desc = "Suggestion / IntelliSense (Ctrl+Space)" })
for _, k in ipairs({ "<F1>", "<A-i>", "<M-i>", "ˆ", "<A-ร>", "<M-ร>", "<A-.>", "<M-.>", "≥", "<C-Space>", "<C-@>" }) do
  map("n", k, trigger_code_suggestion, { desc = "Suggestion / IntelliSense" })
end
-- Insert: ใช้ keymap ของ blink.cmp เป็นหลัก (ไม่ซ้ำซ้อนกับ mapping ข้างบน)
map("i", "<F1>", blink_suggest, { desc = "Suggestion (สำรองถ้า Ctrl+Space ถูก IME ดัก)" })

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
map("n", "<leader>s", fzf("lsp_document_symbols"), { desc = "ฟังก์ชัน/คลาสในไฟล์นี้" })
map("n", "<leader>sw", fzf("lsp_live_workspace_symbols"), { desc = "ค้นหาฟังก์ชันทั้งโปรเจกต์" })

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

-- ===== หน้าเริ่มต้น (แทน [No Name]) : แสดงเมื่อเปิด nvim เปล่าๆ ไม่มีไฟล์ =====
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() > 0 or vim.api.nvim_buf_get_name(0) ~= "" or vim.api.nvim_buf_line_count(0) > 1 then return end
    local lines = {
      "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
      "████╗  ██║██║   ██║██║████╗ ████║",
      "██╔██╗ ██║██║   ██║██║██╔████╔██║",
      "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
      "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
      "",
      "Get started with 4 keys",
      "",
      "Ctrl+N     New file",
      "Ctrl+P     Find file",
      "Ctrl+B     File explorer",
      "Space g    Search in project",
    }
    local old = vim.api.nvim_get_current_buf()
    local buf = vim.api.nvim_create_buf(false, true)
    local pad_top = math.max(0, math.floor((vim.o.lines - #lines) / 2) - 1)
    local out = {}
    for _ = 1, pad_top do out[#out + 1] = "" end
    local ns = vim.api.nvim_create_namespace("start")
    -- ทุกบรรทัดชิดซ้ายที่คอลัมน์เดียวกัน (บล็อกรวมอยู่กลางจอ แต่ข้อความไม่จัดกึ่งกลางทีละบรรทัด)
    local maxw = 0
    for _, l in ipairs(lines) do maxw = math.max(maxw, vim.fn.strdisplaywidth(l)) end
    local pad = string.rep(" ", math.max(0, math.floor((vim.o.columns - maxw) / 2)))
    for _, l in ipairs(lines) do out[#out + 1] = pad .. l end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
    vim.api.nvim_set_hl(0, "StartLogo", { fg = "#d97757", bold = true })
    vim.api.nvim_set_hl(0, "StartKey", { fg = "#1f1f1f", bg = "#d97757", bold = true })
    vim.api.nvim_set_hl(0, "StartDim", { fg = "#6e7681" })
    for i = 1, #lines do
      local row = pad_top + i - 1
      local group = i <= 6 and "StartLogo" or (i == 8 and "StartDim")
      if group then vim.api.nvim_buf_add_highlight(buf, ns, group, row, 0, -1) end
      if i >= 10 then -- ไฮไลต์ส่วนชื่อปุ่ม
        local s = out[row + 1]:find("%S")
        local key = lines[i]:match("^(%S+%s?%S*)%s%s") -- "Ctrl+N" / "Space g"
        vim.api.nvim_buf_set_extmark(buf, ns, row, s - 1, { end_col = s - 1 + #key, hl_group = "StartKey" })
      end
    end
    vim.bo[buf].bufhidden, vim.bo[buf].modifiable, vim.bo[buf].filetype = "wipe", false, "start"
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_buf_delete(old, { force = true }) -- ลบ [No Name] เดิม ไม่ให้โผล่เป็นแท็บ
    for _, opt in ipairs({ "number", "cursorline", "list" }) do vim.wo[opt] = false end
    vim.wo.signcolumn = "no"
  end,
})

-- ตั้งค่าหน้าต่างตามบัฟเฟอร์ที่แสดงอยู่ทุกครั้ง (รวม split/ย้ายบัฟเฟอร์)
-- หน้า start = ไม่มีเลขบรรทัด; ไฟล์ปกติ = มีเลขบรรทัดเสมอ (กัน option หน้า start ติดไปที่ window อื่น)
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  callback = function()
    local start = vim.bo.filetype == "start"
    if not start and vim.bo.buftype ~= "" then return end
    vim.wo.number, vim.wo.cursorline = not start, not start
    vim.wo.signcolumn = start and "no" or "yes"
  end,
})

-- ปิดเมนู completion ทุกครั้งที่ออกจาก : (กันหน้าต่างลอยค้างทับหน้าจอ)
vim.api.nvim_create_autocmd("CmdlineLeave", {
  callback = function() pcall(function() require("blink.cmp").hide() end) end,
})

-- ===== สลับโหมดง่ายๆ =====
-- jk (หรือ ่า บนแป้นไทย) ใน Insert = กลับ Normal; Esc Esc ออกจาก terminal
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "่า", "<Esc>")
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]])
-- Shift+ลูกศร = เลือกแบบ VS Code (Select mode), Ctrl+G สลับ Select<->Visual, v/V เลือก, i/a พิมพ์
-- เคอร์เซอร์เปลี่ยนรูปตามโหมด: Normal=บล็อก, Insert=เส้นตั้ง
vim.o.guicursor = "n-c:block,i-ci-ve:ver25,r-cr-o:hor20,v-sm:block-blinkon500-blinkoff300"

-- Ctrl+N: สร้างไฟล์ใหม่ (พิมพ์ชื่อ เช่น src/a.lua; ลงท้าย / = โฟลเดอร์) ในโฟลเดอร์ของไฟล์ปัจจุบัน
-- ใน Explorer ใช้ Ctrl+N ของ neo-tree แทน (สร้างในโฟลเดอร์ที่เลือก)
local function new_file()
  local cur = vim.api.nvim_buf_get_name(0)
  local dir = (cur ~= "" and vim.bo.buftype == "") and vim.fn.fnamemodify(cur, ":p:h") or vim.fn.getcwd()
  vim.ui.input({ prompt = "ไฟล์ใหม่ใน " .. vim.fn.fnamemodify(dir, ":~:.") .. "/ : ", completion = "file" }, function(name)
    if not name or name == "" then return end
    local path = vim.fs.normalize(dir .. "/" .. name)
    if name:sub(-1) == "/" then
      vim.fn.mkdir(path, "p")
      return vim.notify("สร้างโฟลเดอร์ " .. path)
    end
    vim.fn.mkdir(vim.fs.dirname(path), "p")
    vim.cmd.edit(vim.fn.fnameescape(path))
    vim.cmd("silent! write")
  end)
end
map({ "n", "i" }, "<C-n>", function() vim.cmd("stopinsert"); new_file() end, { desc = "สร้างไฟล์ใหม่" })

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
