local saxtonModels = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true,
    ["models/vsh/player/hell_hale.mdl"] = true
}

local punchVoiceLines = {
    ["models/player/saxton_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_04.mp3"
    },
    ["models/subzero_saxton_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_04.mp3"
    },
    ["models/vsh/player/saxton_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_04.mp3"
    },
    ["models/vsh/player/santa_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_04.mp3"
    },
    ["models/vsh/player/winter/saxton_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_04.mp3"
    },
    ["models/player/hell_hale.mdl"] = {
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_01.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_02.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_03.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_04.mp3"
    },
    ["models/vsh/player/hell_hale.mdl"] = {
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_01.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_02.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_03.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_04.mp3"
    }
}

local INTENSITY = 1.0 -- max flex weight

-- Cooldown to prevent sound spam
local playerCooldowns = {}
local COOLDOWN_TIME = 0.5 -- Half second cooldown between sounds

-- Lip sync data
local lipSyncData = {}
local FLEX_NAME = "AIY"
local FLEX_CYCLE_TIME = 0.4 -- Time to complete one lip movement cycle (up and down)
local EXTRA_LIP_SYNC_TIME = 0.5 -- Extra time to continue lip sync after sound ends

-- Track player attack animations
local playerAttackStates = {}

-- Maximum distance for punch voice lines to play
local MAX_PUNCH_DISTANCE = 120 * 120 -- Squared distance for performance (20 units)

-- Precache all sounds
hook.Add("Initialize", "SaxtonHalePrecacheSounds", function()
    for _, sounds in pairs(punchVoiceLines) do
        for _, sound in ipairs(sounds) do
            util.PrecacheSound(sound)
        end
    end
end)

-- Function to play a random punch voice line
local function PlayPunchVoiceLine(ply, model)
    if not punchVoiceLines[model] then return end
    
    local currentTime = CurTime()
    if playerCooldowns[ply:SteamID()] and currentTime < playerCooldowns[ply:SteamID()] then
        return -- Still on cooldown
    end
    
    -- Set cooldown
    playerCooldowns[ply:SteamID()] = currentTime + COOLDOWN_TIME
    
    -- Get random voice line for this model
    local voiceLines = punchVoiceLines[model]
    local randomSound = voiceLines[math.random(#voiceLines)]
    
    -- Get sound duration
    local soundDuration = SoundDuration(randomSound) or 1.5
    
    -- Add extra time to lip sync duration
    local lipSyncDuration = soundDuration + EXTRA_LIP_SYNC_TIME
    
    -- Play the sound
    ply:EmitSound(randomSound, 75, 100, 1)
    
    -- Set up lip sync data
    if CLIENT then
        lipSyncData[ply:EntIndex()] = {
            startTime = currentTime,
            endTime = currentTime + lipSyncDuration,
            lastCycleTime = currentTime,
            soundEndTime = currentTime + soundDuration
        }
    end
    
    -- Send to clients for lip sync
    if SERVER then
        net.Start("SaxtonHaleLipSync")
        net.WriteEntity(ply)
        net.WriteFloat(soundDuration)
        net.WriteFloat(lipSyncDuration)
        net.Broadcast()
    end
end

-- Check if player is using the Saxton Hale SWEP
local function IsUsingSaxtonHaleSWEP(ply)
    local weapon = ply:GetActiveWeapon()
    return IsValid(weapon) and weapon:GetClass() == "weapon_saxton_hale_swep"
end

-- Check if player model is a Saxton Hale model and has the right skin
local function IsSaxtonHaleWithCorrectSkin(ply)
    local model = ply:GetModel()
    local skin = ply:GetSkin()
    
    if not saxtonModels[model] then return false end
    
    -- Check if skin is 2 or 4
    return skin == 2 or skin == 4
end

-- Check if the player's viewmodel is playing the critical swing animation
local function IsPlayingCritSwingAnimation(ply)
    if CLIENT then
        local vm = ply:GetViewModel()
        if IsValid(vm) then
            local seq = vm:GetSequenceName(vm:GetSequence())
            return seq == "bg_swing_crit"
        end
    end
    return false
end

-- Check if target is within range
local function IsTargetInRange(attacker, target)
    if not IsValid(attacker) or not IsValid(target) then return false end
    
    -- Get positions
    local attackerPos = attacker:GetPos()
    local targetPos = target:GetPos()
    
    -- Calculate squared distance (more efficient than using Distance)
    local distSqr = attackerPos:DistToSqr(targetPos)
    
    -- Check if within range
    return distSqr <= MAX_PUNCH_DISTANCE
end

-- Track player attack animations
hook.Add("SetupMove", "SaxtonHaleTrackAttacks", function(ply, mv, cmd)
    if not IsValid(ply) then return end
    
    -- Check if player is in attack animation
    if ply:GetSequenceActivity(ply:GetSequence()) == ACT_MP_ATTACK_STAND_PRIMARYFIRE then
        playerAttackStates[ply:EntIndex()] = CurTime() + 0.5 -- Track for half a second
    end
end)

-- Handle damage events
hook.Add("EntityTakeDamage", "SaxtonHalePunchSounds", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    
    -- Check if attacker is a valid player
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    
    -- Check if player is using Saxton Hale model with correct skin and SWEP
    if IsSaxtonHaleWithCorrectSkin(attacker) and IsUsingSaxtonHaleSWEP(attacker) then
        -- Check if target is a player, NPC, or NextBot
        if target:IsPlayer() or target:IsNPC() or target.Type == "nextbot" then
            -- Check if target is within range
            if not IsTargetInRange(attacker, target) then return end
            
            -- Check if player is in attack animation or viewmodel is playing crit swing
            local inAttackAnim = playerAttackStates[attacker:EntIndex()] and playerAttackStates[attacker:EntIndex()] > CurTime()
            
            -- For the server, we rely on the attack animation tracking
            if SERVER and inAttackAnim then
                PlayPunchVoiceLine(attacker, attacker:GetModel())
            end
            
            -- For the client, we can check the viewmodel animation directly
            if CLIENT and (inAttackAnim or IsPlayingCritSwingAnimation(attacker)) then
                PlayPunchVoiceLine(attacker, attacker:GetModel())
            end
        end
    end
end)

-- Track PLAYER_ATTACK1 animations
hook.Add("DoAnimationEvent", "SaxtonHaleTrackAttackAnim", function(ply, event, data)
    if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
        if IsSaxtonHaleWithCorrectSkin(ply) and IsUsingSaxtonHaleSWEP(ply) then
            playerAttackStates[ply:EntIndex()] = CurTime() + 0.5 -- Track for half a second
            
            -- If we're the server, we can trigger the voice line directly on attack animation
            -- But only if we hit something in range (we'll check this in EntityTakeDamage)
        end
    end
end)

-- Networking for lip sync
if SERVER then
    util.AddNetworkString("SaxtonHaleLipSync")
end

if CLIENT then
    -- Receive lip sync data from server
    net.Receive("SaxtonHaleLipSync", function()
        local ply = net.ReadEntity()
        local soundDuration = net.ReadFloat()
        local lipSyncDuration = net.ReadFloat()
        
        if IsValid(ply) then
            lipSyncData[ply:EntIndex()] = {
                startTime = CurTime(),
                endTime = CurTime() + lipSyncDuration,
                soundEndTime = CurTime() + soundDuration,
                lastCycleTime = CurTime()
            }
        end
    end)
    
    -- Handle lip sync animation
    hook.Add("Think", "SaxtonHaleLipSync", function()
        local currentTime = CurTime()
        
        for entIndex, data in pairs(lipSyncData) do
            local ply = Entity(entIndex)
            
            if not IsValid(ply) or currentTime > data.endTime then
                -- Remove expired lip sync data
                if currentTime > data.endTime then
                    -- Reset flex to 0 when done
                    if IsValid(ply) then
                        ply:SetFlexWeight(ply:GetFlexIDByName(FLEX_NAME), 0)
                    end
                    lipSyncData[entIndex] = nil
                end
                continue
            end
            
            -- Calculate lip movement
            local timeSinceLastCycle = currentTime - data.lastCycleTime
            local cycleProgress = (timeSinceLastCycle % FLEX_CYCLE_TIME) / FLEX_CYCLE_TIME
            
            -- Reset cycle timer if needed
            if timeSinceLastCycle >= FLEX_CYCLE_TIME then
                data.lastCycleTime = currentTime - (timeSinceLastCycle % FLEX_CYCLE_TIME)
            end
            
            -- Calculate flex weight (smooth sine wave)
            local flexWeight = 0
            
            -- First half of cycle: increase from 0 to 1
            if cycleProgress < 0.5 then
                flexWeight = math.sin(cycleProgress * math.pi)
            -- Second half of cycle: decrease from 1 to 0
            else
                flexWeight = math.sin((1 - (cycleProgress - 0.5) * 2) * math.pi/2)
            end
            
            -- Gradually reduce intensity after sound ends for a smooth fadeout
            if currentTime > data.soundEndTime then
                local fadeProgress = 1 - ((currentTime - data.soundEndTime) / EXTRA_LIP_SYNC_TIME)
                flexWeight = flexWeight * fadeProgress
            end
            
            -- fixed this rare bug idk how that got here
			local flexID = ply:GetFlexIDByName(FLEX_NAME)

			-- flexID MUST be a valid number >= 0
			if flexID ~= nil and flexID >= 0 then
			ply:SetFlexWeight(flexID, math.min(flexWeight * INTENSITY, 1.0)) -- i knew one day that it will break why have i not notice it idk i just found it
			end
        end
    end)
    
    -- Monitor viewmodel animations
    hook.Add("Think", "SaxtonHaleViewModelMonitor", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        if IsSaxtonHaleWithCorrectSkin(ply) and IsUsingSaxtonHaleSWEP(ply) then
            local vm = ply:GetViewModel()
            if IsValid(vm) then
                local seq = vm:GetSequenceName(vm:GetSequence())
                
                -- If we detect the crit swing animation starting
                if seq == "bg_swing_crit" and not playerAttackStates[ply:EntIndex()] then
                    playerAttackStates[ply:EntIndex()] = CurTime() + 0.5 -- Track for half a second
                end
            end
        end
    end)
end

-- Clean up player attack states for disconnected players
hook.Add("PlayerDisconnected", "SaxtonHaleCleanupAttackStates", function(ply)
    if playerAttackStates[ply:EntIndex()] then
        playerAttackStates[ply:EntIndex()] = nil
    end
end)
