//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Proj_MissileRocketProj extends Projectile;

#exec OBJ LOAD FILE=..\Sounds\VMVehicleSounds-S.uax

// FX
var Emitter			TrailEmitter;
var class<Emitter>	TrailClass;


var Effects Corona;
var int NumExtraRockets;

var byte FlockIndex;
var Proj_MissileRocketProj Flock[8];

var() float	FlockRadius;
var() float	FlockStiffness;
var() float FlockMaxForce;
var() float	FlockCurlForce;
var bool bCurl;
var vector Dir;
var	Actor		CurrentTarget;
var float			HomingAggressivity;
var	float			HomingCheckFrequency, HomingCheckCount;
var sound  	IgniteSound;
var sound 	FlightSound;
replication
{
    reliable if ( bNetInitial && (Role == ROLE_Authority) )
        FlockIndex, bCurl;

	reliable if (bNetDirty && Role == ROLE_Authority)
		CurrentTarget;
}


simulated function Destroyed()
{
     if ( TrailEmitter != None )
		TrailEmitter.Destroy();

	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
   	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	local Proj_MissileRocketProj R;
	local int i;

	Super.PostNetBeginPlay();

	Dir = Vector(Rotation);
    // Add Instigator's velocity to projectile
	if ( Instigator != None )
	{
		Speed		= Instigator.Velocity Dot Dir;
		Velocity	= Speed * Dir + (Vect(0,0,-1)>>Instigator.Rotation) * 100.f;
	}

	if ( FlockIndex != 0 )
	{
	    SetTimer(0.1, true);

	    // look for other rockets
	    if ( Flock[1] == None )
	    {
			foreach DynamicActors(class'Proj_MissileRocketProj',R)
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
	 else
	   SetTimer(0.33, false);


}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{


	 if (Pawn(Other) != None)
	{
		if (Other == Owner)
			return;
	}
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
	local PlayerController PC;

	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'NewExplosionA',,,HitLocation + HitNormal*20,rotator(HitNormal));
    	PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation + HitNormal*20, rotator(HitNormal));
//		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
//			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}

simulated function Timer()
{
    local vector ForceDir, CurlDir;
    local float ForceMag;
    local int i;
     SpawnTrail();



	 Velocity = Speed * Dir;
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

	if (CurrentTarget!=none)
	    gotoState('Homing');
	else
        gotoState('Flying');

}

simulated function SpawnTrail()
{
   local PlayerController PC;
    if (TrailEmitter!=none)
       return;
       SetCollision(true,true);

if ( Level.NetMode != NM_DedicatedServer)
	{
	 Corona = Spawn(class'RocketCorona',self);
     TrailEmitter = Spawn(TrailClass,,, Location, Rotation);

    if ( TrailEmitter == None )
        return;

	TrailEmitter.SetBase( Self );

         if ( EffectIsRelevant(location,false) )
		    {
			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && (VSize(PC.ViewTarget.Location - Location) < 3000) )
				Spawn(class'ONSDualMissileIgnite',,,location,rotation);
            }
         PlaySound(IgniteSound, SLOT_Misc, 255, true, 512);
		AmbientSound = FlightSound;
      }
}

state Flying
{
    simulated function Timer()
   {
    local vector ForceDir, CurlDir;
    local float ForceMag;
    local int i;
    ///Velocity = vector(Rotation) * MaxSpeed;
	//Velocity =  Default.Speed * Normal(Dir * 0.5 * Default.Speed + Velocity);
     Velocity = Speed * Dir;
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


	simulated function Tick(float DeltaTime)
	{
		// Increase Speed progressively
		Speed		+= 2000.f * DeltaTime;
		Acceleration = vector(Rotation) * Speed;
	}

	simulated function Landed( vector HitNormal )
	{
		Explode(Location,HitNormal);
	}


	function BlowUp(vector HitLocation)
	{
		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, Location );
		MakeNoise(1.0);
	}
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
     {
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
		Explode(HitLocation, vector(rotation)*-1 );
     }
}

state Homing
{
	simulated function Tick(float DeltaTime)
	{

		// Increase Speed progressively
		Speed		+= 1000.f * DeltaTime;
		Acceleration = vector(Rotation) * Speed;
	}
    simulated function Timer()
	{
	    local vector ForceDir;
	    local float VelMag;

	    if ( Dir == vect(0,0,0) )
	        Dir = Normal(Velocity);

		Acceleration = vect(0,0,0);
	    Super.Timer();
	    if (CurrentTarget!=none)
	    	// do normal guidance to target.
		ForceDir = Normal(CurrentTarget.Location - Location);
		if( (ForceDir dot Dir) > 0 )
		{
			VelMag = VSize(Velocity);

			// track vehicles better
			ForceDir = Normal(ForceDir * 0.5 * VelMag + Velocity);
			Velocity =  VelMag * ForceDir;
			Acceleration += 5 * ForceDir;
		}
		// Update rocket so it faces in the direction its going.
		SetRotation(rotator(Velocity));
	}

	simulated function BeginState()
	{
	    SetTimer(0.1, true);
	}
	simulated function Landed( vector HitNormal )
	{
		Explode(Location,HitNormal);
	}


	function BlowUp(vector HitLocation)
	{
		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, Location );
		MakeNoise(1.0);
	}
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
     {
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
		Explode(HitLocation, vector(rotation)*-1 );
     }
}

defaultproperties
{
     TrailClass=Class'OnslaughtBP.ONSDualMissileSmokeTrail'
     FlockRadius=98.000000
     FlockStiffness=-5.000000
     FlockMaxForce=1000.000000
     FlockCurlForce=2000.000000
     HomingAggressivity=0.250000
     HomingCheckFrequency=0.067000
     IgniteSound=Sound'CicadaSnds.Missile.MissileIgnite'
     FlightSound=Sound'CicadaSnds.Missile.MissileFlight'
     Speed=2000.000000
     MaxSpeed=5500.000000
     Damage=125.000000
     DamageRadius=250.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'CSAPVerIV.DamType_Rocket'
     ExplosionDecal=Class'Onslaught.ONSRocketScorch'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMWeaponsSM.AVRiLGroup.AVRiLprojectileSM'
     AmbientSound=Sound'VMVehicleSounds-S.HoverTank.IncomingShell'
     LifeSpan=5.000000
     DrawScale=0.140000
     AmbientGlow=96
     FluidSurfaceShootStrengthMod=10.000000
     SoundVolume=255
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
