if SERVER then
    util.AddNetworkString("HatmanDeathEffect")
end

local HATMAN_MODEL = "models/bots/headless_hatman.mdl"
local GIB_MODELS = {
    "models/bots/gibs/hh_gib_boot_l.mdl",
    "models/bots/gibs/hh_gib_boot_r.mdl",
    "models/bots/gibs/hh_gib_candle.mdl",
    "models/bots/gibs/hh_gib_glove_l.mdl",
    "models/bots/gibs/hh_gib_glove_r.mdl",
    "models/bots/gibs/hh_gib_torso.mdl",
    "models/bots/gibs/hh_gib_upperarm_r.mdl",
    "models/bots/gibs/hh_gib_upperleg_l.mdl",
    "models/bots/gibs/hh_gib_upperleg_r.mdl",
    "models/bots/gibs/hh_gib_waist.mdl"
}

function PlayHatmanDeathEffect(pos)
    ParticleEffect("halloween_boss_death", pos, Angle(0, 0, 0), nil)
end


-- Precache models, sounds and particles
if SERVER then
    -- Precache models
    util.PrecacheModel(HATMAN_MODEL)
    for _, model in ipairs(GIB_MODELS) do
        util.PrecacheModel(model)
    end
    
    -- Precache sounds
    util.PrecacheSound("vo/halloween_boss/knight_dying.mp3")
    util.PrecacheSound("vo/halloween_boss/knight_death02.mp3")
    util.PrecacheSound("ui/halloween_boss_defeated.wav")
    
    -- Register the particle effect
    game.AddParticles("particles/halloween_boss.pcf")
    PrecacheParticleSystem("halloween_boss_death")
end

if SERVER then
    -- Function to spawn gibs at a position
    local function SpawnGibs(pos)
        local gibs = {}
        
        for _, model in ipairs(GIB_MODELS) do
            local gib = ents.Create("prop_physics")
            if IsValid(gib) then
                gib:SetModel(model)
                gib:SetPos(pos + Vector(math.random(-20, 20), math.random(-20, 20), math.random(-10, 30)))
                gib:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
                gib:Spawn()
                
                -- Set up physics
                local phys = gib:GetPhysicsObject()
                if IsValid(phys) then
                    phys:SetVelocity(VectorRand() * 150)
                    phys:AddAngleVelocity(VectorRand() * 150)
                end
                
                -- No collision with players or NPCs
                gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
                
                -- Remove after 20 seconds
                timer.Simple(20, function()
                    if IsValid(gib) then
                        gib:Remove()
                    end
                end)
                
                table.insert(gibs, gib)
            end
        end
        
        return gibs
    end
    
    -- Function to handle the death effect
    local function CreateHatmanDeathEffect(ply, pos, angles)
        -- Create the prop
        local prop = ents.Create("prop_dynamic")
        if IsValid(prop) then
            prop:SetModel(HATMAN_MODEL)
            prop:SetPos(pos)
            prop:SetAngles(angles)
            prop:Spawn()
            
            -- Play death sound
            prop:EmitSound("vo/halloween_boss/knight_dying.mp3", 100, 100, 1)
            
            -- Play shake animation
            prop:ResetSequence(prop:LookupSequence("shake"))
            
            -- Calculate animation duration
            local animDuration = prop:SequenceDuration()
            
            -- After animation ends, combust and spawn gibs
            timer.Simple(animDuration, function()
                if IsValid(prop) then
                    -- Play death sounds
                    prop:EmitSound("vo/halloween_boss/knight_death02.mp3", 100, 100, 1)
                    prop:EmitSound("ui/halloween_boss_defeated.wav", 100, 100, 1)
                    
                    net.Start("HatmanDeathEffect")
                    net.WriteVector(prop:GetPos() + Vector(0, 0, 50))
                    net.Broadcast()
                    
                    -- Spawn gibs
                    SpawnGibs(prop:GetPos())
                    
                    -- Remove the prop
                    prop:Remove()
                end
            end)
        end
    end
    
    -- Store players who need special death handling
    local playersToHandle = {}
    
    -- Hook to player death
    hook.Add("PlayerDeath", "HeadlessHatmanDeathEffect", function(victim, inflictor, attacker)
        -- Check if the player is using the Headless Hatman model
        if IsValid(victim) and victim:GetModel() == HATMAN_MODEL then
            -- Get player position and angles
            local pos = victim:GetPos()
            local angles = victim:GetAngles()
            
            -- Mark this player for ragdoll removal
            playersToHandle[victim:SteamID()] = true
            
            -- Create the death effect
            CreateHatmanDeathEffect(victim, pos, angles)
            
            -- Remove the ragdoll after a short delay to ensure it's created
            timer.Simple(0.1, function()
                if IsValid(victim) then
                    local ragdoll = victim:GetRagdollEntity()
                    if IsValid(ragdoll) then
                        ragdoll:Remove()
                    end
                end
            end)
        end
    end)
    
    -- Backup hook to catch ragdolls that might be created after our initial check
    hook.Add("OnEntityCreated", "HeadlessHatmanRagdollRemoval", function(entity)
        if entity:GetClass() == "prop_ragdoll" then
            timer.Simple(0, function()
                if not IsValid(entity) then return end
                
                local owner = entity:GetOwner()
                if IsValid(owner) and owner:IsPlayer() and playersToHandle[owner:SteamID()] then
                    entity:Remove()
                    playersToHandle[owner:SteamID()] = nil
                end
            end)
        end
    end)
end

if CLIENT then
    net.Receive("HatmanDeathEffect", function()
        local pos = net.ReadVector()
        PlayHatmanDeathEffect(pos)
    end)
end