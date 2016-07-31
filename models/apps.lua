local M = {}

local util      = require("lib/util")
local tarantool = require("lib/tarantool")

function M:new(schema)
   local space = schema.space.create(
      "apps",
      { if_not_exists = true }
   )

   space:create_index(
      "id", {
         type          = "TREE",
         if_not_exists = true,
         unique        = true,
         parts         = { 1, "NUM" }
   })

   self.__index = self
   return setmetatable({ space = space }, self)
end

function M:get_by_id(id)
   return tarantool.normalize(self.space.index.id:get(id))
end

function M:get_all()
   local res = {}
   for _, v in pairs(self.space:select({})) do
      table.insert(res, tarantool.normalize(v))
   end
   return res
end

function M:insert(app)
   return tarantool.normalize(self.space:auto_increment({ app }))
end

function M:upsert(id, app)
   return tarantool.normalize(self.space:put({ id, app }))
end

return M
