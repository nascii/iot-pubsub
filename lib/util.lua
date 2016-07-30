local M = {}

local json    = require("json")
local logging = require("log")

function M.log(...)
   logging.info(json.encode({...}))
end

function M.debug(...)
   logging.debug(json.encode({...}))
end

function M.split(str, pat)
   local res = {}
   for x in string.gmatch(str, "[^" .. pat .. "]+") do
      table.insert(res, x)
   end
   return res
end

function M.merge(t1, t2)
   for k,v in pairs(t2) do
      t1[k] = v
   end
end


return M
