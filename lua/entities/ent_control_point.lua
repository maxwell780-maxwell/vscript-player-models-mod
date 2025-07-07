AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Mobster Control Point"
ENT.Author = "Code Copilot & maxwell"
ENT.Category = "maxwells map buildable entitys"
ENT.Spawnable = true

-- Constants
local TEAM_NONE, TEAM_RED, TEAM_BLU = 0, 1, 2
local MODEL = "models/effects/cappoint_hologram.mdl"
local MOBSTER_MODEL = "models/vip_mobster/player/mobster.mdl"
local BODYGROUP_CONTROL = 0
local BG_RED, BG_BLU = 2, 3

-- Classes
local CLASS_START, CLASS_MID, CLASS_END, CLASS_NIL = 1, 2, 3, 0
local bluVictoryAnnounced = false
local redWarningCooldown = 0

local function BLUHasAllPoints()
    local counts = { [CLASS_START] = false, [CLASS_MID] = false, [CLASS_END] = false }
    for _, ent in ipairs(ents.FindByClass("ent_control_point")) do
        if IsValid(ent) and ent.OwningTeam == TEAM_BLU then
            counts[ent:GetPointClass()] = true
        end
    end
    return counts[CLASS_START] and counts[CLASS_MID] and counts[CLASS_END]
end

local function ApplyVictoryBonus()
    for _, ply in ipairs(player.GetAll()) do
        local skin = ply:GetSkin()
        if skin == 1 then
            ply.VictoryBuffed = true
            ply:EmitSound("weapons/crit_power.wav")
            for _, wep in ipairs(ply:GetWeapons()) do
                if IsValid(wep) then
                    local viewModel = ply:GetViewModel()
                    local worldModel = wep
                    if IsValid(viewModel) then
                        ParticleEffectAttach("critgun_weaponmodel_blu_glow", PATTACH_ABSORIGIN_FOLLOW, viewModel, 0)
                    end
                    if IsValid(worldModel) then
                        ParticleEffectAttach("critgun_weaponmodel_blu_glow", PATTACH_ABSORIGIN_FOLLOW, worldModel, 0)
                    end
                end
            end
        end
    end
end

local function RemoveVictoryBonus()
    for _, ply in ipairs(player.GetAll()) do
        if ply.VictoryBuffed then
            ply.VictoryBuffed = false
            ply:StopSound("weapons/crit_power.wav")
        end
    end
    bluVictoryAnnounced = false
end

local function PlayToTeam(teamSkin, soundPath)
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetSkin() == teamSkin then
            ply:EmitSound(soundPath)
        end
    end
end

local function StripRedWeapons()
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetSkin() == 0 then
            ply:StripWeapons()
        end
    end
end


function ENT:Initialize()
    self:SetModel(MODEL)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

    self.CaptureProgress = 0
    self.CapturingTeam = TEAM_NONE
    self.OwningTeam = TEAM_RED
    self.Captured = false
    self:UpdateBodygroup()

    local seq = self:LookupSequence("idle")
    self:SetSequence(seq)
    self:SetPlaybackRate(1)
    self:SetCycle(0)
    self.AutomaticFrameAdvance = true

    self.NextCaptureCheck = CurTime() + 1
end

function ENT:UpdateBodygroup()
    local currentBG = self:GetBodygroup(BODYGROUP_CONTROL)
    if self.OwningTeam == TEAM_BLU and currentBG ~= BG_BLU then
        self:SetBodygroup(BODYGROUP_CONTROL, BG_BLU)
    elseif self.OwningTeam == TEAM_RED and currentBG ~= BG_RED then
        self:SetBodygroup(BODYGROUP_CONTROL, BG_RED)
    end
end

function ENT:Think()
    if CurTime() < (self.NextCaptureCheck or 0) then return end
    self.NextCaptureCheck = CurTime() + 0.2

    self:UpdateControlPointClass()

    if self.OwningTeam == TEAM_BLU then
        self:UpdateBodygroup()
    end

    local beingCaptured = false
    if not self:CanCapture() then return true end

    local playersInRange = {}
    for _, ply in ipairs(ents.FindInSphere(self:GetPos(), 200)) do
        if not ply:IsPlayer() then continue end
        if ply:GetModel() ~= MOBSTER_MODEL then continue end

        local skin = ply:GetSkin()
        local team = (skin == 0 and TEAM_RED) or (skin == 1 and TEAM_BLU) or TEAM_NONE
        if team == TEAM_BLU and self.OwningTeam ~= TEAM_BLU then
            table.insert(playersInRange, ply)
            beingCaptured = true
        end
    end

    if beingCaptured and CurTime() > redWarningCooldown then
        redWarningCooldown = CurTime() + 5
        PlayToTeam(0, table.Random({
            "vo/announcer_control_point_warning.mp3",
            "vo/announcer_control_point_warning2.mp3",
            "vo/announcer_control_point_warning3.mp3"
        }))
    end

    if #playersInRange > 0 then
        if not self.Capturing then
            self.Capturing = true
            self:EmitSound("misc/hologram_start.wav")
            self.CaptureLoop = CreateSound(self, "misc/hologram_move.wav")
            self.CaptureLoop:PlayEx(1, 100)
        end
        self.CaptureProgress = math.min(100, self.CaptureProgress + (#playersInRange * 0.5))
        if self.CaptureProgress >= 100 and not self.Captured then
            self.OwningTeam = TEAM_BLU
            self.Captured = true
            self:UpdateBodygroup()
            self:EmitSound("ui/scored.wav")
            self.Capturing = false
            if self.CaptureLoop then self.CaptureLoop:Stop() end

            if self:GetPointClass() ~= CLASS_END then
                PlayToTeam(1, table.Random({
                    "vo/announcer_time_awarded_success.mp3",
                    "vo/announcer_time_awarded_congrats.mp3",
                    "vo/announcer_time_awarded.mp3"
                }))
            end

            if BLUHasAllPoints() and not bluVictoryAnnounced then
                bluVictoryAnnounced = true
                for _, ply in ipairs(player.GetAll()) do
                    local team = ply:GetSkin() == 1 and TEAM_BLU or TEAM_RED
                    if team == TEAM_BLU then
                        ply:EmitSound("misc/your_team_won.wav")
                    elseif team == TEAM_RED then
                        ply:EmitSound("misc/your_team_lost.wav")
                    end
                    ply:ChatPrint("BLU team has won RED team has lost")
                end
                ApplyVictoryBonus()
                StripRedWeapons()
            end
        end
    else
        if self.Capturing then
            self.Capturing = false
            if self.CaptureLoop then self.CaptureLoop:Stop() end
            self:EmitSound("misc/hologram_stop.wav")
        end
        if self.OwningTeam ~= TEAM_BLU then
            for _, ply in ipairs(ents.FindInSphere(self:GetPos(), 200)) do
                if not ply:IsPlayer() then continue end
                local skin = ply:GetSkin()
                if skin == 0 then
                    self.CaptureProgress = math.max(0, self.CaptureProgress - 0.5)
                end
            end
        end
    end

    if not BLUHasAllPoints() then
        RemoveVictoryBonus()
    end

    self:NextThink(CurTime())
    return true
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "PointClass")
end

function ENT:UpdateControlPointClass()
    local allPoints = ents.FindByClass("ent_control_point")
    table.sort(allPoints, function(a, b)
        return IsValid(a) and IsValid(b) and a:EntIndex() < b:EntIndex()
    end)

    for i, ent in ipairs(allPoints) do
        if not IsValid(ent) then continue end
        if i == 1 then
            ent:SetPointClass(CLASS_START)
        elseif i == 2 then
            ent:SetPointClass(CLASS_MID)
        elseif i == 3 then
            ent:SetPointClass(CLASS_END)
        else
            ent:SetPointClass(CLASS_NIL)
        end
    end
end

function ENT:CanCapture()
    if self.OwningTeam == TEAM_BLU or self.Captured then return false end
    local pointClass = self:GetPointClass()
    if pointClass == CLASS_NIL then return false end
    if pointClass == CLASS_START then return true end
    for _, ent in ipairs(ents.FindByClass("ent_control_point")) do
        if ent:GetPointClass() == (pointClass - 1) and ent.OwningTeam ~= TEAM_BLU then
            return false
        end
    end
    return true
end
