ESX = nil

local ShowText 			= false
local YesTiesIGot 		= false
local YesCuttersIGot	= false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	-- Update the door list
	ESX.TriggerServerCallback('esx_doorlockbank:getDoorInfo', function(doorInfo)
		for doorID,state in pairs(doorInfo) do
			Config.DoorList[doorID].locked = state
		end
	end)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

local jobyes            = GoonScripts.Job

Citizen.CreateThread(function()
    while true do
        Wait(5000)
            ESX.TriggerServerCallback('GoonScripts_DoorLockBank:DoYouHaveItemCivie', function(DoYouHaveZipTiesBank)
                if DoYouHaveZipTiesBank then
                    YesTiesIGot = true
                else
                    YesTiesIGot = false
                end
            end)
	        ESX.TriggerServerCallback('GoonScripts_DoorLockBank:DoYouHaveItemPolice', function(DoYouHaveBoltCutter)
	            if DoYouHaveBoltCutter then
	                YesCuttersIGot = true
	            else
	                YesCuttersIGot = false
	            end
	        end)
    end
end)
-- Get objects every second, instead of every frame
Citizen.CreateThread(function()
	while true do
		for _,doorID in ipairs(Config.DoorList) do
			if doorID.doors then
				for k,v in ipairs(doorID.doors) do
					if not v.object or not DoesEntityExist(v.object) then
						v.object = GetClosestObjectOfType(v.objCoords, 1.0, GetHashKey(v.objName), false, false, false)
					end
				end
			else
				if not doorID.object or not DoesEntityExist(doorID.object) then
					doorID.object = GetClosestObjectOfType(doorID.objCoords, 1.0, GetHashKey(doorID.objName), false, false, false)
				end
			end
		end

		Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords, letSleep = GetEntityCoords(PlayerPedId()), true

		for k,doorID in ipairs(Config.DoorList) do
			local distance

			if doorID.doors then
				distance = #(playerCoords - doorID.doors[1].objCoords)
			else
				distance = #(playerCoords - doorID.objCoords)
			end

			local maxDistance, size, displayText = 1.25, 1, _U('unlocked')

			if doorID.distance then
				maxDistance = doorID.distance
			end

			if distance < 50 then
				letSleep = false

				if doorID.doors then
					for _,v in ipairs(doorID.doors) do
						FreezeEntityPosition(v.object, doorID.locked)

						if doorID.locked and v.objYaw and GetEntityRotation(v.object).z ~= v.objYaw then
							SetEntityRotation(v.object, 0.0, 0.0, v.objYaw, 2, true)
						end
					end
				else
					FreezeEntityPosition(doorID.object, doorID.locked)

					if doorID.locked and doorID.objYaw and GetEntityRotation(doorID.object).z ~= doorID.objYaw then
						SetEntityRotation(doorID.object, 0.0, 0.0, doorID.objYaw, 2, true)
					end
				end
			end

			if distance < maxDistance then
				if doorID.size then
					size = doorID.size
				end

				if doorID.locked then
					displayText = _U('locked')
				end

				if ShowText == true then
					ESX.Game.Utils.DrawText3D(doorID.textCoords, displayText, size)
				end
				if IsControlJustReleased(0, 38) then
					if not doorID.locked then
						if YesTiesIGot then
							doorID.locked = true
								TriggerServerEvent('esx_doorlockbank:updateState', k, doorID.locked)
								TriggerServerEvent('GoonScripts_DoorLockBank:UsedAZiptieBank')
						else
							ESX.ShowNotification(_U('not_enough_ziptiesbank'))
						end
					else
						if YesCuttersIGot then
							doorID.locked = false
								TriggerServerEvent('esx_doorlockbank:updateState', k, doorID.locked)
								ESX.ShowNotification(_U('used_boltcutter'))
						else
							ESX.ShowNotification(_U('not_enough_boltcutters'))
						end
					end
				end
			end
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

-- Set state for a door
RegisterNetEvent('esx_doorlockbank:setState')
AddEventHandler('esx_doorlockbank:setState', function(doorID, state)
	Config.DoorList[doorID].locked = state
end)


function ShowDoorText()
	ShowText = true
end

function DontShowDootText()
	ShowText = false
end



RegisterCommand('sdt', function()
	if ShowText == false then 
  		ShowDoorText()
  	else
  		DontShowDootText()
  	end
end)