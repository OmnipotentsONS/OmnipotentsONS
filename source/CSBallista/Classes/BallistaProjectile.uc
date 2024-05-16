class BallistaProjectile extends Projectile;

#exec OBJ LOAD FILE=..\Sounds\VMVehicleSounds-S.uax

var Emitter SmokeTrailEffect;
var bool bHitWater;
var Effects Corona;
var vector Dir;
var Actor HomingTarget;
var vector InitialDir;
var float AccelRate;
var	NewRedeemerTrail SmokeTrail;

var() vector ShakeRotMag;
var() vector ShakeRotRate;
var() float  ShakeRotTime;
var() vector ShakeOffsetMag;
var() vector ShakeOffsetRate;
var() float  ShakeOffsetTime;

var class<Emitter> ExplosionEffectClass;

var byte Team;

function BeginPlay()
{
	Super.BeginPlay();

	if (Instigator != None)
		Team = Instigator.GetTeamNum();
	SetTimer(0.5, true);
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer)
	{
        SmokeTrailEffect = Spawn(class'ONSTankFireTrailEffect',self);
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

event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry )
		return true;

	return false;
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( Other != instigator )
		Explode(HitLocation,Vect(0,0,1));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp(HitLocation);
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
}

simulated function Landed( vector HitNormal )
{
	BlowUp(Location);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	BlowUp(Location);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType)
{
	if ( (Damage > 0) && ((InstigatedBy == None) || (InstigatedBy.Controller == None) || (Instigator == None) || (Instigator.Controller == None) || !InstigatedBy.Controller.SameTeamAs(Instigator.Controller)) )
	{
		if ( (InstigatedBy == None) || DamageType.Default.bVehicleHit || (DamageType == class'Crushed') )
			BlowUp(Location);
		else
		{
	 		Spawn(class'SmallRedeemerExplosion');
		  SetCollision(false,false,false);
		  HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
		  Destroy();
		}
	}
}

simulated event FellOutOfWorld(eKillZType KillType)
{
	BlowUp(Location);
}

function BlowUp(vector HitLocation)
{
	local Emitter E;

    E = Spawn(ExplosionEffectClass,,, HitLocation - 100 * Normal(Velocity), Rot(0,16384,0));
	if ( Level.NetMode == NM_DedicatedServer )
	{
		E.LifeSpan = 0.7;
	}
	MakeNoise(1.0);
	SetPhysics(PHYS_None);
	bHidden = true;
  GotoState('Dying');
}

state Dying
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType) {}
	function Timer() {}

    function BeginState()
    {
		bHidden = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		Spawn(class'IonCore',,, Location, Rotation);
		ShakeView();
		InitialState = 'Dying';
		if ( SmokeTrail != None )
			SmokeTrail.Destroy();
		SetTimer(0, false);
    }

    function ShakeView()
    {
        local Controller C;
        local PlayerController PC;
        local float Dist, Scale;

        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
            PC = PlayerController(C);
            if ( PC != None && PC.ViewTarget != None )
            {
                Dist = VSize(Location - PC.ViewTarget.Location);
                if ( Dist < DamageRadius * 2.0)
                {
                    if (Dist < DamageRadius)
                        Scale = 1.0;
                    else
                        Scale = (DamageRadius*2.0 - Dist) / (DamageRadius);
                    C.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
                }
            }
        }
    }

Begin:
    PlaySound(sound'WeaponSounds.redeemer_explosionsound');
    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.5);
    HurtRadius(Damage, DamageRadius*0.300, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.475, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.650, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.825, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);
    Destroy();
}

replication
{
	reliable if (bNetInitial && Role==ROLE_Authority)
		HomingTarget;
}

simulated function Destroyed()
{
  if (Role == ROLE_Authority && HomingTarget != None)
	  	if(HomingTarget.IsA('Vehicle')) Vehicle(HomingTarget).NotifyEnemyLostLock();
	if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}

function SetHomingTarget()
{
	if (HomingTarget != None)
	    {
	     if(HomingTarget.IsA('Vehicle')) Vehicle(HomingTarget).NotifyEnemyLostLock();
        }
	if (HomingTarget != None)
	    {
	     if(HomingTarget.IsA('Vehicle')) Vehicle(HomingTarget).NotifyEnemyLockedOn();
	    }
}

defaultproperties
{
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     ExplosionEffectClass=Class'CSBallista.BallistaExplosion'
     Team=255
     Speed=25000.000000
     MaxSpeed=27549.000000
     Damage=411.000000
     DamageRadius=2000.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'CSBallista.BallistaShell'
     ExplosionDecal=Class'Onslaught.ONSRocketScorch'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=28
     LightBrightness=255.000000
     LightRadius=6.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RocketProj'
     bDynamicLight=True
     bNetTemporary=False
     AmbientSound=Sound'VMVehicleSounds-S.HoverTank.IncomingShell'
     LifeSpan=1.200000
     AmbientGlow=96
     bUnlit=False
     FluidSurfaceShootStrengthMod=10.000000
     bFullVolume=True
     SoundVolume=255
     SoundRadius=1000.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=1000.000000
     bProjTarget=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
