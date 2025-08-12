local QBX = exports.qbx_core

local savedCoords = {}
local frozenPlayers = {}

-- Register admin rank callback
lib.callback.register('donk_commands:server:getPlayersAdminRank', function(source)
    return IsPlayerAceAllowed(source, 'admin')
end)

-- Command: Bring a player to you
lib.addCommand('bring', {
    help = 'Bring a player to you (Admin only)',
    restricted = 'group.admin',
    params = {
        { name = 'id', help = 'Player ID', type = 'playerId' }
    }
}, function(source, args)
    local admin = GetPlayerPed(source)
    local coords = GetEntityCoords(admin)
    local target = GetPlayerPed(args.id)
    SetEntityCoords(target, coords)
    savedCoords[args.id] = GetEntityCoords(target)
end)

-- Command: Bring back a player
lib.addCommand('bringback', {
    help = 'Bring back a player (Admin only)',
    restricted = 'group.admin',
    params = {
        { name = 'id', help = 'Player ID', type = 'playerId' }
    }
}, function(source, args)
    local coords = savedCoords[args.id]
    if coords then
        local target = GetPlayerPed(args.id)
        SetEntityCoords(target, coords)
    end
end)

-- Command: Teleport to player
lib.addCommand('goto', {
    help = 'Teleport yourself to a player (Admin only)',
    restricted = 'group.admin',
    params = {
        { name = 'id', help = 'ID of player', type = 'number' }
    }
}, function(source, args)
    local targetId = args.id
    if GetPlayerPed(targetId) and GetPlayerPed(targetId) ~= 0 then
        local coords = GetEntityCoords(GetPlayerPed(targetId))
        TriggerClientEvent('donk_commands:client:teleportToPlayer', source, coords)
    else
        lib.notify({ id = source, description = 'This player is not online or invalid ID.', type = 'error' })
    end
end)

-- Command: Set ped model
lib.addCommand('setmodel', {
    help = 'Change Ped Model (Admin Only)',
    restricted = 'group.admin',
    params = {
        { name = 'model', help = 'Name of the model', type = 'string' },
        { name = 'id', help = 'Id of the Player (empty for yourself)', type = 'playerId', optional = true }
    }
}, function(source, args)
    if not args.model or args.model == '' then
        lib.notify({ id = source, description = 'Failed to set model', type = 'error' })
        return
    end

    local target = args.id or source
    local player = QBX:GetPlayer(target)
    if player then
        TriggerClientEvent('donk_commands:client:SetModel', target, args.model)
    else
        lib.notify({ id = source, description = 'Player not online', type = 'error' })
    end
end)

-- Command: Set ammo
lib.addCommand('setammo', {
    help = 'Set Your Ammo Amount (Admin Only)',
    restricted = 'group.admin',
    params = {
        { name = 'amount', help = 'Amount of bullets, for example: 20', type = 'number' },
        { name = 'reason', help = 'Reason for setting ammo', type = 'string' }
    }
}, function(source, args)
    if not args.amount or args.amount < 0 then
        lib.notify({ id = source, description = 'Invalid ammo amount.', type = 'error' })
        return
    end
    if not args.reason then
        lib.notify({ id = source, description = 'Provide a reason for setting ammo.', type = 'error' })
        return
    end
    TriggerClientEvent('donk_commands:client:SetWeaponAmmoManual', source, args.amount, args.reason)
end)

-- Command: Open clothing menu
lib.addCommand('clothing', {
    help = 'Government (Mod Only) - Open clothing menu',
    restricted = 'group.admin',
    params = {
        { name = 'id', help = 'Player ID', type = 'playerId', optional = true }
    }
}, function(source, args)
    local target = args.id or source
    local player = QBX:GetPlayer(target)
    if player then
        TriggerClientEvent('qb-clothing:client:openMenu', target)
    else
        lib.notify({ id = source, description = 'Player Not Online', type = 'error' })
    end
end)

-- Command: Warp into vehicle
lib.addCommand('warp', {
    help = 'Government (Mod Only) - Warp into vehicle',
    restricted = 'group.admin'
}, function(source)
    TriggerClientEvent('donk_commands:commands:warpinvehicle', source)
end)

-- Command: Freeze player
lib.addCommand('freeze', {
    help = 'Government (Admin Only) - Freeze or unfreeze a player',
    restricted = 'group.admin',
    params = {
        { name = 'id', help = 'Player ID', type = 'playerId' }
    }
}, function(source, args)
    local player = QBX:GetPlayer(args.id)
    if player then
        local targetSource = player.PlayerData.source
        local isCurrentlyFrozen = frozenPlayers[targetSource] or false
        local adminName = GetPlayerName(source)
        local targetName = player.PlayerData.name

        if not isCurrentlyFrozen then
            frozenPlayers[targetSource] = true
            TriggerClientEvent('donk_commands:client:freezePlayer', targetSource, true)
        else
            frozenPlayers[targetSource] = false
            TriggerClientEvent('donk_commands:client:freezePlayer', targetSource, false)
        end
    else
        lib.notify({ id = source, description = 'Player not online', type = 'error' })
    end
end)

-- Command: Max vehicle mods
lib.addCommand('maxmods', {
    help = 'Government (God Only) - Max Vehicle Mods',
    restricted = 'group.admin'
}, function(source)
    TriggerClientEvent('donk_commands:commands:maxmodVehicle', source)
end)

-- Command: Mute player voice
lib.addCommand('mutevoice', {
    help = 'Government (Mod Only) - Mute player voice',
    restricted = 'group.admin',
    params = {
        { name = 'id', help = 'Player ID', type = 'playerId' }
    }
}, function(source, args)
    local player = QBX:GetPlayer(args.id)
    if player then
        TriggerClientEvent('donk_commands:client:muteplayersVoice', player.PlayerData.source)
    else
        lib.notify({ id = source, description = 'Player Not Online', type = 'error' })
    end
end)

-- Command: Unmute player voice
lib.addCommand('unmutevoice', {
    help = 'Government (Mod Only) - Unmute player voice',
    restricted = 'group.admin',
    params = {
        { name = 'id', help = 'Player ID', type = 'playerId' }
    }
}, function(source, args)
    local player = QBX:GetPlayer(args.id)
    if player then
        TriggerClientEvent('donk_commands:client:unmuteplayersVoice', player.PlayerData.source)
    else
        lib.notify({ id = source, description = 'Player Not Online', type = 'error' })
    end
end)

-- Command: Clear world props
lib.addCommand('clearprops', {
    help = 'Government (Admin Only) - Clear world props',
    restricted = 'group.admin'
}, function(source)
    TriggerClientEvent('donk_commands:client:clearprops', -1)
end)

-- Command: Clear world peds
lib.addCommand('clearpeds', {
    help = 'Government (Admin Only) - Clear world peds',
    restricted = 'group.admin'
}, function(source)
    TriggerClientEvent('donk_commands:client:clearpeds', -1)
end)

-- Command: Clear world cars
lib.addCommand('clearcars', {
    help = 'Government (Admin Only) - Clear world cars',
    restricted = 'group.admin'
}, function(source)
    TriggerClientEvent('donk_commands:client:clearcars', -1)
end)

-- Command: Clear props (server-side)
lib.addCommand('serverclearprops', {
    help = 'Government (Admin Only) - Clear Props',
    restricted = 'group.admin'
}, function(source)
    local objects = GetAllObjects()
    if #objects > 0 then
        for _, obj in pairs(objects) do
            DeleteEntity(obj)
        end
    end
end)

-- Command: Revive all players in range
lib.addCommand('rr', {
    help = 'Revive all players in a range',
    restricted = 'group.admin',
    params = {
        { name = 'range', help = 'Radius to revive', type = 'number', optional = true }
    }
}, function(source, args)
    local range = args.range or 25.0
    local players = QBX:GetQBPlayers()
    local sourceCoords = GetEntityCoords(GetPlayerPed(source))
    for id, ply in pairs(players) do
        local targetCoords = GetEntityCoords(GetPlayerPed(id))
        if #(sourceCoords - targetCoords) <= range then
            TriggerClientEvent('hospital:client:Revive', id)
        end
    end
    lib.notify({ id = source, description = 'You\'ve successfully revived everyone within ' .. range .. ' meters.', type = 'success', duration = 5000 })
end)