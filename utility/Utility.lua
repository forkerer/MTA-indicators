-- ----------------------------------------------------------------------------
-- Kamil Marciniak <github.com/forkerer> wrote this code. As long as you retain this 
-- notice, you can do whatever you want with this stuff. If we
-- meet someday, and you think this stuff is worth it, you can
-- buy me a beer in return.
-- ----------------------------------------------------------------------------

local abs = math.abs
local floor = math.floor
local format = string.format
local sub = string.sub
local sqrt = math.sqrt


function getDistanceBetweenPoints3D(x,y,z,x1,y1,z1)
	local distX = x1-x
	local distY = y1-y
	local distZ = z1-z
	return sqrt(distX*distX+distY*distY+distZ*distZ)
end

function getDistanceBetweenPoints2D(x,y,x1,y1)
	local distX = x1-x
	local distY = y1-y
	return sqrt(distX*distX+distY*distY)
end

function table.containsValue(tab, value)
    for i=1, #tab do
    	if tab[i] == value then
    		return true
    	end
    end
    return false
end

function table.findValue(tab, value)
	for i=1, #tab do
    	if tab[i] == value then
    		return i
    	end
    end
    return false
end

function table.removeValue(tab, value)
	for i=1, #tab do
    	if tab[i] == value then
    		table.remove(tab,i)
    		return true
    	end
    end
    return false
end

function bind(func, ...)
	assert(type(func) == "function", "First argument to bind has to be function")
	local args = {...}
	return function(...) 
		local retTable = {}
		for _,val in ipairs(args) do
			retTable[#retTable+1] = val
		end
		for _,val in ipairs({...}) do
			retTable[#retTable+1] = val
		end
		func(unpack(retTable))
	end
end

function roundOld(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function round(number,decimals)
    local rounded = floor( number * 10^decimals + 0.5 ) / 10^decimals
    local added = tostring(rounded + 10^-(decimals + 1))
    return added:sub(0,added:len() - 1)
end

function formatDistance(dist)
	if not dist then return "( ----- )" end
	dist = dist+0.0001
	if dist >= 10000 then
		local kms = round(dist/1000,1)
		return "( "..kms.." km )"
	elseif dist >= 1000 then
		local kms = round(dist/1000,2)
		return "( "..kms.." km )"
	elseif dist >= 100 then
		local meters = round(dist,1)
		return "( "..meters.." m )"
	elseif dist >= 10 then
		local meters = round(dist,2)
		return "( "..meters.." m )"
	elseif dist >= 0 then
		local meters = round(dist,3)
		return "( "..meters.." m )"
	else
		return "( ----- )"
	end
end

local distWidthCache = {}
function GetDistanceWidth(scale, font)
	if not distWidthCache[font] then
		distWidthCache[font] = {[scale] = dxGetTextWidth( "( 12.3 km )", scale, font )}
	elseif not distWidthCache[font][scale] then
		distWidthCache[font][scale] = dxGetTextWidth( "( 12.3 km )", scale, font )-- = dxGetTextWidth( "( 1.288 km )", scale, font )
	end
	return distWidthCache[font][scale]
end

function removeColorCoding( name )
	return type(name)=='string' and string.gsub ( name, '#%x%x%x%x%x%x', '' ) or name
end

-- "( 12.3 km )"
-- "( 1.23 km )"
-- "( 900.2 m )"
-- "( 90.21 m )"
-- "( 8.243 m )"
-- "( ------- )"