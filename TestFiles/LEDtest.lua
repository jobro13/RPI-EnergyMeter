GPIO = require "GPIO"
GPIO.setmode(GPIO.BOARD)
GPIO.setup(7,GPIO.OUT)

print("Press any key to go HIGH")
io.read()
print("LED is now HIGH")
GPIO.output(7,true)
print("Press another key when done")
io.read()
GPIO.output(7,false)
