local config = {
   tarantool = {
      slab_alloc_arena = 0.3
   },
   http = {
      addr    = "0.0.0.0",
      port    = 80,
      options = { app_dir = "./app" }
   },
   mqtt = {
      port = 1883,
      channels = {
         broadcast = "devices/#",
         edison    = "devices/Edison",
         discovery = "devices/Edison/get",
      }
   }
}

return config
