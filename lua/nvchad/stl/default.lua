local config = require("nvconfig").ui.statusline
local sep_style = config.separator_style

local utils = require "nvchad.stl.utils"

local sep_icons = utils.separators
local separators = (type(sep_style) == "table" and sep_style) or sep_icons[sep_style]

local sep_l = separators.left
local sep_r = separators.right

local M = {}

M.mode = function()
  if not utils.is_activewin() then
    return ""
  end

  local modes = utils.modes
  local mode = vim.api.nvim_get_mode().mode
  local current = modes[mode] or modes.n

  local current_mode = "%#St_" .. current[2] .. "Mode#  " .. current[1]

  local mode_sep = "%#St_" .. current[2] .. "ModeSep#" .. sep_r

  return current_mode .. mode_sep .. "%#ST_EmptySpace#" .. sep_r
end

M.file = function()
  local x = utils.file()

  local name = " " .. x[2] .. (sep_style == "default" and " " or "")

  return "%#St_file# " .. x[1] .. name .. "%#St_file_sep#" .. sep_r
end

M.git = function()
  return "%#St_gitIcons#" .. utils.git()
end

M.diff = utils.diff

M.lsp_msg = function()
  return "%#St_LspMsg#" .. utils.lsp_msg()
end

M.diagnostics = utils.diagnostics

M.lsp = function()
  return "%#St_Lsp# " .. " LSP ~" .. utils.lsp()
end

M.cwd = function()
  local icon = "%#St_cwd_icon#󰉋 "

  local cwd = vim.uv.cwd() or ""

  local name = cwd:match "([^/\\]+)[/\\]*$" or cwd

  name = "%#St_cwd_text# " .. name .. " "

  if vim.o.columns > 85 then
    return "%#St_cwd_sep#" .. sep_l .. icon .. name
  end

  return ""
end

M.cursor = "%#St_pos_sep#" .. sep_l .. "%#St_pos_icon# " .. "%#St_pos_text# %l/%v "

M["%="] = "%="

return function()
  return utils.generate("default", M)
end
