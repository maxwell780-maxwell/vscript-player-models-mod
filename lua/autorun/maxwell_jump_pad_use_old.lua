if CLIENT then
    -- Create the ConVar to toggle old particle effects (0 = new effects, 1 = old effects)
    CreateClientConVar("maxwell_jump_pad_should_use_old_particle_effects", "0", true, false, "Use old particle effects for jump pads (1 = enabled, 0 = disabled)")
    
    local function ApplyParticleEffects()
        -- Find all jump pad entities
        local jumpPads = ents.FindByClass("vsh_australia_jump_pad")
        
        -- If no jump pads found, try again later
        if #jumpPads == 0 then
            return
        end
        
        -- Check if we should use old effects
        local useOldEffects = GetConVar("maxwell_jump_pad_should_use_old_particle_effects"):GetBool()
        
        -- Process each jump pad
        for _, pad in ipairs(jumpPads) do
            -- Remove any existing particle effect
            if pad.OldParticleEffect then
                pad.OldParticleEffect:StopEmissionAndDestroyImmediately()
                pad.OldParticleEffect = nil
            end
            
            -- Apply old particle effect if enabled
            if useOldEffects then
                pad.OldParticleEffect = CreateParticleSystem(pad, "vsh_jumppad_OLD", PATTACH_ABSORIGIN_FOLLOW, 0, Vector(0, 0, 0))
            end
        end
    end
    
    -- Hook to apply effects when the ConVar changes
    cvars.AddChangeCallback("maxwell_jump_pad_should_use_old_particle_effects", function(_, _, _)
        ApplyParticleEffects()
    end)
    
    -- Apply effects when entities spawn
    hook.Add("OnEntityCreated", "MaxwellJumpPadParticleCheck", function(entity)
        if IsValid(entity) and entity:GetClass() == "vsh_australia_jump_pad" then
            -- Wait a frame to ensure the entity is fully initialized
            timer.Simple(0, function()
                if IsValid(entity) then
                    local useOldEffects = GetConVar("maxwell_jump_pad_should_use_old_particle_effects"):GetBool()
                    
                    if useOldEffects then
                        entity.OldParticleEffect = CreateParticleSystem(entity, "vsh_jumppad_OLD", PATTACH_ABSORIGIN_FOLLOW, 0, Vector(0, 0, 0))
                    end
                end
            end)
        end
    end)
    
    -- Initial check for existing jump pads when the script loads
    hook.Add("InitPostEntity", "MaxwellJumpPadInitialCheck", function()
        -- Wait a bit to ensure all entities are loaded
        timer.Simple(2, ApplyParticleEffects)
    end)
    
    -- Also check when the player spawns (in case they join mid-game)
    hook.Add("PlayerInitialSpawn", "MaxwellJumpPadPlayerCheck", function()
        timer.Simple(5, ApplyParticleEffects)
    end)
end