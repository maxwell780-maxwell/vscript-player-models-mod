SWEP.PrintName = "Money Bag"
SWEP.Author = "Code Copilot & maxwell"
SWEP.Category = "maxwells Vscript swep"
SWEP.Instructions = "press primary fire throw money bag hold reload to inspect"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"

SWEP.Slot = 1
SWEP.SlotPos = 2

SWEP.ViewModel = "models/vip_mobster/v_moneybag.mdl"
SWEP.WorldModel = "models/vip_mobster/w_moneybag_closed.mdl"
SWEP.UseHands = true
SWEP.HoldType = "slam"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Drawnormal = Sound("vip_mobster_emergent_r1b/moneybag_draw.mp3")
SWEP.Drawmultiply = Sound("weapons/cleaver_draw.wav")
SWEP.Thrownormal = Sound("weapons/cleaver_throw.wav")



SWEP.Inspecting = false
SWEP.MoneyBagThrown = false
SWEP.ThrownBagEntity = nil

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
    self:SendViewModelAnim("draw")
	
    self:EmitSound(self.Drawmultiply)

    -- only play sound if map is NOT vip_firebrand_rc1 thanks to code copoilot
    if game.GetMap():lower() ~= "vip_firebrand_rc1" then
        self:EmitSound(self.Drawnormal)
    end

    self:FixMoneybagBodygroup()

    timer.Simple(self:SequenceDuration(), function()
        if IsValid(self) then
            self:SendViewModelAnim("idle")
            self:FixMoneybagBodygroup()
        end
    end)

    return true
end


if SERVER then
    function SWEP:PrimaryAttack()
        if self.MoneyBagThrown then return end

        self:GetOwner():SetAnimation(PLAYER_ATTACK1)
        self:SetNextPrimaryFire(CurTime() + 30)
        self:SendViewModelAnim("bag_throw")
		self:EmitSound(self.Thrownormal)

        local vm = self:GetOwner():GetViewModel()
        local throwTime = vm:SequenceDuration(vm:LookupSequence("bag_throw"))

        timer.Simple(throwTime, function()
            if not IsValid(self) or not IsValid(self:GetOwner()) then return end

            local owner = self:GetOwner()
            local ent = ents.Create("moneybag_projectile")
            if not IsValid(ent) then return end

            local pos = owner:GetShootPos() + owner:GetAimVector() * 16
            local ang = owner:EyeAngles()
            ent:SetPos(pos)
            ent:SetAngles(ang)
            ent:Spawn()

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(owner:GetAimVector() * 300)
            end

            ent:SetOwner(owner)
            self.ThrownBagEntity = ent
            self.MoneyBagThrown = true
        end)
    end
end

function SWEP:Reload()
    if CLIENT then return end

    if not self.Inspecting then
        self.Inspecting = true
        self:SendViewModelAnim("inspect_start")

        local vm = self:GetOwner():GetViewModel()
        local dur = vm and vm:SequenceDuration(vm:LookupSequence("inspect_start")) or 1.5

        timer.Simple(dur, function()
            if IsValid(self) and self.Inspecting then
                self:SendViewModelAnim("inspect_loop")
            end
        end)
    end
end

function SWEP:Think()
    if CLIENT then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    self:FixMoneybagBodygroup()

    if self.Inspecting and not ply:KeyDown(IN_RELOAD) then
        self.Inspecting = false
        self:SendViewModelAnim("inspect_end")

        local vm = ply:GetViewModel()
        local dur = vm and vm:SequenceDuration(vm:LookupSequence("inspect_end")) or 1.5

        timer.Simple(dur, function()
            if IsValid(self) and not self.Inspecting then
                self:SendViewModelAnim("idle")
            end
        end)
    end

    if self.MoneyBagThrown and not IsValid(self.ThrownBagEntity) then
        self.MoneyBagThrown = false
        self.ThrownBagEntity = nil
    end
end

function SWEP:SendViewModelAnim(anim)
    local vm = self:GetOwner():GetViewModel()
    if not IsValid(vm) then return end
    local seq = vm:LookupSequence(anim)
    if seq and seq >= 0 then
        vm:SendViewModelMatchingSequence(seq)
        vm:SetPlaybackRate(1)
    end
end

function SWEP:SecondaryAttack()
    return false
end

if CLIENT then
    function SWEP:PostDrawViewModel(vm, weapon, ply)
        self:FixMoneybagBodygroup()
    end
end

function SWEP:FixMoneybagBodygroup()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    local vm = ply:GetViewModel()
    if not IsValid(vm) then return end

    local bgIndex = vm:FindBodygroupByName("Moneybag")
    if bgIndex >= 0 and vm:GetBodygroup(bgIndex) ~= 0 then
        vm:SetBodygroup(bgIndex, 0)
    end
end

function SWEP:DryFire()
    -- Suppress the click sound entirely
end


function SWEP:EmitSoundCustom(path, ...)
    if path ~= "weapons/weapon_empty.wav" then
        self:EmitSound(path, ...)
    end
end