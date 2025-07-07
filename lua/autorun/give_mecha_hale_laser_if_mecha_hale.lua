local LASER_WEAPON = "weapon_MECHA_laser"
local MECHA_MODEL = "models/vsh/player/mecha_hale.mdl"
local READY_SOUND = "mvm/vsh_mecha/mecha_hale_new/laser_ready_01.mp3"
local COOLDOWN_TIME = 30 -- 30 seconds cooldown

local function GiveLaserWeapon(ply)
    -- Double-check player validity before giving weapon
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if ply:GetModel() ~= MECHA_MODEL then return end
    
    -- Make sure player doesn't already have the weapon
    if not ply:HasWeapon(LASER_WEAPON) then
        -- Safely give the weapon
        if ply.Give then
            ply:Give(LASER_WEAPON)
            ply:EmitSound(READY_SOUND)
        end
    end
end

local function StartLaserTimer(ply)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    
    if ply:GetModel() == MECHA_MODEL then
        local timerName = "MechaLaserTimer_" .. ply:SteamID64()
        
        -- Clear any existing timer
        if timer.Exists(timerName) then
            timer.Remove(timerName)
        end
        
        timer.Create(timerName, COOLDOWN_TIME, 1, function()
            -- Check if player is still valid when timer completes
            if IsValid(ply) and ply:IsPlayer() and ply:GetModel() == MECHA_MODEL then
                GiveLaserWeapon(ply)
            end
        end)
    end
end

-- Check player model and start initial timer
local function CheckPlayerModel(ply)
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    
    if ply:GetModel() == MECHA_MODEL then
        StartLaserTimer(ply)
    end
end

-- Hook for when player spawns
hook.Add("PlayerSpawn", "MechaHaleLaserCheck", function(ply)
    if not IsValid(ply) then return end
    
    -- Small delay to ensure model is set
    timer.Simple(1, function()
        if IsValid(ply) and ply:IsPlayer() then
            CheckPlayerModel(ply)
        end
    end)
end)

-- Hook for when player changes model
hook.Add("PlayerModelChanged", "MechaHaleLaserModelCheck", function(ply)
    if IsValid(ply) and ply:IsPlayer() then
        CheckPlayerModel(ply)
    end
end)

-- Hook for when weapon is removed
hook.Add("WeaponRemoved", "MechaHaleLaserRemoved", function(ply, wep)
    if not IsValid(ply) or not IsValid(wep) then return end
    if not ply:IsPlayer() then return end
    
    if wep:GetClass() == LASER_WEAPON and ply:GetModel() == MECHA_MODEL then
        StartLaserTimer(ply)
    end
end)

-- Periodically check if Mecha Hale players have lost their laser weapon
hook.Add("Think", "MechaHaleLaserInventoryCheck", function()
    if not timer.Exists("MechaHaleLaserChecker") then
        timer.Create("MechaHaleLaserChecker", 2, 1, function()
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and ply:IsPlayer() and ply:GetModel() == MECHA_MODEL then
                    -- If player doesn't have the laser weapon and no timer is running for them
                    if not ply:HasWeapon(LASER_WEAPON) and not timer.Exists("MechaLaserTimer_" .. ply:SteamID64()) then
                        StartLaserTimer(ply)
                    end
                end
            end
        end)
    end
end)

-- For replacing Mega Punch with Laser
hook.Add("Think", "MechaHaleReplacePunch", function()
    if not timer.Exists("MechaHalePunchReplacer") then
        timer.Create("MechaHalePunchReplacer", 2, 1, function()
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and ply:IsPlayer() and ply:GetModel() == MECHA_MODEL then
                    -- If player has Mega Punch but not Laser, replace it
                    if ply:HasWeapon("weapon_megapunch") and not ply:HasWeapon(LASER_WEAPON) then
                        ply:StripWeapon("weapon_megapunch")
                        GiveLaserWeapon(ply)
                    end
                end
            end
        end)
    end
end)

-- Initial check for all players when script loads
hook.Add("Initialize", "MechaHaleInitialCheck", function()
    timer.Simple(5, function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:IsPlayer() then
                CheckPlayerModel(ply)
            end
        end
    end)
end)