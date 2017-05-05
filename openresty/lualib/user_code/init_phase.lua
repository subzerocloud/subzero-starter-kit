cjson = require('cjson')
utils = require('utils')

hooks = {}
local _status, _hooks = pcall(require, "hooks")
if _status then
    hooks = _hooks
end

if type(hooks.on_init) == 'function' then
	hooks.on_init()
end

require 'prelude'()
require 'pl.stringx'.import()
-- cache using nginx internal shared dictionary
-- cache = require 'cache.core'
-- local backend = require 'cache.backend.nginx'
-- backend.init(ngx.shared.cache_tags) -- the parameter is a lua_shared_dict
-- cache.init(backend, user_module, (60 * 5))

-- graphql
subzero = require 'subzero'
postgrest = require 'postgrest.handle'
postgrest.init('/internal/rest')

