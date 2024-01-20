vim.api.nvim_create_user_command("ToggleTheme", function()
  require("toggle-theme").toggle_theme()
end, {
  desc = "ToggleTheme",
})
