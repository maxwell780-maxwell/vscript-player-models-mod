if SERVER then
    local hell_hale_kill_sounds = {
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_01.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_02.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_03.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_04.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_05.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_06.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_07.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_08.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_09.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_10.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_11.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_12.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_13.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_14.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_15.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_16.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_17.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_18.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_19.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_20.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_21.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_22.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_23.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_24.mp3",
        "mvm/hellfire_hale_matthew_simmons2/kill_generic_25.mp3",
        "mvm/hellfire_hale_new_lines2/kill_generic_01.mp3",
        "mvm/hellfire_hale_new_lines2/kill_generic_02.mp3",
        "mvm/hellfire_hale_new_lines2/kill_generic_03.mp3"
    }

    local saxton_hale_kill_sounds = {
        "silent.wav",
        "silent.wav",
        "silent.wav",
        "silent.wav",
        "silent.wav"
    }

    local valid_hell_hale_model = {
        "models/vsh/player/hell_hale.mdl",
        "models/player/hell_hale.mdl"
    }
	
    local player_sounds = {}

    local function playKillSound(player, sounds)
        if player:IsSpeaking() or player_sounds[player] then return end
        player_sounds[player] = true
        local random_sound = sounds[math.random(1, #sounds)]
        player:EmitSound(random_sound)
        timer.Simple(5, function()
            if IsValid(player) then
                player_sounds[player] = nil
            end
        end)
    end

    local function isValidHellHaleModel(model)
        for _, valid_model in ipairs(valid_hell_hale_model) do
            if model == valid_model then
                return true
            end
        end
        return false
    end

    hook.Add("OnNPCKilled", "HellHaleKillSound", function(victim, attacker)
        if IsValid(attacker) and attacker:IsPlayer() then
            local player_model = attacker:GetModel()
            if isValidHellHaleModel(player_model) then
                playKillSound(attacker, hell_hale_kill_sounds)
            else
                playKillSound(attacker, saxton_hale_kill_sounds)
            end
        end
    end)
end
