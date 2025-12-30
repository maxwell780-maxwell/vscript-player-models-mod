if SERVER then return end

local playerModelList = {
    "models/player/saxton_hale.mdl",
    "models/saxton_hale_3.mdl",
    "models/vsh/player/saxton_hale.mdl",
    "models/vsh/player/santa_hale.mdl",
    "models/vsh/player/hell_hale.mdl",
    "models/vsh/player/mecha_hale.mdl",
    "models/player/clone/doplaganger/blue_clolored_tf2_vscript_saxton_hale.mdl",
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


local lastKnownModel = nil
local uiPanel = nil
local isKeyHeld = false
local lastPlayedGesture = nil
local currentHoveredText = nil
local isGesturePlaying = false
local gestureEndTime = 0
local GetEntityInFront
local IsHostileEntity
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



local PlayGesture = function(ply, gestureName)-- PLEASE NEVER agian will i do this
    if not IsValid(ply) or isGesturePlaying or not ply:Alive() then return end
    
    local gestureSeq = ply:LookupSequence(gestureAnimations[gestureName])
    if gestureSeq then
        ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, gestureSeq, 0, true)
        lastPlayedGesture = gestureName
        isGesturePlaying = true
        gestureEndTime = CurTime() + ply:SequenceDuration(gestureSeq)

            
            -- Store the current gesture
            flexTransitions.lastGesture = gestureName
            
        
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

local function CreateGestureButtons(panel, ply)
    local gestures = { "GO!", "CHEER", "HELP!", "THANKS" }

    local size = 100
    local padding = 10
    local startX = ScrW() / 2 - 2 * (size + padding)
    local startY = ScrH() / 2 - (size + padding)

    for i, g in ipairs(gestures) do
        local btn = vgui.Create("DButton", panel)
        btn:SetSize(size, size)
        btn:SetPos(startX + (i - 1) * (size + padding), startY)
        btn:SetText(g)
        btn:SetFont("Trebuchet24")
        btn:SetTextColor(color_white)

        btn.DoClick = function()
            PlayGesture(ply, g)
            panel:SetVisible(false)
            gui.EnableScreenClicker(false)
        end
    end

    if IsHaleModel(ply:GetModel()) then
        local rage = vgui.Create("DButton", panel)
        rage:SetSize(size, size)
        rage:SetPos(startX + 4 * (size + padding), startY)
        rage:SetText("RAGE")
        rage:SetFont("Trebuchet24")
        rage:SetTextColor(color_white)

        rage.DoClick = function()
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
        if IsHaleModel(ply:GetModel()) then
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

hook.Add("Think", "SaxtonRageFlexThink", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    if not IsHaleModel(ply:GetModel()) then return end

    local flexID = ply:GetFlexIDByName("actionfire02")
    if not flexID then return end

    local delta = FrameTime() * rageFlexSpeed
    local current = ply:GetFlexWeight(flexID)

    local target = flexTransitions.saxtonRageFlex and 1 or 0
    ply:SetFlexWeight(flexID, Lerp(delta, current, target))
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
