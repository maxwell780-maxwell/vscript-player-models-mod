if SERVER then
    -- Define constants and variables first
    local mobsterModel = "models/vip_mobster/player/mobster.mdl"
    local KILL_SOUND_COOLDOWN = 3
    local KILL_STREAK_THRESHOLD = 20
    local LIP_FLEX_NAME = "LTH"
    local LIP_MAX_WEIGHT = 0.9
    local LIP_SYNC_INTERVAL = 0.1
    
    -- Track kill count per player
    local mobsterKillCounts = {}
	
    local painSharp = {
        "mvm/mobster_emergent_r1b/mobster_painsharp01.mp3",
        "mvm/mobster_emergent_r1b/mobster_painsharp02.mp3",
        "mvm/mobster_emergent_r1b/mobster_painsharp03.mp3",
        "mvm/mobster_emergent_r1b/mobster_painsharp04.mp3",
        "mvm/mobster_emergent_r1b/mobster_painsharp05.mp3",
        "mvm/mobster_emergent_r1b/mobster_painsharp06.mp3",
        "mvm/mobster_emergent_r1b/mobster_painsharp07.mp3"
    }

    local painSevere = {
        "mvm/mobster_emergent_r1b/mobster_painsevere01.mp3",
        "mvm/mobster_emergent_r1b/mobster_painsevere02.mp3"
    }

    local painCriticalDeath = {
        "mvm/mobster_emergent_r1b/mobster_paincrticialdeath01.mp3",
        "mvm/mobster_emergent_r1b/mobster_paincrticialdeath02.mp3",
        "mvm/mobster_emergent_r1b/mobster_paincrticialdeath03.mp3"
    }

    local leaveSpawnSounds = {
        "mvm/mobster_emergent_r1b/mobster_leavespawn01.mp3",
        "mvm/mobster_emergent_r1b/mobster_leavespawn02.mp3",
        "mvm/mobster_emergent_r1b/mobster_leavespawn03.mp3"
    }

    local killSoundsGeneric = {
        "mvm/mobster_emergent_r1b/mobster_generickill01.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill02.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill03.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill04.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill05.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill06.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill07.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill08.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill09.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill10.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill11.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill12.mp3",
        "mvm/mobster_emergent_r1b/mobster_generickill13.mp3"
    }

    local killSoundsMelee = {
        "mvm/mobster_emergent_r1b/mobster_meleekill01.mp3",
        "mvm/mobster_emergent_r1b/mobster_meleekill02.mp3",
        "mvm/mobster_emergent_r1b/mobster_meleekill03.mp3",
        "mvm/mobster_emergent_r1b/mobster_meleekillimmediate01.mp3",
        "mvm/mobster_emergent_r1b/mobster_meleekillimmediate02.mp3",
        "mvm/mobster_emergent_r1b/mobster_meleekillimmediate03.mp3"
    }

	local moneybagDeploySounds = {
		"mvm/mobster_emergent_r1b/mobster_moneybagdeployed01.mp3",
		"mvm/mobster_emergent_r1b/mobster_moneybagdeployed02.mp3",
		"mvm/mobster_emergent_r1b/mobster_moneybagdeployed03.mp3",
		"mvm/mobster_emergent_r1b/mobster_moneybagdeployed04.mp3",
		"mvm/mobster_emergent_r1b/mobster_moneybagdeployed07.mp3",
		"mvm/mobster_emergent_r1b/mobster_moneybagdeployed08.mp3",
		"mvm/mobster_emergent_r1b/mobster_moneybagdeployed09.mp3",
	}

	local killStreakSounds = {
		"mvm/mobster_emergent_r1b/mobster_special01.mp3",
		"mvm/mobster_emergent_r1b/mobster_taunt01.mp3",
	}

    local KILL_SOUND_COOLDOWN = 3
	
	local KILL_STREAK_THRESHOLD = 20

	-- Track kill count per player
	local mobsterKillCounts = {}

    local LIP_FLEX_NAME = "LTH"
    local LIP_MAX_WEIGHT = 0.9
    local LIP_SYNC_INTERVAL = 0.1 -- How often to update lip sync

    local function IsMobster(ply)
        return IsValid(ply) and ply:IsPlayer() and ply:GetModel() == mobsterModel
    end
    
    local function GetSoundDuration(soundPath)
        local soundDuration = SoundDuration(soundPath)
        if not soundDuration or soundDuration <= 0 then
            -- Fallback duration if SoundDuration fails
            soundDuration = 11.9
        end
        return soundDuration
    end
    
    -- Function to handle lip sync
    local function DoLipSync(ply, soundPath)
        if not IsMobster(ply) then return end
        
        -- Get the flex ID for the lip movement
        local flexID = ply:GetFlexIDByName(LIP_FLEX_NAME)
        if not flexID then return end
        
        -- Stop any existing lip sync timer
        if ply._lipSyncTimer then
            timer.Remove(ply._lipSyncTimer)
        end
        
        -- Get sound duration with better fallback
        local soundDuration = GetSoundDuration(soundPath)
        
        -- Add extra buffer time to ensure we cover the full sound
        soundDuration = soundDuration + 0.5
        
        -- Create a unique timer name for this player
        ply._lipSyncTimer = "MobsterLipSync_" .. ply:EntIndex() .. "_" .. CurTime()
        
        -- Start the lip sync animation
        local startTime = CurTime()
        local endTime = startTime + soundDuration
        
        -- Store lip sync info on player for tracking
        ply._lipSyncActive = true
        ply._lipSyncEndTime = endTime
        
        -- More frequent updates for smoother animation
        local updateInterval = 0.09
        
        timer.Create(ply._lipSyncTimer, updateInterval, 0, function()
            if not IsValid(ply) then
                timer.Remove(ply._lipSyncTimer)
                return
            end
            
            local currentTime = CurTime()
            
            -- If sound has finished playing, stop lip sync
            if currentTime >= endTime then
                ply:SetFlexWeight(flexID, 0)
                ply._lipSyncActive = false
                ply._lipSyncEndTime = nil
                timer.Remove(ply._lipSyncTimer)
                return
            end
            
            -- More varied lip movement patterns
            local timeProgress = (currentTime - startTime) / soundDuration
            local baseFreq = 8 + math.sin(timeProgress * 3) * 2 -- Varying frequency
            local amplitude = LIP_MAX_WEIGHT * (0.7 + math.sin(timeProgress * 5) * 0.3) -- Varying amplitude
            
            -- Create more natural lip movement
            local lipValue = math.abs(math.sin((currentTime - startTime) * baseFreq)) * amplitude
            
            -- Add some randomness for more natural movement
            lipValue = lipValue * (0.8 + math.random() * 0.4)
            
            -- Ensure we don't exceed max weight
            lipValue = math.min(lipValue, LIP_MAX_WEIGHT)
            
            ply:SetFlexWeight(flexID, lipValue)
        end)
    end
    
    -- Function to play sound with lip sync
    local function PlaySoundWithLipSync(ply, soundPath, volume, pitch)
        volume = volume or 75
        pitch = pitch or 100
        
        ply:EmitSound(soundPath, volume, pitch)
        DoLipSync(ply, soundPath)
    end

    local function StopKillSounds(ply)
        if not IsValid(ply) then return end
        
        -- Stop all kill sounds (both melee and generic)
        for _, sound in ipairs(killSoundsMelee) do
            ply:StopSound(sound)
        end
        
        for _, sound in ipairs(killSoundsGeneric) do
            ply:StopSound(sound)
        end
        
        -- Clear kill sound flags since we stopped them
        ply._killSoundPlaying = false
        ply._killSoundEndTime = nil
        
        -- Stop lip sync if it was for a kill sound
        if ply._lipSyncTimer then
            timer.Remove(ply._lipSyncTimer)
            -- Reset lip flex to 0
            local flexID = ply:GetFlexIDByName(LIP_FLEX_NAME)
            if flexID then
                ply:SetFlexWeight(flexID, 0)
            end
        end
    end
	
    -- Define HandleMobsterKillStreak BEFORE CountMobsterKills
    local function HandleMobsterKillStreak(ply)
        -- IMMEDIATELY stop any playing kill sounds
        StopKillSounds(ply)
        
        local selected = table.Random(killStreakSounds)
        PlaySoundWithLipSync(ply, selected)
        mobsterKillCounts[ply] = 0
        
        -- Set killstreak sound playing flag with duration
        local soundDuration = GetSoundDuration(selected)
        ply._killstreakSoundPlaying = true
        ply._killstreakSoundEndTime = CurTime() + soundDuration
        
        -- Clear the flag when sound ends
        timer.Simple(soundDuration, function()
            if IsValid(ply) then
                ply._killstreakSoundPlaying = false
                ply._killstreakSoundEndTime = nil
            end
        end)
    end
    
    
    -- Generic kill tracker (now HandleMobsterKillStreak is defined above)
    local function CountMobsterKills(victim, attacker)
        if not IsMobster(attacker) or victim == attacker then return end
        mobsterKillCounts[attacker] = (mobsterKillCounts[attacker] or 0) + 1
        if mobsterKillCounts[attacker] >= KILL_STREAK_THRESHOLD then
            HandleMobsterKillStreak(attacker)
        end
    end
 
	
    -- Function to play kill sound with cooldown check
    local function PlayMobsterKillSound(attacker)
        if not IsMobster(attacker) then return end
        
        -- Don't play kill sound if killstreak sound is playing
        if attacker._killstreakSoundPlaying and attacker._killstreakSoundEndTime and CurTime() < attacker._killstreakSoundEndTime then
            return
        end
        
        -- Don't play if another kill sound is still playing
        if attacker._killSoundPlaying and attacker._killSoundEndTime and CurTime() < attacker._killSoundEndTime then
            return
        end
        
        -- Check if the player is on cooldown
        if attacker._nextKillSound and attacker._nextKillSound > CurTime() then return end
        
        -- Set the cooldown
        attacker._nextKillSound = CurTime() + KILL_SOUND_COOLDOWN
        
        local wep = attacker:GetActiveWeapon()
        if IsValid(wep) then
            local ht = wep:GetHoldType()
            local sounds = (ht == "melee" or ht == "melee2") and killSoundsMelee or killSoundsGeneric
            local selectedSound = table.Random(sounds)
            
            -- Get sound duration and set playing flag
            local soundDuration = GetSoundDuration(selectedSound)
            attacker._killSoundPlaying = true
            attacker._killSoundEndTime = CurTime() + soundDuration
            
            PlaySoundWithLipSync(attacker, selectedSound)
            
            -- Clear the flag when sound ends
            timer.Simple(soundDuration, function()
                if IsValid(attacker) then
                    attacker._killSoundPlaying = false
                    attacker._killSoundEndTime = nil
                end
            end)
        end
    end

    
    -- Hook definitions
    hook.Add("Think", "MobsterMoneybagThrowSound", function()
        for _, ply in ipairs(player.GetAll()) do
            if not IsMobster(ply) then continue end
            
            local wep = ply:GetActiveWeapon()
            if not IsValid(wep) or wep:GetClass() ~= "mobster_moneybag" then continue end
            
            local vm = ply:GetViewModel()
            if not IsValid(vm) then continue end
            
            local animName = vm:GetSequenceName(vm:GetSequence())
            if animName == "bag_throw" and not ply._playedBagSound then
                local snd = table.Random(moneybagDeploySounds)
                PlaySoundWithLipSync(ply, snd)
                ply._playedBagSound = true
                -- Reset after animation ends (approx 1s safety reset)
                timer.Simple(1, function()
                    if IsValid(ply) then
                        ply._playedBagSound = false
                    end
                end)
            end
        end
    end)
    
    hook.Add("PlayerSpawn", "MobsterInit", function(ply)
        timer.Simple(0.1, function()
            if not IsMobster(ply) then return end
            ply:SetMaxHealth(500)
            ply:SetHealth(500)
            ply:StripWeapons()
            ply:Give("mobster_typewriter")
            ply:Give("mobster_metalpipe")
            ply:Give("mobster_moneybag")
            ply:SetRunSpeed(164.9)
            ply:SetWalkSpeed(164.9)
            ply._mobsterSpawnPos = ply:GetPos()
            ply._mobsterLeftSpawn = false
            ply._nextKillSound = 0 -- Initialize kill sound cooldown
            
            -- Initialize sound playing flags
            ply._killSoundPlaying = false
            ply._killSoundEndTime = nil
            ply._killstreakSoundPlaying = false
            ply._killstreakSoundEndTime = nil
        end)
    end)

    
    -- Fixed: Removed duplicate hook and combined functionality
    hook.Add("EntityTakeDamage", "MobsterPainSounds", function(target, dmginfo)
        if not IsMobster(target) or not target:Alive() then return end
        if target._nextPainSound and target._nextPainSound > CurTime() then return end
        target._nextPainSound = CurTime() + 1.5
        
        local damage = dmginfo:GetDamage()
        local selectedSound
        
        if damage <= 1 then
            selectedSound = table.Random(painSharp)
        elseif damage >= 10 then
            selectedSound = table.Random(painSevere)
        else
            return
        end
        
        PlaySoundWithLipSync(target, selectedSound)
    end)
    
    hook.Add("PlayerDeath", "MobsterDeathSounds", function(ply, inflictor, attacker)
        if not IsMobster(ply) then return end
        
        local selectedSound
        if attacker == ply or attacker:IsWorld() then
            selectedSound = table.Random(painSevere)
        else
            selectedSound = table.Random(painCriticalDeath)
        end
        
        PlaySoundWithLipSync(ply, selectedSound)
    end)
    
    hook.Add("Think", "MobsterLeaveSpawnSound", function()
        for _, ply in ipairs(player.GetAll()) do
            if IsMobster(ply) and ply._mobsterSpawnPos and not ply._mobsterLeftSpawn then
                if ply:GetPos():DistToSqr(ply._mobsterSpawnPos) > 2500 then
                    local selectedSound = table.Random(leaveSpawnSounds)
                    PlaySoundWithLipSync(ply, selectedSound)
                    ply._mobsterLeftSpawn = true
                end
            end
        end
    end)
    
    hook.Add("OnNPCKilled", "MobsterKillSound", function(npc, attacker, inflictor)
        if IsMobster(attacker) then
            PlayMobsterKillSound(attacker)
            CountMobsterKills(npc, attacker)
        end
    end)
    
    hook.Add("PlayerDeath", "MobsterKillPlayer", function(victim, inflictor, attacker)
        if IsMobster(attacker) and attacker ~= victim then
            PlayMobsterKillSound(attacker)
            CountMobsterKills(victim, attacker)
        end
    end)
    
    -- Add support for NextBot kills
    hook.Add("EntityRemoved", "MobsterKillNextbot", function(entity)
        if entity.IsNextBot and entity:IsNextBot() then
            local attacker = entity.KilledBy
            if IsValid(attacker) then
                CountMobsterKills(entity, attacker)
            end
        end
    end)
    -- Clean up lip sync timers when player disconnects
    hook.Add("PlayerDisconnected", "CleanupMobsterLipSync", function(ply)
        if ply._lipSyncTimer then
            timer.Remove(ply._lipSyncTimer)
        end
        mobsterKillCounts[ply] = nil
        
        -- Clean up sound flags
        ply._killSoundPlaying = nil
        ply._killSoundEndTime = nil
        ply._killstreakSoundPlaying = nil
        ply._killstreakSoundEndTime = nil
    end)
end

if CLIENT then
    hook.Add("InitPostEntity", "mobsterVersionMessage", function()
        timer.Simple(3, function()
            hook.Add("Think", "mobsterWaitForLocalPlayer", function()
                local ply = LocalPlayer()
                if IsValid(ply) then
                    chat.AddText(
                        Color(203, 0, 0),
                        "[Mobster core functions] ",
                        Color(255, 255, 255),
                        "mobster core functions version 1.2.1 (BETA) WARNING there is some changes made to mobster core functions that MAY effect gameplay/break or worse effect the on mobster class/playermodel entirely if you see any errors report it to ITS developer lists of changes are in the mods changed notes"
                    )
                    hook.Remove("Think", "mobsterWaitForLocalPlayer")
                end
            end)
        end)
    end)
end

-- THIS IS FOR SAFE KEEPING SO II COULD EDIT IT LATER 

 --   local function GetSoundDuration(soundPath)
     --   local soundDuration = SoundDuration(soundPath)
        
        -- If SoundDuration fails, use filename-based estimation or manual lookup
      --  if not soundDuration or soundDuration <= 0 then
            -- Manual duration lookup for known problematic sounds
         --   local manualDurations = {
           --     ["mvm/mobster_emergent_r1b/mobster_painsharp01.mp3"] = 1.5,
            --    ["mvm/mobster_emergent_r1b/mobster_painsharp02.mp3"] = 1.2,
            --    ["mvm/mobster_emergent_r1b/mobster_painsharp03.mp3"] = 1.8,
            --    ["mvm/mobster_emergent_r1b/mobster_painsharp04.mp3"] = 1.4,
            --    ["mvm/mobster_emergent_r1b/mobster_painsharp05.mp3"] = 1.6,
            --    ["mvm/mobster_emergent_r1b/mobster_painsharp06.mp3"] = 1.3,
            --    ["mvm/mobster_emergent_r1b/mobster_painsharp07.mp3"] = 1.7,
            --    ["mvm/mobster_emergent_r1b/mobster_painsevere01.mp3"] = 2.1,
           --     ["mvm/mobster_emergent_r1b/mobster_painsevere02.mp3"] = 2.3,
        --        ["mvm/mobster_emergent_r1b/mobster_special01.mp3"] = 3.2,
        --        ["mvm/mobster_emergent_r1b/mobster_taunt01.mp3"] = 2.8,

        --    }
            
        --    soundDuration = manualDurations[soundPath] or 2.5 -- Fallback duration
     --   end
        
     --   return soundDuration
  --  end
    
