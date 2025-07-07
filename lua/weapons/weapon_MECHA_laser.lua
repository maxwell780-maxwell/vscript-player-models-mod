SWEP.PrintName = "Mecha Laser mecha saxton hale swep"
SWEP.Author = "codychat & maxwell"
SWEP.Instructions = "press reload to fire the laser press primary or secondary to do basic punches...listen its just the saxton hale demo swep but better and for mecha hale ALSO the laser appears from the eyes of the player model SO PLEASE aim the laser correctly im sorry its not good please forgive me :( i really dont know how the laser ACTS in the vsh facility gamemode NOTE: its pretty broken only the laser effects are broken because they act like bullets but lets just pretend its a laser for me ok ;)"
SWEP.Category = "maxwells saxton hale swep"
SWEP.Spawnable = false -- false cause i dont want any saxton nor player using it its only for mecha hale
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.HoldType = "fist"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.ViewModel = "models/vsh/weapons/c_models/c_mecha_hale_arms.mdl"
SWEP.WorldModel = ""

SWEP.LaserActive = false
SWEP.LaserStartTime = 0
SWEP.LaserDuration = 40
SWEP.NextParticleTime = 0
SWEP.ParticleDelay = 0.05 -- Faster particle creation
SWEP.LastParticle = nil
SWEP.RegularDamage = 65
SWEP.CritDamage = 195
SWEP.DamageMultiplier = 1
SWEP.CritChance = 0.12
SWEP.AttackDelay = 0.8
SWEP.Attacking = false
SWEP.IsCharging = false

function SWEP:Initialize()
    self:SetHoldType("fist")
    self.ParticleList = {}
end

function SWEP:Reload()
    if self.LaserActive or self.IsCharging then return end
    
    self.IsCharging = true
    
    local vm = self.Owner:GetViewModel()
    vm:SetPlaybackRate(1)
    vm:SendViewModelMatchingSequence(vm:LookupSequence("vsh_laser_prepare"))
    
    -- Start the charge sound
    local chargeSound = CreateSound(self.Owner, "vsh_mecha/charge.mp3")
    chargeSound:SetSoundLevel(100)
    chargeSound:Play()
    
    -- Wait for animation to finish
    timer.Simple(vm:SequenceDuration(), function()
        if IsValid(self) and IsValid(self.Owner) then
            self.LaserActive = true
            self.LaserStartTime = CurTime()
            self:StartLaser()
        end
    end)
    
    -- Let the sound finish naturally
    timer.Simple(9.9, function()
        if chargeSound then
            chargeSound:Stop()
        end
    end)
end

function SWEP:StartLaser()
    local vm = self.Owner:GetViewModel()
    local laserAnims = {"vsh_laser_1", "vsh_laser_2", "vsh_laser_3"}
    local randomAnim = laserAnims[math.random(#laserAnims)]
    vm:SendViewModelMatchingSequence(vm:LookupSequence(randomAnim))
    
    -- Play one random laser sound at balanced volume
    local laserSounds = {
        "mvm/vsh_mecha/mecha_hale_new/laser_fire_01.mp3",
        "mvm/vsh_mecha/mecha_hale_new/laser_fire_02.mp3",
        "mvm/vsh_mecha/mecha_hale_new/laser_fire_03.mp3",
        "mvm/vsh_mecha/mecha_hale_new/laser_fire_04.mp3"
    }
    self.Owner:EmitSound(laserSounds[math.random(#laserSounds)], 75, 100, 0.6, CHAN_WEAPON)
end

function SWEP:Think()
    if self.LaserActive then
        if CurTime() - self.LaserStartTime >= self.LaserDuration then
            self.LaserActive = false
            local vm = self.Owner:GetViewModel()
            vm:SendViewModelMatchingSequence(vm:LookupSequence("f_idle"))
            self.Owner:StopParticles()
            if SERVER then
                self.Owner:DropWeapon(self)
                self:Remove()
            end
            return
        end

        if SERVER and CurTime() >= self.NextParticleTime then
            local eyePos = self.Owner:EyePos()
            local eyeAngles = self.Owner:EyeAngles()
            
            -- Create limited angles including crouch
            local limitedPitch = self.Owner:Crouching() and math.Clamp(eyeAngles.pitch, -40, 36) or math.Clamp(eyeAngles.pitch, -65, 65)
            local limitedAngles = Angle(limitedPitch, eyeAngles.yaw, 0)
            
            local forward = limitedAngles:Forward()
            local right = limitedAngles:Right()
            local up = limitedAngles:Up()
            
            -- Adjust position based on crouching
            if self.Owner:Crouching() then
                eyePos = eyePos + forward * 14 + right * 0 + up * 26
            else
                eyePos = eyePos + forward * 6 + right * 0 + up * 13
            end

            local endPos = eyePos + limitedAngles:Forward() * 9999

            local trace = util.TraceLine({
                start = eyePos,
                endpos = endPos,
                filter = self.Owner
            })

            self.Owner:StopParticles()
            
            util.ParticleTracerEx(
                "vsh_laser_tp",
                eyePos,
                trace.HitPos,
                true,
                self.Owner:EntIndex(),
                -1
            )

            if trace.Entity and IsValid(trace.Entity) then
                trace.Entity:TakeDamage(10, self.Owner, self)
            end

            self.NextParticleTime = CurTime() + 0.08
        end
    end
end

function SWEP:Deploy()
    -- Check the player's model and set the view model accordingly
    local playerModel = self.Owner:GetModel()

    if playerModel == "models/vsh/player/winter/saxton_hale.mdl" then
        self.ViewModel = "models/vsh/weapons/c_models/winter/c_saxton_arms.mdl"
    elseif playerModel == "models/vsh/player/hell_hale.mdl" then
        self.ViewModel = "models/vsh/weapons/c_models/c_hell_hale_arms.mdl"
    elseif playerModel == "models/vsh/player/mecha_hale.mdl" then
        self.ViewModel = "models/vsh/weapons/c_models/c_mecha_hale_arms.mdl"
    else
        self.ViewModel = "models/weapons/c_models/c_saxton_arms.mdl"
    end

    -- Set the correct view model
    local vm = self.Owner:GetViewModel()
    if IsValid(vm) then
        vm:SetModel(self.ViewModel)
        -- Get the player's skin
        local skin = self.Owner:GetSkin()

        -- Set the bodygroups based on the player's skin
        if skin == 0 or skin == 1 then
            -- Set both arms to 0 for skins 0 or 1
            vm:SetBodygroup(1, 0) -- ltarm to 0
            vm:SetBodygroup(0, 0) -- rtarm to 0
        elseif skin == 2 then
            -- Set ltarm to 1 and rtarm to 0 for skin 2
            vm:SetBodygroup(1, 1) -- ltarm to 1
            vm:SetBodygroup(0, 0) -- rtarm to 0
        elseif skin == 3 then
            -- Set ltarm to 0 and rtarm to 1 for skin 3
            vm:SetBodygroup(1, 0) -- ltarm to 0
            vm:SetBodygroup(0, 1) -- rtarm to 1
        elseif skin == 4 then
            -- Set both arms to 1 for skin 4
            vm:SetBodygroup(1, 1) -- ltarm to 1
            vm:SetBodygroup(0, 1) -- rtarm to 1
        end

        -- Play the deploy animation using the correct method
        vm:SendViewModelMatchingSequence(vm:LookupSequence("vsh_megapunch_ready"))
    end

    return true
end

function SWEP:Holster()
    if IsValid(self.Owner) then
        self.Owner:StopParticles()
        self.Owner:StopSound("vsh_mecha/charge.mp3")
    end
    self.LaserActive = false
    self.IsCharging = false
    return true
end

function SWEP:OnRemove()
    if IsValid(self.Owner) then
        self.Owner:StopParticles()
        self.Owner:StopSound("vsh_mecha/charge.mp3")
    end
    self.LaserActive = false
    self.IsCharging = false
end

function SWEP:Swing(isCrit, isSecondary)
    local vm = self.Owner:GetViewModel()
    if not IsValid(vm) then return end

    local anim = isCrit and "bg_swing_crit" or (isSecondary and "bg_swing_right" or "bg_swing_left")
    local sound = isCrit and "weapons/fist_swing_crit.wav" or (math.random(1, 2) == 1 and "weapons/bat_draw_swoosh1.wav" or "weapons/bat_draw_swoosh2.wav")

    self.Owner:SetAnimation(PLAYER_ATTACK1)
    
    -- Using the correct animation method
    vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))

    if sound and sound ~= "" then
        self.Owner:EmitSound(sound)
    end

    self.Owner:LagCompensation(true)
    local tr = self.Owner:GetEyeTrace()
    if tr.Hit and tr.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
        local dmg = (isCrit and self.CritDamage or self.RegularDamage) * self.DamageMultiplier
        local hitSound = (IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC())) 
            and ("weapons/cbar_hitbod" .. math.random(1, 3) .. ".wav") 
            or ("weapons/fist_hit_world" .. math.random(1, 2) .. ".wav")
        
        if hitSound and hitSound ~= "" then
            self.Owner:EmitSound(hitSound)
        end
        
        if IsValid(tr.Entity) and tr.Entity.TakeDamageInfo then
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(dmg)
            dmginfo:SetAttacker(self.Owner)
            dmginfo:SetInflictor(self)
            dmginfo:SetDamageForce(self.Owner:GetForward() * 1000)
            dmginfo:SetDamagePosition(tr.HitPos)
            tr.Entity:TakeDamageInfo(dmginfo)
        end
    end
    self.Owner:LagCompensation(false)

    -- Reset attack state to return to idle
    timer.Simple(vm:SequenceDuration(), function()
        if IsValid(self) then
            self.Attacking = false
        end
    end)
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.AttackDelay)
    self.Attacking = true
    self:Swing(math.random() < self.CritChance)
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + self.AttackDelay)
    self.Attacking = true
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self:Swing(math.random() < self.CritChance, true)
end
