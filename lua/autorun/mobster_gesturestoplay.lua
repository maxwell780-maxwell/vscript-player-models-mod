local playerModelList = {
    "models/vip_mobster/player/mobster.mdl"
}

local function GetGestureBasedOnHoldtype(ply, gestureType)
    local weapon = ply:GetActiveWeapon()
    local holdtype = "melee" -- Default holdtype
    
    if IsValid(weapon) then
        holdtype = weapon:GetHoldType() or "melee"
    end
    
    if gestureType == "DISARM" then
        return "gesture_disarm"
    elseif gestureType == "THANKS" then
        if holdtype == "melee" or holdtype == "melee2" then
            return math.random() > 0.5 and "gesture_melee_positive" or "gesture_melee_positive_alt"
        elseif holdtype == "ar2" then
            return math.random() > 0.5 and "gesture_primary_positive" or "gesture_primary_positive_alt"
        elseif holdtype == "slam" then
            return math.random() > 0.5 and "gesture_item1_positive" or "gesture_item1_positive_alt"
        else
            return math.random() > 0.5 and "gesture_melee_positive" or "gesture_melee_positive_alt"
        end
    elseif gestureType == "GO!" then
        if holdtype == "melee" or holdtype == "melee2" then
            return "gesture_melee_go"
        elseif holdtype == "ar2" then
            return "gesture_primary_go"
        elseif holdtype == "slam" then
            return "gesture_item1_go"
        else
            return "gesture_melee_go"
        end
    elseif gestureType == "CHEER" then
        if holdtype == "melee" or holdtype == "melee2" then
            return "gesture_melee_cheer"
        elseif holdtype == "ar2" then
            return "gesture_primary_cheer"
        elseif holdtype == "slam" then
            return "gesture_item1_cheer"
        else
            return "gesture_melee_cheer"
        end
    elseif gestureType == "HELP!" then
        if holdtype == "melee" or holdtype == "melee2" then
            return "gesture_melee_help"
        elseif holdtype == "ar2" then
            return "gesture_primary_help"
        elseif holdtype == "slam" then
            return "gesture_item1_help"
        else
            return "gesture_melee_help"
        end
    end
    
    return "gesture_melee_help" -- Default fallback
end

-- Facial expression data
local facialExpressions = {
    ["THANKS"] = {flex = "happysmall02", targetValue = 1},
    ["CHEER"] = {flex = "upperAngry3", targetValue = 1},
    ["HELP!"] = {flex = "dead03", targetValue = 1},
    ["GO!"] = {flex = "upperSuprise1", targetValue = 1},
    ["JEERS"] = {flex = "upperSad1", targetValue = 1},
    ["HAPPY"] = {flex = "upperHappy1", targetValue = 1},
    ["DISARM"] = nil -- No specific expression for DISARM
}

-- Sound data
local gestureSounds = {
    ["CHEER"] = {
        normal = {
            "mvm/mobster_emergent_r1b/mobster_battlecry01.mp3",
            "mvm/mobster_emergent_r1b/mobster_battlecry02.mp3",
            "mvm/mobster_emergent_r1b/mobster_battlecry03.mp3",
            "mvm/mobster_emergent_r1b/mobster_battlecry04.mp3",
            "mvm/mobster_emergent_r1b/mobster_battlecry05.mp3",
            "mvm/mobster_emergent_r1b/mobster_battlecry06.mp3",
            "mvm/mobster_emergent_r1b/mobster_battlecry07.mp3",
            "mvm/mobster_emergent_r1b/mobster_battlecry08.mp3"
        },
        hostile = {
            "mvm/mobster_emergent_r1b/mobster_meleedare02.mp3",
            "mvm/mobster_emergent_r1b/mobster_meleedare03.mp3",
            "mvm/mobster_emergent_r1b/mobster_meleedare04.mp3"
        }
    },
    ["THANKS"] = {
        "mvm/mobster_emergent_r1b/mobster_thanks01.mp3",
        "mvm/mobster_emergent_r1b/mobster_thanks02.mp3",
        "mvm/mobster_emergent_r1b/mobster_thanks03.mp3",
        "mvm/mobster_emergent_r1b/mobster_thanks04.mp3",
        "mvm/mobster_emergent_r1b/mobster_goodjob01.mp3",
        "mvm/mobster_emergent_r1b/mobster_goodjob02.mp3",
        "mvm/mobster_emergent_r1b/mobster_goodjob03.mp3",
        "mvm/mobster_emergent_r1b/mobster_niceshot01.mp3",
        "mvm/mobster_emergent_r1b/mobster_niceshot02.mp3",
        "mvm/mobster_emergent_r1b/mobster_niceshot03.mp3"
    },
    ["GO!"] = {
        "mvm/mobster_emergent_r1b/mobster_go01.mp3",
        "mvm/mobster_emergent_r1b/mobster_go02.mp3",
        "mvm/mobster_emergent_r1b/mobster_go03.mp3",
        "mvm/mobster_emergent_r1b/mobster_go04.mp3",
        "mvm/mobster_emergent_r1b/mobster_moveup02.mp3"
    },
    ["HELP!"] = {
        "mvm/mobster_emergent_r1b/mobster_helpme01.mp3",
        "mvm/mobster_emergent_r1b/mobster_helpme02.mp3",
        "mvm/mobster_emergent_r1b/mobster_helpme03.mp3",
        "mvm/mobster_emergent_r1b/mobster_helpme04.mp3",
        "mvm/mobster_emergent_r1b/mobster_helpme05.mp3",
        "mvm/mobster_emergent_r1b/mobster_medic01.mp3",
        "mvm/mobster_emergent_r1b/mobster_medic02.mp3",
        "mvm/mobster_emergent_r1b/mobster_medic03.mp3",
        "mvm/mobster_emergent_r1b/mobster_medic04.mp3",
        "mvm/mobster_emergent_r1b/mobster_medic05.mp3",
        "mvm/mobster_emergent_r1b/mobster_medicangry01.mp3",
        "mvm/mobster_emergent_r1b/mobster_medicangry02.mp3",
        "mvm/mobster_emergent_r1b/mobster_medicangry03.mp3"
    },
    ["JEERS"] = {
        "mvm/mobster_emergent_r1b/mobster_jeers01.mp3",
        "mvm/mobster_emergent_r1b/mobster_jeers02.mp3",
        "mvm/mobster_emergent_r1b/mobster_jeers03.mp3",
        "mvm/mobster_emergent_r1b/mobster_jeers04.mp3",
        "mvm/mobster_emergent_r1b/mobster_negativevocalization01.mp3",
        "mvm/mobster_emergent_r1b/mobster_negativevocalization02.mp3",
        "mvm/mobster_emergent_r1b/mobster_negativevocalization03.mp3",
        "mvm/mobster_emergent_r1b/mobster_negativevocalization04.mp3"
    },
    ["HAPPY"] = {
        "mvm/mobster_emergent_r1b/mobster_positivevocalization01.mp3",
        "mvm/mobster_emergent_r1b/mobster_positivevocalization02.mp3",
        "mvm/mobster_emergent_r1b/mobster_positivevocalization03.mp3",
        "mvm/mobster_emergent_r1b/mobster_positivevocalization04.mp3",
        "mvm/mobster_emergent_r1b/mobster_cheers01.mp3",
        "mvm/mobster_emergent_r1b/mobster_cheers02.mp3",
        "mvm/mobster_emergent_r1b/mobster_cheers03.mp3",
        "mvm/mobster_emergent_r1b/mobster_positivevocalization05.mp3",
        "mvm/mobster_emergent_r1b/mobster_positivevocalization06.mp3"
    }
}

-- veriables glore
local uiPanel = nil
local isKeyHeld = false
local lastPlayedGesture = nil
local currentHoveredText = nil
local isGesturePlaying = false
local gestureEndTime = 0
local currentFacialFlex = nil
local currentFlexValue = 0
local targetFlexValue = 0
local flexTransitionSpeed = 3.0 -- Speed of facial expression transition

local needsLipSyncReset = false
local isSoundPlaying = false
local soundEndTime = 0
local isLipSyncActive = false
local lipSyncEndTime = 0
local lipSyncFlexValue = 0
local lipSyncTargetValue = 0
local lipSyncSpeed = 5 -- Speed of lip sync animation
local lipSyncDirection = 1 -- 1 for up, -1 for down

-- Function to check if player is looking at a hostile entity
local function IsLookingAtHostile(ply)
    local trace = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:GetAimVector() * 300,
        filter = ply
    })
    
    if IsValid(trace.Entity) then
        -- Check if it's a player
        if trace.Entity:IsPlayer() and trace.Entity:Team() ~= ply:Team() then
            return true
        end
        
        -- Check if it's an NPC
        if trace.Entity:IsNPC() then
            -- Safer check for NPC disposition
            if trace.Entity.Disposition then
                local relationship = trace.Entity:Disposition(ply)
                if relationship == D_HT or relationship == D_FR then
                    return true
                end
            else
                -- If no Disposition method, assume hostile for most NPCs
                -- Exclude friendly NPCs like citizens
                local class = trace.Entity:GetClass()
                if not string.find(class, "npc_citizen") and 
                   not string.find(class, "npc_alyx") and
                   not string.find(class, "npc_barney") then
                    return true
                end
            end
        end
        
        -- Check for NextBot
        if trace.Entity.IsNextBot or string.find(trace.Entity:GetClass(), "nextbot") then
            return true
        end
    end
    
    return false
end

local function GetSoundDuration(soundPath) -- sound duration for lipsync for the mobster
    -- Approximate sound durations (in seconds) - you can adjust the lipsync time from here
    local soundDurations = {
        ["mvm/mobster_emergent_r1b/mobster_battlecry01.mp3"] = 1.5,
        ["mvm/mobster_emergent_r1b/mobster_battlecry02.mp3"] = 1.6,
        ["mvm/mobster_emergent_r1b/mobster_battlecry03.mp3"] = 1.6,
        ["mvm/mobster_emergent_r1b/mobster_battlecry04.mp3"] = 2.6,
        ["mvm/mobster_emergent_r1b/mobster_battlecry05.mp3"] = 1.5,
        ["mvm/mobster_emergent_r1b/mobster_battlecry06.mp3"] = 1.7,
        ["mvm/mobster_emergent_r1b/mobster_battlecry07.mp3"] = 1.4,
        ["mvm/mobster_emergent_r1b/mobster_battlecry08.mp3"] = 2.7,
        ["mvm/mobster_emergent_r1b/mobster_meleedare02.mp3"] = 1.3,
        ["mvm/mobster_emergent_r1b/mobster_meleedare03.mp3"] = 2.4,
        ["mvm/mobster_emergent_r1b/mobster_meleedare04.mp3"] = 1.4,
        ["mvm/mobster_emergent_r1b/mobster_thanks01.mp3"] = 1.2,
        ["mvm/mobster_emergent_r1b/mobster_thanks02.mp3"] = 1.7,
        ["mvm/mobster_emergent_r1b/mobster_thanks03.mp3"] = 1.4,
        ["mvm/mobster_emergent_r1b/mobster_thanks04.mp3"] = 1.5,
        ["mvm/mobster_emergent_r1b/mobster_goodjob01.mp3"] = 1.5,
        ["mvm/mobster_emergent_r1b/mobster_goodjob02.mp3"] = 2.2,
        ["mvm/mobster_emergent_r1b/mobster_goodjob03.mp3"] = 1.2,
        ["mvm/mobster_emergent_r1b/mobster_niceshot01.mp3"] = 1.7,
        ["mvm/mobster_emergent_r1b/mobster_niceshot02.mp3"] = 1.3,
        ["mvm/mobster_emergent_r1b/mobster_niceshot03.mp3"] = 1.3,
        ["mvm/mobster_emergent_r1b/mobster_go01.mp3"] = 1.0,
        ["mvm/mobster_emergent_r1b/mobster_go02.mp3"] = 1.2,
        ["mvm/mobster_emergent_r1b/mobster_go03.mp3"] = 1.5,
        ["mvm/mobster_emergent_r1b/mobster_go04.mp3"] = 1.2,
        ["mvm/mobster_emergent_r1b/mobster_go05.mp3"] = 1.2,
        ["mvm/mobster_emergent_r1b/mobster_moveup02.mp3"] = 1.4,
        ["mvm/mobster_emergent_r1b/mobster_helpme01.mp3"] = 1.3,
        ["mvm/mobster_emergent_r1b/mobster_helpme02.mp3"] = 1.2,
        ["mvm/mobster_emergent_r1b/mobster_helpme03.mp3"] = 1.2,
        ["mvm/mobster_emergent_r1b/mobster_helpme04.mp3"] = 1.7,
        ["mvm/mobster_emergent_r1b/mobster_helpme05.mp3"] = 1.8,
        ["mvm/mobster_emergent_r1b/mobster_medic01.mp3"] = 1.4,
        ["mvm/mobster_emergent_r1b/mobster_medic02.mp3"] = 1.9,
        ["mvm/mobster_emergent_r1b/mobster_medic03.mp3"] = 1.4,
        ["mvm/mobster_emergent_r1b/mobster_medic04.mp3"] = 1.6,
        ["mvm/mobster_emergent_r1b/mobster_medic05.mp3"] = 1.1,
        ["mvm/mobster_emergent_r1b/mobster_medicangry01.mp3"] = 3.3,
        ["mvm/mobster_emergent_r1b/mobster_medicangry02.mp3"] = 2.2,
        ["mvm/mobster_emergent_r1b/mobster_medicangry03.mp3"] = 3.5,
        ["mvm/mobster_emergent_r1b/mobster_jeers01.mp3"] = 1.8,
        ["mvm/mobster_emergent_r1b/mobster_jeers02.mp3"] = 3.6,
        ["mvm/mobster_emergent_r1b/mobster_jeers03.mp3"] = 1.6,
        ["mvm/mobster_emergent_r1b/mobster_jeers04.mp3"] = 1.9,
        ["mvm/mobster_emergent_r1b/mobster_negativevocalization01.mp3"] = 2.2,
        ["mvm/mobster_emergent_r1b/mobster_negativevocalization02.mp3"] = 2.1,
        ["mvm/mobster_emergent_r1b/mobster_negativevocalization03.mp3"] = 1.6,
        ["mvm/mobster_emergent_r1b/mobster_negativevocalization04.mp3"] = 2.6,
        ["mvm/mobster_emergent_r1b/mobster_positivevocalization01.mp3"] = 1.5,
        ["mvm/mobster_emergent_r1b/mobster_positivevocalization02.mp3"] = 1.8,
        ["mvm/mobster_emergent_r1b/mobster_positivevocalization03.mp3"] = 1.2,
        ["mvm/mobster_emergent_r1b/mobster_positivevocalization04.mp3"] = 2.1,
        ["mvm/mobster_emergent_r1b/mobster_cheers01.mp3"] = 1.5,
        ["mvm/mobster_emergent_r1b/mobster_cheers02.mp3"] = 1.2,
        ["mvm/mobster_emergent_r1b/mobster_cheers03.mp3"] = 1.3,
        ["mvm/mobster_emergent_r1b/mobster_positivevocalization05.mp3"] = 1.3,
        ["mvm/mobster_emergent_r1b/mobster_positivevocalization06.mp3"] = 1.4
    }
    
    return soundDurations[soundPath] or 2.0 -- Default to 2 seconds if not found
end

local function StartLipSync(duration)
    isLipSyncActive = true
    lipSyncEndTime = CurTime() + duration
    lipSyncFlexValue = 0
    lipSyncDirection = 1
end

local function SetFacialExpression(ply, gestureType, active)
    if not facialExpressions[gestureType] then return end
    
    local flexData = facialExpressions[gestureType]
    currentFacialFlex = flexData.flex
    
    if active then
        targetFlexValue = flexData.targetValue
    else
        targetFlexValue = 0
    end
end

local function PlayGestureSound(ply, gestureType)
    if not gestureSounds[gestureType] then return end
    
    local soundList = gestureSounds[gestureType]
    local soundToPlay = ""
    
    -- Special case for CHEER when looking at hostile
    if gestureType == "CHEER" then
        local isHostile = false
        
        -- Use pcall to catch any errors in IsLookingAtHostile
        local success, result = pcall(function() 
            return IsLookingAtHostile(ply) 
        end)
        
        if success and result then
            isHostile = true
        end
        
        if isHostile and soundList.hostile then
            local hostileSounds = soundList.hostile
            soundToPlay = hostileSounds[math.random(#hostileSounds)]
        elseif soundList.normal then
            local normalSounds = soundList.normal
            soundToPlay = normalSounds[math.random(#normalSounds)]
        end
    else
        soundToPlay = soundList[math.random(#soundList)]
    end
    
    -- Play the sound and start lip sync
    if soundToPlay and soundToPlay ~= "" then
        ply:EmitSound(soundToPlay, 75, 100, 1)
        local soundDuration = GetSoundDuration(soundToPlay)
        StartLipSync(soundDuration)
        
        -- Set sound cooldown for JEERS and HAPPY
        if gestureType == "JEERS" or gestureType == "HAPPY" then
            isSoundPlaying = true
            soundEndTime = CurTime() + soundDuration
        end
        
        -- For JEERS and HAPPY, set facial expression duration to match sound
        if gestureType == "JEERS" or gestureType == "HAPPY" then
            SetFacialExpression(ply, gestureType, true)
            -- Schedule facial expression reset after sound ends
            timer.Simple(soundDuration, function()
                if IsValid(ply) then
                    SetFacialExpression(ply, gestureType, false)
                    -- Also reset sound cooldown here as backup
                    if gestureType == "JEERS" or gestureType == "HAPPY" then
                        isSoundPlaying = false
                    end
                end
            end)
        end
    end
end

local function PlayGesture(ply, gestureType)
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- Set lastPlayedGesture for all gesture types (including JEERS and HAPPY)
    lastPlayedGesture = gestureType
    
    -- For JEERS and HAPPY, only play sound (no gesture animation)
    if gestureType == "JEERS" or gestureType == "HAPPY" then
        -- Check if sound is already playing (cooldown)
        if isSoundPlaying and CurTime() < soundEndTime then
            return -- Don't play if sound is still playing
        end
        
        PlayGestureSound(ply, gestureType)
        return
    end
    
    -- For other gestures, check if already playing
    if isGesturePlaying then return end
    
    local gestureAnim = GetGestureBasedOnHoldtype(ply, gestureType)
    local gestureSeq = ply:LookupSequence(gestureAnim)
    
    if gestureSeq then
        ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, gestureSeq, 0, true)
        isGesturePlaying = true
        gestureEndTime = CurTime() + ply:SequenceDuration(gestureSeq)
        
        -- Set facial expression
        SetFacialExpression(ply, gestureType, true)
        
        -- Play sound
        PlayGestureSound(ply, gestureType)
    end
end


-- Fix for the LocalPlayer error by ensuring code only runs on client
if CLIENT then
    -- Precache all sounds
    hook.Add("Initialize", "mobsterPrecacheSounds", function()
        for _, soundGroup in pairs(gestureSounds) do
            if type(soundGroup) == "table" then
                if soundGroup.normal then
                    for _, sound in ipairs(soundGroup.normal) do
                        util.PrecacheSound(sound)
                    end
                end
                if soundGroup.hostile then
                    for _, sound in ipairs(soundGroup.hostile) do
                        util.PrecacheSound(sound)
                    end
                end
                if not soundGroup.normal and not soundGroup.hostile then
                    for _, sound in ipairs(soundGroup) do
                        util.PrecacheSound(sound)
                    end
                end
            end
        end
    end)

    hook.Add("Think", "mobsterCheckGestureCompletion", function()
        local ply = LocalPlayer()
        
    if isGesturePlaying and CurTime() > gestureEndTime then
        isGesturePlaying = false
        
        -- Reset facial expression when gesture ends
        if lastPlayedGesture then
            SetFacialExpression(ply, lastPlayedGesture, false)
        end
    end
    
    -- Reset sound cooldown when sound finishes
    if isSoundPlaying and CurTime() > soundEndTime then
        isSoundPlaying = false
    end
    
-- listen i know this is messy but the sourcegraph told me to do it i dont care if this causes a LUA error i honestly dont TO DO: fix this junk
        
        -- Handle smooth facial flex transitions
    if IsValid(ply) and currentFacialFlex then
           -- Smoothly transition to target value
           local delta = FrameTime() * flexTransitionSpeed
           if currentFlexValue < targetFlexValue then
               currentFlexValue = math.min(currentFlexValue + delta, targetFlexValue)
           elseif currentFlexValue > targetFlexValue then
               currentFlexValue = math.max(currentFlexValue - delta, targetFlexValue)
            end
            
            -- Apply flex value
            local flexID = ply:GetFlexIDByName(currentFacialFlex)
            if flexID then
                ply:SetFlexWeight(flexID, currentFlexValue)
            end
        end
        
        -- Handle lip sync animation
        if IsValid(ply) and isLipSyncActive then
            if CurTime() > lipSyncEndTime then
                -- Sound ended, smoothly transition to 0
                isLipSyncActive = false
                lipSyncTargetValue = 0
            else
                -- Animate lip sync with oscillation
                local delta = FrameTime() * lipSyncSpeed
                lipSyncFlexValue = lipSyncFlexValue + (delta * lipSyncDirection)
                
                -- Bounce between 0 and 1
                if lipSyncFlexValue >= 1.0 then
                    lipSyncFlexValue = 1.0
                    lipSyncDirection = -1
                elseif lipSyncFlexValue <= 0.0 then
                    lipSyncFlexValue = 0.0
                    lipSyncDirection = 1
                end
            end
		end -- PLEASE DONT DO WHAT I DID IT SOME HOW WORKS KIDS DONT TRY THIS AT HOME THIS IS A RISKY ATTEMPT IN PATCHING DOWN A LUA OR EOF ERROR
            
            -- Apply lip sync flex
        if IsValid(ply) then
            local lipFlexID = ply:GetFlexIDByName("EEE")
            if lipFlexID then
                if isLipSyncActive then
                    if CurTime() > lipSyncEndTime then
                        -- Sound ended, force reset to 0
                        isLipSyncActive = false
                        ply:SetFlexWeight(lipFlexID, 0)
                        lipSyncFlexValue = 0
                    else
                        -- Animate lip sync with oscillation
                        local delta = FrameTime() * lipSyncSpeed
                        lipSyncFlexValue = lipSyncFlexValue + (delta * lipSyncDirection)
                        
                        -- Bounce between 0 and 1
                        if lipSyncFlexValue >= 1.0 then
                            lipSyncFlexValue = 1.0
                            lipSyncDirection = -1
                        elseif lipSyncFlexValue <= 0.0 then
                            lipSyncFlexValue = 0.0
                            lipSyncDirection = 1
                        end
                        
                        ply:SetFlexWeight(lipFlexID, lipSyncFlexValue)
                    end
                else
                    -- Ensure EEE is always 0 when not lip syncing
                    ply:SetFlexWeight(lipFlexID, 0)
                end
            end
        end
    end)

    hook.Add("Think", "mobsterCheckPlayerModelAndInput", function()
        local ply = LocalPlayer()
        
        if not IsValid(ply) or not ply:Alive() then
            if uiPanel and uiPanel:IsVisible() then
                uiPanel:SetVisible(false)
                gui.EnableScreenClicker(false)
                isKeyHeld = false
            end
            return
        end
        
        if input.IsKeyDown(KEY_T) and not isKeyHeld then
            if table.HasValue(playerModelList, ply:GetModel()) then
                isKeyHeld = true
                gui.EnableScreenClicker(true)
				
				local focusedPanel = vgui.GetKeyboardFocus()
				if IsValid(focusedPanel) then
					-- Check for common text input types
					local panelType = focusedPanel:GetClassName()
					if panelType == "TextEntry" or 
					panelType == "DTextEntry" or
					panelType == "RichText" or
					string.find(panelType:lower(), "text") or
					string.find(panelType:lower(), "edit") then
						return -- Don't open gesture menu while typing in text fields
					end
				end
    
                
                if not uiPanel then
                    uiPanel = vgui.Create("DPanel")
                    uiPanel:SetSize(ScrW(), ScrH())
                    uiPanel:SetPaintBackground(false)
                    uiPanel:SetMouseInputEnabled(true)

                    local buttonSize = 100
                    local padding = 10
                    local startX = (ScrW() / 2) - (3.5 * (buttonSize + padding))
                    local startY = (ScrH() / 2) - (1 * (buttonSize + padding))

                    local gestures = {"GO!", "CHEER", "HELP!", "THANKS", "DISARM", "JEERS", "HAPPY"}

                    for i, text in ipairs(gestures) do
                        local col = (i - 1) % 7
                        local row = math.floor((i - 1) / 7)
                        
                        local button = vgui.Create("DButton", uiPanel)
                        button:SetText(text)
                        button:SetSize(buttonSize, buttonSize)
                        button:SetPos(startX + col * (buttonSize + padding), startY + row * (buttonSize + padding))
                        button:SetFont("Trebuchet24")
                        button:SetTextColor(Color(255, 255, 255))

                        button.OnCursorEntered = function()
                            currentHoveredText = text
                        end

                        button.OnCursorExited = function()
                            currentHoveredText = nil
                        end

                        button.DoClick = function()
                            PlayGesture(ply, text)
                            uiPanel:SetVisible(false)
                            gui.EnableScreenClicker(false)
                        end
                    end
                end
                
                uiPanel:SetVisible(true)
            end
        elseif not input.IsKeyDown(KEY_T) and isKeyHeld then
            isKeyHeld = false
            if uiPanel then
                if not currentHoveredText and lastPlayedGesture then
                    if (lastPlayedGesture == "JEERS" or lastPlayedGesture == "HAPPY") then
                        if not isSoundPlaying or CurTime() >= soundEndTime then
                            PlayGesture(ply, lastPlayedGesture)
                        end
                    else
                        PlayGesture(ply, lastPlayedGesture)
                    end
                end
                uiPanel:SetVisible(false)
                gui.EnableScreenClicker(false)
            end
        end
    end)

    hook.Add("PlayerBindPress", "mobsterHideUIOnRelease", function(ply, bind, pressed)
        if bind == "+use" and not pressed then
            if uiPanel then
                uiPanel:SetVisible(false)
                gui.EnableScreenClicker(false)
            end
            isKeyHeld = false
        end
    end)
end