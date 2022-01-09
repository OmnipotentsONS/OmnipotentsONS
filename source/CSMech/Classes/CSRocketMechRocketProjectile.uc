
class CSRocketMechRocketProjectile extends Projectile;

var bool bRing,bHitWater,bWaterStart;
var int NumExtraRockets;
var	xEmitter SmokeTrail;
var Effects Corona;
var byte FlockIndex;
var CSRocketMechRocketProjectile Flock[2];

var() float	FlockRadius;
var() float	FlockStiffness;
var() float FlockMaxForce;
var() float	FlockCurlForce;
var bool bCurl;
var vector Dir;

replication
{
    reliable if ( bNetInitial && (Role == ROLE_Authority) )
        FlockIndex, bCurl;
}

simulated function Destroyed()
{
	if ( SmokeTrail != None )
		SmokeTrail.mRegen = False;
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'CSRocketMechRocketSmoke',self);
		Corona = Spawn(class'CSRocketMechRocketCorona',self);
        Corona.SetBase(self);
        Corona.SetRelativeLocation(vect(-100,0,0));
	}

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	if (PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity=0.6*Velocity;
	}
	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	local CSRocketMechRocketProjectile R;
	local int i;
	local PlayerController PC;

	Super.PostNetBeginPlay();

	if ( FlockIndex != 0 )
	{
	    SetTimer(0.1, true);

	    // look for other rockets
	    if ( Flock[1] == None )
	    {
			ForEach DynamicActors(class'CSRocketMechRocketProjectile',R)
				if ( R.FlockIndex == FlockIndex )
				{
					Flock[i] = R;
					if ( R.Flock[0] == None )
						R.Flock[0] = self;
					else if ( R.Flock[0] != self )
						R.Flock[1] = self;
					i++;
					if ( i == 2 )
						break;
				}
		}
	}
    if ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	else
	{
		PC = Level.GetLocalPlayerController();
		if ( (Instigator != None) && (PC == Instigator.Controller) )
			return;
		if ( (PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 3000) )
		{
			bDynamicLight = false;
			LightType = LT_None;
		}
	}
}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
		Explode(HitLocation, vector(rotation)*-1 );
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local rotator rot;
	local int i;
	local CSRocketMechShroomCloud cloud;

	PlaySound(sound'ONSVehicleSounds-S.Explosion06',,2.5*TransientSoundVolume,,1400);
    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'CSRocketMechRocketExplosion',,,HitLocation + HitNormal*20,rotator(HitNormal));

        for(i=0; i<8; i++)
        {
            cloud=none;
            rot.yaw=(8187)*i;
            cloud=Spawn(class'CSMech.CSRocketMechShroomCloud',,,location+vector(rot)*142, Rot);
            cloud.Velocity=vect(0,0,1)*260*1.5;
        }

        Spawn(class'CSRocketMechHitRockEffect',,,HitLocation + HitNormal*16, rotator(HitNormal) + rot(-16384,0,0));
		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}

simulated function Timer()
{
    local vector ForceDir, CurlDir;
    local float ForceMag;
    local int i;

	Velocity =  Default.Speed * Normal(Dir * 0.5 * Default.Speed + Velocity);

	// Work out force between flock to add madness
	for(i=0; i<2; i++)
	{
		if(Flock[i] == None)
			continue;

		// Attract if distance between rockets is over 2*FlockRadius, repulse if below.
		ForceDir = Flock[i].Location - Location;
		ForceMag = FlockStiffness * ( (2 * FlockRadius) - VSize(ForceDir) );
		Acceleration = Normal(ForceDir) * Min(ForceMag, FlockMaxForce);

		// Vector 'curl'
		CurlDir = Flock[i].Velocity Cross ForceDir;
		if ( bCurl == Flock[i].bCurl )
			Acceleration += Normal(CurlDir) * FlockCurlForce;
		else
			Acceleration -= Normal(CurlDir) * FlockCurlForce;
	}
}

defaultproperties
{
    /*
    DrawScale=1.0
    speed=1350.0
    MaxSpeed=1350.0
    Damage=90.0
    DamageRadius=220.0
    MomentumTransfer=50000
    */
    DrawScale=4.0
    speed=6000.0
    MaxSpeed=6000.0
    Damage=360.0
    DamageRadius=800.0
    MomentumTransfer=200000

    MyDamageType=class'CSRocketMechDamTypeRocket'
    ExplosionDecal=class'CSRocketMechRocketMark'
    RemoteRole=ROLE_SimulatedProxy
    LifeSpan=8.0
    AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
    SoundVolume=255
    SoundRadius=100
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'WeaponStaticMesh.RocketProj'
    AmbientGlow=96
    bUnlit=True
    LightType=LT_Steady
    LightEffect=LE_QuadraticNonIncidence
    LightBrightness=255
    LightHue=28
    LightRadius=5
    bDynamicLight=true
    bBounce=false
    bFixedRotationDir=True
    RotationRate=(Roll=50000)
    DesiredRotation=(Roll=30000)
    ForceType=FT_Constant
    ForceScale=5.0
    ForceRadius=100.0
    bCollideWorld=true
    FluidSurfaceShootStrengthMod=10.0

    /*
    FlockRadius=12
    FlockStiffness=-40
    FlockMaxForce=600
    FlockCurlForce=450
    */

    FlockRadius=24
    FlockStiffness=-40
    FlockMaxForce=600
    FlockCurlForce=450

    CullDistance=+15000.0
}
