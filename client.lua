local dpad = {l = 47, r= 51, u= 27, d= 19, a= 21, b= 45, y= 23, x= 22, lt = 10, rt = 11, lb = 37, rb = 44, lu = 32, ld = 33, ll = 34, lr = 35, l3 = 36, rl = 5, rr = 6, ru = 3, rd = 4, r3 = 7, start = 199, sel = 0}	--Updated 29/4/20

--	By StaceyBee
--	Version : 1.1.2
--	Update : 20/03/2022
--	Info: Force vehicle to stop when tyres have popped.

local cfg = {
	on = true,				--<	Use this script?
	amt = "all",			--<	Amount of tyres popped until vehicle stops ( "all", "half", "3/4", "quarter", 1, 2, 3, 4, 5, 6)
	timer = nil,			--< Add a timer before vehicle stops. (timed by 100, timer will increase 1 per frame until it reaches value) (nil or 0+)
	hazards = false, 		--<	Enable hazard lights once vehicle is disabled (turn signals)
	breakEngine = true,		--<	Set engine health to 0.0 once tyres have popped. (will start to decrease if you crash) 
	fixable = true,			--< Reset once vehicle is repaired by any player.
	
	admin = true,			--< Set admin mode so that settings can be changed in game using commands. (Admin can use all mechanic commands)
	login = "tylogin",		--<	/Command to login as admin.
	password = "password1",	--<	Password to login as a admin.
	mech = true,			--<	If fixable = false then vehicles can only be reset by players assigned as a mechanic on their client script (cfg.mech = true).
	mLogin = "tymech",		--<	/Command to login as mechanic.
	mPwd = "password2",		--<	Password to login as a mechanic.
	
	test = {
		on = false,			--<	Activate testing mode (Pops tyres one by one and then repairs them in a loop)
		cmd = "pop",		--< Command to pop a tyre
		but = dpad.a,		--<	Button to press to pop a tyre (Controller) --See dpad at very top of script.
		dbug = false,		--<	Show tyre info on screen.
		amt = 1				--<	Dont touch this, it is edited by the script.
	}, 
	
	event = "handbrake",		--< What to do when tyres have popped?
							-->	"engine":		Turn engine off.
							-->	"handbrake":	Activate handbrake.
							-->	"explode":		Destroy vehicle.
							-->	"fire":			Set vehicle on fire.
							-->	"traction":		Lose control of vehicle by losing traction.
							-->	"launch":		Just for fun. Launches vehicle into air.
							-->	"gravity":		Another fun one. Lose all effects of gravity.
							-->	"crash":		More fun. Accelerator stuck open and you will have no control of steering.
							--> "random":		Any of the normal events picked at random. (see cfg.ev)
							--> "randomfun":	Include fun based events. (see cfg.evf)
							--> "custom":		Edit cfg.custom below to add custom functions.
	
	custom = {				--< Custom user defined events, will be picked at random if there is more than one function below.
	--[[					--<	Delete this line if you want to use template below.
		{func = function()
			local me = GetPlayerPed(-1)
			local veh = GetVehiclePedIsIn(me, 0)
			-->>Add event here<<<--
		end}
	--]]					--<	Delete this line if you want to use template above, put a comma after .
	},

	unique = {				--<	Vehicles with unique amount of wheels. (id: Veh hash, wh: Wheel ID's assigned to vehicle)
		{id = "RAPTOR", wh = {0, 1, 4}}			--This has 2 wheels on front and one wheel on back.
	},
	except = {				--<	Blacklisted vehicles that cant be stopped if tyres are popped.
		14, 15,				--Numbers will ignore the whole vehicle classes and strings will ignore specific vehicles (example: 14 ignores boats, "fbi" ignores the fbi car)
		"fbi", "fbi2", "police", "police2", "police3", "police4", "policeb", "policeold1", "policeold2", "policet", "pranger", "riot", "riot2", "sheriff", "sheriff2",
	},
	ev = {"handbrake", "engine", "fire", "traction"},												--Normal events to pick at random (add and remove events as you please)
	evf = {"handbrake", "engine", "fire", "explode", "traction", "launch", "gravity", "crash"},		--Normal + fun events to pick at random.
	
	---------------------
	--Dont edit these..--
	set = false,
	complete = false,
	stopped = false,
	tyres = {},
	burst = 0,
	crashex = false,
	aam = {"all","quarter","half","3/4"},
	aev = {"handbrake", "engine", "fire", "explode", "traction", "launch", "gravity", "crash", "random", "randomfun", "custom"},
	wh = {
		{name = "FL", id = 0},
		{name = "BL", id = 4},
		{name = "FR", id = 1},
		{name = "BR", id = 5},
		{name = "ML", id = 2},
		{name = "MR", id = 3},
		{name = "TL", id = 45},
		{name = "TR", id = 47}
	},
	all = {}
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if cfg.on == true then
			local me = GetPlayerPed(-1)
			local whr = GetEntityCoords(me)
			if IsPedInAnyVehicle(me, 0) then
				local veh = GetVehiclePedIsIn(me, false)
				local id = GetEntityModel(veh)
				local nam = GetDisplayNameFromVehicleModel(id)
				local mx = GetVehicleNumberOfWheels(veh)
				local class = GetVehicleClass(veh)
				local found = false
				for q1, exc in pairs(cfg.except) do
					local strfind = string.find(exc, "str" )
					if strfind == true then
						if exc == nam then
							found = true
						end
					else
						if exc == class then
							found = true
						end
					end
				end
				if found == false then
					local strfind = string.find(cfg.amt, "str" )
					if cfg.set == false then
						for i = 1, mx do
							table.insert(cfg.tyres, {id = cfg.wh[i].id})
						end
						if strfind == false then if cfg.amt > mx then cfg.amt = mx end end
						cfg.set = true
					else
						if #cfg.tyres > 0 then
							if type(cfg.amt) ~= "number" then
							--	notify("Str")
								if cfg.amt == "quarter" then
									local val = tonumber(string.format("%.0f", mx / 4))
									local val2 = tonumber(string.format("%.0f", mx - val))
									notify(val2)
									if #cfg.tyres < val2 then
										cfg.tyres = {}
									end
								elseif cfg.amt == "half" then
									if #cfg.tyres <= mx / 2 and #cfg.tyres > mx / 4 then
										cfg.tyres = {}
									end
								elseif cfg.amt == "3/4" then
									local val = tonumber(string.format("%.0f", mx / 2))
									local val2 = tonumber(string.format("%.0f", mx / 4))
									if #cfg.tyres < val + val2 - 1 then
										cfg.tyres = {}
									end
								end
							else
								if cfg.amt < 37 then if cfg.burst >= cfg.amt then cfg.tyres = {} end end
							end
							for a, ty in pairs(cfg.tyres) do
								if IsVehicleTyreBurst(veh, ty.id, 0) then
									table.remove(cfg.tyres, a)
									cfg.burst = cfg.burst + 1
								end
							end
						else
							if cfg.complete == false then
								local found = false
								if #cfg.all > 0 then
									for b, al in pairs(cfg.all) do
										if al.v == veh then
											found = true
										end
									end
								end
								if found == false then
									local tim = nil
									if cfg.timer ~= nil then tim = cfg.timer * 100 else tim = 0 end
									table.insert(cfg.all, {v = veh, tim = tim, set = false, ev = nil, done = false})
									if cfg.hazards == true then SetVehicleIndicatorLights(veh, 0, 1) SetVehicleIndicatorLights(veh, 1, 1) end	
									cfg.complete = true
								end
							else
								if cfg.fixable == true then
									local two = {0, 4}
									local four = {0, 4, 1, 5}
									local six = {0, 4, 1, 5, 2, 3}
									local found = 0
									if mx == 2 then
										for a1, to in pairs(two) do
											if not IsVehicleTyreBurst(veh, to, 0) then
												found = found + 1
											end
										end
									elseif mx == 4 then
										for a2, fo in pairs(four) do
											if not IsVehicleTyreBurst(veh, fo, 0) then
												found = found + 1
											end
										end
									elseif mx == 6 then
										for a3, si in pairs(six) do
											if not IsVehicleTyreBurst(veh, to, 0) then
												found = found + 1
											end
										end
									else
										if cfg.unique ~= nil then if #cfg.unique > 0 then
											for u1, un in pairs(cfg.unique) do
												if un.id == nam then
													for a4, unn in pairs(un.wh) do
														if not IsVehicleTyreBurst(veh, unn, 0) then
															found = found + 1
														end
													end
												end
											end
										end end
									end
									if found == mx then
										resetV(veh)
									end
								end
							end
						end
						if cfg.test.on == true then
							if cfg.test.but ~= nil then
								if IsControlJustPressed(0, cfg.test.but) then
									pop(veh)
								end
							end
						end
					end
				end
				local hea = GetVehicleEngineHealth(veh)
				if cfg.test.dbug == true then omg("Val: "..cfg.amt.."~n~Tyres: "..#cfg.tyres.."~n~Amt: "..cfg.test.amt.."~n~Burst: "..cfg.burst.."~n~Max: "..mx.."~n~Health: "..hea, 0.6, 0.7, 0.5, 4) end
			else
				if cfg.set == true then
					cfg.tyres = {}
					cfg.test.amt = 1
					cfg.burst = 0
					cfg.ft = 0
					cfg.set = false
					cfg.complete = false
					ClearPedTasks(me)
				end
			end
			if #cfg.all > 0 then
				for bb, all in pairs(cfg.all) do
					if all.v ~= nil then
						if DoesEntityExist(all.v) then
							local id = GetEntityModel(veh)
							local nam = GetDisplayNameFromVehicleModel(id)
							local found = false
							for q2, excc in pairs(cfg.except) do
								if nam == excc then
									found = true
								end
							end
							if found == false then
								if all.ev == nil then
									if cfg.event == "random" then
										all.ev = cfg.ev[math.random(#cfg.ev)]
									elseif cfg.event == "randomfun" then
										all.ev = cfg.evf[math.random(#cfg.evf)]
									elseif cfg.event == "custom" then
										local furn = cfg.custom[math.random(#cfg.custom)]
										furn.func()
									else
										all.ev = cfg.event
									end
									if all.ev == "crash" then cfg.crashex = false end
									if cfg.breakEngine == true then  SetVehicleEngineHealth(all.v, 0.0) end
								else
									if all.done == false then
										if all.tim > 0 then
											all.tim = all.tim - 1
										else
											if all.ev == "engine" then if GetIsVehicleEngineRunning(all.v) then SetVehicleEngineOn(all.v, false, 1, 1) end
											elseif all.ev == "explode" then
												local vwhr = GetEntityCoords(all.v)
												AddExplosion(vwhr.x, vwhr.y, vwhr.z, 0, 10.0, 0, 0, 0)
											elseif all.ev == "fire" then SetVehicleEngineHealth(all.v, -500.0)
											elseif all.ev == "launch" then
												local xrn = math.random(-100, 100) local yrn = math.random(-100, 100) local zrn = math.random(0, 100)
												SetEntityVelocity(all.v,xrn+.0, yrn+.0, zrn+.0)
												local xv = math.random(-180, 180) local yv = math.random(-180, 180) local zv = math.random(-180, 180)
												SetEntityAngularVelocity(all.v,xv+.0, yv+.0, zv+.0)
											elseif all.ev == "gravity" then SetVehicleGravity(all.v, false)
											end
											all.done = true
										end
									else
										if all.ev == "handbrake" or all.ev == "launch" then SetVehicleHandbrake(all.v, true) 
										elseif all.ev == "traction" then SetVehicleReduceGrip(all.v, true)
										elseif all.ev == "engine" then if GetIsVehicleEngineRunning(all.v) then SetVehicleEngineOn(all.v, false, 1, 1) end
										elseif all.ev == "crash" then 
											local ped = nil
											if IsPedInAnyVehicle(me, 0) then
												if cfg.crashex == false then
													TaskVehicleTempAction(me, all.v, 32, -1) 
													if IsControlJustPressed(0, dpad.y) then 
														TaskLeaveVehicle(me, all.v, 4160)
														RequestModel("a_m_m_og_boss_01")
														while not HasModelLoaded("a_m_m_og_boss_01") do Citizen.Wait(1) end
														ped = CreatePedInsideVehicle(all.v, 2, "a_m_m_og_boss_01", -1, 0, 1)
															SetEntityAsMissionEntity(ped, 1,1)
															SetEntityAlpha(ped, 0, 0)
															TaskVehicleTempAction(ped, all.v, 32, -1)
															
														cfg.crashex = true
													end
												else
													local speed = GetEntityVelocity(all.v)
													SetEntityVelocity(all.v, speed.x, speed.y, speed.z)
												end
											end
											if cfg.crashex == false then
												if ped ~= nil then
													if DoesEntityExist(ped) then
														local pwhr = GetEntityCoords(ped)
														local dist = Vdist(whr.x, whr.y, whr.z, pwhr.x, pwhr.y, pwhr.z)
														if dist > 300 then
															SetEntityAsNoLongerNeeded(ped)
															DeleteEntity(ped)
															table.remove(cfg.all, bb)
															ped = nil
														end
													end
												end
											else
												if ped == nil then
													local speed = GetEntityVelocity(all.v)
													SetEntityVelocity(all.v, speed.x, speed.y, speed.z)
												else
													cfg.crashex = false
												end
											end			
										end
									--	if cfg.fixable == false then
											
									end
								end
							end
						else
							table.remove(cfg.all, bb)
						end
					else
						table.remove(cfg.all, bb)
					end
				end
			end
		end
	end
end)

--=========================================
--{ FUNC }--

--Reset veh--
function resetV(veh)
	SetVehicleHandbrake(veh, false)
	SetVehicleEngineOn(veh, true, 1, 1)
	SetVehicleIndicatorLights(veh, 0, 0)
	SetVehicleIndicatorLights(veh, 1, 0)
	SetVehicleReduceGrip(veh, false)
	if #cfg.all > 0 then
		for b, al in pairs(cfg.all) do
			if al.v == veh then
				table.remove(cfg.all, b)
			end
		end
	end
	cfg.ft = 0
	cfg.tyres = {}
	cfg.test.amt = 1
	cfg.burst = 0
	cfg.set = false
	cfg.complete = false
--	notify("ReseV")
end

--Fix veh--
function fixable(bool)
	if bool == nil then
		if cfg.fixable == true then
			cfg.fixable = false
			notify("~w~Vehicles will ~r~no longer ~w~be fixable by people who are not assigned as a ~o~mechanic ~w~or ~o~admin.")
		else
			cfg.fixable = true
			notify("Script will ~g~detect ~w~and ~g~reset ~w~vehicles after they have been ~o~repaired~w~.")
		end
	else
		if type(bool) == "boolean" then
			cfg.fixable = bool
		else
			notify("~r~Invalid ~w~boolean.")
		end
	end
end
RegisterCommand("tyfixable", function()
	if cfg.admin == true then
		fixable()
	else
		notify("You are ~r~Not ~w a ~o~Admin ~w~or a ~b~Mechanic~w~.")
	end
end)

RegisterCommand(cfg.mLogin, function(source, args, rawCommand)
	if cfg.mech == false then
		local pwd = nil
		if args[1] ~= nil then pwd = args[1] end
		if pwd == cfg.mPwd then
			exports.tyredamage:mechanic()
		else
			notify("Incorrect ~r~Password~w~.")
		end
	else
		exports.tyredamage:mechanic()
	end
end)

function getMech()
	return cfg.mech
end
function mechanic(bool)
	if cfg.fixable == false then
		if bool == nil then
			if cfg.mech == true then
				cfg.mech = false
				notify("You can no longer ~r~fix vehicles~w~.")
			else
				cfg.mech = true
				notify("You can now ~g~fix vehicles~w~.")
			end
		else
			if bool == true then
				cfg.mech = true
				notify("You can now ~g~fix vehicles~w~.")
			elseif bool == false then
				cfg.mech = false
				notify("You can no longer ~r~fix vehicles~w~.")
			else
				notify("~r~Invalid ~w~input.")
			end
				
		end
	else
		if bool == nil then
			if cfg.mech == true then
				cfg.mech = false
				notify("You can no longer ~r~fix vehicles~w~.")
			else
				cfg.mech = true
				notify("You can now ~g~fix vehicles~w~.")
			end
		else
			if bool == true then
				cfg.mech = true
				notify("You can now ~g~fix vehicles~w~.")
			elseif bool == false then
				cfg.mech = false
				notify("You can no longer ~r~fix vehicles~w~.")
			else
				notify("~r~Invalid ~w~input.")
			end
				
		end
		notify("~p~NOTE: ~w~No need to assign mechanic because vehicles are already ~o~fixable ~w~by everybody.")
	end
end

function fixV(veh)
	SetVehicleFixed(veh)
	resetV(veh)
end

RegisterCommand("tyfix", function()
	if cfg.admin == true or cfg.mech == true then
		local me = GetPlayerPed(-1)
		if IsPedInAnyVehicle(me, 0) then
			local veh = GetVehiclePedIsIn(me, 0)
			fixV(veh)
		end
	else
		notify("You are ~r~Not ~w~ a ~o~Admin ~w~or a ~b~Mechanic~w~.")
	end
end)
		
		

--Admin--
function getAdmin()
	return cfg.admin
end
function admin(bool)
	if bool == nil then
		if cfg.admin == true then
			cfg.admin = false
			notify("~r~Exiting~w~ admin mode.")
		else
			cfg.admin = true
			notify("~g~Assigned as admin.")
		end
	else
		cfg.mech = bool
	end
end
RegisterCommand(cfg.login, function(source, args, rawCommand)
	if cfg.admin == false then
		local pwd = nil
		if args[1] ~= nil then pwd = args[1] end
		if pwd == cfg.password then
			exports.tyredamage:admin()
		else
			notify("Incorrect ~r~Password.")
		end
	else
		exports.tyredamage:admin()
	end
end)
RegisterCommand("tyamt", function(source, args, rawCommand)
	if cfg.admin == true then
		local key = nil
		local str = false
		if args[1] ~= nil then key = args[1] end
		if key ~= nil then
			local found = false
			for a, al in pairs(cfg.aam) do
				if key == al then
					found = true
				end
			end
			if found == true then
				cfg.amt = tostring(key)
				notify("~o~Amount ~w~of tyres set to ~g~"..cfg.amt)
			else
				local num = tonumber(string.format("%.0f", key))
				if num <= 6 then
					cfg.amt = num
					notify("~o~Amount ~w~of tyres set to ~g~"..num)
				else
					notify("~r~Invalid ~o~tyre ~w~amount ~n~/tyamti for possible variations.")
				end
			end
		else
			notify("~r~No ~w~key entered. ~n~/tyamti for possible variations")
		end			
	else
		notify("You are ~r~Not ~w an ~o~Admin.")
	end
end)
RegisterCommand("tyamti", function()
	if cfg.admin == true then
		print("Possible variations for 'amount of tyres needed to be popped':")
		for a, al in pairs(cfg.aam) do
			print(al)
		end		
	else
		notify("You are ~r~Not ~w an ~o~Admin.")
	end
end)
RegisterCommand("tyevent", function(source, args, rawCommand)
	if cfg.admin == true then
		local key = nil
		if args[1] ~= nil then key = args[1] end
		if key ~= nil then
			local found = false
			for a, al in pairs(cfg.aev) do
				if key == al then
					found = true
				end
			end
			if found == true then
				cfg.event = key
				notify("Tyre event set to ~g~"..cfg.event)
			else
				notify("~r~Invalid ~o~tyre ~w~event ~n~/tyeventi for possible variations.")
			end
		else
			notify("~r~No ~w~key entered. ~n~/tyeventi for possible variations")
		end			
	else
		notify("You are ~r~Not ~w an ~o~Admin.")
	end
end)
RegisterCommand("tyeventi", function()
	if cfg.admin == true then
		print("Possible variations for 'event that happens once tyres are popped':")
		for a, al in pairs(cfg.aev) do
			print(al)
		end		
	else
		notify("You are ~r~Not ~w an ~o~Admin.")
	end
end)
RegisterCommand("tytest", function()
	if cfg.admin == true then
		local me = GetPlayerPed(-1)
		if cfg.test.on == false then
			cfg.test.on = true
			notify("Tyre test mode ~g~ON")
		else
			cfg.test.on = false
			notify("Tyre test mode ~r~OFF")
		end
	else
		notify("You are ~r~Not ~w~ a ~o~Admin.")
	end
end)
RegisterCommand(cfg.test.cmd, function()
	if cfg.admin == true then
		local me = GetPlayerPed(-1)
		if IsPedInAnyVehicle(me, 0) then
			local veh = GetVehiclePedIsIn(me, 0)
			pop(veh)
		else
			notify("You ~r~need ~w~ to be in a ~o~vehicle.")
		end
	else
		notify("You are ~r~Not ~w~ a ~o~Admin.")
	end
end)

function pop(veh)
	local mx = GetVehicleNumberOfWheels(veh)
	if cfg.test.amt < mx + 1 then
		if not IsVehicleTyreBurst(veh, cfg.wh[cfg.test.amt].id) then
			SetVehicleTyreBurst(veh, cfg.wh[cfg.test.amt].id, 1, 1000)
			cfg.test.amt = cfg.test.amt + 1
		else
			cfg.test.amt = cfg.test.amt + 1
		end
	else
		for ii = 0, 46 do
			SetVehicleTyreFixed(veh, ii)
		end
		fixV(veh)
	end
end
RegisterCommand("tybug", function()
	if cfg.admin == true then
		local me = GetPlayerPed(-1)
		if cfg.test.dbug == false then
			cfg.test.dbug = true
			notify("Tyre debug mode ~g~ON")
		else
			cfg.test.dbug = false
			notify("Tyre debug mode ~r~OFF")
		end
	else
		notify("You are ~r~Not ~w a ~o~Admin.")
	end
end)

RegisterCommand("tyi", function()
	if cfg.admin == true then
		print("All Tyre Damage commands..")
		print("cmd: "..cfg.login.." 		desc:	Log in as admin (cmd + password)")
		print("cmd: tyadmin				desc:	Assign yourself as admin")
		print("cmd: tyamt				desc:	Set amount of tyres needed to be popped before vehicle stops")
		print("cmd: tyamti				desc:	Possible variations for 'amount of tyres needed to be popped'")
		print("cmd: tyevent				desc:	Set event that makes vehicle stop")
		print("cmd: tyeventi			desc:	Possible variations for 'event that stops vehicle'")
		print("cmd: tyfixable			desc:	Set if vehicles can be fixed by any player.")
		print("cmd: tyfix				desc:	Fix vehicle and restore (must be admin or mechanic if fixable = false)")
		print("cmd: tytest				desc:	Enter/exit test mode")
		print("cmd: "..cfg.test.cmd.."	desc:	pop tyres one by one and then reset")
		print("cmd: tybug				desc:	Show tyre information on screen")
		notify("~o~Tyre Damage ~w~ commands printed to console (F8).")
	else
		notify("You are ~r~Not ~w~ a ~o~Admin.")
	end
end)

--Notifications--
function alert(msg)
	SetTextComponentFormat("STRING")
	AddTextComponentString(msg)
	DisplayHelpTextFromStringLabel(0,0,1,-1)
end

function notify(msg)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	DrawNotification(true, false)
end

function omg(msg,x,y,s,f)
	if f ~= nil then SetTextFont(f) else SetTextFont(1) end
	SetTextProportional(1)
	if f ~= nil then SetTextScale(0.0, s) else SetTextScale(0.0, 0.4) end
	SetTextDropshadow(1, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextCentre(true)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	if msg == nil then
		AddTextComponentString("OMG!")
	else
		AddTextComponentString(msg)
	end
	if x ~= nil then DrawText(x, y) else DrawText(0.5, 0.2) end
end