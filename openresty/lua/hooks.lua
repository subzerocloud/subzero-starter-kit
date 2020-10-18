local cache = require 'cache'
local utils = require 'utils'
local cjson = require 'cjson'

-- this module will periodically refresh the jwt token from the cookie to extend the session lifetime
local jwt_auto_refresh = require 'subzero.jwt_auto_refresh'
jwt_auto_refresh.configure({
    rest_prefix = '/rest',
    refresh_uri = '/rpc/refresh_token',
    excluded_uris = {'/rpc/login', '/rpc/logout','/rpc/signup'},
    session_cookie_name = 'SESSIONID',
    session_refresh_threshold = (60*55) -- used condition (expire - now) < session_refresh_threshold,
})

-- ================ GraphQL schema generation hooks =======================
-- Override the auto generated type names for the entities (views/tables)
-- If the function returns nil, subzero will come up with a name for you
local function table_type_name(entity)
    -- local overrides = {
    --     projects = 'MyProject'
    -- }
    -- return overrides[entity]
end

-- Hook to override the auto generated entrypoint names for the entities (views/tables)
-- If the function returns nil, subzero will come up with a name for you
-- If you return _disabled_ this entrypoint will not be available
-- For convenience subzero generates entrypoints that deal with one item or a collection of items
-- single_item parameter tells you which type of entrypoint is being generated
-- location can be one of the following: 
--     select - query entrypoint for retrieving information
--     insert - mutation entrypoint for creating rows
--     update - mutation entrypoint for updating rows
--     delete - mutation entrypoint for deleting rows
--     <parent_name> - query entrypoint that is a field within a parent entrypoint

local function entrypoint_name(entity, single_item, location)
    -- if entity == 'me' then
    --     return '_disabled_' -- special value to disable the generation of this endpoint
    -- end

    -- -- for all the other paths use two simple tables to decide if we want to rename
    -- local singular_overrides = {
    --     projects = 'my_project'
    -- }
    -- local plural_overrides = {
    --     projects = 'my_projects'
    -- }
    -- return single_item and singular_overrides[entity] or plural_overrides[entity]
end

-- Hook function to remove the undesired filter capabilities from nodes
local function argument_filter(parent_entity, entity, column, operator)
    -- if entity == 'todos' and column == 'todo' and operator == 'like' then
    --     return false
    -- end
    return true
end



local function on_init()
    -- print "on_init called"
end

local function on_rest_request()
    jwt_auto_refresh.check()
    cache.compute_cache_key()
    local method = ngx.var.request_method
    if method == 'POST' or method == 'PATCH' or method == 'DELETE' then
        cache.invalidate_cache_tags()
    end
end

local function before_rest_response()
    -- print "before_rest_response called"
    -- postprocess response
    -- utils.set_body_postprocess_mode(utils.postprocess_modes.ALL)
    -- utils.set_body_postprocess_fn(function(body)
    --     local b = cjson.decode(body)
    --     b.custom_key = 'custom_value'
    --     return cjson.encode(b)
    -- end)

    cache.cache_request()
    
end


return {
    on_init = on_init,
    on_rest_request = on_rest_request,
    before_rest_response = before_rest_response,
    argument_filter = argument_filter,
    entrypoint_name = entrypoint_name,
    table_type_name = table_type_name,
}