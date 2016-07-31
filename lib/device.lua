-- local device_mock = {
--     addr = "aaaa::212:4b00:a8b:5123",
--     caps = { "SHT21", "LPS331" },
--     last_seen = 1469951172
-- }

local M = {}
local bit = require("bit")

M.caps = {
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

function M.get_capabilities(ability)
   local res = {}
   local mask
   local i, cap

   for i, cap in pairs(M.caps) do
      mask = bit.lshift(1, i-1)
      if bit.band(ability, mask) ~= 0 then
         table.insert(res, cap)
      end
   end

   return res
end

return M
