local M = {}

M.scroll_offset = 1
M.visible_buffers = {}

function M.reset()
  M.scroll_offset = 1
  M.visible_buffers = {}
end

function M.ensure()
  local total = #vim.t.bufs

  if total == 0 then
    M.scroll_offset = 1
    return
  end

  M.scroll_offset = math.max(1, math.min(M.scroll_offset, total))
end

function M.set_visible_buffers(buffers)
  M.visible_buffers = buffers or {}
end

function M.scroll_left()
  local total = #M.visible_buffers

  if total <= 1 then
    return
  end

  if M.scroll_offset > 1 then
    M.scroll_offset = M.scroll_offset - 1
  else
    M.scroll_offset = total
  end

  vim.cmd "redrawtabline"
end

function M.scroll_right()
  local total = #M.visible_buffers

  if total <= 1 then
    return
  end

  if M.scroll_offset < total then
    M.scroll_offset = M.scroll_offset + 1
  else
    M.scroll_offset = 1
  end

  vim.cmd "redrawtabline"
end

function M.is_left_visible()
  return M.scroll_offset > 1
end

function M.get_range(total, available_width, min_buffers)
  if total == 0 then
    return 0, 0
  end

  M.ensure()

  local visible_count = 0
  local used_width = 0
  local last_index = M.scroll_offset

  for i = M.scroll_offset, total do
    local buffer = M.visible_buffers[i]

    if not buffer then
      break
    end

    local width = buffer.width

    if used_width + width > available_width and visible_count >= min_buffers then
      break
    end

    used_width = used_width + width
    visible_count = visible_count + 1
    last_index = i
  end

  return visible_count, last_index
end

function M.is_right_visible(last_index, total)
  return last_index < total
end

return M
