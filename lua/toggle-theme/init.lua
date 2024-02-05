local M = {}
M.dark_mode = function() end
M.light_mode = function() end

local utils = require "toggle-theme.utils"
local timer_id = nil
local waiting_time = 5000

-- default cache file path
local cache_path = utils.path_join(vim.fn.stdpath "cache", "toggle_theme.json")

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

local load_file = function()
  -- Read cache file
  local file = io.open(cache_path, "r")

  -- If file not exist, create cache file and set theme
  if not file then
    create_or_change_cache()
  else
    -- If file exist, read cache file and set theme
    cache = vim.json.decode(file:read "*a")
    file:close()
  end
end

local set_theme = function()
  if cache.dark then
    M.dark_mode()
  else
    M.light_mode()
  end
end

local start_job = function()
  timer_id = vim.fn.timer_start(waiting_time, function()
    local mode = utils.get_system_mode()
    if mode ~= cache.dark then
      cache.dark = mode
      set_theme()
    end
  end, { ["repeat"] = -1 })
end

local stop_job = function()
  if timer_id == nil then
    return
  end

  vim.fn.timer_stop(timer_id)
  timer_id = nil
end

-- Toggle theme
M.toggle_theme = function()
  if timer_id == nil then
    local file = io.open(cache_path, "r")
    if file then
      cache = vim.json.decode(file:read "*a")
      cache.dark = not cache.dark
      file:close()
    end
    create_or_change_cache()
  else
    stop_job()
    cache.dark = not cache.dark
  end
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

  waiting_time = opts.waiting_time and opts.waiting_time or 2000

  if opts.following_system == true and utils.is_linux == false then
    -- Get theme when start
    vim.fn.timer_start(100, function()
      local mode = utils.get_system_mode()
      cache.dark = mode
      set_theme()
    end)
    start_job()
  else
    load_file()
    set_theme()
  end
end

return M
