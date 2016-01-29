-- This file handles the reading and resetting of the HOLDing capacitors

Lib = require "PowerLib";
Lib:GPIOInit()

local DataProcessing = require "DataProcessing"; -- Used to convert DT to energy

local LastTime

while true do
	print("Waiting for pulse...")
	Lib:WaitForHigh()
	local Time = Lib:GetTimestamp()
	if LastTime then
		DT = Time - LastTime;
		local Power = DataProcessing:GetPower(DT); 
		Lib:WritePower(Power);
	end
	LastTime = Time
	Lib:WritePulse(Time)
	print("Pulsed! Resetting now.")
	Lib:Reset()
	os.execute("sleep 0.1")
	if Lib:IsHigh() then
		os.execute("sleep 0.1")
		if Lib:IsHigh() then
			print("warning: still is high")
			repeat
				os.execute("sleep 0.1")
			until not Lib:IsHigh()
		end
	end
end	
	
