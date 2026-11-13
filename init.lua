-- Neovim 0.11+ : terminal editor ที่ใกล้ Cursor/VS Code (Supermaven + LSP + เมาส์ + แท็บ + file explorer)
-- วางที่ ~/.config/nvim/init.lua
-- ต้องใช้ Nerd Font ใน terminal เพื่อให้ไอคอนแสดงถูกต้อง (เช่น JetBrainsMono Nerd Font)

vim.g.mapleader = " "
if vim.loader then vim.loader.enable() end  -- cache bytecode ของ lua → เปิด nvim เร็วขึ้น

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
  -- Theme หลัก: Catppuccin Mocha (สวย นุ่มตา คอนทราสต์ดี) — ธีม Kanagawa เดิมยังอยู่ สลับได้ด้วย :colorscheme kanagawa
  { "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        term_colors = true,
        transparent_background = false,
        styles = { comments = { "italic" }, keywords = { "italic" }, functions = {} },
        integrations = {
          neotree = true, treesitter = true, blink_cmp = true, gitsigns = true, which_key = true,
          rainbow_delimiters = true, fzf = true, bufferline = true, native_lsp = { enabled = true },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end },

  { "rebelot/kanagawa.nvim", lazy = true,
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
        -- ไอคอน CSS ดั้งเดิม (U+E6B8) ไม่มีในฟอนต์ Nerd Font รุ่นเก่า → ใช้ css3 (U+E749) ที่มีทุกรุ่น
        override_by_extension = {
          css = { icon = vim.fn.nr2char(0xe749), color = "#42a5f5", name = "Css" },
          scss = { icon = vim.fn.nr2char(0xe749), color = "#f55385", name = "Scss" },
        },
        override_by_filename = {
          ["globals.css"] = { icon = vim.fn.nr2char(0xe749), color = "#42a5f5", name = "GlobalsCss" },
        },
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
      -- หมายเหตุ: "jsx" ไม่ใช่ parser แยกใน nvim-treesitter main (ไม่มีไฟล์ jsx.so)
      -- tree-sitter-javascript ครอบ JSX อยู่แล้ว ไฟล์ .jsx/.js (javascriptreact) จึงใช้ "javascript"
      local langs = { "rust", "lua", "toml", "markdown", "python", "javascript", "typescript", "json", "bash", "css", "html", "tsx", "scss" }
      require("nvim-treesitter").install(langs)
      -- map filetype -> parser ชื่อให้ตรง (typescriptreact=tsx, javascriptreact=javascript)
      local ft_to_lang = {
        typescriptreact = "tsx", javascriptreact = "javascript",
        typescript = "typescript", javascript = "javascript",
        sh = "bash",
      }
      local installing = {}
      local function ensure_ts(buf)
        if not vim.api.nvim_buf_is_valid(buf) then return end
        local ft = vim.bo[buf].filetype
        if ft == "" then return end
        -- ถ้าไฮไลต์ยังทำงานอยู่ ไม่เริ่มซ้อน; ถ้าหลุดไปแล้ว (เช่นหลัง :e reload ไฟล์)
        -- ให้เริ่มใหม่ทันที — เดิมมีตัวกัน ts_started ที่บล็อกไม่ให้เริ่มซ้ำเลย สีเลยหายถาวร
        if vim.treesitter.highlighter.active[buf] then return end
        local lang = ft_to_lang[ft] or vim.treesitter.language.get_lang(ft)
        if not lang then return end
        local ok = pcall(vim.treesitter.start, buf, lang)
        if ok then
          vim.b[buf].ts_retry = 0
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          return
        end
        -- parser ยังไม่มี/โหลดไม่ได้: เปิด syntax แบบเก่าไว้ก่อน จะได้มีสีบ้างระหว่างรอ parser
        vim.bo[buf].syntax = ft
        if not installing[lang] then
          installing[lang] = true
          pcall(function()
            require("nvim-treesitter").install({ lang }, { summary = false })
          end)
          vim.defer_fn(function() installing[lang] = nil end, 10000)
        end
        -- ติดตั้งเสร็จจะไม่มี event มาบอกไฟล์ที่เปิดอยู่: ตั้งเวลาลองเปิดไฮไลต์ใหม่อัตโนมัติ
        local retry = (vim.b[buf].ts_retry or 0) + 1
        vim.b[buf].ts_retry = retry
        if retry <= 5 then
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(buf) then ensure_ts(buf) end
          end, 2500)
        end
      end
      -- เรียกตอนเปิดไฟล์/สลับ buffer/แสดงหน้าต่าง/โหลดไฟล์ใหม่ (:e) — ไฟล์ที่ไฮไลต์หลุดจะถูกเปิดใหม่เอง
      vim.api.nvim_create_autocmd({ "FileType", "BufReadPost", "BufNewFile", "BufEnter", "BufWinEnter" }, {
        pattern = { "rust", "lua", "toml", "markdown", "python", "javascript", "typescript", "typescriptreact", "javascriptreact", "json", "sh", "bash", "css", "html", "scss" },
        callback = function(ev) ensure_ts(ev.buf) end,
      })
    end },

  -- แถบ file explorer ด้านซ้าย (Ctrl+B) ดับเบิลคลิกเปิดไฟล์ได้ — ตั้งให้ใกล้ VS Code / ใช้ง่าย
  { "nvim-neo-tree/neo-tree.nvim", branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    opts = {
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = true,
      -- ใช้หน้าต่างยืนยันของ Neovim แทน popup ของ neo-tree: กด d ลบแล้วกด Enter = Yes / Esc = ไม่ลบ
      -- เดิม popup ต้องพิมพ์ y + Enter และแป้นไทยพิมพ์ y ไม่ได้ (ได้ ย) เลยค้าง/ยกเลิก
      use_popups_for_input = false,
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
          ["<Tab>"] = "select",        -- กด Tab เพื่อเลือกไฟล์/โฟลเดอร์ทีละตัว (เลือกหลายตัวได้) แล้วกด d ลบพร้อมกัน
          ["<C-;>"] = "clear_selection", -- ล้างรายการที่เลือกไว้ทั้งหมด
          ["<C-n>"] = { "add", config = { show_path = "none" } }, -- ลงท้ายด้วย / = สร้างโฟลเดอร์
          -- พิมพ์ครั้งเดียวสร้างหลายตัวได้ด้วย {a,b,c} เช่น {index,about,contact}.html หรือ {css,js,images}/
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
      -- ไอคอนแบบ VS Code (Nerd Font): โฟลเดอร์ปิด/เปิด/ว่าง + ไอคอนไฟล์ตามนามสกุลจาก web-devicons + สัญลักษณ์ git
      default_component_configs = {
        -- ใช้รหัส codepoint (nr2char) แทนการพิมพ์อักขระ Nerd Font ตรงๆ — กันอักขระหายตอนแก้ไฟล์
        indent = { with_markers = true, indent_marker = "│", last_indent_marker = "└", with_expanders = true,
          expander_collapsed = vim.fn.nr2char(0xf105), expander_expanded = vim.fn.nr2char(0xf107) },
        icon = {
          folder_closed = vim.fn.nr2char(0xf07b), folder_open = vim.fn.nr2char(0xf07c),
          folder_empty = vim.fn.nr2char(0xf114), folder_empty_open = vim.fn.nr2char(0xf115),
          default = vim.fn.nr2char(0xf15b), provider = function(icon, node)
            local ok, devicons = pcall(require, "nvim-web-devicons")
            if not ok then return end
            if node.type == "file" or node.type == "terminal" then
              local ic, hl = devicons.get_icon(node.name, string.match(node.name, "%a+$"), { default = true })
              icon.text, icon.highlight = ic or icon.text, hl or icon.highlight
            end
          end,
        },
        git_status = { symbols = {
          added = vim.fn.nr2char(0xf067), modified = vim.fn.nr2char(0xf040), deleted = vim.fn.nr2char(0xf00d), renamed = "➜",
          untracked = vim.fn.nr2char(0xf128), ignored = "◌", unstaged = vim.fn.nr2char(0xf111), staged = "✓", conflict = vim.fn.nr2char(0xf071),
        } },
      },
      filesystem = {
        -- ล็อก sidebar ไว้ในโปรเจกต์: Backspace/navigate_up ขึ้นเหนือโฟลเดอร์ workspace (cwd) ไม่ได้
        commands = {
          navigate_up = function(state)
            local function norm(p) return (vim.fs.normalize(p):gsub("/+$", "")):lower() end
            if norm(state.path) == norm(vim.fn.getcwd()) then
              vim.notify("อยู่ที่ root ของโปรเจกต์แล้ว — ออกนอก workspace ไม่ได้", vim.log.levels.INFO, { title = "Explorer" })
              return
            end
            require("neo-tree.sources.filesystem.commands").navigate_up(state)
          end,
        },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        -- ล็อก Explorer ไว้ที่โฟลเดอร์โปรเจกต์ (cwd): กด Backspace ขึ้นได้แค่ขอบโปรเจกต์ ออกไปข้างนอกไม่ได้
        bind_to_cwd = true,
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
        -- สีแท็บตามธีม Catppuccin (ถ้าสลับไปธีมอื่น ใช้สีของธีมนั้นเอง)
        highlights = (function()
          if (vim.g.colors_name or "") ~= "catppuccin" then return nil end
          for _, mod in ipairs({ "catppuccin.groups.integrations.bufferline", "catppuccin.special.bufferline" }) do
            local ok, m = pcall(require, mod)
            if ok then
              local ok2, h = pcall(m.get or m.get_theme)
              if ok2 then return h end
            end
          end
        end)(),
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
    -- shell ของ terminal ในตัว: ใช้ pwsh (PowerShell 7) ถ้ามี ไม่งั้น Git Bash ไม่งั้น powershell เดิม
    opts = function()
      local shell
      for _, s in ipairs({ "pwsh", "C:/Program Files/Git/bin/bash.exe", "powershell" }) do
        if vim.fn.executable(s) == 1 then shell = s; break end
      end
      return { open_mapping = [[<C-\>]], direction = "horizontal", size = 15, shell = shell or vim.o.shell }
    end },

  -- แถบสถานะ + สัญลักษณ์ git
  -- สีโหมดชัดเจน: NORMAL ส้ม / INSERT เขียว / VISUAL ฟ้า
  { "nvim-lualine/lualine.nvim",
    opts = function()
      return { sections = {
        lualine_b = { "branch", "diagnostics" },
        -- โฟลเดอร์โปรเจกต์ (cwd) + path ของไฟล์ที่เปิดอยู่ (relative)
        lualine_c = {
          { function() return "  " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") end, color = { fg = "#89b4fa", gui = "bold" } },
          { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "" } },
        },
      }, options = { globalstatus = true, theme = "auto", section_separators = "", component_separators = "|" } }
    end },
  { "lewis6991/gitsigns.nvim", opts = {} },
  -- ปิดวงเล็บ/quote อัตโนมัติ + กด Enter กลางคู่ เช่น <div>|</div> ให้แตก 3 บรรทัด + indent
  -- ไม่ใช้ Space แทน Enter เพราะ Space ต้องใช้พิมพ์ attribute (class="..." ฯลฯ)
  { "windwp/nvim-autopairs", event = "InsertEnter",
    opts = { map_cr = true } },

  -- พิมพ์ <div> แล้วปิด </div> ให้อัตโนมัติ + แก้ชื่อ tag คู่กัน (HTML/JSX)
  -- tag เดี่ยว (img/br/hr/input/meta/link ฯลฯ) ไม่โดนปิดผิด — ต้องมี treesitter parser html อยู่แล้ว
  { "windwp/nvim-ts-autotag",
    ft = { "html", "xml", "javascriptreact", "typescriptreact", "javascript", "typescript" },
    opts = {
      opts = {
        enable_close = true,          -- auto close tags
        enable_rename = true,         -- auto rename คู่เปิด/ปิด
        enable_close_on_slash = false,
      },
    } },

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
  -- โหลดตอนเปิด Neovim เลย (lazy=false): เดิมใช้ VeryLazy ทำให้ setup ไม่ทันตอนกด Space แรกๆ เมนูเลยไม่ขึ้น
  { "folke/which-key.nvim", lazy = false,
    opts = {
      preset = "classic",
      delay = 150,
      -- ใช้ตำแหน่งค่าเริ่มต้นของ which-key (กลางล่างจอ) — เดิมตั้ง col=0/width=1.0/row=math.huge
      -- ทำให้เมนูไปโผล่นอกจอ/หลังแถบสถานะในบาง terminal เลยดูเหมือนไม่มีเมนู
      win = { border = "rounded" },
      layout = {
        width = { min = 22, max = 45 },
        spacing = 4,
      },
      spec = {
        { "<leader>p", desc = "Command Palette" },
        { "<leader>g", desc = "ค้นหาคำทั้งโปรเจกต์ (คำใต้เคอร์เซอร์/ที่คลุม)" },
        { "<leader>b", desc = "สลับไฟล์ (Buffers)" },
        { "<leader>s", desc = "ฟังก์ชัน/คลาสในไฟล์นี้" },
        { "<leader>sf", desc = "ค้นหาฟังก์ชันทุกไฟล์ (ไม่ต้องมี LSP)" },
        { "<leader>sw", desc = "ฟังก์ชันทั้งโปรเจกต์ (workspace)" },
        { "<leader>fe", desc = "เปิด/ปิด File Explorer" },
        { "<leader>x", desc = "ปิดแท็บปัจจุบัน" },
        { "<C-w>", desc = "ปิดแท็บ (แบบ VS Code)" },
        { "<C-f>", desc = "ค้นหาในไฟล์นี้ (แบบ VS Code)" },
        { "<C-S-f>", desc = "ค้นหาข้อความทั้งโปรเจกต์ (แบบ VS Code)" },
        { "<leader>a", desc = "Code Action (LSP)" },
        { "<leader>df", desc = "ดูรายละเอียด Error" },
        { "<leader>F", desc = "จัดรูปแบบโค้ด (Format)" },
        { "<leader>?", desc = "แสดงเมนูปุ่มลัดทั้งหมด" },
        { "<leader>/", desc = "แสดงเมนูปุ่มลัดทั้งหมด (สำรองแป้นไทย)" },
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

  -- Snippet แบบ VS Code: พิมพ์ตัวย่อ (เช่น rafce) แล้ว Enter = แตกเป็นโครงสร้างทันที
  -- friendly-snippets มีชุด React ให้ (rafce/rfce/rafcp ฯลฯ) + เพิ่มชุด React Native ด้านล่าง
  -- วิธีใช้: พิมพ์ตัวย่อ -> เมนูขึ้น -> Enter แตก snippet -> Ctrl+L ไปช่องถัดไป / Ctrl+H ย้อนกลับ
  { "L3MON4D3/LuaSnip", version = "v2.*", event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      local ls = require("luasnip")
      ls.config.set_config({ history = true, update_events = "TextChanged,TextChangedI", enable_autosnippets = true })
      require("luasnip.loaders.from_vscode").lazy_load()
      local s, t, i, fn = ls.snippet, ls.text_node, ls.insert_node, ls.function_node
      local function mirror(n) return fn(function(args) return args[1][1] end, { n }) end
      -- ===== ชุด React Native (พิมพ์ตัวย่อแล้ว Enter) =====
      local rn = {
        -- rnf: component หลักของ React Native (View + Text + StyleSheet + export default)
        s("rnf", {
          t({ "import React from 'react';", "import { View, Text, StyleSheet } from 'react-native';", "", "const " }),
          i(1, "ComponentName"),
          t({ " = () => {", "  return (", "    <View style={styles.container}>", "      <Text>" }),
          i(0),
          t({ "</Text>", "    </View>", "  );", "};", "", "export default " }),
          mirror(1),
          t({ ";", "", "const styles = StyleSheet.create({", "  container: {", "    flex: 1,", "  },", "});" }),
        }),
        -- rnstyle: StyleSheet.create อย่างเดียว
        s("rnstyle", {
          t({ "const styles = StyleSheet.create({", "  " }),
          i(1, "container"),
          t({ ": {", "    " }),
          i(0),
          t({ "", "  },", "});" }),
        }),
        -- rnpress: ปุ่ม Pressable
        s("rnpress", {
          t({ "import { Pressable, Text } from 'react-native';", "", "<Pressable onPress={() => " }),
          i(1, "handlePress"),
          t({ "}>" }),
          i(0),
          t({ "</Pressable>" }),
        }),
        -- rnflat: รายการ FlatList
        s("rnflat", {
          t({ "import { FlatList } from 'react-native';", "", "<FlatList", "  data={" }),
          i(1, "data"),
          t({ "}", "  keyExtractor={(item) => item.id}", "  renderItem={({ item }) => (" }),
          i(0),
          t({ ")}", "/>" }),
        }),
        -- rnscroll: ScrollView ครอบเนื้อหา
        s("rnscroll", {
          t({ "import { ScrollView } from 'react-native';", "", "<ScrollView>" }),
          i(0),
          t({ "</ScrollView>" }),
        }),
        -- rninput: ช่องพิมพ์ TextInput
        s("rninput", {
          t({ "import { TextInput } from 'react-native';", "", "<TextInput", "  value={" }),
          i(1, "value"),
          t({ "}", "  onChangeText={" }),
          i(2, "setValue"),
          t({ "}", "  placeholder=\"" }),
          i(3, "พิมพ์ที่นี่..."),
          t({ "\"", "/>" }),
        }),
        -- rnstate: useState แบบ RN
        s("rnstate", {
          t({ "const [" }),
          i(1, "value"),
          t({ ", set" }),
          mirror(1),
          t({ "}] = React.useState(" }),
          i(0),
          t({ ");" }),
        }),
      }
      for _, ft in ipairs({ "javascriptreact", "typescriptreact", "javascript", "typescript" }) do
        ls.add_snippets(ft, rn)
      end
    end },

  -- เมนู autocomplete จาก LSP (Enter เพื่อยืนยัน) ไม่ใช้ Tab เพื่อไม่ให้ชนกับ Supermaven
  -- ป็อปอัพกรอบมน สวยแบบ VS Code ไม่ใช่สี่เหลี่ยมกลางจอ
  { "saghen/blink.cmp", version = "1.*",
    opts = {
      -- ไม่โชว์เมนู autocomplete ในช่องพิมพ์ของ neo-tree (neo-tree-popup) — เดิมเมนูจะเด้งขึ้นแล้วไม่หายเมื่อปิดช่องพิมพ์
      enabled = function()
        return vim.bo.filetype ~= "neo-tree-popup" and vim.bo.filetype ~= "neo-tree"
      end,
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
        -- Esc ในโหมดพิมพ์: ปิดเมนูก่อน แล้วค่อยออกจากโหมดพิมพ์ (เดิมไม่มีปุ่มปิดโดยตรง เมนูเลยค้าง)
        ["<Esc>"] = { "hide", "fallback" },
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
          ["<Esc>"] = { "hide", "fallback" },  -- Esc แล้วเมนูต้องหาย ไม่ค้าง
          ["<C-e>"] = { "hide", "fallback" },
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
}, {
  -- ประสิทธิภาพ: ปิด plugin ในตัวที่ไม่ได้ใช้ + ไม่เช็กอัปเดตปลั๊กอินเองตอนเปิด
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = { rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "rplugin", "matchit" } } },
})

-- ===== ปิด popup เมนูที่ค้าง =====
-- ตอนออกจากโหมดพิมพ์ / ออกจากบรรทัดคำสั่ง / สลับไฟล์ / สลับหน้าต่าง / เสียโฟกัส ให้ซ่อนเมนู blink + pum ทันที ไม่ให้ค้างจอ
local function hide_popups()
  pcall(function() require("blink.cmp").hide() end)
  if vim.fn.pumvisible() == 1 then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-e>", true, false, true), "n", false)
  end
end
vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave", "BufEnter", "WinEnter", "WinLeave", "FocusLost" }, {
  callback = hide_popups,
})
-- ออกจากโหมดพิมพ์/เลือกด้วยวิธีอื่น (เช่น Ctrl+C, คลิกเมาส์) ก็ปิดด้วย
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*:*",
  callback = function(ev)
    local old = vim.fn.matchstr(ev.match, "^[^:]*")
    if old:match("^[iRsS]") then
      vim.schedule(hide_popups)
    end
  end,
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
-- ใช้ npx โหลด server อัตโนมัติตอนเปิดไฟล์ครั้งแรก (ไม่ต้องติดตั้งเอง) — package ชื่อ vscode-langservers-extracted
-- เดิมใช้ชื่อ vscode-langservers ซึ่งไม่มีใน npm (404) ทำให้ cssls แครชทุกครั้ง
vim.lsp.config("cssls", {
  cmd = { "npx", "--yes", "-p", "vscode-langservers-extracted", "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_markers = { "package.json", "bun.lock", "bun.lockb", ".git" },
  settings = {
    css = { validate = true, lint = { unknownAtRules = "ignore" } },
    scss = { validate = true, lint = { unknownAtRules = "ignore" } },
    less = { validate = true },
  },
})
vim.lsp.config("tailwindcss", {
  -- ตัวจริงชื่อ @tailwindcss/language-server (ชื่อ tailwindcss-language-server บน npm เป็นแพ็กเกจว่าง 0.0.1 ไม่มี autocomplete)
  cmd = { "npx", "--yes", "-p", "@tailwindcss/language-server", "tailwindcss-language-server", "--stdio" },
  filetypes = { "css", "scss", "less", "html", "javascript", "typescript", "javascriptreact", "typescriptreact" },
  root_markers = { "package.json", "bun.lock", "bun.lockb", "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", ".git" },
  settings = {
    tailwindCSS = { validate = true, lint = { invalidAtRule = "ignore" }, includeLanguages = { css = "css", scss = "css" } },
  },
})
vim.lsp.config("html", {
  cmd = { "npx", "--yes", "-p", "vscode-langservers-extracted", "vscode-html-language-server", "--stdio" },
  filetypes = { "html", "erb" },
  root_markers = { "package.json", "bun.lock", "bun.lockb", ".git" },
})
vim.lsp.config("ts_ls", {
  cmd = { "npx", "--yes", "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  root_markers = { "package.json", "bun.lock", "bun.lockb", "tsconfig.json", ".git" },
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
    -- <leader>F ผูกแบบ global ด้านล่าง (ไม่ผูกเฉพาะตอน LSP attach) — ดู format_code()
  end,
})

-- ===== จัดรูปแบบโค้ด (Space F) — ผูกแบบ global ทุกไฟล์ ไม่รอ LSP =====
-- ลำดับที่ลอง: 1) Prettier (ตัวเดียวกับ VS Code — แตกบรรทัด/จัดโค้ดอัดบรรทัดเดียวได้จริง)
-- 2) LSP format 3) indent ในตัว gg=G (สำรองสุดท้าย) — และแจ้งบอกทุกครั้งว่าใช้อะไร
-- เหตุผลที่ต้องมี Prettier: ts_ls รันไม่ได้ถ้าโปรเจกต์ไม่มี typescript ติดตั้ง
-- และ gg=G อย่างเดียวจัดโค้ดอัดบรรทัดเดียวไม่ได้ เลยดูเหมือน "กดแล้วไม่ format"
local prettier_fts = {
  html = true, css = true, scss = true, less = true, json = true, jsonc = true,
  javascript = true, typescript = true, javascriptreact = true, typescriptreact = true,
  markdown = true, yaml = true, graphql = true,
}
local function try_prettier(bufnr)
  local ft = vim.bo[bufnr].filetype
  if not prettier_fts[ft] then return false end
  local cmd
  if vim.fn.executable("prettier") == 1 then
    cmd = { "prettier" }
  elseif vim.fn.executable("npx") == 1 then
    cmd = { "npx", "--yes", "prettier" }
  else
    return false
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    name = "file." .. (({ javascript = "js", typescript = "ts", javascriptreact = "jsx", typescriptreact = "tsx" })[ft] or ft)
  end
  cmd[#cmd + 1] = "--stdin-filepath"
  cmd[#cmd + 1] = name
  local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"
  local out = vim.fn.system(cmd, text)
  if vim.v.shell_error ~= 0 or out == nil or out == "" then return false end
  out = out:gsub("\r\n", "\n")
  if out:sub(-1) == "\n" then out = out:sub(1, -2) end
  local lines = vim.split(out, "\n")
  local view = vim.fn.winsaveview()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  pcall(vim.fn.winrestview, view)
  return true
end

local function format_code()
  local mode = vim.fn.mode()
  local bufnr = vim.api.nvim_get_current_buf()
  local is_visual = (mode == "v" or mode == "V" or mode == "\22")

  -- 1) Prettier สำหรับไฟล์เว็บ/JS/TS (คลุมเฉพาะส่วนที่เลือกไม่ได้ — Prettier จัดทั้งไฟล์)
  if not is_visual then
    local pok, done = pcall(try_prettier, bufnr)
    if pok and done then
      vim.notify("Format ด้วย Prettier เรียบร้อย", vim.log.levels.INFO, { title = "Format" })
      return
    end
  end

  -- 2) LSP format (ถ้ามีตัวที่รองรับจริง)
  local clients = vim.tbl_filter(function(c)
    local ok, res = pcall(function()
      return c:supports_method("textDocument/formatting", bufnr)
        or c:supports_method("textDocument/rangeFormatting", bufnr)
    end)
    return ok and res
  end, vim.lsp.get_clients({ bufnr = bufnr }))

  if #clients > 0 then
    local opts = { async = false, timeout_ms = 5000 }
    if is_visual then
      opts.range = { vim.api.nvim_buf_get_mark(bufnr, "<"), vim.api.nvim_buf_get_mark(bufnr, ">") }
    end
    local ok, err = pcall(vim.lsp.buf.format, opts)
    if ok then
      vim.notify("Format ด้วย LSP (" .. clients[1].name .. ") เรียบร้อย", vim.log.levels.INFO, { title = "Format" })
      return
    end
    -- LSP พัง (เช่น ts_ls ไม่มี typescript ในโปรเจกต์) -> ตกไปใช้ gg=G ด้านล่าง ไม่หยุดเงียบ
    vim.notify("LSP format ไม่สำเร็จ (" .. tostring(err) .. ") — ใช้ indent ในตัวแทน", vim.log.levels.WARN, { title = "Format" })
  end

  -- 3) สำรองสุดท้าย: indent ในตัวของ Neovim (ทำงานทุกไฟล์)
  local view = vim.fn.winsaveview()
  local ok, err = pcall(function()
    if is_visual then
      vim.cmd("silent keepjumps normal! gv=gv")
    else
      vim.cmd("silent keepjumps normal! gg=G")
    end
  end)
  pcall(vim.fn.winrestview, view)
  vim.notify(
    ok and "จัด indent ในตัว (gg=G) เรียบร้อย"
      or ("Format ไม่สำเร็จ: " .. tostring(err)),
    ok and vim.log.levels.INFO or vim.log.levels.WARN, { title = "Format" })
end
map({ "n", "x" }, "<leader>F", format_code, { desc = "จัดรูปแบบโค้ด (Format)" })
-- Format แบบ VS Code = Shift+Alt+F (Ctrl+F ยกให้ "ค้นหาในไฟล์" แบบ VS Code แล้ว — ดูด้านล่าง)
for _, k in ipairs({ "<A-S-f>", "<M-S-f>", "<A-F>", "<M-F>" }) do
  map({ "n", "x" }, k, format_code, { desc = "จัดรูปแบบโค้ด (Format)" })
end
-- ตอนพิมพ์อยู่ (Insert) กด Space F / Ctrl+F ได้เลย: ออกโหมดชั่วคราว จัดเสร็จกลับไปโหมดพิมพ์ต่อ
local function format_from_insert()
  vim.cmd("stopinsert")
  format_code()
  vim.cmd("startinsert")
end
map("i", "<leader>F", format_from_insert, { desc = "จัดรูปแบบโค้ด (Format)" })
for _, k in ipairs({ "<A-S-f>", "<M-S-f>", "<A-F>", "<M-F>" }) do
  map("i", k, format_from_insert, { desc = "จัดรูปแบบโค้ด (Format)" })
end

-- ===== คีย์ลัดแบบ VS Code / Cursor =====
-- หมายเหตุ: terminal ส่วนใหญ่แยก Ctrl+Shift+<ตัวอักษร> ไม่ได้ จึงใช้ Space (leader) แทน
local fzf = function(fn) return function() require("fzf-lua")[fn]() end end

-- โชว์ Suggestion / ข้อมูลของโค้ดตรงเคอร์เซอร์ (ไม่ใช้ Option+Space เพราะชนกับ Raycast)
-- ใช้ได้ทั้ง:
--   1) Fn + F1 (หรือ F1)
--   2) Option + i (⌥ + i = IntelliSense / Info)
--   3) Option + . (⌥ + . เหมือน VS Code)
--   4) (ยกเลิก Space+Space แล้ว: กด Space ค้าง = ระบบส่ง Space รัวจนเข้าโหมดพิมพ์โดยไม่ตั้งใจ)
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

-- ห้ามผูก <leader><space> (Space เบิ้ล): กด Space ค้าง = terminal ส่ง Space รัว 2 ครั้ง
-- จะเข้าโหมดพิมพ์ + พิมพ์ช่องว่างรัวโดยไม่ตั้งใจ ใช้ Ctrl+Space / F1 / Option+i แทน
for _, k in ipairs({ "<F1>", "<A-i>", "<M-i>", "ˆ", "<A-ร>", "<M-ร>", "<A-.>", "<M-.>", "≥" }) do
  map("n", k, trigger_code_suggestion, { desc = "Suggestion / IntelliSense" })
end

-- Normal: Ctrl+Space บนชื่อ function/ตัวแปร = ไปที่ไฟล์/บรรทัดที่ประกาศไว้ (Go to Definition)
-- มี LSP ใช้ LSP; ไม่มี LSP (เช่น ts_ls ยังไม่พร้อม) ค้นหาบรรทัดประกาศ function/const/class/def/fn ทั้งโปรเจกต์แทน
-- กลับมาที่เดิมด้วย Ctrl+O  (Insert: Ctrl+Space ยังเป็นเมนู suggestion)
local function goto_definition()
  local word = vim.fn.expand("<cword>")
  if word == "" then return end
  local has_def = false
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if c:supports_method("textDocument/definition", 0) then has_def = true end
  end
  if has_def then
    vim.lsp.buf.definition()
    return
  end
  local w = vim.pesc(word)
  local pat = ([[(function\s+WORD\b|(const|let|var|class|interface|type|enum)\s+WORD\b|\bWORD\s*[:=]\s*(async\s*)?(function|\()|def\s+WORD\b|fn\s+WORD\b|func\s+WORD\b|class\s+WORD\b|local\s+function\s+WORD\b)]]):gsub("WORD", w)
  require("fzf-lua").grep({ search = pat, no_esc = true, prompt = "Definition: " .. word .. " > " })
end
for _, k in ipairs({ "<C-Space>", "<C-@>" }) do
  map("n", k, goto_definition, { desc = "ไปที่ที่ประกาศ function (Go to Definition)" })
end
-- Insert: ใช้ keymap ของ blink.cmp เป็นหลัก (ไม่ซ้ำซ้อนกับ mapping ข้างบน)
map("i", "<F1>", blink_suggest, { desc = "Suggestion (สำรองถ้า Ctrl+Space ถูก IME ดัก)" })
-- Ctrl+Space ใน Insert: ผูกแบบ global ซ้ำอีกชั้น (กรณีปุ่มถูกส่งมาเป็น <C-Space> หรือ <C-@> ที่ blink ไม่จับ)
map("i", "<C-Space>", blink_suggest, { desc = "Suggestion โค้ด (Ctrl+Space)" })
map("i", "<C-@>", blink_suggest, { desc = "Suggestion โค้ด (Ctrl+Space)" })

-- บันทึก / undo / redo / เลือกทั้งหมด
map({ "n", "v" }, "<C-s>", "<cmd>w<cr>", { desc = "บันทึก" })
map("i", "<C-s>", "<esc><cmd>w<cr>", { desc = "บันทึก" })
map("n", "<C-z>", "u", { desc = "undo" })
map("i", "<C-z>", "<C-o>u", { desc = "undo" })
map("n", "<C-y>", "<C-r>", { desc = "redo" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "redo" })
-- Ctrl+A เลือกทั้งหมดทุกโหมดแบบ VS Code (Normal/Insert/Visual/Select) — พิมพ์ทับได้เลย
-- เดิมโหมดพิมพ์ Ctrl+A = ไปหน้าสุดบรรทัด (ชนคำสั่ง Home อยู่แล้ว) เลยเปลี่ยนเป็นเลือกทั้งหมด
map({ "n", "x" }, "<C-a>", "ggVG", { desc = "เลือกทั้งหมด" })
map("i", "<C-a>", "<Esc>ggVG", { desc = "เลือกทั้งหมด" })
map("s", "<C-a>", "<C-g>ggVG", { desc = "เลือกทั้งหมด" })

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
map("n", "<leader>b", fzf("buffers"), { desc = "buffers" })
-- ปุ่มสำรอง: กด Space ? (หรือ Space / บนแป้นไทยที่ Shift+/ ได้ / ไม่ใช่ ?) เรียกเมนูปุ่มลัดขึ้นมาเองทันที
-- ใช้ show() ค่าเริ่มต้น (global) — ห้ามใส่ global=false ไม่งั้นไม่เห็นปุ่ม <leader> ที่เป็นปุ่มกลาง
local function show_whichkey() require("which-key").show() end
map("n", "<leader>?", show_whichkey, { desc = "แสดงเมนูปุ่มลัดทั้งหมด" })
map("n", "<leader>/", show_whichkey, { desc = "แสดงเมนูปุ่มลัดทั้งหมด (สำรองแป้นไทย)" })

-- :Keys — หน้า cheat sheet แสดงปุ่มลัดทั้งหมดในหน้าต่างแยก (เห็นได้แน่นอน ไม่พึ่งเมนูป๊อปอัพ)
vim.api.nvim_create_user_command("Keys", function()
  local lines = {
    "ปุ่มลัดทั้งหมด (Space = ปุ่ม leader กดนำหน้าทุกตัว)",
    "",
    "ค้นหา / ไฟล์",
    "  Ctrl+P        ค้นหาไฟล์",
    "  Space p       เมนูคำสั่งทั้งหมด (ค้นหาแล้ว Enter)",
    "  Space g / F4 / Ctrl+Shift+F  ค้นหาคำทั้งโปรเจกต์ (คำใต้เคอร์เซอร์/ที่คลุม)",
    "  Space s       ฟังก์ชัน/คลาสในไฟล์นี้",
    "  Space sf      ฟังก์ชันทุกไฟล์ (ไม่ต้องมี LSP)",
    "  Space sw      ฟังก์ชันทั้งโปรเจกต์",
    "  Space b       สลับไฟล์ที่เปิดอยู่",
    "",
    "สร้าง / แก้ไขไฟล์",
    "  Ctrl+N        สร้างไฟล์ใหม่ (รองรับ {a,b}.tsx สร้างหลายไฟล์)",
    "  Ctrl+B        เปิด/ปิด File Explorer (a=ไฟล์, A=โฟลเดอร์, d=ลบ)",
    "  Space fe      เปิด/ปิด File Explorer (สำรอง)",
    "  Ctrl+F        ค้นหาในไฟล์นี้ (Space f f)",
    "  Space F / Alt+Shift+F  จัดรูปแบบโค้ด (Format)",
    "  Ctrl+S        บันทึก",
    "  Ctrl+/        คอมเมนต์บรรทัด",
    "",
    "แท็บ / หน้าต่าง",
    "  Ctrl+W / Space x  ปิดแท็บปัจจุบัน",
    "  Shift+l / h   แท็บถัดไป / ก่อนหน้า",
    "  Ctrl+\\        เปิด terminal ในตัว",
    "",
    "โค้ด (LSP)",
    "  gd / F12      ไปที่ definition",
    "  gr            หา references",
    "  K             ดูเอกสารของโค้ด",
    "  F2            เปลี่ยนชื่อตัวแปร/ฟังก์ชัน",
    "  Space a       Code Action",
    "  F1 / Ctrl+Space  เมนู suggestion",
    "",
    "พิมพ์ตัวย่อแล้ว Enter (Snippet)",
    "  rafce         React component (export)",
    "  rnf / rnfs    React Native component",
    "  rnpress       ปุ่ม Pressable,  rnflat = รายการ,  rninput = ช่องพิมพ์",
    "  Ctrl+L / Ctrl+H  ไปช่องถัดไป/ย้อนกลับใน snippet",
    "",
    "หมายเหตุ: กดปุ่มตามลำดับโดยไม่ต้องรอเมนู เช่น Space s f = ค้นฟังก์ชันทุกไฟล์",
    "ปิดหน้านี้ด้วย q",
  }
  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.modifiable, vim.bo.bufhidden, vim.bo.filetype = false, "wipe", "keys"
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = 0 })
end, { desc = "แสดงปุ่มลัดทั้งหมด (cheat sheet)" })
map("n", "<leader>h", "<cmd>Keys<cr>", { desc = "แสดงปุ่มลัดทั้งหมด (cheat sheet)" })

-- ค้นหาคำทั้งโปรเจกต์แล้วเห็นว่าแต่ละผลอยู่ไฟล์/บรรทัดไหน:
-- ไม่คลุมอะไร = ค้นคำใต้เคอร์เซอร์ทันที / คลุมข้อความใน Visual = ค้นข้อความที่คลุม / เคอร์เซอร์ไม่มีคำ = พิมพ์คำค้นเอง
local function visual_text()
  -- กำลังคลุมอยู่ (Visual/Select): อ่านจากช่วงที่คลุมจริง — mark '< '> ยังไม่อัปเดตจนกว่าจะออกจากโหมด
  local m = vim.fn.mode()
  if m:match("^[vV\22sS\19]") then
    local rt = ({ s = "v", S = "V", ["\19"] = "\22" })[m] or m
    local ok, region = pcall(vim.fn.getregion, vim.fn.getpos("v"), vim.fn.getpos("."), { type = rt })
    if ok and region then
      return (table.concat(region, " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
    end
  end
  local s = vim.api.nvim_buf_get_mark(0, "<")
  local e = vim.api.nvim_buf_get_mark(0, ">")
  local lines = vim.api.nvim_buf_get_lines(0, s[1] - 1, e[1], false)
  if #lines == 0 then return "" end
  lines[1] = lines[1]:sub(s[2] + 1)
  lines[#lines] = lines[#lines]:sub(1, e[2] + 1)
  return table.concat(lines, " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end
local function grep_word()
  local in_visual = vim.fn.mode():match("^[vV\22sS\19]") ~= nil
  local word = in_visual and visual_text() or vim.fn.expand("<cword>")
  if word == "" then
    require("fzf-lua").live_grep({})
  else
    require("fzf-lua").live_grep({ search = word })
  end
end
map({ "n", "x" }, "<leader>g", grep_word, { desc = "ค้นหาคำทั้งโปรเจกต์ (คำใต้เคอร์เซอร์/ที่คลุม)" })
-- Ctrl+Shift+F แบบ VS Code = ค้นหาข้อความทั้งโปรเจกต์ (บาง terminal แยก Shift ไม่ได้ จะได้เป็น Ctrl+F แทน — ใช้ Space g สำรอง)
map({ "n", "x", "s" }, "<C-S-f>", grep_word, { desc = "ค้นหาข้อความทั้งโปรเจกต์" })
map("i", "<C-S-f>", function() vim.cmd("stopinsert"); grep_word() end, { desc = "ค้นหาข้อความทั้งโปรเจกต์" })
-- ปุ่มสำรองที่ terminal ไม่ดักไว้ (Windows Terminal ใช้ Ctrl+Shift+F เป็นค้นหาของตัวเองและไม่ส่งให้ nvim)
map({ "n", "x", "s" }, "<F4>", grep_word, { desc = "ค้นหาข้อความทั้งโปรเจกต์ (สำรอง)" })
map("i", "<F4>", function() vim.cmd("stopinsert"); grep_word() end, { desc = "ค้นหาข้อความทั้งโปรเจกต์ (สำรอง)" })

-- Ctrl+F แบบ VS Code = ค้นหาข้อความในไฟล์นี้ (แสดงรายการบรรทัดที่ตรง พิมพ์กรองได้ Enter ไปที่บรรทัดนั้น)
-- ตอนคลุมข้อความอยู่ จะค้นด้วยข้อความที่คลุม
local function find_in_file()
  local in_visual = vim.fn.mode():match("^[vV\22sS\19]") ~= nil
  local q = in_visual and visual_text() or nil
  if in_visual then vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false) end
  require("fzf-lua").blines(q and q ~= "" and { search = q } or {})
end
map({ "n", "x", "s" }, "<C-f>", find_in_file, { desc = "ค้นหาในไฟล์นี้ (Ctrl+F แบบ VS Code)" })
map("i", "<C-f>", function() vim.cmd("stopinsert"); find_in_file() end, { desc = "ค้นหาในไฟล์นี้" })

-- ค้นหาฟังก์ชันทุกไฟล์โดยไม่ต้องมี LSP (grep หา function/const ที่เป็นฟังก์ชันทุกไฟล์ในโปรเจกต์)
local function find_functions_all()
  require("fzf-lua").grep({
    regex = [[(function\s+\w+|const\s+\w+\s*=\s*(async\s*)?\(|export\s+(default\s+)?(function|const)\s+\w+|def\s+\w+|func\s+\w+)]],
    prompt = "Functions > ",
  })
end
map("n", "<leader>sf", find_functions_all, { desc = "ค้นหาฟังก์ชันทุกไฟล์ (ไม่ต้องมี LSP)" })
map("n", "<leader>s", fzf("lsp_document_symbols"), { desc = "ฟังก์ชัน/คลาสในไฟล์นี้" })
-- มี LSP ใช้ LSP หาฟังก์ชันทั้งโปรเจกต์; ไม่มี LSP (เช่น ts_ls ไม่ติด) ใช้ตัวค้น grep แทน ไม่เงียบหาย
map("n", "<leader>sw", function()
  if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
    vim.notify("ไม่มี LSP — ค้นฟังก์ชันทุกไฟล์ด้วย grep แทน", vim.log.levels.INFO, { title = "Search" })
    find_functions_all()
  else
    require("fzf-lua").lsp_live_workspace_symbols({})
  end
end, { desc = "ค้นหาฟังก์ชันทั้งโปรเจกต์" })

-- file explorer / terminal / แท็บ
-- Ctrl+B: ไปอยู่ที่ sidebar (เปิดให้ถ้ายังไม่เปิด แล้วโฟกัสที่รายการโฟลเดอร์/ไฟล์ทันที)
-- ถ้าอยู่ใน sidebar อยู่แล้ว กดซ้ำ = กลับไปหน้าไฟล์เดิม (Space f e = เปิด/ปิด sidebar)
local function focus_sidebar()
  if vim.bo.filetype == "neo-tree" then
    vim.cmd("wincmd p")
  else
    vim.cmd("Neotree focus position=left reveal")
  end
end
map({ "n", "x" }, "<C-b>", focus_sidebar, { desc = "ไปที่ Explorer (sidebar)" })
map("i", "<C-b>", function() vim.cmd("stopinsert"); focus_sidebar() end, { desc = "ไปที่ Explorer (sidebar)" })
map("n", "<leader>fe", "<cmd>Neotree toggle position=left<cr>", { desc = "เปิด/ปิด Explorer (สำรอง)" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "แท็บถัดไป" })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "แท็บก่อนหน้า" })
local function close_tab() require("mini.bufremove").delete(0, false) end
-- Ctrl+W แบบ VS Code = ปิดแท็บ (Space x ยังใช้ได้เป็นสำรอง)
-- หมายเหตุ: Ctrl+W เดิมเป็นปุ่มนำหน้าคำสั่งหน้าต่าง (Ctrl+W w/h/j/k) — ยกให้ปิดแท็บแล้ว ใช้เมาส์/คำสั่ง :split แทน
map("n", "<C-w>", close_tab, { desc = "ปิดแท็บ" })
map("n", "<leader>x", close_tab, { desc = "ปิดแท็บ" })

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
-- Home / gh = หน้าสุดของโค้ดในบรรทัด (ข้ามช่องว่างย่อหน้า) — Ctrl+A ย้ายไปเป็นเลือกทั้งหมดแล้ว
-- End  / Ctrl+E (insert) / gl = ท้ายสุดของโค้ดในบรรทัด
map("n", "<Home>", "^", { desc = "ไปหน้าสุดของโค้ดในบรรทัด" })
map("i", "<Home>", "<C-o>^", { desc = "ไปหน้าสุดของโค้ดในบรรทัด" })
map("n", "<End>", "$", { desc = "ไปท้ายสุดของโค้ดในบรรทัด" })
map("i", "<End>", "<End>", { desc = "ไปท้ายสุดของโค้ดในบรรทัด" })
map({ "n", "x" }, "gh", "^", { desc = "ไปหน้าสุดของโค้ดในบรรทัด" })
map({ "n", "x" }, "gl", "g_", { desc = "ไปท้ายสุดของโค้ดในบรรทัด" })
map("n", "<C-e>", "$", { desc = "ไปท้ายสุดของโค้ดในบรรทัด" })
map("i", "<C-e>", "<End>", { desc = "ไปท้ายสุดของโค้ดในบรรทัด" })

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
    vim.api.nvim_set_hl(0, "StartLogo", { fg = "#89b4fa", bold = true })
    vim.api.nvim_set_hl(0, "StartKey", { fg = "#1e1e2e", bg = "#89b4fa", bold = true })
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
-- เคอร์เซอร์เปลี่ยนรูปทรง+สีตามโหมด (สีตรงกับ lualine): Normal ส้มบล็อก / Insert เขียวเส้นตั้ง / Visual ฟ้า / Select ม่วง / Replace แดง
vim.o.guicursor = table.concat({
  "n-c:block-CursorNormal", "i-ci-ve:ver25-CursorInsert", "r-cr:hor20-CursorReplace",
  "o:hor50", "v:block-CursorVisual", "sm:block-CursorSelect-blinkon500-blinkoff300",
}, ",")
local function cursor_hl()
  for name, c in pairs({ CursorNormal = "#89b4fa", CursorInsert = "#a6e3a1", CursorVisual = "#cba6f7",
    CursorSelect = "#f9e2af", CursorReplace = "#f38ba8" }) do
    vim.api.nvim_set_hl(0, name, { bg = c, fg = "#1e1e2e" })
  end
end
cursor_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = cursor_hl })
-- ฟอนต์สำหรับ GUI (Neovide ฯลฯ); ใน terminal ฟอนต์ตั้งที่ตัว terminal (ใช้ JetBrainsMono Nerd Font)
vim.o.guifont = "JetBrainsMono Nerd Font:h13"
-- สลับเลขบรรทัดปกติ <-> relative (Space n)
vim.keymap.set("n", "<leader>n", function() vim.wo.relativenumber = not vim.wo.relativenumber end, { desc = "สลับเลขบรรทัด relative" })

-- ===== ค้นหาแบบ VS Code =====
-- Space f f = ค้นหาข้อความในไฟล์นี้ (รายการบรรทัด) / Space f w = ค้นทั้งโปรเจกต์พร้อมกรองไฟล์ด้วย glob
-- (พิมพ์ "คำค้น -- *.tsx" เพื่อกรองเฉพาะนามสกุล) / Space f r = ไฟล์ที่เปิดล่าสุด
vim.keymap.set("n", "<leader>ff", function() require("fzf-lua").blines() end, { desc = "ค้นหาข้อความในไฟล์นี้" })
vim.keymap.set("n", "<leader>fw", function() require("fzf-lua").live_grep_glob() end, { desc = "ค้นข้อความทั้งโปรเจกต์ + กรองไฟล์ (glob)" })
vim.keymap.set("n", "<leader>fr", function() require("fzf-lua").oldfiles({ cwd_only = true }) end, { desc = "ไฟล์ที่เปิดล่าสุด" })

-- ===== :NvimCheck — ตรวจ syntax/ภาษา (treesitter + LSP) และประสิทธิภาพ =====
vim.api.nvim_create_user_command("NvimCheck", function()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local lines = { "== ไฟล์ปัจจุบัน ==", "filetype : " .. (ft ~= "" and ft or "(ไม่ทราบ)") }
  local lang = vim.treesitter.language.get_lang(ft) or ft
  lines[#lines + 1] = "treesitter: " .. (vim.treesitter.highlighter.active[buf] and ("ทำงาน (" .. lang .. ")") or "ไม่ทำงาน (ใช้ syntax เดิม)")
  local clients = vim.lsp.get_clients({ bufnr = buf })
  lines[#lines + 1] = "LSP      : " .. (#clients > 0 and table.concat(vim.tbl_map(function(c) return c.name end, clients), ", ") or "ไม่มี client ที่ attach")
  local d = vim.diagnostic.count(buf)
  lines[#lines + 1] = ("diagnostics: error %d / warn %d / info %d / hint %d"):format(d[1] or 0, d[2] or 0, d[3] or 0, d[4] or 0)
  lines[#lines + 1] = ""
  lines[#lines + 1] = "== เครื่องมือในระบบ =="
  for _, exe in ipairs({ "git", "rg", "fd", "fzf", "node", "npx", "gcc", "tree-sitter", "rust-analyzer", "lua-language-server", "pyright-langserver", "prettier" }) do
    lines[#lines + 1] = ("%-20s %s"):format(exe, vim.fn.executable(exe) == 1 and "OK" or "ไม่พบ")
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "== ประสิทธิภาพ =="
  local ok, stats = pcall(function() return require("lazy").stats() end)
  if ok then
    lines[#lines + 1] = ("ปลั๊กอิน %d/%d โหลดแล้ว, เวลาเปิด nvim %.1f ms"):format(stats.loaded, stats.count, stats.startuptime)
  end
  lines[#lines + 1] = ("หน่วยความจำ Lua: %.1f MB"):format(collectgarbage("count") / 1024)
  lines[#lines + 1] = "รายละเอียดเพิ่ม: :Lazy profile | :checkhealth | nvim --startuptime t.log"
  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.bo.modifiable, vim.bo.bufhidden, vim.bo.buftype = false, "wipe", "nofile"
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = 0 })
end, { desc = "ตรวจ syntax/LSP/ประสิทธิภาพ" })

-- Ctrl+N: สร้างไฟล์ใหม่ (พิมพ์ชื่อ เช่น src/a.lua; ลงท้าย / = โฟลเดอร์) ในโฟลเดอร์ของไฟล์ปัจจุบัน
-- รองรับ {a,b,c} แตกเป็นหลายไฟล์/โฟลเดอร์เหมือนใน Explorer เช่น "{login,sign-up}.tsx" หรือ "{css,js}/"
-- ใน Explorer ใช้ Ctrl+N ของ neo-tree แทน (สร้างในโฟลเดอร์ที่เลือก)
-- แตก {a,b,c} เป็นหลายชื่อ (รองรับซ้อนกันหลายชั้น เช่น {css,js}/{a,b}.ts)
local function expand_braces(s)
  local open = s:find("{", 1, true)
  if not open then return { s } end
  local close = s:find("}", open, true)
  if not close then return { s } end
  local inside = s:sub(open + 1, close - 1)
  if not inside:find(",", 1, true) then return { s } end
  local prefix, suffix = s:sub(1, open - 1), s:sub(close + 1)
  local results = {}
  for part in inside:gmatch("[^,]+") do
    part = part:gsub("^%s+", ""):gsub("%s+$", "")
    for _, expanded in ipairs(expand_braces(prefix .. part .. suffix)) do
      results[#results + 1] = expanded
    end
  end
  return results
end

local function new_file()
  local cur = vim.api.nvim_buf_get_name(0)
  local dir = (cur ~= "" and vim.bo.buftype == "") and vim.fn.fnamemodify(cur, ":p:h") or vim.fn.getcwd()
  vim.ui.input({ prompt = "ไฟล์ใหม่ใน " .. vim.fn.fnamemodify(dir, ":~:.") .. "/ : ", completion = "file" }, function(name)
    if not name or name == "" then return end
    local names = expand_braces(vim.trim(name))
    local first_file = nil
    for _, one in ipairs(names) do
      local path = vim.fs.normalize(dir .. "/" .. one)
      if one:sub(-1) == "/" then
        vim.fn.mkdir(path, "p")
      else
        vim.fn.mkdir(vim.fs.dirname(path), "p")
        if vim.fn.filereadable(path) == 0 then
          vim.fn.writefile({}, path) -- สร้างไฟล์เปล่าไว้เลย (ไฟล์ที่เหลือเปิดให้ทีหลัง)
        end
        first_file = first_file or path
      end
    end
    if #names > 1 then
      vim.notify(("สร้าง %d รายการเรียบร้อย"):format(#names))
    end
    if first_file then
      vim.cmd.edit(vim.fn.fnameescape(first_file))
    elseif #names == 1 then
      vim.notify("สร้างโฟลเดอร์ " .. vim.fs.normalize(dir .. "/" .. names[1]))
    end
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

-- ===== Sync popup (macOS): ถาม commit + push config ขึ้น GitHub ตอนเปิด nvim =====
-- ทำงานเฉพาะ macOS และเฉพาะเมื่อโฟลเดอร์ config เป็น git repo ที่มี remote
-- ถ้ามีไฟล์ค้าง (แก้แล้วยังไม่ commit) หรือ commit ค้าง (ยังไม่ push) จะเด้ง popup ถามตอนเปิด nvim
-- ปิดฟีเจอร์นี้ชั่วคราว: ใส่ `vim.g.sync_popup = false` ใน init.lua ก่อนบรรทัดนี้
-- รันเองเมื่อไหร่ก็ได้ด้วย :NvimSync
local function git_sync_out(dir, args)
  local cmd = { "git", "-C", dir }
  vim.list_extend(cmd, args)
  local ok, lines = pcall(vim.fn.systemlist, cmd)
  if not ok or vim.v.shell_error ~= 0 then return nil end
  return lines
end

local function nvim_config_sync_check()
  if vim.g.sync_popup == false then return end
  local dir = vim.fn.stdpath("config")
  if not git_sync_out(dir, { "rev-parse", "--is-inside-work-tree" }) then return end
  if not git_sync_out(dir, { "remote", "get-url", "origin" }) then return end

  local dirty = git_sync_out(dir, { "status", "--porcelain" }) or {}
  local sb = (git_sync_out(dir, { "status", "-sb" }) or {})[1] or ""
  local ahead = tonumber(sb:match("ahead (%d+)")) or 0
  if #dirty == 0 and ahead == 0 then return end

  local parts = {}
  if #dirty > 0 then parts[#parts + 1] = ("ไฟล์ค้าง %d ไฟล์"):format(#dirty) end
  if ahead > 0 then parts[#parts + 1] = ("commit ค้าง %d ตัว"):format(ahead) end

  local choice = vim.fn.confirm(
    ("Config มีของค้าง (%s) — sync ขึ้น GitHub ไหม?"):format(table.concat(parts, ", ")),
    "&Commit + Push\n&ภายหลัง"
  )
  if choice ~= 1 then return end

  local function do_push()
    local out = git_sync_out(dir, { "push", "origin" })
    vim.notify(out and "Sync config ขึ้น GitHub เรียบร้อย" or "Push ไม่สำเร็จ — ดูรายละเอียดด้วย :!git -C " .. dir .. " push",
      out and vim.log.levels.INFO or vim.log.levels.ERROR, { title = "nvim sync" })
  end

  if #dirty == 0 then
    do_push()
    return
  end
  vim.ui.input({ prompt = "ข้อความ commit: ", default = "chore: update nvim config" }, function(msg)
    if not msg or msg == "" then return end -- ยกเลิก ไม่ sync รอบนี้
    git_sync_out(dir, { "add", "-A" })
    local commit_out = git_sync_out(dir, { "commit", "-m", msg })
    if not commit_out then
      vim.notify("Commit ไม่สำเร็จ — ดูรายละเอียดด้วย :!git -C " .. dir .. " status",
        vim.log.levels.ERROR, { title = "nvim sync" })
      return
    end
    do_push()
  end)
end

vim.api.nvim_create_user_command("NvimSync", nvim_config_sync_check, { desc = "sync nvim config ขึ้น GitHub" })

-- ===== Sync จาก GitHub: เปิด nvim → เช็ก setup → ดึงอัปเดต → restart =====
-- 1) ถ้า config ยังไม่ผูกกับ GitHub → ถามเพื่อผูก remote origin (ไม่ลบ/เขียนทับไฟล์ใดๆ)
-- 2) ถ้า GitHub มี commit ใหม่และไม่มีไฟล์ค้างในเครื่อง → ถามแล้ว git pull --ff-only → :Lazy restore → restart nvim
-- 3) ถ้ามีไฟล์/commit ค้างในเครื่อง → popup commit + push (nvim_config_sync_check ด้านบน)
-- ปิดทั้งหมดด้วย `vim.g.sync_popup = false` ก่อนบรรทัดนี้ หรือรันเองด้วย :NvimUpdate
local CONFIG_REPO = "https://github.com/Panudetingai/nvim-config.git"

local function git_async(dir, args, cb)
  local cmd = { "git", "-C", dir }
  vim.list_extend(cmd, args)
  local ok = pcall(vim.system, cmd, { text = true }, function(res)
    vim.schedule(function() cb(res) end)
  end)
  if not ok then cb({ code = 1, stdout = "", stderr = "git not found" }) end
end

local function restart_nvim()
  if vim.fn.exists(":restart") == 2 then
    vim.cmd("restart")
  else
    vim.notify("อัปเดตแล้ว — กรุณาปิดแล้วเปิด nvim ใหม่", vim.log.levels.WARN, { title = "nvim sync" })
  end
end

local function nvim_config_update(manual)
  if vim.g.sync_popup == false and not manual then return end
  local dir = vim.fn.stdpath("config")
  local function info(msg, lvl) vim.notify(msg, lvl or vim.log.levels.INFO, { title = "nvim sync" }) end

  -- (1) ยังไม่ใช่ git repo / ยังไม่มี remote → เสนอให้ผูกกับ GitHub
  if not git_sync_out(dir, { "rev-parse", "--is-inside-work-tree" }) then
    if vim.fn.confirm("Config นี้ยังไม่ผูกกับ GitHub — ผูกกับ " .. CONFIG_REPO .. " ไหม?", "&ผูก\n&ภายหลัง") ~= 1 then return end
    git_sync_out(dir, { "init", "-b", "main" })
  end
  if not git_sync_out(dir, { "remote", "get-url", "origin" }) then
    if vim.fn.confirm("ยังไม่มี remote origin — ตั้งเป็น " .. CONFIG_REPO .. " ไหม?", "&ตั้ง\n&ภายหลัง") ~= 1 then return end
    git_sync_out(dir, { "remote", "add", "origin", CONFIG_REPO })
  end

  local branch = (git_sync_out(dir, { "rev-parse", "--abbrev-ref", "HEAD" }) or {})[1]
  if not branch or branch == "HEAD" then return end

  git_async(dir, { "fetch", "--quiet", "origin", branch }, function(res)
    if res.code ~= 0 then
      if manual then info("เชื่อมต่อ GitHub ไม่ได้ (offline?)", vim.log.levels.WARN) end
      return nvim_config_sync_check()
    end
    local counts = (git_sync_out(dir, { "rev-list", "--left-right", "--count", "HEAD...origin/" .. branch }) or {})[1] or "0\t0"
    local ahead, behind = counts:match("(%d+)%s+(%d+)")
    behind = tonumber(behind) or 0
    if behind == 0 then
      if manual then info("Config เป็นเวอร์ชันล่าสุดแล้ว") end
      return nvim_config_sync_check()
    end
    local dirty = git_sync_out(dir, { "status", "--porcelain" }) or {}
    if #dirty > 0 or (tonumber(ahead) or 0) > 0 then
      info(("GitHub มีอัปเดตใหม่ %d commit แต่ในเครื่องมีการแก้ที่ยังไม่ sync — รัน :NvimSync ก่อน แล้วค่อย pull เอง"):format(behind), vim.log.levels.WARN)
      return nvim_config_sync_check()
    end
    if vim.fn.confirm(("GitHub มีอัปเดตใหม่ %d commit — อัปเดตและ restart nvim ไหม?"):format(behind), "&อัปเดต\n&ภายหลัง") ~= 1 then return end
    git_async(dir, { "pull", "--ff-only", "origin", branch }, function(pull)
      if pull.code ~= 0 then
        return info("git pull ไม่สำเร็จ:\n" .. (pull.stderr or ""), vim.log.levels.ERROR)
      end
      info("อัปเดต config แล้ว กำลังซิงก์ปลั๊กอิน...")
      pcall(function() require("lazy").restore({ wait = true, show = false }) end)
      restart_nvim()
    end)
  end)
end

vim.api.nvim_create_user_command("NvimUpdate", function() nvim_config_update(true) end, { desc = "ดึงอัปเดต config จาก GitHub แล้ว restart" })
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function() vim.defer_fn(function() nvim_config_update(false) end, 1500) end,
})
