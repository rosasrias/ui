local utils = require "nvchad.stl.utils"

local M = {}

M.mode = function()
  if not utils.is_activewin() then
    return ""
  end

  local mode = vim.api.nvim_get_mode().mode
  local current = utils.modes[mode] or utils.modes.n

  local sep = "%#Staline" .. current[2] .. "ModeSep# "
  local sep_two = "%#StalineModeSepTwo# "

  return "%#Staline"
    .. current[2]
    .. "Mode#  "
    .. current[1]
    .. " "
    .. sep
    .. sep_two
    .. " "
end

M.file = function()
  local x = utils.file()

  if x[2] == "Empty" then
    return "%#StalineFilenameFancy#  NVIM  " .. "%#StalineFilenameSep# " .. "%#StalineEmptySpace#"
  end

  return "%#StalineFilenameFancy#"
    .. " "
    .. x[1]
    .. "  "
    .. x[2]
    .. "   "
    .. "%#StalineFilenameSep# "
    .. "%#StalineEmptySpace#"
end

M.git = function()
  local git = utils.git()

  if git == "" then
    return ""
  end

  return git
end

M.diff = function()
  return utils.diff()
end

M.diagnostics = function()
  local value = utils.diagnostics()

  if value == "" then
    return ""
  end

  return value .. "%#StalineEmptySpace#"
end

M.lsp_msg = function()
  local value = utils.lsp_msg()

  if value == "" then
    return ""
  end

  return "%#St_LspMsg#" .. value
end

M.lsp = function()
  local value = utils.lsp()

  if value == "" then
    return ""
  end

  return "%#StalineLspIcon#"
    .. "   "
    .. "%#StalineLspName#"
    .. value:gsub("^%%#St_Lsp#", "")
    .. "%#StalineEmptySpace# "
end

M.cwd = function()
  local cwd = vim.uv.cwd() or ""
  local name = cwd:match "([^/\\]+)[/\\]*$" or cwd

  return "%#StalineFolderSep#"
    .. "%#StalineFolderIcon#"
    .. "  "
    .. "%#StalineFolderText# "
    .. name
    .. " "
    .. "%#StalineEmptySpace# "
end

M.cursor = function()
  local current = vim.fn.line "."
  local total = vim.fn.line "$"

  return "%#StalineProgressIcon#"
    .. "   "
    .. "%#StalineProgress#"
    .. " "
    .. current
    .. "/"
    .. total
    .. " "
    .. "%#StalineEmptySpace#"
end

M["%="] = "%="

return function()
  return utils.generate("fancy", M)
end
