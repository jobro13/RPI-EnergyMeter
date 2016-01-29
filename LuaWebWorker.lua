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

function UpdateGraph(Data) 
	-- Update graph function
	local Data = DataProcessing:GetEnergyData(Data);
	local DataFileName = os.tmpname();
	local DataFile = io.open(DataFileName, "w")
	local PlotFileName = os.tmpname()
	local PlotFile = io.open(PlotFileName, "w");
	local TimeLast = Data[#Data][1];	
	for i,v in pairs(Data) do
		DataFile:write(((v[1]-TimeLast)/60).."\t"..v[2].."\t0xAAAAAA\n");
	end
	DataFile:flush()
	local Body = "set term png size 1920,1080\n"
	Body = Body .. "set output \""..IFrameDir.."DailyGraph.png\"\n"
	
	local function add(s) Body = Body .. s .. "\n" end

	add("set xtics 60")
	add("set style fill pattern 3")
	add("set linetype 1 linecolor variable")
	add("set yrange [0:*]")
	--filledcurves x1
	Body = Body.."plot \""..DataFileName.."\" using 1:2:3 with filledcurves x1 fs solid 1\n"
	PlotFile:write(Body);
	PlotFile:flush();
	PlotFile:close();

	os.execute("gnuplot "..PlotFileName)
	-- Remove tmpfiles
	os.remove(DataFileName)
	os.remove(PlotFileName)
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
	CCosts = math.floor((CCosts*1000)+0.5)/1000;
	local wfile = io.open(IFrameDir.."DailyCosts", "w+");
	wfile:write(CCosts)
	wfile:flush()
	wfile:close()
end

function UpdateCEnergy(Data)
	local Energy = DataProcessing:GetKWH(Data);
	Energy = math.floor((Energy*1000)+0.5)/1000;
	local wfile = io.open(IFrameDir.."DailyPower", "w+");
	wfile:write(Energy)
	wfile:flush()
	wfile:close()
end

local Counter = 0;

while true do
	Counter = Counter + 1
	if true or Counter == 20 then -- 20*3 = 60
		-- Every minute, update the graph;
		local Data = DataProcessing:CollectData(60*60*24);
		UpdateGraph(Data)
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
	--os.execute("sleep 3")
	break
end
