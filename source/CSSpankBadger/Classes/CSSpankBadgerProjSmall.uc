class CSSpankBadgerProjSmall extends Projectile;

#exec AUDIO IMPORT FILE=Sounds\smallpop.wav

var int PawnMomentumTransfer;
var CSSpankBadgerProjectileEffectSmall ONSShockBallEffect;
var() Sound ComboSound;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
	{
        ONSShockBallEffect = Spawn(class'CSSpankBadgerProjectileEffectSmall', self);
        ONSShockBallEffect.SetBase(self);
	}

    if(Role == ROLE_Authority)
    {
        Velocity = Speed * Vector(Rotation); 
        RandSpin(900000);
    }
}

simulated function Destroyed()
{
    if (ONSShockBallEffect != None)
    {
		if ( bNoFX )
			ONSShockBallEffect.Destroy();
		else
			ONSShockBallEffect.Kill();
	}

	Super.Destroyed();
}

simulated function DestroyTrails()
{
    if (ONSShockBallEffect != None)
        ONSShockBallEffect.Destroy();
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
    Explode(Location + ExploWallOut * HitNormal, HitNormal);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( Other != Instigator )
		Explode(HitLocation,Normal(HitLocation-Other.Location));
}

simulated function Landed( vector HitNormal )
{
	HitWall(HitNormal, None);
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
    SuperExplosion();
}

simulated function SuperExplosion()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, Location );

	Spawn(class'CSSpankBadger.CSSpankBadgerProjectileExplosionSmall');
	if ( (Level.NetMode != NM_DedicatedServer) && EffectIsRelevant(Location,false) )
	{
		HitActor = Trace(HitLocation, HitNormal,Location - Vect(0,0,120), Location,false);
		if ( HitActor != None )
			Spawn(class'ComboDecal',self,,HitLocation, rotator(vect(0,0,-1)));
	}
	PlaySound(ComboSound, SLOT_None,1.0,,800);
    DestroyTrails();
    Destroy();
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float dist, damageScale;
	local vector dir;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;

            Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				vect(0,0,0),
				DamageType
			);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, 0, HitLocation);                

            dir.Z = Abs(dir.Z);
            if(XPawn(Victims) != None)
            {
                XPawn(Victims).SetPhysics(PHYS_Falling);
                XPawn(Victims).AddVelocity(Normal(dir)*PawnMomentumTransfer);
            }
            else
            {
                Victims.KAddImpulse(Normal(dir)*MomentumTransfer, HitLocation);
            }
		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;

        Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
			vect(0,0,0),
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, 0, HitLocation);

        dir.Z = Abs(dir.Z);
        if(XPawn(Victims) != None)
        {
            XPawn(Victims).SetPhysics(PHYS_Falling);
            XPawn(Victims).AddVelocity(Normal(dir)*PawnMomentumTransfer);
        }
        else
        {
            Victims.KAddImpulse(Normal(dir)*MomentumTransfer, HitLocation);
        }
	}

	bHurtEntry = false;
}

simulated function BlowUp(vector HitLocation)
{
	DelayedHurtRadius(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

defaultproperties
{
    bSwitchToZeroCollision=true
    bBlockZeroExtentTraces=true
    bBlockNonZeroExtentTraces=true
    bCollideWorld=true

    Physics=PHYS_Projectile
    bBounce=false
    Speed=15000.0
    MaxSpeed=15000.0
    Damage=55
    MomentumTransfer=60000
    PawnMomentumTransfer=10000
    TossZ=0.0
	DamageRadius=280.0
    ComboSound=sound'CSSpankBadger.smallpop'
    AmbientSound=sound'ONSBPSounds.ShockTank.ShockBallAmbient'    
    DesiredRotation=(Pitch=9000000,Yaw=9000000,Roll=9000000)
    CollisionRadius=60.0
	CollisionHeight=40.0
    bFixedRotationDir=true
    Skins(0)=None
    Texture=None
    MyDamageType=Class'CSSpankBadger.CSSpankBadgerDamTypeProjSmall'
    AmbientGlow=255
    FluidSurfaceShootStrengthMod=3.00000    
    DrawType=DT_None
    Lifespan=5.0
}