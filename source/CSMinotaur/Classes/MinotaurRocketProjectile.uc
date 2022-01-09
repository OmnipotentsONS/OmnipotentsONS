class MinotaurRocketProjectile extends Projectile;

#exec OBJ LOAD FILE=..\Sounds\VMVehicleSounds-S.uax

var Emitter SmokeTrailEffect;
var bool bHitWater;
var Effects Corona;
var vector Dir;

simulated function Destroyed()
{
	if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer)
	{
        SmokeTrailEffect = Spawn(class'MinotaurRoundTrailEffect',self);
		Corona = Spawn(class'RocketCorona',self);
	}

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	if (PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity=0.6*Velocity;
	}
    if ( Level.bDropDetail )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	Super.PostBeginPlay();
}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
		Explode(HitLocation,Vect(0,0,1));
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	PlaySound(sound'WeaponSounds.BExplosion3',,5.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'MinotaurHitRockEffect',,,HitLocation + HitNormal*16, rotator(HitNormal) + rot(-16384,0,0));
		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}

simulated function HurtRadius(float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation)
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if (bHurtEntry)
		return;

	bHurtEntry = true;

	foreach VisibleCollidingActors(class 'Actor', Victims, DamageRadius, HitLocation)
	{
		if(Victims != self && Hurtwall != Victims && Victims.Role == ROLE_Authority && !Victims.IsA('FluidSurfaceInfo'))
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1, VSize(dir));
			dir = dir / dist;

			damageScale = 1 - FMax(0, (dist - Victims.CollisionRadius) / DamageRadius);

			if (Instigator == None || Instigator.Controller == None)
				Victims.SetDelayedDamageInstigatorController(InstigatorController);
			if (Victims == LastTouched)
				LastTouched = None;

			Victims.TakeDamage(damageScale * DamageAmount, Instigator,
						Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
						(damageScale * Momentum * dir), DamageType);

			if (Pawn(Victims) != none && Pawn(Victims).Health > 0 && PlayerController(Pawn(Victims).Controller) != none)
			{
				PlayerController(Pawn(Victims).Controller).StopViewShaking();
				PlayerController(Pawn(Victims).Controller).DamageShake(50);
			}

			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);

		}
	}

	if (LastTouched != None && LastTouched != self && LastTouched.Role == ROLE_Authority && !LastTouched.IsA('FluidSurfaceInfo'))
	{
		Victims = LastTouched;
		LastTouched = None;

		dir = Victims.Location - HitLocation;
		dist = FMax(1, VSize(dir));
		dir = dir / dist;

		damageScale = FMax(Victims.CollisionRadius / (Victims.CollisionRadius + Victims.CollisionHeight),
					1 - FMax(0, (dist - Victims.CollisionRadius) / DamageRadius));

		if (Instigator == None || Instigator.Controller == None)
			Victims.SetDelayedDamageInstigatorController(InstigatorController);

		Victims.TakeDamage(damageScale * DamageAmount, Instigator,
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(damageScale * Momentum * dir), DamageType);

		if (Pawn(Victims) != none && Pawn(Victims).Health > 0 && PlayerController(Pawn(Victims).Controller) != none)
		{
			PlayerController(Pawn(Victims).Controller).StopViewShaking();
			PlayerController(Pawn(Victims).Controller).DamageShake(50);
		}

		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
	}

	bHurtEntry = false;
}

defaultproperties
{
     Speed=19000.000000
     MaxSpeed=19000.000000
     Damage=335.000000
     DamageRadius=2000.000000
     MomentumTransfer=600000.000000
     MyDamageType=Class'CSMinotaur.MinotaurKill'
     ExplosionDecal=Class'CSMinotaur.MinotaurRocketScorch'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RocketProj'
     AmbientSound=Sound'VMVehicleSounds-S.HoverTank.IncomingShell'
     LifeSpan=1.500000
     AmbientGlow=250
     FluidSurfaceShootStrengthMod=10.000000
     bFullVolume=True
     SoundVolume=255
     SoundRadius=2000.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=1000.000000
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
