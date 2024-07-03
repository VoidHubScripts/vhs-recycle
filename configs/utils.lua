
if Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() else QBCore = exports['qb-core']:GetCoreObject() end


Notify = function(type, title, text, targetClient)
    local types = { info = "inform", error = "error", success = "success" }
    if not types[type] then return end  
    
    local message = title
    if text and text ~= "" then
        message = message .. ": " .. text
    end

    if Notifications == "ox_lib" then
        if IsDuplicityVersion() then
            TriggerClientEvent('ox_lib:notify', targetClient, { type = types[type], title = title, position = 'center-right', description = text, })
        else 
            lib.notify({ title = title, description = text, position = 'center-right', type = types[type] })
        end 
    elseif Notifications == "esx" then
        if IsDuplicityVersion() then
            TriggerClientEvent('esx:showNotification', targetClient, message)
        else
            ESX.ShowNotification(message)
        end
    elseif Notifications == "qbcore" then
        local types = {info = "primary", error = "error", success = "success"}
        if types[type] then
            if IsDuplicityVersion() then
                TriggerClientEvent('QBCore:Notify', targetClient, message, types[type])
            else
                QBCore.Functions.Notify(message, types[type])
            end
        end
    elseif Notifications == "custom" then
        -- Custom notification handling
    else
        -- Default notification handling
    end
end
ProgressBar = function(duration, label)
    if Progress == "ox_lib_circle" then
        lib.progressCircle({
            duration = duration,
            label = label,
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            allowSwimming = true, 
            disable = { move = true, car = false, combat = true, },
        })
    elseif Progress == "ox_lib_bar" then
        lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = false,
            disable = { move = true, car = true, combat = true, },
        })
    elseif Progress == "qbcore" then
        QBCore.Functions.Progressbar(label, label, duration, false, false, { disableMovement = true, disableCarMovement = false, disableMouse = false, disableCombat = true, }, {}, {}, {}, function() end)
        Wait(duration)
    elseif Progress == "custom" then
        exports['progressBars']:startUI(duration, label)
    end
end
