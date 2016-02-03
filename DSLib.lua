local Lib = {}
Lib.FileCache = {};

-- Summary file:
-- dd/mm/yy -> day
-- Others could possibly be stored to... (week/month/year) but is that really necessary? Nah.

--Lib.SummaryFileName = "Summary.txt" -- Unused

local JSON = require "cjson"

function Lib:Unpack(target)
	for i,v in pairs(self) do
		if target[v] then
			error("Cannot unpack: target key is already set. Key is: "..tostring(i));
		end
		target[i] = self[i] -- link together;
	end
end

-- Convert a number (string) to a number we can save to a file.
-- This is a TODO as there's a lot of space used now for data..
function Lib:NumberEncode(Number)
	return Number
end

-- Convert a string back to the original number. 
-- so Lib:NumberEncode(Lib:NumberDecode(Number)) = Number = Lib:NumberDecode(Lib:NumberEncode(Number))

function Lib:NumberDecode(String)
	return String
end

function Lib:WriteNumber(number,file)
	assert(number, "no number given")
	assert(file, "no file given")
	local fname=file;
	local file = self.FileCache[file] or io.open(file, "a+");
	local wr = self:NumberEncode(number);
	file:write(wr.."\n") -- write to file + seperator;
	file:flush() -- save changes.
	self.FileCache[fname] = file;
	-- Have only one file open at a time.
	for i,v in pairs(self.FileCache) do
		if i ~= fname then
			v:close()
			self.FileCache[i] = nil
		end
	end			
end



-- Doesn't check for multiples!!
function Lib:WriteSummary(Identifier, Data, Filename)
	if string.match(Identifier, ": ") then
		error("Invalid identifier string: " .. tostring(Identifier));
	end
	if Lib:GetSummary(Identifier, Filename) then
		print("Data is already present. No update functionality is present. Needs a manual update")
		return false, "Data Identifier non-unique"
	end
	local f = io.open(Filename, "a+") -- open in append mode;
	local str = Identifier.. ": " .. JSON.encode(Data) .. "\n";
	f:write(str);
	f:flush()
	f:close()
	return true
end

function Lib:GetSummary(Identifier, Filename)
	if string.match(Identifier, ": ") then
		error("Invalid identifier string: " .. tostring(Identifier));
	end
	
	for line in io.lines(Filename) do
		if line:match("^"..Identifier) then
			local data = line:match("^"..Identifier..": (.*)");
			return JSON.decode(data)
		end
	end	
end


return Lib


