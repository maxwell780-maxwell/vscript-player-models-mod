AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "RED Tank (heavy)"
ENT.Author = "Code Copilot & sourcegraph & maxwell"
ENT.Category = "maxwells custom tanks"
ENT.IconOverride = "vgui/icons/tank_heavy_icon"
ENT.Spawnable = true

-- Constants
local MODE_IDLE = 1
local MODE_ACTIVATED = 2
local MODE_WANDER = 3

function ENT:Initialize()
    self:SetModel("models/props_tank/tank_animated.mdl")
    self:SetSkin(1)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)

    if self.SetUseType then
        self:SetUseType(SIMPLE_USE)
    end

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(500)
    end

    self.CurrentHealth = 1000  -- Initialize CurrentHealth directly
    self.MaxHealth = 1000
    self.ExplosivesOnly = true -- Only take damage from explosives
    self.IsDying = false
    self.DeathTime = 0
    self.ExplosionCount = 0
    self.NextExplosion = 0
	
    self.TurnSpeed = 60
    self.DesiredYaw = nil
    self.AnimCycle = 0
    self.AnimRate = 0.4 -- slower playback for realism

    self.Speed = 100
    self.TurnRate = 30
    self.PushForce = 500

    self.WanderIdleCooldown = 0
    self.WanderMoving = true

    self.StartWanderingTime = CurTime() + 17  -- Wait 20 seconds before wandering
    self.CanWander = false

    self:SetMode(MODE_IDLE)
end

function ENT:OnTakeDamage(dmginfo)
    -- Initialize health if it doesn't exist yet
    if self.CurrentHealth == nil then
        self.CurrentHealth = 1000
    end
    
    -- Only take damage from explosives if ExplosivesOnly is true
    if self.ExplosivesOnly then
        local damageType = dmginfo:GetDamageType()
        if bit.band(damageType, DMG_BLAST) == 0 then
            -- Not explosive damage, return
            return
        end
    end
    
    -- Apply damage
    self.CurrentHealth = self.CurrentHealth - dmginfo:GetDamage()
    
    -- Play damage sound
    self:EmitSound("ambient/machines/thumper_shutdown1.wav", 85, 100)
    
    -- Check if tank is destroyed
    if self.CurrentHealth <= 0 and not self.IsDying then
        self:StartDeathSequence()
    end
end

function ENT:StartDeathSequence()
    self.IsDying = true
    self.DeathTime = CurTime()
    self.ExplosionCount = 0
    self.NextExplosion = CurTime()
    self:SetSkin(1)
    
    -- Play death animation if it exists
    local explodeSeq = self:LookupSequence("explode")
    if explodeSeq != -1 then
        self:ResetSequence(explodeSeq)
        self:SetPlaybackRate(1)
        self:SetCycle(0)
        
        -- Store animation duration to know when it ends
        local animDuration = self:SequenceDuration(explodeSeq)
        self.AnimEndTime = CurTime() + animDuration
        
        -- Add backup timer in case animation doesn't end properly
        self.BackupFreezeTime = CurTime() + 1

        -- If no animation exists, set a default end time
        self.AnimEndTime = CurTime() + 3
        self.BackupFreezeTime = CurTime() + 4
    end
    
    -- Stop physics movement
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
    end
    
    -- Play initial explosion sound
    self:EmitSound("ambient/explosions/explode_4.wav", 100, 100)
end


-- Handle the death sequence in Think with animation freezing
function ENT:HandleDeathSequence()
    if not self.IsDying then return end
    
    -- Check both regular end time and backup timer
    local shouldFreezeAnim = (self.AnimEndTime and CurTime() > self.AnimEndTime) or 
                            (self.BackupFreezeTime and CurTime() > self.BackupFreezeTime)
    
    -- Handle animation freezing at end
    if shouldFreezeAnim and not self.AnimFrozen then
        -- Freeze animation at the last frame
        self:SetCycle(0.99) -- Set to just before the end to avoid looping
        self:SetPlaybackRate(0) -- Stop the animation from playing
        self.AnimFrozen = true
        
        -- Force the entity to use this sequence and not change
        self.ForcedSequence = self:GetSequence()
        
        -- Switch to a looping reference animation if available
        local refSeq = self:LookupSequence("ref")
        if refSeq != -1 and refSeq != self:GetSequence() then
            self:ResetSequence(refSeq)
            self:SetPlaybackRate(1)
            self:SetCycle(0)
            self.ForcedSequence = refSeq
            self.UsingRefAnimation = true
        end
    end
    
    -- Create explosions every 10 seconds
    if CurTime() > self.NextExplosion then
        -- Create explosion effect
        local explosionPos = self:GetPos() + Vector(math.random(-50, 50), math.random(-50, 50), math.random(0, 50))
        
        local effectdata = EffectData()
        effectdata:SetOrigin(explosionPos)
        effectdata:SetScale(2)
        util.Effect("Explosion", effectdata)
        
        -- Play explosion sound
        self:EmitSound("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav", 100, 100)
        
        -- Increment explosion counter
        self.ExplosionCount = self.ExplosionCount + 1
        
        -- Schedule next explosion
        if self.ExplosionCount < 10 then
            self.NextExplosion = CurTime() + 1
        elseif self.ExplosionCount == 10 then
            -- Last explosion after 20 seconds
            self.NextExplosion = CurTime() + 1
        else
            -- Final destruction
            self:FinalDestruction()
        end
    end
    
    -- If using ref animation, let it play normally
    if self.UsingRefAnimation then
        -- Let the ref animation loop naturally
        return
    end
    
    -- If animation is frozen (but not using ref), make sure it stays frozen
    if self.AnimFrozen and self.ForcedSequence and not self.UsingRefAnimation then
        if self:GetSequence() != self.ForcedSequence then
            self:SetSequence(self.ForcedSequence)
        end
        if self:GetCycle() != 0.99 then
            self:SetCycle(0.99)
        end
        if self:GetPlaybackRate() != 0 then
            self:SetPlaybackRate(0)
        end
    end
end
-- Final destruction function
function ENT:FinalDestruction()
    -- Create final explosion
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetScale(5)
    util.Effect("Explosion", effectdata)
    
    -- Spawn gibs
    self:SpawnGibs()
    
    -- Remove the entity
    self:Remove()
end

-- Spawn gibs function
function ENT:SpawnGibs()
    -- Spawn tank body gib with skin 1
    local tankGib = ents.Create("prop_physics")
    if IsValid(tankGib) then
        tankGib:SetModel("models/props_others/other_stuff/tank.mdl")
        tankGib:SetPos(self:GetPos())
        tankGib:SetAngles(self:GetAngles())
        tankGib:SetSkin(1) -- Set skin to 1 for realism
        tankGib:Spawn()
        
        local gibPhys = tankGib:GetPhysicsObject()
        if IsValid(gibPhys) then
            gibPhys:ApplyForceCenter(Vector(math.random(-200, 200), math.random(-200, 200), math.random(100, 300)))
            gibPhys:AddAngleVelocity(Vector(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)))
        end
        
        -- Make gib dissolve after 50 seconds
        tankGib:Fire("Kill", "", 50)
    end
    
    -- Spawn tank turret gib with skin 1
    local turretGib = ents.Create("prop_physics")
    if IsValid(turretGib) then
        turretGib:SetModel("models/props_others/other_stuff/tank_turret.mdl")
        turretGib:SetPos(self:GetPos() + Vector(0, 0, 50))
        turretGib:SetAngles(self:GetAngles())
        turretGib:SetSkin(1) -- Set skin to 1 for realism
        turretGib:Spawn()
        
        local gibPhys = turretGib:GetPhysicsObject()
        if IsValid(gibPhys) then
            gibPhys:ApplyForceCenter(Vector(math.random(-200, 200), math.random(-200, 200), math.random(200, 400)))
            gibPhys:AddAngleVelocity(Vector(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100)))
        end
        
        -- Make gib dissolve after 50 seconds
        turretGib:Fire("Kill", "", 50)
    end
    
    -- Spawn soldier ragdoll with death sound and facial expression
    local ragdoll = ents.Create("prop_ragdoll")
    if IsValid(ragdoll) then
        ragdoll:SetModel("models/player/heavy.mdl")
        ragdoll:SetPos(self:GetPos() + Vector(0, 0, 70))
        ragdoll:SetAngles(self:GetAngles())
        ragdoll:Spawn()
        
        -- Set facial expression - pain
        ragdoll:SetFlexScale(1.0)
        
        -- Find the dead flex ID
        local dead03FlexID = ragdoll:GetFlexIDByName("dead03")
        if painFlexID then
            ragdoll:SetFlexWeight(painFlexID, 1.0) -- Set to maximum
        else
            -- Try alternative flex names if painBig doesn't exist
            local alternativeFlexes = {"dead03", "dead02", "dead01", "painbig"}
            for _, flexName in ipairs(alternativeFlexes) do
                local flexID = ragdoll:GetFlexIDByName(flexName)
                if flexID then
                    ragdoll:SetFlexWeight(flexID, 1.0)
                    break
                end
            end
        end
        
        -- Apply force to ragdoll pieces
        for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
            local bone = ragdoll:GetPhysicsObjectNum(i)
            if IsValid(bone) then
                bone:ApplyForceCenter(Vector(math.random(-100, 100), math.random(-100, 100), math.random(100, 300)))
            end
        end
        
        -- Play soldier death sound
        local deathSounds = {
            "vo/heavy_paincrticialdeath01.mp3",
            "vo/heavy_paincrticialdeath03.mp3",
            "vo/heavy_paincrticialdeath02.mp3",
            "vo/heavy_painsevere02.mp3",
            "vo/heavy_painsevere01.mp3",
            "vo/heavy_painsevere03.mp3"
        }
        
        -- Pick a random death sound
        local chosenSound = deathSounds[math.random(#deathSounds)]
        
        -- Play sound directly on the ragdoll
        ragdoll:EmitSound(chosenSound, 100, 100)
        
        -- Make ragdoll dissolve after 50 seconds
        ragdoll:Fire("Kill", "", 50)
    end
end


function ENT:SetMode(mode)
    self.Mode = mode

    if mode == MODE_IDLE then
        self:SetSkin(1)
        self:ResetSequence("ref")
        self.NextModeSwitch = CurTime() + math.Rand(5, 20)

    elseif mode == MODE_ACTIVATED then
        self:SetSkin(0)
        self:ResetSequence("idle")
        self.TankSound = CreateSound(self, "mvm/mvm_tank_loop.wav")
        self.TankSound:PlayEx(1, 100)
        self.NextModeSwitch = CurTime() + 3

    elseif mode == MODE_WANDER then
        self:ResetSequence("move_slow")
        self:SetPlaybackRate(self.AnimRate)
        self.AnimCycle = 0
        self.MoveCooldown = 0
        self.WanderIdleCooldown = CurTime() + math.Rand(8, 14)
        self.WanderMoving = true
    end
end

function ENT:Think()
    if self.Mode == MODE_IDLE and CurTime() > self.NextModeSwitch then
        self:SetMode(MODE_ACTIVATED)
    elseif self.Mode == MODE_ACTIVATED and CurTime() > self.NextModeSwitch then
        self:SetMode(MODE_WANDER)
    elseif self.Mode == MODE_WANDER then
        self:HandleWander()
    end

    self.AnimCycle = (self.AnimCycle + FrameTime() * self.AnimRate) % 1
    self:SetCycle(self.AnimCycle)

    if self.IsDying then
        self:HandleDeathSequence()
        
        -- Additional check for backup timer
        if not self.AnimFrozen and self.BackupFreezeTime and CurTime() > self.BackupFreezeTime then
            self:SetCycle(0.99)
            self:SetPlaybackRate(0)
            self.AnimFrozen = true
            
            -- Try to switch to ref animation
            local refSeq = self:LookupSequence("ref")
            if refSeq != -1 then
                self:ResetSequence(refSeq)
                self:SetPlaybackRate(1)
                self:SetCycle(0)
                self.ForcedSequence = refSeq
                self.UsingRefAnimation = true
            end
        end
    else
        self:HandleWander()
    end
	
    self:NextThink(CurTime())
    return true
end

function ENT:HandleWander()
    -- Don't wander if dying or if it's not time to wander yet
    if self.IsDying then return end
    if not self.CanWander then
        if CurTime() > self.StartWanderingTime then
            self.CanWander = true
            -- Optional: Play a sound or effect when the tank starts moving
            self:EmitSound("vehicles/tank_turret_start1.wav", 75, 100)
        else
            return -- Don't wander yet
        end
    end
    
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end
    
    -- Initialize movement properties if they don't exist
    if not self.Speed then self.Speed = 100 end
    if not self.TurnRate then self.TurnRate = 30 end
    if not self.LastThink then self.LastThink = CurTime() end
    if not self.NextDirectionChange then self.NextDirectionChange = CurTime() + math.Rand(3, 6) end
    if not self.TargetYaw then self.TargetYaw = self:GetAngles().y end
    if not self.PushForce then self.PushForce = 500 end
    
    local deltaTime = CurTime() - self.LastThink
    self.LastThink = CurTime()
    
    -- Randomly change direction
    if CurTime() > self.NextDirectionChange then
        local turnAmount = math.random(-90, 90)
        self.TargetYaw = (self:GetAngles().y + turnAmount) % 360
        self.NextDirectionChange = CurTime() + math.Rand(3, 8)
    end
    
    -- Smooth turning
    local currentYaw = self:GetAngles().y
    local yawDiff = math.AngleDifference(self.TargetYaw, currentYaw)
    
    if math.abs(yawDiff) > 1 then
        local turnAmount = math.Clamp(yawDiff, -self.TurnRate * deltaTime, self.TurnRate * deltaTime)
        local newYaw = currentYaw + turnAmount
        
        local newAng = self:GetAngles()
        newAng.y = newYaw
        self:SetAngles(newAng)
    end
    
    -- Enhanced wall detection with multiple traces
    local forward = self:GetForward()
    local right = self:GetRight()
    local pos = self:GetPos()
    local wallDetected = false
    local wallNormal = Vector(0, 0, 0)
    local entityInPath = nil
    
    -- Create an array of trace positions (center, left, right)
    local tracePositions = {
        {start = pos + Vector(0, 0, 20), dir = forward, weight = 1.0},
        {start = pos + Vector(0, 0, 20) + right * 30, dir = forward, weight = 0.7},
        {start = pos + Vector(0, 0, 20) - right * 30, dir = forward, weight = 0.7}
    }
    
    -- Check all trace positions
    for _, tracePos in ipairs(tracePositions) do
        local tr = util.TraceLine({
            start = tracePos.start,
            endpos = tracePos.start + tracePos.dir * 100, -- Detect walls within 100 units
            filter = self
        })
        
        if tr.Hit then
            -- Debug visualization
            debugoverlay.Line(tracePos.start, tr.HitPos, 0.1, Color(255, 0, 0), true)
            
            if tr.Entity:IsWorld() then
                -- Wall detected - store the normal for turning away
                wallDetected = true
                wallNormal = wallNormal + (tr.HitNormal * tracePos.weight)
            elseif IsValid(tr.Entity) then
                entityInPath = tr.Entity
            end
        else
            -- Debug visualization
            debugoverlay.Line(tracePos.start, tracePos.start + tracePos.dir * 100, 0.1, Color(0, 255, 0), true)
        end
    end
    
    -- Handle wall detection
    if wallDetected then
        -- Turn away from the wall using the wall normal
        wallNormal:Normalize()
        local turnAwayAngle = wallNormal:Angle().y
        self.TargetYaw = turnAwayAngle
        
        -- Slow down near walls
        phys:SetVelocity(phys:GetVelocity() * 0.7)
    end
    
    -- Handle entity in path
    if IsValid(entityInPath) then
        -- Push entity out of the way
        local entityPhys = entityInPath:GetPhysicsObject()
        
        if IsValid(entityPhys) then
            -- Push physics objects
            local pushDir = (entityInPath:GetPos() - self:GetPos()):GetNormalized()
            entityPhys:ApplyForceCenter(pushDir * self.PushForce * entityPhys:GetMass())
        elseif entityInPath:IsPlayer() or entityInPath:IsNPC() or entityInPath.IsNextBot then
            -- Push players, NPCs, and NextBots
            local pushDir = (entityInPath:GetPos() - self:GetPos()):GetNormalized()
            local pushVelocity = pushDir * self.PushForce * 0.05
            
            if entityInPath:IsPlayer() then
                entityInPath:SetVelocity(entityInPath:GetVelocity() + pushVelocity)
            else
                entityInPath:SetVelocity(pushVelocity)
            end
        end
        
        -- Continue moving forward with extra force to push through
        phys:ApplyForceCenter(forward * self.Speed * phys:GetMass() * 1.5)
    end
    
    -- Apply movement force
    local moveDir = self:GetForward()
    local moveForce = moveDir * self.Speed * phys:GetMass()
    
    -- Apply force to center of mass for better movement
    phys:ApplyForceCenter(moveForce)
    
    -- Apply some damping to prevent excessive sliding
    phys:AddAngleVelocity(phys:GetAngleVelocity() * -0.3)
    
    -- Limit velocity to prevent excessive speed
    local velocity = phys:GetVelocity()
    local maxSpeed = self.Speed * 0.75
    if velocity:Length() > maxSpeed then
        phys:SetVelocity(velocity:GetNormalized() * maxSpeed)
    end
    
    -- Keep the tank upright
    if self.IsOnGround then
        local ang = self:GetAngles()
        if math.abs(ang.r) > 11 or math.abs(ang.p) > 11 then
            -- Only reset angles if they're significantly off
            local newAng = Angle(0, ang.y, 0)
            self:SetAngles(newAng)
		end
    end
end

-- Add this function to handle collisions better
function ENT:PhysicsCollide(data, phys)
    -- Get collision information
    local hitEnt = data.HitEntity
    local hitPos = data.HitPos
    local hitNormal = data.HitNormal
    local hitSpeed = data.Speed
    
    -- If we hit a wall at high speed
    if hitEnt:IsWorld() and hitSpeed > 50 then
        -- Bounce off the wall
        phys:SetVelocity(phys:GetVelocity() * 0.5)
        
        -- Turn away from the wall
        local newDirection = hitNormal:Angle().y
        self.TargetYaw = newDirection
        self.NextDirectionChange = CurTime() + math.Rand(2, 4)
        
        -- Play a collision sound if you have one
        self:EmitSound("vehicles/v8/vehicle_impact_medium" .. math.random(1, 4) .. ".wav")
    end
    
    -- If we hit an entity
    if IsValid(hitEnt) and not hitEnt:IsWorld() then
        -- Push the entity
        local entPhys = hitEnt:GetPhysicsObject()
        if IsValid(entPhys) then
            local pushDir = (hitEnt:GetPos() - self:GetPos()):GetNormalized()
            entPhys:ApplyForceCenter(pushDir * self.PushForce * entPhys:GetMass())
        end
    end
end


function ENT:OnRemove()
    if self.TankSound then
        self.TankSound:Stop()
    end
end

function ENT:GetHealth()
    if self.CurrentHealth == nil then
        self.CurrentHealth = 1000
    end
    return self.CurrentHealth
end

function ENT:SetHealth(amount)
    self.CurrentHealth = amount
end

function ENT:SetSequence(seq)
    if self.AnimFrozen and self.ForcedSequence then
        -- If animation is frozen, don't allow sequence changes
        return
    end
    
    -- Call the original SetSequence
    self.BaseClass.SetSequence(self, seq)
end