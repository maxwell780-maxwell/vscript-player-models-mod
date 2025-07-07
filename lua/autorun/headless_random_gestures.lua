local HEADLESS_HATMAN_MODEL = "models/bots/headless_hatman.mdl"
local GESTURE_INTERVAL = 5 -- Time in seconds between gesture plays

-- Spawn intro settings
local SPAWN_GESTURE = "spawn" -- The gesture to play on spawn
local SPAWN_SOUND = "ui/halloween_boss_summoned_fx.wav"
local SPAWN_FREEZE_DURATION = 6.3 -- How long to freeze the player during spawn animation (seconds)

local REGULAR_GESTURES = {
    "gesture_air_grab_shake",
    "gesture_melee_go",
    "gesture_point_down"
}

-- Rare gesture
local RARE_GESTURE = "gesture_melee_help"
local RARE_GESTURE_CHANCE = 15 -- Percentage chance (out of 100) for the rare gesture to play

-- Sound effects for regular gestures
local REGULAR_SOUNDS = {
    "vo/halloween_boss/knight_laugh01.mp3",
    "vo/halloween_boss/knight_laugh02.mp3",
    "vo/halloween_boss/knight_laugh03.mp3",
    "vo/halloween_boss/knight_laugh04.mp3"
}

-- Sound effects for the rare gesture
local RARE_SOUNDS = {
    "vo/halloween_boss/knight_alert01.mp3",
    "vo/halloween_boss/knight_alert02.mp3"
}

-- Pain sounds
local PAIN_SOUNDS = {
    "vo/halloween_boss/knight_pain01.mp3",
    "vo/halloween_boss/knight_pain02.mp3",
    "vo/halloween_boss/knight_pain03.mp3"
}

-- Table to store timers for each player
local playerTimers = {}
local frozenPlayers = {}
local lastPainSound = {} -- To prevent sound spam

-- Server-side networking setup
if SERVER then
    util.AddNetworkString("PlayCustomGesture")
    util.AddNetworkString("PlayCustomGestureClient")
    util.AddNetworkString("PlayHatmanSound")
    util.AddNetworkString("PlaySpawnSequence")
    
    -- Function to freeze a player
    local function FreezePlayer(ply)
        if not IsValid(ply) then return end
        
        -- Store original movement values
        frozenPlayers[ply:SteamID()] = {
            walkSpeed = ply:GetWalkSpeed(),
            runSpeed = ply:GetRunSpeed(),
            jumpPower = ply:GetJumpPower()
        }
        
        -- Disable movement
        ply:SetWalkSpeed(1)
        ply:SetRunSpeed(1)
        ply:SetJumpPower(0)
    end
    
    -- Function to unfreeze a player
    local function UnfreezePlayer(ply)
        if not IsValid(ply) then return end
        
		local originalValues = frozenPlayers[ply:SteamID()]
		if originalValues then
			-- Restore original movement values for walk speed and jump power
			ply:SetWalkSpeed(444.5)

        
			-- Set run speed to 444.5 instead of original value
			ply:SetRunSpeed(444.5)
        
			ply:SetJumpPower(originalValues.jumpPower)
			frozenPlayers[ply:SteamID()] = nil
        end
    end
    
    -- Handle the network message from clients
    net.Receive("PlayCustomGesture", function(len, ply)
        local target = net.ReadEntity()
        local gesture = net.ReadString()
        local isRare = net.ReadBool()
        
        -- Only allow players to trigger gestures on themselves or if they're admin
        if IsValid(target) and (target == ply or ply:IsAdmin()) and target:Alive() then
            -- Broadcast gesture to all clients
            net.Start("PlayCustomGestureClient")
            net.WriteEntity(target)
            net.WriteString(gesture)
            net.WriteBool(isRare)
            net.Broadcast()
            
            -- Select appropriate sound list based on gesture type
            local soundList = isRare and RARE_SOUNDS or REGULAR_SOUNDS
            local randomSound = soundList[math.random(#soundList)]
            
            -- Broadcast sound to all clients
            net.Start("PlayHatmanSound")
            net.WriteEntity(target)
            net.WriteString(randomSound)
            net.Broadcast()
        end
    end)
    
    -- Handle spawn sequence request
    net.Receive("PlaySpawnSequence", function(len, ply)
        local target = net.ReadEntity()
        
        if IsValid(target) and target:Alive() and target:GetModel() == HEADLESS_HATMAN_MODEL then
            -- Freeze the player
            FreezePlayer(target)
            
            -- Play spawn gesture
            net.Start("PlayCustomGestureClient")
            net.WriteEntity(target)
            net.WriteString(SPAWN_GESTURE)
            net.WriteBool(false)
            net.Broadcast()
            
            -- Play spawn sound
            net.Start("PlayHatmanSound")
            net.WriteEntity(target)
            net.WriteString(SPAWN_SOUND)
            net.Broadcast()
            
            -- Unfreeze after animation
            timer.Simple(SPAWN_FREEZE_DURATION, function()
                if IsValid(target) and target:Alive() then
                    UnfreezePlayer(target)
                end
            end)
        end
    end)
    
    -- Play pain sounds when player takes damage
    hook.Add("EntityTakeDamage", "HeadlessHatmanPainSounds", function(target, dmginfo)
        if IsValid(target) and target:IsPlayer() and target:Alive() and target:GetModel() == HEADLESS_HATMAN_MODEL then
            -- Check if damage is significant enough
            if dmginfo:GetDamage() >= 1 then
                -- Prevent sound spam by checking last pain sound time
                local currentTime = CurTime()
                if not lastPainSound[target:SteamID()] or (currentTime - lastPainSound[target:SteamID()]) > 1 then
                    lastPainSound[target:SteamID()] = currentTime
                    
                    -- Play a random pain sound
                    local randomPainSound = PAIN_SOUNDS[math.random(#PAIN_SOUNDS)]
                    
                    net.Start("PlayHatmanSound")
                    net.WriteEntity(target)
                    net.WriteString(randomPainSound)
                    net.Broadcast()
                end
            end
        end
    end)
    
    -- Cleanup frozen state if player dies
    hook.Add("PlayerDeath", "HeadlessHatmanUnfreeze", function(ply)
        UnfreezePlayer(ply)
    end)
    
    -- Cleanup frozen state if player disconnects
    hook.Add("PlayerDisconnected", "HeadlessHatmanDisconnectUnfreeze", function(ply)
        UnfreezePlayer(ply)
    end)
end

-- Function to play a gesture on a player with appropriate sound
local function PlayGesture(ply, gesture, isRare)
    if not IsValid(ply) then return end
    if not ply:Alive() then return end
    if ply:GetModel() ~= HEADLESS_HATMAN_MODEL then return end
    
    if CLIENT then
        -- Send gesture and rarity info to server
        net.Start("PlayCustomGesture")
        net.WriteEntity(ply)
        net.WriteString(gesture)
        net.WriteBool(isRare)
        net.SendToServer()
    end
end

-- Function to play a random gesture on a player
local function PlayRandomGesture(ply)
    if not IsValid(ply) then return end
    if not ply:Alive() then return end
    if ply:GetModel() ~= HEADLESS_HATMAN_MODEL then return end
    
    -- Determine if we should play the rare gesture
    local playRare = (math.random(100) <= RARE_GESTURE_CHANCE)
    
    if playRare then
        -- Play the rare gesture
        PlayGesture(ply, RARE_GESTURE, true)
    else
        -- Select a random regular gesture
        local randomGesture = REGULAR_GESTURES[math.random(#REGULAR_GESTURES)]
        PlayGesture(ply, randomGesture, false)
    end
end

-- Function to play the spawn sequence
local function PlaySpawnSequence(ply)
    if not IsValid(ply) then return end
    if not ply:Alive() then return end
    if ply:GetModel() ~= HEADLESS_HATMAN_MODEL then return end
    
    if CLIENT then
        net.Start("PlaySpawnSequence")
        net.WriteEntity(ply)
        net.SendToServer()
    end
end

-- Register the net messages on the client
if CLIENT then
    net.Receive("PlayCustomGestureClient", function()
        local ply = net.ReadEntity()
        local gesture = net.ReadString()
        local isRare = net.ReadBool() -- We still read this even though we don't use it directly
        
        if IsValid(ply) and ply:Alive() then
            local gestureID = ply:LookupSequence(gesture)
            if gestureID and gestureID > 0 then
                ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, gestureID, 0, true)
            end
        end
    end)
    
    net.Receive("PlayHatmanSound", function()
        local ply = net.ReadEntity()
        local sound = net.ReadString()
        
        if IsValid(ply) and ply:Alive() then
            ply:EmitSound(sound, 75, 100, 1)
        end
    end)
end

-- Function to start gesture timer for a player
local function StartGestureTimer(ply)
    if not IsValid(ply) then return end
    if not CLIENT then return end -- Only run this on client
    if not ply:Alive() then return end
    
    -- Clear any existing timer for this player
    if playerTimers[ply:SteamID()] then
        timer.Remove(playerTimers[ply:SteamID()])
    end
    
    -- Create a unique timer name for this player
    local timerName = "HeadlessHatmanGestures_" .. ply:SteamID()
    playerTimers[ply:SteamID()] = timerName
    
    -- Create the timer
    timer.Create(timerName, GESTURE_INTERVAL, 0, function()
        if IsValid(ply) and ply:Alive() then
            PlayRandomGesture(ply)
        else
            -- Remove timer if player is no longer valid or dead
            timer.Remove(timerName)
            playerTimers[ply:SteamID()] = nil
        end
    end)
    
    -- Play a gesture immediately
    PlayRandomGesture(ply)
end

-- Function to stop gesture timer for a player
local function StopGestureTimer(ply)
    if not CLIENT then return end
    if not ply or not IsValid(ply) then return end
    
    if playerTimers[ply:SteamID()] then
        timer.Remove(playerTimers[ply:SteamID()])
        playerTimers[ply:SteamID()] = nil
    end
end

if CLIENT then
    -- Check when players spawn
    hook.Add("PlayerSpawn", "HeadlessHatmanGestureCheck", function(ply)
        -- Wait a moment for the model to be fully set
        timer.Simple(1, function()
            if IsValid(ply) and ply:Alive() and ply:GetModel() == HEADLESS_HATMAN_MODEL then
                -- First play the spawn sequence
                PlaySpawnSequence(ply)
                
                -- Then start the regular gesture timer after the spawn animation finishes
                timer.Simple(SPAWN_FREEZE_DURATION + 0.5, function()
                    if IsValid(ply) and ply:Alive() and ply:GetModel() == HEADLESS_HATMAN_MODEL then
                        StartGestureTimer(ply)
                    end
                end)
            end
        end)
    end)

    -- Monitor player model changes
    hook.Add("Think", "HeadlessHatmanModelMonitor", function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                local currentModel = ply:GetModel()
                
                -- If player has the Headless Hatman model and no timer, start spawn sequence
                if currentModel == HEADLESS_HATMAN_MODEL and ply:Alive() and not playerTimers[ply:SteamID()] and not ply.HatmanSpawnPlayed then
                    ply.HatmanSpawnPlayed = true
                    PlaySpawnSequence(ply)
                    
                    -- Start regular gestures after spawn sequence
                    timer.Simple(SPAWN_FREEZE_DURATION + 0.5, function()
                        if IsValid(ply) and ply:Alive() and ply:GetModel() == HEADLESS_HATMAN_MODEL then
                            StartGestureTimer(ply)
                        end
                    end)
                -- If player changed from Headless Hatman to something else or died, remove timer
                elseif (currentModel ~= HEADLESS_HATMAN_MODEL or not ply:Alive()) and playerTimers[ply:SteamID()] then
                    StopGestureTimer(ply)
                    ply.HatmanSpawnPlayed = false
                end
            end
        end
    end)

    -- Stop gestures when player dies
    hook.Add("PlayerDeath", "HeadlessHatmanDeathStop", function(ply)
        StopGestureTimer(ply)
        ply.HatmanSpawnPlayed = false
    end)

    -- Clean up timers when a player disconnects
    hook.Add("PlayerDisconnected", "HeadlessHatmanCleanup", function(ply)
        StopGestureTimer(ply)
    end)
end