local component = require("component")
local fs = require("filesystem")
local string = require("string")
local event = require("event")
local modem = component.modem
local gpu = component.gpu

local dir = "/dns"
modem.open(19178)
require("term")

local time = os.date()
gpu.setForeground(0x00FF00)
print(time ..  " Запущен DNS-сервер")
print("Адрес сервера: "..modem.address)

while true do
	local data = {event.pull("modem_message")}
	local subdomain = string.sub(data[7], 0, string.find(data[7], ".", 0, true)-1) -- vs
	local domain = string.sub(data[7], string.find(data[7], ".", 0, true)+1, string.len(data[7])) -- .io
	local path = dir.."/"..domain.."/"..subdomain..".dns"
	if data[6] == "dns_request" then
		gpu.setForeground(0xFFFF00)
		print(time .. " Поступил DNS-запрос: "..data[3].." -> "..data[7])
		if fs.exists(path) then
			local address = io.lines(path)()
			gpu.setForeground(0x00FF00)
			print(time .. " DNS-запрос успешно обработан, адрес: "..address)
			modem.send(data[3], 19178, "dns_answer", address)
		else
			gpu.setForeground(0xFF0000)
			print(time .. " DNS-адрес "..subdomain.."."..domain.." не существует.")
			modem.send(data[3], 19178, "dns_not")
		end
	elseif data[6] == "dns_reg" then
		gpu.setForeground(0xFFFF00)
		print(time .. " Поступил запрос на регистрацию: "..data[3].." -> "..data[7])
		if fs.exists(dir.."/"..domain) then
			gpu.setForeground(0x00FF00)
			print("Регистрация зоны ."..domain.." возможна")
			if not fs.exists(dir.."/"..domain.."/"..subdomain..".dns") then
				gpu.setForeground(0x00FF00)
				print("Домен "..subdomain.." свободный!")
				local reg_file = io.open(dir.."/"..domain.."/"..subdomain..".dns", "w")
				reg_file:write(data[3])
				reg_file:flush()
				reg_file:close()
				print(time .. " Домен "..subdomain.."."..domain.." зарегистрирован!")
				modem.send(data[3], 19178, "dns_success")
			else
				gpu.setForeground(0xFF0000)
				print(time .. " Домен "..subdomain.." уже зарегистрирован.")
				modem.send(data[3], 19178, "dns_err")
			end
		else
		--elseif data[8] == "dns_del" then
			--gpu.setForeground(0xFFFF00)
			--print(time .. " Поступил запрос на удаление домена, от "..data[3].." на "..data[7])
			--fs.remove(dir .. domain)
			--print(time .. "Домен" ..data[7] "Был удален")
			--modem.send(data[3], 19178, "dns_success")
			--end
		end
	end
end
