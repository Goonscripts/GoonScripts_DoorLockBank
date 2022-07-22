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

	doorInfo[doorID] = state

	TriggerClientEvent('esx_doorlockbank:setState', -1, doorID, state)
end)

ESX.RegisterServerCallback('esx_doorlockbank:getDoorInfo', function(source, cb)
	cb(doorInfo)
end)

ESX.RegisterServerCallback('GoonScripts_DoorLockBank:DoYouHaveItemCivie', function(source, cb)
	local xPlayer		= ESX.GetPlayerFromId(source)
	local identifier	= xPlayer.getIdentifier()
	local minamount		= GoonScripts.MinAmount
	local item 			= GoonScripts.CivieItem
	local getitem 		= xPlayer.getInventoryItem(item).count

	if getitem >= minamount then
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('GoonScripts_DoorLockBank:DoYouHaveItemPolice', function(source, cb)
	local xPlayer		= ESX.GetPlayerFromId(source)
	local identifier	= xPlayer.getIdentifier()
	local minamount		= GoonScripts.MinAmount
	local item 			= GoonScripts.PoliceItem
	local getitem 		= xPlayer.getInventoryItem(item).count

	if getitem >= minamount then
		cb(true)
	else
		cb(false)
	end
end)

RegisterServerEvent('GoonScripts_DoorLockBank:UsedAZiptieBank')
AddEventHandler('GoonScripts_DoorLockBank:UsedAZiptieBank', function()
	local xPlayer		= ESX.GetPlayerFromId(source)
	local identifier	= xPlayer.getIdentifier()
	local minamount		= GoonScripts.MinAmount
	local item 			= GoonScripts.CivieItem
	local getitem 		= xPlayer.getInventoryItem(item).count

	if getitem >= minamount then
		xPlayer.removeInventoryItem(item, minamount)
		xPlayer.showNotification(_U('used_ziptie_bank'))
	end
end)