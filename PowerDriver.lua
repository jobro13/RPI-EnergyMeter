-- This file handles the reading and resetting of the HOLDing capacitors

Lib = require "PowerLib";



while true do
	print("Waiting for pulse...")
	Lib:WaitForHigh()
	local Time = Lib:GetTimestamp()
	Lib:WritePulse(Time)
	print("Pulsed! Resetting now.")
	Lib:Reset()
end	
	
