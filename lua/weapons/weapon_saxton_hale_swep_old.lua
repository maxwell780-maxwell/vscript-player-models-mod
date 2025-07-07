SWEP.Base = "weapon_base"
SWEP.PrintName = "Saxton Hale's own fist's (old)"
SWEP.Author = "chatgpt & sourcegraph codychat & maxwell"
SWEP.Instructions = "primary attack and secondary attack does basic punches wait for 30 seconds and SAXTON PUNCH will be ready hold G to inspect and unhold G key and inpection ends currently inspection is kinda broken but will be reworked soon its the legacy version of the saxton hale swep no charge ability"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/c_models/c_saxton_arms.mdl"
SWEP.WorldModel = ""
SWEP.UseHands = false
SWEP.HoldType = "fist"
SWEP.ViewModelFlip = false
SWEP.Category = "maxwells Vscript swep"

SWEP.IconOverride = "vgui/icons/saxton_gammode_hard_teaser_icon"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.RegularDamage = 97
SWEP.CritDamage = 195
SWEP.DamageMultiplier = 3
SWEP.CritChance = 0.1
SWEP.AttackDelay = 0.75
SWEP.MegaPunchReady = false
SWEP.MegaPunchCooldown = 30 -- 30 seconds cooldown
SWEP.NextMegaPunchTime = 0
SWEP.OriginalSkin = 0
SWEP.IsMegaPunchActive = false
SWEP.AttackCooldown = 0.7 
SWEP.MegaPunchRange = 75 -- Standard range
SWEP.MegaPunchGroupRange = 150 -- Range for group hits
SWEP.MegaPunchRange = 75 -- Standard range
SWEP.MegaPunchGroupRange = 150 -- Range for group hits
SWEP.MegaPunchLoopSound = nil
SWEP.MegaPunchLoopSoundID = nil
SWEP.SaxtonMegaPunchLoopSound = "weapons/crit_power.wav"
SWEP.HellHaleMegaPunchLoopSound = "misc/halloween/merasmus_float.wav"


function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    
    -- Check if player model is Mecha Hale - if so, don't enable mega punch
    if IsValid(self.Owner) and self.Owner:GetModel() == "models/vsh/player/mecha_hale.mdl" then
        self.MegaPunchReady = false
        self.IsMegaPunchActive = false
    else
        self.NextMegaPunchTime = CurTime() + self.MegaPunchCooldown
        self.MegaPunchReady = false
        self.IsMegaPunchActive = false
    end
    
    self.MegaPunchReadySoundPlayed = false -- Initialize the flag
    self.NextAttackTime = 0
    
    -- Precache all sounds
    self:PrecacheSounds()
end

function SWEP:Deploy()
    -- Check the player's model and set the view model accordingly
    local playerModel = self.Owner:GetModel()

    if playerModel == "models/vsh/player/winter/saxton_hale.mdl" then
        self.ViewModel = "models/vsh/weapons/c_models/winter/c_saxton_arms.mdl"
    elseif playerModel == "models/vsh/player/hell_hale.mdl" then
        self.ViewModel = "models/vsh/weapons/c_models/c_hell_hale_arms.mdl"
    elseif playerModel == "models/vsh/player/saxton_hale.mdl" then
        self.ViewModel = "models/vsh/weapons/c_models/c_saxton_hale_arms.mdl"
    elseif playerModel == "models/vsh/player/mecha_hale.mdl" then
        self.ViewModel = "models/vsh/weapons/c_models/c_mecha_hale_arms.mdl"
    else
        self.ViewModel = "models/weapons/c_models/c_saxton_arms.mdl"
    end

    -- Set the correct view model
    local vm = self.Owner:GetViewModel()
    if IsValid(vm) then
        vm:SetModel(self.ViewModel)
        self:UpdateViewModelBodygroups()
    end

    -- Play the deploy animation
    self:SendViewModelAnim("bg_draw")
    
    return true
end

function SWEP:Think()
    local vm = self.Owner:GetViewModel()
    if not IsValid(vm) then return end

    self:UpdateViewModelBodygroups()

    if CLIENT and self.Owner == LocalPlayer() then
        local isHoldingG = input.IsKeyDown(KEY_G)

        if isHoldingG and not self.GKeyHeld then
            self.GKeyHeld = true
            if not self.Inspecting then
                self:StartInspection()
            end
        elseif not isHoldingG and self.GKeyHeld then
            self.GKeyHeld = false
            if self.Inspecting then
                self:EndInspection()
            end
        end
    end

    if self.Inspecting and self.InspectIdlePlaying and vm:GetCycle() >= 1 then
        self:SendViewModelAnim(self.InspectIdleAnim)
    end

    if not self.Inspecting and vm:GetCycle() >= 1 and not self.Attacking then
        self:Idle()
    end

    -- Skip mega punch for Mecha Hale
    local playerModel = self.Owner:GetModel()
    if playerModel == "models/vsh/player/mecha_hale.mdl" or playerModel == "models/saxton_hale_3.mdl" then
        return
    end
    
    -- Mega Punch cooldown logic
    if not self.MegaPunchReady and CurTime() >= self.NextMegaPunchTime then
        self.MegaPunchReady = true
        self:MegaPunchReadyEffects()
    end
end

function SWEP:MegaPunchReadyEffects()
    -- Skip for Mecha Hale
    local playerModel = self.Owner:GetModel()
    if playerModel == "models/vsh/player/mecha_hale.mdl" or playerModel == "models/saxton_hale_3.mdl" then
        return
    end
    
    
    -- Store original skin
    self.OriginalSkin = self.Owner:GetSkin()
    
    -- Set player skin to 2 as indicator that mega punch is ready
    self.Owner:SetSkin(2)
    
    -- Play ready animation
    self:SendViewModelAnim("vsh_megapunch_ready")
    
    -- After animation ends, return to idle
    timer.Simple(self.Owner:GetViewModel():SequenceDuration(), function()
        if IsValid(self) then
            self:Idle()
        end
    end)
    
    -- Start the looping sound based on player model (only if not already playing)
    if not self.MegaPunchLoopSoundID then
        local playerModel = self.Owner:GetModel()
        if playerModel == "models/player/saxton_hale.mdl" or 
           playerModel == "models/vsh/player/winter/saxton_hale.mdl" or 
           playerModel == "models/vsh/player/saxton_hale.mdl" or 
           playerModel == "models/vsh/player/santa_hale.mdl" then
            -- Regular Saxton, Winter Saxton, and Santa Saxton use the crit power sound
            self.MegaPunchLoopSound = self.SaxtonMegaPunchLoopSound
        elseif playerModel == "models/vsh/player/hell_hale.mdl" then
            -- Hell Hale uses the Merasmus float sound
            self.MegaPunchLoopSound = self.HellHaleMegaPunchLoopSound
        end
        
        -- Play the looping sound
        if self.MegaPunchLoopSound then
            self.MegaPunchLoopSoundID = self.Owner:StartLoopingSound(self.MegaPunchLoopSound)
        end
    end
end

-- Modify PrimaryAttack to handle mega punch and add cooldown
function SWEP:PrimaryAttack()
    -- Check if we're on cooldown
    if CurTime() < self.NextAttackTime then
        return
    end
    
    -- Set next attack time
    self.NextAttackTime = CurTime() + self.AttackCooldown
    
    -- Skip mega punch for Mecha Hale
    if self.Owner:GetModel() == "models/vsh/player/mecha_hale.mdl" then
        -- Normal attack
        self:SetNextPrimaryFire(CurTime() + self.AttackDelay)
        self.Attacking = true
        self:Swing(math.random() < self.CritChance)
        return
    end
    
    -- If mega punch is ready, use it
    if self.MegaPunchReady then
        self:MegaPunch()
        return
    end
    
    -- Normal attack if mega punch not ready
    self:SetNextPrimaryFire(CurTime() + self.AttackDelay)
    self.Attacking = true
    self:Swing(math.random() < self.CritChance)
end

-- Modify SecondaryAttack to handle mega punch and add cooldown
function SWEP:SecondaryAttack()
    -- Check if we're on cooldown
    if CurTime() < self.NextAttackTime then
        return
    end
    
    -- Set next attack time
    self.NextAttackTime = CurTime() + self.AttackCooldown
    
    -- Skip mega punch for Mecha Hale
    if self.Owner:GetModel() == "models/vsh/player/mecha_hale.mdl" then
        -- Normal attack
        self:SetNextSecondaryFire(CurTime() + self.AttackDelay)
        self.Attacking = true
        self.Owner:SetAnimation(PLAYER_ATTACK1)
        self:Swing(math.random() < self.CritChance, true)
        return
    end
    
    -- If mega punch is ready, use it
    if self.MegaPunchReady then
        self:MegaPunch()
        return
    end
    
    -- Normal attack if mega punch not ready
    self:SetNextSecondaryFire(CurTime() + self.AttackDelay)
    self.Attacking = true
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self:Swing(math.random() < self.CritChance, true)
end

-- Add the mega punch function
function SWEP:FindTargetsInCone(position, direction, range, maxTargets)
    local targets = {}
    local entCount = 0
    
    -- Get all entities in range
    for _, ent in ipairs(ents.FindInSphere(position, range)) do
        if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC() or ent.Type == "nextbot") and ent != self.Owner then
            -- Calculate direction to entity
            local entPos = ent:GetPos() + Vector(0, 0, 30) -- Aim for center mass
            local entDir = (entPos - position):GetNormalized()
            
            -- Check if entity is in front of player (dot product > 0)
            local dot = direction:Dot(entDir)
            if dot > 0.5 then -- Approximately 60 degree cone
                table.insert(targets, ent)
                entCount = entCount + 1
                
                if entCount >= maxTargets then
                    break
                end
            end
        end
    end
    
    return targets
end

-- Add the mega punch function
function SWEP:MegaPunch()
    self.IsMegaPunchActive = true
    self.Attacking = true
    
    -- Play the crit swing animation - forcing it to play
    local vm = self.Owner:GetViewModel()
    if IsValid(vm) then
        local seq = vm:LookupSequence("bg_swing_crit")
        if seq >= 0 then
            vm:SendViewModelMatchingSequence(seq)
            vm:SetPlaybackRate(1)
        end
    end
    
    -- Play the swing sound
    self.Owner:EmitSound("weapons/fist_swing_crit.wav")
    
    -- Set player animation
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    
    -- Get player position and view direction
    local playerPos = self.Owner:GetShootPos()
    local playerDir = self.Owner:GetAimVector()
    
    -- Trace for hit
    self.Owner:LagCompensation(true)
    local tr = self.Owner:GetEyeTrace()
    local hit = false
    local hitTargets = {}
    
    -- First check direct hit
    if tr.Hit and tr.HitPos and tr.HitPos:Distance(playerPos) <= self.MegaPunchRange then
        local directTarget = tr.Entity
        if IsValid(directTarget) and (directTarget:IsPlayer() or directTarget:IsNPC() or directTarget.Type == "nextbot") then
            hit = true
            table.insert(hitTargets, directTarget)
        end
    end
    
    -- Then check for group hits if we have less than 3 targets
    if #hitTargets < 3 then
        local groupTargets = self:FindTargetsInCone(playerPos, playerDir, self.MegaPunchGroupRange, 3 - #hitTargets)
        for _, target in ipairs(groupTargets) do
            if not table.HasValue(hitTargets, target) then
                table.insert(hitTargets, target)
                hit = true
            end
        end
    end
    
    if hit then
        -- Create shockwave effect
        local effectData = EffectData()
        effectData:SetOrigin(playerPos + playerDir * 50)
        effectData:SetNormal(playerDir)
        effectData:SetScale(1)
        util.Effect("vsh_megapunch_shockwave", effectData)
        
        -- Play the mega punch hit sound
        self.Owner:EmitSound("mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav", 100)
        
        -- Apply damage to all hit targets
        for _, target in ipairs(hitTargets) do
            if IsValid(target) and target.TakeDamageInfo then
                local dmginfo = DamageInfo()
                dmginfo:SetDamage(326) -- Mega punch damage
                dmginfo:SetAttacker(self.Owner)
                dmginfo:SetInflictor(self)
                dmginfo:SetDamageForce(self.Owner:GetForward() * 5000) -- Extra knockback
                dmginfo:SetDamagePosition(target:GetPos())
                target:TakeDamageInfo(dmginfo)
            end
        end
        
        -- Stop the looping sound if we hit a valid target
        if self.MegaPunchLoopSoundID then
            self.Owner:StopLoopingSound(self.MegaPunchLoopSoundID)
            self.MegaPunchLoopSoundID = nil
        end
        
        -- Reset mega punch state and start cooldown only if we hit a valid target
        self.MegaPunchReady = false
        self.NextMegaPunchTime = CurTime() + self.MegaPunchCooldown
        
        -- Reset player skin after hit
        timer.Simple(0.5, function()
            if IsValid(self) and IsValid(self.Owner) then
                self.Owner:SetSkin(0)
            end
        end)
    end
    
    self.Owner:LagCompensation(false)
    
    -- Reset attack state after animation
    timer.Simple(vm:SequenceDuration(), function()
        if IsValid(self) then
            self.Attacking = false
            
            -- Only reset IsMegaPunchActive if we hit something
            if hit then
                self.IsMegaPunchActive = false
            end
        end
    end)
end

function SWEP:Swing(isCrit, isSecondary)
    local vm = self.Owner:GetViewModel()
    if not IsValid(vm) then return end

    local anim = isCrit and "bg_swing_crit" or (isSecondary and "bg_swing_right" or "bg_swing_left")
    local sound = isCrit and "weapons/fist_swing_crit.wav" or (math.random(1, 2) == 1 and "weapons/bat_draw_swoosh1.wav" or "weapons/bat_draw_swoosh2.wav")

    self.Owner:SetAnimation(PLAYER_ATTACK1)
    
    -- Force the animation to play
    local seq = vm:LookupSequence(anim)
    if seq >= 0 then
        vm:SendViewModelMatchingSequence(seq)
        vm:SetPlaybackRate(1)
    end

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

function SWEP:IsSoundPlaying(soundName)
    if not IsValid(self.Owner) then return false end
    
    -- This is a basic implementation. In a full game, i might want to use a more robust system
    -- to track which sounds are currently playing.
    return false
end

-- Function to play a sound only if no other sounds from the same category are playing
function SWEP:PlayUniqueSound(soundName, soundLevel)
    if not self:IsSoundPlaying(soundName) then
        self.Owner:EmitSound(soundName, soundLevel or 75)
        return true
    end
    return false
end

function SWEP:StartInspection()
    local playerModel = self.Owner:GetModel()
    local isMecha = playerModel == "models/vsh/player/mecha_hale.mdl"
    local isSaxton = playerModel == "models/vsh/player/saxton_hale.mdl"
    local isRare = math.random() < 0.1

    if (isMecha or isSaxton) and isRare then
        self.InspectStartAnim = "vsh_hide_arms"
        self.InspectIdleAnim = "vsh_hidden_slot_1"
        self.InspectEndAnim = isMecha and (math.random(1, 2) == 1 and "vsh_show_arms" or "vsh_show_arms_2") or "vsh_show_arms"
    else
        self.InspectStartAnim = "alt1_inspect_start"
        self.InspectIdleAnim = "alt1_inspect_idle"
        self.InspectEndAnim = "alt1_inspect_end"
    end

    self:SendViewModelAnim(self.InspectStartAnim)
    self.Inspecting = true
    self.InspectIdlePlaying = false

    timer.Simple(self.Owner:GetViewModel():SequenceDuration(), function()
        if IsValid(self) and self.Inspecting then
            self.InspectIdlePlaying = true
            self:SendViewModelAnim(self.InspectIdleAnim)
        end
    end)
end

function SWEP:EndInspection()
    self:SendViewModelAnim(self.InspectEndAnim)
    self.Inspecting = false
    self.InspectIdlePlaying = false
end

function SWEP:Idle()
    self:SendViewModelAnim("bg_idle")
end

function SWEP:SendViewModelAnim(anim)
    local vm = self.Owner:GetViewModel()
    if IsValid(vm) then
        local seq = vm:LookupSequence(anim)
        if seq >= 0 then
            vm:SendViewModelMatchingSequence(seq)
            vm:SetPlaybackRate(1)
        end
    end
end

function SWEP:PrecacheSounds()
    -- Precache all the sound files to avoid stuttering when they're first played
    if self.SaxtonReadySounds then
        for _, sound in ipairs(self.SaxtonReadySounds) do
            util.PrecacheSound(sound)
        end
    end
    
    if self.HellHaleReadySounds then
        for _, sound in ipairs(self.HellHaleReadySounds) do
            util.PrecacheSound(sound)
        end
    end
    
    if self.SantaHaleReadySounds then
        for _, sound in ipairs(self.SantaHaleReadySounds) do
            util.PrecacheSound(sound)
        end
    end
    
    if self.SaxtonPunchHitSounds then
        for _, sound in ipairs(self.SaxtonPunchHitSounds) do
            util.PrecacheSound(sound)
        end
    end
    
    if self.HellHalePunchHitSounds then
        for _, sound in ipairs(self.HellHalePunchHitSounds) do
            util.PrecacheSound(sound)
        end
    end
    
    -- Precache other sounds
    util.PrecacheSound("weapons/fist_swing_crit.wav")
    util.PrecacheSound("mvm/giant_soldier/giant_soldier_rocket_shoot_crit.wav")
    util.PrecacheSound("weapons/bat_draw_swoosh1.wav")
    util.PrecacheSound("weapons/bat_draw_swoosh2.wav")
    util.PrecacheSound("weapons/cbar_hitbod1.wav")
    util.PrecacheSound("weapons/cbar_hitbod2.wav")
    util.PrecacheSound("weapons/cbar_hitbod3.wav")
    util.PrecacheSound("weapons/fist_hit_world1.wav")
    util.PrecacheSound("weapons/fist_hit_world2.wav")
    
    -- Precache looping sounds
    util.PrecacheSound(self.SaxtonMegaPunchLoopSound)
    util.PrecacheSound(self.HellHaleMegaPunchLoopSound)
end

function SWEP:UpdateViewModelBodygroups()
    local vm = self.Owner:GetViewModel()
    if not IsValid(vm) then return end
    
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
end

function SWEP:Holster()
    -- Stop looping sound if it's playing
    if self.MegaPunchLoopSoundID then
        self.Owner:StopLoopingSound(self.MegaPunchLoopSoundID)
        self.MegaPunchLoopSoundID = nil
    end
    
    return true
end

function SWEP:OnRemove()
    -- Stop looping sound if it's playing
    if IsValid(self.Owner) and self.MegaPunchLoopSoundID then
        self.Owner:StopLoopingSound(self.MegaPunchLoopSoundID)
        self.MegaPunchLoopSoundID = nil
    end
end

function SWEP:GetRandomSound(soundTable)
    if not soundTable or #soundTable == 0 then 
        return "" 
    end
    return soundTable[math.random(1, #soundTable)]
end

function SWEP:PlaySingleSound(soundFile, soundLevel)
    if not IsValid(self.Owner) then return end
    
    -- Stop any currently playing ready sound
    if self.CurrentReadySound then
        self.Owner:StopSound(self.CurrentReadySound)
        self.CurrentReadySound = nil
    end
    
    -- Set the flag to indicate a sound is playing
    self.ReadySoundPlaying = true
    
    -- Play the new sound
    self.Owner:EmitSound(soundFile, soundLevel or 75)
    self.CurrentReadySound = soundFile
    
    -- Calculate sound duration (approximate)
    local soundDuration = SoundDuration(soundFile) or 2 -- Default to 2 seconds if duration can't be determined
    
    -- Reset the flag after the sound finishes
    timer.Simple(soundDuration, function()
        if IsValid(self) then
            self.ReadySoundPlaying = false
        end
    end)
end

if CLIENT then
    SWEP.GKeyHeld = false
end
