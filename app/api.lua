#!/usr/bin/env tarantool
local log    = require("log")
local server = require("http.server")
local json   = require("json")
local config = require("config")

box.cfg(config.tarantool)

local devices = require("models/devices"):new(box.schema)
local apps    = require("models/apps"):new(box.schema)

local function json_response(body, code)
   return {
      status  = code or 200,
      headers = { ["content-type"] = "application/json; charset=utf8" },
      body    = json.encode(body),
   }
end

local function devices_handler(request)
   local devices_table = devices:get_all()
   local code          = 200

   if not devices_table then
      code = 404
   end

   return json_response(devices_table, code)
end

local function apps_handler(request)
   if request.method == "GET" then
      return json_response(
         apps:get_all(),
         200
      )
   end

   if request.method == "POST" then
         return json_response(
            apps:insert(request:json()),
            201
         )
   end

   if request.method == "PUT" then
      local body = request:json()
      local id   = body.id
      body.id    = nil

      return json_response(
         apps:upsert(id, body),
         202
      )
   end
end

local function app_handler(request)
   return json_response(
      apps:get_by_id(tonumber(request:stash('id'))),
      200
   )
end

local function main()
   local server = server.new(
      config.http.addr,
      config.http.port,
      config.http.options
   )

   server:route(
      { path = "/" },
      function(request) return request:redirect_to("/index.html") end
   )

   server:route(
      { path = "/api/devices" },
      devices_handler
   )

   server:route(
      { path = "/api/apps" },
      apps_handler
   )

   server:route(
      { path = "/api/apps/:id" },
      app_handler
   )

   server:start()
end

main()
