local M = {}

M.diagnostic_config = function()
  local severity = vim.diagnostic.severity

  vim.diagnostic.config {
    virtual_text = {
      prefix = "",
    },

    signs = {
      text = {
        [severity.ERROR] = " ",
        [severity.WARN] = " ",
        [severity.INFO] = " ",
        [severity.HINT] = "󰌵",
      },
    },

    underline = true,
    -- update_in_insert = false,
    -- severity_sort = true,

    float = {
      suffix = "",
      header = {
        "  Diagnostics",
        "String",
      },

      prefix = function()
        return " 󰶻 ", "String"
      end,
    },
  }
end

return M
