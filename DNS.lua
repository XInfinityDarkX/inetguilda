local component = require("component")
local event = require("event")
local string = require("string")
local modem = component.modem
 
local dns_server = "47b05608-29f3-4189-bbac-9731208143df"
modem.open(19178)
local lib = {}
 
function lib.get(dns_address)
    if not string.find(dns_address, ".", 0, true) then
        return false, "please type the zone"
    end
    repeat
        modem.send(dns_server, 19178, "dns_request", dns_address)
        data = {event.pull("modem_message")}
    until data[3] == dns_server
    -----
    if data[6] == "dns_answer" and data[7] then
        return data[7]
    elseif data[6] == "dns_not" then
        return false, "domain not exists"
    end
end
 
function lib.register(dns_address)
    if not string.find(dns_address, ".", 0, true) then
        return false, "please type the zone"
    end
    modem.send(dns_server, 19178, "dns_reg", dns_address)
    local data = {event.pull("modem_message")}
    if data[6] == "dns_success" then
        return true
    elseif data[6] == "dns_err" then
        return false
    end
end
 
return lib
