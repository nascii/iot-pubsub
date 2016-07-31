#!/usr/bin/env tarantool
local discovery = require("lib/discovery")
local util      = require("lib/util")
local config    = require("config")

box.cfg(config.tarantool)

local devices = require("models/devices"):new(box.schema)

local function on_device(device)
   util.log(device)
   devices:upsert(device)
end

discovery.discover(
   {
      host = "0.0.0.0",
      port = config.mqtt.port,
   },
   on_device
)
