#!/usr/bin/env tarantool
local discovery = require("lib/discovery")
local util      = require("lib/util")
local config    = require("config")

local function on_device(device)
   util.log(device)
end

discovery.discover(
   {
      host = "0.0.0.0",
      port = config.mqtt.port,
   },
   on_device
)
