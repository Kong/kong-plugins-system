-----------------------------------------------------------------------------------
-- Kong plugin as system wide plugin, or background worker.
--
-- The plugin must be added to the system to be activated, by setting the
-- `custom_plugins` configuration setting.
--
-- Then it should be added as a plugin to some entity (preferably a non-used one, to
-- not cause any runtime overhead) to be able to supply a configuration.
--
-- **NOTE 1**: it will start when Kong starts, or when initially added. When updating or
-- deleting, it requires a Kong reload/restart to effectuate the changes.
--
-- **NOTE 2**: make sure to only add it once! So only one configuration is available.
-- Behaviour is undefined if you add more than one.
--
-- **NOTE 3**: This whole thing is a big hack, until the Plugin API makes it possible
-- to do this in a more structured way.
--
-- @module kong.plugins.system
-- @copyright 2017 Kong Inc.
-- @license Apache 2.0
--

local BasePlugin = require "kong.plugins.base_plugin"
local singletons = require "kong.singletons"
local ngx_log = ngx.log
local ERR = ngx.ERR
local DEBUG = ngx.DEBUG

local _M = {}


-- There should be 1 or 0 configurations, find and return it.
local function get_entity(plugin_name, log_prefix)
  local dao = singletons.dao
  if not dao then return end

  local rows, err = dao.plugins:find_all {
    name = plugin_name
  }
  if not rows then
    if err then
      ngx_log(ERR, log_prefix, "could not fetch config data from database: ", err)
    end
    return
  end

  if #rows > 1 then
    -- cannot error out, because Kong must run to be able to remove the additional
    -- entries again.
    ngx_log(ERR, log_prefix, "found (", #rows, ") rows, only 1 expected.")
  end

  return rows[1]
end

-- Initialize the plugin, only if a configuration is available
local function initialize(plugin_name, init_callback, log_prefix)
  local entity = get_entity(plugin_name, log_prefix)
  if entity == nil then
    return  -- exit, plugin not configured yet
  end

  ngx_log(DEBUG, log_prefix, "starting background plugin")
  init_callback(entity.config)
  ngx_log(DEBUG, log_prefix, "background plugin started")
end

--- Creates a new plugin to run as a system wide/background process.
-- The callback has signature `function(conf)` and will at startup run in the
-- `init_worker` context.
-- @param plugin_name (string) name of the plugin to create
-- @param init_callback (function) callback as initializer
-- @param log_prefix (optional) defaults to "[`<plugin_name>`] "
-- @return the plugin object
-- @usage
-- -- Example `handler.lua` file for a background plugin
-- local systemwide_plugin = require "kong.plugins.system"
--
-- -- Grab pluginname from module name
-- local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")
--
-- local function initialize(conf)
--   -- do whatever you want, must be able to run in the `init_worker` context
-- end
--
-- -- this is identical to: `systemwide_plugin.create_plugin(plugin_name, initialize)`
-- return systemwide_plugin(plugin_name, initialize)
function _M.create_plugin(plugin_name, init_callback, log_prefix)
  log_prefix = log_prefix or ("[" .. plugin_name .. "] ")
  local plugin = BasePlugin:extend()
  plugin.PRIORITY = 100

  ngx_log(DEBUG, log_prefix, "created as background/system plugin")
  function plugin:new()
    plugin.super.new(self, plugin_name)
  end

  function plugin:init_worker()
    plugin.super.init_worker(self)

    -- create an event handler, to start when config is created/added
    singletons.worker_events.register(function(data)
      if data.entity.name ~= plugin_name then
        return
      end
      initialize(plugin_name, init_callback, log_prefix)
    end, "crud", "plugins:create")

    -- run at startup
    initialize(plugin_name, init_callback, log_prefix)
  end

  return plugin
end

return setmetatable(_M, {
  __call = function(self, ...)
    return self.create_plugin(...)
  end
})