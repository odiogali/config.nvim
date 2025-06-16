return {
  {
    'neovim/nvim-lspconfig',
    opts = {
      servers = {
        gopls = {},
        clangd = {},
        pyright = {},
        rust_analyzer = {},
        hls = {},
        glsl_analyzer = {
          filetypes = {
            'glsl',
            'vert',
            'frag',
          },
        },
      },
    },
  },
}
