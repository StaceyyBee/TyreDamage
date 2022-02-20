local dpad = {l = 47, r= 51, u= 27, d= 19, a= 21, b= 45, y= 23, x= 22, lt = 10, rt = 11, lb = 37, rb = 44, lu = 32, ld = 33, ll = 34, lr = 35, l3 = 36, rl = 5, rr = 6, ru = 3, rd = 4, r3 = 7, start = 199, sel = 0}	--Updated 29/4/20

--	By StaceyBee
--	version : 1.01
--	update : 13/02/2022
--	info: Force vehicle to stop when tyres have popped.

local cfg = {
	on = true,				--<	Use this script?
	amt = "all",			--<	Amount of tyres popped until vehicle stops ( "all", "half", "3/4", "quarter", 1, 2, 3, 4, 5, 6)
	hazards = true, 		--<	Enable hazard lights once vehicle is disabled (turn signals)
	test = {
		on = true,			--<	Activate testing mode (Pops tyres one by one and then repairs them)
		but = dpad.a,		--<	Button to press to pop tyres (Controller)
		dbug = false,		--<	debug text.
		amt = 1	,			--<	Dont touch this, it is edited by the script.
	},
	event = "fire",			--< What to do when tyres have popped?
							-->	"engine":		Turn engine off.
							-->	"handbrake":	Activate handbrake.
							-->	"explode":		Destroy vehicle.
							-->	"fire":			Set vehicle on fire.
							-->	"launch":		Just for fun. Launches vehicle into air.
							-->	"grip":			Another fun one. Lose traction.
	--Dont edit these..--
	set = false,
	complete = false,
	stopped = false,
	tyres = {},
	burst = 0,
	wh = {
		{name = "FL", id = 0},
		{name = "BL", id = 4},
		{name = "FR", id = 1},
		{name = "BR", id = 5},
		{name = "ML", id = 2},
		{name = "MR", id = 3},
		{name = "TL", id = 45},
		{name = "TR", id = 47}
	}
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if cfg.on == true then
			local me = GetPlayerPed(-1)
			if IsPedInAnyVehicle(me, 0) then
				local veh = GetVehiclePedIsIn(me, false)
				local mx = GetVehicleNumberOfWheels(veh)
				if cfg.set == false then
					for i = 1, mx do
						table.insert(cfg.tyres, {id = cfg.wh[i].id})
					end
					if IsStringNullOrEmpty(cfg.amt) then if cfg.amt > mx then cfg.amt = mx end end
					cfg.set = true
				else
					if #cfg.tyres > 0 then
						local strfind = string.find(cfg.amt, "str" )
						if not IsStringNullOrEmpty(cfg.amt) then
							if cfg.amt == "quarter" then
								local val = tonumber(string.format("%.0f", mx / 2))
								local val2 = tonumber(string.format("%.0f", mx / 4))
								if #cfg.tyres < val - val - 1 then
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
							if cfg.amt < 37 then if cfg.burst == cfg.amt then cfg.tyres = {} cfg.burst = 0 end end
						end
						for a, ty in pairs(cfg.tyres) do
							if IsVehicleTyreBurst(veh, ty.id, 0) then
								table.remove(cfg.tyres, a)
								cfg.burst = cfg.burst + 1
							end
						end
					else
						if cfg.event == "handbrake" or cfg.event == "launch" then SetVehicleHandbrake(veh, true) 
						elseif cfg.event == "engine" then if GetIsVehicleEngineRunning(veh) then SetVehicleEngineOn(veh, false, 1, 1) end
						elseif cfg.event == "explode" then
							if cfg.complete == false then
								local vwhr = GetEntityCoords(veh)
								AddExplosion(vwhr.x, vwhr.y, vwhr.z, 0, 10.0, 0, 0, 0)
							end
						elseif cfg.event == "fire" then
							if cfg.complete == false then
								SetVehicleEngineHealth(veh, -500.0)
							end
						end
						if cfg.complete == false then 
							if cfg.hazards == true then SetVehicleIndicatorLights(veh, 0, 1) SetVehicleIndicatorLights(veh, 1, 1) end
							if cfg.event == "launch" then
								local xrn = math.random(-100, 100) local yrn = math.random(-100, 100) local zrn = math.random(0, 100)
								SetEntityVelocity(veh,xrn+.0, yrn+.0, zrn+.0)
							elseif cfg.event == "grip" then
								SetVehicleReduceGrip(veh, true)
							end
						end
						cfg.complete = true
					end
					if cfg.test.on == true then
						if cfg.test.but ~= nil then
							if IsControlJustPressed(0, cfg.test.but) then
								if cfg.test.amt < mx + 1 then
								--	if cfg.test.amt == 1 then cfg.test.amt = 4 end
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
									SetVehicleFixed(veh)
									SetVehicleHandbrake(veh, false)
									SetVehicleEngineOn(veh, true, 1, 1)
									SetVehicleIndicatorLights(veh, 0, 0)
									SetVehicleIndicatorLights(veh, 1, 0)
									SetVehicleReduceGrip(veh, false)
									cfg.tyres = {}
									cfg.test.amt = 1
									cfg.burst = 0
									
									cfg.set = false
									cfg.complete = false
								end
							end
						end
					end
				end
				local hea = GetVehicleEngineHealth(veh)
				if cfg.test.dbug == true then omg("Val: "..cfg.amt.."~n~Tyres: "..#cfg.tyres.."~n~Amt: "..cfg.test.amt.."~n~Burst: "..cfg.burst.."~n~Max: "..mx.."~n~Health: "..hea) end
			else
				if cfg.set == true then
					cfg.tyres = {}
					cfg.test.amt = 1
					cfg.burst = 0
					cfg.set = false
					cfg.complete = false
				end
			end
		end
	end
end)

--=========================================
--{ TEXT }--

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

function omg(msg)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.4)
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
	DrawText(0.5, 0.5)
end