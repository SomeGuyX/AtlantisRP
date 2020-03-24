ESX                     = nil
Items                   = {}
local InventoriesIndex  = {}
local Inventories       = {}
local SharedInventories = {}


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
	local items = MySQL.Sync.fetchAll('SELECT * FROM items')

	for i=1, #items, 1 do
		Items[items[i].name] = items[i].label
	end

	local result = MySQL.Sync.fetchAll('SELECT * FROM addon_inventory')

	for i=1, #result, 1 do
		local name   = result[i].name
		local label  = result[i].label
		local shared = result[i].shared

		local result2 = MySQL.Sync.fetchAll('SELECT * FROM addon_inventory_items WHERE inventory_name = @inventory_name', {
			['@inventory_name'] = name
		})

		if shared == 0 then

			table.insert(InventoriesIndex, name)
			Inventories[name] = {}

		else

			local items = {}

			for j=1, #result2, 1 do
				table.insert(items, {
					name  = result2[j].name,
					count = result2[j].count,
					label = Items[result2[j].name]
				})
			end

			local addonInventory    = CreateAddonInventory(name, nil, items)
			SharedInventories[name] = addonInventory

		end
	end
end)
function ReRegisterInventory() 
SharedInventories = {}
	local items = MySQL.Sync.fetchAll('SELECT * FROM items')

	for i=1, #items, 1 do
		Items[items[i].name] = items[i].label
	end

	local result = MySQL.Sync.fetchAll('SELECT * FROM addon_inventory WHERE shared = 1')

	for i=1, #result, 1 do
		local name   = result[i].name
		local label  = result[i].label
		local shared = result[i].shared

		local result2 = MySQL.Sync.fetchAll('SELECT * FROM addon_inventory_items WHERE inventory_name = @inventory_name', {
			['@inventory_name'] = name
		})

		if shared == 1 then

			local items = {}

			for j=1, #result2, 1 do
				table.insert(items, {
					name  = result2[j].name,
					count = result2[j].count,
					label = Items[result2[j].name]
				})
			end

			local addonInventory    = CreateAddonInventory(name, nil, items)
			SharedInventories[name] = addonInventory

		end
	end

end
function GetInventory(name, owner)
	for i=1, #Inventories[name], 1 do
		if Inventories[name][i].owner == owner then
			return Inventories[name][i]
		end
	end
end
function GetInventoryReset(name, owner)
	for i=1, #Inventories[name], 1 do
		if Inventories[name][i] ~= nil then
			if Inventories[name][i].owner == owner then
				table.remove(Inventories[name], i)
			end
		end
	end
	return true
end
function GetSharedInventory(name)
	ReRegisterInventory()
	return SharedInventories[name]
end

AddEventHandler('esx_addoninventory:getInventory', function(name, owner, cb)
	cb(GetInventory(name, owner))
end)

AddEventHandler('esx_addoninventory:getSharedInventory', function(name, cb)
	cb(GetSharedInventory(name))
end)
RegisterServerEvent('esx_fixAddon:Inventory')
AddEventHandler('esx_fixAddon:Inventory', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local addonInventories = {}
	for i=1, #InventoriesIndex, 1 do
		local name      = InventoriesIndex[i]
		local inventoryReset = GetInventoryReset(name, xPlayer.identifier)
	end
	local result = MySQL.Sync.fetchAll('SELECT * FROM addon_inventory')

	for i=1, #result, 1 do
		local name   = result[i].name
		local label  = result[i].label
		local shared = result[i].shared

		local result2 = MySQL.Sync.fetchAll('SELECT * FROM addon_inventory_items WHERE inventory_name = @inventory_name AND owner = @owner' , {
			['@inventory_name'] = name,
			['@owner'] = xPlayer.identifier
		})

		if shared == 0 then		
			local items       = {}

			for j=1, #result2, 1 do
				local itemName  = result2[j].name
				local itemCount = result2[j].count
				local itemOwner = result2[j].owner

				if items[itemOwner] == nil then
					items[itemOwner] = {}
				end

				table.insert(items[itemOwner], {
					name  = itemName,
					count = itemCount,
					label = Items[itemName]
				})
			end

			for k,v in pairs(items) do
				local addonInventory = CreateAddonInventory(name, k, v)
				table.insert(Inventories[name], addonInventory)
			end
		end
	end
	

	for i=1, #InventoriesIndex, 1 do
		local name      = InventoriesIndex[i]
		--local inventoryReset = GetInventoryReset(name, xPlayer.identifier)
		local inventory = GetInventory(name, xPlayer.identifier)
		
		if inventory == nil then
			inventory = CreateAddonInventory(name, xPlayer.identifier, {})
			table.insert(Inventories[name], inventory)
		end

		table.insert(addonInventories, inventory)
	end

	xPlayer.set('addonInventories', addonInventories)
	ReRegisterInventory() 
end)
AddEventHandler('esx:playerLoaded', function(source)

end)
