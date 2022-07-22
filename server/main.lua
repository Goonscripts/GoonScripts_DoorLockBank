ESX = nil
local doorInfo = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_doorlockbank:updateState')
AddEventHandler('esx_doorlockbank:updateState', function(doorID, state)
	local xPlayer = ESX.GetPlayerFromId(source)

	if type(doorID) ~= 'number' then
		print(('esx_doorlockbank: %s didn\'t send a number!'):format(xPlayer.identifier))
		return
	end

	if type(state) ~= 'boolean' then
		print(('esx_doorlockbank: %s attempted to update invalid state!'):format(xPlayer.identifier))
		return
	end

	if not Config.DoorList[doorID] then
		print(('esx_doorlockbank: %s attempted to update invalid door!'):format(xPlayer.identifier))
		return
	end

	if not IsAuthorized(xPlayer.job.name, Config.DoorList[doorID]) then
		print(('esx_doorlockbank: %s was not authorized to open a locked door!'):format(xPlayer.identifier))
		return
	end

	doorInfo[doorID] = state

	TriggerClientEvent('esx_doorlockbank:setState', -1, doorID, state)
end)

ESX.RegisterServerCallback('esx_doorlockbank:getDoorInfo', function(source, cb)
	cb(doorInfo)
end)

function IsAuthorized(jobName, doorID)
	for _,job in pairs(doorID.authorizedJobs) do
		if job == jobName then
			return true
		end
	end

	return false
end