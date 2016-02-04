local Dir = "/home/pi/RPI-EnergyMeter/Data"

function handle(r)
	local tmpname = os.tmpname()
	r:puts("Zipping...")
	r:flush()
	os.execute("zip -r " ..tmpname..".zip "..Dir)
	r:sendfile(tmpname..".zip")
	r:puts("\nComplete!")
	r:flush()
	return apache2.OK
end
