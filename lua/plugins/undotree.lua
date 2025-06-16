return {
  'mbbill/undotree',
  opts = {},
  config = function()
    vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
  end,
}
