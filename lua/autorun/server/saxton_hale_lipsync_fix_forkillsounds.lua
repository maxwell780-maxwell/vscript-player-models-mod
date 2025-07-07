local HALE_MODELS = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true
}

-- Kill sounds list (replacing jump sounds with kill sounds)
local SAXTON_SOUNDS = {
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_01.mp3"] = 1.7,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_02.mp3"] = 1.7,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_03.mp3"] = 3.7,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_04.mp3"] = 3.1,
    ["mvm/saxton_hale_karijini/kill_generic_02.mp3"] = 3.2,
    ["mvm/saxton_hale_karijini/kill_generic_01.mp3"] = 1.5,
    ["mvm/saxton_hale_karijini/kill_generic_03.mp3"] = 3.1,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_05.mp3"] = 2.8,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_06.mp3"] = 2.5,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_07.mp3"] = 2.1,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_08.mp3"] = 1.8,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_09.mp3"] = 2.4,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_10.mp3"] = 2.4,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_11.mp3"] = 1.9,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_12.mp3"] = 1.8,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_13.mp3"] = 2.5,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_14.mp3"] = 2.5,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_15.mp3"] = 2.5,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_16.mp3"] = 4.5,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_17.mp3"] = 4.6,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_18.mp3"] = 5.4,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_19.mp3"] = 2.2,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_20.mp3"] = 2.0,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_21.mp3"] = 3.6,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_22.mp3"] = 3.6,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_23.mp3"] = 3.6,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_24.mp3"] = 2.3,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_25.mp3"] = 2.3,
    ["mvm/saxton_hale_by_matthew_simmons/kill_generic_26.mp3"] = 2.5
}

local hasDoubleJumped = {}
local soundPlayed = {}

local function GetPlayerRagdoll(ply)
    local ragdolls = ents.FindByClass("prop_ragdoll")
    for _, rag in ipairs(ragdolls) do
        if rag:GetOwner() == ply then
            return rag
        end
    end
    return nil
end

local function StartSilentFlex(ply)
    local flexIDSilence = ply:GetFlexIDByName("silence")
    local startTime = CurTime()
    local duration = 1.5
    
    hook.Add("Think", "SaxtonSilentFlex_" .. ply:EntIndex(), function()
        if not IsValid(ply) then
            hook.Remove("Think", "SaxtonSilentFlex_" .. ply:EntIndex())
            return
        end
        
        local targetEnt = ply:Alive() and ply or GetPlayerRagdoll(ply)
        if not IsValid(targetEnt) then return end
        
        local progress = (CurTime() - startTime) / duration
        if progress >= 1 then
            if flexIDSilence then
                targetEnt:SetFlexWeight(flexIDSilence, 0)
            end
            hook.Remove("Think", "SaxtonSilentFlex_" .. ply:EntIndex())
            return
        end
        
        if flexIDSilence then
            local weight = Lerp(progress, 1, 0)
            targetEnt:SetFlexWeight(flexIDSilence, weight)
        end
    end)
end

local function StartLipSync(ply, duration)
    local flexIDAH = ply:GetFlexIDByName("AH")
    local startTime = CurTime()
    local endTime = startTime + duration
    
    hook.Add("Think", "SaxtonLipSync_" .. ply:EntIndex(), function()
        if not IsValid(ply) then
            hook.Remove("Think", "SaxtonLipSync_" .. ply:EntIndex())
            return
        end
        
        local targetEnt = ply:Alive() and ply or GetPlayerRagdoll(ply)
        if not IsValid(targetEnt) then return end
        
        if CurTime() > endTime then
            if flexIDAH then
                targetEnt:SetFlexWeight(flexIDAH, 0)
            end
            hook.Remove("Think", "SaxtonLipSync_" .. ply:EntIndex())
            return
        end
        
        if flexIDAH then
            local flexWeight = math.abs(math.sin(CurTime() * 12)) * 0.7
            targetEnt:SetFlexWeight(flexIDAH, flexWeight)
        end
    end)
end

hook.Add("EntityEmitSound", "SaxtonTrackKillSounds", function(data)
    local ent = data.Entity
    if IsValid(ent) and ent:IsPlayer() and SAXTON_SOUNDS[data.SoundName] then
        soundPlayed[ent] = true
        StartLipSync(ent, SAXTON_SOUNDS[data.SoundName])
    end
end)

hook.Add("KeyPress", "SaxtonLipSyncDoubleJump", function(ply, key)
    if not HALE_MODELS[ply:GetModel()] then return end
    
    if key == IN_JUMP then
        if not ply:IsOnGround() and not hasDoubleJumped[ply] then
            hasDoubleJumped[ply] = true
            
            timer.Simple(0.1, function()
                if IsValid(ply) and not soundPlayed[ply] then
                    StartSilentFlex(ply)
                end
            end)
            
            soundPlayed[ply] = false
        elseif ply:IsOnGround() then
            hasDoubleJumped[ply] = false
        end
    end
end)

hook.Add("PlayerSpawn", "SaxtonLipSyncReset", function(ply)
    hasDoubleJumped[ply] = false
    soundPlayed[ply] = false
end)

hook.Add("PlayerDisconnected", "SaxtonLipSyncCleanup", function(ply)
    hasDoubleJumped[ply] = nil
    soundPlayed[ply] = nil
    hook.Remove("Think", "SaxtonLipSync_" .. ply:EntIndex())
    hook.Remove("Think", "SaxtonSilentFlex_" .. ply:EntIndex())
end)
