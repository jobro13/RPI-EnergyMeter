GPIO = require "GPIO"
GPIO.setmode(GPIO.BOARD)
GPIO.setup(7,GPIO.OUT)

GPIO.output(7,true)
os.execute("sleep 1")
GPIO.output(7,false)
