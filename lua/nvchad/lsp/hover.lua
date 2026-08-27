local M = {}

local api = vim.api
local lsp = vim.lsp

local nvconfig = require "nvconfig"

local FALLBACK_ICON = "󰒋"
local FALLBACK_HL = "Normal"
local DEFAULT_WIDTH = 60

---@return string
local function get_border()
  return nvconfig.base46.transparency and "rounded" or "single"
end

---@param bufnr number
---@return string
local function get_client_name(bufnr)
  local clients = lsp.get_clients { bufnr = bufnr }

  return clients[1] and clients[1].name or "LSP"
end

---@param bufnr number
---@return string icon
---@return string hl
local function get_filetype_icon(bufnr)
  local ok, mini_icons = pcall(require, "mini.icons")

  if not ok then
    return FALLBACK_ICON, FALLBACK_HL
  end

  local filetype = vim.bo[bufnr].filetype
  local icon, hl = mini_icons.get("filetype", filetype)

  return icon or FALLBACK_ICON, hl or FALLBACK_HL
end

---@param contents string[]
local function add_padding(contents)
  for index, line in ipairs(contents) do
    contents[index] = ("  %s  "):format(line)
  end
end

---@param opts table
---@param bufnr number
local function configure_window(opts, bufnr)
  opts.border = get_border()
  opts.width = DEFAULT_WIDTH
  opts.scrollbar = false
  opts.focusable = true
  opts.focus = false

  local icon, icon_hl = get_filetype_icon(bufnr)
  local client_name = get_client_name(bufnr)

  opts.title = {
    { " " .. icon .. " ", icon_hl },
    { client_name .. " ", icon_hl },
  }

  opts.title_pos = "right"
end

function M.setup()
  if M._original_open_floating_preview then
    return
  end

  M._original_open_floating_preview = lsp.util.open_floating_preview

  lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
    opts = opts or {}

    local bufnr = api.nvim_get_current_buf()

    add_padding(contents)
    configure_window(opts, bufnr)

    return M._original_open_floating_preview(contents, syntax, opts, ...)
  end
end

return M
