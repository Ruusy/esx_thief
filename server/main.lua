ESX = nil
local Users = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_thief:getValue', function(source, cb, targetSID)
	if Users[targetSID] then
		cb(Users[targetSID])
	else
		cb({value = false, time = 0})
	end
end)

ESX.RegisterServerCallback('esx_thief:getOtherPlayerData', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)

	local data = {
		name = GetPlayerName(target),
		inventory = xPlayer.inventory,
		accounts = xPlayer.accounts,
		money = xPlayer.getMoney()
	}

	cb(data)
end)

RegisterServerEvent('esx_thief:stealPlayerItem')
AddEventHandler('esx_thief:stealPlayerItem', function(target, itemType, itemName, amount)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if itemType == 'item_standard' then

		local label = sourceXPlayer.getInventoryItem(itemName).label
		local itemLimit = sourceXPlayer.getInventoryItem(itemName).limit
		local sourceItemCount = sourceXPlayer.getInventoryItem(itemName).count
		local targetItemCount = targetXPlayer.getInventoryItem(itemName).count

		if amount > 0 and targetItemCount >= amount then
			if itemLimit ~= -1 and (sourceItemCount + amount) > itemLimit then
				TriggerClientEvent("pNotify:SendNotification", targetXPlayer.source, {text = _U('ex_inv_lim_target'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })

				TriggerClientEvent("pNotify:SendNotification", sourceXPlayer.source, {text = _U('ex_inv_lim_source'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })

			else
				targetXPlayer.removeInventoryItem(itemName, amount)
				sourceXPlayer.addInventoryItem(itemName, amount)

				TriggerClientEvent("pNotify:SendNotification", sourceXPlayer.source, {text = _U('you_stole') .. ' x' .. amount .. ' ' .. label .. '' .. _U('from_your_target'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })
				TriggerClientEvent("pNotify:SendNotification", targetXPlayer.source, {text = _U('someone_stole') .. '~x'  .. amount .. ' ' .. label,type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })
			end
		else
			TriggerClientEvent("pNotify:SendNotification", _source, {text = _U('invalid_quantity'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })

		end

	elseif itemType == 'item_money' then

		if amount > 0 and targetXPlayer.get('money') >= amount then
			targetXPlayer.removeMoney(amount)
			sourceXPlayer.addMoney(amount)

			TriggerClientEvent("pNotify:SendNotification", sourceXPlayer.source, {text = _U('you_stole') .. ' $' .. amount .. '' .. _U('from_your_target'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })
			TriggerClientEvent("pNotify:SendNotification", targetXPlayer.source, {text = _U('someone_stole') .. ' $'  .. amount,type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })

		else
			TriggerClientEvent("pNotify:SendNotification", _source, {text =_U('imp_invalid_amount'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })

		end

	elseif itemType == 'item_account' then

		if amount > 0 and targetXPlayer.getAccount(itemName).money >= amount then
			targetXPlayer.removeAccountMoney(itemName, amount)
			sourceXPlayer.addAccountMoney(itemName, amount)

			TriggerClientEvent("pNotify:SendNotification", sourceXPlayer.source, {text =_U('you_stole') .. '$' .. amount .. ' ' .. _U('of_black_money') .. ' ' .. _U('from_your_target'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })
			TriggerClientEvent("pNotify:SendNotification", targetXPlayer.source, {text =_U('someone_stole') .. ' $'  .. amount .. ' ' .. _U('of_black_money'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })

		else
			TriggerClientEvent("pNotify:SendNotification", _source, {text =_U('imp_invalid_amount'),type = "warning",queue = "duty", theme = "metroui", timeout = 2500,layout = "topRight" })

		end

	end
end)

RegisterServerEvent('esx_thief:update')
AddEventHandler('esx_thief:update', function(bool)
	local _source = source
	Users[_source] = {value = bool, time = os.time()}
end)

RegisterServerEvent('esx_thief:getValue')
AddEventHandler('esx_thief:getValue', function(targetSID)
	local _source = source
	if Users[targetSID] then
		TriggerClientEvent('esx_thief:returnValue', _source, Users[targetSID])
	else
		TriggerClientEvent('esx_thief:returnValue', _source, Users[targetSID])
	end
end)