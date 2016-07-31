local M = {}

local tarantool = require("lib/tarantool")

function M:new(schema)
   local space = schema.space.create(
      "device",
      { if_not_exists = true }
   )

   space:create_index(
      "id", {
         if_not_exists = true,
         unique        = true,
         parts         = { 1, "STR" }
   })

   self.__index = self
   return setmetatable({ space = space }, self)
end

function M:get_by_ip(ip)
   return self.space.index.id:get(ip)
end

function M:get_all()
   local res = {}
   for _, v in pairs(self.space:select({})) do
      table.insert(res, tarantool.normalize(v))
   end
   return res
end

function M:upsert(device)
   return tarantool.normalize(self.space:put({ device.addr, device }))
end

return M
