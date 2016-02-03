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
Lib.DataDir = DataDir;
Lib.RootPath = RootLib.Path;
Lib.PowerLib = RootLib;
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
	local TimestampE = os.date("*t", EndTime-1); --guarantees exclusion;
	
	local Timestamps = {TimestampE};
	
	local function DateToName(struct)
		--print(struct)
		--for i,v in pairs(struct) do print(i) end
		return struct.day.."_"..struct.month.."_"..struct.year..".txt"
	end
	
	local CurTime = EndTime;
	while CurTime - DailyDelta >= StartTime do
		CurTime = CurTime - DailyDelta - 1;
		table.insert(Timestamps, 1, os.date("*t", CurTime));
	end  
	
	for i,v in pairs(Timestamps) do
		table.insert(FileList, DateToName(v));
	end

	local Data_Out = {};
	
	for _, FileName in pairs(FileList) do
		local file = io.open(DataDir..FileName, "r")
		print(FileName,file)
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


-- Extended mode:
-- Returns a table:
-- {[PriceClass] = {KWH = n; Costs = n;}, [PriceClass2] = {...}
function Lib:GetCosts(Data, Extended)
	local Costs = 0;
	local ExtraVal;
	for i,v in pairs(Data) do
		local PriceClass = self:GetPrice(os.date("*t", v));
		local Price = self.Price[PriceClass];
		local Cost = Price*self.KWHPerPulse;
		Costs = Costs+Cost;
		if Extended then
			if not ExtraVal then
				ExtraVal = {}; -- inits extra return value;
			end
			if not ExtraVal[PriceClass] then
				ExtraVal[PriceClass] = {KWH=0;Costs=0;};
			end
			-- Costs + KWH is saved. The prices might change.
			ExtraVal[PriceClass].KWH = ExtraVal[PriceClass].KWH + self.KWHPerPulse;
			ExtraVal[PriceClass].Costs = ExtraVal[PriceClass].Costs + Cost;
		end
	end
	return Costs, ExtraVal;
end

function Lib:GetKWH(Data)
	local NumData = #Data;
	local KWH = NumData * self.KWHPerPulse;
	return KWH;
end

-- returns: Time (s) and Energy (W) (so x and y values for graph use)
function Lib:GetEnergyData(Data)
	local Out = {}
	for i,v in pairs(Data) do
		if i == #Data then
			break
		end
		local Time = Data[i+1];
		local DTime = Time-v;
		local Power = self:GetPower(DTime);
		table.insert(Out, {Time, Power});
	end
	return Out;
end

function Lib:DataIsEmpty(Data)
	return #Data == 0 
end

return Lib 
