local Lib = {}

Lib.KWHPerPulse = 1/500;
Lib.Price = {
	Low = 0.2042;
	High = 0.2289;
}

-- This function accepts a timestamp and should return the Price tag
-- So that Lib.Price[Tag] returns the Price per KWH
-- The timestamp is given as a os.date table.
function Lib:GetPrice(Timestamp)
	if Timestamp.wday == 7 or Timestamp.wday == 1 then -- Weekend;
		return "Low"
	elseif Timestamp.hour >= 23 or Timestamp.hour < 7 then
		return "Low"
	end
	return "High"
end

-- Above are settings; Below is code, don't change.

local RootLib = require "PowerLib";
local DataDir = RootLib.Path .. RootLib.DataDir .. "/"

local DSLib = require "DSLib"; -- required for decoding;

-- Returns Power given in Watts, given a time difference (DeltaTime) between two pulses
function Lib:GetPower(DeltaTime)
	local WhPerPulse = self.KWHPerPulse*1000*3600;
	local W = WhPerPulse / DeltaTime;
	return W
end

-- If no EndTime is given, assume "now"
-- Delta is how many minutes we should look in the past.
-- For smoothing purposes: EndTime is non-inclusive: Delta is inclusive
-- Thus all times given satisfy:
-- EndTime - Delta <= Timestamp < EndTime
function Lib:CollectData(Delta, EndTime)
	local EndTime = (EndTime or os.time());
	local StartTime = EndTime - Delta;
	-- Find all files we should be looking in.
	local DailyDelta = 60*60*24; -- how many seconds in a day?

	local FileList = {};
	local TimestampE = os.date(EndTime-1); --guarantees exclusion;
	
	local Timestamps = {TimestampE};
	
	local function DateToName(struct)
		return struct.day.."_"..struct.month.."_"..struct.year..".txt"
	end
	
	local CurTime = EndTime;
	while CurTime - DailyDelta > StartTime do
		CurTime = CurTime - DailyDelta - 1;
		table.insert(Timestamps, 1, os.date(CurTime));
	end  
	
	for i,v in pairs(Timestamps) do
		table.insert(FileList, DateToName(v));
	end

	local Data_Out = {};
	
	for _, FileName in pairs(FileList) do
		local file = io.open(FileName, r)
		if file then
			while true do
				local line = file:read("*n");
				if line then
					local Num = DSLib:NumberDecode(line)
					if Num and Num >= StartTime and Num < EndTime then
						table.insert(Data_Out, tonumber(Num))	
					end 
				else
					break
				end
			end	
		end
	end
	return Data_Out
end

return Lib 
