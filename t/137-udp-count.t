# vim:set ft= ts=4 sw=4 et fdm=marker:
use Test::Nginx::Socket::Lua::Dgram;

#worker_connections(1014);
#master_on();
#workers(4);
#log_level('warn');
no_root_location();

#repeat_each(2);

plan tests => repeat_each() * (blocks() * 3);

our $HtmlDir = html_dir;

#$ENV{LUA_CPATH} = "/usr/local/openresty/lualib/?.so;" . $ENV{LUA_CPATH};

no_long_string();
run_tests();

__DATA__


=== TEST 1: entries under ngx._udp_meta
--- SKIP
--- dgram_server_config
    content_by_lua_block {
        local n = 0
        for k, v in pairs(ngx._udp_meta) do
            n = n + 1
        end
        ngx.say("n = ", n)
    }
--- dgram_response
n = 5
--- no_error_log
[error]



=== TEST 2: entries under the metatable of req sockets
--- dgram_server_config
    content_by_lua_block {
        local n = 0
        local sock, err = ngx.req.udp_socket()
        if not sock then
            ngx.say("failed to get the request socket: ", err)
        end

        for k, v in pairs(getmetatable(sock)) do
            print("key: ", k)
            n = n + 1
        end
        assert(ngx.say("n = ", n))
    }
--- dgram_response
n = 3
--- no_error_log
[error]
