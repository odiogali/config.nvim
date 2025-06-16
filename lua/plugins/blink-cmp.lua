return {
  'saghen/blink.cmp',
  enabled = true,
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = function(_, opts)
    opts.sources = vim.tbl_deep_extend('force', opts.sources or {}, {
      default = {
        'lsp',
        'path',
        'snippets',
        'buffer',
      },
    })
    opts.completion = {
      menu = {
        border = 'rounded',
        winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
      },
      documentation = {
        auto_show = true,
        window = {
          border = 'rounded',
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
        },
      },
    }
    opts.snippets = { preset = 'luasnip' }
    opts.keymap = {
      preset = 'enter',
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },

      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },

      ['<S-k>'] = { 'scroll_documentation_up', 'fallback' },
      ['<S-j>'] = { 'scroll_documentation_down', 'fallback' },

      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide', 'fallback' },
    }
    return opts
  end,
  -- config = function(_, opts)
  --   require('blink.cmp').setup(opts)
  --
  --   -- Force override all highlights after setup
  --   vim.schedule(function()
  --     local highlights = {
  --       'BlinkCmpMenu',
  --       'BlinkCmpMenuBorder',
  --       'BlinkCmpMenuSelection',
  --       'BlinkCmpLabel',
  --       'BlinkCmpLabelMatch',
  --       'BlinkCmpLabelDetail',
  --       'BlinkCmpLabelDescription',
  --       'BlinkCmpKind',
  --       'BlinkCmpDoc',
  --       'BlinkCmpDocBorder',
  --     }
  --
  --     for _, hl in ipairs(highlights) do
  --       vim.api.nvim_set_hl(0, hl, { link = 'Normal' })
  --     end
  --
  --     -- Keep selection visible
  --     vim.api.nvim_set_hl(0, 'BlinkCmpMenuSelection', { link = 'Visual' })
  --     vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { link = 'FloatBorder' })
  --     vim.api.nvim_set_hl(0, 'BlinkCmpDocBorder', { link = 'FloatBorder' })
  --   end)
  -- end,
}
