package = "kong-plugins-system"
version = "0.1.0-1"
source = {
   url = "https://github.com/kong/kong-plugins-system/archive/0.1.0.tar.gz",
   dir = "kong-plugins-system-0.1.0"
}
description = {
   summary = "Helper module to create systemwide/background Kong plugins",
   detailed = [[
      Kong plugins run based on requests, occasionally background processes
      are required to do validations/updatesetc. This module provides a simple
      way to create this.
      DISCLAIMER: temporary solution until the Kong Plugin API natively supports
      creating such plugins! This will break in the future!
   ]],
   license = "Apache 2.0",
   homepage = "https://github.com/kong/kong-plugins-system"
}
dependencies = {
}
build = {
   type = "builtin",
   modules = { 
     ["kong.plugins.system"] = "kong/plugins/system.lua",
   }
}
