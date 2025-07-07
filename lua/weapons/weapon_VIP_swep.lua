SWEP.PrintName = "The VIP's Cane [BETA]"
SWEP.Author = "codychat & maxwell"
SWEP.Instructions = "its just a cane for the VIP anyways primary attack does a basic melee attack while secondary attack will switch view model with a coin veiw model press primary attack if view model is the coin view model to give any teammate and yourself any buff depending on your coin also hold reload will begin inspecting the weapon cause why not its not a swep without it let go if the reload key to end inspection WARNING the The VIP's Cane kinda buggy so use at your own risk"
SWEP.Category = "maxwells Vscript swep"

SWEP.IconOverride = "vgui/icons/VIP weapon icon"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HoldType = "melee"
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/vip/weapons/c_models/c_julius_arms.mdl"
SWEP.WorldModel = "models/vip/weapons/c_models/c_cane/c_cane.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true

SWEP.IsInspecting = false
SWEP.UsingAltModel = false

local ActIndex = {
    ["draw"] = "b_draw",
    ["idle"] = "b_idle",
    ["swing_a"] = "b_swing_a",
    ["swing_b"] = "b_swing_b",
    ["swing_c"] = "b_swing_c",
    ["inspect_start"] = "melee_inspect_start",
    ["inspect_idle"] = "melee_inspect_idle",
    ["inspect_end"] = "melee_inspect_end",
    ["coin_draw"] = "coin_draw",
    ["coin_idle"] = "coin_idle",
    ["coin_throw"] = "coin_throw"  -- Added this missing animation
}

sound.Add({
    name = "Weapon_Cane.MiniCritBoost",
    channel = CHAN_VOICE,
    volume = 1.0,
    level = 75,
    pitch = 100,
    sound = {"mvm/julius_v7/julius_miniboost01.mp3", "mvm/julius_v7/julius_miniboost02.mp3", "mvm/julius_v7/julius_miniboost04.mp3", "mvm/julius_v7/julius_miniboost05.mp3", "mvm/julius_v7/julius_miniboost06.mp3"}
})

sound.Add({
    name = "Weapon_Cane.ResistanceBoost",
    channel = CHAN_VOICE,
    volume = 1.0,
    level = 75,
    pitch = 100,
    sound = {"mvm/julius_v7/julius_resistanceboost01.mp3", "mvm/julius_v7/julius_resistanceboost02.mp3", "mvm/julius_v7/julius_resistanceboost04.mp3", "mvm/julius_v7/julius_resistanceboost05.mp3", "mvm/julius_v7/julius_resistanceboost06.mp3", "mvm/julius_v7/julius_resistanceboost03.mp3"}
})

sound.Add({
    name = "Weapon_Cane.SpeedBoost",
    channel = CHAN_VOICE,
    volume = 1.0,
    level = 75,
    pitch = 100,
    sound = {"mvm/julius_v7/julius_speedboost01.mp3", "mvm/julius_v7/julius_speedboost02.mp3", "mvm/julius_v7/julius_speedboost06.mp3", "mvm/julius_v7/julius_speedboost04.mp3", "mvm/julius_v7/julius_speedboost05.mp3", "mvm/julius_v7/julius_speedboost03.mp3"}
})

sound.Add({
    name = "Weapon_Cane.HitWorld",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 75,
    pitch = {95, 105},
    sound = {"weapons/cbar_hit1.wav", "weapons/cbar_hit2.wav"}
})

sound.Add({
    name = "Weapon_Cane.HitBody",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 75,
    pitch = {95, 105},
    sound = {"weapons/cbar_hitbod1.wav", "weapons/cbar_hitbod2.wav", "weapons/cbar_hitbod3.wav"}
})

sound.Add({
    name = "Weapon_Cane.Miss",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 75,
    pitch = {95, 105},
    sound = "weapons/cbar_miss1.wav"
})

sound.Add({
    name = "Weapon_Cane.MissCrit",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 75,
    pitch = {95, 105},
    sound = "weapons/cbar_miss1_crit.wav"
})

sound.Add({
    name = "Weapon_Cane.BoostReceived",
    channel = CHAN_ITEM,
    volume = 1.0,
    level = 75,
    pitch = 100,
    sound = "vip_v7/coin_boost_received.mp3"
})

sound.Add({
    name = "Weapon_Cane.ThrowMinicrits",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 75,
    pitch = 100,
    sound = "vip_v7/coin_throw_minicrits.mp3"
})

sound.Add({
    name = "Weapon_Cane.ThrowResistance",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 75,
    pitch = 100,
    sound = "vip_v7/coin_throw_resistance.mp3"
})

sound.Add({
    name = "Weapon_Cane.ThrowSpeed",
    channel = CHAN_WEAPON,
    volume = 1.0,
    level = 75,
    pitch = 100,
    sound = "vip_v7/coin_throw_speed.mp3"
})

sound.Add({
    name = "Weapon_Cane.CoinRegen",
    channel = CHAN_ITEM,
    volume = 1.0,
    level = 75,
    pitch = 100,
    sound = "vip_v7/coin_regen.mp3"
})

sound.Add({
    name = "Weapon_Cane.Denied",
    channel = CHAN_ITEM,
    volume = 1.0,
    level = 75,
    pitch = 100,
    sound = "weapons/medigun_no_target.wav"
})

SWEP.NextCoinThrow = 0
SWEP.CoinCooldown = 20
SWEP.CurrentBoostType = 0


function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self.IdleDelay = 0
    
    if CLIENT then
        local cane = ClientsideModel("models/vip/weapons/c_models/c_cane/c_cane.mdl", RENDERGROUP_VIEWMODEL)
        cane:SetNoDraw(true)
        cane:SetParent(self.Owner:GetViewModel())
        cane:AddEffects(EF_BONEMERGE)
        cane:AddEffects(EF_BONEMERGE_FASTCULL)
        self.ViewModelCane = cane
    end
end

function SWEP:Deploy()
    local vm = self.Owner:GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence(self.UsingAltModel and ActIndex["coin_draw"] or ActIndex["draw"]))
    self.IdleDelay = CurTime() + vm:SequenceDuration()
    return true
end

function SWEP:Think()
    if self.IdleDelay and self.IdleDelay < CurTime() and not self.IsInspecting then
        local vm = self.Owner:GetViewModel()
        vm:SendViewModelMatchingSequence(self:GetSequenceFromAct(self.UsingAltModel and ActIndex["coin_idle"] or ActIndex["idle"]))
        self.IdleDelay = CurTime() + vm:SequenceDuration()
    end
    
    self:UpdateSkins()
    
    if self.Owner:KeyDown(IN_RELOAD) and not self.IsInspecting and not self.UsingAltModel then -- inspection code
        self.IsInspecting = true
        local vm = self.Owner:GetViewModel()
        vm:SendViewModelMatchingSequence(vm:LookupSequence(ActIndex["inspect_start"]))
        timer.Simple(vm:SequenceDuration(), function()
            if IsValid(self) and self.IsInspecting then
                vm:SendViewModelMatchingSequence(vm:LookupSequence(ActIndex["inspect_idle"]))
            end
        end)
    elseif not self.Owner:KeyDown(IN_RELOAD) and self.IsInspecting then -- if player is not holding the reload key then end the inspection
        self.IsInspecting = false
        local vm = self.Owner:GetViewModel()
        vm:SendViewModelMatchingSequence(vm:LookupSequence(ActIndex["inspect_end"]))
        self.IdleDelay = CurTime() + vm:SequenceDuration()
    end
end

function SWEP:SecondaryAttack()
    if self.NextModelSwitch and self.NextModelSwitch > CurTime() then return end
    
    if not self.UsingAltModel and CurTime() < self.NextCoinThrow then
        self:EmitSound("Weapon_Cane.Denied")
        return
    end
    
    self.UsingAltModel = not self.UsingAltModel
    self.NextModelSwitch = CurTime() + 0.5
    
    if self.UsingAltModel then
        self.CurrentBoostType = math.random(0, 2)
        if SERVER then
            self:CallOnClient("UpdateViewModel", tostring(self.CurrentBoostType))
        end
    else
        if SERVER then
            self:CallOnClient("UpdateViewModel", "-1")
        end
    end
end

function SWEP:UpdateSkins()
    local playerSkin = self.Owner:GetSkin()
    local weaponSkin = 0
    
    if playerSkin == 0 then
        weaponSkin = 0
    elseif playerSkin == 4 then
        weaponSkin = 0
    elseif playerSkin == 5 then
        weaponSkin = 1
    elseif playerSkin == 1 then
        weaponSkin = 1
    end
    
    -- Set world model skin
    self:SetSkin(weaponSkin)
    
    -- Set viewmodel cane skin
    if CLIENT and IsValid(self.ViewModelCane) then
        self.ViewModelCane:SetSkin(weaponSkin)
    end
end

function SWEP:UpdateViewModel(state)
    local boostType = tonumber(state)
    self.UsingAltModel = (boostType >= 0)
    self.CurrentBoostType = boostType
    
    if CLIENT then
        local vm = self.Owner:GetViewModel()
        if self.UsingAltModel then
            vm:SetModel("models/vip/weapons/v_coin.mdl")
            vm:SetBodygroup(0, self.CurrentBoostType)
            vm:SendViewModelMatchingSequence(self:GetSequenceFromAct(ActIndex["coin_draw"]))
        else
            vm:SetModel("models/vip/weapons/c_models/c_julius_arms.mdl")
            vm:SendViewModelMatchingSequence(self:GetSequenceFromAct(ActIndex["draw"]))
        end
        self.IdleDelay = CurTime() + vm:SequenceDuration()
    end
end

function SWEP:ApplyBoostEffects(target) -- these are all of the bost stuff you can get with the VIP swep
    if !IsValid(target) then return end
    
    target:EmitSound("Weapon_Cane.BoostReceived")
    
    if self.CurrentBoostType == 0 then -- Mini-crits
        self.Owner:EmitSound("Weapon_Cane.MiniCritBoost")
        target.HasMinicrits = true
        timer.Simple(20, function()
            if IsValid(target) then
                target.HasMinicrits = false
            end
        end)
    elseif self.CurrentBoostType == 1 then -- Resistance
        self.Owner:EmitSound("Weapon_Cane.ResistanceBoost")
        
        -- Apply resistance buff to nearby players
        local nearbyPlayers = ents.FindInSphere(self.Owner:GetPos(), 300)
        for _, ply in pairs(nearbyPlayers) do
            if ply:IsPlayer() then
                ply:SetDSP(15, false)
                ply.HasResistance = true
                
                -- Create visual effect to show resistance
                if SERVER then
                    local effectData = EffectData()
                    effectData:SetOrigin(ply:GetPos())
                    effectData:SetEntity(ply)
                    util.Effect("TeslaHitBoxes", effectData)
                end
                
                -- Apply damage resistance hook
                hook.Add("EntityTakeDamage", "ResistanceHook_" .. ply:EntIndex(), function(victim, dmginfo)
                    if victim == ply and ply.HasResistance and dmginfo:IsBulletDamage() then
                        dmginfo:ScaleDamage(0.5) -- 50% bullet damage resistance
                    end
                end)
                
                timer.Simple(20, function()
                    if IsValid(ply) then
                        ply.HasResistance = false
                        ply:SetDSP(0, false)
                        hook.Remove("EntityTakeDamage", "ResistanceHook_" .. ply:EntIndex())
                    end
                end)
            end
        end
    elseif self.CurrentBoostType == 2 then -- Speed
        self.Owner:EmitSound("Weapon_Cane.SpeedBoost")
        if target:IsPlayer() then
            local currentRun = target:GetRunSpeed()
            local currentWalk = target:GetWalkSpeed()
            target:SetRunSpeed(currentRun * 1.5)
            target:SetWalkSpeed(currentWalk * 1.5)
            timer.Simple(20, function()
                if IsValid(target) then
                    target:SetRunSpeed(currentRun)
                    target:SetWalkSpeed(currentWalk)
                end
            end)
        end
    end
end

function SWEP:ThrowCoin() -- the coin that you can throw
    if SERVER then
        local coin = ents.Create("prop_physics")
        coin:SetModel("models/vip/weapons/w_coin.mdl")
        coin:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 20)
        coin:SetAngles(self.Owner:EyeAngles())
        coin:SetSkin(self.CurrentBoostType)
        coin:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        coin:Spawn()
        
        local phys = coin:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(self.Owner:GetAimVector() * 1000)
        end
        
        SafeRemoveEntityDelayed(coin, 20)
    end
end

function SWEP:PrimaryAttack()
    if self.UsingAltModel then
        if CurTime() < self.NextCoinThrow then return end
        
        local vm = self.Owner:GetViewModel()
        vm:SendViewModelMatchingSequence(self:GetSequenceFromAct(ActIndex["coin_throw"]))
        
        -- Play both sounds with minimal delay to create overlap
        if IsValid(self.Owner) then
            -- Play the boost voice line first
            if self.CurrentBoostType == 0 then
                self.Owner:EmitSound("Weapon_Cane.MiniCritBoost")
            elseif self.CurrentBoostType == 1 then
                self.Owner:EmitSound("Weapon_Cane.ResistanceBoost")
            else
                self.Owner:EmitSound("Weapon_Cane.SpeedBoost")
            end
            
            -- Play the throw sound immediately after (will overlap)
            timer.Simple(0.05, function()
                if IsValid(self) and IsValid(self.Owner) then
                    if self.CurrentBoostType == 0 then
                        self.Owner:EmitSound("Weapon_Cane.ThrowMinicrits")
                    elseif self.CurrentBoostType == 1 then
                        self.Owner:EmitSound("Weapon_Cane.ThrowResistance")
                    else
                        self.Owner:EmitSound("Weapon_Cane.ThrowSpeed")
                    end
                end
            end)
            
            -- Play the boost received sound slightly after (will overlap with both)
            timer.Simple(0.09, function()
                if IsValid(self) and IsValid(self.Owner) then
                    self.Owner:EmitSound("Weapon_Cane.BoostReceived")
                end
            end)
        end
		
        -- Throw single coin
        if SERVER then
            local coin = ents.Create("prop_physics")
            coin:SetModel("models/vip/weapons/w_coin.mdl")
            coin:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 20)
            coin:SetAngles(self.Owner:EyeAngles())
            coin:SetSkin(self.CurrentBoostType)
            coin:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            coin:Spawn()
            
            local phys = coin:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(self.Owner:GetAimVector() * 1000)
            end
            
            SafeRemoveEntityDelayed(coin, 20)
        end
        
        -- Apply boost to the player
        self:ApplyBoostEffects(self.Owner)
        
        -- Set cooldown
        self.NextCoinThrow = CurTime() + self.CoinCooldown
        
        -- Switch back to regular viewmodel after animation
        local animDuration = vm:SequenceDuration()
        timer.Simple(animDuration, function()
            if IsValid(self) then
                self:SecondaryAttack()
            end
        end)
        
        -- Play ready sound when cooldown is done
        timer.Simple(self.CoinCooldown, function()
            if IsValid(self) then
                self:EmitSound("Weapon_Cane.CoinRegen")
            end
        end)
        
        return
    end
    
    self:SetNextPrimaryFire(CurTime() + 0.5)
    
    local vm = self.Owner:GetViewModel()
    local swingAnims = {ActIndex["swing_a"], ActIndex["swing_b"], ActIndex["swing_c"]}
    vm:SendViewModelMatchingSequence(vm:LookupSequence(swingAnims[math.random(1, #swingAnims)]))
    
    self.IdleDelay = CurTime() + vm:SequenceDuration()
    
    local isCritical = math.random(1, 10) == 1
    
    local tr = util.TraceHull({
        start = self.Owner:GetShootPos(),
        endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 75,
        filter = self.Owner,
        mins = Vector(-10, -10, -10),
        maxs = Vector(10, 10, 10),
        mask = MASK_SHOT_HULL
    })
    
    if tr.Hit then
        if IsValid(tr.Entity) then
            local damage = isCritical and 50 or 25
            tr.Entity:TakeDamage(damage, self.Owner, self)
            self:EmitSound("Weapon_Cane.HitBody")
        else
            self:EmitSound("Weapon_Cane.HitWorld")
        end
    else
        self:EmitSound(isCritical and "Weapon_Cane.MissCrit" or "Weapon_Cane.Miss")
    end
    
    self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:ViewModelDrawn(vm)
    if CLIENT and IsValid(self.ViewModelCane) and not self.UsingAltModel then
        self.ViewModelCane:DrawModel()
    end
end

function SWEP:OnRemove()
    if CLIENT and IsValid(self.ViewModelCane) then
        self.ViewModelCane:Remove()
    end
end

function SWEP:Holster()
    if CLIENT and IsValid(self.ViewModelCane) then
        self.ViewModelCane:Remove()
    end
    return true
end

function SWEP:GetSequenceFromAct(act)
    if !act then return end
    local vm = self.Owner:GetViewModel()
    local seq = vm:LookupSequence(act)
    return seq or vm:LookupSequence("b_idle") -- Fallback to idle if sequence not found
end