SWEP.PrintName = "Typewriter"
SWEP.Author = "Code Copilot & maxwell"
SWEP.Instructions = "press primary fire to shoot duh hold H to inspect weapon press secondary fire to SHOVE"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"
SWEP.Category = "maxwells Vscript swep"

SWEP.ViewModel = "models/vip_mobster/weapons/v_typewriter.mdl"
SWEP.WorldModel = "models/vip_mobster/weapons/w_typewriter.mdl"
SWEP.UseHands = true
SWEP.HoldType = "ar2"

SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Damage = 10

SWEP.Primary.Sounds_Normal = {
    "vip_mobster_emergent_r1b/typewriter_fire01.mp3",
    "vip_mobster_emergent_r1b/typewriter_fire02.mp3",
    "vip_mobster_emergent_r1b/typewriter_fire03.mp3"
}
SWEP.Primary.Sounds_Crit = {
    "vip_mobster_emergent_r1b/typewriter_fire01_crit.mp3",
    "vip_mobster_emergent_r1b/typewriter_fire02_crit.mp3",
    "vip_mobster_emergent_r1b/typewriter_fire03_crit.mp3"
}
SWEP.Primary.Sounds_Low = {
    "vip_mobster_emergent_r1b/typewriter_fire01_low.mp3",
    "vip_mobster_emergent_r1b/typewriter_fire02_low.mp3",
    "vip_mobster_emergent_r1b/typewriter_fire03_low.mp3"
}
SWEP.Primary.Sounds_LowCrit = {
    "vip_mobster_emergent_r1b/typewriter_fire01_low_crit.mp3",
    "vip_mobster_emergent_r1b/typewriter_fire02_low_crit.mp3",
    "vip_mobster_emergent_r1b/typewriter_fire03_low_crit.mp3"
}

SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.ShoveDamage = 65

SWEP.NoAmmoSound = Sound("vip_mobster_emergent_r1b/typewriter_noammo.mp3")
SWEP.ReloadSound = Sound("vip_mobster_emergent_r1b/typewriter_reload.mp3")
SWEP.Reloadnormal = Sound("weapons/short_stop_reload.wav")
SWEP.Shovenormal = Sound("weapons/push.wav")

SWEP.IsReloading = false
SWEP.IsShoving = false
SWEP.IsInspecting = false
SWEP.HasPlayedInspectStart = false

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self.ViewModelAnimMaxes = {
        ["draw"] = 1,
        ["idle"] = 1,
        ["fire"] = 1,
        ["reload"] = 1
    }
    if SERVER then
        -- Register the network message
        util.AddNetworkString("SWEP_InspectKey")
    end
    
    if CLIENT then
        self.LastInspectKeyState = false
    end
end


function SWEP:Deploy()
    self.IsReloading = false -- Reset reload state on deploy
    self:SendViewModelAnim("draw")
    timer.Simple(self:SequenceDuration(), function()
        if IsValid(self) then 
            self:SendViewModelAnim("idle") 
        end
    end)
    return true
end

function SWEP:PrimaryAttack()
    if self:Clip1() <= 0 then
        self:CheckDryFireSound()
        return
    end

    self:SetNextPrimaryFire(CurTime() + 0.1)

    local isCrit = math.random() < 0.1
    local isLow = self:Clip1() <= 10
    local sndTbl = isCrit and (isLow and self.Primary.Sounds_LowCrit or self.Primary.Sounds_Crit)
        or (isLow and self.Primary.Sounds_Low or self.Primary.Sounds_Normal)

    local index = math.random(1, #sndTbl)
    self:EmitSound(sndTbl[index])

    self:SendViewModelAnim("fire")

    local damage = self.Primary.Damage
    if isCrit then damage = damage * 3 end

    self:ShootBullet(damage, 1, 0.01)
    self:TakePrimaryAmmo(1)

    timer.Simple(self:SequenceDuration(), function()
        if IsValid(self) then self:SendViewModelAnim("idle") end
    end)
end

function SWEP:SecondaryAttack()
    if self.IsShoving then return end
    if self:GetNextSecondaryFire() > CurTime() then return end
	
    self:EmitSound(self.Shovenormal)

    self.IsShoving = true
    local anim = math.random(1, 2) == 1 and "shove" or "shove2"
    self:SendViewModelAnim(anim)
    self:GetOwner():SetAnimation(PLAYER_ATTACK1)

    local owner = self:GetOwner()
    owner:LagCompensation(true)
    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 75,
        filter = owner
    })
    owner:LagCompensation(false)

    if tr.Hit and tr.Entity and tr.Entity.TakeDamage then
        tr.Entity:TakeDamage(self.ShoveDamage, owner, self)
    end

    local vm = self:GetOwner():GetViewModel()
    local shoveDuration = vm and vm:SequenceDuration(vm:LookupSequence(anim)) or 5.8

    timer.Simple(shoveDuration, function()
        if IsValid(self) then
            self.IsShoving = false
            self:SetNextSecondaryFire(CurTime())
            self:SendViewModelAnim("idle")
        end
    end)
end

function SWEP:Reload()
    if self:Clip1() >= self.Primary.ClipSize then return end
    if self:Ammo1() <= 0 then return end
    if self.IsReloading then return end
    
    self.IsReloading = true
    self:EmitSound(self.Reloadnormal)
    
    local vm = self:GetOwner():GetViewModel()
    local seq = vm and vm:LookupSequence("reload") or -1
    local reloadTime = (seq >= 0 and vm:SequenceDuration(seq)) or 2.0
    
    -- Force the reload animation and lock it
    if IsValid(vm) then
        vm:SendViewModelMatchingSequence(seq)
        vm:SetPlaybackRate(1.0)
        vm:SetCycle(0)
        -- Lock the animation by setting a high cycle rate
        vm:SetSequence(seq)
    end
    
    self:DefaultReload(ACT_VM_RELOAD)
    
    local soundDelay = 0.6
    timer.Simple(soundDelay, function()
        if IsValid(self) and self.IsReloading then
            self:EmitSound(self.ReloadSound)
        end
    end)
    
    timer.Simple(reloadTime, function()
        if IsValid(self) then
            self.IsReloading = false
            -- Now safely return to idle
            if IsValid(vm) then
                local idleSeq = vm:LookupSequence("idle")
                vm:SendViewModelMatchingSequence(idleSeq)
                vm:SetPlaybackRate(1.0)
            end
        end
    end)
end

function SWEP:Think()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    -- Don't let idle animations play during reload
    if self.IsReloading then
        return
    end
    
    -- Handle inspection animation
    if CLIENT then
        -- Client-side key detection
        local holdingInspect = input.IsKeyDown(KEY_H)
                
        -- Send key state to server
        if holdingInspect ~= self.LastInspectKeyState then
            self.LastInspectKeyState = holdingInspect
            net.Start("SWEP_InspectKey")
            net.WriteBool(holdingInspect)
            net.SendToServer()
        end
    else
        -- Server-side logic
        local holdingInspect = ply.IsHoldingInspect or false
                
        if holdingInspect and not self.IsInspecting then
            self.IsInspecting = true
            self.HasPlayedInspectStart = true
            self:SendViewModelAnim("primary_alt1_inspect_start")
                        
            local vm = ply:GetViewModel()
            local dur = vm and vm:SequenceDuration(vm:LookupSequence("primary_alt1_inspect_start")) or 1.5
                        
            timer.Simple(dur, function()
                if IsValid(self) and self.IsInspecting then
                    self:SendViewModelAnim("inspect_idle")
                end
            end)
        elseif not holdingInspect and self.IsInspecting then
            self.IsInspecting = false
            self:SendViewModelAnim("inspect_end")
                        
            local vm = ply:GetViewModel()
            local dur = vm and vm:SequenceDuration(vm:LookupSequence("inspect_end")) or 1.5
                        
            timer.Simple(dur, function()
                if IsValid(self) and not self.IsInspecting then
                    self:SendViewModelAnim("idle")
                end
            end)
        end
    end
end


-- Also add this net receiver somewhere in your file (outside any functions):
if SERVER then
    net.Receive("SWEP_InspectKey", function(len, ply)
        local isHolding = net.ReadBool()
        ply.IsHoldingInspect = isHolding
    end)
end

function SWEP:ShootBullet(damage, num_bullets, aimcone)
    local owner = self:GetOwner()
    local bullet = {}
    bullet.Num = num_bullets
    bullet.Src = owner:GetShootPos()
    bullet.Dir = owner:GetAimVector()
    bullet.Spread = Vector(aimcone, aimcone, 0)
    bullet.Tracer = 1
    bullet.TracerName = "Tracer"
    bullet.Force = damage * 0.5
    bullet.Damage = damage
    bullet.AmmoType = self.Primary.Ammo

    owner:FireBullets(bullet)
    owner:MuzzleFlash()
    owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:SendViewModelAnim(anim)
    -- Block idle animations during reload
    if self.IsReloading and anim == "idle" then
        return -- Block idle animations during reload
    end
    
    local vm = self:GetOwner():GetViewModel()
    if not IsValid(vm) then return end
    local seq = vm:LookupSequence(anim)
    if seq and seq >= 0 then
        vm:SendViewModelMatchingSequence(seq)
        vm:SetPlaybackRate(1)
    end
end

function SWEP:CheckDryFireSound()
    if self:Clip1() <= 0 then
        if not self.PlayedNoAmmoSound then
            self:EmitSound(self.NoAmmoSound)
            self.PlayedNoAmmoSound = true
            self.NoAmmoCooldown = CurTime() + 1.5 -- prevent rapid repeat
        elseif CurTime() >= (self.NoAmmoCooldown or 0) then
            self.PlayedNoAmmoSound = false -- allow sound again after cooldown
        end
    elseif self:Clip1() > 0 then
        self.PlayedNoAmmoSound = false
    end
end

