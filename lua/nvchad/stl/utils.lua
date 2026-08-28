local M = {}

M.stbufnr = function()
  return vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
end

M.is_activewin = function()
  return vim.api.nvim_get_current_win() == vim.g.statusline_winid
end

M.get_mode = function()
  local mode = vim.api.nvim_get_mode().mode
  return M.modes[mode] or M.modes.n
end

-- Orders
local orders = {
  default = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor" },
  minimal = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cwd", "cursor" },
  vscode = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cursor", "cwd" },
  blocks = { "mode", "file", "git", "diff", "%=", "diagnostics", "lsp_msg", "cwd","lsp", "cursor" },
  fancy = { "mode", "file", "git", "diff", "%=", "diagnostics", "lsp_msg", "cwd","lsp", "cursor" },
}

-- Generator
M.generate = function(theme, modules)
  local config = require("nvconfig").ui.statusline
  local order = config.order or orders[theme] or orders.default

  local result = {}

  -- Allow nvconfig modules to override built-in modules.
  if config.modules then
    for key, value in pairs(config.modules) do
      modules[key] = value
    end
  end

  for _, name in ipairs(order) do
    local module = modules[name]

    if module then
      module = type(module) == "string" and module or module()

      if module then
        result[#result + 1] = module
      end
    end
  end

  return table.concat(result)
end

-- Modes
M.modes = {
  ["n"] = { "NORMAL", "Normal" },
  ["no"] = { "NORMAL", "Normal" },
  ["nov"] = { "NORMAL", "Normal" },
  ["noV"] = { "NORMAL", "Normal" },
  ["noCTRL-V"] = { "NORMAL", "Normal" },

  ["niI"] = { "NORMAL i", "Normal" },
  ["niR"] = { "NORMAL r", "Normal" },
  ["niV"] = { "NORMAL v", "Normal" },

  ["nt"] = { "NTERMINAL", "NTerminal" },
  ["ntT"] = { "NTERMINAL", "NTerminal" },

  ["v"] = { "VISUAL", "Visual" },
  ["vs"] = { "V-CHAR", "Visual" },
  ["V"] = { "V-LINE", "Visual" },
  ["Vs"] = { "V-LINE", "Visual" },

  ["i"] = { "INSERT", "Insert" },
  ["ic"] = { "INSERT", "Insert" },
  ["ix"] = { "INSERT", "Insert" },

  ["t"] = { "TERMINAL", "Terminal" },

  ["R"] = { "REPLACE", "Replace" },
  ["Rc"] = { "REPLACE", "Replace" },
  ["Rx"] = { "REPLACE", "Replace" },
  ["Rv"] = { "V-REPLACE", "Replace" },
  ["Rvc"] = { "V-REPLACE", "Replace" },
  ["Rvx"] = { "V-REPLACE", "Replace" },

  ["s"] = { "SELECT", "Select" },
  ["S"] = { "S-LINE", "Select" },
  [""] = { "S-BLOCK", "Select" },

  ["c"] = { "COMMAND", "Command" },
  ["cv"] = { "COMMAND", "Command" },
  ["ce"] = { "COMMAND", "Command" },
  ["cr"] = { "COMMAND", "Command" },

  ["r"] = { "PROMPT", "Confirm" },
  ["rm"] = { "MORE", "Confirm" },
  ["r?"] = { "CONFIRM", "Confirm" },
  ["x"] = { "CONFIRM", "Confirm" },

  ["!"] = { "SHELL", "Terminal" },
}

-- File
M.file = function()
  local buf = M.stbufnr()
  local path = vim.api.nvim_buf_get_name(buf)

  local icon = "󰈚"
  local name = "Empty"

  if path ~= "" then
    name = path:match "([^/\\]+)[/\\]*$" or "Empty"
  end

  if name ~= "Empty" then
    local ok, mini_icons = pcall(require, "mini.icons")

    if ok then
      local ft_icon = mini_icons.get("file", name)

      if ft_icon then
        icon = ft_icon
      end
    else
      local ok_devicons, devicons = pcall(require, "nvim-web-devicons")

      if ok_devicons then
        icon = devicons.get_icon(name) or icon
      end
    end
  end

  return { icon, name }
end

-- Git
M.git = function()
  local buf = M.stbufnr()

  if not vim.b[buf].gitsigns_head or vim.b[buf].gitsigns_git_status then
    return ""
  end

  local git_status = vim.b[buf].gitsigns_status_dict

  if not git_status then
    return ""
  end

  local branch = git_status.head

  if not branch then
    return ""
  end

  return "%#St_gitIcons#  " .. branch .. " "
end

-- Git diff
M.diff = function()
  local buf = M.stbufnr()

  if not vim.b[buf].gitsigns_head or vim.b[buf].gitsigns_git_status then
    return ""
  end

  local status = vim.b[buf].gitsigns_status_dict

  if not status then
    return ""
  end

  local added = tonumber(status.added) or 0
  local changed = tonumber(status.changed) or 0
  local removed = tonumber(status.removed) or 0

  local result = {}

  if added > 0 then
    result[#result + 1] = "%#St_gitAdded#  " .. added .. " "
  end

  if changed > 0 then
    result[#result + 1] = "%#St_gitChanged#  " .. changed .. " "
  end

  if removed > 0 then
    result[#result + 1] = "%#St_gitRemoved#  " .. removed .. " "
  end

  return table.concat(result)
end

-- LSP message
M.state = {
  lsp_msg = "",
}

M.lsp_msg = function()
  if vim.o.columns < 120 then
    return ""
  end

  return M.state.lsp_msg
end

-- LSP
M.lsp = function()
  if not rawget(vim, "lsp") then
    return ""
  end

  local buf = M.stbufnr()

  for _, client in ipairs(vim.lsp.get_clients()) do
    if client.attached_buffers and client.attached_buffers[buf] then
      if vim.o.columns > 100 then
        return "%#St_Lsp# " .. client.name .. " "
      end

      return "%#St_Lsp# "
    end
  end

  return ""
end

-- Diagnostics
M.diagnostics = function()
  if not rawget(vim, "diagnostic") then
    return ""
  end

  local buf = M.stbufnr()

  local errors = #vim.diagnostic.get(buf, {
    severity = vim.diagnostic.severity.ERROR,
  })

  local warnings = #vim.diagnostic.get(buf, {
    severity = vim.diagnostic.severity.WARN,
  })

  local hints = #vim.diagnostic.get(buf, {
    severity = vim.diagnostic.severity.HINT,
  })

  local info = #vim.diagnostic.get(buf, {
    severity = vim.diagnostic.severity.INFO,
  })

  local result = {}

  if errors > 0 then
    result[#result + 1] = "%#St_lspError#  " .. errors .. " "
  end

  if warnings > 0 then
    result[#result + 1] = "%#St_lspWarning#  " .. warnings .. " "
  end

  if hints > 0 then
    result[#result + 1] = "%#St_lspHints# 󰛩 " .. hints .. " "
  end

  if info > 0 then
    result[#result + 1] = "%#St_lspInfo# 󰋼 " .. info .. " "
  end

  if #result == 0 then
    return ""
  end

  return table.concat(result)
end

-- Separators
M.separators = {
  default = {
    left = "",
    right = "",
  },

  round = {
    left = "",
    right = "",
  },

  block = {
    left = "█",
    right = "█",
  },

  arrow = {
    left = "",
    right = "",
  },
}

-- LSP progress
local spinners = {
  "",
  "󰪞",
  "󰪟",
  "󰪠",
  "󰪡",
  "󰪢",
  "󰪣",
  "󰪤",
  "󰪥",
  "",
}

M.autocmds = function()
  vim.api.nvim_create_autocmd("LspProgress", {
    pattern = { "begin", "report", "end" },

    callback = function(args)
      if not args.data or not args.data.params then
        return
      end

      local data = args.data.params.value

      if not data then
        return
      end

      local progress = ""

      if data.percentage then
        local index = math.max(1, math.min(10, math.floor(data.percentage / 10) + 1))
        local icon = spinners[index]

        progress = icon .. " " .. data.percentage .. "%% "
      end

      local loaded_count = ""

      if data.message then
        loaded_count = string.match(data.message, "^(%d+/%d+)") or ""
      end

      local message = progress .. (data.title or "") .. " " .. loaded_count
      M.state.lsp_msg = data.kind == "end" and "" or message

      vim.cmd.redrawstatus()
    end,
  })
end

return M
