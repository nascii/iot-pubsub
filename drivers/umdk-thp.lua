local M = {}

local mqtt   = require("mqtt")
local config = require("config")
local fiber  = require("fiber")
local util   = require("util")

M.channels = {
   temperature = "sht21/temperature/get",
   humidity    = "sht21/humidity/get",
   pressure    = "lps331/pressure/get",
}

local function channel_name(channel)
   return config.mqtt.channels.edison .. "/" .. channel
end

local function create_poller(mq, subscriptions, interval)
   return function()
      while true do
         util.log("polling", subscriptions, "interval", interval)
         for channel, status in pairs(subscriptions) do
            if status then
               mq:publish(channel, "1")
            end
         end
         fiber.sleep(interval)
      end
   end
end

function M:new(broker, interval)
   self.__index = self
   return setmetatable(
      {
         mq            = mqtt.new(),
         broker        = broker,
         subscriptions = {},
         fiber         = nil,
      },
      self
   )
end

function M:start()
   local ok, msg = self.mq:connect(self.broker)
   if not ok then
      error("failed to connect to mqtt broker")
   end

   self.fiber = fiber.create(
      create_poller(
         self.mq,
         self.subscriptions,
         self.interval
      )
   )
end

function M:stop()
   if self.fiber then
      fiber.kill(self.fiber.id)
   end
end

function M:on(channel, handler)
   self.subscriptions[channel] = true
   return mq:subscribe(
      channel_name(channel),
      handler
   )
end

function M:off(channel)
   self.subscriptions[channel] = false
   return mq:unsubscribe(
      channel_name(channel)
   )
end

return M
