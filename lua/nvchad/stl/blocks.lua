local utils = require "nvchad.stl.utils"

local M = {}

M.mode = function()
  if not utils.is_activewin() then
    return ""
  end

  local mode = vim.api.nvim_get_mode().mode
  local current = utils.modes[mode] or utils.modes.n

  return "%#Staline" .. current[2] .. "Mode#  " .. current[1] .. " "
end

M.file = function()
  local x = utils.file()

  return "%#StalineFilenameIcon#"
    .. " "
    .. "%#StalineFilename#"
    .. x[1]
    .. " "
    .. x[2]
    .. " "
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
  return utils.diagnostics()
end

M.lsp_msg = function()
  return "%#St_LspMsg#" .. utils.lsp_msg()
end

M.lsp = function()
  local value = utils.lsp()

  value = value:gsub("%%#St_Lsp#", "")

  return "%#StalineLspIcon# LSP "
    .. "%#StalineLspText#"
    .. value
    .. "%#StalineEmptySpace#"
end

M.cwd = function()
  local cwd = vim.uv.cwd() or ""
  local name = cwd:match "([^/\\]+)[/\\]*$" or cwd

  return "%#StalineFolderIcon# DIR "
    .. "%#StalineFolderText# "
    .. name
    .. " "
    .. "%#StalineEmptySpace#"
end

M.cursor = function()
  local current = vim.fn.line "."
  local total = vim.fn.line "$"

  return "%#StalineProgress# "
    .. current
    .. "/"
    .. total
    .. " "
    .. "%#StalineProgressIcon# "
    .. "%#StalineEmptySpace#"
end

M["%="] = "%="

return function()
  return utils.generate("blocks", M)
end
