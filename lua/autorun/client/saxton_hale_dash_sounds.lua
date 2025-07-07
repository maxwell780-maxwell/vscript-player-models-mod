local SAXTON_MODELS = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/saxton_hale_3.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true,
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true,
    ["models/vsh/player/mecha_hale.mdl"] = true
}

local DEFAULT_HALE = {
    ["models/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/santa_hale.mdl"] = true,
    ["models/saxton_hale_3.mdl"] = true,
    ["models/vsh/player/saxton_hale.mdl"] = true,
    ["models/vsh/player/winter/saxton_hale.mdl"] = true,
    ["models/subzero_saxton_hale.mdl"] = true
}

local HELL_HALE = {
    ["models/vsh/player/hell_hale.mdl"] = true,
    ["models/player/hell_hale.mdl"] = true
}

local MECHA_HALE = {
    ["models/vsh/player/mecha_hale.mdl"] = true
}

local lastDashAnimation = ""
local lastSoundTime = 0
local DASH_COOLDOWN = 0.5 -- Prevent spam
local GESTURE_SLOT = 3 -- Custom gesture slot

-- Server-side networking
if SERVER then
    util.AddNetworkString("HaleDashGesturePlay")
    
    -- Function to trigger gesture from server
    local function TriggerDashGesture(ply, gestureName)
        if not IsValid(ply) then return end
        
        net.Start("HaleDashGesturePlay")
        net.WriteEntity(ply)
        net.WriteString(gestureName)
        net.Broadcast()
    end
    
    -- You can call this from other server-side code if needed
    -- TriggerDashGesture(player, "vsh_dash_attack_in")
end

-- Client-side code
if CLIENT then
    -- Network receiver for gesture playing
    net.Receive("HaleDashGesturePlay", function()
        local ply = net.ReadEntity()
        local gestureName = net.ReadString()
        
        if not IsValid(ply) then return end
        
        local gestureID = ply:LookupSequence(gestureName)
        if gestureID and gestureID >= 0 then
            ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT, gestureID, 0, true)
            print("Playing gesture: " .. gestureName .. " (ID: " .. gestureID .. ")")
        else
            print("Gesture not found: " .. gestureName)
        end
    end)
    
    -- Local function to play gesture directly on client
    local function PlayDashGesture(ply, gestureName)
        if not IsValid(ply) then return end
        
        local gestureID = ply:LookupSequence(gestureName)
        if gestureID and gestureID >= 0 then
            ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT, gestureID, 0, true)
        end
    end

    local function PlayDashSound(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        
        -- Check if player has the correct weapon
        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or weapon:GetClass() ~= "weapon_saxton_hale_swep" then return end
        
        -- Check if player has correct model
        local model = string.lower(ply:GetModel() or "")
        if not SAXTON_MODELS[model] then return end
        
        -- Get viewmodel
        local vm = ply:GetViewModel()
        if not IsValid(vm) then return end
        
        -- Check current viewmodel animation
        local currentAnim = vm:GetSequenceName(vm:GetSequence()) or ""
        local isDashLoop = (currentAnim == "vsh_dash_loop")
		local isDashStart = (currentAnim == "vsh_dash_start")
        local isDashEnd = (currentAnim == "vsh_dash_end")
		local isMegaPunchReady = (currentAnim == "vsh_megapunch_ready")
        
        -- Handle gesture changes based on viewmodel animation
		if (isDashLoop or isDashStart) and lastDashAnimation ~= currentAnim then
            -- Starting dash loop - play dash attack in gesture
            PlayDashGesture(ply, "vsh_dash_attack_in")
            
            -- Also play dash sound
            if (CurTime() - lastSoundTime) > DASH_COOLDOWN then
                local soundList = {}
                
                if DEFAULT_HALE[model] then
                    soundList = {
                        "mvm/saxton_hale_by_matthew_simmons/dash_a_01.mp3",
                        "mvm/saxton_hale_by_matthew_simmons/dash_a_02.mp3",
                        "mvm/saxton_hale_by_matthew_simmons/dash_b_01.mp3",
                        "mvm/saxton_hale_by_matthew_simmons/dash_b_02.mp3",
                        "mvm/saxton_hale_by_matthew_simmons/dash_b_03.mp3",
                        "mvm/saxton_hale_by_matthew_simmons/dash_c_01.mp3",
                        "mvm/saxton_hale_by_matthew_simmons/dash_c_02.mp3",
                        "mvm/saxton_hale_by_matthew_simmons/dash_c_03.mp3"
                    }
                elseif HELL_HALE[model] then
                    soundList = {
                        "mvm/hellfire_hale_matthew_simmons2/dash_a_01.mp3",
                        "mvm/hellfire_hale_matthew_simmons2/dash_a_02.mp3",
                        "mvm/hellfire_hale_matthew_simmons2/dash_b_01.mp3",
                        "mvm/hellfire_hale_matthew_simmons2/dash_b_02.mp3",
                        "mvm/hellfire_hale_matthew_simmons2/dash_b_03.mp3",
                        "mvm/hellfire_hale_matthew_simmons2/dash_c_01.mp3",
                        "mvm/hellfire_hale_matthew_simmons2/dash_c_02.mp3",
                        "mvm/hellfire_hale_matthew_simmons2/dash_c_03.mp3"
                    }
                elseif MECHA_HALE[model] then
                    soundList = {
                        "mvm/vsh_mecha/mecha_hale_edit/dash_a_01.mp3",
                        "mvm/vsh_mecha/mecha_hale_edit/dash_a_02.mp3",
                        "mvm/vsh_mecha/mecha_hale_edit/dash_b_01.mp3",
                        "mvm/vsh_mecha/mecha_hale_edit/dash_b_02.mp3",
                        "mvm/vsh_mecha/mecha_hale_edit/dash_b_03.mp3",
                        "mvm/vsh_mecha/mecha_hale_edit/dash_c_01.mp3",
                        "mvm/vsh_mecha/mecha_hale_edit/dash_c_02.mp3"
                    }
                end
                
                if #soundList > 0 then
                    ply:EmitSound(soundList[math.random(#soundList)], 75, 100)
                    lastSoundTime = CurTime()
                end
            end
        elseif isDashEnd and lastDashAnimation ~= "vsh_dash_end" then
            PlayDashGesture(ply, "vsh_dash_attack_end")

        elseif isMegaPunchReady and lastDashAnimation ~= "vsh_megapunch_ready" then
            PlayDashGesture(ply, "gesture_melee_cheer")
        end

        -- Update last animation state
        if isDashLoop then
            lastDashAnimation = "vsh_dash_loop"
		elseif isDashStart then
			lastDashAnimation = "vsh_dash_start"
        elseif isDashEnd then
            lastDashAnimation = "vsh_dash_end"
		elseif isMegaPunchReady then
			lastDashAnimation = "vsh_megapunch_ready"
		else
            lastDashAnimation = ""
        end
    end

    hook.Add("Think", "SaxtonHaleDashSound", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        PlayDashSound(ply)
    end)

    -- Debug command to check current viewmodel animation and gestures
    concommand.Add("check_dash_anim", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then 
            print("Player not valid")
            return 
        end
        
        local vm = ply:GetViewModel()
        if not IsValid(vm) then
            print("Viewmodel not valid")
            return
        end
        
        local currentSeq = vm:GetSequence()
        local currentAnim = vm:GetSequenceName(currentSeq) or "unknown"
        
        print("=== Viewmodel Animation Debug ===")
        print("Current sequence: " .. currentSeq)
        print("Current animation: " .. currentAnim)
        print("Is dash loop: " .. (currentAnim == "vsh_dash_loop" and "YES" or "NO"))
        print("Is dash end: " .. (currentAnim == "vsh_dash_end" and "YES" or "NO"))
        print("Player model: " .. ply:GetModel())
        
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            print("Active weapon: " .. weapon:GetClass())
        else
            print("No active weapon")
        end
    end)

    -- Debug command to test gestures directly
    concommand.Add("test_dash_gesture", function(ply, cmd, args)
        local ply = LocalPlayer()
        if not IsValid(ply) then 
            print("Player not valid")
            return 
        end
        
        local gestureName = args[1] or "vsh_dash_attack_in"
        print("Testing gesture: " .. gestureName)
        PlayDashGesture(ply, gestureName)
    end)

    -- Debug command to list all available sequences
    concommand.Add("list_hale_sequences", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then 
            print("Player not valid")
            return 
        end
        
        print("=== Available sequences for " .. ply:GetModel() .. " ===")
        for i = 0, ply:GetSequenceCount() - 1 do
            local seqName = ply:GetSequenceName(i)
            if seqName and string.find(string.lower(seqName), "dash") then
                print("  " .. i .. ": " .. seqName)
            end
        end
    end)
end
