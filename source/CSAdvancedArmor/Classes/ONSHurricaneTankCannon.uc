//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSHurricaneTankCannon extends ONSWeapon;

var vector OldDir;
var rotator OldRot;
var class<Projectile> TeamProjectileClasses[2];
var float MinAim;
var float MaxLockRange, LockAim;
var FX_ArmorRunningLight AttenRunningLight;




simulated function Destroyed()
{

    if(AttenRunningLight!=none)
       AttenRunningLight.Destroy();

	super.Destroyed();
}
function byte BestMode()
{
	if ( Vehicle(Instigator.Controller.Enemy) != None
	     && (Instigator.Controller.Enemy.bCanFly || Instigator.Controller.Enemy.IsA('ONSHoverCraft')) && FRand() < 0.75 )
		return 1;
	else
		return 0;
}

simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
	if (bIsRepeatingFF)
	{
		if (bIsAltFire)
			StopForceFeedback( AltFireForce );
		else
			StopForceFeedback( FireForce );
	}

	if (Role < ROLE_Authority && AmbientEffectEmitter != None)
		AmbientEffectEmitter.SetEmitterStatus(false);
     if (bIsAltFire)
			DualFireOffset = 85;
		else
		DualFireOffset = 00.0;


}

//ClientStartFire() and ClientStopFire() are only called for the client that owns the weapon (and not at all for bots)
simulated function ClientStartFire(Controller C, bool bAltFire)
{
    bIsAltFire = bAltFire;

	if (FireCountdown <= 0)
	{
	     if (bIsAltFire)
			DualFireOffset = 85;
		else
		 {
		  DualFireOffset = 00.0;
          PlayAnim('Fire');
         }
		if (bIsRepeatingFF)
		{
			if (bIsAltFire)

				ClientPlayForceFeedback( AltFireForce );
			else
				ClientPlayForceFeedback( FireForce );
		}
		OwnerEffects();
	}
}

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;

	if (FireCountdown <= 0)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (bAltFire)
		{
			FireCountdown = AltFireInterval;
			AltFire(C);
		}
		else
		{
		        DualFireOffset=00.0;
		       	FireCountdown = FireInterval;
		       	Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	OldDir = Vector(CurrentAim);
}

function Tick(float Delta)
{
 local int i;
	local xPawn P;
	local vector NewDir, PawnDir;
    local coords WeaponBoneCoords;


    Super.Tick(Delta);

	if ( (Role == ROLE_Authority) && (Base != None) )
	{
     WeaponBoneCoords = GetBoneCoords(YawBone);
		NewDir = WeaponBoneCoords.XAxis;
		if ( (Vehicle(Base).Controller != None) && (NewDir.Z < 0.9) )
		{
			for ( i=0; i<Base.Attached.Length; i++ )
			{
				P = XPawn(Base.Attached[i]);
				if ( (P != None) && (P.Physics != PHYS_None) && (P != Vehicle(Base).Driver) )
				{
					PawnDir = P.Location - WeaponBoneCoords.Origin;
					PawnDir.Z = 0;
					PawnDir = Normal(PawnDir);
					if ( ((PawnDir.X <= NewDir.X) && (PawnDir.X > OldDir.X))
						|| ((PawnDir.X >= NewDir.X) && (PawnDir.X < OldDir.X)) )
					{
						if ( ((PawnDir.Y <= NewDir.Y) && (PawnDir.Y > OldDir.Y))
							|| ((PawnDir.Y >= NewDir.Y) && (PawnDir.X < OldDir.Y)) )
						{
							P.SetPhysics(PHYS_Falling);
							P.Velocity = WeaponBoneCoords.YAxis;
							if ( ((NewDir - OldDir) Dot WeaponBoneCoords.YAxis) < 0 )
								P.Velocity *= -1;
							P.Velocity = 500 * (P.Velocity + 0.3*NewDir);
							P.Velocity.Z = 200;
						}
					}
				}
			}
		}
		OldDir = NewDir;
		if (AttenRunningLight==none)
          {

		  AttenRunningLight = Spawn(class'FX_ArmorRunningLight',self,,Location);
		  if( !AttachToBone(AttenRunningLight,'AttnLight') )
		    {
			 log( "Couldn't attach AttenRunningLight to AttnLight", 'Error' );
			 AttenRunningLight.Destroy();
			 return;
		    }

         }
       if (Vehicle(Base).Controller!=none)
          {
           if (Vehicle(Base).Controller.PlayerReplicationInfo.Team.TeamIndex==1)
               {
               if(AttenRunningLight.Team!=1)
                 {
                  AttenRunningLight.SetBlueColor();
                  AttenRunningLight.Team=1;
                 }
               }
           if (Vehicle(Base).Controller.PlayerReplicationInfo.Team.TeamIndex==0)
              {
               if(AttenRunningLight.Team!=0)
                 {
                  AttenRunningLight.SetRedColor();
                  AttenRunningLight.Team=0;
                 }
               }
           }
	}

}
state ProjectileFireMode
{
	function Fire(Controller C)
	{
	    DualFireOffset=00.0;
		if (Vehicle(Owner) != None && Vehicle(Owner).Team < 2)
			ProjectileClass = TeamProjectileClasses[Vehicle(Owner).Team];
		else
			ProjectileClass = TeamProjectileClasses[0];
         Super.Fire(C);
	}
function AltFire(Controller C)
	{
		local PROJ_TankRocket M;
		local float BestAim, BestDist;

		M = PROJ_TankRocket(SpawnProjectile(AltFireProjectileClass, False));
		if (M != None)
		{
			if (AIController(C) != None)
			    {
			     M.HomingTarget = C.Enemy;
				 M.SetHomingTarget();
		        }
			else
			   {
				BestAim = LockAim;
				M.HomingTarget = C.PickTarget(BestAim, BestDist, vector(WeaponFireRotation), WeaponFireLocation, MaxLockRange);
  		        M.SetHomingTarget();
               }
        }
	}
}

defaultproperties
{
     TeamProjectileClasses(0)=Class'CSAdvancedArmor.Proj_TankShellRed'
     TeamProjectileClasses(1)=Class'CSAdvancedArmor.Proj_TankShellBlue'
     MinAim=0.900000
     MaxLockRange=15000 //30000.000000
     LockAim=0.975000
     YawBone="Object01"
     PitchBone="Object02"
     PitchUpLimit=6000
     PitchDownLimit=63700
     WeaponFireAttachmentBone="Firepoint"
     WeaponFireOffset=200.000000
     DualFireOffset=95.000000
     RotationsPerSecond=0.180000
     FireInterval=1.800000
     AltFireInterval=0.500000
     EffectEmitterClass=Class'Onslaught.ONSTankFireEffect'
     FireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankFire01'
     FireSoundVolume=512.000000
     AltFireSoundClass=SoundGroup'WeaponSounds.RocketLauncher.RocketLauncherFire'
     FireForce="Explosion05"
     AltFireForce="PRVSideAltFire"
     ProjectileClass=Class'Onslaught.ONSRocketProjectile'
     AltFireProjectileClass=Class'CSAdvancedArmor.PROJ_TankRocket'
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.500000)
     AIInfo(1)=(bLeadTarget=True,RefireRate=0.500000)
     Mesh=SkeletalMesh'AdvancedArmor_anim.HurricaneTurret'
     DrawScale=0.700000
}
