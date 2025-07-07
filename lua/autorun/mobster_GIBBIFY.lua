local MOBSTER_MODEL = "models/vip_mobster/player/mobster.mdl"

-- Gib models
local gibModels = {
    "models/vip_mobster/player/gibs/mobstergib001.mdl",
    "models/vip_mobster/player/gibs/mobstergib002.mdl",
    "models/vip_mobster/player/gibs/mobstergib004.mdl",
    "models/vip_mobster/player/gibs/mobstergib005.mdl",
    "models/vip_mobster/player/gibs/mobstergib006.mdl",
    "models/vip_mobster/player/gibs/mobstergib007.mdl"
}

-- Flesh impact sounds
local fleshSounds = {
    "physics/flesh/flesh_squishy_impact_hard1.wav",
    "physics/flesh/flesh_squishy_impact_hard2.wav",
    "physics/flesh/flesh_squishy_impact_hard3.wav",
    "physics/flesh/flesh_squishy_impact_hard4.wav"
}

-- Blood decals
local bloodDecals = {
    "Blood",
    "Blood1",
    "Blood2",
    "Blood3",
    "Blood4",
    "Blood5",
    "Blood6",
    "Blood7",
    "Blood8"
}

-- Track explosion damage for players
local playerExplosionDamage = {}

-- Precache models and sounds
hook.Add("Initialize", "MobsterGibsPrecache", function()
    for _, model in ipairs(gibModels) do
        util.PrecacheModel(model)
    end
    
    for _, sound in ipairs(fleshSounds) do
        util.PrecacheSound(sound)
    end
end)

-- Check if damage is from explosion
local function IsExplosiveDamage(damageInfo)
    -- Check if damageInfo is valid
    if not damageInfo then return false end
    
    -- Safely get damage type
    local damageType = 0
    pcall(function() damageType = damageInfo:GetDamageType() end)
    
    return bit.band(damageType, DMG_BLAST) ~= 0 or 
           bit.band(damageType, DMG_BLAST_SURFACE) ~= 0 or 
           bit.band(damageType, DMG_AIRBOAT) ~= 0
end

-- Create blood decal at position
local function CreateBloodDecal(pos, normal)
    -- Create blood decal
    util.Decal(bloodDecals[math.random(#bloodDecals)], pos + normal, pos - normal)
    
    -- Add some extra blood decals nearby for a more realistic effect
    for i = 1, math.random(2, 5) do
        local offset = VectorRand() * math.random(5, 20)
        offset.z = math.abs(offset.z) * 0.5 -- Keep blood mostly on the ground
        util.Decal(bloodDecals[math.random(#bloodDecals)], pos + offset + normal, pos + offset - normal)
    end
    
    -- Sometimes add blood pools
    if math.random() > 0.5 then
        util.Decal("Blood", pos + Vector(0, 0, 5), pos - Vector(0, 0, 5))
    end
end

-- Create blood splash effect
local function CreateBloodSplash(pos)
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetScale(math.random(2, 5))
    util.Effect("BloodImpact", effectData)
end

-- Create a single gib
local function CreateGib(pos, model, vel, ang, skin)
    local gib = ents.Create("prop_physics")
    if not IsValid(gib) then return nil end
    
    gib:SetModel(model)
    gib:SetPos(pos)
    gib:SetAngles(ang or Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
    
    -- Set the skin to match the player's skin
    if skin then
        gib:SetSkin(skin)
    end
    
    gib:Spawn()
    gib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    
    -- Add blood decals
    gib:SetKeyValue("SpawnFlags", "3")
    
    -- Set velocity
    local phys = gib:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(vel)
        phys:AddAngleVelocity(VectorRand() * 500)
    end
    
    -- Add collision sound and blood decals
    gib.LastCollide = 0
    gib:AddCallback("PhysicsCollide", function(ent, data)
        if not IsValid(ent) then return end
        if CurTime() - (ent.LastCollide or 0) < 0.2 then return end
        ent.LastCollide = CurTime()
        
        if data.Speed > 50 then
            -- Play impact sound
            local sound = fleshSounds[math.random(#fleshSounds)]
            ent:EmitSound(sound, 75, math.random(90, 110), math.min(1, data.Speed / 500))
            
            -- Create blood decal at impact point
            if data.HitPos and data.HitNormal then
                CreateBloodDecal(data.HitPos, data.HitNormal)
                
                -- Create blood splash effect
                if data.Speed > 150 then
                    CreateBloodSplash(data.HitPos)
                end
            end
        end
    end)
    
    -- Add blood drip effect
    gib.NextBloodDrip = CurTime() + math.random(0.1, 0.5)
    hook.Add("Think", "MobsterBloodDrip" .. gib:EntIndex(), function()
        if not IsValid(gib) then 
            hook.Remove("Think", "MobsterBloodDrip" .. gib:EntIndex())
            return
        end
        
        if CurTime() > gib.NextBloodDrip then
            gib.NextBloodDrip = CurTime() + math.random(0.5, 2)
            
            -- Chance to create blood decal below the gib
            if math.random() > 0.3 then
                local pos = gib:GetPos()
                local trace = util.TraceLine({
                    start = pos,
                    endpos = pos - Vector(0, 0, 50),
                    filter = gib
                })
                
                if trace.Hit then
                    CreateBloodDecal(trace.HitPos, trace.HitNormal)
                end
            end
        end
    end)
    
    -- Remove after some time
    SafeRemoveEntityDelayed(gib, 15 + math.random() * 5)
    
    return gib
end

-- Create gibs at position
local function CreateGibs(ply)
    if not IsValid(ply) then return end
    
    local pos = ply:GetPos() + Vector(0, 0, 40)
    local vel = ply:GetVelocity()
    local playerSkin = ply:GetSkin() -- Get the player's skin
    
    -- Create initial blood splash
    CreateBloodSplash(pos)
    
    -- Create blood decals on the ground
    local trace = util.TraceLine({
        start = pos,
        endpos = pos - Vector(0, 0, 100),
        filter = ply
    })
    
    if trace.Hit then
        for i = 1, math.random(5, 10) do
            local offset = VectorRand() * math.random(10, 50)
            offset.z = 0 -- Keep blood on the ground
            CreateBloodDecal(trace.HitPos + offset, trace.HitNormal)
        end
    end
    
    -- Spawn all gibs
    local gibs = {}
    for i, model in ipairs(gibModels) do
        local gibVel = vel + VectorRand() * 200 + Vector(0, 0, 200)
        local gib = CreateGib(pos + VectorRand() * 10, model, gibVel, nil, playerSkin)
        if IsValid(gib) then
            gibs[i] = gib
            
            -- Add blood trail
            local effectData = EffectData()
            effectData:SetEntity(gib)
            effectData:SetScale(1)
            util.Effect("BloodTrail", effectData)
        end
    end
    
    return gibs
end

-- Handle player death
hook.Add("PlayerDeath", "MobsterGibsOnDeath", function(victim, inflictor, attacker)
    if not IsValid(victim) then return end
    if victim:GetModel() ~= MOBSTER_MODEL then return end
    
    local steamID = victim:SteamID()
    
    -- Check if player was damaged by explosion recently
    if playerExplosionDamage[steamID] and playerExplosionDamage[steamID] > CurTime() - 1 then
        -- Create gibs
        CreateGibs(victim)
        
        -- Play gib sound
        victim:EmitSound("physics/flesh/flesh_bloody_break.wav", 100, math.random(90, 110))
        
        -- Remove the ragdoll with a slight delay to ensure it's created first
        timer.Simple(0, function()
            if IsValid(victim) then
                local ragdoll = victim:GetRagdollEntity()
                if IsValid(ragdoll) then
                    ragdoll:Remove()
                end
            end
        end)
        
        -- Add a backup timer in case the ragdoll isn't immediately available
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

-- Store explosion damage info
hook.Add("EntityTakeDamage", "MobsterTrackExplosionDamage", function(ent, dmginfo)
    if not IsValid(ent) or not ent:IsPlayer() then return end
    if ent:GetModel() ~= MOBSTER_MODEL then return end
    
    -- Safely check for explosive damage
    if IsExplosiveDamage(dmginfo) then
        playerExplosionDamage[ent:SteamID()] = CurTime()
    end
end)

-- Clean up on player disconnect
hook.Add("PlayerDisconnected", "MobsterCleanupExplosionData", function(ply)
    if IsValid(ply) then
        playerExplosionDamage[ply:SteamID()] = nil
    end
end)

-- Clean up on round restart
hook.Add("PostCleanupMap", "MobsterCleanupData", function()
    playerExplosionDamage = {}
end)