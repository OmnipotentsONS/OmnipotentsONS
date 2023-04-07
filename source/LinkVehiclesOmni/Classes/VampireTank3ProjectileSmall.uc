// ============================================================================
// Link Tank gunner projectile.
// ============================================================================
class VampireTank3ProjectileSmall extends  PROJ_LinkTurret_Plasma;

// ============================================================================


simulated function Explode(vector HitLocation, vector HitNormal)
{
    if ( EffectIsRelevant(Location,false) )
    {
        if (Links == 0)
            Spawn(class'VampireTank3ProjSparksPurple',,, HitLocation, rotator(HitNormal));
        else
            Spawn(class'VampireTank3ProjSparksPurple',,, HitLocation, rotator(HitNormal));
            
/*            
        if (Links == 0)
            Spawn(class'LinkProjSparks',,, HitLocation, rotator(HitNormal));
        else
            Spawn(class'LinkProjSparksYellow',,, HitLocation, rotator(HitNormal));
*/    
    }
    
            
    PlaySound(Sound'WeaponSounds.BioRifle.BioRifleGoo2');
    Destroy();
}



defaultproperties
{
     Speed=2500.000000
     MaxSpeed=5000.000000
     Damage=50.000000
     DamageRadius=100.000000
     MyDamageType=Class'LinkVehiclesOmni.DamTypeLink3SecondaryPlasma'
     LifeSpan=4.000000
     Skins(0)=FinalBlend'LinkTank3Tex.VampireTank.LinkProjPurpleFB'
     bDynamicLight=False
}
