local HALE_MODELS = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/saxton_hale_3.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true,
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/vsh/player/mecha_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true
}

-- Model-specific jump sounds because saxton is saxton of course he talks when jumping
local MODEL_JUMP_SOUNDS = {
    ["models/vsh/player/winter/saxton_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/jump_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_06.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_07.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_08.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_09.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_10.mp3"
    },
    ["models/subzero_saxton_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/jump_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_06.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_07.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_08.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_09.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_10.mp3"
    },
    ["models/vsh/player/saxton_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/jump_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_06.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_07.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_08.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_09.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_10.mp3"
    },
    ["models/saxton_hale_3.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/jump_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_06.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_07.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_08.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_09.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_10.mp3"
    },
    ["models/vsh/player/mecha_hale.mdl"] = {
        "mvm/vsh_mecha/mecha_hale_edit/jump_01.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/jump_02.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/jump_03.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/jump_04.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/jump_05.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/jump_06.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/jump_07.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/jump_08.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/jump_09.mp3",
        "mvm/vsh_mecha/mecha_hale_edit/jump_10.mp3"
    },
    ["models/vsh/player/santa_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/jump_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_06.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_07.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_08.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_09.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_10.mp3"
    },
    ["models/player/saxton_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/jump_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_06.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_07.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_08.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_09.mp3",
        "mvm/saxton_hale_by_matthew_simmons/jump_10.mp3"
    },
    ["models/player/hell_hale.mdl"] = {
        "mvm/hellfire_hale_matthew_simmons2/jump_01.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_02.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_03.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_04.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_05.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_06.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_07.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_08.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_09.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_10.mp3"
    },
    ["models/vsh/player/hell_hale.mdl"] = {
        "mvm/hellfire_hale_matthew_simmons2/jump_01.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_02.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_03.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_04.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_05.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_06.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_07.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_08.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_09.mp3",
        "mvm/hellfire_hale_matthew_simmons2/jump_10.mp3"
    }
}

local hasDoubleJumped = {}
local lastVelocity = {}
local isPlayingSound = {} --saxton voice dont play twice no more YAAAAY :D

hook.Add("Initialize", "HaleSoundPrecache", function()
    for _, soundTable in pairs(MODEL_JUMP_SOUNDS) do
        for _, sound in ipairs(soundTable) do
            util.PrecacheSound(sound)
        end
    end
end)

hook.Add("Think", "HaleMovementCheck", function() --vibe check
    for _, ply in ipairs(player.GetAll()) do
        if HALE_MODELS[ply:GetModel()] then
            ply:SetRunSpeed(300)
            ply:SetWalkSpeed(300)
        end
    end
end)

local function PlayJumpSound(ply, soundTable)
    if isPlayingSound[ply] then return end
    
    local randomSound = soundTable[math.random(#soundTable)]
    isPlayingSound[ply] = true
    
    ply:EmitSound(randomSound, 75, 100, 1)
    
    timer.Simple(1.0, function()
        if IsValid(ply) then
            isPlayingSound[ply] = false
        end
    end)
end

hook.Add("KeyPress", "HaleDoubleJump", function(ply, key)
    if not HALE_MODELS[ply:GetModel()] then return end
    
    if key == IN_JUMP then
        if not ply:IsOnGround() and not hasDoubleJumped[ply] then
            lastVelocity[ply] = ply:GetVelocity().z
            hasDoubleJumped[ply] = true
            local vel = ply:GetVelocity()
            ply:SetVelocity(Vector(vel.x, vel.y, 700))
			
            if ply:GetModel() == "models/vsh/player/mecha_hale.mdl" and math.abs(400 - lastVelocity[ply]) >= 390 then
                ply:EmitSound("weapons/flame_thrower_airblast.wav", 75, 100, 1)
            end
            
            local modelSounds = MODEL_JUMP_SOUNDS[ply:GetModel()]
            if modelSounds and math.abs(400 - lastVelocity[ply]) >= 390 then
                PlayJumpSound(ply, modelSounds)
            end
        elseif ply:IsOnGround() then
            hasDoubleJumped[ply] = false
            lastVelocity[ply] = 0
        end
    end
end)

hook.Add("PlayerSpawn", "HaleDoubleJumpReset", function(ply)
    hasDoubleJumped[ply] = false
    lastVelocity[ply] = 0
    isPlayingSound[ply] = false
end)

hook.Add("PlayerDisconnected", "HaleCleanup", function(ply)
    hasDoubleJumped[ply] = nil
    lastVelocity[ply] = nil
    isPlayingSound[ply] = nil
end)