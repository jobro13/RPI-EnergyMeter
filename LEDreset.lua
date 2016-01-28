GPIO = require "GPIO";
GPIO.setwarnings(false)
GPIO.setmode(GPIO.BOARD);
GPIO.setup(7, GPIO.OUT);
GPIO.setup(11, GPIO.OUT);

print("LED is off:")
GPIO.output(7,false);
--print("Input is:", GPIO.input(11));
print("Press any key to pulse LED (20ms):");
io.read()
GPIO.output(7,true)
os.execute("sleep 0.02") -- allow the input to go HIGH
print("LED has pulsed")-- Input is: ", GPIO.input(11))
print("Press any key to RESET")
--io.read()
GPIO.output(7,false)
io.read()
GPIO.output(11,true)
os.execute("sleep 0.01")
GPIO.output(11,false)
print("Done")
