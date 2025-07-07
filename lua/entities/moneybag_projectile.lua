AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Money Projectile"
ENT.Category = "maxwells projectile entitys"
ENT.Author = "Code Copilot & maxwell & sourcegraph"
ENT.Spawnable = false

function ENT:Initialize()
    if SERVER then
        local model = "models/vip_mobster/w_moneybag_closed.mdl"
        util.PrecacheModel(model)
        
        self:SetModel(model)
        self:Activate()
        
        timer.Simple(0.1, function()
            if IsValid(self) then
                self:SetModel(model)
            end
        end)
        
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        
        self:SetRenderMode(RENDERMODE_NORMAL)
        self:DrawShadow(true)
        self:SetNoDraw(false)
        self:EnableCustomCollisions(false)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableGravity(true)
            phys:SetMass(10) -- Adjust weight for throwing feel
        end
        
        -- Auto-remove after some time if it doesn't hit anything
        timer.Simple(10, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end
end

function ENT:PhysicsCollide(data, physobj)
    if SERVER then
        local pos = self:GetPos()
        local ang = self:GetAngles()

        timer.Simple(0, function()
            if not IsValid(self) then return end
            self:Remove()

            local moneybag = ents.Create("moneybag")
            if IsValid(moneybag) then
                moneybag:SetPos(pos)
                moneybag:SetAngles(ang)
                moneybag:Spawn()
            end
        end)
    end
end

function ENT:Throw(direction, force)
    if SERVER then
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            force = force or 10000000
            phys:SetVelocity(direction * force)
            phys:AddAngleVelocity(Vector(math.random(-500, 500), math.random(-500, 500), math.random(-500, 500)))
        end
    end
end