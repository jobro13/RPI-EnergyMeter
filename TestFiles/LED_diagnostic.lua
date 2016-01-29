lib = require "LED_lib"

lib:Reset()

for i = 1,10 do
	lib:WaitForHigh()
	print("It's now high! Let's reset.")
	lib:Reset()
	os.execute("sleep 0.1")
	print("Is it still high?", lib:IsHigh())
	os.execute("sleep 0.9")
	print("Repeat waiting for high...")
end
