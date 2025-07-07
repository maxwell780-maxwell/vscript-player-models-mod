local introSounds = {
    "subzero/intro_music_01.wav",
    "subzero/intro_music_02.wav",
    "subzero/intro_music_03.wav",
    "subzero/intro_music_04.wav"
}

local currentSoundIndex = 1

if SERVER then
    util.AddNetworkString("PlaySaxtonHaleIntro")
end

if CLIENT then
    net.Receive("PlaySaxtonHaleIntro", function()
        local soundPath = net.ReadString()
        surface.PlaySound(soundPath)
    end)
end

-- Function to check if the player model is fully loaded
local function CheckPlayerModel(ply, callback)
    -- Wait a short time for the model to fully load
    timer.Simple(0.5, function()
        if not IsValid(ply) then return end
        
        local playerModel = ply:GetModel()
        local currentMap = game.GetMap()
        local shouldPlaySound = false
        
        -- Check conditions based on player model
        if playerModel == "models/player/saxton_hale.mdl" then
            -- Original Saxton Hale only plays on specific map
            if currentMap == "vsh_expedition_rc3" then
                shouldPlaySound = true
            end
        elseif playerModel == "models/subzero_saxton_hale.mdl" then
            -- Subzero Saxton Hale plays on any map
            shouldPlaySound = true
        end
        
        if shouldPlaySound then
            callback(ply, playerModel, currentMap)
        end
    end)
end

hook.Add("PlayerSpawn", "SaxtonHaleIntroSounds", function(ply)
    if not IsValid(ply) then return end
    
    if SERVER then
        -- Check player model after a short delay to ensure it's loaded
        CheckPlayerModel(ply, function(ply, playerModel, currentMap)
            -- Find the entity with ID 315 and set player position if on the specific map
            if currentMap == "vsh_expedition_rc3" then
                local spawnPoint = ents.GetByIndex(315)
                if IsValid(spawnPoint) then
                    ply:SetPos(spawnPoint:GetPos())
                end
            end
            
            net.Start("PlaySaxtonHaleIntro")
            net.WriteString(introSounds[currentSoundIndex])
            net.Broadcast()
            
            -- Move to next sound, loop back to 1 if we reach the end
            currentSoundIndex = currentSoundIndex + 1
            if currentSoundIndex > #introSounds then
                currentSoundIndex = 1
            end
        end)
    end
end)