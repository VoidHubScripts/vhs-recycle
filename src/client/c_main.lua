if Framework == 'esx' then ESX = exports["es_extended"]:getSharedObject() else QBCore = exports['qb-core']:GetCoreObject() end

local spawnedProps = {}
local spawnedNPCs = {}
local selectedProp = nil
local carriedProp = nil

function spawnProps()
    for _, propData in pairs(props) do
        local prop = propData.prop
        local loc = propData.loc
        local propObject = CreateObject(GetHashKey(prop), loc.x, loc.y, loc.z, false, true, false)
        SetEntityHeading(propObject, loc.w)
        FreezeEntityPosition(propObject, true)
        propData.object = propObject
        table.insert(spawnedProps, propObject)
    end
end

function createBlip(depot)
    local blip = AddBlipForCoord(depot.outside.zone.x, depot.outside.zone.y, depot.outside.zone.z)
    SetBlipSprite(blip, depot.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, depot.blip.size)
    SetBlipColour(blip, depot.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Recycling Depot")
    EndTextCommandSetBlipName(blip)
end

function spawnBin()
    local binModel = GetHashKey(depot.bin.prop)
    local loc = depot.bin.placement
    lib.requestModel(binModel, 10000)
    local binObject = CreateObject(binModel, loc.x, loc.y, loc.z, false, true, false)
    SetEntityHeading(binObject, loc.w)
    FreezeEntityPosition(binObject, true)
    depot.bin.object = binObject
    table.insert(spawnedProps, binObject)

    targetModel(binModel, 'reecyclebin', 'vhs-recycle:process', 'fas fa-trash-alt', 'Process Items', item, nil, interact, job, gang, distance)
    
end

Citizen.CreateThread(function()
    spawnNPC()
    spawnProps()
    createBlip(depot)
    spawnBin()
end)

function deleteProps()
    for _, propObject in ipairs(spawnedProps) do
        if DoesEntityExist(propObject) then
            DeleteObject(propObject)
        end
    end
end

function spawnNPC()
    local npcConfigs = { depot.npc, depot.sell }
    for _, npcData in pairs(npcConfigs) do
        local pedModel = GetHashKey(npcData.ped)
        lib.requestModel(pedModel, 10000)
        local npc = CreatePed(4, pedModel, npcData.zone.x, npcData.zone.y, npcData.zone.z, npcData.zone.w, false, true)
        TaskStartScenarioInPlace(npc, npcData.scenario, 0, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)
        table.insert(spawnedNPCs, npc)
    end
end

RegisterNetEvent('vhs-recycle:enter')
AddEventHandler('vhs-recycle:enter', function()
    local ped = PlayerPedId()
    RequestCollisionAtCoord(depot.inside.zone[1], depot.inside.zone[2], depot.inside.zone[3])
    SetEntityCoords(ped, depot.inside.zone[1], depot.inside.zone[2], depot.inside.zone[3] + 1.0, false, false, false, true)
    while not HasCollisionLoadedAroundEntity(ped) do
        Citizen.Wait(0)
    end
    SetEntityCoords(ped, depot.inside.zone[1], depot.inside.zone[2], depot.inside.zone[3], false, false, false, true)
    SetEntityHeading(ped, depot.inside.zone[4])
end)

RegisterNetEvent('vhs-recycle:exit')
AddEventHandler('vhs-recycle:exit', function()
    local ped = PlayerPedId()
    RequestCollisionAtCoord(depot.outside.zone[1], depot.outside.zone[2], depot.outside.zone[3])
    SetEntityCoords(ped, depot.outside.zone[1], depot.outside.zone[2], depot.outside.zone[3] + 1.0, false, false, false, true)
    while not HasCollisionLoadedAroundEntity(ped) do
        Citizen.Wait(0)
    end
    SetEntityCoords(ped, depot.outside.zone[1], depot.outside.zone[2], depot.outside.zone[3], false, false, false, true)
    SetEntityHeading(ped, depot.outside.zone[4])
end)


RegisterNetEvent('vhs-recycle:interact')
AddEventHandler('vhs-recycle:interact', function()
    local playerPed = PlayerPedId()
    local propPlacement = { vector3(0.025000, 0.080000, 0.255000), vector3(-145.000000, 290.000000, 0.000000) }
    lib.requestAnimDict('anim@heists@box_carry@', 500)
    lib.requestModel('hei_prop_heist_box', 10000)
    TaskPlayAnim(playerPed, 'anim@heists@box_carry@', 'idle', 8.0, -8.0, -1, 50, 0, false, false, false)
    carriedProp = CreateObject(GetHashKey('hei_prop_heist_box'), 0, 0, 0, true, true, true)
    AttachEntityToEntity(carriedProp, playerPed, GetPedBoneIndex(playerPed, 60309), propPlacement[1].x, propPlacement[1].y, propPlacement[1].z, propPlacement[2].x, propPlacement[2].y, propPlacement[2].z, true, true, false, true, 1, true)
end)

RegisterNetEvent('vhs-recycle:interactNPC')
AddEventHandler('vhs-recycle:interactNPC', function()
    lib.registerContext({
        id = 'npc_menu',
        title = '♻️ **Recycling Items**',
        options = { { title = 'Process Items (5x)', description = 'Process recycled 5x products', icon = 'recycle', event = 'vhs-recycle:iteemz', args = { amountToAdd = 5 }  },  { title = 'Process Items (10x)', description = 'Process recycled 10x products', icon = 'recycle', event = 'vhs-recycle:iteemz', args = { amountToAdd = 10 } } }
    })
    lib.showContext('npc_menu')
end)

RegisterNetEvent('vhs-recycle:interactsell')
AddEventHandler('vhs-recycle:interactsell', function()
    local menuOptions = lib.callback.await('vhs-recycle:sellmenu', false)
    if menuOptions then
        lib.registerContext({ id = 'sell_menu', title = '♻️ **Recycling Sell Items**', options = menuOptions })
        lib.showContext('sell_menu')
    end
end)

RegisterNetEvent('vhs-recycle:iteemz')
AddEventHandler('vhs-recycle:iteemz', function(data)
    local playerPed = PlayerPedId()
    local amountToAdd = data.amountToAdd
    lib.requestAnimDict('misscarsteal4@actor', 500)
    TaskPlayAnim(playerPed, 'misscarsteal4@actor', 'actor_berating_loop', 8.0, -8.0, -1, 50, 0, false, false, false)
    ProgressBar(5000, 'Processing Items')
    local giveitems = lib.callback.await('vhs-recycle:giveitems', false, amountToAdd)
    ClearPedTasksImmediately(playerPed)
    if giveitems then
        Notify("success", "Recycling Bin", amountToAdd .. " items processed successfully!")
    else
        Notify("error", "Recycling Bin", "Failed to process items!")
    end
end)

RegisterNetEvent('vhs-recycle:process')
AddEventHandler('vhs-recycle:process', function()
    local playerPed = PlayerPedId()
    if carriedProp and DoesEntityExist(carriedProp) then
        ClearPedTasksImmediately(playerPed)
        DeleteEntity(carriedProp)
        carriedProp = nil
        lib.requestAnimDict('mini@repair', 500)
        TaskPlayAnim(playerPed, 'mini@repair', 'fixing_a_ped', 8.0, -8.0, -1, 50, 0, false, false, false)
        ProgressBar(5000, 'Recycling Items')
        ClearPedTasksImmediately(playerPed)
        local added = lib.callback.await('vhs-recycle:processing', false)
        if added then
            Notify("success", "Recycling Bin", "Items processed successfully!", playerPed)
        else
            Notify("error", "Recycling Bin", "Failed to process items!", playerPed)
        end
    else
        Notify("info", "Recycling Bin", "You have nothing to process!", playerPed)
    end
end)

RegisterNetEvent('vhs-recycle:sellamount')
AddEventHandler('vhs-recycle:sellamount', function(data)
    local input = lib.inputDialog('Enter quantity to sell', {'Quantity'})
    if not input or not tonumber(input[1]) then
        Notify("info", "Invalid Amount", 'Please enter a valid amount')
        return
    end
    local quantity = math.floor(tonumber(input[1]))
    if quantity < 1 then
        Notify("info", "Invalid Amount", 'Please enter a valid amount')
        return
    end
    lib.callback.await('vhs-recycle:sellItem', 5000, { item = data.item, amount = quantity, price = data.price })
end)


function targetModel(model, name, event, icon, label, item, action, interact, job, gang, distance)
    local targetOptions = { name = name, icon = icon, label = label, distance = distance, items = item, groups = job,
        canInteract = function(entity, dist, coords, name, bone)
            return type(interact) == "function" and interact(entity, dist, coords, name, bone) or true
        end,
    }
    if event then
        targetOptions.event = event
    end
    if action then
        targetOptions.onSelect = function(data)
            if type(action) == "function" then
                action(data)
            end
        end
    end
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:addModel(model, { targetOptions })
    elseif GetResourceState('qb-target') == 'started' then
        local qbOptions = {
            options = {{ event = event, icon = icon, label = label, item = item, job = job, gang = gang,
                action = action and function(entity)
                    if type(action) == "function" then
                        action(entity)
                    end
                end or nil,
                canInteract = function(entity, dist, data)
                    return type(interact) == "function" and interact(entity, dist, data) or true
                end
            }},
            distance = distance
        }
        if not action then
            qbOptions.options[1].action = nil
        end
        if not event then
            qbOptions.options[1].event = nil
        end
        exports['qb-target']:AddTargetModel(model, qbOptions)
    else
        print('Neither ox_target nor qb-target is started.')
    end
end

function targetBox(name, coords, size, options, job, gang, distance, rotation, debug)
    if GetResourceState('ox_target') == 'started' then
        local oxSize = vector3(size[1], size[2], 2.0 + 9)
        local oxOptions = { { name = name, coords = coords, size = oxSize, rotation = rotation or 0, debug = debug or false, distance = distance or 2.0, options = {} } }
        for _, opt in ipairs(options) do
            table.insert(oxOptions[1].options, { event = opt.event, icon = opt.icon, label = opt.label, items = opt.item, groups = job,
                onSelect = function(data)
                    if opt.action and type(opt.action) == "function" then
                        opt.action(data)
                    end
                end,
                canInteract = function(entity, dist, zoneCoords, zoneName, bone)
                    if type(opt.canInteract) == "function" then
                        return opt.canInteract(entity, dist, zoneCoords, zoneName, bone)
                    end
                    return true
                end
            })
        end
        exports.ox_target:addBoxZone(oxOptions[1])
    elseif GetResourceState('qb-target') == 'started' then
        local qbOptions = {}
        for _, opt in ipairs(options) do
            table.insert(qbOptions, { event = opt.event, icon = opt.icon, label = opt.label, item = opt.item, job = job or 'all', gang = gang,
                action = function(entity)
                    if opt.action and type(opt.action) == "function" then
                        opt.action(entity)
                    end
                end,
                canInteract = function(entity, dist, data)
                    if type(opt.canInteract) == "function" then
                        return opt.canInteract(entity, dist, data)
                    end
                    return true
                end
            })
        end
        exports['qb-target']:AddBoxZone(name, coords, size[1], size[2], { name = name, heading = rotation or 0, debugPoly = debug or false, minZ = coords.z - 1.0, maxZ = coords.z + 1.0, }, { options = qbOptions, distance = distance or 2.0 })
    else
        print('Neither ox_target nor qb-target is started.')
    end
end

targetModel(depot.npc.ped, 'npc', 'vhs-recycle:interactNPC', 'fas fa-hand', 'Open Recycle Menu', item, nil, interact, job, gang, distance)
targetModel(depot.sell.ped, 'sell', 'vhs-recycle:interactsell', 'fas fa-hand', 'Sell Items', nil, nil, interact,  job, gang, distance)

targetBox('outside', depot.outside.zone, {3.5, 5.5}, { { icon = 'fas fa-door-open', label = 'Enter Depot',  action = function(entity) TriggerEvent('vhs-recycle:enter')  end }, }, job, gang, distance, rotation, false)
targetBox('exit', depot.exit.zone, {1.5, 1.3}, { { icon = 'fas fa-door-open', label = 'Exit Warehouse',  action = function(entity) TriggerEvent('vhs-recycle:exit')  end }, }, job, gang, distance, rotation, false)
targetBox('duty', depot.duty.zone, {1, 1}, { { icon = 'fas fa-door-open', label = 'Start Working',  action = function(entity) TriggerEvent('vhs-recycle:start')  end }, }, job, gang, distance, rotation, false)


RegisterNetEvent('vhs-recycle:start')
AddEventHandler('vhs-recycle:start', function()
    for _, propData in pairs(props) do
        if DoesEntityExist(propData.object) then
            local model = GetHashKey(propData.prop)
            targetModel(model, 'interact', 'vhs-recycle:interact', 'fas fa-hand', 'Take Items', nil, nil, interact,  job, gang, distance)
        end
    end
end)

