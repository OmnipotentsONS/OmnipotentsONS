//=============================================================================
// PROJ_AvrilMKII_Missile
//
//=============================================================================

class PROJ_AvrilMKII_Missile extends Projectile;
#exec OBJ LOAD FILE=..\StaticMeshes\APVerIV_ST.usx

// FX
var Emitter SmokeTrail;
var Effects Corona;

var float AccelRate;

var Actor HomingTarget,NewTarget;

var vector InitialDir;
var Proj_FighterChaff Decoy;
var float Range;
var bool bHasDecoy;
replication
{
	reliable if (bNetInitial && Role==ROLE_Authority)
		HomingTarget;
		reliable if ( Role == ROLE_Authority )
        NewTarget,bHasDecoy;
}


simulated function Destroyed()
{
	// Turn of smoke emitters. Emitter should then destroy itself when all particles fade out.
	if ( SmokeTrail != None )
		SmokeTrail.Kill();

	if ( Corona != None )
		Corona.Destroy();

	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
	if (!bNoFX && EffectIsRelevant(Location, false))
		spawn(class'ONSAVRiLRocketExplosion',,, Location, rotator(vect(0,0,1)));
	if (Instigator != None && Instigator.IsLocallyControlled() && Instigator.Weapon != None && !Instigator.Weapon.HasAmmo())
		Instigator.Weapon.DoAutoSwitch();

	if ( Role == Role_Authority && HomingTarget != None )
	   {
	    if (HomingTarget.IsA('Vehicle'))
		Vehicle(HomingTarget).NotifyEnemyLostLock();
       }
    Super.Destroyed();


}
simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	InitialDir = vector(Rotation);
	Velocity = InitialDir * Speed;

	if ( PhysicsVolume.bWaterVolume )
		Velocity = 0.6 * Velocity;
		if ( Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'ONSAvrilSmokeTrail',,,Location - 15 * InitialDir);
		SmokeTrail.Setbase(self);

		Corona = Spawn(class'RocketCorona',self);
	}
	SetTimer(0.1, true);
}
function SetHomingTarget()
{
	if (HomingTarget != None)
	    {
	     if(HomingTarget.IsA('Vehicle'))
		  Vehicle(HomingTarget).NotifyEnemyLostLock();
        }
	//HomingTarget = NewTarget;
	if (HomingTarget != None)
	    {
	     if(HomingTarget.IsA('Vehicle'))
		     Vehicle(HomingTarget).NotifyEnemyLockedOn();
	    }
}
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	Acceleration = Normal(Velocity) * AccelRate;
}

simulated function Timer()
{
	local float VelMag;
	local vector ForceDir;


	if (HomingTarget == None)
		return;
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
	if (ForceDir dot InitialDir > 0)
	{
	    	// Do normal guidance to target.
	    	VelMag = VSize(Velocity);

	    	ForceDir = Normal(ForceDir * 0.7 * VelMag + Velocity);
		Velocity =  VelMag * ForceDir;
    		Acceleration = Normal(Velocity) * AccelRate;

	    	// Update rocket so it faces in the direction its going.
		SetRotation(rotator(Velocity));
	}
	   if(HomingTarget.IsA('Vehicle'))
	   {
	 if (HomingTarget != None)
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
 	  }
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

	if ( SmokeTrail != None )
	{
		SmokeTrail.Kill();
		SmokeTrail = None;
	}

    if ( EffectIsRelevant(Location, false) )
    {
    	Spawn(class'CSAPVerIV.FX_MissileExpl',,, HitLocation + HitNormal*16, rotator(HitNormal));
    	PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation, rotator(HitNormal));

		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp( HitLocation + HitNormal * 2.f );
	Destroy();
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if (Damage > 0)
		Explode(HitLocation, vect(0,0,0));
}

defaultproperties
{
     AccelRate=2000.000000
     Range=2256.000000
     Speed=550.000000
     MaxSpeed=6000.000000
     Damage=270.000000
     DamageRadius=512.000000
     MomentumTransfer=80000.000000
     MyDamageType=Class'CSAPVerIV.DamType_FighterMissile'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'APVerIV_ST.AP_Weapons_ST.Interceptor'
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=8.000000
     DrawScale=0.800000
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
