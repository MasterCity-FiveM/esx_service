ESX                = nil
local InService    = {}
local MaxInService = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function GetInServiceCount(name)
	local count = 0
	
	if InService[name] == nil then
		return 0
	end
		
	for k,v in pairs(InService[name]) do
		if v == true then
			count = count + 1
		end
	end

	return count
end

AddEventHandler('esx_service:activateService', function(name, max)
	InService[name]    = {}
	MaxInService[name] = max
end)

RegisterServerEvent('esx_service:disableService')
AddEventHandler('esx_service:disableService', function(name)
	InService[name][source] = nil
end)

RegisterServerEvent('esx_service:notifyAllInService')
AddEventHandler('esx_service:notifyAllInService', function(notification, name)
	if InService[name][source] == nil then
		return
	end
	
	for k,v in pairs(InService[name]) do
		if v == true then
			TriggerClientEvent('esx_service:notifyAllInService', k, notification, source)
		end
	end
end)

ESX.RegisterServerCallback('esx_service:enableService', function(source, cb, name)
	local inServiceCount = GetInServiceCount(name)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer.job == nil or xPlayer.job.name == nil or xPlayer.job.name ~= name then
		cb(false, MaxInService[name], inServiceCount)
		return
	end

	if inServiceCount >= MaxInService[name] then
		xPlayer.set('InService', false)
		cb(false, MaxInService[name], inServiceCount)
	else
		xPlayer.set('InService', true)
		InService[name][source] = true
		cb(true, MaxInService[name], inServiceCount)
	end
end)

AddEventHandler('esx_service:GetServiceCount', function(cb, name)
	local inServiceCount = GetInServiceCount(name)

	cb(inServiceCount)
end)

ESX.RegisterServerCallback('esx_service:GetServiceCount', function(cb, name)
	local inServiceCount = GetInServiceCount(name)
	cb(inServiceCount)
end)

ESX.RegisterServerCallback('esx_service:isInService', function(source, cb, name)
	local isInService = false

	if InService[name] == nil then
		isInService = true
		cb(isInService)
		return
	end

	if InService[name][source] then
		isInService = true
	end

	cb(isInService)
end)

ESX.RegisterServerCallback('esx_service:getInServOnlinePlayers', function(source, cb, job)
	local players = {}
	if InService[job] == nil then
		cb(players)
		return
	end
	
	for k, _ in pairs(InService[job]) do
		local xPlayer = ESX.GetPlayerFromId(k)
		if xPlayer then
			table.insert(players, {
				source = xPlayer.source,
				identifier = xPlayer.identifier,
				name = xPlayer.name,
				job = xPlayer.job
			})
		end
	end
	
	cb(players)
end)

ESX.RegisterServerCallback('esx_service:getInServiceList', function(source, cb, name)
	cb(InService[name])
end)

AddEventHandler('esx_service:getInServicePlayers', function(cb, name)
	cb(InService[name])
end)

AddEventHandler('playerDropped', function()
	local _source = source
		
	for k,v in pairs(InService) do
		if v[_source] == true then
			v[_source] = nil
		end
	end
end)