-- NOTE: Plugins can specify dependencies.
--
-- The dependencies are proper plugin specifications as well - anything
-- you do for a plugin at the top level, you can do for a dependency.
--
-- Use the `dependencies` key to specify the dependencies of a particular plugin

return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
  config = function()
    local lualine = require 'lualine'
    -- Color table for highlights
    -- stylua: ignore
    local colors = {
    bg       = '#1c1e26',
    fg       = '#bbc2cf',
    yellow   = '#FFA500',
    cyan     = '#008080',
    darkblue = '#081633',
    green    = '#98be65',
    orange   = '#FF8800',
    violet   = '#a9a1e1',
    magenta  = '#c678dd',
    blue     = '#51afef',
    pink      = '#ec5f67',
    red  = '#FF0000',
    }

    local conditions = {
      buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand '%:t') ~= 1
      end,
      hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end,
      check_git_workspace = function()
        local filepath = vim.fn.expand '%:p:h'
        local gitdir = vim.fn.finddir('.git', filepath .. ';')
        return gitdir and #gitdir > 0 and #gitdir < #filepath
      end,
    }

    -- Config
    local config = {
      options = {
        -- Disable sections and component separators
        component_separators = '',
        section_separators = '',
        theme = {
          -- We are going to use lualine_c an lualine_x as left and
          -- right section. Both are highlighted by c theme .  So we
          -- are just setting default looks o statusline
          normal = { c = { fg = colors.fg, bg = colors.bg } },
          inactive = { c = { fg = colors.fg, bg = colors.bg } },
        },
      },
      sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        -- These will be filled later
        lualine_c = {},
        lualine_x = {},
      },
      inactive_sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {},
      },
    }

    -- Inserts a component in lualine_c at left section
    local function ins_left(component)
      table.insert(config.sections.lualine_c, component)
    end

    -- Inserts a component in lualine_x at right section
    local function ins_right(component)
      table.insert(config.sections.lualine_x, component)
    end

    ins_left {
      function()
        return '▊'
      end,
      color = { fg = colors.blue }, -- Sets highlighting of component
      padding = { left = 0, right = 1 }, -- We don't need space before this
    }

    ins_left {
      -- mode component
      function()
        return ''
      end,
      color = function()
        -- auto change color according to neovims mode
        local mode_color = {
          n = colors.pink,
          i = colors.green,
          v = colors.blue,
          [''] = colors.blue,
          V = colors.blue,
          c = colors.magenta,
          no = colors.red,
          s = colors.orange,
          S = colors.orange,
          [''] = colors.orange,
          ic = colors.yellow,
          R = colors.violet,
          Rv = colors.violet,
          cv = colors.red,
          ce = colors.red,
          r = colors.cyan,
          rm = colors.cyan,
          ['r?'] = colors.cyan,
          ['!'] = colors.red,
          t = colors.red,
        }
        return { fg = mode_color[vim.fn.mode()] }
      end,
      padding = { right = 1 },
    }

    ins_left {
      -- filesize component
      'filesize',
      cond = conditions.buffer_not_empty,
    }

    ins_left {
      'filename',
      cond = conditions.buffer_not_empty,
      color = { fg = colors.magenta, gui = 'bold' },
    }

    local ts_utils = require 'nvim-treesitter.ts_utils'
    local ts_parsers = require 'nvim-treesitter.parsers'

    local function get_current_function_name()
      local bufnr = vim.api.nvim_get_current_buf()
      local lang = ts_parsers.get_buf_lang(bufnr)
      local current_node = ts_utils.get_node_at_cursor()

      if not current_node or not queries[lang] then
        return ''
      end

      local valid_function_nodes = {
        function_definition = true,
        function_declaration = true,
        method_definition = true,
        method_declaration = true,
        constructor_definition = true,
        destructor_definition = true,
        ['function'] = true,
        lambda = true,
        arrow_function = true,
      }

      local expr = current_node
      while expr do
        if valid_function_nodes[expr:type()] then
          break
        end
        expr = expr:parent()
      end

      if not expr then
        return ''
      end

      if lang == 'go' then
        return get_function_name_at_cursor()
      elseif lang == 'python' or lang == 'c' or lang == 'cpp' then
        -- Simply call your helper function for these languages too
        return get_function_name_at_cursor()
      else
        return ''
      end
    end
    local function get_current_function_name()
      local current_node = ts_utils.get_node_at_cursor()
      if not current_node then
        return ''
      end

      local expr = current_node

      local validStrings = {
        ['function_definition'] = 1, -- C, C++
        ['function_declaration'] = 2, -- C, C++
        ['method_definition'] = 3, -- C++, JS
        ['method_declaration'] = 4, -- C++, JS
        ['constructor_definition'] = 5, -- C++
        ['destructor_definition'] = 6, -- C++
        ['function'] = 7, -- Haskell, JS
        ['lambda'] = 8, -- Haskell, Python
        ['arrow_function'] = 9, -- JS
      }
      -- Traverse up the parent nodes to find the function definition
      while expr do
        if validStrings[expr:type()] then
          break
        end
        expr = expr:parent()
      end

      -- If no function definition is found, return empty string
      if not expr then
        return ''
      end

      local queries = {
        go = vim.treesitter.query.parse(
          'go',
          [[ (function_declaration name: (identifier) @funcname) (method_declaration name: (field_identifier) @funcname) ]]
        ),
        python = vim.treesitter.query.parse('python', [[ (function_definition name: (identifier) @funcname) ]]),
        c = vim.treesitter.query.parse(
          'c',
          [[
              (function_definition
                declarator: (function_declarator
                  declarator: (identifier) @funcname))
              (function_definition
                declarator: (pointer_declarator
                  declarator: (function_declarator
                    declarator: (identifier) @funcname)))
          ]]
        ),
      }

      local function get_function_name_at_cursor()
        local bufnr = vim.api.nvim_get_current_buf()
        local lang = ts_parsers.get_buf_lang(bufnr)

        if not queries[lang] then
          return ''
        end

        local parser = vim.treesitter.get_parser(bufnr, lang)
        local tree = parser:parse()[1]
        local root = tree:root()

        local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
        cursor_row = cursor_row - 1 -- Lua index correction

        -- Find the smallest node containing the cursor position
        local node = root:descendant_for_range(cursor_row, cursor_col, cursor_row, cursor_col)

        while node do
          local type = node:type()

          -- only match nodes that our query handles
          if type == 'function_declaration' or type == 'method_declaration' or type == 'function_definition' then
            for id, capture_node in queries[lang]:iter_captures(node, bufnr, node:start(), node:end_()) do
              local name = vim.treesitter.get_node_text(capture_node, bufnr)
              return '󰊕 ' .. name
            end
          end

          node = node:parent()
        end

        return ''
      end

      local function_name_node = expr
      local bufnr = vim.api.nvim_get_current_buf()
      local lang = ts_parsers.get_buf_lang(bufnr)

      if lang == 'python' then
        function_name_node = expr:child(1) -- The first child should be the function name
        if not function_name_node then
          return ''
        end
      elseif lang == 'c' then
        local name = get_function_name_at_cursor()
        return name
      elseif lang == 'go' then
        local name = get_function_name_at_cursor()
        return name
      elseif lang == 'cpp' then
        for child in expr:iter_children() do
          if string.find(child:type(), 'declarator') then
            -- Search for the identifier inside the declarator
            for grandchild in child:iter_children() do
              if string.find(grandchild:type(), 'identifier') then
                function_name_node = grandchild
              end
            end
          end
        end
      else
        return ''
      end

      local function_name = vim.treesitter.get_node_text(function_name_node, 0)

      local i = 1
      local res = ''
      while i <= #function_name and string.sub(function_name, i, i) ~= '(' do
        res = res .. string.sub(function_name, i, i)
        i = i + 1
      end

      res = '󰊕 ' .. res

      return res or ''
    end

    ins_left {
      function()
        return get_current_function_name()
      end,
      color = { fg = colors.violet, gui = 'none' },
    }

    ins_left { 'progress', color = { fg = colors.fg, gui = 'bold' } }

    ins_left {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      symbols = { error = ' ', warn = ' ', info = ' ' },
      diagnostics_color = {
        error = { fg = colors.red },
        warn = { fg = colors.yellow },
        info = { fg = colors.fg },
      },
    }

    -- Insert mid section. You can make any number of sections in neovim :)
    -- for lualine it's any number greater then 2
    ins_left {
      function()
        return '%='
      end,
    }

    --ins_left {
    --  -- Lsp server name .
    --  function()
    --    local msg = 'No Active Lsp'
    --    local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
    --    local clients = vim.lsp.get_clients()
    --    if next(clients) == nil then
    --      return msg
    --    end
    --    for _, client in ipairs(clients) do
    --      local filetypes = client.config.filetypes
    --      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
    --        return client.name
    --      end
    --    end
    --    return msg
    --  end,
    --  icon = ' LSP:',
    --  color = { fg = '#ffffff', gui = 'bold' },
    --}

    -- Add components to right sections
    ins_right {
      'o:encoding', -- option component same as &encoding in viml
      fmt = string.lower, -- I'm not sure why it's upper case either ;)
      cond = conditions.hide_in_width,
      color = { fg = colors.green, gui = 'bold' },
    }

    ins_right {
      'fileformat',
      fmt = string.upper,
      icons_enabled = true, -- I think icons are cool but Eviline doesn't have them. sigh
      color = { fg = colors.green, gui = 'bold' },
    }

    ins_right {
      'branch',
      icon = '',
      color = { fg = colors.violet, gui = 'bold' },
    }

    ins_right {
      'diff',
      -- Is it me or the symbol for modified us really weird
      symbols = { added = ' ', modified = '󰝤 ', removed = ' ' },
      diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.orange },
        removed = { fg = colors.red },
      },
      cond = conditions.hide_in_width,
    }

    ins_right {
      function()
        return '▊'
      end,
      color = { fg = colors.blue },
      padding = { left = 1 },
    }

    -- Now don't forget to initialize lualine
    lualine.setup(config)
  end,
}
