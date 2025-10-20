local colorscheme = "catppuccin-mocha"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end

-- List of color schemes to toggle through
local color_schemes = {
    'catppuccin-latte',
    'catppuccin-frappe',
    'catppuccin-macchiato',
    'catppuccin-mocha'
}

-- Current index in the color schemes list
local current_index = 1

function toggle_colorscheme()
    -- Apply the current color scheme
    vim.cmd('colorscheme ' .. color_schemes[current_index])
    -- Move to the next color scheme in the list
    current_index = current_index % #color_schemes + 1
end
