-- You can easily change to a different colorscheme.
-- Change the name of the colorscheme plugin below, and then
-- change the command in the config to whatever the name of that colorscheme is.
return {
  'sainnhe/gruvbox-material',
  priority = 1000, -- Make sure to load this before all the other start plugins.
  lazy = false,
  config = function()
    -- Load the colorscheme here.
    -- Like many other themes, this one has different styles, and you could load
    -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.

    vim.g.gruvbox_material_transparent_background = 1
    vim.g.gruvbox_material_ui_contrast = 'high' -- The contrast of line numbers, indent lines, etc.

    -- You can configure highlights by doing something like:
    vim.cmd.hi 'Comment gui=none'
    vim.cmd.colorscheme 'gruvbox-material'
    vim.o.background = 'dark'
  end,
}
