#!/usr/bin/env tarantool

local mqtt    = require("mqtt")
local fiber   = require("fiber")
local json    = require("json")
local util    = require("lib/util")
local bit     = require("bit")
local clock   = require("clock")
local config  = require("config")

local device_caps = {
   "GPIO",
   "PWN",
   "BUTTON",
   "GPIO_INPUT",
   "ADC",
   "DALI",
   "SHT21",
   "LPS331",
   "OPT3001",
   "LSM6DS3",
   "INCOTEX",
   "UART",
   "A420"
}

local function get_device_abilities(ability)
   local res = {}
   for i, cap in pairs(device_caps) do
      local mask = bit.lshift(1, i-1)
      if bit.band(ability, mask) ~= 0 then
         table.insert(res, cap)
      end
   end
   return res
end

local function message_handler(id, topic, message)
   local parts = util.split(topic, "/")
   if #parts < 3 then
      return
   end

   local addr = parts[3]

   if not string.find(addr, ":") then
      return
   end

   local fixed_data = "[" .. message:sub(2, -2) .. "]"
   local data = json.decode(fixed_data)

   local dict = {}
   for i,d in pairs(data) do
      util.merge(dict, d)
   end

   local ability = tonumber(dict.ability, 16)
   local caps = get_device_abilities(ability)

   local last_seen = math.floor(clock.time()) - tonumber(dict.last_seen, 10)

   util.log("Found device at "..addr.." with caps: "..table.concat(caps, ",").." last seen: "..last_seen)
end

local function discover()
   conn = mqtt.new()

   local ok, msg

   ok, msg = conn:on_message(message_handler)
   ok, msg = conn:connect({
         host = "0.0.0.0",
         port = config.mqtt.port,
   })

   util.log({"<> connected", ok, msg, host})

   ok, msg = conn:subscribe("devices/#")
   util.log({"<> subscribed", ok, msg})

   while true do
      ok, msg = conn:publish("devices/Edison/get", "1")
      util.log({"-> send discovery request", ok, msg})
      fiber.sleep(2)
   end
end

local function main()
   --fiber.create(discover)
   discover()
end

main()
