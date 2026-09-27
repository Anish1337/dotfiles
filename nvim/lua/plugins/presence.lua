return {
  "andweeb/presence.nvim",
  config = function()
    -- Discord rich presence
    require("presence").setup({
      -- General options
      auto_update = true,
      neovim_image_text = "The One True Text Editor",
      main_image = "file", -- keep language / file-type image
      client_id = "793271441293967371",
      log_level = nil,
      debounce_timeout = 10,
      enable_line_number = false,
      blacklist = {},
      buttons = true,
      file_assets = {},
      show_time = false,

      -- Rich Presence text options (%s would insert the filename / project)
      editing_text = "Coding",
      file_explorer_text = "Browsing",
      git_commit_text = "Committing changes",
      plugin_manager_text = "Managing plugins",
      reading_text = "Reading",
      workspace_text = function()
        return nil -- omit the workspace / project line
      end,
    })

    -- presence.nvim always puts the filename (or language label) into
    -- assets.large_text when main_image = "file". Discord shows that as
    -- the image tooltip / secondary text. Force it to the status line instead.
    local presence = package.loaded.presence
    local discord = presence.discord
    local set_activity = discord.set_activity
    discord.set_activity = function(self, activity, callback)
      if activity.assets and activity.state then
        activity.assets.large_text = activity.state
      end
      return set_activity(self, activity, callback)
    end
  end,
}
