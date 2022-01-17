class FireballIncendiary extends Projectile;

var bool		bHitWater, bWaterStart;
var vector		Dir;

var Emitter			TrailEmitter;
var class<Emitter>	TrailClass;
var Emitter SmokeTrailEffect;
var Effects Corona;
var Actor HomingTarget;
var vector			InitialDir;
var float AccelRate;
var xEmitter Flame;
var() class<xEmitter> FlameClass;
var() class<DamageType> DamageType, BurnDamageType;
var bool bDoTouch;

replication
{
	reliable if (bNetInitial && Role==ROLE_Authority)
		HomingTarget;
}

simulated function Destroyed()
{
	if ( TrailEmitter != None )
		TrailEmitter.Destroy();
    if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	Acceleration = Normal(Velocity) * AccelRate;
if (Level.NetMode != NM_DedicatedServer)
	{
		TrailEmitter = Spawn(TrailClass, self,, Location - 1 * InitialDir);
		TrailEmitter.SetBase(self);
	}
 if (Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrailEffect = Spawn(class'FireballStream',self);
	}

}

// this was updated by pooty, per snarf's suggestions on the forum to get rid of the timer calls.

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
    local Pawn P;
  //local float VelMag;
	//local vector ForceDir;
	
	local Burner Inv;
	
    if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
    {
        P = Pawn(Other);
        If(P != None && P != class'ONSPowerCore'&& P.Controller != None)
        {
            if(P.Health > 0 && (!Level.Game.bTeamGame || !P.Controller.SameTeamAs(InstigatorController)))
            {
                P.CreateInventory("FireVehiclesV2Omni.Burner");
                Inv = Burner(P.FindInventoryType(class'FireVehiclesV2Omni.Burner'));

                if(Inv != None)
                {
                    Inv.DamageType = BurnDamageType;
                    Inv.Chef = Instigator;
                    Inv.DamageDealt = 0;
                    Inv.Temperature += 1.5;
                    Inv.WaitTime = 0;
                }
            }
        }

    //    Explode(HitLocation,Vect(0,0,1));
    }
    // Moved so it always explodes
    Explode(HitLocation,Vect(0,0,1));
}


//simulated function ProcessTouch (Actor Other, Vector HitLocation)
//{
//	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
//	{
//		Explode(HitLocation,Vect(0,0,1));
//	}
//}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	  local vector start;
    local rotator rot;
    local int i;
    local FireTankFire FireBLOB;

	PlaySound(sound'WeaponSounds.BExplosion5',, 2.5*TransientSoundVolume);

	if ( TrailEmitter != None )
	{
		TrailEmitter.Kill();
		TrailEmitter = None;
	}

    if ( EffectIsRelevant(Location, false) )
    {
	Spawn(class'IncendiarySmokeRing',,, HitLocation + HitNormal*3, rotator(HitNormal));
	Spawn(class'IncendiarySmokeRing',,, HitLocation + HitNormal*20, rotator(HitNormal));
	Spawn(class'IncendiarySmokeRing',,, HitLocation + HitNormal*16, rotator(HitNormal));
	Spawn(class'IncendiarySmokeRing',,, HitLocation + HitNormal*1, rotator(HitNormal));
    	Spawn(class'FireballBlowup',,, HitLocation + HitNormal*16, rotator(HitNormal));
	Spawn(class'IncendiarySmokeRing',,, HitLocation + HitNormal*10, rotator(HitNormal));
	Spawn(class'IncendiarySmokeRing',,, HitLocation + HitNormal*13, rotator(HitNormal));
	Spawn(class'IncendiarySmokeRing',,, HitLocation + HitNormal*5, rotator(HitNormal));
	Spawn(class'IncendiarySmokeRing',,, HitLocation + HitNormal*9, rotator(HitNormal));
		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }
	start = Location + 10 * HitNormal;
	if ( Role == ROLE_Authority )
	{
		HurtRadius(Damage, 220, MyDamageType, MomentumTransfer, HitLocation);	
		
		for (i=0; i<6; i++)
		{
			rot = Rotation;
			rot.yaw += FRand()*32000-16000;
			rot.pitch += FRand()*32000-16000;
			rot.roll += FRand()*32000-16000;
			FireBLOB = Spawn( class 'FireTankFire',, '', Start, rot);
		}
	}

	BlowUp( HitLocation + HitNormal * 2.f );
	Destroy();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	InitialDir = vector(Rotation);
	Velocity = InitialDir * Speed;

	if ( PhysicsVolume.bWaterVolume )
		Velocity = 0.6 * Velocity;



	SetTimer(0.1, true);
}

defaultproperties
{
     TrailClass=Class'FireVehiclesV2Omni.IncendiaryRoundTrailEffect'
     AccelRate=1500.000000
     BurnDamageType=Class'FireVehiclesV2Omni.Burned'
     Speed=17000.000000
     MaxSpeed=17000.000000
     Damage=285.000000
     DamageRadius=1001.000000
     MomentumTransfer=1000.000000
     MyDamageType=Class'FireVehiclesV2Omni.FireBall'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakChunk'
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=5.500000
     AmbientGlow=32
     SoundVolume=255
     SoundRadius=200.000000
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
