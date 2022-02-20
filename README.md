Version 1.0.2		--Created by StaceyBee--
Created 20/2/22


--[[ INTRO]]--

Here is a basic script to force player vehicles to stop once the tyres have been popped.
With many settings to choose from like the amount of tyres needed to pop before it stops, how you want to stop the vehicle, etc.

--[[ INSTALL ]]--
Drag folder into your resource folder, ensure tyredamage in server.cfg.

--[[ SETTINGS ]]--

By default the script will set the car on FIRE once ALL of the tyres are popped.
Open client.lua and edit the settings in the cfg table.

On:							--Turn the script on/off

Amt:						--Amount of tyres needed to be popped before vehicle stops.
	--Possible variables:
	--"all":				All tyres needed to be popped.
	--"half":				Half of all tyres needed to be popped.
	--"quarter":			A quarter of all tyres needed to be popped.
	--"3/4":				Three quarters of all tyres needed to be popped.
	--Numbers 1 - 6:		Specific amount of tyres.

Event:						--What to do once the tyres are popped.
	--Possible variables:
	--"engine":				Turn engine off.
	--"handbrake":			Activate handbrake.
	--"explode":			Destroy vehicle.
	--"fire":				Set vehicle on fire.
	--"launch":				Just for fun. Launches vehicle into air.
	--"grip":				Another fun one. Lose traction.
	
Hazards:					--Enable hazard lights once vehicle is disabled. (turn signals)

Test:						--Enable test/debug mode. (enables you to pop tyres one by one and then reset)
On:							--Activate test mode.
But:						--Buttom to press to pop tyres (use "dpad." + button, example: dpad.r), see top of client script for button names)
Dbug:						--Show vehicle & tyre info



