ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Money Bag"
ENT.Author = "Code Copilot & maxwell"
ENT.Spawnable = false
ENT.Category = "maxwells unuseable entitys"

-- File: lua/entities/ent_moneybag/init.lua

AddCSLuaFile()

local PARTICLES = { -- GOD GIVE US PARTICALS THANK YOU SO MUCH
    "weapon_moneybag_aura",
    "weapon_moneybag_crosses",
    "weapon_moneybag_pulse",
    "weapon_moneybag_instapulse"
}

local SOUND_SPAWN = "vip_mobster_emergent_r1b/moneybag_deploy.mp3"
local SOUND_HIT = "vip_mobster_emergent_r1b/moneybag_hitsound.mp3"
-- local SOUND_RESIST = "vip_mobster_emergent_r1b/moneybag_resist.mp3" -- STUPID USELESS CODE I HATE LUA ERRORS I HATE IT I HATE IT I HATE IT I HATE IT I HATE IT THIS IS STUPID 

function ENT:Initialize() -- THIS IS STUPID CODE AND MORE IMPORTANTLY I WISH TO NEVER MAKE THIS STUPID ENTITY OR UPDATE THIS ENTITY EVER AGAIN
    self:SetModel("models/props_others/w_moneybag_open.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end

    self.AttachedParticles = {}
    for _, fx in ipairs(PARTICLES) do
        ParticleEffectAttach(fx, PATTACH_ABSORIGIN_FOLLOW, self, 0)
    end

    self:EmitSound(SOUND_SPAWN, 75, 100, 1, CHAN_AUTO)

    self.NextEffect = CurTime()
    self.NextParticleRefresh = CurTime() + 4
end

function ENT:Think()
    local cur = CurTime()
    if not self.NextEffect or cur < self.NextEffect then return true end
    self.NextEffect = cur + 0.2

    local origin = self:GetPos()
    for _, ent in ipairs(ents.FindInSphere(origin, 200)) do
        if ent:IsPlayer() then
            if ent.SetArmor then
                ent:SetArmor(100)
            end

        elseif ent:IsNPC() and ent:Health() > 0 and ent.AddEntityRelationship then
            ent:AddEntityRelationship(self, D_HT, 99)
            ent:SetEnemy(self)
            ent:SetTarget(self)
            ent:SetSchedule(SCHED_CHASE_ENEMY)
        end
    end

    if cur >= self.NextParticleRefresh then
        for _, fx in ipairs(PARTICLES) do
            ParticleEffectAttach(fx, PATTACH_ABSORIGIN_FOLLOW, self, 0)
        end
        self.NextParticleRefresh = cur + 5
    end

    return true
end


function ENT:OnTakeDamage(dmg)
    self:EmitSound(SOUND_HIT, 75, 100, 1, CHAN_AUTO)
end

function ENT:OnRemove()
    -- Particles are cleaned up automatically when the entity is removed cause the partical effects are F#CKED so i have to make it refresh the partical effects
end