-- Lua Web Worker.
-- Creates the following files:
-- /web/iframe/CurrentPower (current power in W)
-- /web/iframe/DailyCosts   (costs since midnight)
-- /web/iframe/DailyGraph   (graph created by gnuplot)
-- /web/iframe/DailyPower   (energy usage today (kWh)

local DataProcessing = require "DataProcessing"; -- Data processing library;
local WebDir = DataProcessing.RootPath.."web/"
local IFrameDir = WebDir.."iframe/"

local CPower = DataProcessing.DataDir.."CurrentPower.txt";

function UpdateGraph() 
	-- Update graph function
end

function UpdateCPower()
	-- Update current power
	local file = io.open(CPower, "r");
	local use = file:read();
	local num = tonumber(use)
	local num = math.floor((num*10)+0.5)/10;
	print(use,num)
	local wfile = io.open(IFrameDir.."CurrentPower", "w+")
	print(IFrameDir.."CurrentPower")
	wfile:write(num);
	wfile:flush()
	wfile:close()
	file:close()
end

function UpdateCCosts(Data)
	-- update current costs
	local CCosts = DataProcessing:GetCosts(Data);
	local wfile = io.open(IFrameDir.."DailyCosts", "w+");
	wfile:write(CCosts)
	wfile:flush()
	wfile:close()
end

function UpdateCEnergy(Data)
	local Energy = DataProcessing:GetKWH(Data);
	local wfile = io.open(IFrameDir.."DailyPower", "w+");
	wfile:write(Energy)
	wfile:flush()
	wfile:close()
end

local Counter = 0;

while true do
	Counter = Counter + 1
	if Counter == 20 then -- 20*3 = 60
		-- Every minute, update the graph;
		UpdateGraph()
		Counter=0
	end
	
	local TimeNow = os.time();
	local DateTable = os.date("*t", TimeNow);
	DateTable.hour=0;
	DateTable.min=0;
	DateTable.sec=0;
	local StartTime = os.time(DateTable);
	local Delta = TimeNow-StartTime;
	local Data = DataProcessing:CollectData(Delta,TimeNow);
	
	UpdateCPower()
	UpdateCCosts(Data)
	UpdateCEnergy(Data)
	os.execute("sleep 3");
	break
end
