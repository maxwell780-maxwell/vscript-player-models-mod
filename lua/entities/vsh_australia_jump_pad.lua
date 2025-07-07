-- File: lua/entities/ent_jumppad/shared.lua

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "vsh australia Jump Pad"
ENT.Author = "Code Copilot & maxwell"
ENT.Spawnable = true
ENT.Category = "maxwells vsh custom entitys"
ENT.IconOverride = "vgui/icons/jump_pad_icon"

-- File: lua/entities/ent_jumppad/init.lua

-- not that it is useful but keep anyways

AddCSLuaFile()

function ENT:Initialize() -- YES IM NOT THAT GOOD OF A LUA CODDER DONT ASK. - dragonlords
    self:SetModel("models/props_vsh_australia/jumppad.mdl")
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    self:SetCollisionBounds(Vector(-120, -120, 0), Vector(120, 120, 32)) -- adjusted the collision bounds by myself DANG im smart.
    self:UseTriggerBounds(true, 32)

    local seq = self:LookupSequence("idle_hover")
    if seq and seq >= 0 then
        self:ResetSequence(seq)
        self:SetCycle(0)
        self:SetPlaybackRate(1.0)
    end
end

function ENT:StartTouch(ent)
    if not IsValid(ent) then return end
    if ent:IsPlayer() or ent:IsNPC() then
        local entBottom = ent:GetPos().z
        local padTop = self:GetPos().z + 16  -- half of collision height
        if entBottom >= padTop then  -- Only boost if above top
            local vel = ent:GetVelocity()
            vel.z = 500
            ent:SetVelocity(vel)
            self:EmitSound("weapons/flame_thrower_airblast.wav", 75, 100, 1, CHAN_AUTO)
        end
    end
end

function ENT:Think()
    self:FrameAdvance(FrameTime())
    self:NextThink(CurTime())
    return true
end