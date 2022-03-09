local uci = require "uci"

local M = {}

function M.get(params)
	local c = uci.cursor()

	return {
		c:get("openvpn", params.section, params.option)
	}
end

function M.getNetwork(params)
	local c = uci.cursor()

	return {
		c:get("network", params.section, params.option)
	}
end

function M.set(params)
	local c = uci.cursor()

	c:set("openvpn", params.section, params.option, params.value)
	c:commit("openvpn")

	return { c:get("openvpn", params.section, params.option) }
end

function M.setOne(params)
	local c = uci.cursor()

	c:set("openvpn", params.name, params.type)
	c:set("openvpn", params.name, "enable", 0)
	c:set("openvpn", params.name, "type", params.role)
	c:commit("openvpn")

end

function M.remove(params)
	local c = uci.cursor()

	local res = c:delete("openvpn", params.name)
	c:commit("openvpn")

	return res
end

function M.getOpenvpn(params)
	local c = uci.cursor()
	
	local a = {}
	local num = 0
	c:foreach("openvpn","openvpn", function(i)
		a[num] = i
		num = num + 1
	end)

	return a
end

function M.restartOpenVpn(params)
  os.execute('/etc/init.d/openvpn restart')
end

function M.readFile(params)
  local arr = {}

	local f = io.open(params.path, "r")
	if f~=nil then
		io.close(f)
		local handle  = assert( io.open(params.path,"r") )
		local value = handle:read("*line")
		while value do
			table.insert( arr, value )
			value = handle:read("*line")
		end
		handle:close()
		return arr
	else
		return arr
	end
end

function M.createFile(params)
  os.execute('touch "' ..params.path..'"')
	os.execute('echo "OpenVPN STATISTICS" > "' ..params.path..'"')
	os.execute('echo "Updated,2022-03-04 08:08:08" >> "' ..params.path..'"')
	os.execute('echo "TUN/TAP read bytes,0" >> "' ..params.path..'"')
	os.execute('echo "TUN/TAP write bytes,0" >> "' ..params.path..'"')
	os.execute('echo "TCP/UDP read bytes,0" >> "' ..params.path..'"')
	os.execute('echo "TCP/UDP write bytes,0" >> "' ..params.path..'"')
	os.execute('echo "Auth read bytes,0" >> "' ..params.path..'"')
	os.execute('echo "END" >> "' ..params.path..'"')
end

function M.deleteFile(params)
  os.execute('rm -fr "' ..params.path..'"')
end

function M.delete_keys(params)
	M.deleteFile(params)

	local c = uci.cursor()

	local res = c:delete("openvpn", params.name, params.key_type)
	c:commit("openvpn")

	return res
end

function M.deleteServerTls(name)
	local c = uci.cursor()

	c:delete("openvpn", name, "_tls_cipher")
	c:delete("openvpn", name, "server_ip")
	c:delete("openvpn", name, "server_netmask")
	c:delete("openvpn", name, "auth")
	c:delete("openvpn", name, "_tls_auth")
	c:delete("openvpn", name, "ca")
	c:delete("openvpn", name, "cert")
	c:delete("openvpn", name, "key")
	c:delete("openvpn", name, "dh")
	c:delete("openvpn", name, "tls_server")
	c:delete("openvpn", name, "client_config_dir")
	c:delete("openvpn", name, "push")
	c:delete("openvpn", name, "upload_files")
	c:delete("openvpn", name, "comp_lzo")

	c:commit("openvpn")
end	

function M.deleteServerStatic(name)
	local c = uci.cursor()
	
	c:delete("openvpn", name, "local_ip")
	c:delete("openvpn", name, "remote_ip")
	c:delete("openvpn", name, "network_ip")
	c:delete("openvpn", name, "network_mask")
	c:delete("openvpn", name, "secret")
	
	c:commit("openvpn")
end	

function M.setServerStaticKey(params)
	local c = uci.cursor()

	M.deleteServerTls(params.name)

	c:set("openvpn", params.name, "keepalive", params.keepalive)
	c:set("openvpn", params.name, "_name", params._name)
	c:set("openvpn", params.name, "data_ciphers", { params.data_ciphers })
	c:set("openvpn", params.name, "persist_key", params.persist_key)
	c:set("openvpn", params.name, "port", params.port)
	c:set("openvpn", params.name, "persist_tun", params.persist_tun)
	c:set("openvpn", params.name, "dev", params.dev)
	c:set("openvpn", params.name, "verb", params.verb)
	c:set("openvpn", params.name, "type", params.typetype)
	c:set("openvpn", params.name, "proto", params.proto)
	c:set("openvpn", params.name, "_auth", params._auth)
	c:set("openvpn", params.name, "cipher", params.cipher)
	c:set("openvpn", params.name, "local_ip", params.local_ip)
	c:set("openvpn", params.name, "remote_ip", params.remote_ip)
	c:set("openvpn", params.name, "network_ip", params.network_ip)
	c:set("openvpn", params.name, "network_mask", params.network_mask)
	c:set("openvpn", params.name, "secret", params.secret)
	c:set("openvpn", params.name, "enable", params.enable)

	c:commit("openvpn")
end

function M.setServerTls(params)
	local c = uci.cursor()

	M.deleteServerStatic(params.name)

	c:set("openvpn", params.name, "keepalive", params.keepalive)
	c:set("openvpn", params.name, "_name", params._name)
	c:set("openvpn", params.name, "_tls_cipher", params._tls_cipher)
	c:set("openvpn", params.name, "data_ciphers", { params.data_ciphers })
	c:set("openvpn", params.name, "persist_key", params.persist_key)
	c:set("openvpn", params.name, "port", params.port)
	c:set("openvpn", params.name, "persist_tun", params.persist_tun)
	c:set("openvpn", params.name, "dev", params.dev)
	c:set("openvpn", params.name, "verb", params.verb)
	c:set("openvpn", params.name, "type", params.typetype)
	c:set("openvpn", params.name, "proto", params.proto)
	c:set("openvpn", params.name, "enable", params.enable)
	c:set("openvpn", params.name, "_auth", params._auth)
	c:set("openvpn", params.name, "server_ip", params.server_ip)
	c:set("openvpn", params.name, "server_netmask", params.server_netmask)
	c:set("openvpn", params.name, "auth", params.auth)
	c:set("openvpn", params.name, "_tls_auth", params._tls_auth)
	c:set("openvpn", params.name, "ca", params.ca)
	c:set("openvpn", params.name, "cert", params.cert)
	c:set("openvpn", params.name, "key", params.key)
	c:set("openvpn", params.name, "dh", params.dh)
	c:set("openvpn", params.name, "cipher", params.cipher)
	c:set("openvpn", params.name, "tls_server", params.tls_server)
	c:set("openvpn", params.name, "client_config_dir", params.client_config_dir)
	c:set("openvpn", params.name, "push", { params.push })
	c:set("openvpn", params.name, "upload_files", params.upload_files)
	c:set("openvpn", params.name, "comp_lzo", "no")

	c:commit("openvpn")
end

function M.deleteClientStatic(name)
	local c = uci.cursor()
	
	c:delete("openvpn", name, "local_ip")
	c:delete("openvpn", name, "remote_ip")
	c:delete("openvpn", name, "network_ip")
	c:delete("openvpn", name, "network_mask")
	c:delete("openvpn", name, "secret")
	c:delete("openvpn", name, "_tls_auth")

	c:commit("openvpn")
end	

function M.deleteClientTls(name)
	local c = uci.cursor()

	c:delete("openvpn", name, "_tls_cipher")
	c:delete("openvpn", name, "auth")
	c:delete("openvpn", name, "_tls_auth")
	c:delete("openvpn", name, "ca")
	c:delete("openvpn", name, "cert")
	c:delete("openvpn", name, "key")
	c:delete("openvpn", name, "tls_client")
	c:delete("openvpn", name, "client")
	c:delete("openvpn", name, "network_ip")
	c:delete("openvpn", name, "network_mask")
	c:delete("openvpn", name, "comp_lzo")

	c:commit("openvpn")
end	

function M.setClientStaticKey(params)
	local c = uci.cursor()

	M.deleteClientTls(params.name)

	c:set("openvpn", params.name, "keepalive", params.keepalive)
	c:set("openvpn", params.name, "_name", params._name)
	c:set("openvpn", params.name, "data_ciphers", { params.data_ciphers })
	c:set("openvpn", params.name, "nobind", params.nobind)
	c:set("openvpn", params.name, "persist_key", params.persist_key)
	c:set("openvpn", params.name, "port", params.port)
	c:set("openvpn", params.name, "dev", params.dev)
	c:set("openvpn", params.name, "persist_tun", params.persist_tun)
	c:set("openvpn", params.name, "status", params.status)
	c:set("openvpn", params.name, "verb", params.verb)
	c:set("openvpn", params.name, "type", params.typetype)
	c:set("openvpn", params.name, "proto", params.proto)
	c:set("openvpn", params.name, "_auth", params._auth)
	c:set("openvpn", params.name, "cipher", params.cipher)
	c:set("openvpn", params.name, "remote", params.remote)
	c:set("openvpn", params.name, "resolv_retry", params.resolv_retry)
	c:set("openvpn", params.name, "local_ip", params.local_ip)
	c:set("openvpn", params.name, "remote_ip", params.remote_ip)
	c:set("openvpn", params.name, "network_ip", params.network_ip)
	c:set("openvpn", params.name, "network_mask", params.network_mask)
	c:set("openvpn", params.name, "secret", params.secret)
	c:set("openvpn", params.name, "upload_files", params.upload_files)
	c:set("openvpn", params.name, "_tls_auth", params._tls_auth)
	c:set("openvpn", params.name, "enable", params.enable)

	c:commit("openvpn")
end

function M.setClientTls(params)
	local c = uci.cursor()

	M.deleteClientStatic(params.name)

	c:set("openvpn", params.name, "keepalive", params.keepalive)
	c:set("openvpn", params.name, "_name", params._name)
	c:set("openvpn", params.name, "_tls_cipher", params._tls_cipher)
	c:set("openvpn", params.name, "data_ciphers", { params.data_ciphers })
	c:set("openvpn", params.name, "nobind", params.nobind)
	c:set("openvpn", params.name, "persist_key", params.persist_key)
	c:set("openvpn", params.name, "port", params.port)
	c:set("openvpn", params.name, "dev", params.dev)
	c:set("openvpn", params.name, "persist_tun", params.persist_tun)
	c:set("openvpn", params.name, "status", params.status)
	c:set("openvpn", params.name, "verb", params.verb)
	c:set("openvpn", params.name, "type", params.typetype)
	c:set("openvpn", params.name, "proto", params.proto)
	c:set("openvpn", params.name, "_auth", params._auth)
	c:set("openvpn", params.name, "remote", params.remote)
	c:set("openvpn", params.name, "resolv_retry", params.resolv_retry)
	c:set("openvpn", params.name, "auth", params.auth)
	c:set("openvpn", params.name, "_tls_auth", params._tls_auth)
	c:set("openvpn", params.name, "ca", params.ca)
	c:set("openvpn", params.name, "cert", params.cert)
	c:set("openvpn", params.name, "key", params.key)
	c:set("openvpn", params.name, "cipher", params.cipher)
	c:set("openvpn", params.name, "upload_files", params.upload_files)
	c:set("openvpn", params.name, "tls_client", params.tls_client)
	c:set("openvpn", params.name, "client", params.client)
	c:set("openvpn", params.name, "enable", params.enable)
	c:set("openvpn", params.name, "network_ip", params.network_ip)
	c:set("openvpn", params.name, "network_mask", params.network_mask)
	c:set("openvpn", params.name, "comp_lzo", "no")

	c:commit("openvpn")
end

return M
