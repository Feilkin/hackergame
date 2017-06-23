-- this file defines some of the different possible nodes

-- pc's
return {
	type = "pc",
	scriptable = true,

	sockets = extend(
		amount(1, 4, function ()
			return {
				type = "ethernet",
				speed = choice(10, 100, 1000),
				name = "eth" .. index()
			} end
		),
		amount(0, 1, function ()
			return {
				type = "wlan",
				speed = choice(5, 10, 50),
				name = "wlan" .. index()
			} end
		),
		amount(1, 3, function ()
			return {
				type = "usb",
				speed = choice(1),
				name = "usb" .. index()
			} end
		),
	),

	cpu = {
		freq = range(800, 3200, 100),
		cores = range(1, 6)
	}
}