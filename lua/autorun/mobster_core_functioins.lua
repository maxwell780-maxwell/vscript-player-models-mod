if SERVER then

    local mobsterModel = "models/vip_mobster/player/mobster.mdl"

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
        "mvm/mobster_emergent_r1b/mobster_taunt01.mp3",
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

    local KILL_SOUND_COOLDOWN = 3

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
            soundDuration = 2.5
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
        
        -- Get sound duration
        local soundDuration = GetSoundDuration(soundPath)
        
        -- Create a unique timer name for this player
        ply._lipSyncTimer = "MobsterLipSync_" .. ply:EntIndex()
        
        -- Start the lip sync animation
        local startTime = CurTime()
        local endTime = startTime + soundDuration
        
        timer.Create(ply._lipSyncTimer, LIP_SYNC_INTERVAL, 0, function()
            if not IsValid(ply) then
                timer.Remove(ply._lipSyncTimer)
                return
            end
            
            local currentTime = CurTime()
            
            -- If sound has finished playing, stop lip sync
            if currentTime >= endTime then
                ply:SetFlexWeight(flexID, 0)
                timer.Remove(ply._lipSyncTimer)
                return
            end
            
            -- Animate the lip movement (oscillate between 0 and max weight)
            local lipValue = math.abs(math.sin((currentTime - startTime) * 10)) * LIP_MAX_WEIGHT
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

    -- Function to play kill sound with cooldown check
    local function PlayMobsterKillSound(attacker)
        if not IsMobster(attacker) then return end
        
        -- Check if the player is on cooldown
        if attacker._nextKillSound and attacker._nextKillSound > CurTime() then return end
        
        -- Set the cooldown
        attacker._nextKillSound = CurTime() + KILL_SOUND_COOLDOWN
        
        local wep = attacker:GetActiveWeapon()
        if IsValid(wep) then
            local ht = wep:GetHoldType()
            local sounds = (ht == "melee" or ht == "melee2") and killSoundsMelee or killSoundsGeneric
            local selectedSound = table.Random(sounds)
            PlaySoundWithLipSync(attacker, selectedSound)
        end
    end
	
 --   hook.Add("PlayerInitialSpawn", "MobsterCheckModelDelayed", function(ply)
    --    timer.Simple(5, function()
     --       if IsMobster(ply) then
     --           ply:Spawn()
     --       end
    --    end)
  --  end)

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
        end)
    end)

    hook.Add("EntityTakeDamage", "MobsterPainSounds", function(target, dmginfo)
        if not IsMobster(target) or not target:Alive() then return end
        if target._nextPainSound and target._nextPainSound > CurTime() then return end
        target._nextPainSound = CurTime() + 1.5
        local damage = dmginfo:GetDamage()
        if damage <= 1 then
            target:EmitSound(table.Random(painSharp), 75, 100)
        elseif damage >= 10 then
            target:EmitSound(table.Random(painSevere), 75, 100)
        end
    end)

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
        end
    end)

    hook.Add("PlayerDeath", "MobsterKillPlayer", function(victim, inflictor, attacker)
        if IsMobster(attacker) and attacker ~= victim then
            PlayMobsterKillSound(attacker)
        end
    end)
    
    -- Add support for NextBot kills
    hook.Add("EntityRemoved", "MobsterKillNextbot", function(entity)
        if entity.IsNextBot and entity:IsNextBot() then
            local attacker = entity.KilledBy
            if IsValid(attacker) and IsMobster(attacker) then
                PlayMobsterKillSound(attacker)
            end
        end
    end)
    
    -- Track NextBot attackers (this code is pretty useless and may ruin immersion might be removed some were later so im keeping it do pervent errors)
--    hook.Add("EntityTakeDamage", "TrackNextBotAttacker", function(target, dmginfo)
--        if target.IsNextBot and target:IsNextBot() then
 --           local attacker = dmginfo:GetAttacker()
 --           if IsValid(attacker) and attacker:IsPlayer() then
  --              target.KilledBy = attacker
  --              -- Clear the attacker after a short time in case the NextBot survives
   --             timer.Simple(0.1, function()
   --                 if IsValid(target) then
  --                      target.KilledBy = nil
     --               end
     --           end)
  --          end
  --      end
  --  end)
    
    -- Clean up lip sync timers when player disconnects
    hook.Add("PlayerDisconnected", "CleanupMobsterLipSync", function(ply)
        if ply._lipSyncTimer then
            timer.Remove(ply._lipSyncTimer)
        end
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
                        "mobster core functions version 1.2.0 (BETA) WARNING there is some changes made to mobster core functions that MAY effect gameplay/break or worse effect the on mobster class/playermodel entirely if you see any errors report it to ITS developer lists of changes are in the mods changed notes"
                    )
                    hook.Remove("Think", "mobsterWaitForLocalPlayer")
                end
            end)
        end)
    end)
end