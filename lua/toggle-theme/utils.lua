local M = {}

local os_name = jit.os
M.is_windows = os_name:find "Windows" ~= nil
M.is_mac = os_name:find "OSX" ~= nil
M.is_linux = os_name:find "Linux" ~= nil

M.path_join = function(...)
  local sep = M.is_windows and "\\" or "/"
  return table.concat({ ... }, sep)
end

M.get_system_mode = function()
  if M.is_mac then
    local result = io.popen("osascript -e 'tell app \"System Events\" to tell appearance preferences to get dark mode'")
      :read "l"

    return result == "true" and true or false
  end
  return true
end

return M
