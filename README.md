Version 1.0.4		--Created by StaceyBee--
Created 20/2/22
Updated 27/2/22


--[[ INTRO]]--

Here is a basic script to force player vehicles to stop once the tyres have been popped.
With many settings to choose from like the amount of tyres needed to pop before it stops, how you want to stop the vehicle, etc.

--[[ INSTALL ]]--
Drag folder into your resource folder, ensure tyredamage in server.cfg.

--[[ SETTINGS ]]--

By default the script will set the vehicles HANDBRAKE once ALL of the tyres are popped.
Admin and Mech both will be set to true by default so all players will have full control of script.
Open client.lua and edit the settings in the cfg table.

On:							--Turn the script on/off

Amt:						--Amount of tyres needed to be popped before vehicle stops.
	--Possible variables:
	--"all":				All tyres needed to be popped.
	--"half":				Half of all tyres needed to be popped.
	--"quarter":				A quarter of all tyres needed to be popped.
	--"3/4":				Three quarters of all tyres needed to be popped.
	--Numbers 1 - 6:			Specific amount of tyres.

Event:						--What to do once the tyres are popped.
	--Possible variables:
	--"engine":				Turn engine off.
	--"handbrake":				Activate handbrake.
	--"grip":				Lose traction.
	--"fire":				Set vehicle on fire.
	--"explode":				Destroy vehicle. (This is considered by script to be a "fun" based event).
	--"launch":				Just for fun. Launches vehicle into air.
	--"gravity":				Another fun one. Lose all effects of gravity.
	--"crash":				More fun. Accelerator stuck open and you will have no control of steering.
	--"random":				Any of the normal events picked at random. (see cfg.ev)
	--"randomfun":				Include fun based events. (see cfg.evf)
	--"custom":				Edit cfg.custom below to add custom functions.
	
Custom:						--An easy way for users to add their own events without having to edit the base script.
						--Remove the --[[ & --]] from the custom lines to use custom functions. If you are adding more than one dont forget to put a..							--..comma between the functions after the }. Custom functiions will be chosen at random if there is more than one.

Timer:						--Add a timer before vehicle stops. (multiplied by 100, timer will increase 1 per frame until it reaches value) (nil or 0+)	
Breakable Engine:				--Set engine health to 0.0 once tyres have popped. (will start to decrease if you crash) 
Fixable:					--If set to true then script will auto-detect when a vehicle has been repaired by other scripts. False will mean that only 
						--..players assigned as an admin or mechanic on their client script can reset vehicles using \tyfix.
Hazards:					--Enable hazard lights once vehicle is disabled. (turn signals)
						
						
Admin: 						--Is client assigned as an admin. Admin can also use all mechanic features.
login:						--/command to sign in as an admin.
Password:					--Password to sign in as an admin. (ex: /tylogin password1)
Mech:						--Is client assigned as a mechanic? Mechanics can fix vehicles using command /tyfix.
mLogin:						--/command to sign in as an mechanic.
mPwd:						--Password to sign in as an mechanic. (ex: /tymech password2)

Unique:						--Add vehicles with a unique amount of tyres. (id = veh-hash, wh = wheel-ID's)
						--For example the "Raptor" has 2 wheels on the front and 1 wheel on back.
					
Except:						--Blacklisted vehicles that cant be stopped if tyres are popped. By default cop cars are ignored.

Test:						--Enable test/debug mode. (enables you to pop tyres one by one and then reset)
On:						--Activate test mode.
But:						--Buttom to press to pop tyres (use "dpad." + button, example: dpad.r), see top of client script for button names)
Dbug:						--Show vehicle & tyre info

NOTE: Type /tyi in chat to see all commands in console. (you have to be admin to do this)

---------------------------------------------------------------------
--{	CHANGELOG	}--

1.0.0 (19-10-2019) - Basic script created to help somebody on forums. --https://forum.cfx.re/t/request-stop-the-car-when-the-tire-punctures/853032--
	   	    - Script was created on a train home from work and untested. Was only intended to point the OP in the right direction. I was also new to FiveM.
	   
1.0.1 (18-2-2022) - Forum user had edited script and messaged me asking me for help. --https://forum.cfx.re/uploads/short-url/yQQsOezhzn3ipxobpwdlWDj5P4m.rar--

1.1.0 (20-2-2022) - Official release. Script was remastered. Lots of features added, intended to be used in game rather than as an example.

1.1.1 (27-2-2022) - Bugs fixed and more features added.
		  - Features added:
		  -	Admin/Password system to allow users access to commands that control the script.
		  - 	A mechanic and repair system that either detects and resets vehicles as they are repaired by other scripts, .. 
		  		or it will only let players assigned as an admin and mechanic reset vehicles.
		  -	Added a unique table to handle vehicles with unique amount of wheels.
		  -	Added a blacklist to ignore certain vehicles by script.
		  -	Optional timer added between when tyres are finished popping and when event is triggered.
		  -	Option to easily add own events without having to edit base code.
		  -	Command added for test mode.
		  -	Many new commands added
		  -	Some export functions to control script from your own resourses.
		  -	Command /tyi to print all commands to console.
		  
		  - Events added:
		  -	"random"	--Pick any of the normal events at random
		  -	"randomfun"	--Pick any of the normal + fun events at random
		  -	"custom"	--User defined events.
		  -	"gravity"	--I was just messing around. Lose gravity (fun based)
		  -	"crash"		--Accelerator stuck open and no control of steering, also car will still accelerate after player has exited because never gonna give 			  		  	you up lol. (fun based)
		  -	"traction"	--"grip" is now named "traction".
		  -	"explode"	--"explode" is now considered to only be a fun based event by script.
		  
		  - Bugs fixed:
		  -	Fixed bug where vehicles cannot be reset when they are repaired.
		  -	"quarter" amt is now calculated correctly.
		  -	Script will now calculate when vehicles dont exist correctly.
		  -	Script will no longer break when using a vehicle with strange amount of wheels (3 or 5 or whatever)



	   



