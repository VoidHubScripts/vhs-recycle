function GetPlayerData(source)
    if Framework == 'esx' then
        ESX = exports["es_extended"]:getSharedObject()
        return 
        ESX.GetPlayerFromId(source)
    elseif Framework == 'qbcore' then 
        QBCore = exports['qb-core']:GetCoreObject()
        return 
        QBCore.Functions.GetPlayer(source)
    else 
        print('Unsupported Framework')
    end 
end   

function GetItemLabel(item)
    if Framework == 'esx' then
        return ESX.GetItemLabel(item)
    elseif Framework == 'qbcore' then
        if QBCore and QBCore.Shared and QBCore.Shared.Items[item] then
            return QBCore.Shared.Items[item].label
        else
            return item  
        end
    else
        print("Unsupported framework.")
        return item  
    end
end

function AddMoney(source, amount)
    if Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.addMoney(amount)
        else
        end
    elseif Framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            xPlayer.Functions.AddMoney('cash', amount)
        else
        end
    else
        print("Unsupported framework.")
    end
end

function AddItem(source, item, amount)
    if Framework == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.canCarryItem(item, amount) then 
            xPlayer.addInventoryItem(item, amount)
        else 
            Notify("error", "Error", 'You cannot carry anymore!', source)
            print('ESX: Inventory full or cannot carry item')
        end 
    elseif Framework == 'qbcore' then 
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            local added = xPlayer.Functions.AddItem(item, amount)
            if added then
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'add', amount)
            else
                print('QBCore: Inventory full or cannot carry item') 
            end  
        else 
            print('QBCore: Player not found')
        end 
    else 
        print('')
    end 
end

function GetInventoryItem(source, item)
    if Framework == 'esx' then
        local xPlayer = GetPlayerData(source)
        if xPlayer then
            local esxItem = xPlayer.getInventoryItem(item)
            if esxItem and esxItem.count > 0 then
                return { count = esxItem.count, label = esxItem.label }
            end
        end
    elseif Framework == 'qbcore' then
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            local qItem = xPlayer.Functions.GetItemByName(item)
            if qItem then 
                return { count = qItem.amount, label = qItem.label }
            end 
        end 
    else
        print("Unsupported framework.")
    end
    return { count = 0, label = item } 

end

function RemoveItem(source, item, amount)
    if Framework == 'esx' then 
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then        
            if xPlayer.getInventoryItem(item).count >= amount then
                xPlayer.removeInventoryItem(item, amount)
                return true
            else
                print("Player does not have enough of the item.")
                return false
            end
        else 
            print("Player not found.")
            return false
        end 
    elseif Framework == 'qbcore' then 
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
                xPlayer.Functions.RemoveItem(item, amount)
                TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item], 'remove', amount)
                return true
            else
            print("Player not found.")
            return false
        end 
    else 
        print("Set your framework!")
        return false
    end 
end


