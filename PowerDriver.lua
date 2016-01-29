-- This file handles the reading and resetting of the HOLDing capacitors

Lib = require "PowerLib";



while true do
	print("Waiting for pulse...")
	Lib:WaitForHigh()
	local Time = Lib:GetTimestamp()
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
	
