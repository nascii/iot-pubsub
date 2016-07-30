#!/usr/bin/env tarantool
local mqtt  = require("mqtt")
local fiber = require("fiber")

local devices = {
   one = { host = "100.100.150.184", port = 1883 },
   two = { host = "100.100.150.96",  port = 1883 },
}

local function log(msg)
   local encoder = require("json")
   require("log").error(encoder.encode(msg))
end

local function message_handler(id, topic, message)
   log({
         "<- received message",
         id,
         topic,
         message,
   })
end

local function loop()
   local ok, msg
   while true do
      ok, msg = conn:publish(
         "devices/Edison/212:4B00:A88:5123/sht21/temperature/get",
         "1"
      )
      log({"-> publishing message", ok, msg})
      fiber.sleep(2)
   end
end

local function pubsub(device)
   conn = mqtt.new()

   local ok, msg

   ok, msg = conn:on_message(message_handler)
   ok, msg = conn:connect({
         host = device.host,
         port = device.port,
   })

   log({"<> connected", ok, msg, host})

   ok, msg = conn:subscribe("devices/#")
   log({"<> subscribed", ok, msg})

   fiber.create(loop)
end

local function main()
   for _, v in pairs(devices) do
      pubsub(v)
   end
end

main()
