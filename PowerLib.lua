-- Driver library - used with built-in led circuit;

local Lib = {}

Lib.Path = "/home/pi/RPI-EnergyMeter/" -- path to home directory;
Lib.DataDir = "Data"

local PINS = {
	[7] = "Pulse", -- Led pulse pin (not necessary for normal operation)
	[11] = "Reset", -- Hold RESET pin
	[13] = "Read", -- Read pin
}
PINS.Pulse=7 -- Why doesn't this work in below code!?
-- couple keys and pairs of PINS table
for i,v in pairs(PINS) do
	PINS[v] = i
end

local DSLib = require "DSLib"; -- Data saving library;
DSLib:Unpack(Lib); -- unpacks DSLib functions inside Lib;


local GPIO = require "GPIO"
GPIO.setwarnings(false);
GPIO.setmode(GPIO.BOARD);
print(PINS.Pulse, PINS.Read, PINS.Reset)
for i,v in pairs(PINS) do print(i) end
GPIO.setup(PINS.Read, GPIO.IN);
GPIO.setup(PINS.Reset, GPIO.OUT);
GPIO.setup(PINS.Pulse, GPIO.OUT);

local OUT = Lib

local function sleep(t) os.execute("sleep "..t) end

function OUT:GetTimestamp()
	local cmd = "date +%s:%N:%D";
	local out = io.popen(cmd);
	str = out:read();
	out:close()
	local ts, N, Date = str:match("(%d+):(%d+):(.*)");
	local ts = ts + N/10^9;
	return ts, Date
end

function OUT:GetFilename(Mode, Date)
	local Root = self.Path..self.DataDir.."/"
	if Mode == "WritePulse" then -- Write a pulse timestamp
		return Root..Date:gsub("/", "_")..".txt" -- format is now 01_01_01
	elseif Mode == "WriteSummary" then -- Write a summary (day/week/year)
		-- yet to do
	end
end

function OUT:WritePulse(Timestamp)
	local N = math.floor(Timestamp)
	local Date = os.date("*t", N);
	local DStr = Date.day.."/"..Date.month.."/"..Date.year;
	local FName = self:GetFilename("WritePulse", DSTr);
	self:WriteNumber(Timestamp, FName)
end

function OUT:Pulse(t)
	GPIO.output(PINS.Pulse,true)
	sleep(t)
	GPIO.output(PINS.Pulse,false)
end

function OUT:Reset()
	GPIO.output(PINS.Reset, true)
	sleep(0.01)
	GPIO.output(PINS.Reset, false)
end

function OUT:IsHigh()
	return GPIO.input(PINS.Read)
end

function OUT:WaitForHigh()
	while not OUT:IsHigh() do
		sleep(0.1)
	end
end
	
return OUT
