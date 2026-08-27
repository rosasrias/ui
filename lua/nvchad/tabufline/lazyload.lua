local opts = require("nvconfig").ui.tabufline

local api = vim.api
local get_opt = api.nvim_get_option_value
local cur_buf = api.nvim_get_current_buf

local autocmd = api.nvim_create_autocmd

--------------------------------------------------------------------------------
-- Buffer storage
--------------------------------------------------------------------------------

vim.t.bufs = vim.t.bufs or vim.tbl_filter(function(buf)
  return vim.fn.buflisted(buf) == 1
end, api.nvim_list_bufs())

--------------------------------------------------------------------------------
-- Buffer events
--------------------------------------------------------------------------------

autocmd({ "BufAdd", "BufEnter", "tabnew" }, {
  callback = function(args)
    local bufs = vim.t.bufs
    local is_current = cur_buf() == args.buf

    if not bufs then
      bufs = is_current and {} or { args.buf }
    end

    if
      not vim.tbl_contains(bufs, args.buf)
      and (args.event == "BufEnter" or not is_current or get_opt("buflisted", { buf = args.buf }))
      and api.nvim_buf_is_valid(args.buf)
      and get_opt("buflisted", { buf = args.buf })
    then
      table.insert(bufs, args.buf)
    end

    -- Remove unnamed unmodified buffer
    if args.event == "BufAdd" and bufs[1] then
      if #api.nvim_buf_get_name(bufs[1]) == 0 and not get_opt("modified", { buf = bufs[1] }) then
        table.remove(bufs, 1)
      end
    end

    vim.t.bufs = bufs
  end,
})

--------------------------------------------------------------------------------
-- Buffer deletion
--------------------------------------------------------------------------------

autocmd("BufDelete", {
  callback = function(args)
    for _, tab in ipairs(api.nvim_list_tabpages()) do
      local bufs = vim.t[tab].bufs

      if bufs then
        for i, bufnr in ipairs(bufs) do
          if bufnr == args.buf then
            table.remove(bufs, i)
            vim.t[tab].bufs = bufs
            break
          end
        end
      end
    end

    local ok, state = pcall(require, "nvchad.tabufline.state")

    if ok then
      state.ensure()
    end
  end,
})

--------------------------------------------------------------------------------
-- Lazy loading
--------------------------------------------------------------------------------

if opts.lazyload then
  api.nvim_create_autocmd({
    "BufNew",
    "BufNewFile",
    "BufRead",
    "TabEnter",
    "TermOpen",
  }, {
    pattern = "*",
    group = api.nvim_create_augroup("TabuflineLazyLoad", {}),

    callback = function()
      if #vim.fn.getbufinfo { buflisted = 1 } >= 2 or #api.nvim_list_tabpages() >= 2 then
        vim.o.showtabline = 2

        vim.o.tabline = "%!v:lua.require('nvchad.tabufline.modules')()"

        api.nvim_del_augroup_by_name "TabuflineLazyLoad"

        dofile(vim.g.base46_cache .. "tbline")
      end
    end,
  })
else
  vim.o.showtabline = 2

  vim.o.tabline = "%!v:lua.require('nvchad.tabufline.modules')()"

  dofile(vim.g.base46_cache .. "tbline")
end

--------------------------------------------------------------------------------
-- Quickfix
--------------------------------------------------------------------------------

autocmd("FileType", {
  pattern = "qf",

  callback = function()
    vim.opt_local.buflisted = false
  end,
})
