return {
  {
    'maxmx03/dracula.nvim',
    lazy = false,
    priority = 1000,
    config = function ()
      ---@type dracula
      local dracula = require "dracula"

      dracula.setup({
      styles = {
        types = {},
        functions = {},
        parameters = {},
        comments = {},
        strings = {},
        keywords = {},
        variables = {},
        constants = {},
      },
      transparent = false,
      on_colors = function (colors, color)
        ---@type dracula.palette
        return {
          -- override or create new colors
          mycolor = "#ffffff",
        }
      end,
      on_highlights = function (colors, color)
        ---@type dracula.highlights
        return {
          ---@type vim.api.keyset.highlight
          Normal = { fg = colors.mycolor }
        }

