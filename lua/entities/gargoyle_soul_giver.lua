AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Soul"
ENT.Author = "code copilot & maxwell"
ENT.Category = "behind the scenes n stuff"
ENT.Spawnable = false

-- Model, effect, and sound settings
ENT.Model = "models/weapons/v_models/v_baseball.mdl"
ENT.ParticleEffect = "soul_trail"
ENT.HealDistance = 11
ENT.HealAmount = 1
ENT.FlySpeed = 5
ENT.SeparationDistance = 150

ENT.HealSounds = {
    "player/souls_receive3.wav",
    "player/souls_receive1.wav",
    "player/souls_receive2.wav"
}

-- Follow the player or entity that picked it up
function ENT:SetFollowTarget(target)
    self.FollowTarget = target
end

function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)
        self:SetNoDraw(true)
        self:SetMoveType(MOVETYPE_FLY)
        self:SetSolid(SOLID_NONE)
        self:SetPersistent(true)
        
        ParticleEffectAttach(self.ParticleEffect, PATTACH_ABSORIGIN_FOLLOW, self, 0)
    end
end

function ENT:Think()
    if CLIENT then return end

    -- Make the soul follow its target (the player or entity that picked it up)
    if IsValid(self.FollowTarget) then
        local direction = (self.FollowTarget:GetPos() - self:GetPos()):GetNormalized()
        
        -- Push away from other souls
        for _, soul in ipairs(ents.FindByClass("soul_entity")) do
            if soul ~= self and IsValid(soul) and self:GetPos():Distance(soul:GetPos()) < self.SeparationDistance then
                local separationDir = (self:GetPos() - soul:GetPos()):GetNormalized()
                direction = direction + separationDir * 0.5
            end
        end
        
        direction:Normalize()
        self:SetPos(self:GetPos() + direction * self.FlySpeed)

        -- Heal the target (player or NPC), but give max health to NPCs instead of armor
        local nearestDistance = self:GetPos():Distance(self.FollowTarget:GetPos())
        if nearestDistance <= self.HealDistance then
            if self.FollowTarget:IsPlayer() then
                -- For players, heal health and armor as before
                self.FollowTarget:SetHealth(self.FollowTarget:Health() + self.HealAmount) -- Overheal allowed
                self.FollowTarget:SetArmor(self.FollowTarget:Armor() + 1)
            elseif self.FollowTarget:IsNPC() then
                -- For NPCs, heal max health instead of armor
                local currentHealth = self.FollowTarget:Health()
                local maxHealth = self.FollowTarget:GetMaxHealth()
                local newHealth = math.min(currentHealth + self.HealAmount, maxHealth)
                self.FollowTarget:SetHealth(newHealth) -- Increase health up to max health
            end
            
            self.FollowTarget:EmitSound(table.Random(self.HealSounds), 75, 100, 1, CHAN_AUTO)
            self:Remove() -- Remove the soul after healing
        end
    end

    self:NextThink(CurTime() + 0.01)
    return true
end