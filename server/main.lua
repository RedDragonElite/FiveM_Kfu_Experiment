ESX = exports["es_extended"]:getSharedObject()

-- Initialize Database
MySQL.query([[
    CREATE TABLE IF NOT EXISTS kungfu_stats (
        identifier VARCHAR(60) PRIMARY KEY,
        kicks_performed INT DEFAULT 0,
        hits_landed INT DEFAULT 0,
        damage_dealt INT DEFAULT 0,
        last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )
]])

-- Hit Registration Event
RegisterNetEvent('kungfu:hitRegistered')
AddEventHandler('kungfu:hitRegistered', function(targetId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(targetId)

    if xPlayer and xTarget then
        -- Update attacker stats
        MySQL.update('INSERT INTO kungfu_stats (identifier, kicks_performed, hits_landed, damage_dealt) VALUES (?, 1, 1, 25) ON DUPLICATE KEY UPDATE kicks_performed = kicks_performed + 1, hits_landed = hits_landed + 1, damage_dealt = damage_dealt + 25', {
            xPlayer.identifier
        })

        -- Notify target
        TriggerClientEvent('kungfu:receiveHit', targetId)

        -- Log the hit (optional)
        print(string.format("[Kung Fu System] Player %s landed a hit on %s", source, targetId))
    end
end)

-- Stats Command
RegisterCommand('kungfustats', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        MySQL.query('SELECT * FROM kungfu_stats WHERE identifier = ?', {
            xPlayer.identifier
        }, function(results)
            if results[1] then
                local stats = results[1]
                TriggerClientEvent('esx:showNotification', source, string.format(
                    'Kung Fu Stats:\nKicks: %d\nHits: %d\nDamage: %d',
                    stats.kicks_performed,
                    stats.hits_landed,
                    stats.damage_dealt
                ))
            else
                TriggerClientEvent('esx:showNotification', source, 'No Kung Fu statistics found!')
            end
        end)
    end
end)
