hook.Add("PlayerSpawn", "oldalphaJuliusVIPHealthBonus", function(ply)
    -- Wait a tick to ensure the player model is set
    timer.Simple(0.1, function()
        if IsValid(ply) and ply:GetModel() == "models/vip/player/civilian/julius.mdl" then
            ply:SetHealth(175)
            ply:SetMaxHealth(175)
        end
    end)
end)

-- Also check when a player changes their model
hook.Add("PlayerModelChanged", "oldalphaJuliusVIPHealthBonusModelChange", function(ply)
    if IsValid(ply) and ply:GetModel() == "models/vip/player/civilian/julius.mdl" then
        ply:SetHealth(175)
        ply:SetMaxHealth(175)
    else
        -- Reset to default health if they change away from the VIP model
        ply:SetMaxHealth(100)
        -- Only set current health to 100 if it's higher than 100
        if ply:Health() > 100 then
            ply:SetHealth(100)
        end
    end
end)
