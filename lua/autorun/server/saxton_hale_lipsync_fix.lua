local HALE_MODELS = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true,
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true
}

local SAXTON_SOUNDS = {
    ["mvm/saxton_hale_by_matthew_simmons/jump_01.mp3"] = 1.5,--flex timers for lipsync to stop :)
    ["mvm/saxton_hale_by_matthew_simmons/jump_02.mp3"] = 1.0,
    ["mvm/saxton_hale_by_matthew_simmons/jump_03.mp3"] = 1.0,
    ["mvm/saxton_hale_by_matthew_simmons/jump_04.mp3"] = 0.5,
    ["mvm/saxton_hale_by_matthew_simmons/jump_05.mp3"] = 0.5,
    ["mvm/saxton_hale_by_matthew_simmons/jump_06.mp3"] = 0.5,
    ["mvm/saxton_hale_by_matthew_simmons/jump_07.mp3"] = 0.5,
    ["mvm/saxton_hale_by_matthew_simmons/jump_08.mp3"] = 1.0,
    ["mvm/saxton_hale_by_matthew_simmons/jump_09.mp3"] = 1.4,
    ["mvm/saxton_hale_by_matthew_simmons/jump_10.mp3"] = 1.0,
    ["mvm/hellfire_hale_matthew_simmons2/jump_01.mp3"] = 1.0,
    ["mvm/hellfire_hale_matthew_simmons2/jump_02.mp3"] = 1.0,
    ["mvm/hellfire_hale_matthew_simmons2/jump_03.mp3"] = 1.0,
    ["mvm/hellfire_hale_matthew_simmons2/jump_04.mp3"] = 0.5,
    ["mvm/hellfire_hale_matthew_simmons2/jump_05.mp3"] = 0.5,
    ["mvm/hellfire_hale_matthew_simmons2/jump_06.mp3"] = 0.5,
    ["mvm/hellfire_hale_matthew_simmons2/jump_07.mp3"] = 0.5,
    ["mvm/hellfire_hale_matthew_simmons2/jump_08.mp3"] = 1.0,
    ["mvm/hellfire_hale_matthew_simmons2/jump_09.mp3"] = 1.4,
    ["mvm/hellfire_hale_matthew_simmons2/jump_10.mp3"] = 1.5
}

local hasDoubleJumped = {}
local soundPlayed = {}

local function GetPlayerRagdoll(ply) --keeping this code in case somthing bad happens
    local ragdolls = ents.FindByClass("prop_ragdoll")
    for _, rag in ipairs(ragdolls) do
        if rag:GetOwner() == ply then
            return rag
        end
    end
    return nil
end

local function StartSilentFlex(ply) --the real juicy stuff on how saxton can well lip sync idk why lizard of Oz does not want to make saxton lip sync this is me proving my point of why lip syncing is good and tf2 has lip sync for the mercs why must i do everything myself and throw a fit about it?
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

hook.Add("EntityEmitSound", "SaxtonTrackJumpSounds", function(data)
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
