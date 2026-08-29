local api = vim.api
local fn = vim.fn

local utils = require "nvchad.tabufline.utils"
local state = require "nvchad.tabufline.state"

local txt = utils.txt
local btn = utils.btn
local style_buf = utils.style_buf

local strep = string.rep
local cur_buf = api.nvim_get_current_buf

local opts = require("nvconfig").ui.tabufline

local M = {}

-- Callback registration

local function register_callbacks()
  if vim.g.nvchad_tabufline_callbacks then
    return
  end

  vim.g.nvchad_tabufline_callbacks = true

  vim.cmd [[
    function! TbGoToBuf(bufnr,b,c,d)
      call luaeval('require("nvchad.tabufline").goto_buf(_A)', a:bufnr)
    endfunction

    function! TbKillBuf(bufnr,b,c,d)
      call luaeval('require("nvchad.tabufline").close_buffer(_A)', a:bufnr)
    endfunction

    function! TbScrollLeft(a,b,c,d)
      lua require('nvchad.tabufline.state').scroll_left()
    endfunction

    function! TbScrollRight(a,b,c,d)
      lua require('nvchad.tabufline.state').scroll_right()
    endfunction

    function! TbNewTab(a,b,c,d)
      tabnew
    endfunction

    function! TbGotoTab(tabnr,b,c,d)
      execute a:tabnr .. 'tabnext'
    endfunction

    function! TbToggleTheme(a,b,c,d)
      lua require('base46').toggle_theme()
    endfunction

    function! TbToggleTransparency(a,b,c,d)
      lua require('base46').toggle_transparency()
    endfunction

    function! TbCloseAllBufs(a,b,c,d)
      lua require('nvchad.tabufline').closeAllBufs()
    endfunction

    function! TbSplit(a,b,c,d)
      vsplit
    endfunction

    function! TbRun(a,b,c,d)
      lua require('code-runner').build_run()
    endfunction
  ]]
end

register_callbacks()

-- Hide the right-side action buttons while the dashboard is shown
local function dashboard_active()
  return vim.g.nvdash_displayed == true
end

-- Tree width
local function get_tree_width()
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    local buf = api.nvim_win_get_buf(win)

    if vim.bo[buf].filetype == opts.treeOffsetFt then
      return api.nvim_win_get_width(win)
    end
  end

  return 0
end

-- Buffer data
local function get_buffer_data()
  local buffers = {}

  vim.t.bufs = vim.tbl_filter(api.nvim_buf_is_valid, vim.t.bufs or {})

  for i, bufnr in ipairs(vim.t.bufs) do
    buffers[i] = {
      bufnr = bufnr,
      width = opts.bufwidth,
    }
  end

  return buffers
end

-- Tree offset
M.treeOffset = function()
  local width = get_tree_width()

  if width == 0 then
    return ""
  end

  return "%#NvimTreeNormal#" .. strep(" ", width) .. "%#NvimTreeWinSeparator#│"
end

-- Buffers
M.buffers = function()
  local buffers = get_buffer_data()
  local total = #buffers

  state.set_visible_buffers(buffers)
  state.ensure()

  if total == 0 then
    return txt("", "Fill")
  end

  local tree_width = get_tree_width()

  -- Reserve space for:
  -- tree + scroll + right-side modules

  local scroll_space = 4
  local right_space = 12

  local available_width = vim.o.columns - tree_width - scroll_space - right_space

  available_width = math.max(opts.bufwidth, available_width)

  local min_buffers = tree_width > 0 and 3 or 4

  local visible_count, last_index = state.get_range(total, available_width, min_buffers)

  local result = {}

  for i = state.scroll_offset, state.scroll_offset + visible_count - 1 do
    local buffer = buffers[i]

    if buffer then
      result[#result + 1] = style_buf(buffer.bufnr, i, opts.bufwidth)
    end
  end

  local left_scroll = ""

  if state.scroll_offset > 1 then
    left_scroll = btn("  ", "Scroll", "TbScrollLeft")
  end

  local right_scroll = ""

  if state.is_right_visible(last_index, total) then
    right_scroll = btn("  ", "Scroll", "TbScrollRight")
  end

  return table.concat {
    left_scroll,
    table.concat(result),
    right_scroll,
    txt("%=", "Fill"),
  }
end

-- Tabs
M.tabs = function()
  local tabs = fn.tabpagenr "$"

  if tabs <= 1 then
    return ""
  end

  local result = {}

  for nr = 1, tabs do
    local hl = "TabO" .. (nr == fn.tabpagenr() and "n" or "ff")

    result[#result + 1] = btn(" " .. nr .. " ", hl, "TbGotoTab", nr)
  end

  result[#result + 1] = btn(" 󰐕 ", "TabNewBtn", "TbNewTab")

  return table.concat(result)
end

-- Run
M.run = function()
  if dashboard_active() then
    return ""
  end

  local icon = vim.bo.filetype == "html" and "󰀂" or ""

  return btn(" " .. icon .. " ", "BuffLineRun", "TbRun")
end

-- Split
M.split = function()
  if dashboard_active() then
    return ""
  end

  return btn("  ", "BuffLineSplit", "TbSplit")
end

-- Transparency
M.transparency = function()
  if dashboard_active() then
    return ""
  end

  return btn(" 󱡓 ", "BufflineTrans", "TbToggleTransparency")
end

-- Theme
M.theme_toggle = function()
  if dashboard_active() then
    return ""
  end

  return btn(" 󱥚  ", "BuffLineToggleTheme", "TbToggleTheme")
end

-- Close all
M.close_all = function()
  if dashboard_active() then
    return ""
  end

  return btn(" 󰅗 ", "BufflineCloseButton", "TbCloseAllBufs")
end

-- Render
return function()
  if opts.modules then
    for key, value in pairs(opts.modules) do
      M[key] = value
    end
  end

  local result = {}

  for _, module in ipairs(opts.order) do
    local render = M[module]

    if render then
      result[#result + 1] = render()
    end
  end

  return table.concat(result)
end
