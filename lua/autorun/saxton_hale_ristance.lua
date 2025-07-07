local HALE_MODELS = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/saxton_hale_3.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/vsh/player/mecha_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true,
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true 
}

local DAMAGE_RESISTANCE = 0.25 -- 25% resistance
local DAMAGE_CAP = 60           -- Max damage cap
local DAMAGE_THRESHOLD = 70    -- Threshold for capping damage

-- Hook into player damage
hook.Add("EntityTakeDamage", "SaxtonHaleDamageResistance", function(target, dmg)
    if target:IsPlayer() and IsValid(target) then
        local playerModel = target:GetModel()
        
        if HALE_MODELS[playerModel] then
            local damage = dmg:GetDamage()
            
            -- Cap damage if above threshold
            if damage >= DAMAGE_THRESHOLD then
                damage = DAMAGE_CAP
            end
            
            -- Apply damage resistance
            local reducedDamage = damage * (1 - DAMAGE_RESISTANCE)
            dmg:SetDamage(reducedDamage)
        end
    end
end)