-- cache using nginx internal shared dictionary
local cache = require 'cache.core'
-- use in conjunction with ngx_http_proxy_module caching method
local tag_store_backend = require 'cache.backend.nginx'
tag_store_backend.init(ngx.shared.cache_tags) -- the parameter is a lua_shared_dict defined in nginx.conf

-- use in conjunction with ngx_srcache caching method
-- local tag_store_backend = require 'cache.backend.redis'
-- tag_store_backend.init('/redis?method=batch') -- the parameter is an internally accesible location defined in redis.conf


local function get_endpoint()
    return ngx.var.uri:gsub(ngx.var.rest_prefix .. '/', '')
end

--[[
Return all the "tags" for the current GET request
We can use these tags on DELETE/POST/PATCH to selectively invalidate a group of cached requests at the same time
--]]
local function get_request_tags()
    local endpoint_synonyms = { 
        item='items'
    }
    local tags = {'all'} -- we add tag so that if we need to we can invalidate all cached requests
    local endpoint = get_endpoint()
    table.insert(tags, endpoint) -- we tag the request with the current endpoint name (table name)
    local select = ngx.var.arg_select or '*'
    -- we also look for other tables specified in the select parameter from where the data is pulled
    -- the regexp will match only the simple cases (this is jsut an example)
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
cache.init(tag_store_backend, {
    get_cache_key = get_cache_key,
    get_cache_tags = get_invalid_cache_tags
}, tags_ttl)


return cache