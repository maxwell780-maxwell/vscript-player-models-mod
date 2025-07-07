if not CLIENT then return end

-- Table of Hale models and their corresponding aura models its actully the BEST and effective way if dealing with aura effects MEGA THANKS TO sourcegraph please do support them as the ai made this code
local haleAuraModels = { 
    ["models/player/saxton_hale.mdl"] = {
        body = "models/player/items/vsh_effect_body_aura.mdl",
        leftArm = "models/player/items/vsh_effect_ltarm_aura.mdl",
        rightArm = "models/player/items/vsh_effect_rtarm_aura.mdl"
    },
    ["models/vsh/player/saxton_hale.mdl"] = {
        body = "models/player/items/vsh_effect_body_aura.mdl",
        leftArm = "models/player/items/vsh_effect_ltarm_aura.mdl",
        rightArm = "models/player/items/vsh_effect_rtarm_aura.mdl"
    },
    ["models/vip_mobster/player/mobster.mdl"] = { -- finnaly fixed mobster
        body = "models/vip_mobster/w_cigar.mdl",
        leftArm = "models/vip_mobster/weapons/w_cigar.mdl",
        rightArm = "models/vip_mobster/weapons/w_cigar.mdl"
    },
    ["models/bots/hwn_botler/hwn_botler_boss.mdl"] = { 
        body = "models/player/items/demo/crown.mdl",
        leftArm = "models/player/items/demo/crown.mdl",
        rightArm = "models/player/items/demo/crown.mdl"
    },
    ["models/player/redmond_mann.mdl"] = {
        body = "models/vsh/player/items/vsh_effect_body_aura.mdl",
        leftArm = "models/vsh/player/items/vsh_effect_ltarm_aura.mdl",
        rightArm = "models/vsh/player/items/vsh_effect_rtarm_aura.mdl"
    },
    ["models/player/blutarch_mann.mdl"] = {
        body = "models/vsh/player/items/vsh_effect_body_aura.mdl",
        leftArm = "models/vsh/player/items/vsh_effect_ltarm_aura.mdl",
        rightArm = "models/vsh/player/items/vsh_effect_rtarm_aura.mdl"
    },
    ["models/subzero_saxton_hale.mdl"] = {
        body = "models/player/items/vsh_effect_body_aura.mdl",
        leftArm = "models/player/items/vsh_effect_ltarm_aura.mdl",
        rightArm = "models/player/items/vsh_effect_rtarm_aura.mdl"
    },
    ["models/saxton_hale_3.mdl"] = {
        body = "models/player/items/vsh_effect_body_aura.mdl",
        leftArm = "models/player/items/vsh_effect_ltarm_aura.mdl",
        rightArm = "models/player/items/vsh_effect_rtarm_aura.mdl"
    },
    ["models/vsh/player/santa_hale.mdl"] = {
        body = "models/vsh/player/items/vsh_effect_body_aura.mdl",
        leftArm = "models/player/items/santa/vsh_effect_ltarm_aura.mdl",
        rightArm = "models/player/items/santa/vsh_effect_rtarm_aura.mdl"
    },
    ["models/vsh/player/mecha_hale.mdl"] = {
        body = "models/vsh/player/items/vsh_effect_body_aura_mecha_hale.mdl",
        leftArm = "models/vsh/player/items/vsh_effect_ltarm_aura_mecha_hale.mdl",
        rightArm = "models/vsh/player/items/vsh_effect_rtarm_aura_mecha_hale.mdl"
    },
    ["models/vsh/player/hell_hale.mdl"] = {
        body = "models/player/items/vsh_effect_body_aura.mdl",
        leftArm = "models/player/items/vsh_effect_ltarm_aura.mdl",
        rightArm = "models/player/items/vsh_effect_rtarm_aura.mdl"
    },
    ["models/player/hell_hale.mdl"] = {
        body = "models/vsh/player/items/vsh_effect_body_aura.mdl",
        leftArm = "models/vsh/player/items/vsh_effect_ltarm_aura.mdl",
        rightArm = "models/vsh/player/items/vsh_effect_rtarm_aura.mdl"
    },
    ["models/vsh/player/winter/saxton_hale.mdl"] = {
        body = "models/player/items/vsh_effect_body_aura.mdl",
        leftArm = "models/player/items/vsh_effect_ltarm_aura.mdl",
        rightArm = "models/player/items/vsh_effect_rtarm_aura.mdl"
    }
} -- models/vip_mobster/w_cigar.mdl

local specialAttachments = { -- models/vip_mobster/player/mobster.mdl
    ["models/vip/player/civilian/julius.mdl"] = {
        hat = "models/vip/player/civilian/julius_hat.mdl"
    }
}

-- Special aura models for specific skins
local specialRightArmAura = "models/player/items/vsh_effect_rtarm_aura_chargedash.mdl"
local specialLeftArmAura = "models/player/items/vsh_effect_ltarm_aura_megapunch.mdl"

-- Mecha Hale special thruster models
local mechaLegThrusters = "models/vsh/player/items/thrusters_legs_fx_constant.mdl"
local mechaBackThrusters = "models/vsh/player/items/thrusters_back_fx_constant.mdl"

-- Mecha Hale dash animations that should trigger back thrusters
local mechaDashAnimations = {
    ["vsh_dash_chargeup"] = true,
    ["vsh_dash_chargeup_air"] = true,
    ["vsh_dash_chargeup_air_crouchfix"] = true,
    ["vsh_dash_chargeup_airwalk"] = true,
    ["vsh_dash_chargeup_airwalk_crouchfix"] = true,
    ["vsh_dash_chargeup_walk"] = true,
    ["vsh_dash_chargeup_walk_crouchfix"] = true,
    ["vsh_dash_chargeup_crouchfix"] = true
}

-- Models that should be excluded from special left arm aura and i tottaly forgot to include the mobster oopsie 
local excludeFromMegapunch = {
    ["models/saxton_hale_3.mdl"] = true,
    ["models/vsh/player/mecha_hale.mdl"] = true,
    ["models/bots/hwn_botler/hwn_botler_boss.mdl"] = true,
    ["models/vip_mobster/player/mobster.mdl"] = true
}

-- Default aura models if specific ones aren't found
local defaultAuraModels = {
    body = "models/player/items/vsh_effect_body_aura.mdl",
    leftArm = "models/player/items/vsh_effect_ltarm_aura.mdl",
    rightArm = "models/player/items/vsh_effect_rtarm_aura.mdl"
}

-- Track auras for each player
local playerAuras = {}
-- Track player skins to detect changes
local playerSkins = {}
-- Track player velocities for jump detection
local playerVelocities = {}
-- Track player ground state
local playerOnGround = {}
-- Track player animations
local playerAnimations = {}
-- Track last ground check time
local lastGroundCheck = {}

-- Function to create an aura and properly attach it NEW AND APROVED i call it the CreateAura function rhymes with grug and also this was a pain to deal with honestly
local function CreateAura(ply, model)
    if not IsValid(ply) then return nil end
    
    local aura = ClientsideModel(model)
    if not IsValid(aura) then return nil end
    
    aura:SetParent(ply)
    aura:AddEffects(EF_BONEMERGE)
    aura:SetNoDraw(false)
    
    -- Ensure proper positioning
    aura:SetPos(ply:GetPos())
    aura:SetAngles(ply:GetAngles())
    
    -- Set initial skin to match player (with fallback check)
    if aura:SkinCount() > 0 then
        aura:SetSkin(ply:GetSkin() or 0)
    end
    
    -- Create a unique hook for this specific aura to monitor skin changes
    local hookName = "UpdateAuraSkin_" .. aura:EntIndex()
    hook.Add("Think", hookName, function()
        if not IsValid(aura) or not IsValid(ply) then
            hook.Remove("Think", hookName)
            return
        end
        
        -- Multiple death/invalid state checks
        if not ply:Alive() or ply:Health() <= 0 or ply:GetObserverMode() > 0 then
            hook.Remove("Think", hookName)
            return
        end
        
        -- Skip if player is noclipping
        if ply:GetMoveType() == MOVETYPE_NOCLIP then
            return
        end
        
        -- Check if player is using the problematic mecha hale model
        local playerModel = ply:GetModel()
        if playerModel and string.find(string.lower(playerModel), "mecha_hale") then
            -- Extra safety for mecha hale - check if model is fully loaded
            if not ply:GetModel() or ply:GetModel() == "" then
                return
            end
        end
        
        -- Only update skin if the aura has skins available
        if aura:SkinCount() and aura:SkinCount() > 0 then
            -- Extra protection: check if the functions exist before calling
            if not ply.GetSkin or not aura.GetSkin then
                return
            end
            
            -- Wrap everything in multiple layers of protection
            local playerSkin, auraSkin
            
            -- Get player skin with maximum safety
            if ply:IsValid() and ply:Alive() and ply.GetSkin then
                local success, result = pcall(ply.GetSkin, ply)
                playerSkin = (success and result) or 0
            else
                playerSkin = 0
            end
            
            -- Get aura skin with maximum safety
            if aura:IsValid() and aura.GetSkin then
                local success, result = pcall(aura.GetSkin, aura)
                auraSkin = (success and result) or 0
            else
                auraSkin = 0
            end
            
            -- Ensure both are valid numbers
            playerSkin = tonumber(playerSkin) or 0
            auraSkin = tonumber(auraSkin) or 0
            
            -- Final comparison with absolute safety
            if playerSkin ~= nil and auraSkin ~= nil and auraSkin ~= playerSkin then
                pcall(function() aura:SetSkin(playerSkin) end)
            end
        end
    end)
    
    return aura
end

-- Function to remove leg thrusters
local function RemoveLegThrusters(ply)
    if playerAuras[ply] and IsValid(playerAuras[ply].legThrusters) then
        playerAuras[ply].legThrusters:Remove()
        playerAuras[ply].legThrusters = nil
        playerOnGround[ply] = true
    end
end

-- Function to check if player is truly on ground (with multiple methods)
local function IsPlayerTrulyOnGround(ply)
    -- Method 1: Standard OnGround check
    if ply:OnGround() then return true end
    
    -- Method 2: Check if very close to ground
    local trace = {
        start = ply:GetPos(),
        endpos = ply:GetPos() - Vector(0, 0, 5), -- 5 units below player
        filter = ply
    }
    local tr = util.TraceLine(trace)
    if tr.Hit then return true end
    
    -- Method 3: Check velocity (if falling very slowly or not at all)
    local vel = ply:GetVelocity()
    if vel.z > -10 and vel.z < 10 then
        -- Additional ground check
        local trace2 = {
            start = ply:GetPos(),
            endpos = ply:GetPos() - Vector(0, 0, 10), -- 10 units below player
            filter = ply
        }
        local tr2 = util.TraceLine(trace2)
        if tr2.Hit then return true end
    end
    
    return false
end

-- Function to remove auras from a player
function RemoveAurasFromPlayer(ply)
    if not playerAuras[ply] then return end
    
    for _, aura in pairs(playerAuras[ply]) do
        if IsValid(aura) then
            aura:Remove()
        end
    end
    
    playerAuras[ply] = nil
    playerSkins[ply] = nil
    playerVelocities[ply] = nil
    playerOnGround[ply] = nil
    playerAnimations[ply] = nil
    lastGroundCheck[ply] = nil
    hook.Remove("Think", "UpdateAuraPositions_" .. ply:EntIndex())
    hook.Remove("Think", "UpdateHatSkin_" .. ply:EntIndex())
end

-- Function to get the right arm aura model based on player skin
local function GetRightArmAuraModel(ply, defaultModel)
    local playerModel = ply:GetModel()
    local skin = ply:GetSkin()
    
    -- Exclude mobster model from special right arm effects
    if playerModel == "models/vip_mobster/player/mobster.mdl" then
        return defaultModel
    end
    
    if skin == 3 or skin == 4 then
        return specialRightArmAura
    else
        return defaultModel
    end
end

-- Function to get the left arm aura model based on player skin
local function GetLeftArmAuraModel(ply, defaultModel)
    local playerModel = ply:GetModel()
    local skin = ply:GetSkin()
    
    -- Check if this model should be excluded from megapunch
    if excludeFromMegapunch[playerModel] then
        return defaultModel
    end
    
    -- Apply megapunch for skins 2 and 4
    if skin == 2 or skin == 4 then
        return specialLeftArmAura
    else
        return defaultModel
    end
end

-- Function to get current animation name
local function GetPlayerAnimation(ply)
    local sequence = ply:GetSequence()
    return ply:GetSequenceName(sequence)
end

-- Function to attach auras to a player
local function AttachAurasToPlayer(ply)
    if not IsValid(ply) then return end
    
    -- Remove any existing auras first
    RemoveAurasFromPlayer(ply)
    
    -- Get the appropriate aura models for this player's model
    local playerModel = ply:GetModel()
    local auraModels = haleAuraModels[playerModel] or defaultAuraModels
    
    -- Store the current skin, velocity, ground state and animation
    playerSkins[ply] = ply:GetSkin()
    playerVelocities[ply] = ply:GetVelocity()
    playerOnGround[ply] = IsPlayerTrulyOnGround(ply)
    playerAnimations[ply] = GetPlayerAnimation(ply)
    lastGroundCheck[ply] = CurTime()
    
    -- Get the special arm models based on skin
    local rightArmModel = GetRightArmAuraModel(ply, auraModels.rightArm)
    local leftArmModel = GetLeftArmAuraModel(ply, auraModels.leftArm)
    
    -- Create and store the auras
    playerAuras[ply] = {
        body = CreateAura(ply, auraModels.body),
        leftArm = CreateAura(ply, leftArmModel),
        rightArm = CreateAura(ply, rightArmModel)
    }
    
    -- Add a think hook to update positions and check for skin changes
    local hookName = "UpdateAuraPositions_" .. ply:EntIndex()
    hook.Add("Think", hookName, function()
        if not IsValid(ply) or not ply:Alive() then
            RemoveAurasFromPlayer(ply)
            hook.Remove("Think", hookName)
            return
        end
        
        -- Get current states
        local currentSkin = ply:GetSkin()
        local currentVelocity = ply:GetVelocity()
        local playerModel = ply:GetModel()
        local currentAnimation = GetPlayerAnimation(ply)
        
        -- Check if skin has changed
        if playerSkins[ply] ~= currentSkin then
            -- Update stored skin
            playerSkins[ply] = currentSkin
            
            -- Update auras if needed
            if playerAuras[ply] then
                local auraModels = haleAuraModels[playerModel] or defaultAuraModels
                
                -- Check and update right arm aura
                local rightArmModel = GetRightArmAuraModel(ply, auraModels.rightArm)
                local currentRightModel = IsValid(playerAuras[ply].rightArm) and playerAuras[ply].rightArm:GetModel() or ""
                
                if currentRightModel ~= rightArmModel then
                    -- Remove old right arm aura
                    if IsValid(playerAuras[ply].rightArm) then
                        playerAuras[ply].rightArm:Remove()
                    end
                    
                    -- Create new right arm aura
                    playerAuras[ply].rightArm = CreateAura(ply, rightArmModel)
                end
                
                -- Check and update left arm aura
                local leftArmModel = GetLeftArmAuraModel(ply, auraModels.leftArm)
                local currentLeftModel = IsValid(playerAuras[ply].leftArm) and playerAuras[ply].leftArm:GetModel() or ""
                
                if currentLeftModel ~= leftArmModel then
                    -- Remove old left arm aura
                    if IsValid(playerAuras[ply].leftArm) then
                        playerAuras[ply].leftArm:Remove()
                    end
                    
                    -- Create new left arm aura
                    playerAuras[ply].leftArm = CreateAura(ply, leftArmModel)
                end
            end
        end
        
        -- Handle Mecha Hale special effects
        if playerModel == "models/vsh/player/mecha_hale.mdl" then
            -- Check ground state more frequently for Mecha Hale
            if CurTime() - (lastGroundCheck[ply] or 0) > 0.05 then
                lastGroundCheck[ply] = CurTime()
                
                -- Perform thorough ground check
                local onGround = IsPlayerTrulyOnGround(ply)
                
                -- If ground state changed
                if onGround ~= playerOnGround[ply] then
                    playerOnGround[ply] = onGround
                    
                    -- If now on ground, remove leg thrusters
                    if onGround then
                        RemoveLegThrusters(ply)
                    -- If now in air, add leg thrusters
                    else
                        if not IsValid(playerAuras[ply].legThrusters) then
                            playerAuras[ply].legThrusters = CreateAura(ply, mechaLegThrusters)
                        end
                    end
                end
                
                -- Extra safety check: if on ground but thrusters still exist, remove them
                if onGround and IsValid(playerAuras[ply].legThrusters) then
                    RemoveLegThrusters(ply)
                end
            end
            
            -- Handle back thrusters for dash animations
            if currentAnimation ~= playerAnimations[ply] then
                playerAnimations[ply] = currentAnimation
                
                -- If now in a dash animation, add back thrusters
                if mechaDashAnimations[currentAnimation] then
                    if not IsValid(playerAuras[ply].backThrusters) then
                        playerAuras[ply].backThrusters = CreateAura(ply, mechaBackThrusters)
                    end
                -- If no longer in a dash animation, remove back thrusters
                else
                    if IsValid(playerAuras[ply].backThrusters) then
                        playerAuras[ply].backThrusters:Remove()
                        playerAuras[ply].backThrusters = nil
                    end
                end
            end
        end
        
        -- Update velocities for next check
        playerVelocities[ply] = currentVelocity
        
        -- Update positions
        if playerAuras[ply] then
            for _, aura in pairs(playerAuras[ply]) do
                if IsValid(aura) then
                    aura:SetPos(ply:GetPos())
                    aura:SetAngles(ply:GetAngles())
                end
            end
        end
    end)
end
local function IsHaleModel(model)
    return haleAuraModels[model] ~= nil
end

-- Monitor player model changes
hook.Add("Think", "MonitorPlayerModelsForAuras", function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local currentModel = ply:GetModel()
            
            -- If player has a Hale model but no auras, add them
            if IsHaleModel(currentModel) and not playerAuras[ply] then
                AttachAurasToPlayer(ply)
            -- If player has auras but changed to a non-Hale model, remove them
            elseif playerAuras[ply] and not IsHaleModel(currentModel) then
                RemoveAurasFromPlayer(ply)
            end
        end
    end
end)

-- Handle player spawning
hook.Add("OnEntityCreated", "CheckNewPlayerForAuras", function(ent)
    if IsValid(ent) and ent:IsPlayer() then
        timer.Simple(0.5, function()
            if IsValid(ent) and IsHaleModel(ent:GetModel()) then
                AttachAurasToPlayer(ent)
            end
        end)
    end
end)

-- Handle player death
hook.Add("PlayerDeath", "RemoveAurasOnDeath", function(ply)
    RemoveAurasFromPlayer(ply)
end)

-- Handle player disconnection
hook.Add("EntityRemoved", "RemoveAurasOnDisconnect", function(ent)
    if ent:IsPlayer() then
        RemoveAurasFromPlayer(ent)
    end
end)

-- Support for the original network messages
net.Receive("AttachPlayerAura", function()
    local ply = net.ReadEntity()
    if IsValid(ply) then
        AttachAurasToPlayer(ply)
    end
end)

net.Receive("RemovePlayerAura", function()
    local ply = net.ReadEntity() or LocalPlayer()
    if IsValid(ply) then
        RemoveAurasFromPlayer(ply)
    end
end)

-- Clean up on map change
hook.Add("ShutDown", "CleanupAllAuras", function()
    for ply, _ in pairs(playerAuras) do
        RemoveAurasFromPlayer(ply)
    end
end)

-- Add a hook to detect velocity changes for better jump detection
hook.Add("OnPlayerHitGround", "DetectMechaHaleLanding", function(ply, inWater, onFloater, speed)
    if IsValid(ply) and ply:GetModel() == "models/vsh/player/mecha_hale.mdl" and playerAuras[ply] then
        RemoveLegThrusters(ply)
    end
end)

-- Add a hook to detect jumps more reliably
hook.Add("KeyPress", "DetectMechaHaleJump", function(ply, key)
    if key == IN_JUMP and IsValid(ply) and ply:GetModel() == "models/vsh/player/mecha_hale.mdl" and playerAuras[ply] then
        if ply:OnGround() then
            -- Player is jumping from the ground
            timer.Simple(0.1, function()
                if IsValid(ply) and not IsPlayerTrulyOnGround(ply) and not IsValid(playerAuras[ply].legThrusters) then
                    playerAuras[ply].legThrusters = CreateAura(ply, mechaLegThrusters)
                    playerOnGround[ply] = false
                end
            end)
        end
    end
end)

-- Add a hook to detect animation changes more reliably
hook.Add("CalcMainActivity", "DetectMechaHaleAnimations", function(ply, velocity)
    if IsValid(ply) and ply:GetModel() == "models/vsh/player/mecha_hale.mdl" and playerAuras[ply] then
        local currentAnimation = GetPlayerAnimation(ply)
        
        -- If animation changed
        if currentAnimation ~= playerAnimations[ply] then
            playerAnimations[ply] = currentAnimation
            
            -- Handle back thrusters based on animation
            if mechaDashAnimations[currentAnimation] then
                if not IsValid(playerAuras[ply].backThrusters) then
                    playerAuras[ply].backThrusters = CreateAura(ply, mechaBackThrusters)
                end
            else
                if IsValid(playerAuras[ply].backThrusters) then
                    playerAuras[ply].backThrusters:Remove()
                    playerAuras[ply].backThrusters = nil
                end
            end
        end
        
        -- Extra ground check in this hook
        if IsPlayerTrulyOnGround(ply) and IsValid(playerAuras[ply].legThrusters) then
            RemoveLegThrusters(ply)
        end
    end
end)

-- Add a hook to detect significant vertical velocity changes (for double jumps)
hook.Add("Think", "DetectMechaHaleDoubleJump", function()
    for ply, lastVelocity in pairs(playerVelocities) do
        if IsValid(ply) and ply:GetModel() == "models/vsh/player/mecha_hale.mdl" and playerAuras[ply] then
            local currentVelocity = ply:GetVelocity()
            
            -- Check for sudden upward velocity change while in air (double jump)
            if not IsPlayerTrulyOnGround(ply) and lastVelocity.z < 600 and currentVelocity.z > 600 then
                if not IsValid(playerAuras[ply].legThrusters) then
                    playerAuras[ply].legThrusters = CreateAura(ply, mechaLegThrusters)
                end
                playerOnGround[ply] = false
            end
            
            -- Extra ground check
            if IsPlayerTrulyOnGround(ply) and IsValid(playerAuras[ply].legThrusters) then
                RemoveLegThrusters(ply)
            end
            
            -- Update stored velocity
            playerVelocities[ply] = currentVelocity
        end
    end
end)

-- Add a timer to periodically check ground state for Mecha Hale players
timer.Create("MechaHaleGroundStateCheck", 0.1, 0, function()
    for ply, auras in pairs(playerAuras) do
        if IsValid(ply) and ply:GetModel() == "models/vsh/player/mecha_hale.mdl" then
            -- If player is on ground but still has leg thrusters, remove them
            if IsPlayerTrulyOnGround(ply) and IsValid(auras.legThrusters) then
                RemoveLegThrusters(ply)
            end
        end
    end
end)

-- fixed this one thanks to sourcegraph AI is a tool and ill use it responsably
hook.Add("Move", "MechaHaleGroundMovementCheck", function(ply, mv)
    if IsValid(ply) and ply:GetModel() == "models/vsh/player/mecha_hale.mdl" and playerAuras[ply] then
        -- If player is on ground but still has leg thrusters, remove them
        if ply:OnGround() and IsValid(playerAuras[ply].legThrusters) then
            RemoveLegThrusters(ply)
        end
    end
end)

hook.Add("Think", "MonitorPlayerModelsForSpecialItems", function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local currentModel = ply:GetModel()
            
            -- Check for Julius model
            if currentModel == "models/vip/player/civilian/julius.mdl" and (not playerAuras[ply] or not IsValid(playerAuras[ply].hat)) then
                AttachSpecialItems(ply)
            -- If player has a hat but changed to a different model, remove it
            elseif playerAuras[ply] and IsValid(playerAuras[ply].hat) and currentModel ~= "models/vip/player/civilian/julius.mdl" then
                playerAuras[ply].hat:Remove()
                playerAuras[ply].hat = nil
            end
        end
    end
end)

function AttachSpecialItems(ply)
    local playerModel = ply:GetModel()
    
    -- Check if this model needs special attachments
    if playerModel == "models/vip/player/civilian/julius.mdl" then
        -- Store the current skin
        playerSkins[ply] = ply:GetSkin()
        
        -- Create and attach the hat
        if not playerAuras[ply] then
            playerAuras[ply] = {}
        end
        
        -- Remove existing hat if there is one
        if IsValid(playerAuras[ply].hat) then
            playerAuras[ply].hat:Remove()
        end
        
        -- Create new hat
        playerAuras[ply].hat = CreateHat(ply, specialAttachments[playerModel].hat)
        
        -- Add a think hook to update the hat
        local hookName = "UpdateHatSkin_" .. ply:EntIndex()
        hook.Add("Think", hookName, function()
            if not IsValid(ply) or not ply:Alive() or ply:GetModel() ~= "models/vip/player/civilian/julius.mdl" then
                if IsValid(playerAuras[ply] and playerAuras[ply].hat) then
                    playerAuras[ply].hat:Remove()
                    playerAuras[ply].hat = nil
                end
                hook.Remove("Think", hookName)
                return
            end
            
            -- Check if skin has changed
            local currentSkin = ply:GetSkin()
            if playerSkins[ply] ~= currentSkin then
                -- Update stored skin
                playerSkins[ply] = currentSkin
                
                -- Update hat skin
                if IsValid(playerAuras[ply].hat) then
                    playerAuras[ply].hat:SetSkin(currentSkin)
                end
            end
            
            -- Update position
            if IsValid(playerAuras[ply].hat) then
                playerAuras[ply].hat:SetPos(ply:GetPos())
                playerAuras[ply].hat:SetAngles(ply:GetAngles())
            end
        end)
    end
end

function CreateHat(ply, model)
    if not IsValid(ply) then return nil end
    
    local hat = ClientsideModel(model)
    if not IsValid(hat) then return nil end
    
    hat:SetParent(ply)
    hat:AddEffects(EF_BONEMERGE)
    hat:SetNoDraw(false)
    
    -- Match the hat skin to the player's skin
    hat:SetSkin(ply:GetSkin())
    
    -- Ensure proper positioning
    hat:SetPos(ply:GetPos())
    hat:SetAngles(ply:GetAngles())
    
    return hat
end

-- done and done
hook.Add("InitPostEntity", "AuraSpawnVersionMessage", function()
    timer.Simple(2, function() -- Small delay to ensure chat is ready
        if IsValid(LocalPlayer()) then
            chat.AddText(Color(255, 100, 100), "[Aura Spawn] ", Color(255, 255, 255), "aura spawn version 1.2.0 (ALPHA) WARNING there is some changes made to aura spawn that MAY effect gameplay/break if you see any errors report it to ITS developer server side error is fixed")
        end
    end)
end)
