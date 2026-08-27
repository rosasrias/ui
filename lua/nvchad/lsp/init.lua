local M = {}

local diagnostic = vim.diagnostic
local severity = diagnostic.severity

local SIGNS = {
  [severity.ERROR] = "󰅙",
  [severity.WARN] = "",
  [severity.INFO] = "󰋼",
  [severity.HINT] = "󰌵",
}

local function diagnostic_prefix()
  return "󰶻 ", "String"
end

function M.setup()
  diagnostic.config {
    virtual_text = {
      prefix = "",
    },

    signs = {
      text = SIGNS,
    },

    underline = true,
    update_in_insert = false,
    severity_sort = true,

    float = {
      suffix = "",
      header = {
        "  Diagnostics",
        "String",
      },
      prefix = diagnostic_prefix,
    },
  }
end

return M
