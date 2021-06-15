ESX = nil
local JobPlayersBlip = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_service:notifyAllInService')
AddEventHandler('esx_service:notifyAllInService', function(notification, target)
	target = GetPlayerFromServerId(target)
	if target == PlayerId() then return end

	local targetPed = GetPlayerPed(target)
	local mugshot, mugshotStr = ESX.Game.GetPedMugshot(targetPed)

	ESX.ShowAdvancedNotification(notification.title, notification.subject, notification.msg, mugshotStr, notification.iconType)
	UnregisterPedheadshot(mugshot)
end)

function createBlip(id, playerData)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(playerData.name)
		EndTextCommandSetBlipName(blip)
		
		SetBlipScale(blip, 0.7) -- set scale
		SetBlipAsShortRange(blip, true)
		SetBlipColour(blip, 2)

		table.insert(JobPlayersBlip, blip) -- add blip to array so we can remove it later
	end
end

function createBlipCoords(playerData)
	local blip = AddBlipForCoord(playerData.coords)
	SetBlipSprite(blip, 1)
	ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
	SetBlipRotation(blip, math.ceil(playerData.heading)) -- update rotation
	SetBlipColour(blip, 2)
	
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(playerData.name)
	EndTextCommandSetBlipName(blip)
	
	SetBlipScale(blip, 0.7) -- set scale
	SetBlipAsShortRange(blip, true)

	table.insert(JobPlayersBlip, blip)
end

RegisterNetEvent('esx_service:inServicePlayersBlips')
AddEventHandler('esx_service:inServicePlayersBlips', function(players)
	-- Refresh all blips
	for k, existingBlip in pairs(JobPlayersBlip) do
		RemoveBlip(existingBlip)
	end
	
	-- Clean the blip table
	JobPlayersBlip = {}
	local playerServerId = GetPlayerServerId(PlayerId())
	
	for k, player in pairs(players) do
		local id = GetPlayerFromServerId(player.source)
		if player.source ~= playerServerId then
			if GetPlayerPed(id) ~= PlayerPedId() then
				createBlip(id, player)
			else
				createBlipCoords(player)
			end
		end
	end
end)

RegisterNetEvent('esx_service:DisableServiceBlips')
AddEventHandler('esx_service:DisableServiceBlips', function()
	for k, existingBlip in pairs(JobPlayersBlip) do
		RemoveBlip(existingBlip)
	end
end)