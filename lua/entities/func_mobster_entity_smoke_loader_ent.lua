AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "func_mobster_entity_smoke_loader_ent"
ENT.Author = "Code Copilot & maxwell"
ENT.Category = "maxwells map buildable entitys"
ENT.Information = "Temporary entity used to force mobster_appearation particle to load correctly i know is kinda weird using an entity for a simple partical effect idk why does mobster smoke effect dont appear in an autorun script"
ENT.IconOverride = "vgui/icons/mobster_spawn_smoke_teaser_icon"
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:Initialize()
    self:SetModel("models/maxofs2d/cube_tool.mdl")
    self:DrawShadow(false)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)

    if SERVER then
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

        local effectName = "mobster_appearation"
        ParticleEffectAttach(effectName, PATTACH_ABSORIGIN_FOLLOW, self, 0)

        -- Replace with actual particle length, or estimate it
        local particleDuration = 3.0
        timer.Simple(particleDuration, function()
            if IsValid(self) then self:Remove() end -- after time ends then remove the entity the partical has now loaded into gmod
        end)
    end
end
