local M = {}

local api = vim.api
local cur_buf = api.nvim_get_current_buf
local set_buf = api.nvim_set_current_buf
local get_opt = api.nvim_get_option_value

local function buf_index(bufnr)
  for i, value in ipairs(vim.t.bufs) do
    if value == bufnr then
      return i
    end
  end
end

M.next = function()
  local bufs = vim.t.bufs
  local curbuf_index = buf_index(cur_buf())

  if not curbuf_index then
    set_buf(bufs[1])
    return
  end

  set_buf((curbuf_index == #bufs and bufs[1]) or bufs[curbuf_index + 1])
end

M.prev = function()
  local bufs = vim.t.bufs
  local curbuf_index = buf_index(cur_buf())

  if not curbuf_index then
    set_buf(bufs[1])
    return
  end

  set_buf((curbuf_index == 1 and bufs[#bufs]) or bufs[curbuf_index - 1])
end

M.close_buffer = function(bufnr)
  bufnr = bufnr or cur_buf()

  if not api.nvim_buf_is_valid(bufnr) then
    return
  end

  if vim.bo[bufnr].buftype == "terminal" then
    vim.cmd(vim.bo[bufnr].buflisted and "set nobl | enew" or "hide")
  else
    local cur_buf_index = buf_index(bufnr)
    local bufhidden = vim.bo[bufnr].bufhidden

    -- force close floating windows
    if api.nvim_win_get_config(0).zindex then
      vim.cmd "bw"
      return

    -- handle listed buffers
    elseif cur_buf_index and #vim.t.bufs > 1 then
      local new_buf_index = cur_buf_index == #vim.t.bufs and -1 or 1
      vim.cmd("b" .. vim.t.bufs[cur_buf_index + new_buf_index])

    -- handle unlisted buffers
    elseif not vim.bo[bufnr].buflisted then
      local tmpbufnr = vim.t.bufs[1]

      if tmpbufnr then
        local winid = vim.fn.bufwinid(tmpbufnr)
        winid = winid ~= -1 and winid or 0

        api.nvim_set_current_win(winid)
        api.nvim_set_current_buf(tmpbufnr)
      end

      vim.cmd("bw" .. bufnr)
      return
    else
      vim.cmd "enew"
    end

    if bufhidden ~= "delete" then
      vim.cmd("confirm bd" .. bufnr)
    end
  end

  local ok, state = pcall(require, "nvchad.tabufline.state")

  if ok then
    state.ensure()
  end

  vim.cmd "redrawtabline"
end

M.closeAllBufs = function(include_cur_buf)
  local bufs = vim.deepcopy(vim.t.bufs)

  if include_cur_buf ~= nil and not include_cur_buf then
    local index = buf_index(cur_buf())

    if index then
      table.remove(bufs, index)
    end
  end

  for _, buf in ipairs(bufs) do
    if api.nvim_buf_is_valid(buf) then
      M.close_buffer(buf)
    end
  end
end

M.closeBufs_at_direction = function(direction)
  local curbuf_index = buf_index(cur_buf())

  if not curbuf_index then
    return
  end

  local bufs = vim.deepcopy(vim.t.bufs)

  for i = #bufs, 1, -1 do
    local bufnr = bufs[i]

    if (direction == "left" and i < curbuf_index) or (direction == "right" and i > curbuf_index) then
      M.close_buffer(bufnr)
    end
  end
end

M.move_buf = function(n)
  local bufs = vim.t.bufs

  for i, bufnr in ipairs(bufs) do
    if bufnr == cur_buf() then
      if n < 0 and i == 1 or n > 0 and i == #bufs then
        bufs[1], bufs[#bufs] = bufs[#bufs], bufs[1]
      else
        bufs[i], bufs[i + n] = bufs[i + n], bufs[i]
      end

      break
    end
  end

  vim.t.bufs = bufs

  local ok, state = pcall(require, "nvchad.tabufline.state")

  if ok then
    state.ensure()
  end

  vim.cmd "redrawtabline"
end

M.goto_buf = function(bufnr)
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end

  local cur_win = api.nvim_get_current_win()
  local fixedbuf = get_opt("winfixbuf", { win = cur_win })

  if fixedbuf then
    for _, win in ipairs(api.nvim_list_wins()) do
      local buflisted = get_opt("buflisted", {
        buf = api.nvim_win_get_buf(win),
      })

      local tmp_fixedbuf = get_opt("winfixbuf", {
        win = win,
      })

      if buflisted and not tmp_fixedbuf then
        api.nvim_set_current_win(win)
        break
      end
    end
  end

  api.nvim_set_current_buf(bufnr)
end

return M
