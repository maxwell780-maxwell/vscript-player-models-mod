local saxtonModels = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true,
    ["models/vsh/player/hell_hale.mdl"] = true
}

local voiceLines = {
    ["models/player/saxton_hale.mdl"] = { 
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_06.mp3"
    },
    ["models/subzero_saxton_hale.mdl"] = { 
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_06.mp3"
    },
    ["models/vsh/player/saxton_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_06.mp3"
    },
    ["models/vsh/player/santa_hale.mdl"] = {
        "mvm/santa_hale_lines/saxton_punch_ready_maul_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_06.mp3"
    },
    ["models/vsh/player/winter/saxton_hale.mdl"] = {
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_01.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_02.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_03.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_04.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_05.mp3",
        "mvm/saxton_hale_by_matthew_simmons/saxton_punch_ready_06.mp3"
    },
    ["models/player/hell_hale.mdl"] = {
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_01.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_02.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_03.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_04.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_05.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_06.mp3"
    },
    ["models/vsh/player/hell_hale.mdl"] = {
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_01.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_02.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_03.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_04.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_05.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_ready_06.mp3"
    }
}

local punchVoiceLines = {
    ["models/player/saxton_hale.mdl"] = {
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
    ["models/player/hell_hale.mdl"] = {
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_01.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_02.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_03.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_04.mp3"
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
    ["models/vsh/player/hell_hale.mdl"] = {
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_01.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_02.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_03.mp3",
        "mvm/hellfire_hale_matthew_simmons2/saxton_punch_04.mp3"
    }
}

-- Track weapon equip state to play sound only once when conditions are met
local playerStates = {}

-- Lip sync variables
local isTalking = false
local talkingStartTime = 0
local talkingDuration = 0
local lipSyncFlex = 0
local AE_FLEX_ID = nil -- Will be set dynamically
local ACTIONFIRE01_FLEX_ID = nil -- Will be set dynamically
local actionFireValue = 0
local actionFireEndTime = 0

local lastPunchSoundTime = 0
local PUNCH_SOUND_COOLDOWN = 0.5 -- Half second cooldown


if CLIENT then
    -- Precache all sounds
	for _, sounds in pairs(voiceLines) do
        for _, soundPath in ipairs(sounds) do
            util.PrecacheSound(soundPath)
        end
    end
    
    for _, sounds in pairs(punchVoiceLines) do
        for _, soundPath in ipairs(sounds) do
            util.PrecacheSound(soundPath)
        end
    end
    
    -- Precache the rocket sound we need to listen for
    util.PrecacheSound("mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav")

    -- Function to find flex IDs for a model
    local function FindFlexIDs(ply)
        if not IsValid(ply) then return nil, nil end
        
        local aeFlexID = nil
        local actionFireFlexID = nil
        
        local flexCount = ply:GetFlexNum()
        for i = 0, flexCount - 1 do
            local name = ply:GetFlexName(i)
            if name then
                if name:lower() == "ae" then
                    aeFlexID = i
                elseif name:lower() == "actionfire01" then
                    actionFireFlexID = i
                end
            end
        end
        
        -- Fallbacks if we can't find by name
        if not aeFlexID then
            aeFlexID = 11 -- Common ID for "AE" mouth position
        end
        
        if not actionFireFlexID then
            actionFireFlexID = 32 -- Common ID for action expressions
        end
        
        return aeFlexID, actionFireFlexID
    end

    -- Function to play sound and start lip sync
    local function PlaySaxtonSound(soundPath, isReadySound)
        -- Get sound duration
        local soundDuration = SoundDuration(soundPath)
        if not soundDuration or soundDuration <= 0 then
            soundDuration = 3 -- Default duration if we can't get it
        end
        
        -- Play the sound
        surface.PlaySound(soundPath)
        
        -- Set lip sync variables
        isTalking = true
        talkingStartTime = CurTime()
        talkingDuration = soundDuration
        
        -- Find flex IDs if we don't have them yet
        if not AE_FLEX_ID or not ACTIONFIRE01_FLEX_ID then
            AE_FLEX_ID, ACTIONFIRE01_FLEX_ID = FindFlexIDs(LocalPlayer())
        end
        
        -- If this is a ready sound, set the actionfire01 flex
        if isReadySound and ACTIONFIRE01_FLEX_ID then
            actionFireValue = 1
            actionFireEndTime = CurTime() + soundDuration + 10 -- 10 second delay after sound ends
        end
    end

    -- Main check function for ready sounds
    local function CheckPlayerModel()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local model = ply:GetModel()
        local skin = ply:GetSkin()
        local activeWeapon = ply:GetActiveWeapon()
        
        -- Check if player has the right model, skin, and weapon
        if saxtonModels[model] and skin == 2 and IsValid(activeWeapon) and activeWeapon:GetClass() == "weapon_saxton_hale_swep" then
            -- Create a unique state key for this player
            local stateKey = model .. "_" .. skin
            
            -- If we haven't played a sound for this state yet
            if not playerStates[stateKey] then
                -- Select a random voice line for the model
                local modelSounds = voiceLines [model]
                if modelSounds and #modelSounds > 0 then
                    local randomSound = modelSounds[math.random(#modelSounds)]
                    PlaySaxtonSound(randomSound, true) -- true indicates this is a ready sound
                    
                    -- Mark that we've played a sound for this state
                    playerStates[stateKey] = true
                end
            end
        else
            -- Reset state if conditions are no longer met
            local stateKey = model .. "_" .. skin
            if playerStates[stateKey] then
                playerStates[stateKey] = nil
            end
        end
    end

    -- Function to play punch sound
    local function PlayPunchSound()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local model = ply:GetModel()
        local activeWeapon = ply:GetActiveWeapon()
        
        -- Check if player has the right model and weapon
        if saxtonModels[model] and IsValid(activeWeapon) and activeWeapon:GetClass() == "weapon_saxton_hale_swep" then
            -- Select a random punch voice line for the model
            local modelSounds = punchVoiceLines[model]
            if modelSounds and #modelSounds > 0 then
                local randomSound = modelSounds[math.random(#modelSounds)]
                PlaySaxtonSound(randomSound, false) -- false indicates this is not a ready sound
            end
        end
    end

    -- Hook to weapon switching
    hook.Add("PlayerSwitchWeapon", "SaxtonHaleVoiceLines_WeaponSwitch", function(ply, oldWeapon, newWeapon)
        if ply == LocalPlayer() then
            -- Reset state when switching weapons
            playerStates = {}
            -- Small delay to ensure the weapon switch is complete
            timer.Simple(0.1, CheckPlayerModel)
        end
    end)

    -- Hook to skin changes
    hook.Add("Think", "SaxtonHaleVoiceLines_SkinCheck", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        -- Store current model and skin
        local currentModel = ply:GetModel()
        local currentSkin = ply:GetSkin()
        
        -- If we don't have previous values, set them
        if not ply.PrevSaxtonModel then
            ply.PrevSaxtonModel = currentModel
            ply.PrevSaxtonSkin = currentSkin
            return
        end
        
        -- Check if model or skin changed
        if ply.PrevSaxtonModel ~= currentModel or ply.PrevSaxtonSkin ~= currentSkin then
            -- Reset state when model or skin changes
            playerStates = {}
            -- Update previous values
            ply.PrevSaxtonModel = currentModel
            ply.PrevSaxtonSkin = currentSkin
            -- Check if we should play a sound
            timer.Simple(0.1, CheckPlayerModel)
            
            -- Reset flex IDs when model changes
            AE_FLEX_ID = nil
            ACTIONFIRE01_FLEX_ID = nil
        end
    end)

    -- Lip sync animation in PrePlayerDraw
    hook.Add("PrePlayerDraw", "SaxtonHaleVoiceLines_LipSync", function(ply)
        if ply ~= LocalPlayer() then return end
        
        -- Find flex IDs if we don't have them yet
        if not AE_FLEX_ID or not ACTIONFIRE01_FLEX_ID then
            AE_FLEX_ID, ACTIONFIRE01_FLEX_ID = FindFlexIDs(ply)
        end
        
        -- Handle lip sync for talking
        if isTalking and AE_FLEX_ID then
            local currentTime = CurTime()
            local elapsedTime = currentTime - talkingStartTime
            
            -- Check if we're still within the sound duration
            if elapsedTime <= talkingDuration then
                -- Calculate lip sync value with pulsing effect
                local talkProgress = elapsedTime / talkingDuration
                local pulseSpeed = 20 -- Adjust for faster/slower mouth movement
                local pulseValue = math.sin(elapsedTime * pulseSpeed) * 0.5 + 0.5
                
                -- Fade in at start and fade out at end
                local fadeInOut = 1
                if talkProgress < 0.1 then
                    -- Fade in during first 10% of sound
                    fadeInOut = talkProgress / 0.1
                elseif talkProgress > 0.8 then
                    -- Fade out during last 20% of sound
                    fadeInOut = (1 - talkProgress) / 0.2
                end
                
                -- Set the flex value (smoothly animated)
                lipSyncFlex = math.Approach(lipSyncFlex, pulseValue * fadeInOut, FrameTime() * 5)
                ply:SetFlexWeight(AE_FLEX_ID, lipSyncFlex)
            else
                -- Sound has ended, fade out lip sync
                lipSyncFlex = math.Approach(lipSyncFlex, 0, FrameTime() * 5)
                ply:SetFlexWeight(AE_FLEX_ID, lipSyncFlex)
                
                -- If we've fully faded out, stop talking
                if lipSyncFlex <= 0.01 then
                    isTalking = false
                end
            end
        elseif AE_FLEX_ID then
            -- Make sure flex is reset when not talking
            ply:SetFlexWeight(AE_FLEX_ID, 0)
        end

        -- Handle actionfire01 flex animation
        if ACTIONFIRE01_FLEX_ID then
            local currentTime = CurTime()
            
            -- If we're within the action fire time window
            if currentTime < actionFireEndTime then
                -- If we're in the last 2 seconds, start fading out
                if currentTime > actionFireEndTime - 2 then
                    local fadeOutProgress = (actionFireEndTime - currentTime) / 2
                    actionFireValue = math.Approach(actionFireValue, 0, FrameTime() * (1 - fadeOutProgress) * 2)
                else
                    -- Otherwise maintain the value at 1
                    actionFireValue = math.Approach(actionFireValue, 1, FrameTime() * 5)
                end
            else
                -- Outside the time window, ensure it's set to 0
                actionFireValue = math.Approach(actionFireValue, 0, FrameTime() * 5)
            end
            
            -- Apply the flex weight
            ply:SetFlexWeight(ACTIONFIRE01_FLEX_ID, actionFireValue)
        end
    end)
    
    -- Initialize when the script loads
    hook.Add("InitPostEntity", "SaxtonHaleVoiceLines_Init", function()
        -- Wait a moment for the player to fully initialize
        timer.Simple(1, function()
            local ply = LocalPlayer()
            if IsValid(ply) then
                AE_FLEX_ID, ACTIONFIRE01_FLEX_ID = FindFlexIDs(ply)
            end
        end)
    end)
end
