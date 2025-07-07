if SERVER then
    -- Constants for health calculation
    local BASE_HEALTH = 3000
    local HEALTH_PER_PLAYER = 200
    local MIN_HEALTH = 5000
    local MAX_HEALTH = 23000
    
    -- Function to update player health based on model and player count
    local function UpdateHatmanHealth(ply)
        -- Check if player is using the Headless Hatman model
        if ply:GetModel() == "models/bots/headless_hatman.mdl" then
            -- Calculate health based on player count
            local playerCount = #player.GetAll()
            local calculatedHealth = BASE_HEALTH + (playerCount * HEALTH_PER_PLAYER)
            
            -- Enforce minimum and maximum health values
            calculatedHealth = math.max(calculatedHealth, MIN_HEALTH)
            calculatedHealth = math.min(calculatedHealth, MAX_HEALTH)
            
            -- Set the player's health
            ply:SetMaxHealth(calculatedHealth)
            ply:SetHealth(calculatedHealth)
        end
    end
    
    -- Hook for when a player spawns
    hook.Add("PlayerSpawn", "HeadlessHatmanHealthBoost", function(ply)
        -- Delay the check slightly to ensure the model is fully loaded
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateHatmanHealth(ply)
            end
        end)
    end)
    
    -- Hook for when a player changes model
    hook.Add("PlayerSetModel", "HeadlessHatmanHealthBoost", function(ply)
        -- Delay the check slightly to ensure the model is fully loaded
        timer.Simple(0.1, function()
            if IsValid(ply) then
                UpdateHatmanHealth(ply)
            end
        end)
    end)
    
    -- Hook for when a player joins or leaves to update health for all Hatman players
    hook.Add("PlayerInitialSpawn", "HeadlessHatmanHealthBoostPlayerCount", function()
        -- Update all players using the Hatman model
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:GetModel() == "models/bots/headless_hatman.mdl" then
                UpdateHatmanHealth(ply)
            end
        end
    end)
    
    hook.Add("PlayerDisconnected", "HeadlessHatmanHealthBoostPlayerCount", function()
        -- Wait a moment for the player to fully disconnect
        timer.Simple(0.1, function()
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and ply:GetModel() == "models/bots/headless_hatman.mdl" then
                    UpdateHatmanHealth(ply)
                end
            end
        end)
    end)
end