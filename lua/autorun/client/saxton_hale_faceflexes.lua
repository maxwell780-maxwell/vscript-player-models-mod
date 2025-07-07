local HALE_MODELS = {
    "models/player/saxton_hale.mdl",
    "models/vsh/player/santa_hale.mdl",
    "models/vsh/player/hell_hale.mdl",
    "models/vsh/player/saxton_hale.mdl",
    "models/player/hell_hale.mdl",
    "models/subzero_saxton_hale.mdl",
    "models/vsh/player/winter/saxton_hale.mdl"
}

local INTRO_CYCLES = 4
local TRANSITION_SPEED = 0.5
local INTRO_PHASE_TIME = 1.5
local HAPPY_TRANSITION_TIME = 1.0
local LOW_HEALTH_TRANSITION_TIME = 1.0

-- Low health expression timings
local LOW_HEALTH_VARIATIONS = {
    { delay = 3, chance = 0.4 },    -- 3 seconds, 40% chance
    { delay = 5, chance = 0.4 },    -- 5 seconds, 40% chance
    { delay = 8, chance = 0.2 }     -- 8 seconds, 20% chance
}

if CLIENT then
    local lastDeath = 0
    local wasAlive = true -- Track if player was alive last frame
    
    -- Function to reset all face flexes
    local function ResetFaceFlexes(ply)
        if not IsValid(ply) then return end
        
        local flexNames = {
            "left_CloseLid", "right_CloseLid", "idleface", "Neutral", 
            "defaultFace", "mad", "happysmall02", "upset2", "dead01", 
            "upset1", "dead03", "happy1"
        }
        
        for _, flexName in ipairs(flexNames) do
            local flexID = ply:GetFlexIDByName(flexName)
            if flexID then
                ply:SetFlexWeight(flexID, 0)
            end
        end
        
        ply:SetFlexScale(0)
    end
    
    hook.Add("Think", "SaxtonFaceExpressions", function()
        if not LocalPlayer() then return end
        
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local isAlive = ply:Alive()
        
        -- Check if player just died
        if wasAlive and not isAlive then
            lastDeath = CurTime()
            -- Immediately reset face flexes when player dies
            ResetFaceFlexes(ply)
            -- Reset all state variables
            ply.haleIntroStarted = nil
            ply.mainExpressionsStarted = nil
            ply.happyTransitioning = nil
            ply.lowHealthState = nil
            ply.lowHealthTransitioning = nil
        end
        
        wasAlive = isAlive
        
        -- If player is dead, keep resetting flexes and return
        if not isAlive then
            ResetFaceFlexes(ply)
            return
        end
        
        -- Reset state variables shortly after respawn
        if CurTime() - lastDeath < 0.1 then
            ply.haleIntroStarted = nil
            ply.mainExpressionsStarted = nil
            ply.happyTransitioning = nil
            ply.lowHealthState = nil
            ply.lowHealthTransitioning = nil
        end
        
        local isHaleModel = false
        for _, model in ipairs(HALE_MODELS) do
            if ply:GetModel() == model then
                isHaleModel = true
                break
            end
        end
        
        if not isHaleModel then
            -- Reset all face flexes if not using Hale model
            ResetFaceFlexes(ply)
            -- Reset all state variables
            ply.haleIntroStarted = nil
            ply.mainExpressionsStarted = nil
            ply.happyTransitioning = nil
            ply.lowHealthState = nil
            ply.lowHealthTransitioning = nil
            return
        end
        
        -- Continue with Hale model logic
        ply:SetFlexScale(1)
        
        local leftLidID = ply:GetFlexIDByName("left_CloseLid") or 0
        local rightLidID = ply:GetFlexIDByName("right_CloseLid") or 1
        local idleFaceID = ply:GetFlexIDByName("idleface") or 2
        local neutralID = ply:GetFlexIDByName("Neutral") or 3
        local defaultFaceID = ply:GetFlexIDByName("defaultFace") or 4
        local madID = ply:GetFlexIDByName("mad") or 5
        local happySmallID = ply:GetFlexIDByName("happysmall02") or 6
        local upset2ID = ply:GetFlexIDByName("upset2") or 7
        local dead01ID = ply:GetFlexIDByName("dead01") or 8
        local upset1ID = ply:GetFlexIDByName("upset1") or 9
        local dead03ID = ply:GetFlexIDByName("dead03") or 10
        local happy1ID = ply:GetFlexIDByName("happy1") or 11
        
        -- Reset problematic flexes
        ply:SetFlexWeight(happy1ID, 0)
        ply:SetFlexWeight(dead03ID, 0)
        ply:SetFlexWeight(leftLidID, -0.9)
        ply:SetFlexWeight(rightLidID, -0.9)
        
        -- Check health status
        local isLowHealth = ply:Health() <= ply:GetMaxHealth() * 0.5
        local wasLowHealth = ply.lowHealthState ~= nil
        
        if isLowHealth then
            -- Initialize low health state
            if not ply.lowHealthState then
                ply.lowHealthState = "upset2"
                ply.lowHealthTime = CurTime()
                
                -- Select random duration
                local rand = math.random()
                local cumulative = 0
                for _, variation in ipairs(LOW_HEALTH_VARIATIONS) do
                    cumulative = cumulative + variation.chance
                    if rand <= cumulative then
                        ply.lowHealthDuration = variation.delay
                        break
                    end
                end
            end
            
            local timeSinceLowHealth = CurTime() - ply.lowHealthTime
            
            if timeSinceLowHealth > ply.lowHealthDuration then
                ply.lowHealthState = ply.lowHealthState == "upset2" and "dead01" or "upset2"
                ply.lowHealthTime = CurTime()
                
                -- New random duration
                local rand = math.random()
                local cumulative = 0
                for _, variation in ipairs(LOW_HEALTH_VARIATIONS) do
                    cumulative = cumulative + variation.chance
                    if rand <= cumulative then
                        ply.lowHealthDuration = variation.delay
                        break
                    end
                end
            end
            
            -- Smooth transitions for low health expressions
            local progress = math.min(timeSinceLowHealth / LOW_HEALTH_TRANSITION_TIME, 1)
            
            if ply.lowHealthState == "upset2" then
                ply:SetFlexWeight(upset2ID, Lerp(progress, 0, 1))
                ply:SetFlexWeight(dead01ID, Lerp(progress, 1, 0))
                ply:SetFlexWeight(upset1ID, 0)
            else
                ply:SetFlexWeight(upset2ID, Lerp(progress, 1, 0))
                ply:SetFlexWeight(dead01ID, Lerp(progress, 0, 1))
                ply:SetFlexWeight(upset1ID, Lerp(progress, 0, 1))
            end
            
            -- Reset normal expressions
            ply:SetFlexWeight(idleFaceID, 0)
            ply:SetFlexWeight(neutralID, 0)
            ply:SetFlexWeight(defaultFaceID, 0)
            ply:SetFlexWeight(madID, 0)
            ply:SetFlexWeight(happySmallID, 0)
            
        elseif wasLowHealth then
            -- Transitioning from low health to normal
            if not ply.lowHealthTransitioning then
                ply.lowHealthTransitioning = true
                ply.lowHealthTransitionStart = CurTime()
                -- Store current values for smooth transition
                ply.transitionFromUpset2 = ply:GetFlexWeight(upset2ID)
                ply.transitionFromDead01 = ply:GetFlexWeight(dead01ID)
                ply.transitionFromUpset1 = ply:GetFlexWeight(upset1ID)
            end
            
            local transitionProgress = math.min((CurTime() - ply.lowHealthTransitionStart) / LOW_HEALTH_TRANSITION_TIME, 1)
            
            -- Smoothly transition low health expressions to 0
            ply:SetFlexWeight(upset2ID, Lerp(transitionProgress, ply.transitionFromUpset2, 0))
            ply:SetFlexWeight(dead01ID, Lerp(transitionProgress, ply.transitionFromDead01, 0))
            ply:SetFlexWeight(upset1ID, Lerp(transitionProgress, ply.transitionFromUpset1, 0))
            
            if transitionProgress >= 1 then
                -- Transition complete, reset low health state
                ply.lowHealthState = nil
                ply.lowHealthTransitioning = nil
                ply.transitionFromUpset2 = nil
                ply.transitionFromDead01 = nil
                ply.transitionFromUpset1 = nil
            end
            
            -- Don't start normal expressions until transition is complete
            if transitionProgress < 1 then
                ply:SetFlexWeight(idleFaceID, 0)
                ply:SetFlexWeight(neutralID, 0)
                ply:SetFlexWeight(defaultFaceID, 0)
                ply:SetFlexWeight(madID, 0)
                ply:SetFlexWeight(happySmallID, 0)
                return
            end
        end
        
        -- Normal expressions (only when not in low health)
        if not isLowHealth and not ply.lowHealthTransitioning then
            if not ply.haleIntroStarted then
                ply.haleIntroStarted = true
                ply.haleIntroCycle = 0
                ply.haleIntroTime = CurTime()
                ply.haleIntroPhase = "up"
                ply.mainExpressionsStarted = nil
                ply.happyTransitioning = nil
            end
            
            if ply.haleIntroCycle < INTRO_CYCLES then
                local timeSincePhase = CurTime() - ply.haleIntroTime
                
                ply:SetFlexWeight(idleFaceID, 0)
                ply:SetFlexWeight(neutralID, 0)
                ply:SetFlexWeight(defaultFaceID, 0)
                ply:SetFlexWeight(madID, 0)
                ply:SetFlexWeight(upset2ID, 0)
                ply:SetFlexWeight(dead01ID, 0)
                ply:SetFlexWeight(upset1ID, 0)
                
                if ply.haleIntroPhase == "up" and timeSincePhase > INTRO_PHASE_TIME then
                    ply:SetFlexWeight(happySmallID, 0.7)
                    ply.haleIntroPhase = "down"
                    ply.haleIntroTime = CurTime()
                elseif ply.haleIntroPhase == "down" and timeSincePhase > INTRO_PHASE_TIME then
                    ply:SetFlexWeight(happySmallID, 0.4)
                    ply.haleIntroPhase = "up"
                    ply.haleIntroTime = CurTime()
                    ply.haleIntroCycle = ply.haleIntroCycle + 1
                end
            else
                if not ply.happyTransitioning then
                    ply.happyTransitioning = true
                    ply.happyTransitionStart = CurTime()
                    ply.initialHappyValue = ply:GetFlexWeight(happySmallID)
                end
                
                if ply.happyTransitioning then
                    local transitionProgress = math.min((CurTime() - ply.happyTransitionStart) / HAPPY_TRANSITION_TIME, 1)
                    local currentHappyValue = Lerp(transitionProgress, ply.initialHappyValue, 0)
                    ply:SetFlexWeight(happySmallID, currentHappyValue)
                    
                    if transitionProgress >= 1 then
                        ply.happyTransitioning = false
                    end
                end
                
                if not ply.mainExpressionsStarted then
                    ply.mainExpressionsStarted = true
                    ply.expressionTime = CurTime()
                    ply.expressionState = "idle"
                    ply.stateStartTime = CurTime()
                end
                
                local timeSinceStateChange = CurTime() - ply.stateStartTime
                
                if ply.expressionState == "idle" then
                    local progress = math.min(timeSinceStateChange / 2, 1)
                    ply:SetFlexWeight(idleFaceID, Lerp(progress, 0, 1))
                    ply:SetFlexWeight(neutralID, Lerp(progress, 0, 1))
                    ply:SetFlexWeight(defaultFaceID, Lerp(progress, 0, 1))
                    ply:SetFlexWeight(madID, Lerp(progress, 0.6, 0))
                    
                    if progress >= 1 and timeSinceStateChange > 4 then
                        ply.expressionState = "mad"
                        ply.stateStartTime = CurTime()
                    end
                else
                    local progress = math.min(timeSinceStateChange / 2, 1)
                    ply:SetFlexWeight(idleFaceID, Lerp(progress, 1, 0))
                    ply:SetFlexWeight(neutralID, Lerp(progress, 1, 0))
                    ply:SetFlexWeight(defaultFaceID, Lerp(progress, 1, 0))
                    ply:SetFlexWeight(madID, Lerp(progress, 0, 0.6))
                    
                    if progress >= 1 and timeSinceStateChange > 4 then
                        ply.expressionState = "idle"
                        ply.stateStartTime = CurTime()
                    end
                end
            end
        end
    end)
end