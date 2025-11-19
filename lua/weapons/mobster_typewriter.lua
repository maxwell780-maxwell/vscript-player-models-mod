if SERVER then
    util.AddNetworkString("PlayerFiredSWEP")
end

SWEP.PrintName = "Typewriter"
SWEP.Author = "Code Copilot & maxwell"
SWEP.Instructions = "press primary fire to shoot duh hold H to inspect weapon press secondary fire to SHOVE"

SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"
SWEP.Category = "maxwells Vscript swep"

SWEP.ViewModel = "models/vip_mobster/weapons/v_typewriter_augmented.mdl"
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


function SWEP:DrawWorldModel()
    local ply = self:GetOwner()
    if IsValid(ply) then
        local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
        if bone then
            local pos, ang = ply:GetBonePosition(bone)

            -- Adjust these until it fits right
            ang:RotateAroundAxis(ang:Right(), 180)
            pos = pos + ang:Forward() * 4
            pos = pos + ang:Right() * 1
            pos = pos + ang:Up() * -1

            self:SetRenderOrigin(pos)
            self:SetRenderAngles(ang)
            self:DrawModel()
            return
        end
    end
    self:DrawModel()
end


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
	
    if self.IsReloading then return end

	if SERVER then
		net.Start("PlayerFiredSWEP")
		net.Send(self:GetOwner())
	end


    self:SetNextPrimaryFire(CurTime() + 0.1)

    local isCrit = math.random() < 0.1
    local isLow = self:Clip1() <= 10
    local sndTbl =
        isCrit and (isLow and self.Primary.Sounds_LowCrit or self.Primary.Sounds_Crit)
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

	if SERVER then
		net.Start("PlayerFiredSWEP")
		net.Send(self:GetOwner())
	end


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

    local owner = self:GetOwner()
    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end

    ----------------------------------------------------
    -- PLAY FIRST LAYER (mechanical rattle)
    ----------------------------------------------------
    self:EmitSound(self.Reloadnormal, 80, 100, 1, CHAN_ITEM)
	self:DefaultReload(ACT_VM_RELOAD)
    ----------------------------------------------------
    -- SETUP SLOW RELOAD ANIMATION
    ----------------------------------------------------
    local reloadSeq = vm:LookupSequence("reload")
    if reloadSeq < 0 then reloadSeq = 0 end

    vm:SendViewModelMatchingSequence(reloadSeq)
    vm:SetPlaybackRate(1)
    vm:SetCycle(0)

    local reloadTime = vm:SequenceDuration() / 1 -- its gonna be used once i figure out a way to add slow reload animations which will take forever but i dont give f*ck



    ----------------------------------------------------
    -- PLAY SECOND SOUND LAYER (the MP3 reload)
    ----------------------------------------------------
    timer.Simple(0.6, function()
        if IsValid(self) and self.IsReloading then
            self:EmitSound(self.ReloadSound, 80, 100, 1, CHAN_WEAPON)
        end
    end)



    ----------------------------------------------------
    -- WHEN THE ANIMATION FINISHES → GIVE AMMO
    ----------------------------------------------------
    timer.Simple(reloadTime + 0.1, function()
        if not IsValid(self) then return end
        if not IsValid(owner) then return end

        self.IsReloading = false

        -- CALCULATE AMMO TO RESTORE
        local needed = self.Primary.ClipSize - self:Clip1()
        local available = owner:GetAmmoCount(self.Primary.Ammo)
        local toLoad = math.min(needed, available)

        -- FILL THE CLIP
        self:SetClip1(self:Clip1() + toLoad)
        owner:RemoveAmmo(toLoad, self.Primary.Ammo)

        ------------------------------------------------
        -- RETURN TO IDLE ANIMATION
        ------------------------------------------------
        if IsValid(vm) then
            local idle = vm:LookupSequence("idle")
            vm:SendViewModelMatchingSequence(idle)
            vm:SetPlaybackRate(1)
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

    bullet.Num       = 3  -- always fire 3 bullets
    bullet.Src       = owner:GetShootPos()
    bullet.Dir       = owner:GetAimVector()

    -- small spread boost (adjust to taste)
    bullet.Spread    = Vector(aimcone * 5.5, aimcone * 5.5, 0)

    bullet.Tracer    = 1
    bullet.TracerName= "Tracer"
    bullet.Force     = damage * 0.5
    bullet.Damage    = damage
    bullet.AmmoType  = self.Primary.Ammo

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


-- if SERVER then
 --   local att = self:LookupAttachment("muzzle")
 --   if att and att > 0 then
      --  local attData = self:GetAttachment(att)
       -- if attData then
            -- Attach the particle normally
        --    local effect = ParticleEffectAttach("muzzle_bignasty", PATTACH_POINT_FOLLOW, self, att)

            -- If you want it to face forward, use a control point to rotate it
            -- CP 0 is usually the origin; adjust angles as needed
        --    if effect then
        --        effect:SetControlPointOrientation(0, attData.Pos, (attData.Ang + Angle(0, 79.224, 0)):Forward(), Vector(0,0,1))
      --      end
     --   end
  --  end
-- end

