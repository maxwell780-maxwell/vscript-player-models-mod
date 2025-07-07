local HALE_MODELS = {
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true,
}

local SAXTON_SOUNDS = { --that did not took long i swear =) im not going mentaly insane i swear
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_01.mp3"] = 1.7,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_02.mp3"] = 1.7,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_03.mp3"] = 3.7,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_04.mp3"] = 3.1,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_05.mp3"] = 2.8,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_06.mp3"] = 2.5,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_07.mp3"] = 2.1,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_08.mp3"] = 1.8,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_09.mp3"] = 2.4,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_10.mp3"] = 2.4,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_11.mp3"] = 1.9,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_12.mp3"] = 1.8,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_13.mp3"] = 2.4,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_14.mp3"] = 2.5,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_15.mp3"] = 2.5,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_16.mp3"] = 4.5,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_17.mp3"] = 4.6,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_18.mp3"] = 5.4,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_19.mp3"] = 2.2,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_20.mp3"] = 2.0,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_21.mp3"] = 3.6,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_22.mp3"] = 3.6,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_23.mp3"] = 3.6,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_24.mp3"] = 2.3,
    ["mvm/hellfire_hale_matthew_simmons2/kill_generic_25.mp3"] = 2.3,
    ["mvm/hellfire_hale_new_lines2/kill_generic_01.mp3"] = 2.8,
    ["mvm/hellfire_hale_new_lines2/kill_generic_02.mp3"] = 2.4,
    ["mvm/hellfire_hale_new_lines2/kill_generic_03.mp3"] = 3.0
}

local hasDoubleJumped = {}
local soundPlayed = {}

local function GetPlayerRagdoll(ply)
    for _, rag in ipairs(ents.FindByClass("prop_ragdoll")) do
        if rag:GetOwner() == ply then return rag end
    end
    return nil
end

local function StartLipSync(ply, duration)
    local flexIDAH = ply:GetFlexIDByName("AH")
    local startTime = CurTime()
    local endTime = startTime + duration

    hook.Add("Think", "HellHaleLipSync_" .. ply:EntIndex(), function()
        if not IsValid(ply) then
            hook.Remove("Think", "HellHaleLipSync_" .. ply:EntIndex())
            return
        end
        local targetEnt = ply:Alive() and ply or GetPlayerRagdoll(ply)
        if not IsValid(targetEnt) then return end
        if CurTime() > endTime then
            if flexIDAH then targetEnt:SetFlexWeight(flexIDAH, 0) end
            hook.Remove("Think", "HellHaleLipSync_" .. ply:EntIndex())
            return
        end
        if flexIDAH then
            targetEnt:SetFlexWeight(flexIDAH, math.abs(math.sin(CurTime() * 12)) * 0.7)
        end
    end)
end

hook.Add("EntityEmitSound", "HellHaleTrackKillSounds", function(data)
    local ent = data.Entity
    if IsValid(ent) and ent:IsPlayer() and SAXTON_SOUNDS[data.SoundName] then
        soundPlayed[ent] = true
        StartLipSync(ent, SAXTON_SOUNDS[data.SoundName])
    end
end)

hook.Add("PlayerSpawn", "HellHaleLipSyncReset", function(ply)
    hasDoubleJumped[ply] = false
    soundPlayed[ply] = false
end)

hook.Add("PlayerDisconnected", "HellHaleLipSyncCleanup", function(ply)
    hasDoubleJumped[ply] = nil
    soundPlayed[ply] = nil
    hook.Remove("Think", "HellHaleLipSync_" .. ply:EntIndex())
end)