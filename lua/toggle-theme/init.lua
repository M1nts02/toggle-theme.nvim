local M = {}
M.dark_mode = function() end
M.light_mode = function() end

local os_name = jit.os
local is_windows = os_name:find "Windows" ~= nil

local path_join = function(...)
  local sep = is_windows and "\\" or "/"
  return table.concat({ ... }, sep)
end

-- default cache file path
local cache_path = path_join(vim.fn.stdpath "cache", "toggle_theme.json")

-- default cache
local cache = {
  dark = true,
}

local create_or_change_cache = function()
  local cache_file = io.open(cache_path, "w")
  local context = vim.json.encode(cache)
  cache_file:write(context)
  cache_file:close()
end

local set_theme = function()
  if cache.dark then
    M.dark_mode()
  else
    M.light_mode()
  end
end

-- Toggle theme
M.toggle_theme = function()
  local file = io.open(cache_path, "r")
  if file then
    cache = vim.json.decode(file:read "*a")
    cache.dark = not cache.dark
    file:close()
  end
  create_or_change_cache()
  set_theme()
end

-- Get status
M.get_dark_mode = function()
  return cache.dark
end

-- Setup
M.setup = function(opts)
  vim.validate { option = { opts, "t" } }
  M.light_mode = opts.light_mode
  M.dark_mode = opts.dark_mode

  -- Read cache file
  local file = io.open(cache_path, "r")

  -- If file not exist, create cache file and set theme
  if not file then
    create_or_change_cache()
    set_theme()
  else
    -- If file exist, read cache file and set theme
    cache = vim.json.decode(file:read "*a")
    set_theme()
    file:close()
  end
end

return M
