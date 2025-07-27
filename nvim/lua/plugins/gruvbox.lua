return {
<<<<<<< HEAD
"ellisonleao/gruvbox.nvim", 
priority = 1000 , 
config = true, 
opts = ...,
=======
      'sainnhe/gruvbox-material',
      lazy = false,
      priority = 1000,
      config = function()
        -- Optionally configure and load the colorscheme
        -- directly inside the plugin declaration.
        vim.g.gruvbox_material_background = 'hard'
        vim.g.gruvbox_material_enable_italic = true
        vim.cmd.colorscheme('gruvbox-material')
      end
>>>>>>> 61bf42f7e98c450b33fdaa164a2c956800c62024
}
