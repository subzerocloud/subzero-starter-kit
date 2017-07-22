-- this module will transparently turn your jwt based auth mechanism
-- into a session cookie based one
-- aditionally it will periodically refresh the jwt token to extend the session lifetime
-- for why this is a good idea when it comes to browsers, check out this article
-- https://stormpath.com/blog/where-to-store-your-jwts-cookies-vs-html5-web-storage
local session_cookie = require 'subzero.jwt_session_cookie'
session_cookie.configure({
    -- rest_prefix = '/internal/rest/',
    -- login_uri = 'rpc/login',
    -- logout_uri = 'rpc/logout' ,
    -- refresh_uri = 'rpc/refresh_token',
    -- session_cookie_name = 'SESSIONID',
    -- session_refresh_threshold = (60*55) -- (expire - now < session_refresh_threshold),
    -- path = '/',
    -- domain = nil,
    -- secure = false,
    -- httponly = true,
    -- samesite = "Strict",
    -- extension = nil,
})

-- ================ GraphQL schema generation hooks =======================
-- Override the auto generated type names for the entities (views/tables)
-- If the function returns nil, subzero will come up with a name for you
local function table_type_name(entity)
    local overrides = {
        --projects = 'MyProject'
    }
    return overrides[entity]
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
    if entity == 'me' then
        -- we have a special case for this
        if not single_item and location == 'select' then
            return 'me'
        else
            return '_disabled_' -- special value to disable the generation of this endpoint
        end
    end

    -- for all the other paths use two simple tables to decide if we want to rename
    local singular_overrides = {
        --projects = 'my_project'
    }
    local plural_overrides = {
        --projects = 'my_projects'
    }
    return single_item and singular_overrides[entity] or plural_overrides[entity]
end

-- Hook function to remove the undesired filter capabilities from nodes
local function argument_filter(parent_entity, entity, column, operator)
    if entity == 'todos' and column == 'todo' and operator == 'like' then
        return false
    end
    return true
end



local function on_init()
    -- print "on_init called"
end

local function on_rest_request()
    -- print "on_rest_request called"
    session_cookie.run()
end

local function before_rest_response()
    -- print "before_rest_response called"
end


return {
    on_init = on_init,
    on_rest_request = on_rest_request,
    before_rest_response = before_rest_response,
    argument_filter = argument_filter,
    entrypoint_name = entrypoint_name,
    table_type_name = table_type_name,
}