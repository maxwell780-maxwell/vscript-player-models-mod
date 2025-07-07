local haleModels = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
	["models/vsh/player/mecha_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true
}

local robotstartsounds = {
    "mvm/vsh_mecha/mecha_hale_new/round_start_01.mp3",
    "mvm/vsh_mecha/mecha_hale_new/round_start_02.mp3",
    "mvm/vsh_mecha/mecha_hale_new/round_start_03.mp3",
    "mvm/vsh_mecha/mecha_hale_new/round_start_04.mp3",
    "mvm/vsh_mecha/mecha_hale_new/round_start_after_win_01.mp3"

}

local startSounds = {
    "mvm/saxton_hale_by_matthew_simmons/round_start_01.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_02.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_03.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_04.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_05.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_06.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_07.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_08.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_09.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_10.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_long_01.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_long_02.mp3"
}

local beerSounds = {
    "mvm/saxton_hale_by_matthew_simmons/round_start_beer_01.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_beer_02.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_beer_03.mp3"
}

local saxtonNEWSounds = {
    "mvm/saxton_hale_karijini/round_start_01.mp3",
    "mvm/saxton_hale_karijini/round_start_02.mp3",
    "mvm/saxton_hale_karijini/round_start_03.mp3",
    "mvm/saxton_hale_karijini/round_start_04.mp3",
    "mvm/saxton_hale_karijini/round_start_long_01.mp3",
    "mvm/saxton_hale_karijini/round_start_long_02.mp3",
    "mvm/saxton_hale_karijini/round_start_long_03.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_01.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_02.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_03.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_04.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_05.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_06.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_07.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_08.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_09.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_10.mp3",
    "mvm/saxton_hale_matthew_simmons/round_start_11.mp3",
    "mvm/saxton_hale_matthew_simmons/round_start_beer_04.mp3",
    "mvm/saxton_hale_matthew_simmons/round_start_long_01.mp3",
    "mvm/saxton_hale_matthew_simmons/round_start_long_02.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_long_01.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_long_02.mp3"
}

local santaSounds = {
    "mvm/santa_hale_lines/round_start_maul_01.mp3",
    "mvm/santa_hale_lines/round_start_maul_02.mp3",
    "mvm/santa_hale_lines/round_start_maul_03.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_01.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_02.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_03.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_04.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_05.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_06.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_07.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_08.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_09.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_10.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_long_01.mp3",
    "mvm/saxton_hale_by_matthew_simmons/round_start_long_02.mp3"
}

local hellHaleSounds = {
    "mvm/hellfire_hale_matthew_simmons2/round_start_01.mp3",
    "mvm/hellfire_hale_matthew_simmons2/round_start_02.mp3",
    "mvm/hellfire_hale_matthew_simmons2/round_start_03.mp3",
    "mvm/hellfire_hale_matthew_simmons2/round_start_04.mp3",
    "mvm/hellfire_hale_matthew_simmons2/round_start_06.mp3",
    "mvm/hellfire_hale_matthew_simmons2/round_start_07.mp3",
    "mvm/hellfire_hale_matthew_simmons2/round_start_08.mp3",
    "mvm/hellfire_hale_matthew_simmons2/round_start_09.mp3",
    "mvm/hellfire_hale_new_lines2/round_start_01.mp3",
    "mvm/hellfire_hale_new_lines2/round_start_02.mp3",
    "mvm/hellfire_hale_new_lines2/round_start_03.mp3",
    "mvm/hellfire_hale_new_lines2/round_start_04.mp3",
    "mvm/hellfire_hale_new_lines2/round_start_05.mp3",
    "mvm/hellfire_hale_new_lines2/round_start_06.mp3",
    "mvm/hellfire_hale_new_lines2/round_start_07.mp3",
    "mvm/hellfire_hale_new_lines2/round_start_08.mp3",
    "mvm/hellfire_hale_new_lines2/round_start_extralong_01.mp3",
    "mvm/hellfire_hale_new_lines2/round_start_long_01.mp3"
}

hook.Add("PlayerSpawn", "SaxtonHaleSpawnSounds", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    -- Delay the sound to ensure the model is correctly set after spawn
    timer.Simple(0.1, function() 
        if not IsValid(ply) then return end  -- Check if the player is still valid

        local model = ply:GetModel()
        local map = game.GetMap()
        
        if haleModels[model] then
            local soundToPlay
            
            if model == "models/vsh/player/hell_hale.mdl" then
                -- Hell Hale voice lines
                soundToPlay = table.Random(hellHaleSounds)
            elseif model == "models/vsh/player/saxton_hale.mdl" then
                -- Santa Hale special lines
                soundToPlay = table.Random(saxtonNEWSounds)
            elseif model == "models/player/hell_hale.mdl" then
                -- Santa Hale special lines
                soundToPlay = table.Random(hellHaleSounds)
            elseif model == "models/vsh/player/santa_hale.mdl" then
                -- Santa Hale special lines
                soundToPlay = table.Random(santaSounds)
			elseif model == "models/vsh/player/mecha_hale.mdl" then
                -- Santa Hale special lines
                soundToPlay = table.Random(robotstartsounds)
            elseif map == "vsh_distillery" and math.random(1, 100) <= 10 then
                -- Rare beer lines in distillery (10% chance)
                soundToPlay = table.Random(beerSounds)
            else
                -- Normal round start sounds
                soundToPlay = table.Random(startSounds)
            end
            
            if soundToPlay then
                ply:EmitSound(soundToPlay)
            end
        end
    end)
end)
