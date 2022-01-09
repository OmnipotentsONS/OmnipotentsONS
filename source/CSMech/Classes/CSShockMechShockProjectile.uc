
class CSShockMechShockProjectile extends ShockProjectile;

simulated function PostBeginPlay()
{
	Super(Projectile).PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
	{
        ShockBallEffect = Spawn(class'CSShockMechShockBall', self);
        ShockBallEffect.SetBase(self);
	}

	Velocity = Speed * Vector(Rotation); // starts off slower so combo can be done closer

    SetTimer(0.4, false);
    tempStartLoc = Location;
}

function Timer()
{
    SetCollisionSize(120, 120);
}

function SuperExplosion()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HurtRadius(ComboDamage, ComboRadius, class'DamTypeShockCombo', ComboMomentumTransfer, Location );

	Spawn(class'CSShockMechShockCombo');
	if ( (Level.NetMode != NM_DedicatedServer) && EffectIsRelevant(Location,false) )
	{
		HitActor = Trace(HitLocation, HitNormal,Location - Vect(0,0,120), Location,false);
		if ( HitActor != None )
			Spawn(class'ComboDecal',self,,HitLocation, rotator(vect(0,0,-1)));
	}
	//PlaySound(ComboSound, SLOT_None,1.0,,800);
	PlaySound(ComboSound, SLOT_None,1.0,,3200,0.8);
    DestroyTrails();
    Destroy();
}

defaultproperties
{
    /*
    Speed=1150
    MaxSpeed=1150
    Damage=45
    DamageRadius=150
    MomentumTransfer=70000
    ComboDamage=200
    ComboRadius=275
    ComboMomentumTransfer=150000
    ComboSound=Sound'WeaponSounds.ShockRifle.ShockComboFire'
    ComboDamageType=class'DamTypeShockBeam'
    MyDamageType=class'DamTypeShockBall'
    //DrawScale=0.7
    //CollisionRadius=10
    //CollisionHeight=10
    DrawScale=2.8
    CollisionRadius=40
    CollisionHeight=40
    */
    Speed=3550
    MaxSpeed=3550
    Damage=180
    DamageRadius=600
    MomentumTransfer=280000
    ComboDamage=1000
    ComboRadius=1100
    ComboMomentumTransfer=600000
    ComboSound=Sound'WeaponSounds.ShockRifle.ShockComboFire'
    ComboDamageType=class'DamTypeShockBeam'
    MyDamageType=class'CSShockMechDamTypeShockBall'
    ExplosionDecal=class'CSShockMechShockImpactScorch'

    //DrawScale=0.7
    //CollisionRadius=10
    //CollisionHeight=10
    DrawScale=2.8
    CollisionRadius=40
    CollisionHeight=40
    MaxEffectDistance=15000.0
    CullDistance=+14000.0
}