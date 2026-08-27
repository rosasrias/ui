local nvconfig = require "nvconfig"

local cmp_ui = nvconfig.ui.cmp
local cmp_style = cmp_ui.style
local transparency = nvconfig.base46.transparency

local format_color = require "nvchad.cmp.format"
local styles = require "nvchad.cmp.styles"

local atom_styled = cmp_style == "atom" or cmp_style == "atom_colored"

local fields = (atom_styled or cmp_ui.icons_left) and { "kind", "abbr", "menu" } or { "abbr", "kind", "menu" }

-- Resolve the active CMP style according to the
-- global Base46 transparency setting.
local style = styles.get(cmp_style, transparency)

local M = {
  formatting = {
    format = function(entry, item)
      local icons = require "nvchad.icons.lspkind"

      local icon = icons[item.kind] or ""
      local kind = item.kind or ""

      -- Atom / Atom Colored
      if atom_styled then
        item.menu = kind
        item.menu_hl_group = "LineNr"
        item.kind = " " .. icon .. " "

      -- Icons on the left
      elseif cmp_ui.icons_left then
        item.menu = kind
        item.menu_hl_group = "CmpItemKind" .. kind
        item.kind = icon

      -- Default / Flat / Bordered
      else
        item.kind = " " .. icon .. " " .. kind
        item.menu_hl_group = "comment"
      end

      -- LSP color formatting
      if kind == "Color" and cmp_ui.format_colors.lsp then
        format_color.lsp(entry, item, (not (atom_styled or cmp_ui.icons_left) and kind) or "")
      end

      -- Limit completion abbreviation width
      if #item.abbr > cmp_ui.abbr_maxwidth then
        item.abbr = string.sub(item.abbr, 1, cmp_ui.abbr_maxwidth) .. "…"
      end

      return item
    end,

    fields = fields,
  },

  window = {
    completion = {
      scrollbar = false,
      side_padding = atom_styled and 0 or 1,

      border = style.border,

      winhighlight = table.concat({
        "Normal:CmpPmenu",
        "CursorLine:CmpSel",
        "Search:None",
        "FloatBorder:CmpBorder",
      }, ","),
    },

    documentation = {
      border = style.border,

      winhighlight = table.concat({
        "Normal:CmpDoc",
        "FloatBorder:CmpDocBorder",
      }, ","),
    },
  },
}

return M
