require 'prelude'()
require 'pl.stringx'.import()

local cjson = require('cjson')
local utils = require('utils')
local hooks = require("hooks")
local subzero = require('subzero')
local postgrest = require('postgrest.handle')

if type(hooks.on_init) == 'function' then
	hooks.on_init()
end
