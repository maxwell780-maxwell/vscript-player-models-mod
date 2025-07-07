if SERVER then
    AddCSLuaFile()
    
    -- Create a networked variable to track marked entities
    util.AddNetworkString("BigMallet_MarkedEntity")
end

SWEP.Base = "weapon_base"
SWEP.PrintName = "Horsemans Big mallet"
SWEP.Author = "Your Name"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "maxwells Vscript swep"
SWEP.Instructions = "use primary fire to perform a melee attack this time it does a smash on hit cool am i right :P plus it can knockback npcs to. use reload to use the BOO! ability making npcs in your path run away in terror use secondary ability to mark your foe but you have to align it perfectly with your cross hair its the same thing as the horsemans axe ok please dont expect much from this swep"

SWEP.IconOverride = "vgui/icons/hatmans hammer icon"
 
SWEP.ViewModel = "models/weapons/c_models/c_demo_arms.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_big_mallet/c_big_mallet.mdl"
SWEP.UseHands = true
SWEP.HoldType = "melee2"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 1.0
SWEP.Primary.DamageMultiplier = 0.8  -- 80% of target's health
SWEP.Primary.HitDelay = 0.3  -- Delay before dealing damage
SWEP.Primary.Range = 100  -- Melee attack range in units

SWEP.ReloadCooldown = 10  -- Cooldown for the reload ability
SWEP.LastReloadTime = 0

SWEP.MissSound = "misc/halloween/strongman_fast_impact_01.wav"
SWEP.HitSound = "misc/halloween/strongman_fast_impact_01.wav"
SWEP.SwingSound = "misc/halloween/strongman_fast_whoosh_01.wav"
SWEP.ReloadSound = "vo/halloween_boss/knight_alert.mp3"
SWEP.KnockbackPower = 800  -- Power of the knockback
SWEP.KnockbackRadius = 190  -- Radius of the knockback effect

SWEP.ScreamSounds = {
    "vo/halloween/halloween_scream1.mp3",
    "vo/halloween/halloween_scream2.mp3",
    "vo/halloween/halloween_scream3.mp3",
    "vo/halloween/halloween_scream4.mp3",
    "vo/halloween/halloween_scream5.mp3",
    "vo/halloween/halloween_scream6.mp3",
    "vo/halloween/halloween_scream7.mp3",
    "vo/halloween/halloween_scream8.mp3"
}

SWEP.AttackSounds = {
    "vo/halloween_boss/knight_attack01.mp3",
    "vo/halloween_boss/knight_attack02.mp3",
    "vo/halloween_boss/knight_attack03.mp3",
    "vo/halloween_boss/knight_attack04.mp3"
}

SWEP.FearRadius = 500  -- Medium radius for NPCs/entities
SWEP.FearDuration = 40  -- Seconds

SWEP.MarkSound = "ui/halloween_boss_chosen_it.wav"
SWEP.BecomesItSound = "ui/halloween_boss_player_becomes_it.wav"
SWEP.TaggedOtherSound = "ui/halloween_boss_tagged_other_it.wav"

SWEP.MarkedEntity = nil -- The entity currently marked for death
SWEP.MarkedColor = Color(255, 0, 0) -- Red halo for marked entities

if CLIENT then
    BigMallet_MarkedEntities = BigMallet_MarkedEntities or {}
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self.LastReloadTime = 0 -- Ensure LastReloadTime is initialized
end

function SWEP:Deploy()
    if IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetViewModel()) then
        self:GetOwner():GetViewModel():SetSequence(self:GetOwner():GetViewModel():LookupSequence("cm_idle"))
    end
    return true
end

-- Custom melee trace function with safety checks
function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    owner:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_VM_HITCENTER)
    
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    
    -- Play both sounds - the swing sound and the attack voice
    self:EmitSound(self.SwingSound, 75, 100, 1, CHAN_WEAPON)
    self:EmitSound(self.AttackSounds[math.random(#self.AttackSounds)], 75, 100, 1, CHAN_AUTO)
    
    -- Use timer for the hit detection to match the animation
    timer.Simple(self.Primary.HitDelay, function()
        if not IsValid(self) or not IsValid(owner) then return end
        
        -- Perform a proper melee trace
        local hitEntity, hitPos = self:MeleeTrace(self.Primary.Range)
        
        -- Ensure hitPos is valid
        if not hitPos then
            hitPos = owner:GetShootPos() + owner:GetAimVector() * self.Primary.Range
        end
        
        -- Apply knockback to all entities in radius
        if SERVER then
            for _, entity in pairs(ents.FindInSphere(hitPos, self.KnockbackRadius or 150)) do
                if IsValid(entity) and (entity:IsPlayer() or entity:IsNPC() or entity:IsNextBot() or entity:GetClass() == "prop_physics") and entity != owner then
                    local direction = (entity:GetPos() - hitPos):GetNormalized()
                    
                    -- Add upward component to the knockback
                    direction.z = math.max(direction.z, 0.2)
                    direction:Normalize()
                    
                    local knockbackForce = direction * (self.KnockbackPower or 800)
                    
                    if entity:IsPlayer() then
                        entity:SetVelocity(knockbackForce)
                    elseif entity:IsNPC() or entity:IsNextBot() then
                        entity:SetVelocity(knockbackForce)
                    else
                        local phys = entity:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:ApplyForceCenter(knockbackForce * 10)
                        end
                    end
                end
            end
        end
        
        if IsValid(hitEntity) and (hitEntity:IsPlayer() or hitEntity:IsNPC() or hitEntity:IsNextBot()) then
            local dmg = hitEntity:Health() * self.Primary.DamageMultiplier
            local dmgInfo = DamageInfo()
            dmgInfo:SetDamage(dmg)
            dmgInfo:SetDamageType(DMG_CLUB)  -- Changed to club damage for mallet
            dmgInfo:SetAttacker(owner)
            dmgInfo:SetInflictor(self)
            dmgInfo:SetDamagePosition(hitPos)
            dmgInfo:SetDamageForce(owner:GetAimVector() * 10000)  -- Add force to the damage
            hitEntity:TakeDamageInfo(dmgInfo)
            
            -- Add impact effect
            local effectdata = EffectData()
            effectdata:SetOrigin(hitPos)
            effectdata:SetEntity(hitEntity)
            util.Effect("halloween_boss_axe_hit_sparks", effectdata)
            
            self:EmitSound(self.HitSound, 75, 100, 1, CHAN_WEAPON)
        else
            self:EmitSound(self.MissSound, 75, 100, 1, CHAN_WEAPON)
        end
    end)
end

-- Custom melee trace function
function SWEP:MeleeTrace(distance)
    local owner = self:GetOwner()
    
    local traceStart = owner:GetShootPos()
    local traceEnd = traceStart + owner:GetAimVector() * distance
    
    local tr = util.TraceLine({
        start = traceStart,
        endpos = traceEnd,
        filter = owner,
        mask = MASK_SHOT_HULL
    })
    
    if not tr.Hit then
        tr = util.TraceHull({
            start = traceStart,
            endpos = traceEnd,
            filter = owner,
            mins = Vector(-10, -10, -10),
            maxs = Vector(10, 10, 10),
            mask = MASK_SHOT_HULL
        })
    end
    
    return tr.Entity, tr.HitPos
end

function SWEP:Reload()
    if CurTime() < self.LastReloadTime + self.ReloadCooldown then return end
    self.LastReloadTime = CurTime()
    
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    owner:SetAnimation(PLAYER_ATTACK1) -- Player plays attack animation
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    
    local vm = owner:GetViewModel()
    if IsValid(vm) then
        vm:SetSequence(vm:LookupSequence("b_swing_b"))
    end
    
    self:EmitSound(self.ReloadSound, 75, 100, 1, CHAN_VOICE)
    
    timer.Simple(vm:SequenceDuration(), function()
        if IsValid(vm) then
            vm:SetSequence(vm:LookupSequence("cm_idle"))
        end
    end)
    
    for _, entity in pairs(ents.FindInSphere(owner:GetPos(), self.FearRadius)) do
        if entity:IsNPC() and not entity:IsNextBot() then
            local screamSound = self.ScreamSounds[math.random(#self.ScreamSounds)]
            entity:EmitSound(screamSound, 75, 100, 1, CHAN_AUTO)
            entity:SetSchedule(SCHED_RUN_FROM_ENEMY)
            entity:AddEntityRelationship(owner, D_FR, 99) -- Forces NPC to flee and not attack
            
            timer.Simple(self.FearDuration, function()
                if IsValid(entity) then
                    entity:SetSchedule(SCHED_IDLE_STAND)
                    entity:AddEntityRelationship(owner, D_HT, 99) -- Restore hostility
                end
            end)
        end
    end
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    
    -- Use the melee trace for marking as well
    local target, _ = self:MeleeTrace(self.Primary.Range * 10000000000) -- Double range for marking
    
    if IsValid(target) and (target:IsPlayer() or target:IsNPC()) and target != owner then
        -- Mark the entity
        self:MarkEntity(target)
        
        self:EmitSound(self.MarkSound, 75, 100, 1, CHAN_STATIC)
        
        for _, entity in pairs(ents.FindInSphere(owner:GetPos(), self.FearRadius)) do
            if entity:IsPlayer() or entity:IsNPC() then
                entity:EmitSound(self.BecomesItSound, 75, 100, 1, CHAN_STATIC)
            end
        end
    end
    
    owner:SetAnimation(PLAYER_ATTACK1) -- Ensure the player performs an attack animation
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    
    self:SetNextSecondaryFire(CurTime() + 1.5)
    
    local vm = owner:GetViewModel()
    if IsValid(vm) then
        vm:SetSequence(vm:LookupSequence("b_swing_c"))
        timer.Simple(vm:SequenceDuration(), function()
            if IsValid(vm) then
                vm:SetSequence(vm:LookupSequence("cm_idle"))
            end
        end)
    end
end


function SWEP:MarkEntity(entity)
    -- Never mark the weapon owner
    if entity == self:GetOwner() then return end
    
    if SERVER then
        -- Unmark previous entity if it exists
        if IsValid(self.MarkedEntity) then
            net.Start("BigMallet_MarkedEntity")
                net.WriteEntity(self.MarkedEntity)
                net.WriteBool(false) -- Unmark
            net.Broadcast()
        end
        
        -- Mark new entity
        self.MarkedEntity = entity
        
        net.Start("BigMallet_MarkedEntity")
            net.WriteEntity(entity)
            net.WriteBool(true) -- Mark
        net.Broadcast()
    end
end

-- Function to unmark an entity
function SWEP:UnmarkEntity(entity)
    if SERVER and IsValid(entity) then
        net.Start("BigMallet_MarkedEntity")
            net.WriteEntity(entity)
            net.WriteBool(false) -- Unmark
        net.Broadcast()
        
        if self.MarkedEntity == entity then
            self.MarkedEntity = nil
        end
    end
end

if CLIENT then
    -- Receive marked entity updates from server
    net.Receive("BigMallet_MarkedEntity", function()
        local entity = net.ReadEntity()
        local isMarked = net.ReadBool()
        
        if IsValid(entity) then
            if isMarked then
                BigMallet_MarkedEntities[entity:EntIndex()] = true
            else
                BigMallet_MarkedEntities[entity:EntIndex()] = nil
            end
        end
    end)
    
    -- Draw halos around marked entities
    hook.Add("PreDrawHalos", "BigMalletMarkedEntityHalo", function()
        local markedEntities = {}
        
        for entIndex, _ in pairs(BigMallet_MarkedEntities) do
            local ent = Entity(entIndex)
            if IsValid(ent) then
                table.insert(markedEntities, ent)
            else
                -- Clean up invalid entities
                BigMallet_MarkedEntities[entIndex] = nil
            end
        end
        
        if #markedEntities > 0 then
            halo.Add(markedEntities, Color(255, 0, 0), 2, 2, 5, true, true)
        end
    end)
end

hook.Add("EntityTakeDamage", "TransferMalletMark", function(target, dmgInfo)
    local attacker = dmgInfo:GetAttacker()
    
    -- Check if the attacker is the marked entity and is attacking another NPC
    if SERVER and IsValid(attacker) and IsValid(target) and attacker ~= target then
        -- Find all weapons that might have this entity marked
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and IsValid(ply:GetActiveWeapon()) and 
               ply:GetActiveWeapon().MarkedEntity == attacker and 
               ply:GetActiveWeapon():GetClass() == "big_mallet" then
                
                local weapon = ply:GetActiveWeapon()
                
                -- Triple safety check: target must be valid NPC/player, not the weapon owner, and not any player using a big_mallet
                if (target:IsNPC() or (target:IsPlayer() and target:GetActiveWeapon():GetClass() != "big_mallet")) and 
                   target != ply and target != weapon:GetOwner() then
                    
                    -- Unmark the current attacker
                    weapon:UnmarkEntity(attacker)
                    
                    -- Mark the new target with safety check
                    if target != weapon:GetOwner() then
                        weapon:MarkEntity(target)
                        weapon:EmitSound(weapon.TaggedOtherSound, 75, 100, 1, CHAN_STATIC)
                        
                        if target:IsNPC() and not target:IsNextBot() then
                            target:SetEnemy(ply) -- Make the NPC target the player
                        end
                    end
                    
                    break -- Only need to process once
                end
            end
        end
    end
end)

-- Add a client-side hook to ensure the owner is never marked
if CLIENT then
    hook.Add("PreDrawHalos", "BigMalletMarkedEntityHalo", function()
        local markedEntities = {}
        local localPlayer = LocalPlayer()
        
        for entIndex, _ in pairs(BigMallet_MarkedEntities) do
            local ent = Entity(entIndex)
            -- Never add the local player to the marked entities
            if IsValid(ent) and ent != localPlayer then
                table.insert(markedEntities, ent)
            else
                -- Clean up invalid entities or the local player
                BigMallet_MarkedEntities[entIndex] = nil
            end
        end
        
        if #markedEntities > 0 then
            halo.Add(markedEntities, Color(255, 0, 0), 2, 2, 5, true, true)
        end
    end)
end

-- Clean up when the weapon is removed
function SWEP:OnRemove()
    if SERVER and IsValid(self.MarkedEntity) then
        self:UnmarkEntity(self.MarkedEntity)
    end
end

-- Clean up when the player dies or drops the weapon
function SWEP:Holster()
    if SERVER and IsValid(self.MarkedEntity) then
        self:UnmarkEntity(self.MarkedEntity)
    end
    return true
end