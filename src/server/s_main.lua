if Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
else
    QBCore = exports['qb-core']:GetCoreObject()
end

function logDiscord(title, message, color)
    local data = { username = "vh-fishing", avatar_url = "https://i.imgur.com/E2Z3mDO.png", embeds = { { ["color"] = color, ["title"] = title, ["description"] = message, ["footer"] = { ["text"] = "Installation Support - [ESX, QBCore Qbox] -  https://discord.gg/CBSSMpmqrK" },} }}
    PerformHttpRequest(WebhookConfig.URL, function(err, text, headers) end, 'POST', json.encode(data), {['Content-Type'] = 'application/json'})
end

lib.callback.register('vhs-recycle:processing', function(source)
    local src = source
    AddItem(src, 'recycle', 1)
    return true
end)

lib.callback.register('vhs-recycle:sellmenu', function(source)
    local src = source
    local menuOptions = {}
    for itemName, itemPrice in pairs(items) do
        table.insert(menuOptions, {
            title = GetItemLabel(itemName) .. " ($" .. itemPrice .. ")",
            icon = InventoryImagePath .. itemName .. ".png", 
            event = 'vhs-recycle:sellamount',
            args = { item = itemName, price = itemPrice }
        })
    end
    return menuOptions
end)


lib.callback.register('vhs-recycle:sellItem', function(source, data)
    local xPlayer = GetPlayerData(source)
    if not xPlayer then  
        Notify("info", "Player Not Found", "", source) 
        return false 
    end
    local item = GetInventoryItem(source, data.item)
    if item and item.count >= data.amount then
        local moneys = data.amount * data.price
        RemoveItem(source, data.item, data.amount)
        AddMoney(source, moneys)
        local discordMessage = string.format("**%s sold %d x %s for $%d**", GetPlayerName(source), data.amount, GetItemLabel(data.item), moneys)
        logDiscord("\u{1F4B8} Recycle Sold - " .. GetItemLabel(data.item), discordMessage, 65280)
        Notify("info", "Recycling Depot", "You sold " .. data.amount .. " " .. GetItemLabel(data.item) .. " for $" .. moneys, source)
        return true
    else
        Notify("error", "Recycling Depot", "Not enough items to sell.", source)
        return false
    end
end)

lib.callback.register('vhs-recycle:giveitems', function(source, amountToAdd)
    local src = source
    local recycleItem = GetInventoryItem(src, 'recycle')
    if recycleItem.count >= amountToAdd then 
        RemoveItem(src, 'recycle', amountToAdd)
        for i = 1, amountToAdd do
            local itemsGiven = 0
            while itemsGiven < giveItemAmount do
                local randomItem = getRandomItemFromConfig()
                AddItem(src, randomItem, 1)
                itemsGiven = itemsGiven + 1
            end
        end
        return true
    else
        return false, "Not enough recycle items"
    end
end)

function getRandomItemFromConfig()
    local keys = {}
    for key in pairs(items) do
        table.insert(keys, key)
    end
    return keys[math.random(#keys)]
end

