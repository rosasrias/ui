local M = {}
local nvconfig = require "nvconfig"
local ui = nvconfig.ui.cmp
local transparency = nvconfig.base46.transparency
local atom_styled = ui.style == "atom" or ui.style == "atom_colored"

local menu_cols
if atom_styled or ui.icons_left then
  menu_cols = { { "kind_icon" }, { "label" }, { "kind" } }
else
  menu_cols = { { "label" }, { "kind_icon" }, { "kind" } }
end

M.components = {
  kind_icon = {
    text = function(ctx)
      local icons = require "nvchad.icons.lspkind"
      local icon = (icons[ctx.kind] or "󰈚")

      if atom_styled then
        icon = " " .. icon .. " "
      end

      return icon
    end,
  },

  kind = {
    highlight = function(ctx)
      return atom_styled and "comment" or ctx.kind
    end,
  },
}

-- border logic mirrors nvchad/cmp/styles.lua: transparent => rounded even for atom
local border_style
if transparency then
  border_style = "rounded"
else
  border_style = atom_styled and "none" or "single"
end

M.menu = {
  scrollbar = false,
  border = border_style,
  draw = {
    padding = { atom_styled and 0 or 1, 1 },
    columns = menu_cols,
    components = M.components,
  },
}

return M
