local playerSpawnTimes = {}
local playerSoundTimers = {}

hook.Add("PlayerSpawn", "TrackHaleSpawnTime", function(ply)
    if IsValid(ply) and ply:IsPlayer() then
        playerSpawnTimes[ply] = CurTime()
    end
end)

hook.Add("PlayerDeath", "SaxtonHaleDeathSounds", function(victim)
    if not IsValid(victim) or not victim:IsPlayer() then return end

    local haleModels = {
        ["models/vsh/player/saxton_hale.mdl"] = true,
        ["models/player/saxton_hale.mdl"] = true,
        ["models/vsh/player/mecha_hale.mdl"] = true,
        ["models/saxton_hale_3.mdl"] = true,
        ["models/subzero_saxton_hale.mdl"] = true,
        ["models/vsh/player/winter/saxton_hale.mdl"] = true,
        ["models/vsh/player/santa_hale.mdl"] = true,
        ["models/vsh/player/hell_hale.mdl"] = true,
        ["models/player/hell_hale.mdl"] = true
    }

    if haleModels[victim:GetModel()] then
        local lifetime = CurTime() - (playerSpawnTimes[victim] or 0)
        local soundPath
        local soundDuration = 0
        local bailoutSounds, deathSounds

        if victim:GetModel() == "models/vsh/player/hell_hale.mdl" then
            bailoutSounds = {
                "mvm/hellfire_hale_matthew_simmons2/bailout_01.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_02.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_03.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_04.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_05.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_06.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_08.mp3"
            }
            deathSounds = {
                "mvm/hellfire_hale_matthew_simmons2/mercs_win_kill_02.mp3",
                "mvm/hellfire_hale_matthew_simmons2/mercs_win_kill_03.mp3",
                "mvm/hellfire_hale_matthew_simmons2/mercs_win_kill_04.mp3",
                "mvm/hellfire_hale_matthew_simmons2/mercs_win_kill_05.mp3",
                "mvm/hellfire_hale_new_lines2/mercs_win_kill_01.mp3",
                "mvm/hellfire_hale_new_lines2/mercs_win_kill_02.mp3"
            }
        elseif  victim:GetModel() == "models/player/hell_hale.mdl" then
            bailoutSounds = {
                "mvm/hellfire_hale_matthew_simmons2/bailout_01.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_02.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_03.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_04.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_05.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_06.mp3",
                "mvm/hellfire_hale_matthew_simmons2/bailout_08.mp3"
            }
            deathSounds = {
                "mvm/hellfire_hale_matthew_simmons2/mercs_win_kill_02.mp3",
                "mvm/hellfire_hale_matthew_simmons2/mercs_win_kill_03.mp3",
                "mvm/hellfire_hale_matthew_simmons2/mercs_win_kill_04.mp3",
                "mvm/hellfire_hale_matthew_simmons2/mercs_win_kill_05.mp3"
            }
        elseif  victim:GetModel() == "models/vsh/player/saxton_hale.mdl" then
            bailoutSounds = {
                "mvm/saxton_hale_by_matthew_simmons/bailout_01.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_02.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_03.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_04.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_05.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_06.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_07.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_08.mp3"
            }
            deathSounds = {
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_02.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_03.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_04.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_05.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_08.mp3",
                "mvm/saxton_hale_karijini/mercs_win_02.mp3",
                "mvm/saxton_hale_karijini/mercs_win_01.mp3",
                "mvm/saxton_hale_matthew_simmons/mercs_win_kill_11.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_09.mp3"
            }
        elseif victim:GetModel() == "models/vsh/player/mecha_hale.mdl" then
            deathSounds = {
                "mvm/vsh_mecha/mecha_hale_edit/mercs_win_kill_02.mp3",
                "mvm/vsh_mecha/mecha_hale_edit/mercs_win_kill_04.mp3",
                "mvm/vsh_mecha/mecha_hale_edit/mercs_win_kill_05.mp3",
                "mvm/vsh_mecha/mecha_hale_new/mercs_win_01.mp3",
                "mvm/vsh_mecha/mecha_hale_new/mercs_win_02.mp3",
                "mvm/vsh_mecha/mecha_hale_new/mercs_win_03.mp3",
                "mvm/vsh_mecha/mecha_hale_new/mercs_win_04.mp3"
            }
            bailoutSounds = deathSounds -- Use death sounds for bailout since Mecha Hale has no bailout sounds
        elseif victim:GetModel() == "models/saxton_hale_3.mdl" then
            -- Old Saxton Hale placeholder sounds
            deathSounds = {
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_02.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_03.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_04.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_05.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_08.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_09.mp3"
            }
            bailoutSounds = deathSounds -- Use same sounds for bailout since old Hale has no bailout sounds
        else
            bailoutSounds = {
                "mvm/saxton_hale_by_matthew_simmons/bailout_01.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_02.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_03.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_04.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_05.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_06.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_07.mp3",
                "mvm/saxton_hale_by_matthew_simmons/bailout_08.mp3"
            }
            deathSounds = {
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_02.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_03.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_04.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_05.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_08.mp3",
                "mvm/saxton_hale_by_matthew_simmons/mercs_win_kill_09.mp3"
            }
        end

        if lifetime < 30 then
            soundPath = table.Random(bailoutSounds)
            soundDuration = SoundDuration(soundPath)
            playerSoundTimers[victim] = CurTime() + soundDuration
            victim:EmitSound(soundPath)
        else
            if not playerSoundTimers[victim] or CurTime() > playerSoundTimers[victim] then
                soundPath = table.Random(deathSounds)
                victim:EmitSound(soundPath)
            end
        end
    end
end)