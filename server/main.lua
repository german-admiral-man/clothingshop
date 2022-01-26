ESX = nil

TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

ESX.RegisterServerCallback('clothingshop:getConfigData', function(source, cb)

    while shop == nil do
        Citizen.Wait(50)
    end

    cb(shop)

end)

ESX.RegisterServerCallback('clothingshop:pay', function(source, cb, price, label)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        TriggerClientEvent("clothingshop:sendNotify", source, "Du hast das Outfit unter dem Namen " ..label.. " für $" ..price.. " gespeichert.")
        cb(true)
    else
        TriggerClientEvent("clothingshop:sendNotify", source, "Du hast nicht genug Geld für $" ..price.. " , um ein Outfit zu kaufen - " ..label)
        cb(false)
    end
end)

RegisterServerEvent('clothingshop:saveOutfit')
AddEventHandler('clothingshop:saveOutfit', function(datastore, label, skin)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerEvent('esx_datastore:getDataStore', datastore, xPlayer.identifier, function(store)
        local dressing = store.get('dressing')

        if dressing == nil then
            dressing = {}
        end

        table.insert(dressing, {
            label = label,
            skin  = skin
        })

        store.set('dressing', dressing)
        store.save()
    end)
end)

ESX.RegisterServerCallback('clothingshop:getOutfits', function(source, cb, datastore)
    local xPlayer  = ESX.GetPlayerFromId(source)

    TriggerEvent('esx_datastore:getDataStore', datastore, xPlayer.identifier, function(store)
        local count    = store.count('dressing')
        local labels   = {}

        for i=1, count, 1 do
            local entry = store.get('dressing', i)
            table.insert(labels, entry.label)
        end

        cb(labels)
    end)
end)

RegisterServerEvent('clothingshop:deleteOutfit')
AddEventHandler('clothingshop:deleteOutfit', function(outfData, outfLabel, datastore)
    local xPlayer = ESX.GetPlayerFromId(source)

    TriggerEvent('esx_datastore:getDataStore', datastore, xPlayer.identifier, function(store)
        local dressing = store.get('dressing')

        if dressing == nil then
            dressing = {}
        end

        outfData = outfData

        table.remove(dressing, outfData)

        store.set('dressing', dressing)

        TriggerClientEvent("clothingshop:sendNotify", source, "Du hast folgendes Outfit gelöscht - " ..outfLabel)
    end)
end)

ESX.RegisterServerCallback('clothingshop:getPlayerOutfit', function(source, cb, num, label, datastore)
    local xPlayer  = ESX.GetPlayerFromId(source)

    TriggerEvent('esx_datastore:getDataStore', datastore, xPlayer.identifier, function(store)
        local outfit = store.get('dressing', num)
        cb(outfit.skin)
        TriggerClientEvent("clothingshop:sendNotify", source, "Du hast folgendes Outfit gewechselt - " ..label)
    end)
end)