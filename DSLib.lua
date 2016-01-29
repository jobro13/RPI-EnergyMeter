local Lib = {}
Lib.FileCache = {};

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
	self.FileCache[file] = fname;
	-- Have only one file open at a time.
	for i,v in pairs(self.FileCache) do
		if i ~= fname then
			v:close()
			self.FileCache[i] = nil
		end
	end			
end



return Lib


