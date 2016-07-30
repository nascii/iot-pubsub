#!/usr/bin/env tarantool
local log    = require("log")
local server = require("http.server")
local json   = require("json")
local config = require("config")

local devices_mock = {
   {
      id       = "fe80::5054:ff:fecb:288c",
      lastSeen = 666,
      caps     = {
         "tempterature"
      }
   }
}

local function json_response(body, code)
   return {
      status  = code or 200,
      headers = { ["content-type"] = "application/json; charset=utf8" },
      body    = json.encode(body),
   }
end

local function get_devices(request)
   return json_response(devices_mock, 200)
end

local function main()
   local server = server.new(
      config.http.addr,
      config.http.port
   )

   server:route(
      { path = "/api/devices" },
      get_devices
   )

   server:start()
end

main()
