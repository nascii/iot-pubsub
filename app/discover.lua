#!/usr/bin/env tarantool
local mqtt    = require("mqtt")
local fiber   = require("fiber")
local json    = require("json")
local util    = require("lib/util")
local bit     = require("bit")
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
      if  bit.band(ability, bit.lshift(1, i)) then
         table.insert(res, cap)
      end
   end
   return res
end

local function message_handler(id, topic, message)
   util.log(topic)
   local parts = util.split(topic, "/")
   util.log(parts)
   if #parts < 3 then
      return
   end

   local addr = parts[3]

   if addr == "get" then
      return
   end

   util.log(addr)
   util.log(message)

   local fixed_data = "[" .. message:sub(2, -2) .. "]"

   util.log(fixed_data)

   local data = json.decode(fixed_data)
   local dict = {}
   for d in fixed_data do
      --util.merge(dict, d)
   end

   util.log("DATA")

   util.log(dict)
   util.log(dict.ability)

   local ability = tonumber(data.ability, 16)

   util.log(ability)

   local caps = get_device_abilities(ability)

   util.log("CAPS")
   util.log(caps)
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
   fiber.create(discover)
end

main()
