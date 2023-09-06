local ngx = ngx
local _M = {}

function _M.rewrite()
  local ngx_re_split = require("ngx.re").split
  local host_port, err = ngx_re_split(ngx.var.best_http_host, ":")
  if host_port then
    ngx.var.best_http_host = host_port[1]
  end
end

return _M