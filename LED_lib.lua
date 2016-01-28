-- Driver library - used with built-in led circuit;
local PINS = {
	[7] = "Pulse" -- Led pulse pin
	[11] = "Reset" -- Hold RESET pin
	[13] = "Read" -- Read pin
}

-- couple keys and pairs of PINS table
for i,v in pairs(PINS) do
	PINS[v] = i
end

local GPIO = require "GPIO"
GPIO.setwarnings(false);
GPIO.setmode(GPIO.BOARD);

GPIO.setup(PINS.Read, GPIO.IN);
GPIO.setup(PINS.Reset, GPIO.OUT);
GPIO.setup(PINS.Pulse, GPIO.OUT);

local OUT = {}

local function sleep(t) os.execute("sleep "..t) end

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
