local component = require("component")
local event = require("event")
local term = require("term")
local dns = require("dns")
local ver = "0.0.6"
-- Config (you can change this)
 
local dns_addr = "47b05608-29f3-4189-bbac-9731208143df"
 
local modem = component.modem
 
print("Версия: "..ver)
 
print("Введите URL адрес, например: info.ru")
local url = io.read()
 
function string.starts(String,Starts)
  return string.sub(String,1,String.len(Starts))==Starts
end
 
function lines(str)
  local t = {}
  local function helper(line) table.insert(t, line) return "" end
  helper((str:gsub("(.-)\n", helper)))
  return t
end
 
function parseColor(tln)
  if tln == "RED" then return 0xFF0000
  elseif tln == "ORA" then return 0xFF6600 -- оранжевый
  elseif tln == "YEL" then return 0xFFFF00 -- жёлтый
  elseif tln == "GRE" then return 0x00FF00 --
  elseif tln == "BLU" then return 0x0000FF -- синий
  elseif tln == "PUR" then return 0xFF00FF -- пурпурный
  elseif tln == "WHI" then return 0xFFFFFF -- белый
  elseif tln == "GRA" then return 0xC3C3C3 -- серый
  elseif tln == "DAI" then return 0x00A3FF -- алмазный
  elseif tln == "BLA" then return 0x000000 end
end
local gpu = component.gpu
function parseOnml(onml)
  local lns = lines(onml)
  for i,line in ipairs(lns) do
    if string.starts(line, "BACK") then
      gpu.setBackground(parseColor(string.sub(line, 6)))
      local w,h= gpu.getResolution()
      gpu.fill(1, 1, w, h, " ")
    else
      gpu.setForeground(parseColor(string.sub(line, 1, 3)))
      term.write(string.sub(line,4).."\n")
    end
  end
  gpu.setForeground(0xFFFFFF)
end
 
--modem.open(50)
--modem.send(dns_addr, 55, url)
--local _, _, _, _, _, resp = event.pull("modem_message")
print("Pinging server at " .. url .. "...")
--modem.close(50)
modem.open(80)
term.clear()
term.setCursor(1,1)
 
local dn = dns.get(url)
--local _, _, _, _, _, adds = event.pull("dns")
 
modem.send(dn, 80, "GET")
local _, _, _, _, _, resp = event.pull("modem_message")
parseOnml(resp)
modem.close(80)
