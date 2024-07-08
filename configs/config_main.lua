Config = Config or {}     

Framework = 'esx' -- esx, qbcore 
Notifications = 'ox_lib'  -- qbcore, esx, ox_lib
Progress = 'ox_lib_circle' -- ox_lib_circle, ox_lib_bar, qbcore
InventoryImagePath = "nui://ox_inventory/web/images/"

giveItemAmount = math.random(2,5)
items = {steel = 5, rubber = 3, metalscrap = 6, plastic = 3, copper = 10, fabric = 4}

depot = {
    npc = {zone = vector4(1090.5276, -3103.3540, -39.9999, 357.3629), ped = 'a_m_m_farmer_01', scenario = 'WORLD_HUMAN_CLIPBOARD_FACILITY'}, 
    sell = {zone = vector4(37.3948, -1288.4828, 28.2922, 291.4622), ped = 'a_m_m_soucent_02', scenario = 'WORLD_HUMAN_STAND_MOBILE'},

    blip = { sprite = 728, color = 2, size = 1.0 },
    outside = { zone = vector4(36.3291, -1283.9606, 29.2956, 89.5190), 
        minZ = 2.5, 
        maxZ = 4.5
    }, 
    inside = {
        zone = vector4(1088.0067, -3099.5161, -39.0000, 277.3064) 
    }, 
    exit = { 
        zone = vector3(1087.4320, -3099.3901, -38.9999), 
        h = 89.7790, 
        minZ = 1.5, 
        maxZ = 3.5
    },
    duty = { zone = vector3(1087.9154, -3101.2112, -39.1759), 
        h = 119.7421, 
        minZ = 1.5, 
        maxZ = 2.0
    },
    bin = {prop = 'prop_recyclebin_05_a', placement = vector4(1096.2809, -3102.6228, -39.9999, 178.2123)},
}

props = { 
    prop1 = { prop = 'sm_prop_smug_crate_l_fake', loc = vector4(1088.7007, -3096.2437, -40.0000, 1.8227) }, 
    prop2 = { prop = 'ba_prop_battle_crate_art_02_bc', loc = vector4(1091.2141, -3096.6941, -39.9999, 357.8739) }, 
    prop3 = { prop = 'ex_prop_crate_narc_bc', loc = vector4(1095.0951, -3096.8997, -39.9999, 357.5524) }, 
    prop4 = { prop = 'ex_prop_crate_wlife_bc', loc = vector4(1097.7412, -3097.0847, -39.9999, 0.8478) }, 
    prop5 = { prop = 'ex_prop_crate_clothing_sc', loc = vector4(1101.3965, -3096.7812, -39.9999, 356.3791) }, 
    prop6 = { prop = 'ex_prop_crate_art_02_sc', loc = vector4(1103.9249, -3096.8760, -39.9999, 356.1726) }, 
}


