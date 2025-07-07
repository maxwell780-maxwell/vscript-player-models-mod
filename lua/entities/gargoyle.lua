AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Soul Gargoyle"
ENT.Author = "code copilot & chatgpt & maxwell"
ENT.Category = "maxwells gargoyle Entity"
ENT.Spawnable = true

ENT.IconOverride = "vgui/icons/gargoyle entity icon"

-- Model and sound settings 
ENT.Model = "models/props_halloween/gargoyle_ghost.mdl"
ENT.PickupSound = "items/gift_pickup.wav"

ENT.SpinSpeed = 1
ENT.PickupDistance = 100 -- Distance for pickup
ENT.NPCAttractDistance = 500 -- Distance within which NPCs will be attracted
ENT.SoulCount = 3 -- Number of souls to spawn
ENT.SoulSpawnRadius = 50 -- Radius for circular soul spawn

-- Initialize the gargoyle entity
function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_BBOX)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        self:PhysicsInit(SOLID_VPHYSICS)
    end
end

-- Spawn soul and set target for following
function ENT:SpawnSoul(followTarget, angleOffset)
    local spawnPos = self:GetPos() + Vector(math.cos(angleOffset) * self.SoulSpawnRadius, math.sin(angleOffset) * self.SoulSpawnRadius, 0)
    
    local soul = ents.Create("gargoyle_soul_giver")
    if IsValid(soul) then
        soul:SetPos(spawnPos)
        soul:Spawn()
        soul:SetOwner(followTarget) -- Set the owner to follow
        soul:SetFollowTarget(followTarget) -- Custom function to follow target
    end
end

function ENT:Think()
    if CLIENT then return end

    -- Spin the entity
    local ang = self:GetAngles()
    ang.y = ang.y + self.SpinSpeed
    self:SetAngles(ang)

    -- Check for nearby players or NPCs
    for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.NPCAttractDistance)) do
        if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) then
            local dist = ent:GetPos():Distance(self:GetPos())

            -- Make NPC walk towards the gargoyle
            if ent:IsNPC() and dist > self.PickupDistance then
                ent:SetLastPosition(self:GetPos())
                ent:SetSchedule(SCHED_FORCED_GO_RUN)
            end

            -- Pickup logic for players and NPCs
            if dist <= self.PickupDistance then
                ent:EmitSound(self.PickupSound)

                -- Spawn souls around the Gargoyle and make them follow the player
                for i = 1, self.SoulCount do
                    local angleOffset = (math.pi * 2 / self.SoulCount) * i
                    local soul = self:SpawnSoul(ent, angleOffset)
                    if IsValid(soul) and ent:IsPlayer() then
                        soul:SetParent(ent) -- Attach souls to the player
                    end
                end

                -- Pause NPC behavior for pickup
                if ent:IsNPC() then
                    local originalState = ent:GetSaveTable().m_iState
                    ent:SetSaveValue("m_iState", 0)
                    timer.Simple(2, function()
                        if IsValid(ent) then
                            ent:SetSaveValue("m_iState", originalState)
                        end
                    end)
                end

                -- Remove the gargoyle after pickup
                self:Remove()
                return
            end
        end
    end

    -- Schedule next think
    self:NextThink(CurTime() + 0.01)
    return true
end

-- Spawn command for the Gargoyle entity
concommand.Add("spawn_gargoyle", function(ply)
    if not IsValid(ply) then return end

    local ent = ents.Create("gargoyle_entity")
    if IsValid(ent) then
        ent:SetPos(ply:GetEyeTrace().HitPos + Vector(0, 0, 10))
        ent:Spawn()
    end
end)