-- cache using nginx internal shared dictionary
local cache = require 'cache.core'
local backend = require 'cache.backend.nginx'
backend.init(ngx.shared.cache_tags) -- the parameter is a lua_shared_dict defined in nginx.conf

local endpoint_synonyms = { 
    item='items'
}
local function get_endpoint()
    return ngx.var.uri:gsub(ngx.var.rest_prefix, '')
end

--[[
Look at the select parameter and extract all the embeded endpoints (tables) in this request
--]]
local function get_request_tags()
    local tags = {}
    local endpoint = get_endpoint()
    local select = ngx.var.arg_select or '*'
    table.insert(tags, endpoint)
    local matches = select:gsub(' ',''):gmatch('([^,:]+)%(')
    for tag in matches do
        table.insert(tags, (endpoint_synonyms[tag] or tag))
    end
    return unique(tags)
end

--[[
For every GET request this function returns the cache key, tags and the ttl for the current request.
If you do not want the request to be cached, return a nil value for key.
For every PostgREST request (except RPC calls) we can figure out the tables involved at generating the response
by looking at the endpoint name and select parameter. We tag each request with the name of the tables involved
in generating that request for GET so that later, if the data in one of them changes, we can invalidate the caches containing data from it. 
--]]
local function get_cache_key()
    local headers = ngx.req.get_headers()
    local endpoint = get_endpoint()
    local tags = get_request_tags()
    local key_parts = { endpoint, ngx.var.args or '', headers.Authorization }
    local key = table.concat(key_parts,':')
    local ttl = 60 -- seconds
    return key, ttl, tags
end

--[[
For every (PATCH/POST/DELETE) this list represents the cache tags that must be invalidated by the current request.
--]]


local function get_invalid_cache_tags()
    local endpoint = get_endpoint()
    return {endpoint}
end

local tags_ttl = 60 * 5;
cache.init(backend, {
    get_cache_key = get_cache_key,
    get_cache_tags = get_invalid_cache_tags
}, tags_ttl)


return cache