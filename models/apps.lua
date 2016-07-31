local M = {}

local util = require("lib/util")

local function normalize(res)
   local data = { id = res[1] }
   util.merge(data, res[2])
   return data
end

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
   return normalize(self.space.index.id:get(id))
end

function M:get_all()
   return self.space:select({})
end

function M:insert(app)
   return normalize(self.space:auto_increment({ app }))
end

function M:upsert(id, app)
   return normalize(self.space:put({ id, app }))
end

return M
