GPIO = require "GPIO";
GPIO.setmode(GPIO.BOARD);
GPIO.setup(7, GPIO.OUT);
GPIO.setup(11, GPIO.IN);

print("LED is off:")
GPIO.output(7,false);
print("Input is:", GPIO.input(11));
print("Press any key to enable LED:");
io.read()
GPIO.output(7,true)
os.execute("sleep 1") -- allow the input to go HIGH
print("LED is on. Input is: ", GPIO.input(11))
print("Press any key to quit")
--io.read()
GPIO.output(7,false)
