if SERVER then
    -- Sound file paths for Mecha Hale
    local mecha_hale_kill_sounds = {
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_01.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_02.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_03.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_04.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_05.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_06.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_08.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_09.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_10.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_11.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_12.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_13.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_14.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_15.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_17.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_18.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_19.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_20.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_22.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/kill_generic_23.mp3",
        "mvm/vsh_mecha/mecha_hale_new/kill_generic_01.mp3",
        "mvm/vsh_mecha/mecha_hale_new/kill_generic_02.mp3",
        "mvm/vsh_mecha/mecha_hale_new/kill_generic_03.mp3",
        "mvm/vsh_mecha/mecha_hale_new/kill_generic_04.mp3",
        "mvm/vsh_mecha/mecha_hale_new/kill_generic_05.mp3",
        "mvm/vsh_mecha/mecha_hale_new/kill_generic_06.mp3",
        "mvm/vsh_mecha/mecha_hale_new/kill_generic_07.mp3",
        "mvm/vsh_mecha/mecha_hale_new/kill_generic_08.mp3",
        "mvm/vsh_mecha/mecha_hale_new/kill_generic_09.mp3"
    }

    local saxton_hale_kill_sounds = {
        "silent.wav",
        "silent.wav",
        "silent.wav",
        "silent.wav",
        "silent.wav"
    }

    local player_sounds = {}
    local sound_cooldowns = {}
    local COOLDOWN_TIME = 5

    local function canPlaySound(player)
        if player:IsSpeaking() or player_sounds[player] then 
            return false 
        end
        
        local lastSound = sound_cooldowns[player] or 0
        if CurTime() - lastSound < COOLDOWN_TIME then
            return false
        end
        
        return true
    end

    local function playKillSound(player, sounds)
        if not canPlaySound(player) then return end

        player_sounds[player] = true
        sound_cooldowns[player] = CurTime()
        
        local random_sound = sounds[math.random(#sounds)]
        player:EmitSound(random_sound)

        timer.Simple(COOLDOWN_TIME, function()
            if IsValid(player) then
                player_sounds[player] = nil
            end
        end)
    end

    hook.Add("OnNPCKilled", "MechaHaleKillSound", function(victim, attacker)
        if IsValid(attacker) and attacker:IsPlayer() then
            if attacker:GetModel() == "models/vsh/player/mecha_hale.mdl" then
                playKillSound(attacker, mecha_hale_kill_sounds)
            else
                playKillSound(attacker, saxton_hale_kill_sounds)
            end
        end
    end)

    -- Cleanup on player disconnect
    hook.Add("PlayerDisconnected", "CleanupSoundStates", function(player)
        player_sounds[player] = nil
        sound_cooldowns[player] = nil
    end)
end