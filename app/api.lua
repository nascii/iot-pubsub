#!/usr/bin/env tarantool
local log    = require("log")
local server = require("http.server")
local json   = require("json")
local config = require("config")

box.cfg({
      slab_alloc_arena = 0.3
})

local devices = require("models/devices"):new(box.schema)

local function json_response(body, code)
   return {
      status  = code or 200,
      headers = { ["content-type"] = "application/json; charset=utf8" },
      body    = json.encode(body),
   }
end

local function get_devices(request)
   local devices_table = devices:get_all()
   local code          = 200

   if not devices_table then
      code = 404
   end

   return json_response(devices_table, code)
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
      get_devices
   )

   server:start()
end

main()
