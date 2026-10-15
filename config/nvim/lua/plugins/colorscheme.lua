-- Optional system theme.
-- local function system_mode()
--   local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
--   if not handle then
--     return "dark"
--   end
--   local result = handle:read("*a") or ""
--   handle:close()
--   if result:match("Dark") then
--     return "dark"
--   end
--   return "light"
-- end
--
-- vim.o.background = system_mode()
vim.o.background = "dark"

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,

    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,

    opts = {
      flavour = "auto",
      background = {
        light = "latte",
        dark = "frappe",
      },
    },
  },

  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },

  { "folke/tokyonight.nvim", enabled = false },
}
