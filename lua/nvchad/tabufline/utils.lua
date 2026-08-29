local M = {}

local api = vim.api
local get_opt = api.nvim_get_option_value
local strep = string.rep
local cur_buf = api.nvim_get_current_buf
local buf_name = api.nvim_buf_get_name

local icon_cache = {}

local FALLBACK_ICON = "󰈚"
local FALLBACK_HL = "DevIconDefault"

local function filename(path)
  return path:match "([^/\\]+)[/\\]*$"
end

local function get_icon(name)
  if not name or name == "" then
    return FALLBACK_ICON, FALLBACK_HL
  end

  if icon_cache[name] then
    return icon_cache[name][1], icon_cache[name][2]
  end

  -- Prefer nvim-web-devicons
  local ok, devicons = pcall(require, "nvim-web-devicons")

  if ok then
    local icon, hl = devicons.get_icon(name)

    if icon then
      icon_cache[name] = { icon, hl }
      return icon, hl
    end
  end

  -- Fallback to mini.icons
  local ok_mini, mini_icons = pcall(require, "mini.icons")

  if ok_mini then
    local icon, hl = mini_icons.get("file", name)

    if icon then
      icon_cache[name] = { icon, hl }
      return icon, hl
    end
  end

  icon_cache[name] = {
    FALLBACK_ICON,
    FALLBACK_HL,
  }

  return FALLBACK_ICON, FALLBACK_HL
end

local function new_hl(group1, group2)
  local fg = api.nvim_get_hl(0, {
    name = group1,
    link = false,
  }).fg

  local bg = api.nvim_get_hl(0, {
    name = "Tb" .. group2,
    link = false,
  }).bg

  local name = group1 .. group2

  api.nvim_set_hl(0, name, {
    fg = fg,
    bg = bg,
  })

  return "%#" .. name .. "#"
end

local function gen_unique_name(name, index)
  for i2, nr2 in ipairs(vim.t.bufs) do
    local filepath = filename(buf_name(nr2))

    if index ~= i2 and filepath == name then
      return vim.fn.fnamemodify(buf_name(vim.t.bufs[index]), ":h:t") .. "/" .. name
    end
  end
end

M.txt = function(str, hl)
  return "%#Tb" .. hl .. "#" .. (str or "")
end

M.btn = function(str, hl, func, arg)
  str = hl and M.txt(str, hl) or str
  arg = arg or ""

  return "%" .. arg .. "@" .. func .. "@" .. str .. "%X"
end

M.style_buf = function(nr, index, width)
  local is_current = cur_buf() == nr
  local tb_hl_name = "BufO" .. (is_current and "n" or "ff")

  local name = filename(buf_name(nr))

  if name then
    name = gen_unique_name(name, index) or name
  else
    name = " No Name "
  end

  local icon, icon_hl = get_icon(filename(buf_name(nr)))

  icon_hl = new_hl(icon_hl, tb_hl_name)

  local max_name_len = math.max(1, width - 7)

  if #name > max_name_len then
    name = name:sub(1, max_name_len - 2) .. ".."
  end

  local name_width = vim.fn.strdisplaywidth(name)

  local pad = math.floor((width - name_width - 5) / 2)

  pad = math.max(1, pad)

  local content = table.concat {
    strep(" ", pad),
    icon_hl,
    " ",
    icon,
    " ",
    M.txt(name, tb_hl_name),
    strep(" ", pad),
  }

  local close_btn

  local modified = get_opt("modified", {
    buf = nr,
  })

  if modified then
    close_btn = M.txt("  ", is_current and "BufOnModified" or "BufOffModified")
  else
    local close_hl = is_current and "KillBufOn" or "KillBufOff"
    close_btn = M.btn(
      " 󰅖 ",
      close_hl,
      "TbKillBuf",
      nr
    )
  end

  content = M.btn(content, nil, "TbGoToBuf", nr)

 return M.txt(content .. close_btn, tb_hl_name)
end

return M
