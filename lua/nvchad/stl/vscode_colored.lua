local utils = require "nvchad.stl.utils"

local M = {}

M.mode = function()
  if not utils.is_activewin() then
    return ""
  end

  local modes = utils.modes
  local mode = vim.api.nvim_get_mode().mode
  local current = modes[mode] or modes.n

  return "%#St_" .. current[2] .. "mode#" .. "  " .. current[1] .. " "
end

M.file = function()
  local x = utils.file()

  local name = " " .. x[2] .. " "

  return "%#StText# " .. x[1] .. name
end

M.git = utils.git
M.diff = utils.diff
M.lsp_msg = utils.lsp_msg
M.diagnostics = utils.diagnostics

M.lsp = function()
  return "%#St_Lsp#" .. utils.lsp()
end

M.cursor = "%#StText# Ln %l, Col %v "
M["%="] = "%="

M.cwd = function()
  local cwd = vim.uv.cwd() or ""

  local name = cwd:match "([^/\\]+)[/\\]*$" or cwd

  return vim.o.columns > 85 and "%#St_cwd# 󰉖 " .. name .. " " or ""
end

return function()
  return utils.generate("vscode", M)
end
