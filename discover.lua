#!/usr/bin/env tarantool
local mqtt  = require("mqtt")
local fiber = require("fiber")
local json = require("json")
local log = require("log")
local bit = require("bit")


local devices = {
}

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

local function log_msg(msg)
   log.error(json.encode(msg))
end

local function get_device_abilities(ability)
   local res = {}
   for i, cap in pairs(device_caps) do
      if  bit.band(ability, bit.lshift(1, i)) then
         table.insert(res, cap)
      end
   end
   return res
end

function split(str, pat)
   local res = {}
   for x in string.gmatch(str, "[^"..pat.."]+") do
      table.insert(res, x)
   end
   return res
end

function merge(t1, t2)
   for k,v in pairs(t2) do
      t1[k] = v
   end
end


local function message_handler(id, topic, message)
   log.info(topic)
   local parts = split(topic, "/")
   log_msg(parts)
   if #parts < 3 then
      return
   end

   local addr = parts[3]

   if addr == "get" then
      return
   end

   log_msg(addr)
   log_msg(message)

   local fixed_data = "[" .. message:sub(2, -2) .. "]"
   
   log_msg(fixed_data)

   local data = json.decode(fixed_data)
   local dict = {}
   for d in fixed_data do
      --merge(dict, d)
   end

   log.info("DATA")

   log_msg(dict)
   log_msg(dict.ability)

   local ability = tonumber(data.ability, 16)

   log.info(ability)

   local caps = get_device_abilities(ability)

   log.info("CAPS")
   log_msg(caps)

   --log.info("Found device at" .. addr .. " with caps: " .. table.concat(caps, ",")) 
end

-- conn:publish("devices/Edison/212:4B00:A88:5123/sht21/temperature/get",

local function discover()
   conn = mqtt.new()

   local ok, msg

   ok, msg = conn:on_message(message_handler)
   ok, msg = conn:connect({
         host = "0.0.0.0",
         port = 1883,
   })

   log_msg({"<> connected", ok, msg, host})

   ok, msg = conn:subscribe("devices/#")
   log_msg({"<> subscribed", ok, msg})

   while true do
      ok, msg = conn:publish("devices/Edison/get", "1")
      log_msg({"-> send discovery request", ok, msg})
      fiber.sleep(2)
   end
end

local function main()
   fiber.create(discover)
end

main()

