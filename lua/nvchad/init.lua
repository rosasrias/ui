local api = vim.api
local config = require "nvconfig"
local new_cmd = api.nvim_create_user_command

if config.ui.statusline.enabled then
  vim.o.statusline = "%!v:lua.require('nvchad.stl." .. config.ui.statusline.theme .. "')()"
  require("nvchad.stl.utils").autocmds()
end

-- load nvdash on startup via VimEnter: runs after options.lua (so window-local
-- opts like 'number' are not clobbered) but before the first frame is drawn
if config.nvdash.load_on_startup then
  api.nvim_create_autocmd("VimEnter", {
    callback = function()
      local opening_file = api.nvim_buf_get_name(0)
      local is_dir = vim.fn.isdirectory(opening_file) == 1
      local bufmodifed = api.nvim_get_option_value("modified", { buf = 0 })

      if not bufmodifed and (is_dir or opening_file == "") then
        local current_buffer = api.nvim_get_current_buf()
        require("nvchad.nvdash").open()
        api.nvim_buf_delete(current_buffer, { force = true, unload = false })
      end
    end,
  })
end

if config.ui.tabufline.enabled then
  require "nvchad.tabufline.lazyload"
end

-- Command to toggle NvDash
new_cmd("Nvdash", function()
  if vim.g.nvdash_displayed then
    require("nvchad.tabufline").close_buffer(vim.g.nvdash_buf)
  else
    require("nvchad.nvdash").open()
  end
end, {})

new_cmd("NvCheatsheet", function()
  if vim.g.nvcheatsheet_displayed then
    vim.cmd "bw"
  else
    require("nvchad.cheatsheet." .. config.cheatsheet.theme)()
  end
end, {})

vim.schedule(function()
  require "nvchad.au"
end)
