SWEP.PrintName = "Metal Pipe"
SWEP.Author = "Code Copilot & maxwell"
SWEP.Instructions = "press primary fire to melee attack hold reload to inspect"
SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"
SWEP.Category = "maxwells Vscript swep"

SWEP.Slot = 2
SWEP.SlotPos = 3

SWEP.ViewModel = "models/vip_mobster/weapons/v_leadpipe.mdl"
SWEP.WorldModel = "models/vip_mobster/weapons/w_leadpipe.mdl"
SWEP.UseHands = true
SWEP.HoldType = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Damage = 35

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.Inspecting = false

local HIT_SOUNDS = {
    "weapons/cbar_hitbod1.wav",
    "weapons/cbar_hitbod2.wav",
    "weapons/cbar_hitbod3.wav"
}
local HIT_WORLD_SOUNDS = {
    "weapons/cbar_hit1.wav",
    "weapons/cbar_hit2.wav"
}
local SWING_SOUND = "weapons/cbar_miss1.wav"
local SWING_SOUND_CRIT = "weapons/cbar_miss1_crit.wav"

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self.KillCount = 0
    self.LastKillTime = 0
    self.ViewModelAnimMaxes = {
        ["pipe_draw"] = 1,
        ["pipe_idle"] = 1,
        ["pipe_attack"] = 1,
        ["pipe_attack2"] = 1,
        ["pipe_attack3"] = 1,
        ["pipe_inspect_start"] = 1,
        ["pipe_inspect_end"] = 1,
        ["pipe_inspect_idle"] = 1
    }
end

function SWEP:Deploy()
    self:SendViewModelAnim("pipe_draw")

    timer.Simple(self:SequenceDuration(), function()
        if IsValid(self) then
            self:SendViewModelAnim("pipe_idle")
        end
    end)

    timer.Simple(0, function()
        if IsValid(self) then
            self:UpdatePipeBodygroup()
        end
    end)

    return true
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.5)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)

    local anim = math.random(1, 3)
    self:SendViewModelAnim("pipe_attack" .. (anim == 1 and "" or anim))

    local isCrit = math.random() < 0.15
    self:EmitSound(isCrit and SWING_SOUND_CRIT or SWING_SOUND)

    local owner = self:GetOwner()
    owner:LagCompensation(true)

    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 75,
        filter = owner
    })

    owner:LagCompensation(false)

	if tr.Hit then
		if IsValid(tr.Entity) and (tr.Entity:IsNPC() or tr.Entity:IsPlayer() or tr.Entity:IsNextBot()) then
			if SERVER then
				tr.Entity:TakeDamage(self.Primary.Damage * (isCrit and 2 or 1), owner, self)
        end
        tr.Entity:EmitSound(table.Random(HIT_SOUNDS), 75, 100, 1, CHAN_WEAPON)
        else
            sound.Play(table.Random(HIT_WORLD_SOUNDS), tr.HitPos, 75, 100, 1)
        end
    end

    timer.Simple(self:SequenceDuration(), function()
        if IsValid(self) then self:SendViewModelAnim("pipe_idle") end
    end)
end

function SWEP:Reload()
    if CLIENT then return end

    if not self.Inspecting then
        self.Inspecting = true
        self:SendViewModelAnim("pipe_inspect_start")

        local vm = self:GetOwner():GetViewModel()
        local dur = vm and vm:SequenceDuration(vm:LookupSequence("pipe_inspect_start")) or 1.5

        timer.Simple(dur, function()
            if IsValid(self) and self.Inspecting then
                self:SendViewModelAnim("pipe_inspect_idle")
            end
        end)
    end
end

function SWEP:Think()
    if CLIENT then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if self.Inspecting and not ply:KeyDown(IN_RELOAD) then
        self.Inspecting = false
        self:SendViewModelAnim("pipe_inspect_end")

        local vm = ply:GetViewModel()
        local dur = vm and vm:SequenceDuration(vm:LookupSequence("pipe_inspect_end")) or 1.5

        timer.Simple(dur, function()
            if IsValid(self) and not self.Inspecting then
                self:SendViewModelAnim("pipe_idle")
            end
        end)
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

hook.Add("OnNPCKilled", "MobsterPipe_KillTracker", function(npc, attacker, inflictor)
    if IsValid(attacker) and attacker:IsPlayer() and IsValid(attacker:GetActiveWeapon()) then
        local wep = attacker:GetActiveWeapon()
        if wep:GetClass() == "mobster_metalpipe" then
            wep:AddKillCount()
        end
    end
end)

hook.Add("PlayerDeath", "MobsterPipe_KillTrackerPlayer", function(victim, inflictor, attacker)
    if IsValid(attacker) and attacker:IsPlayer() and IsValid(attacker:GetActiveWeapon()) then
        local wep = attacker:GetActiveWeapon()
        if wep:GetClass() == "mobster_metalpipe" then
            wep:AddKillCount()
        end
    end
end)

function SWEP:AddKillCount()
    self.KillCount = (self.KillCount or 0) + 1
    self:UpdatePipeBodygroup()
end

function SWEP:UpdatePipeBodygroup()
    local vm = self:GetOwner():GetViewModel()
    if not IsValid(vm) then return end

    local group = 0
    if self.KillCount >= 23 then
        group = 2
    elseif self.KillCount >= 13 then
        group = 1
    end
    vm:SetBodygroup(0, group) -- Assuming bodygroup index is 0
end

function SWEP:OnDrop()
    self.KillCount = 0
end

function SWEP:OnRemove()
    self.KillCount = 0
end

function SWEP:Equip()
    timer.Simple(0, function()
        if IsValid(self) then
            self:UpdatePipeBodygroup()
        end
    end)
end