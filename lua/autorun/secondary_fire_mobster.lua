local TYPEWRITER_WEAPON_CLASS = "mobster_typewriter"
local GESTURE_NAMES = {"ss_alt_fire", "ss_alt_fire1", "ss_alt_fire2"}  -- Try these gestures in order
local VIEWMODEL_ANIMS_TO_DETECT = {"shove2", "shove"}
local GESTURE_SLOT = 4  -- Using a different slot from other gesture scripts to avoid conflicts
local GESTURE_DURATION = 1.0  -- Estimated duration of the gesture in seconds

-- Network setup
if SERVER then
    util.AddNetworkString("PlayTypewriterShoveGesture")
end

-- Function to check if the viewmodel is playing any of the specified animations
local function IsViewModelPlayingAnimations(ply, animNames)
    if CLIENT then
        local vm = ply:GetViewModel()
        if IsValid(vm) then
            local currentAnim = string.lower(vm:GetSequenceName(vm:GetSequence()))
            for _, animName in ipairs(animNames) do
                if string.find(currentAnim, string.lower(animName)) then
                    return true
                end
            end
        end
    end
    return false
end

-- Function to find a valid gesture from our list
local function FindValidGesture(ply)
    if not IsValid(ply) then return nil end
    
    -- Try each gesture in order
    for _, gestureName in ipairs(GESTURE_NAMES) do
        local gestureID = ply:LookupSequence(gestureName)
        if gestureID and gestureID > 0 then
            return gestureID, gestureName
        end
    end
    
    return nil, nil
end

-- Function to play the typewriter shove gesture
local function PlayTypewriterShoveGesture(ply)
    if not IsValid(ply) or not ply:Alive() then return end
    
    local gestureID, gestureName = FindValidGesture(ply)
    if not gestureID then return false end
    
    if CLIENT then
        -- Play the gesture locally
        ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT, gestureID, 0, true)
        return true, gestureName
    elseif SERVER then
        -- Broadcast to all clients
        net.Start("PlayTypewriterShoveGesture")
        net.WriteEntity(ply)
        net.WriteString(gestureName)  -- Send the gesture name to ensure consistency
        net.Broadcast()
        return true, gestureName
    end
    
    return false, nil
end

-- Client-side animation detection and networking
if CLIENT then
    -- Track when we last played the gesture
    local lastGestureTime = {}
    local isCurrentlyPlaying = {}
    local lastGestureName = {}
    
    -- Hook into the Think function to continuously check for the animation every tick
    hook.Add("Tick", "TypewriterShoveAnimationDetector", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
        
        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or weapon:GetClass() ~= TYPEWRITER_WEAPON_CLASS then 
            isCurrentlyPlaying[ply:SteamID()] = false
            return 
        end
        
        -- Check if the viewmodel is playing any of the specified animations
        local isPlaying = IsViewModelPlayingAnimations(ply, VIEWMODEL_ANIMS_TO_DETECT)
        local steamID = ply:SteamID()
        
        if isPlaying then
            local currentTime = CurTime()
            
            -- If we're not tracking this animation or the gesture has likely ended, play a new one
            if not isCurrentlyPlaying[steamID] or 
               (lastGestureTime[steamID] and currentTime - lastGestureTime[steamID] >= GESTURE_DURATION) then
                
                -- Play gesture locally
                local success, gestureName = PlayTypewriterShoveGesture(ply)
                if success then
                    lastGestureTime[steamID] = currentTime
                    isCurrentlyPlaying[steamID] = true
                    lastGestureName[steamID] = gestureName
                    
                    -- Notify server to broadcast to other clients
                    net.Start("PlayTypewriterShoveGesture")
                    net.WriteEntity(ply)
                    net.WriteString(gestureName)
                    net.SendToServer()
                end
            end
        else
            -- Reset when animation ends
            isCurrentlyPlaying[steamID] = false
        end
    end)
    
    -- Client-side network receiver
    net.Receive("PlayTypewriterShoveGesture", function()
        local ply = net.ReadEntity()
        local gestureName = net.ReadString()
        
        if IsValid(ply) and ply:Alive() and ply ~= LocalPlayer() then
            local gestureID = ply:LookupSequence(gestureName)
            if gestureID and gestureID > 0 then
                ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT, gestureID, 0, true)
                
                local steamID = ply:SteamID()
                lastGestureTime[steamID] = CurTime()
                isCurrentlyPlaying[steamID] = true
                lastGestureName[steamID] = gestureName
            end
        end
    end)
    
    -- Clean up player data when they disconnect
    hook.Add("PlayerDisconnected", "CleanupTypewriterGestureData_Client", function(ply)
        if ply and ply:IsValid() then
            local steamID = ply:SteamID()
            lastGestureTime[steamID] = nil
            isCurrentlyPlaying[steamID] = nil
            lastGestureName[steamID] = nil
        end
    end)
end

-- Server-side network handling
if SERVER then
    -- Track when we last played the gesture for each player
    local lastGestureTime = {}
    
    net.Receive("PlayTypewriterShoveGesture", function(len, ply)
        if not IsValid(ply) or not ply:Alive() then return end
        
        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or weapon:GetClass() ~= TYPEWRITER_WEAPON_CLASS then return end
        
        local gestureName = net.ReadString()
        local currentTime = CurTime()
        local steamID = ply:SteamID()
        
        -- Prevent spam by checking if enough time has passed since the last gesture
        if lastGestureTime[steamID] and currentTime - lastGestureTime[steamID] < GESTURE_DURATION * 0.8 then
            return
        end
        
        lastGestureTime[steamID] = currentTime
        
        -- Broadcast to all other clients
        net.Start("PlayTypewriterShoveGesture")
        net.WriteEntity(ply)
        net.WriteString(gestureName)
        net.SendOmit(ply)  -- Send to everyone except the original player
    end)
    
    -- Clean up player data when they disconnect
    hook.Add("PlayerDisconnected", "CleanupTypewriterGestureData_Server", function(ply)
        if ply and ply:IsValid() then
            lastGestureTime[ply:SteamID()] = nil
        end
    end)
end