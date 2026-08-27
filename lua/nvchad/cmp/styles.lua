local M = {}

M.styles = {
  default = {
    normal = {
      border = "single",
    },
    transparent = {
      border = "rounded",
    },
  },

  flat_light = {
    normal = {
      border = "single",
    },
    transparent = {
      border = "rounded",
    },
  },

  flat_dark = {
    normal = {
      border = "single",
    },
    transparent = {
      border = "rounded",
    },
  },

  atom = {
    normal = {
      border = "none",
    },
    transparent = {
      border = "rounded",
    },
  },

  atom_colored = {
    normal = {
      border = "none",
    },
    transparent = {
      border = "rounded",
    },
  },

  bordered = {
    normal = {
      border = "single",
    },
    transparent = {
      border = "rounded",
    },
  },
}

function M.get(style, transparency)
  local config = M.styles[style] or M.styles.default

  return transparency and config.transparent or config.normal
end

return M
