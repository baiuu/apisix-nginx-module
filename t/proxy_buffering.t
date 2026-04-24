use t::APISIX_NGINX 'no_plan';

run_tests;

__DATA__

=== TEST 1: proxy_buffering off
--- config
    proxy_buffering off;
    proxy_buffer_size 1k;
    proxy_buffers 2 1k;
    location /t {
        proxy_pass http://127.0.0.1:1984/up;
    }
    location /up {
        content_by_lua_block {
            ngx.print(string.rep("x", 10240))
        }
    }
--- request
GET /t
--- grep_error_log eval
qr/an upstream response is buffered to a temporary file/
--- grep_error_log_out



=== TEST 2: proxy_buffering off by Lua API
--- config
    proxy_buffering on;
    proxy_buffer_size 1k;
    proxy_buffers 2 1k;
    location /t {
        access_by_lua_block {
            local client = require("resty.apisix.client")
            assert(client.set_proxy_buffering(false))
        }
        proxy_pass http://127.0.0.1:1984/up;
    }
    location /up {
        content_by_lua_block {
            ngx.print(string.rep("x", 10240))
        }
    }
--- request
GET /t
--- grep_error_log eval
qr/an upstream response is buffered to a temporary file/
--- grep_error_log_out



=== TEST 3: proxy_buffering on
--- config
    proxy_buffering on;
    proxy_buffer_size 1k;
    proxy_buffers 2 1k;
    location /t {
        proxy_pass http://127.0.0.1:1984/up;
    }
    location /up {
        content_by_lua_block {
            ngx.print(string.rep("x", 10240))
        }
    }
--- request
GET /t
--- grep_error_log eval
qr/an upstream response is buffered to a temporary file/
--- grep_error_log_out
an upstream response is buffered to a temporary file



=== TEST 4: proxy_buffering on by Lua API
--- config
    proxy_buffering off;
    proxy_buffer_size 1k;
    proxy_buffers 2 1k;
    location /t {
        access_by_lua_block {
            local client = require("resty.apisix.client")
            assert(client.set_proxy_buffering(true))
        }
        proxy_pass http://127.0.0.1:1984/up;
    }
    location /up {
        content_by_lua_block {
            ngx.print(string.rep("x", 10240))
        }
    }
--- request
GET /t
--- grep_error_log eval
qr/an upstream response is buffered to a temporary file/
--- grep_error_log_out
an upstream response is buffered to a temporary file
