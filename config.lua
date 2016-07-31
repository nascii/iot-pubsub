local config = {
   http = {
      addr    = "0.0.0.0",
      port    = 80,
      options = { app_dir = "./app" }
   },
   mqtt = {
      port = 1883,
   },
   devices = {
      -- Edison devices
      { host = "100.100.150.184", port = 1883 },
      { host = "100.100.150.96",  port = 1883 },
   }
}

return config
