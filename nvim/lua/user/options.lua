local options = {
    -- automatically indent line 
    autoindent = true,                       
    -- autom. read file when changed outside of Vim 
    autoread = true,                        
    -- automatically write file if changed
    autowrite = true,
    -- keep backup file after overwriting a file
    backup = false,
    -- do not ring the bell for these reasons
    belloff = "all",
    -- wrapped line repeats indent
    breakindent = false,
    -- use the clipboard as the unnamed register
    clipboard = "unnamedplus",
    -- number of lines to use for the command-line
    cmdheight = 1,
    -- columns to highlight
    colorcolumn = "80",
    -- specify how Insert mode completion works
    complete = ".,w,b,u,t",
    -- options for Insert mode completion
    completeopt = "menuone,noinsert,noselect,preview",
    -- whether concealable text is shown or hidden
    conceallevel = 0,
    -- highlight the screen column of the cursor
    cursorcolumn = false,
    -- highlight the screen line of the cursor
    cursorline = true,
    -- use spaces when <Tab> is inserted
    expandtab = true,
    -- highlight matches with last search pattern
    hlsearch = false,
    -- ignore case in search patterns
    ignorecase = true,
    -- file encoding for multibyte text
    fileencoding = "utf-8",
    -- program to use for the ":make" command
    makeprg = "make",
    -- enable the use of mouse clicks
    mouse = "a",
    -- print the line number in front of each line
    number = true,
    -- number of columns used for the line number
    numberwidth = 4,
    -- list of directories searched with "gf" et.al.
    path = ".,/usr/include,,",
    -- maximum number of items to show in the popup menu
     pumheight = 10,
    -- show relative line number in front of each line
    relativenumber = true,
    -- number of spaces to use for (auto)indent step
    shiftwidth = 4,
    -- message on status line to show current mode
    showmode = false,
    -- minimum nr. of lines above and below cursor
    scrolloff = 10,
    -- list of flags, reduce length of messages
    shortmess = "flmnrwxtToOFc",
    -- min. nr. of columns to left and right of cursor
    sidescrolloff = 0,
    -- when and how to display the sign column
    signcolumn = "yes",
    -- no ignore case when pattern has uppercase
    smartcase = true,
    -- smart autoindenting for C programs
    smartindent = true,
    -- new window from split is below the current one
    splitbelow = true,
    -- new window is put right of the current one
    splitright = true,
    -- whether to use a swapfile for a buffer
    swapfile = false,
    -- number of spaces that <Tab> in file uses
    tabstop = 2,
    -- time out on mappings and key codes
    timeout = true,
    -- time out time in milliseconds
    timeoutlen = 300,
    -- Vim set the title of the window
    title = true,
    -- save undo information in a file
    undofile = true,
    -- after this many milliseconds flush swap file
    updatetime = 250,
    -- lines wrap and continue on the next line
    wrap = false,
    -- Enables 24-bit RGB color in the |TUI|.
    termguicolors = true,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end
