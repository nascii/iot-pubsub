#!/usr/bin/env tarantool

local M = {}

local mqtt    = require("mqtt")
local fiber   = require("fiber")
local json    = require("json")
local util    = require("lib/util")
local clock   = require("clock")
local device  = require("lib/device")

M.tick = 3

function M.get_device_addr(topic)
   local parts = util.split(topic, "/")
   if #parts < 3 then
      return
   end

   return string.match(parts[3], "^[a-f0-9:]+$")
end

local function message_handler(id, topic, message)
   local addr = M.get_device_addr(topic)
   if not addr then
      util.debug("received non relevant topic", topic)
      return
   end

   local fixed_data = "[" .. message:sub(2, -2) .. "]"

   local data = {}
   for _, v in pairs(json.decode(fixed_data)) do
      util.merge(data, v)
   end

   local caps      = device.get_capabilities(tonumber(data.ability, 16))
   local last_seen = math.floor(clock.time()) - tonumber(data.last_seen, 10)

   util.log(
      "found device",
      addr,
      caps,
      last_seen
   )

   return {
      addr      = addr,
      caps      = caps,
      last_seen = last_seen,
   }
end

function M.discover(broker, channels, on_device)
   local ok, msg
   mq = mqtt.new()

   ok, msg = mq:on_message(function(...)
         local device = message_handler(...)
         if device then
            on_device(device)
         end
   end)
   if not ok then
      error("failed to receive message from channel")
   end

   ok, msg = mq:connect(broker)
   if not ok then
      error("failed to connect to mqtt broker")
   end

   util.log("connected", broker, ok, msg)

   ok, msg = mq:subscribe(channels.broadcast)
   if not ok then
      error("failed to subscribe to " .. channels.broadcast)
   end

   util.log("subscribed to " .. channels.broadcast, ok, msg)

   while true do
      ok, msg = mq:publish(channels.discovery, "1")
      util.log("sent discovery request", ok, msg)
      fiber.sleep(M.tick)
   end
end

return M
