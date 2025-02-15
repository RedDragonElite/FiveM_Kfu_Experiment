local isKungFuActive = false
local cooldown = false
local cooldownTime = 500 -- how fast can u kick after a kick
local kickForce = 17.66 -- POWER of kick
local kickRange = 2.8 -- How near needs the ped to be ..

lib.registerMenu({
    id = 'kungfu_menu',
    title = 'Kung Fu Controls',
    position = 'top-right',
    options = {
        {label = 'Toggle Kung Fu Mode', description = 'Activate/Deactivate Kung Fu'},
    }
})

RegisterCommand('kungfu', function()
    isKungFuActive = not isKungFuActive
    if isKungFuActive then
        lib.notify({
            title = 'Kung Fu Mode',
            description = 'Activated',
            type = 'success'
        })
    else
        lib.notify({
            title = 'Kung Fu Mode',
            description = 'Deactivated',
            type = 'error'
        })
    end
end)

local function PlayKickAnimation(ped)
    local dict = "melee@unarmed@streamed_core_fps"
    local anim = "kick_close_a"

    if not lib.requestAnimDict(dict, 1000) then return false end

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, 1000, 0, 0, false, false, false)
    return true
end

local function KickTarget(targetPed)
    if cooldown then return end

    local ped = PlayerPedId()
    local pedPos = GetEntityCoords(ped)
    local targetPos = GetEntityCoords(targetPed)

    local angle = GetHeadingFromVector_2d(targetPos.x - pedPos.x, targetPos.y - pedPos.y)
    SetEntityHeading(ped, angle)

    if not PlayKickAnimation(ped) then
        lib.notify({
            title = 'Animation Error',
            description = 'Failed to load animation',
            type = 'error'
        })
        return
    end

    -- Wait for the right moment in the kick
    Wait(750) -- Time of the animation entry or solid

    local dx = targetPos.x - pedPos.x
    local dy = targetPos.y - pedPos.y
    local dz = targetPos.z - pedPos.z

    local length = math.sqrt(dx * dx + dy * dy + dz * dz)
    local nx = dx / length
    local ny = dy / length

    SetPedToRagdoll(targetPed, 2000, 2000, 0, true, true, false)

    ApplyForceToEntity(targetPed, 1,
        nx * kickForce,
        ny * kickForce,
        3.0,
        0.0, 0.0, 0.0, 0, false, true, true, false, true)

    ApplyDamageToPed(targetPed, 5, false) -- from 30 lowered to 5. Maybe more fun

    cooldown = true
    SetTimeout(cooldownTime, function()
        cooldown = false
    end)

    TriggerServerEvent('kungfu:hitRegistered', GetPlayerServerId(targetPed))
end

CreateThread(function()
    while true do
        Wait(0)
        if isKungFuActive and IsControlPressed(0, 25) then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            local closestPed = lib.getClosestPed(coords, kickRange, true) -- true to include players
            if closestPed and not IsPedDeadOrDying(closestPed) then
                KickTarget(closestPed)
            end
        end
    end
end)

exports.ox_target:addGlobalPlayer({
    {
        name = 'kungfu_kick',
        icon = 'fa-solid fa-hand-fist',
        label = 'Kung Fu Kick',
        canInteract = function(entity, distance)
            return isKungFuActive and not cooldown and distance <= kickRange
        end,
        onSelect = function(entity)
            KickTarget(entity)
        end
    }
})
