local TRANSITION_TIME = 1   -- duration to return from changed expression to normal
local ANGRY_FACE_DURATION = 2   -- how long to hold the angry face
local ANGRY_COOLDOWN = 2        -- cooldown before another angry face

local MOBSTER_MODELS = {
    ["models/vip_mobster/player/old/mobster.mdl"] = true,
    ["models/vip_mobster/player/mobster_new.mdl"] = true
}

local TRANSITION_SPEED = 0.5
local CHANCE_TO_CHANGE = 0.001 -- 0.1% chance per think
local LOW_HEALTH_THRESHOLD = 0.5
local UPSET_HOLD_TIME = 10
local UPSET_TRANSITION_SPEED = 0.5
local ANGRY_IN_TIME = 0.2
local ANGRY_OUT_TIME = 0.5


-- Time variations for the original expression
local TIME_VARIATIONS = {
    { delay = 10, chance = 0.7 },    -- 10 seconds, 70% chance
    { delay = 60, chance = 0.25 },   -- 1 minute, 25% chance
    { delay = 600, chance = 0.05 }   -- 10 minutes, 5% chance
}

local function IsMobsterModel(ply)
    return MOBSTER_MODELS[string.lower(ply:GetModel())] == true
end

-- OH GOD I MADE IT HORRIBLE welp to bad :/ is just what i get for being a bad programer if garrys mod dont complain im not complaining
    -- Variables
    local nextAngryTime = 0
    local angryState = {
        active = false,
        startTime = 0,
    }

    net.Receive("PlayerFiredSWEP", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not IsMobsterModel(ply) then return end
        if CurTime() < nextAngryTime then return end -- cooldown

        angryState.active = true
        angryState.startTime = CurTime()
        nextAngryTime = CurTime() + ANGRY_FACE_DURATION + ANGRY_COOLDOWN
    end)

    hook.Add("Think", "MobsterFaceExpressionSWEP", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not IsMobsterModel(ply) then return end

        local madID = ply:GetFlexIDByName("mad") or 6 -- change 6 if your flex ID differs

        if angryState.active then
            local elapsed = CurTime() - angryState.startTime

            if elapsed <= TRANSITION_TIME then
                -- Smoothly lerp in
                local t = elapsed / TRANSITION_TIME
                ply:SetFlexWeight(madID, t)
elseif elapsed <= ANGRY_IN_TIME + ANGRY_FACE_DURATION then
    ply:SetFlexWeight(madID, 1)
elseif elapsed <= ANGRY_IN_TIME + ANGRY_FACE_DURATION + ANGRY_OUT_TIME then
    local t = (elapsed - ANGRY_IN_TIME - ANGRY_FACE_DURATION) / ANGRY_OUT_TIME
    ply:SetFlexWeight(madID, 1 - t)
else
                -- Finished
                angryState.active = false
                ply:SetFlexWeight(madID, 0)
            end
        end
    end)

hook.Add("Think", "MobsterFaceExpressionstime", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    
    if IsMobsterModel(ply) then
        ply:SetFlexScale(1)
        
        local idleFaceID = ply:GetFlexIDByName("idleface") or 0
        local leftLidID = ply:GetFlexIDByName("left_CloseLid") or 1
        local rightLidID = ply:GetFlexIDByName("right_lid_closer") or 2
        local multiLidID = ply:GetFlexIDByName("multi_CloseLid") or 3
        local upset1ID = ply:GetFlexIDByName("upset1") or 4
        local upset2ID = ply:GetFlexIDByName("upset2") or 5
        
        -- Random chance to change expression
        if not ply.changingExpression and math.random() < CHANCE_TO_CHANGE then
            ply.changingExpression = true
            ply.changeStartTime = CurTime()
            ply.returningToNormal = false
            
            -- Select random duration based on chances
            local rand = math.random()
            local cumulative = 0
            for _, variation in ipairs(TIME_VARIATIONS) do
                cumulative = cumulative + variation.chance
                if rand <= cumulative then
                    ply.selectedDelay = variation.delay
                    break
                end
            end
        end
        
        local healthFraction = ply:Health() / ply:GetMaxHealth() -- note to self REMINDER for in the future to update this dumb aah code f*ck me guess ill just forget about it for another year or never till i manage to get start coding this stupid code


-- THIS TOOK FOREVER but its worth the wait


local health = ply:Health()
local maxHealth = ply:GetMaxHealth()

if type(health) ~= "number" or type(maxHealth) ~= "number" or maxHealth <= 0 then return end



local healthFraction = health / maxHealth


		if healthFraction <= LOW_HEALTH_THRESHOLD then
            ply.changingExpression = false
            ply.returningToNormal = false

            if not ply.upsetState then
                -- Initialize state
                ply.upsetState = {
                    current = 1,          -- 1 = upset1, 2 = upset2
                    startTime = CurTime(), -- time when this flex started
                    phase = "hold"         -- hold -> transition
                }
            end

            local state = ply.upsetState
            local elapsed = CurTime() - state.startTime

            if state.phase == "hold" then
                -- Hold the current flex at 1
                if state.current == 1 then
                    ply:SetFlexWeight(upset1ID, 1)
                    ply:SetFlexWeight(upset2ID, 0)
                else
                    ply:SetFlexWeight(upset1ID, 0)
                    ply:SetFlexWeight(upset2ID, 1)
                end

                -- Reset other face flexes
                ply:SetFlexWeight(idleFaceID, 0)
                ply:SetFlexWeight(leftLidID, 0.5)
                ply:SetFlexWeight(rightLidID, 0.5)
                ply:SetFlexWeight(multiLidID, 0.5)

                -- Wait UPSET_HOLD_TIME seconds
                if elapsed >= UPSET_HOLD_TIME then
                    state.phase = "transition"
                    state.startTime = CurTime()
                    state.from = state.current
                    state.to = 3 - state.current -- switch 1<->2
                end
            elseif state.phase == "transition" then
                local t = math.min(elapsed / UPSET_TRANSITION_SPEED, 1) -- lerp progress
                if state.from == 1 then
                    ply:SetFlexWeight(upset1ID, 1 - t)
                    ply:SetFlexWeight(upset2ID, t)
                else
                    ply:SetFlexWeight(upset1ID, t)
                    ply:SetFlexWeight(upset2ID, 1 - t)
                end

                -- Reset other face flexes
                ply:SetFlexWeight(idleFaceID, 0)
                ply:SetFlexWeight(leftLidID, 0.5)
                ply:SetFlexWeight(rightLidID, 0.5)
                ply:SetFlexWeight(multiLidID, 0.5)

                if t >= 1 then
                    -- Transition complete, start hold again
                    state.current = state.to
                    state.phase = "hold"
                    state.startTime = CurTime()
                end
            end

            return
        else
            ply.upsetState = nil
        end

        -- NORMAL FACE EXPRESSION LOGIC
        if not ply.changingExpression and math.random() < CHANCE_TO_CHANGE then
            ply.changingExpression = true
            ply.changeStartTime = CurTime()
            ply.returningToNormal = false

            local rand = math.random()
            local cumulative = 0
            for _, variation in ipairs(TIME_VARIATIONS) do
                cumulative = cumulative + variation.chance
                if rand <= cumulative then
                    ply.selectedDelay = variation.delay
                    break
                end
            end
        end

        if ply.changingExpression then
            local timeSinceChange = CurTime() - ply.changeStartTime

            if timeSinceChange < ply.selectedDelay then
                local progress = timeSinceChange / ply.selectedDelay
                local targetWeight = Lerp(progress, 1, 0)
                local lidTargetWeight = Lerp(progress, 0.5, 0.5)
                local multiTargetWeight = Lerp(progress, 0.5, 0.5)

                ply:SetFlexWeight(idleFaceID, targetWeight)
                ply:SetFlexWeight(leftLidID, lidTargetWeight)
                ply:SetFlexWeight(rightLidID, lidTargetWeight)
                ply:SetFlexWeight(multiLidID, multiTargetWeight)
            elseif not ply.returningToNormal then
                ply.returningToNormal = true
                ply.returnStartTime = CurTime()
            end

            if ply.returningToNormal then
                local returnProgress = (CurTime() - ply.returnStartTime) / TRANSITION_TIME

                if returnProgress >= 1 then
                    ply.changingExpression = false
                else
                    local targetWeight = Lerp(returnProgress, 0, 1)
                    local lidTargetWeight = Lerp(returnProgress, 0.5, 0.5)
                    local multiTargetWeight = Lerp(returnProgress, 0.5, 0.5)

                    ply:SetFlexWeight(idleFaceID, targetWeight)
                    ply:SetFlexWeight(leftLidID, lidTargetWeight)
                    ply:SetFlexWeight(rightLidID, lidTargetWeight)
                    ply:SetFlexWeight(multiLidID, multiTargetWeight)
                end
            end
        else
            ply:SetFlexWeight(idleFaceID, 1)
            ply:SetFlexWeight(leftLidID, 0.5)
            ply:SetFlexWeight(rightLidID, 0.5)
            ply:SetFlexWeight(multiLidID, 0.5)
        end
    end
end)
