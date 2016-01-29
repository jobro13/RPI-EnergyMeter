lib = require "LED_lib"

lib:Reset()

local ofile = ({...})[1];
print("LOGGING TO: " .. ofile);

local f = io.open(ofile, "a+") -- open in append mode;


for i = 1,1000 do
	lib:WaitForHigh()
	local time = lib:GetTimestamp();
	print("It's now high! Let's reset. Time: "..time)
	lib:Reset()
	f:write(time.."\n") -- very CRUDE data logging
	f:flush()
	os.execute("sleep 0.1")
	print("Waiting...")
	
end
