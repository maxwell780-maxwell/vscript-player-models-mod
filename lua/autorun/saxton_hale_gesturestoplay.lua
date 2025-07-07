if SERVER then return end

local playerModelList = {
    "models/player/saxton_hale.mdl",
    "models/saxton_hale_3.mdl",
    "models/vsh/player/saxton_hale.mdl",
    "models/vsh/player/santa_hale.mdl",
    "models/vsh/player/hell_hale.mdl",
    "models/vsh/player/mecha_hale.mdl",
    "models/subzero_saxton_hale.mdl",
    "models/player/hell_hale.mdl",
    "models/vsh/player/winter/saxton_hale.mdl"
}

local function IsHaleModel(model)
    for _, haleModel in ipairs(playerModelList) do
        if model == haleModel then
            return true
        end
    end
    return false
end


local gestureAnimations = {
    ["GO!"] = "gesture_melee_go",
    ["CHEER"] = "gesture_melee_cheer",
    ["HELP!"] = "gesture_melee_help",
    ["THANKS"] = "gesture_melee_positive",
    ["RAGE"] = "vsh_rage_attack"
}

local juliusSounds = {
    ["HELP!"] = {
        "mvm/julius_v7/julius_medic01.mp3",
        "mvm/julius_v7/julius_medic02.mp3",
        "mvm/julius_v7/julius_medic03.mp3",
        "mvm/julius_v7/julius_medic04.mp3",
        "mvm/julius_v7/julius_medic05.mp3",
        "mvm/julius_v7/julius_medic06.mp3",
        "mvm/julius_v7/julius_medic07.mp3",
        "mvm/julius_v7/julius_medic08.mp3",
        "mvm/julius_v7/julius_medic09.mp3",
        "mvm/julius_v7/julius_medic10.mp3",
        "mvm/julius_v7/julius_medic11.mp3",
        "mvm/julius_v7/julius_medic12.mp3",
        "mvm/julius_v7/julius_medic13.mp3",
        "mvm/julius_v7/julius_medic14.mp3",
        "mvm/julius_v7/julius_medic15.mp3",
        "mvm/julius_v7/julius_medic16.mp3",
        "mvm/julius_v7/julius_medic17.mp3",
        "mvm/julius_v7/julius_medic18.mp3",
        "mvm/julius_v7/julius_medic19.mp3",
        "mvm/julius_v7/julius_medic20.mp3",
        "mvm/julius_v7/julius_helpme01.mp3",
        "mvm/julius_v7/julius_helpme02.mp3",
        "mvm/julius_v7/julius_helpme03.mp3",
        "mvm/julius_v7/julius_helpme04.mp3",
        "mvm/julius_v7/julius_helpme05.mp3"

    },
    ["GO!"] = {
        "mvm/julius_v7/julius_moveup01.mp3",
        "mvm/julius_v7/julius_moveup02.mp3",
        "mvm/julius_v7/julius_moveup03.mp3",
        "mvm/julius_v7/julius_moveup04.mp3",
        "mvm/julius_v7/julius_moveup05.mp3",
        "mvm/julius_v7/julius_moveup06.mp3",
        "mvm/julius_v7/julius_moveup07.mp3",
        "mvm/julius_v7/julius_moveup08.mp3",
        "mvm/julius_v7/julius_moveup09.mp3",
        "mvm/julius_v7/julius_go01.mp3",
        "mvm/julius_v7/julius_go02.mp3",
        "mvm/julius_v7/julius_go03.mp3",
        "mvm/julius_v7/julius_go04.mp3",
        "mvm/julius_v7/julius_go05.mp3",
        "mvm/julius_v7/julius_go06.mp3",
        "mvm/julius_v7/julius_go07.mp3",
        "mvm/julius_v7/julius_go08.mp3",
        "mvm/julius_v7/julius_go09.mp3",
        "mvm/julius_v7/julius_go10.mp3"
    },
    ["CHEER"] = {
        "mvm/julius_v7/julius_battlecry01.mp3",
        "mvm/julius_v7/julius_battlecry02.mp3",
        "mvm/julius_v7/julius_battlecry03.mp3",
        "mvm/julius_v7/julius_battlecry04.mp3",
        "mvm/julius_v7/julius_battlecry05.mp3",
        "mvm/julius_v7/julius_battlecry06.mp3",
        "mvm/julius_v7/julius_battlecry07.mp3",
        "mvm/julius_v7/julius_blooper01.mp3"
    },
    ["THANKS"] = {
        "mvm/julius_v7/julius_niceshot01.mp3",
        "mvm/julius_v7/julius_niceshot02.mp3",
        "mvm/julius_v7/julius_niceshot03.mp3",
        "mvm/julius_v7/julius_niceshot04.mp3",
        "mvm/julius_v7/julius_niceshot05.mp3",
        "mvm/julius_v7/julius_thanks01.mp3",
        "mvm/julius_v7/julius_thanks02.mp3",
        "mvm/julius_v7/julius_thanks03.mp3",
        "mvm/julius_v7/julius_thanks04.mp3",
        "mvm/julius_v7/julius_thanks05.mp3",
        "mvm/julius_v7/julius_thanks06.mp3",
        "mvm/julius_v7/julius_thanks07.mp3",
        "mvm/julius_v7/julius_thanks08.mp3",
        "mvm/julius_v7/julius_thanks09.mp3",
        "mvm/julius_v7/julius_goodjob01.mp3",
        "mvm/julius_v7/julius_goodjob02.mp3",
        "mvm/julius_v7/julius_goodjob03.mp3",
        "mvm/julius_v7/julius_goodjob04.mp3",
        "mvm/julius_v7/julius_goodjob05.mp3",
        "mvm/julius_v7/julius_goodjob06.mp3",
        "mvm/julius_v7/julius_goodjob07.mp3"
    }
}

local juliusMeleeDareSounds = {
    "mvm/julius_v7/julius_meleedare01.mp3",
    "mvm/julius_v7/julius_meleedare02.mp3",
    "mvm/julius_v7/julius_meleedare03.mp3",
    "mvm/julius_v7/julius_meleedare04.mp3",
    "mvm/julius_v7/julius_meleedare05.mp3"
}

local flexTransitions = {
    current = 0,
    target = 0,
    speed = 5,
    currentFlex = nil,
    nextFlex = nil,
    cheerSequence = false,
    aggressiveTimer = 0,
    lastGesture = nil,
    saxtonRageFlex = false
}

local juliusFlexes = {
    ["HELP!"] = "painBigUpper",
    ["GO!"] = {"madUpper", "painSmallUpper"},
    ["THANKS"] = "Cocky",
    ["CHEER"] = "AggresiveClosed"
}

local juliusResetFlexes = {
    "CloseLidUp",
    "CloseLidLo"
}

local lastKnownModel = nil
local uiPanel = nil
local isKeyHeld = false
local lastPlayedGesture = nil
local currentHoveredText = nil
local isGesturePlaying = false
local gestureEndTime = 0
local GetEntityInFront
local IsHostileEntity
local PlayJuliusSound
local SmoothlySetFlex
local HandleCheerFlexTransition
local PlayGesture
local gestureKey = KEY_T -- Default key
local gestureKeyName = input.GetKeyName(gestureKey) or "T"
local rageFlexSpeed = 9 -- Default speed

-- Function to save the key binding to a file
local function SaveKeyBinding(key)
    if not file.Exists("maxwell_gestures", "DATA") then
        file.CreateDir("maxwell_gestures")
    end
    
    file.Write("maxwell_gestures/keybind.txt", tostring(key))
    gestureKey = key
    gestureKeyName = input.GetKeyName(key) or "T"
    
    chat.AddText(Color(255, 200, 0), "Gesture key bound to: ", Color(255, 255, 255), gestureKeyName)
end

-- Function to load the key binding from file
local function LoadKeyBinding()
    if file.Exists("maxwell_gestures/keybind.txt", "DATA") then
        local keyCode = tonumber(file.Read("maxwell_gestures/keybind.txt", "DATA"))
        if keyCode then
            gestureKey = keyCode
            gestureKeyName = input.GetKeyName(keyCode) or "T"
        end
    end
end

-- Load the key binding when the script starts
LoadKeyBinding()

-- Console command to set a custom key binding
concommand.Add("maxwell_playgestures", function(ply, cmd, args)
    if #args < 1 then
        return
    end
    
    local keyName = string.upper(args[1])
    local keyCode = input.GetKeyCode(keyName)
    
    if not keyCode then
        chat.AddText(Color(255, 0, 0), "Invalid key name: ", keyName)
        return
    end
    
    SaveKeyBinding(keyCode)
end)

-- Console command to reset the key binding to default
concommand.Add("maxwell_playgestures_reset", function()
    SaveKeyBinding(KEY_T)
    chat.AddText(Color(255, 200, 0), "Gesture key has been reset to default: T")
end)


-- Define the functions
GetEntityInFront = function()
    local ply = LocalPlayer()
    local eyePos = ply:EyePos()
    local eyeAngles = ply:EyeAngles()
    
    local traceData = {
        start = eyePos,
        endpos = eyePos + (eyeAngles:Forward() * 200),
        filter = ply
    }
    
    local trace = util.TraceLine(traceData)
    return trace.Entity
end

local SmoothlySetFlex = function(ply, flexName, targetValue)
    flexTransitions.target = targetValue
    flexTransitions.currentFlex = flexName
end

local ResetEyeLids = function(ply)
    if not IsValid(ply) then return end
    
    for _, flexName in ipairs(juliusResetFlexes) do
        local flexID = ply:GetFlexIDByName(flexName)
        if flexID then
            ply:SetFlexWeight(flexID, 0)
        end
    end
end


local HandleSaxtonRageFlex = function(ply)
    if not IsValid(ply) or not IsHaleModel(ply:GetModel()) then return end
    
    local flexID = ply:GetFlexIDByName("actionfire02")
    if flexID then
        local deltaTime = FrameTime() * rageFlexSpeed -- Use the adjustable speed
        
        if flexTransitions.saxtonRageFlex then
            -- Smoothly increase to 1
            local currentValue = ply:GetFlexWeight(flexID)
            local newValue = Lerp(deltaTime, currentValue, 1)
            ply:SetFlexWeight(flexID, newValue)
        else
            -- Smoothly decrease to 0
            local currentValue = ply:GetFlexWeight(flexID)
            local newValue = Lerp(deltaTime, currentValue, 0)
            ply:SetFlexWeight(flexID, newValue)
        end
    end
end

local HandleCheerFlexTransition = function(ply)
    local currentTime = CurTime()
    
    -- Only process if the last gesture was CHEER
    if flexTransitions.lastGesture != "CHEER" then return end
    
    -- If we're in a cheer sequence and AggresiveClosed is done
    if flexTransitions.cheerSequence and flexTransitions.currentFlex == "AggresiveClosed" and flexTransitions.current <= 0.1 then
        -- Start the Aggressive flex
        flexTransitions.currentFlex = "Aggressive"
        flexTransitions.target = 1
        flexTransitions.aggressiveTimer = currentTime + 0.5 -- Hold for half a second
    end
    
    -- If Aggressive has been at 1 for the timer duration
    if flexTransitions.currentFlex == "Aggressive" and flexTransitions.current >= 0.9 and currentTime > flexTransitions.aggressiveTimer then
        flexTransitions.target = 0
    end
    
    -- If Aggressive is done, end the sequence
    if flexTransitions.currentFlex == "Aggressive" and flexTransitions.current <= 0.1 then
        flexTransitions.cheerSequence = false
        flexTransitions.lastGesture = nil
    end
    
    -- Always ensure eyelids are reset during cheer sequence
    ResetEyeLids(ply)
end


IsHostileEntity = function(ent)
    if not IsValid(ent) then return false end
    if ent.IsNextbot then return true end
    if ent:IsNPC() then return true end
    if ent:IsPlayer() and ent:Team() != LocalPlayer():Team() then return true end
    return false
end

PlayJuliusSound = function(gestureType)
    if LocalPlayer():GetModel() != "models/vip/player/julius/julius.mdl" then return end

    if gestureType == "CHEER" then
        local entityInFront = GetEntityInFront()
        if IsHostileEntity(entityInFront) then
            local randomDareSound = juliusMeleeDareSounds[math.random(#juliusMeleeDareSounds)]
            surface.PlaySound(randomDareSound)
            return
        end
    end

    local soundList = juliusSounds[gestureType]
    if soundList then
        local randomSound = soundList[math.random(#soundList)]
        surface.PlaySound(randomSound)
    end
end 

local PlayGesture = function(ply, gestureName)-- PLEASE NEVER agian will i do this
    if not IsValid(ply) or isGesturePlaying or not ply:Alive() then return end
    
    local gestureSeq = ply:LookupSequence(gestureAnimations[gestureName])
    if gestureSeq then
        ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, gestureSeq, 0, true)
        lastPlayedGesture = gestureName
        isGesturePlaying = true
        gestureEndTime = CurTime() + ply:SequenceDuration(gestureSeq)
        PlayJuliusSound(gestureName)

        -- Handle flex animations for Julius
        if ply:GetModel() == "models/vip/player/julius/julius.mdl" then
            -- Always reset eyelids first
            ResetEyeLids(ply)
            
            local flexName = juliusFlexes[gestureName]
            
            -- Store the current gesture
            flexTransitions.lastGesture = gestureName
            
            -- Special handling for CHEER
            if gestureName == "CHEER" then
                flexTransitions.cheerSequence = true
                SmoothlySetFlex(ply, "AggresiveClosed", 1)
            elseif type(flexName) == "table" then
                for _, flex in ipairs(flexName) do
                    SmoothlySetFlex(ply, flex, 1)
                end
            elseif flexName then
                SmoothlySetFlex(ply, flexName, 1)
            end
        end
        
        -- Handle RAGE flex for Saxton Hale models
        if IsHaleModel(ply:GetModel()) and gestureName == "RAGE" then
            flexTransitions.saxtonRageFlex = true
        end
    end
end


hook.Add("Think", "CheckGestureCompletion", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    if isGesturePlaying and CurTime() > gestureEndTime then
        isGesturePlaying = false
        
        -- Handle Julius model
        if ply:GetModel() == "models/vip/player/julius/julius.mdl" then
            -- For CHEER, only reset AggresiveClosed to trigger the sequence
            if flexTransitions.lastGesture == "CHEER" then
                SmoothlySetFlex(ply, "AggresiveClosed", 0)
            else
                -- Reset all other flexes normally
                local flexName = juliusFlexes[flexTransitions.lastGesture]
                if type(flexName) == "table" then
                    for _, flex in ipairs(flexName) do
                        SmoothlySetFlex(ply, flex, 0)
                    end
                elseif flexName then
                    SmoothlySetFlex(ply, flexName, 0)
                end
            end
        end
        
        -- Reset Saxton Hale RAGE flex
        if IsHaleModel(ply:GetModel()) then
            flexTransitions.saxtonRageFlex = false
        end
    end
end)

hook.Add("Think", "CheckPlayerModelAndInput", function()
    local ply = LocalPlayer()
    
    if not IsValid(ply) or not ply:Alive() then
        if uiPanel and uiPanel:IsVisible() then
            uiPanel:SetVisible(false)
            gui.EnableScreenClicker(false)
            isKeyHeld = false
        end
        return
    end
end)

local function IsHaleModel(model)
    return table.HasValue(playerModelList, model)
end

local function CreateGestureButtons(panel, ply, startX, startY, buttonSize, padding)
    -- Base gestures that everyone gets
    local gestures = {"GO!", "CHEER", "HELP!", "THANKS"}
    
    -- Create the basic gesture buttons first
    for i, text in ipairs(gestures) do
        local col = (i - 1) % 4
        local row = math.floor((i - 1) / 4)
        
        local button = vgui.Create("DButton", panel)
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
            panel:SetVisible(false)
            gui.EnableScreenClicker(false)
        end
    end
    
    -- Add RAGE button only for Hale models
    if IsHaleModel(ply:GetModel()) then
        local rageButton = vgui.Create("DButton", panel)
        rageButton:SetText("RAGE")
        rageButton:SetSize(buttonSize, buttonSize)
        rageButton:SetPos(startX + 4 * (buttonSize + padding), startY) -- Position after other buttons
        rageButton:SetFont("Trebuchet24")
        rageButton:SetTextColor(Color(255, 255, 255))
        rageButton.OnCursorEntered = function()
            currentHoveredText = "RAGE"
        end
        rageButton.OnCursorExited = function()
            currentHoveredText = nil
        end
        rageButton.DoClick = function()
            PlayGesture(ply, "RAGE")
            panel:SetVisible(false)
            gui.EnableScreenClicker(false)
        end
    end
end

local function RecreateUI()
    if uiPanel and uiPanel:IsValid() then
        uiPanel:Remove()
    end
    uiPanel = nil
end

hook.Add("Think", "CheckPlayerModelAndInput", function()
    local ply = LocalPlayer()
    
    if not IsValid(ply) or not ply:Alive() then
        if uiPanel and uiPanel:IsVisible() then
            uiPanel:SetVisible(false)
            gui.EnableScreenClicker(false)
            isKeyHeld = false
        end
        return
    end
    
    -- Check if model changed
    local currentModel = ply:GetModel()
    if currentModel != lastKnownModel then
        lastKnownModel = currentModel
        RecreateUI()
    end
	
    if input.IsKeyDown(gestureKey) and not isKeyHeld then
        -- NEW: Check if player is typing in any text field
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
	end
    
    if input.IsKeyDown(gestureKey) and not isKeyHeld then
        if IsHaleModel(ply:GetModel()) or ply:GetModel() == "models/vip/player/julius/julius.mdl" then
            isKeyHeld = true
            gui.EnableScreenClicker(true)
            
            if not uiPanel then
                uiPanel = vgui.Create("DPanel")
                uiPanel:SetSize(ScrW(), ScrH())
                uiPanel:SetPaintBackground(false)
                uiPanel:SetMouseInputEnabled(true)
                
                local buttonSize = 100
                local padding = 10
                local startX = (ScrW() / 2) - (2 * (buttonSize + padding))
                local startY = (ScrH() / 2) - (2 * (buttonSize + padding))
                
                CreateGestureButtons(uiPanel, ply, startX, startY, buttonSize, padding)
            end
            
            uiPanel:SetVisible(true)
        end
    elseif not input.IsKeyDown(gestureKey) and isKeyHeld then
        isKeyHeld = false
        if uiPanel then
            if not currentHoveredText and lastPlayedGesture then
                PlayGesture(ply, lastPlayedGesture)
            end
            uiPanel:SetVisible(false)
            gui.EnableScreenClicker(false)
        end
    end
end)

hook.Add("PlayerBindPress", "HideUIOnRelease", function(ply, bind, pressed)
    if bind == "+use" and not pressed then
        if uiPanel then
            uiPanel:SetVisible(false)
            gui.EnableScreenClicker(false)
        end
        isKeyHeld = false
    end
end)

hook.Add("Think", "JuliusFlexTransitions", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    -- Handle Julius model flexes
    if ply:GetModel() == "models/vip/player/julius/julius.mdl" then
        -- Always ensure eyelids are reset
        ResetEyeLids(ply)

        local deltaTime = FrameTime() * flexTransitions.speed
        flexTransitions.current = Lerp(deltaTime, flexTransitions.current, flexTransitions.target)

        if flexTransitions.currentFlex then
            local flexID = ply:GetFlexIDByName(flexTransitions.currentFlex)
            if flexID then
                ply:SetFlexWeight(flexID, flexTransitions.current)
            end
            
            -- Handle the cheer sequence if active
            if flexTransitions.cheerSequence then
                HandleCheerFlexTransition(ply)
            end
        end
    end
    
    -- Handle Saxton Hale RAGE flex
    if IsHaleModel(ply:GetModel()) then
        HandleSaxtonRageFlex(ply)
    end
end)

concommand.Add("maxwell_playgestures_help", function()
    chat.AddText(Color(255, 200, 0), "Gesture System Help:")
    chat.AddText(Color(255, 200, 0), "Current gesture key: ", Color(255, 255, 255), gestureKeyName)
    chat.AddText(Color(255, 200, 0), "Commands:")
    chat.AddText(Color(255, 255, 255), "maxwell_playgestures <key> - Bind gestures to a specific key")
    chat.AddText(Color(255, 255, 255), "maxwell_playgestures_reset - Reset to default key (T)")
    chat.AddText(Color(255, 255, 255), "maxwell_playgestures_help - Show this help message")
    chat.AddText(Color(255, 255, 255), "maxwell_whataremygesturebinds  - Show what are your curret binds")
end)

concommand.Add("maxwell_whataremygesturebinds", function()
    chat.AddText(Color(255, 200, 0), "Usage: maxwell_playgestures <key>")
    chat.AddText(Color(255, 200, 0), "Current gesture key: ", Color(255, 255, 255), gestureKeyName)
end)