ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_slotmachine:sv:1')
AddEventHandler('esx_slotmachine:sv:1', function(amount,a,b,c)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	amount = tonumber(amount)
		if (xPlayer.getMoney() >= tonumber(amount)) or (xPlayer.getAccounts('black_money') >= tonumber(amount)) then
		xPlayer.removeMoney(amount)
		-- xPlayer.removeAccountMoney('black_money', (amount))
		TriggerClientEvent("esx_slotmachine:1",source,tonumber(amount),tostring(a),tostring(b),tostring(c))
	else
		TriggerClientEvent("pNotify:SendNotification", source, {text = "Nie masz wystarczająco dużo pieniędzy", type = "atlantis", queue = "global", timeout = 2000, layout = "atlantis"})
	end
end)

RegisterServerEvent('esx_slotmachine:sv:2')
AddEventHandler('esx_slotmachine:sv:2', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	    xPlayer.addMoney(amount)
	    -- xPlayer.addAccountMoney('black_money', (amount))
		TriggerClientEvent("pNotify:SendNotification", source, {text = "WYGRANA! " .. amount .. "$", type = "atlantis", queue = "global", timeout = 2000, layout = "atlantis"})
	end)