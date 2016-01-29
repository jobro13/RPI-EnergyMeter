# RPI-EnergyMeter
Raspberry Pi energy monitoring system (analog)

Services are:
PowerDriver.lua 

PowerDriver drives the RESET pin and the READ pin of the Pi GPIO. It also writes all timestamps - millisecond precision - to a file.

LuaWebWorker.lua

WebWorker updates the current usage files.

Apache should be configured with /web as DocumentRoot (or equivalent).

