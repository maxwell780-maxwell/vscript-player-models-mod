local HALE_MODELS = {
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/vsh/player/mecha_hale.mdl"] = true,
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true,
    ["models/saxton_hale_3.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/bots/headless_hatman.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/vip_mobster/player/mobster.mdl"] = true,
    ["models/bots/vineyard_event/skeleton_sniper_mafia.mdl"] = true,
}

local prevGroundState = {}

-- Animation override hook
hook.Add("CalcMainActivity", "HaleSwimFix", function(ply, velocity)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local mdl = string.lower(ply:GetModel() or "")
    if not HALE_MODELS[mdl] then return end

    local waterLevel = ply:WaterLevel()
    local isOnGround = ply:IsOnGround()

    -- Detect landing and jumping
    if prevGroundState[ply] ~= nil and prevGroundState[ply] ~= isOnGround then
        if not isOnGround then
--            ply:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_MP_JUMP, true)
        else
            ply:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_LAND, true)
        end
    end

    prevGroundState[ply] = isOnGround

    if waterLevel <= 1 and not isOnGround then
        if velocity.z > 0 then
            -- Player moving upwards, use jump float
            return ACT_MP_JUMP_FLOAT, ply:SelectWeightedSequence(ACT_MP_JUMP_FLOAT)
        else
            -- Player falling or neutral, use airwalk
            return ACT_MP_AIRWALK, ply:SelectWeightedSequence(ACT_MP_AIRWALK)
        end
    end

    -- Otherwise let default activities happen
end)

-- Force playback rate to normal
hook.Add("UpdateAnimation", "HaleFixPlaybackRate", function(ply, velocity, maxSeqGroundSpeed)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local mdl = string.lower(ply:GetModel() or "")
    if not HALE_MODELS[mdl] then return end

    local waterLevel = ply:WaterLevel()
    local isOnGround = ply:IsOnGround()

    if waterLevel <= 1 and not isOnGround then
        ply:SetPlaybackRate(1)
    else
        ply:SetPlaybackRate(1)
    end
end)

-- Optional: Force model cache refresh on spawn
hook.Add("PlayerSpawn", "HaleModelCache", function(ply)
    timer.Simple(0, function()
        if IsValid(ply) then
            ply.HaleModelCached = string.lower(ply:GetModel() or "")
        end
    end)
end)