function split1(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

--function string:split(separator)
--    local init = 1
--    return function()
--        if init == nil then return nil end
--        local i, j = self:find(separator, init)
--        local result
--        if i ~= nil then
--            result = self:sub(init, i – 1)
--            init = j + 1
--        else
--            result = self:sub(init)
--            init = nil
--        end
--        return result
--    end
--end

local text = "mVideos#videos"
local resultado = split1(text,"#")

print (resultado[2])