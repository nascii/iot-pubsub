local M = {}

local util = require("lib/util")

function M.normalize(res)
   local data = { id = res[1] }
   util.merge(data, res[2])
   return data
end

return M
