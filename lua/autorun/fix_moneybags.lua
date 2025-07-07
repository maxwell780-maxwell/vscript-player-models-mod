if SERVER then
    -- Table to track all moneybag entities
    local moneybags = {}
    local SOUND_RESIST = "vip_mobster_emergent_r1b/moneybag_resist.mp3"
    
    -- Players who have received buffs (to prevent stacking)
    local buffedPlayers = {}
    local buffedNPCs = {}
    
    -- Function to safely remove a moneybag
    local function SafeRemoveMoneybag(ent)
        if IsValid(ent) then
            -- Play death particle effect
            ParticleEffect("weapon_moneybag_parent", ent:GetPos(), Angle(0,0,0), nil)
            
            -- Remove the entity after a short delay to allow the particle to play
            timer.Simple(0.5, function()
                if IsValid(ent) then
                    ent:Remove()
                end
            end)
        end
    end
    
    -- Hook into entity creation to detect moneybags
    hook.Add("OnEntityCreated", "MoneyBagManager_TrackCreation", function(ent)
        if not IsValid(ent) then return end
        
        -- Wait a tick to ensure the entity is fully initialized
        timer.Simple(0, function()
            if not IsValid(ent) then return end
            
            -- Check if it's a moneybag entity
            if ent:GetClass() == "moneybag" then
                -- Generate a unique ID for this moneybag
                local bagID = "moneybag_" .. ent:EntIndex() .. "_" .. CurTime()
                
                -- Store the entity in our tracking table
                moneybags[bagID] = ent
                
                -- Create a timer to remove this specific moneybag after 30 seconds
                timer.Create(bagID, 30, 1, function()
                    if moneybags[bagID] and IsValid(moneybags[bagID]) then
                        SafeRemoveMoneybag(moneybags[bagID])
                        moneybags[bagID] = nil
                    end
                end)
            end
        end)
    end)
    
    -- Hook into entity removal to clean up our tracking table
    hook.Add("EntityRemoved", "MoneyBagManager_TrackRemoval", function(ent)
        if ent:GetClass() == "moneybag" then
            -- Find and remove this entity from our tracking table
            for id, bagEnt in pairs(moneybags) do
                if bagEnt == ent then
                    timer.Remove(id)
                    moneybags[id] = nil
                    break
                end
            end
        end
    end)
    
    -- Periodically check for invalid entities in our tracking table
    timer.Create("MoneyBagManager_Cleanup", 10, 0, function()
        for id, ent in pairs(moneybags) do
            if not IsValid(ent) then
                timer.Remove(id)
                moneybags[id] = nil
            end
        end
    end)
    
    -- Function to check if an entity is near any moneybag
    local function IsNearMoneybag(ent)
        if not IsValid(ent) then return false end
        
        local entPos = ent:GetPos()
        for _, moneybag in pairs(moneybags) do
            if IsValid(moneybag) then
                local distance = entPos:Distance(moneybag:GetPos())
                if distance <= 200 then
                    return true
                end
            end
        end
        return false
    end
    
    -- Regeneration and buff timer
    timer.Create("MoneyBagManager_Regeneration", 1, 0, function()
        -- Reset buff tracking tables
        buffedPlayers = {}
        buffedNPCs = {}
        
        -- Process players
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) and player:Alive() and IsNearMoneybag(player) then
                -- Apply regeneration (15% of max health)
                local maxHealth = player:GetMaxHealth()
                local currentHealth = player:Health()
                local healAmount = math.ceil(maxHealth * 0.15)
                
                if currentHealth < maxHealth then
                    player:SetHealth(math.min(currentHealth + healAmount, maxHealth))
                    -- Removed sound here - no sound when healing
                end
                
                -- Set armor to 100
                player:SetArmor(100)
                
                -- Mark player as buffed
                buffedPlayers[player] = true
            end
        end
        
        -- Process NPCs
        for _, npc in ipairs(ents.GetAll()) do
            if IsValid(npc) and npc:IsNPC() and npc:Health() > 0 and IsNearMoneybag(npc) then
                -- Check if NPC is friendly to players
                local isFriendly = false
                for _, player in ipairs(player.GetAll()) do
                    if npc:Disposition(player) == D_LI or npc:Disposition(player) == D_NU then
                        isFriendly = true
                        break
                    end
                end
                
                if isFriendly then
                    -- Apply regeneration (15% of max health)
                    local maxHealth = npc:GetMaxHealth()
                    local currentHealth = npc:Health()
                    local healAmount = math.ceil(maxHealth * 0.15)
                    
                    if currentHealth < maxHealth then
                        npc:SetHealth(math.min(currentHealth + healAmount, maxHealth))
                    end
                    
                    -- Mark NPC as buffed
                    buffedNPCs[npc] = true
                end
            end
        end
    end)
    
    -- Hook into player damage to play resist sound and apply damage modifiers
    hook.Add("EntityTakeDamage", "MoneyBagManager_DamageModifiers", function(target, dmginfo)
        -- Damage resistance for players (15% reduction) and play resist sound
        if target:IsPlayer() and buffedPlayers[target] and dmginfo:GetDamage() > 0 then
            dmginfo:ScaleDamage(0.85) -- 15% damage reduction
            target:EmitSound(SOUND_RESIST, 65, 100, 0.5, CHAN_AUTO)
        end
        
        -- Damage resistance for friendly NPCs (15% reduction)
        if target:IsNPC() and buffedNPCs[target] and dmginfo:GetDamage() > 0 then
            dmginfo:ScaleDamage(0.85) -- 15% damage reduction
        end
        
        -- Damage boost for players (15% increase)
        local attacker = dmginfo:GetAttacker()
        if IsValid(attacker) then
            if attacker:IsPlayer() and buffedPlayers[attacker] then
                dmginfo:ScaleDamage(1.15) -- 15% damage boost
            elseif attacker:IsNPC() and buffedNPCs[attacker] then
                dmginfo:ScaleDamage(1.15) -- 15% damage boost
            end
        end
    end)
end