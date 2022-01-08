class FX_LaserShockExplosion extends Actor;

#exec OBJ LOAD FILE=XEffectMat.utx

var ShockComboFlare Flare;
var() sound LaserShockSound;
var() float LaserShockDamage;
var() float LaserShockRadius;
var() float LaserShockMomentumTransfer;

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        Spawn(class'ShockComboExpRing');
        Flare = Spawn(class'ShockComboFlare');
        //Spawn(class'ShockComboSphere');
        Spawn(class'ShockComboCore');
        Spawn(class'ShockComboSphereDark');
        Spawn(class'ShockComboVortex');
        Spawn(class'ShockComboWiggles');
        Spawn(class'ShockComboFlash');
         SuperExplosion();
    }
}

auto simulated state Combo
{
Begin:
    Sleep(0.9);
    //Spawn(class'ShockAltExplosion');
    if ( Flare != None )
    {
		Flare.mStartParticles = 2;
		Flare.mRegenRange[0] = 0.0;
		Flare.mRegenRange[1] = 0.0;
		Flare.mLifeRange[0] = 0.3;
		Flare.mLifeRange[1] = 0.3;
		Flare.mSizeRange[0] = 150;
		Flare.mSizeRange[1] = 150;
		Flare.mGrowthRate = -500;
		Flare.mAttenKa = 0.9;
	}
    LightType = LT_None;
}
function SuperExplosion()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HurtRadius(LaserShockDamage, LaserShockRadius, class'DamType_LaserBeam', LaserShockMomentumTransfer, Location );

	if ( (Level.NetMode != NM_DedicatedServer) && EffectIsRelevant(Location,false) )
	{
		HitActor = Trace(HitLocation, HitNormal,Location - Vect(0,0,120), Location,false);
		if ( HitActor != None )
			Spawn(class'ComboDecal',self,,HitLocation, rotator(vect(0,0,-1)));
	}
	PlaySound(LaserShockSound, SLOT_None,1.0,,800);

}

defaultproperties
{
     LaserShockSound=Sound'WeaponSounds.ShockRifle.ShockComboFire'
     LaserShockDamage=200.000000
     LaserShockRadius=575.000000
     LaserShockMomentumTransfer=150000.000000
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=195
     LightSaturation=100
     LightBrightness=255.000000
     LightRadius=10.000000
     DrawType=DT_None
     bDynamicLight=True
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     bCollideActors=True
     ForceType=FT_Constant
     ForceRadius=300.000000
     ForceScale=-500.000000
}
