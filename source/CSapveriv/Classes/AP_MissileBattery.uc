class AP_MissileBattery extends AP_AutoTurret
      placeable;

#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax

var (BOTMissileTurret)bool bSeeker;
var vector MSpawnOffsetA,MSpawnOffsetB;
var vector MSpawnOffsetC,MSpawnOffsetD;
var bool bMA,bMB,bMC,bMD;


simulated function postBeginPlay()
{
  bMA=true;
 Super.PostBeginPlay();
}

function Fire()
{
 local vector RotX, RotY, RotZ;
 local Projectile P;

  FireCountDown = 0.0;
  super.Fire();

 if (NewEnemy == None)
     return;

	// Client can't do firing
	if(Role != ROLE_Authority)
		return;

   //if (DesiredRotation.Pitch < -20000) Return;
	// Fire as many rockets as we have time to.
	while(FireCountDown <= 0)
	{
	 GetAxes(Rotation, RotX, RotY, RotZ);
	 GetFireoffset();
     WeaponFireLocation = Location + (FireOffset >> AimDir);
     P = spawn(ProjectileClass, self, , WeaponFireLocation,AimDir);
	 if(NewEnemy.IsA('Vehicle'))
	 PROJ_RLMissile(P).HomingTarget= Vehicle(NewEnemy);
     PlaySound(Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01', SLOT_None,,,,, false);
     //DoFireEffect();
     FireCountDown+= FireInterval;
    }
}

simulated function GetFireoffset()
{
  if(bMA==true)
	{
     FireOffset = MSpawnOffsetA;
     bMA=False;
     bMB=true;
     return;
    }
  if(bMB==true)
	{
     FireOffset = MSpawnOffsetB;
     bMB=False;
     bMC=true;
     return;
    }
  if(bMC==true)
	{
     FireOffset = MSpawnOffsetC;
     bMC=False;
     bMD=true;
     return;
    }
  if(bMD==true)
	{
     FireOffset = MSpawnOffsetD;
     bMD=False;
     bMA=true;
     return;
    }
}

simulated function GetViewAxes( out vector xaxis, out vector yaxis, out vector zaxis )
{
   GetAxes( Rotation, xaxis, yaxis, zaxis );
}

defaultproperties
{
     MSpawnOffsetA=(X=500.000000,Y=80.000000,Z=40.000000)
     MSpawnOffsetB=(X=500.000000,Y=-80.000000,Z=40.000000)
     MSpawnOffsetC=(X=500.000000,Y=80.000000,Z=18.000000)
     MSpawnOffsetD=(X=500.000000,Y=80.000000,Z=18.000000)
     FireInterval=1.500000
     Range=8500.000000
     TargettingLatency=0.000000
     ProjectileClass=Class'CSAPVerIV.PROJ_RLMissile'
     Health=350
     ExplosionEffectClass=Class'UT2k4Assault.FX_SpaceFighter_Explosion'
     TraceRange=19000.000000
     Momentum=70000.000000
     DamageAtten=1.000000
     TurretBaseClass=Class'CSAPVerIV.AP_MissileBatteryBase'
     BaseOffset=(Z=-90.000000)
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'APVerIV_Anim.MissileBatteryMesh'
     CollisionRadius=128.000000
     CollisionHeight=90.000000
     bDirectional=True
}
