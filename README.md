# kong-plugins-system

Helper module to create systemwide/background Kong plugins.

*DISCLAIMER*: temporary solution until the Kong Plugin API natively supports
creating such plugins! _This will break in the future!_

## Status

This library is still under early development.

## Synopsis

```lua
-- Example `handler.lua` file for a background plugin
local systemwide_plugin = require "kong.plugins.system"

-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

local function initialize(conf)
  -- Do whatever you want, must be able to run in the `init_worker` context
end

return systemwide_plugin(plugin_name, initialize)
```

## Description

Kong plugins run based on requests, occasionally background processes
are required to do validations/updates/etc. This module provides a simple
way to create this.

For usage specific notes please refer to the module documentation.

*DISCLAIMER*: temporary solution until the Kong Plugin API natively supports
creating such plugins! _This will break in the future!_

## History

### 0.1 (xx-Nov-2018) Initial release

  * Initial upload

## Copyright and License

```
Copyright 2017 Kong Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
