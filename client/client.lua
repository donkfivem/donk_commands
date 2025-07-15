-- Import required modules
local QBX = exports.qbx_core
local PlayerData = QBX:GetPlayerData()

-- Update PlayerData when player loads
AddEventHandler('qbx_core:client:onPlayerLoaded', function()
    PlayerData = QBX:GetPlayerData()
end)

local blockedPeds = {
    "mp_m_freemode_01",
    "mp_f_freemode_01",
}

--- Functions
local function LoadPlayerModel(skin)
    RequestModel(skin)
    while not HasModelLoaded(skin) do
        Wait(0)
    end
end

local function isPedAllowedRandom(skin)
    local retval = false
    for _, v in pairs(blockedPeds) do
        if v ~= skin then
            retval = true
        end
    end
    return retval
end

-- Set player model
RegisterNetEvent('donk_commands:client:SetModel', function(skin)
    local ped = PlayerPedId()
    local model = GetHashKey(skin)
    SetEntityInvincible(ped, true)

    if IsModelInCdimage(model) and IsModelValid(model) then
        LoadPlayerModel(model)
        SetPlayerModel(PlayerId(), model)

        if isPedAllowedRandom(skin) then
            SetPedRandomComponentVariation(ped, true)
        end

        SetModelAsNoLongerNeeded(model)
    end
    SetEntityInvincible(ped, false)
end)

-- Set weapon ammo
RegisterNetEvent('donk_commands:client:SetWeaponAmmoManual', function(ammo, reason)
    local ped = PlayerPedId()
    local weaponHash = GetSelectedPedWeapon(ped)

    if weaponHash == `WEAPON_UNARMED` then
        lib.notify({ description = "You currently have no weapon", type = 'error' })
        return
    end

    SetPedAmmo(ped, weaponHash, ammo)
    lib.notify({ description = "Your ammo was set to " .. ammo .. " (native, may desync with inventory)", type = 'success' })
end)

-- Warp into vehicle
RegisterNetEvent('donk_commands:commands:warpinvehicle', function()
    local vehicle = QBX:GetClosestVehicle()
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    exports.wasabi_carlock:GiveKey(vehicle)
end)

-- Performance upgrade for vehicle
local performanceModIndices = { 11, 12, 13, 15, 16 }
function PerformanceUpgradeVehicle(vehicle, customWheels)
    customWheels = customWheels or false
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        SetVehicleModKit(vehicle, 0)
        for _, modType in ipairs(performanceModIndices) do
            local max = GetNumVehicleMods(vehicle, tonumber(modType)) - 1
            SetVehicleMod(vehicle, modType, max, customWheels)
        end
        ToggleVehicleMod(vehicle, 18, true) -- Turbo
        SetVehicleFixed(vehicle)
    end
end

RegisterNetEvent('donk_commands:commands:maxmodVehicle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    PerformanceUpgradeVehicle(vehicle)
end)

-- Get vehicle model from hash
local function getVehicleFromVehList(hash)
    for _, v in pairs(QBX:GetVehiclesByName()) do
        if hash == v.hash then
            return v.model
        end
    end
end

-- Save car
RegisterNetEvent('donk_commands:client:SaveCar', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)

    if veh ~= nil and veh ~= 0 then
        local plate = qbx.getVehiclePlate(veh)
        local props = QBX:GetVehicleProperties(veh)
        local hash = props.model
        local vehname = getVehicleFromVehList(hash)
        local vehicles = QBX:GetVehiclesByName()
        if vehicles[vehname] ~= nil and next(vehicles[vehname]) ~= nil then
            TriggerServerEvent('donk_commands:server:SaveCar', props, vehicles[vehname], GetHashKey(veh), plate)
        else
            lib.notify({ description = 'Vehicle cannot be stored in garage', type = 'error' })
        end
    else
        lib.notify({ description = 'No vehicle found', type = 'error' })
    end
end)

-- Mute/unmute voice
RegisterNetEvent('donk_commands:client:muteplayersVoice', function()
    local player = PlayerPedId()
    exports['pma-voice']:overrideProximityCheck(function()
        return false
    end)
end)

RegisterNetEvent('donk_commands:client:unmuteplayersVoice', function()
    exports['pma-voice']:resetProximityCheck()
end)

-- Entity enumeration functions
local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end

        local enum = { handle = iter, destructor = disposeFunc }
        setmetatable(enum, entityEnumerator)

        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

-- Clear props
RegisterNetEvent('donk_commands:client:clearprops', function()
    local rank = lib.callback.await('donk_commands:server:getPlayersAdminRank', false)
    if rank then
        for object in EnumerateObjects() do
            if IsEntityAnObject(object) then
                SetEntityAsMissionEntity(object, false, false)
                DeleteEntity(object)
                if DoesEntityExist(object) then
                    DeleteEntity(object)
                end
            end
        end
    end
end)

-- Clear peds
RegisterNetEvent('donk_commands:client:clearpeds', function()
    local rank = lib.callback.await('donk_commands:server:getPlayersAdminRank', false)
    if rank then
        for ped in EnumeratePeds() do
            if not IsPedAPlayer(ped) then
                SetEntityAsMissionEntity(ped, false, false)
                DeleteEntity(ped)
                if DoesEntityExist(ped) then
                    DeleteEntity(ped)
                end
            end
        end
    end
end)

-- Clear vehicles
RegisterNetEvent('donk_commands:client:clearcars', function()
    local rank = lib.callback.await('donk_commands:server:getPlayersAdminRank', false)
    if rank then
        for vehicle in EnumerateVehicles() do
            if not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) then
                SetVehicleHasBeenOwnedByPlayer(vehicle, false)
                SetEntityAsMissionEntity(vehicle, false, false)
                DeleteVehicle(vehicle)
                if DoesEntityExist(vehicle) then
                    DeleteVehicle(vehicle)
                end
            end
        end
    end
end)

-- Freeze player
RegisterNetEvent('donk_commands:client:freezePlayer', function(freeze)
    local ped = PlayerPedId()
    if freeze then
        FreezeEntityPosition(ped, true)
        lib.notify({ description = 'You have been frozen by an admin.', type = 'inform' })
    else
        FreezeEntityPosition(ped, false)
        lib.notify({ description = 'You have been unfrozen by an admin.', type = 'success' })
    end
end)

-- Teleport to player
RegisterNetEvent('donk_commands:client:teleportToPlayer', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
end)

-- Teleport to coordinates
RegisterNetEvent('donk_commands:client:teleportToCoords', function(x, y, z)
    local ped = PlayerPedId()
    SetEntityCoords(ped, x, y, z)
end)