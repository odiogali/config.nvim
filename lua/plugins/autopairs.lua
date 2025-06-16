-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  dependencies = { "hrsh7th/nvim-cmp" },
  config = function()
    require("nvim-autopairs").setup({})

    -- Delay cmp integration setup until InsertEnter and cmp is loaded
    vim.api.nvim_create_autocmd("InsertEnter", {
      callback = function()
        local ok, cmp = pcall(require, "cmp")
        if not ok then
          return
        end
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end,
      once = true,
    })
  end,
}
