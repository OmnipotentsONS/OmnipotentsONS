//=============================================================================
// PROJ_Fighter_Missile
//  Fighter Air To Air Missile
//=============================================================================

class PROJ_Fighter_Missile extends Projectile;
#exec OBJ LOAD FILE=..\StaticMeshes\APVerIV_ST.usx
var bool		bHitWater, bWaterStart;
var vector		Dir;

// FX
var Emitter			TrailEmitter;
var class<Emitter>	TrailClass;

//Homing
var Actor			HomingTarget,NewTarget;
var vector			InitialDir;
var Proj_FighterChaff Decoy;
var float Range;
var bool bHasDecoy;
var float			HomingAggressivity;
var	float			HomingCheckFrequency, HomingCheckCount;
var bool bGroundHit;
replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		HomingTarget,NewTarget;
	reliable if (Role == ROLE_Authority)
    	 Decoy,Range,bHasDecoy;
}

simulated function Destroyed()
{
	if ( Role == Role_Authority && HomingTarget != None )
	   {
	    if (HomingTarget.IsA('Vehicle'))
		Vehicle(HomingTarget).NotifyEnemyLostLock();
       }
	if ( TrailEmitter != None )
		TrailEmitter.Destroy();

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	Dir = Vector(Rotation);

	// Add Instigator's velocity to projectile
	if ( Instigator != None )
	{
		Speed		= Instigator.Velocity Dot Dir;
		Velocity	= Speed * Dir + (Vect(0,0,-1)>>Instigator.Rotation) * 100.f;
	}

	SetTimer(0.33, false);
}
simulated function Timer()
{
	// Rockets is done falling, now it's flying
	SpawnTrail();

	Velocity = Speed * Dir;
	GotoState('Flying');
}
state Flying
{
simulated function Tick(float DeltaTime)
	{
    local float VelMag;
	local vector ForceDir;
    // Increase Speed progressively
		Speed		+= 2000.f * DeltaTime;
		Acceleration = vector(Rotation) * Speed;
    if (HomingTarget == None)
		return;

	 if (Role==Role_Authority && HomingTarget!=None)
	 {
	            if (HomingTarget.IsA('AirPower_Fighter'))
    	       {

    	         if (AirPower_Fighter(HomingTarget).Decoy!=none)
    	            {
    	             AirPower_Fighter(HomingTarget).NotifyEnemyLostLock();
					 NewTarget=AirPower_Fighter(HomingTarget).Decoy;
                     HomingTarget=NewTarget;
                    }
                }
          if (HomingTarget.IsA('Predator'))
    	     {
    	      if (Predator(HomingTarget).Decoy!=none)
    	         {
    	          Predator(HomingTarget).NotifyEnemyLostLock();
    	          NewTarget=Predator(HomingTarget).Decoy;
                  HomingTarget=NewTarget;
                 }
             }

 	  }
 	  foreach RadiusActors(class'Proj_FighterChaff', Decoy, range, Location)
            {
            // only go after one Decoy
             if(bHasDecoy!=True)
               {
                if (Decoy.IsA('Proj_FighterChaff'))
                   {
                    HomingTarget=Decoy;
                    bHasDecoy=true;
                   }
                }

            }

      ForceDir = Normal(HomingTarget.Location - Location);

	// Homing
		if ( HomingTarget != None && HomingTarget != Instigator && (default.LifeSpan-LifeSpan) > default.LifeSpan * 0.18 )
		{
			HomingCheckCount += DeltaTime;
			if ( HomingCheckCount > HomingCheckFrequency )
			{
				HomingCheckCount -= HomingCheckFrequency;

				if ( InitialDir == vect(0,0,0) )
					InitialDir = Normal(Velocity);

				ForceDir = Normal(HomingTarget.Location - Location);

				if ( (ForceDir Dot InitialDir ) > 0 )
				{
					VelMag			= VSize(Velocity);
					ForceDir		= Normal(ForceDir * HomingAggressivity * VelMag + Velocity);
					Velocity		= VelMag * ForceDir;
					Acceleration   += 5 * ForceDir;
					HomingAggressivity += HomingAggressivity * 0.03;
				}
				else if ( Role == Role_Authority && HomingTarget != None )
				{
					if(HomingTarget.IsA('Vehicle'))
                    Vehicle(HomingTarget).NotifyEnemyLostLock();
					HomingTarget = None;
				}

				// Update rocket so it faces in the direction its going.
				SetRotation( rotator(Velocity) );
			}
		}

     }
}

simulated function SpawnTrail()
{
	if ( Level.NetMode == NM_DedicatedServer || Instigator == None )
		return;

	TrailEmitter = Spawn(TrailClass,,, Location, Rotation);

    if ( TrailEmitter == None )
        return;

	if ( Instigator.GetTeamNum() == 0 ) // Red Team version
	{
		TrailEmitter.Emitters[0].Texture = Texture'AS_FX_TX.Trails.Trail_Red';
		TrailEmitter.Emitters[1].ColorScale[0].Color = class'Canvas'.static.MakeColor(200, 64, 64);
		TrailEmitter.Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor(200, 64, 64);
	}
	TrailEmitter.SetBase( Self );
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
	{
		//log("PROJ_SpaceFighter_Rocket::ProcessTouch Other:"@Other@"bCollideActors:"@Other.bCollideActors@"bBlockActors:"@Other.bBlockActors);
		Explode(HitLocation,Vect(0,0,1));
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(sound'WeaponSounds.BExplosion3',, 2.5*TransientSoundVolume);

	if ( TrailEmitter != None )
	{
		TrailEmitter.Kill();
		TrailEmitter = None;
	}

    if ( EffectIsRelevant(Location, false) )
    {
    	if ( bGroundHit==true )
         Spawn(class'Onslaught.ONSTankHitRockEffect',,, Location, Rotation);
        else
        Spawn(class'FX_SpaceFighter_Explosion',,, HitLocation + HitNormal*16, rotator(HitNormal));
        bDynamicLight=true;
        Spawn(class'CSAPVerIV.FX_NukeFlashFirst',,, Location, Rotation);
        Spawn(class'CSAPVerIV.FX_NukeFlash',,, Location, Rotation);
        Spawn(class'CSAPVerIV.FX_MissileHitGlow',,, Location, Rotation);

        PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation, rotator(HitNormal));

		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp( HitLocation + HitNormal * 2.f );
	Destroy();
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    if ( Wall.bWorldGeometry )
         bGroundHit=true;
         Explode(Location,HitNormal);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if (Damage > 0)
		Explode(HitLocation, vect(0,0,0));
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     TrailClass=Class'UT2k4AssaultFull.FX_SpaceFighter_Rocket_Trail'
     Range=2256.000000
     HomingAggressivity=0.250000
     HomingCheckFrequency=0.067000
     Speed=2800.000000
     MaxSpeed=20000.000000
     Damage=275.000000
     DamageRadius=512.000000
     MomentumTransfer=80000.000000
     MyDamageType=Class'CSAPVerIV.DamType_FighterMissile'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'APVerIV_ST.AP_Weapons_ST.Interceptor'
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=4.000000
     DrawScale=0.500000
     AmbientGlow=32
     SoundVolume=255
     SoundRadius=100.000000
     bProjTarget=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
