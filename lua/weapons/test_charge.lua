SWEP.PrintName = "Sweeping Charge (prototype)"
SWEP.Author = "Code Copilot & sourcegraph & maxwell"
SWEP.Instructions = "Hold RELOAD to charge, release to dash this is basicly a prototype for the charge ability no this is not indended as a swep rather a prototype for sweeping charge"
SWEP.Category = "Custom"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"
SWEP.HoldType = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary = SWEP.Primary
SWEP.DrawAmmo = false
SWEP.ViewModel = "models/weapons/c_models/c_saxton_arms.mdl"
SWEP.WorldModel = ""

local CHARGE_COOLDOWN = 10
local CHARGE_SPEED = 1400
local CHARGE_DURATION = 1.0
local CHARGE_DAMAGE_PCT = 0.55
local CHARGE_DISTANCE = 1500
local KNOCKBACK_FORCE = 600

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self:SetNWBool("Charging", false)
    self:SetNWBool("Dashing", false)
    self.NextCharge = CurTime() + CHARGE_COOLDOWN
    self.CooldownPlayed = false
    self.FirstDeploy = true
    self.HasPlayedWindup = false
end

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "ChargeStart")
    self:NetworkVar("Bool", 0, "Charging")
    self:NetworkVar("Bool", 1, "Dashing")
    self:NetworkVar("Float", 1, "DashEnd")
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    -- Play cooldown finished sound once, skip if first deploy
    if CurTime() >= self.NextCharge and not self.CooldownPlayed and not self.FirstDeploy then
        owner:EmitSound("player/recharged.wav")
        self.CooldownPlayed = true
    end

    if self:GetCharging() and not owner:KeyDown(IN_RELOAD) then
        self:ReleaseCharge()
    end

    if not self.OriginalSkin then
        self.OriginalSkin = owner:GetSkin()
    end

    if self:GetCharging() then
        self:SetHoldType("magic")
        owner:SetSkin(self.OriginalSkin == 2 and 4 or 3)

        local vm = owner:GetViewModel()
        if IsValid(vm) and not self.HasPlayedWindup then
            vm:SetPlaybackRate(1)
            vm:SendViewModelMatchingSequence(vm:LookupSequence("vsh_dash_windup"))
            self.HasPlayedWindup = true
        end

    elseif self:GetDashing() then
        self:SetHoldType("fist")
        if CurTime() > self:GetDashEnd() then
            self:EndDash()
        else
            local vm = owner:GetViewModel()
            if IsValid(vm) then
                vm:SetPlaybackRate(1)
                vm:SendViewModelMatchingSequence(vm:LookupSequence("vsh_dash_loop"))
            end
            self:MaintainDash()
        end
    else
        owner:SetSkin(self.OriginalSkin == 2 and 2 or 0)
        self:SetHoldType("melee")
    end
end

function SWEP:Reload()
    if CurTime() < self.NextCharge then return end
    if self:GetCharging() or self:GetDashing() then return end

    self:SetCharging(true)
    self:SetChargeStart(CurTime())
    self.CooldownPlayed = false
    self.HasPlayedWindup = false

    local owner = self:GetOwner()
    if CLIENT then return end

    owner:SetMoveType(MOVETYPE_NONE)
    owner:EmitSound("weapons/stickybomblauncher_charge_up.wav")
end

function SWEP:ReleaseCharge()
    local owner = self:GetOwner()
    if not IsValid(owner) or not self:GetCharging() then return end

    self:SetCharging(false)
    self:SetDashing(true)
    self:SetDashEnd(CurTime() + CHARGE_DURATION)

    if SERVER then
        owner:SetMoveType(MOVETYPE_WALK)
        self.HitEntities = {}
        owner:EmitSound("npc/strider/strider_skewer1.wav")
    end
end

function SWEP:MaintainDash()
    if CLIENT then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    local dir = owner:GetAimVector()
    dir.z = math.Clamp(dir.z, -0.6, 0.6)
    dir:Normalize()
    
    local vel = dir * CHARGE_SPEED
    owner:SetVelocity(-owner:GetVelocity() + vel)
    
    if not self.HitEntities then self.HitEntities = {} end
    
    local hitEnt = self:CheckDashCollision()
    if IsValid(hitEnt) and not table.HasValue(self.HitEntities, hitEnt) then
        table.insert(self.HitEntities, hitEnt)
        
        local maxHP = 100
        if hitEnt:IsPlayer() or hitEnt:IsNPC() then
            maxHP = hitEnt:GetMaxHealth() or 100
        end
        
        local damage = math.floor(maxHP * CHARGE_DAMAGE_PCT)
        
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(damage)
        dmginfo:SetAttacker(owner)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamageType(DMG_CLUB)
        dmginfo:SetDamageForce(owner:GetAimVector() * 10000)
        
        hitEnt:TakeDamageInfo(dmginfo)
        
        local fleshSound = "weapons/demo_charge_hit_flesh" .. math.random(1, 3) .. ".wav"
        hitEnt:EmitSound(fleshSound)
        
        local knockback = (hitEnt:GetPos() - owner:GetPos()):GetNormalized() * KNOCKBACK_FORCE
        knockback.z = 200
        hitEnt:SetVelocity(knockback)
    end
end

function SWEP:EndDash()
    self:SetDashing(false)
    self.NextCharge = CurTime() + CHARGE_COOLDOWN
    self.CooldownPlayed = false
    self.FirstDeploy = false
    self.HitEntities = {}

    local owner = self:GetOwner()
    if IsValid(owner) then
        local vm = owner:GetViewModel()
        if IsValid(vm) then
            vm:SetPlaybackRate(1)
            vm:SendViewModelMatchingSequence(vm:LookupSequence("vsh_dash_end"))
        end
    end
end

function SWEP:Deploy()
    self:SetCharging(false)
    self:SetDashing(false)
    return true
end

function SWEP:Holster()
    local owner = self:GetOwner()
    if self:GetCharging() or self:GetDashing() then
        self:SetCharging(false)
        self:SetDashing(false)
        if IsValid(owner) then
            owner:SetMoveType(MOVETYPE_WALK)
        end
    end
    return true
end

function SWEP:CheckDashCollision()
    local owner = self:GetOwner()
    if not IsValid(owner) then return nil end
    
    local traceData = {
        start = owner:GetPos(),
        endpos = owner:GetPos() + owner:GetAimVector() * 80,
        filter = owner,
        mins = Vector(-20, -20, 0),
        maxs = Vector(20, 20, 72),
        mask = MASK_SHOT_HULL
    }
    
    local trace = util.TraceHull(traceData)
    
    if SERVER then
        debugoverlay.Box(trace.HitPos, traceData.mins, traceData.maxs, 1, Color(255, 0, 0, 100))
    end
    
    if trace.Hit and IsValid(trace.Entity) then
        if trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:Health() > 0 then
            return trace.Entity
        end
    end
    
    return nil
end