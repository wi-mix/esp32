-- Wifi.lua
--
-- w = Wifi.init()
-- w.onStart(function() ... end)
-- w.onStop(function() ... end)
-- w.onConnect(function(ssid, bssid, channel, auth) ... end)
-- w.onDisconnect(function(ssid, bssid, reason) ... end)
-- w.onAuthModeChanged(function(old_mode, new_mode) ... end)
-- w.onGetIp(function(ip, netmask, gw) ... end)
-- w:connect("ssid", "password")

Wifi = {}
function Wifi.init()
	local _wifi = {}
	setmetatable(_wifi, {__index = Wifi})

	wifi.sta.on("start", function(event, info)
		if self.onStartFunc then
			self.onStartFunc()
		end
	end)
	wifi.sta.on("stop", function(event, info)
		if self.onStopFunc then
			self.onStopFunc()
		end
	end)
	wifi.sta.on("connected", function(event, info)
		if self.onConnectFunc then
			self.onConnectFunc(
				info.ssid,
				info.bssid,
				info.channel,
				info.auth)
		end
	end)
	wifi.sta.on("disconnected", function(event, info)
		if self.onDisconnectFunc then
			self.onDisconnectFunc(
				info.ssid,
				info.bssid,
				info.reason)
		end
	end)
	wifi.sta.on("authmode_changed", function(event, info)
		if self.onAuthModeChangedFunc then
			self.onAuthModeChangedFunc(
				info.old_mode,
				info.new_mode)
		end
	end)
	wifi.sta.on("got_ip", function(event, info)
		if self.onGetIpFunc then
			self.onGetIpFunc(
				info.ip,
				info.netmask,
				info.gw)
		end
	end)

	return _wifi
end

function Wifi:connect(ssid, password)
	wifiConfig = {}
	wifiConfig.ssid = ssid
	wifiConfig.pwd = password

	wifi.mode(wifi.STATION)
	wifi.start()
	wifi.sta.config(wifiConfig)
end

function Wifi:onStart(func)
	self.onStartFunc = func
end

function Wifi:onStop(func)
	self.onStopFunc = func
end

function Wifi:onConnect(func)
	self.onConnectFunc = func
end

function Wifi:onDisconnect(func)
	self.onDisconnectFunc = func
end

function Wifi:onAuthModeChanged(func)
	self.onAuthModeChangedFunc = func
end

function Wifi:onGetIp(func)
	self.onGetIpFunc = func
end
