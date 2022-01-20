local options = {
  -- General options
  backup = false,                          -- creates a backup file
  clipboard = "unnamedplus",               -- allow access to system clipboard
  conceallevel = 0,                        -- `` is visible in markdown files
  fileencoding = "utf-8",                  -- the encoding written to a file
  hlsearch = true,                         -- highlight matches on search
  ignorecase = true,                       -- ignore case in search patterns
  mouse = "a",                             -- allow mouse movements in neovim
  showmode = false,                        -- suppress showing mode name 
  smartcase = true,                        -- chooses when to unset ignorecase
  swapfile = false,                        -- do not create a swap file
  termguicolors = true,                    -- set term gui colors
  timeoutlen = 1000,                       -- time to wait for mapped sequence
  title = true,                            -- set titlebar to display fname
  undofile = true,                         -- enable persistent undo
  updatetime = 300,                        -- faster completion in ms
  -- End of general options
  --
  -- Indent options
  autoindent = true,	               		   -- automatically indent line 
  expandtab = true,                        -- convert tabs to spaces
  shiftwidth = 2,                          -- number of spaces per indentation
  smartindent = true,                      -- make indenting smarter again
  tabstop = 2,                             -- insert 2 spaces for a tab
  -- End of indent options
  --
  -- Completion options
  completeopt = { "menuone",               -- use popup menu for completions 
                  "noselect" },            -- no selection until user selects
  -- End of completion options
  --
  -- Split options
  splitbelow = true,                       -- all horizontal splits go below
  splitright = true,                       -- all vertical splits go right
  -- End of split options
  --
  -- Line options
  cmdheight = 1,                           -- more space in the command line
  colorcolumn = "80",                      -- keep a visible column line
  cursorline = true,                       -- highlight the current line
  number = true,                          -- set numbered lines
  numberwidth = 4,                         -- set number column width
  relativenumber = true,                  -- set relative numbered lines
  scrolloff = 8,                           -- keep lines visible at each side
  showtabline = 2,                         -- always show tabs
  sidescrolloff = 8,			                 -- keep lines visible at each side
  -- signcolumn = "yes",                      -- always show the sign column
  wrap = false,                            -- display lines as one long line
  pumheight = 10,                          -- pop up menu height
  -- End of line options
  --
}


vim.opt.shortmess:append "c"

for k, v in pairs(options) do
	vim.opt[k] = v
end

