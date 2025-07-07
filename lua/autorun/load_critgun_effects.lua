if SERVER then
    -- Load the PCF file
    game.AddParticles("particles/critgun_weaponmodel.pcf")

    -- Precache the specific particle system
    PrecacheParticleSystem("critgun_weaponmodel_blu_glow")
end
