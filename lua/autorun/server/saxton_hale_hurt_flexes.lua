local HALE_MODELS = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/vip/player/julius/julius.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/vip_mobster/player/mobster.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true,
    ["models/saxton_hale_3.mdl"] = true,
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true
}

local activePainFlex = {}
local TRANSITION_TIME = 0.5

local function StartPainFlex(ply, flexName, intensity)
    if not IsValid(ply) then return end
    
    local flexID = ply:GetFlexIDByName(flexName)
    if not flexID then return end
    
    local startTime = CurTime()
    
    timer.Create("PainFlex_" .. ply:EntIndex() .. "_" .. flexName, 0, 0, function()
        if not IsValid(ply) then
            timer.Remove("PainFlex_" .. ply:EntIndex() .. "_" .. flexName)
            return
        end
        
        local progress = (CurTime() - startTime) / TRANSITION_TIME
        if progress >= 1 then
            ply:SetFlexWeight(flexID, 0)
            timer.Remove("PainFlex_" .. ply:EntIndex() .. "_" .. flexName)
            return
        end
        
        local weight = math.sin((1 - progress) * math.pi / 2) * intensity
        ply:SetFlexWeight(flexID, weight)
    end)
end

hook.Add("EntityTakeDamage", "HalePainFlexTrigger", function(target, dmginfo)
    if not IsValid(target) or not target:IsPlayer() or not HALE_MODELS[target:GetModel()] then return end
    
    local damage = dmginfo:GetDamage()
    target:SetFlexScale(1)
    
    if damage >= 50 then
        StartPainFlex(target, "painBig", 1)
    else
        StartPainFlex(target, "painSmall", 1)
    end
end)

hook.Add("PlayerSpawn", "HalePainFlexReset", function(ply)
    if not HALE_MODELS[ply:GetModel()] then return end
    
    local flexSmall = ply:GetFlexIDByName("painSmall")
    local flexBig = ply:GetFlexIDByName("painBig")
    
    if flexSmall then ply:SetFlexWeight(flexSmall, 0) end
    if flexBig then ply:SetFlexWeight(flexBig, 0) end
end)

hook.Add("PlayerDisconnected", "HalePainFlexCleanup", function(ply)
    timer.Remove("PainFlex_" .. ply:EntIndex() .. "_painSmall")
    timer.Remove("PainFlex_" .. ply:EntIndex() .. "_painBig")
end)