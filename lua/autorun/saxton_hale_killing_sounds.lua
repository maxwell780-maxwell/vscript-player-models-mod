if SERVER then
    -- Sound file paths
    local kill_sounds = {
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_06.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_07.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_08.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_09.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_10.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_11.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_12.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_13.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_14.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_15.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_16.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_17.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_18.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_19.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_20.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_21.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_22.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_23.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_24.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_25.mp3",
        "mvm/saxton_hale_by_matthew_simmons/kill_generic_26.mp3"
    }

    -- List of allowed player models
    local valid_models = {
        "models/player/saxton_hale.mdl",
        "models/saxton_hale_3.mdl",
        "models/subzero_saxton_hale.mdl",
        "models/vsh/player/santa_hale.mdl",
        "models/vsh/player/winter/saxton_hale.mdl"
    }

    -- Table to track whether a player is already playing a sound
    local player_sounds = {}

    -- Function to play the random kill sound
    local function playKillSound(player)
        -- Check if a voice line is already playing
        if player:IsSpeaking() then return end

        -- Ensure we only play one sound at a time for the player
        if player_sounds[player] then
            return
        end

        -- Mark that the player is playing a sound
        player_sounds[player] = true

        -- Pick a random sound from the kill_sounds table
        local random_sound = kill_sounds[math.random(1, #kill_sounds)]

        -- Play the sound for the player
        player:EmitSound(random_sound)

        -- Set a timer to remove the sound tracking after the sound finishes
        timer.Simple(5, function()
            -- Ensure the player is still valid
            if IsValid(player) then
                -- Allow the player to play another kill sound
                player_sounds[player] = nil
            end
        end)
    end

    -- Hook into the entity's death event
    hook.Add("OnNPCKilled", "SaxtonHaleKillSound", function(victim, attacker)
        -- Ensure it's a valid player
        if IsValid(attacker) and attacker:IsPlayer() then
            local player_model = attacker:GetModel()

            -- Check if the player is using a valid Saxton Hale model
            if table.HasValue(valid_models, player_model) then
                -- Call function to play a kill sound
                playKillSound(attacker)
            end
        end
    end)
end
