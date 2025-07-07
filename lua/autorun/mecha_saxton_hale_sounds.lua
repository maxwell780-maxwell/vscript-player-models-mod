local MECHA_MODEL = "models/vsh/player/mecha_hale.mdl"
local LOOP_SOUND = "vsh_mecha/mecha_hale_loop.wav"
local DEATH_SOUND = "mvm/sentrybuster/mvm_sentrybuster_explode.wav"
local FOOTSTEP_SOUNDS = {
    "mvm/sentrybuster/mvm_sentrybuster_step_01.wav",
    "mvm/sentrybuster/mvm_sentrybuster_step_02.wav",
    "mvm/sentrybuster/mvm_sentrybuster_step_03.wav",
    "mvm/sentrybuster/mvm_sentrybuster_step_04.wav"
}

local MECHA_GIBS = {
    "models/vsh/player/gibs/mecha_hale_gib_chest.mdl",
    "models/vsh/player/gibs/mecha_hale_gib_feet_l.mdl",
    "models/vsh/player/gibs/mecha_hale_gib_feet_r.mdl",
    "models/vsh/player/gibs/mecha_hale_gib_hand_l.mdl",
    "models/vsh/player/gibs/mecha_hale_gib_hat.mdl",
    "models/vsh/player/gibs/mecha_hale_gib_head.mdl",
    "models/vsh/player/gibs/mecha_hale_gib_hip_l.mdl",
    "models/vsh/player/gibs/mecha_hale_gib_hip_r.mdl",
    "models/vsh/player/gibs/mecha_hale_gib_lowerarm_l.mdl",
    "models/vsh/player/gibs/mecha_hale_gib_upperarm_r.mdl"
}

-- local SKIN_CHANGE_INTERVAL = 35.1 -- Adjustable time interval for skin changes

if CLIENT then
    local function CheckModel(ply)
        if IsValid(ply) and ply:GetModel() == MECHA_MODEL and ply:Alive() then
            if not ply.MechaLoopSound then
                ply.MechaLoopSound = CreateSound(ply, LOOP_SOUND)
                ply.MechaLoopSound:Play()
                ply.MechaLoopSound:ChangeVolume(0.5)
            end
        elseif ply.MechaLoopSound then
            ply.MechaLoopSound:Stop()
            ply.MechaLoopSound = nil
        end
    end

    hook.Add("Think", "MechaHaleLoopSound", function()
        local ply = LocalPlayer()
        CheckModel(ply)
    end)
end

-- Skin changing timer
-- timer.Create("MechaHaleSkinChanger", SKIN_CHANGE_INTERVAL, 0, function()
 --   for _, ply in ipairs(player.GetAll()) do
     --   if IsValid(ply) and ply:GetModel() == MECHA_MODEL and ply:Alive() then
     --       ply:SetSkin(2)
    --    end
 --   end
-- end)

hook.Add("PlayerFootstep", "MechaHaleFootsteps", function(ply, pos, foot, sound, volume, rf)
    if ply:GetModel() == MECHA_MODEL then
        ply:EmitSound(table.Random(FOOTSTEP_SOUNDS), 75, 100, 1.2) -- Increased volume
        return true
    end
end)

local function SpawnGibs(pos)
    -- Create the custom explosion effect
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    util.Effect("vsh_mecha_hale_explosion", effectData)

    for _, gibModel in ipairs(MECHA_GIBS) do
        local gib = ents.Create("prop_physics")
        gib:SetModel(gibModel)
        gib:SetPos(pos + Vector(math.random(-20, 20), math.random(-20, 20), math.random(0, 40)))
        gib:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
        gib:Spawn()
        gib:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
        
        local phys = gib:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(VectorRand() * 300) -- Increased velocity for more dramatic effect
            phys:AddAngleVelocity(VectorRand() * 150)
        end
        
        timer.Simple(30, function()
            if IsValid(gib) then
                gib:Remove()
            end
        end)
    end
    
    local explosion = ents.Create("env_explosion")
    explosion:SetPos(pos)
    explosion:SetOwner(victim)
    explosion:Spawn()
    explosion:SetKeyValue("iMagnitude", "120")
    explosion:Fire("Explode", 0, 0)
end

hook.Add("PlayerDeath", "MechaHaleDeath", function(victim, inflictor, attacker)
    if victim:GetModel() == MECHA_MODEL then
        victim:EmitSound(DEATH_SOUND, 75, 100, 1)
        
        -- 85% chance for gibbing, 15% chance for ragdoll
        if math.random(1, 100) <= 85 then
            if IsValid(victim:GetRagdollEntity()) then
                victim:GetRagdollEntity():Remove()
            end
            SpawnGibs(victim:GetPos())
        end
        
        if victim.MechaLoopSound then
            victim.MechaLoopSound:Stop()
            victim.MechaLoopSound = nil
        end
    end
end)