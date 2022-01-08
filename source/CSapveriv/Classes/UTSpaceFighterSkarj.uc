//=============================================================================
// UTSpaceFighterSkarj
//=============================================================================

class UTSpaceFighterSkarj extends AirPower_Fighter config(CSAPVerIV);


simulated function SetTrailFX()
{
	local vector ThrusterLocation;
   ThrusterLocation= Location + (ThrusterOffset >> Rotation);
  	// Trail FX
	if ( Thruster==None && Health>0 && Team != 255  )
	   {
		    Thruster = Spawn(class'FX_FighterThrusters', Self,, ThrusterLocation);
            Thruster.SetBase( self );

      }
     if ( Thruster != None )
		{
		 if ( Team == 0 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==0) )	// Red version
			 Thruster.SetRedColor();
         else
          if ( Team == 1 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==1) )	// Blue version
			  Thruster.SetBlueColor();

       }
}
simulated function SetRunningLightsFX()
{
 if (LeftWingLight==none && Health>0 && Team != 255 )
          {
           LeftWingLight=spawn(Class'FX_RunningLight',Self,,Location);
           AttachToBone(LeftWingLight, 'Engine_Fins02');

		   RightWingLight=spawn(Class'FX_RunningLight',Self,,Location);
           AttachToBone(RightWingLight,'Engine_Fins03');

           BottomLight=spawn(Class'FX_RunningLight',Self,,Location);
           AttachToBone(BottomLight,'Gear_R');
          }
       if (LeftWingLight!=none)
          {
           if ( Team == 1 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==1) )	// Blue version
			   {
				LeftWingLight.SetBlueColor();
                RightWingLight.SetBlueColor();
                BottomLight.SetBlueColor();
               }
            else
               if ( Team == 0 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==0) )	// Blue version
			   {
                LeftWingLight.SetRedColor();
                RightWingLight.SetRedColor();
                BottomLight.SetRedColor();
               }
          }
}

function bool KDriverLeave( bool bForceLeave )
{
   local Controller C;
   local Pawn		OldPawn;
   local vector	EjectVel;

	OldPawn = Driver;

	if(OldPawn==None)
      super.Destroyed();

      C = Controller;
      if(C==None)
      super.Destroyed();
	  C.StopFiring();
      if ( Super.KDriverLeave(bForceLeave) || bForceLeave )
         {
    	  if (C != None)
    	     {
	       	  C.Pawn.bSetPCRotOnPossess = C.Pawn.default.bSetPCRotOnPossess;
              Instigator = C.Pawn;  //so if vehicle continues on and runs someone over, the appropriate credit is given
             }
           EjectVel	= Velocity;
           if (bReadyForTakeOff==True)
	       EjectVel.Z	= EjectVel.Z + EjectMomentum;

	       OldPawn.Velocity = EjectVel;
            return True;
          }
        else
         return False;
}

simulated function AdjustEngineFX()
{
  local vector FXAmount;
  local float CurrThrust;
  CurrThrust = FClamp( (Velocity dot Vector(Rotation)) * 1000.f / AirSpeed, 0.f, 1000.f);
      //0 to 1000
      FXAmount.X=0.003 * CurrThrust;
      FXAmount.Z=0.002 * CurrThrust;
      FXAmount.Y=1.0;
  if ( Thruster != None )
   Thruster.SetDrawScale3D(FXAmount);
}
// Special calc-view for vehicles
simulated function bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector			CamLookAt, HitLocation, HitNormal;
	local PlayerController	PC;
	local float				CamDistFactor;
	local vector			CamDistance;
	local Rotator			CamRotationRate;
	local Rotator			TargetRotation;

	PC = PlayerController(Controller);

	// Only do this mode if we have a playercontroller viewing this vehicle
	if ( PC == None || PC.ViewTarget == None )
		return false;

	ViewActor = Self;

	if ( !PC.bBehindView )	// First Person View
	{
		SpecialCalcFirstPersonView( PC, ViewActor, CameraLocation, CameraRotation);
		return true;
	}

	// 3rd person view
	myDeltaTime			= Level.TimeSeconds - LastTimeSeconds;
	LastTimeSeconds		= Level.TimeSeconds;
	CamLookAt			= ViewActor.Location + (Vect(60, 0, 0) >> ViewActor.Rotation);

	// Camera Rotation
	if ( ViewActor == Self ) // Client Hack to camera roll is not affected by strafing
		TargetRotation = GetViewRotation();
	else
		TargetRotation = ViewActor.Rotation;

	if ( IsInState('ShotDown') )		// shotdown
	{
		TargetRotation.Yaw += 56768;
		Normalize( TargetRotation );
		CamRotationInertia = default.CamRotationInertia * 10.f;
		CamDistFactor	= 1024.0;

	}
	else if ( IsInState('Dying') )	// dead
	{
		CamRotationInertia = default.CamRotationInertia * 50.f;
		CamDistFactor	= 3.0;
	}
	else
	{
		CamDistFactor	= 1 - (DesiredVelocity / AirSpeed);
	}

	CamRotationRate			= Normalize(TargetRotation - LastCamRot);
	CameraRotation.Yaw		= CalcInertia(myDeltaTime, CamRotationInertia, CamRotationRate.Yaw, LastCamRot.Yaw);
	CameraRotation.Pitch	= CalcInertia(myDeltaTime, CamRotationInertia, CamRotationRate.Pitch, LastCamRot.Pitch);
	CameraRotation.Roll		= CalcInertia(myDeltaTime, CamRotationInertia, CamRotationRate.Roll, LastCamRot.Roll);
	LastCamRot				= CameraRotation;

	// Camera Location
	CamDistance		= Vect(-700, 0, 186);
	CamDistance.X	-= CamDistFactor * 200.0;	// Adjust Camera location based on ship's velocity
	CameraLocation	= CamLookAt + (CamDistance >> CameraRotation);

	if ( Trace( HitLocation, HitNormal, CameraLocation, ViewActor.Location, false, vect(10, 10, 10) ) != None )
		CameraLocation = HitLocation + HitNormal * 10;

	return true;
}

static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );

	L.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human1_Tex' );		// Skins
	L.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human2_Tex' );

	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	L.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	L.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	L.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	L.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_blue' );				// FX
	L.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_red' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlashFlare1' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.Flares.Laser_Flare' );
	L.AddPrecacheMaterial( Material'XEffectMat.RedShell' );
	L.AddPrecacheMaterial( Material'XEffectMat.BlueShell' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.Beams.LaserTex' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlickerFlare' );
	L.AddPrecacheMaterial( Texture'XGameShaders.Trans.TransRingEnergy' );

	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	L.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.AssaultRadar' );

	L.AddPrecacheStaticMesh( StaticMesh'WeaponStaticMesh.Shield' );
	L.AddPrecacheStaticMesh( StaticMesh'AS_Vehicles_SM.Vehicles.SpaceFighter_Human_FP' );
}


simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh( StaticMesh'WeaponStaticMesh.Shield' );
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Vehicles_SM.Vehicles.SpaceFighter_Human_FP' );

	super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human1_Tex' );		// Skins
	Level.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human2_Tex' );

	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	Level.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	Level.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	Level.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_blue' );				// FX
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Trails.Trail_red' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlashFlare1' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Flares.Laser_Flare' );
	Level.AddPrecacheMaterial( Material'XEffectMat.RedShell' );
	Level.AddPrecacheMaterial( Material'XEffectMat.BlueShell' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Beams.LaserTex' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Flares.FlickerFlare' );
	Level.AddPrecacheMaterial( Texture'XGameShaders.Trans.TransRingEnergy' );

	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	Level.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.AssaultRadar' );

	super.UpdatePrecacheMaterials();
}

function Fire( optional float F )
{
    Super.Fire(F);
	if (bReadyForTakeOff==False)
    {
      DesiredVelocity = EngineMinVelocity + 260;
      Velocity = EngineMinVelocity * Vector(Rotation);
      Acceleration = Velocity;
      bLanded =false;
      bReadyForTakeOff=true;
      bGearUp=true;
      if ( LaunchSound != none )
        PlaySound(LaunchSound, SLOT_None, 2.0);
    }

}

defaultproperties
{
     VehicleRotationSpeed=0.020000
     VehiclePitchRotSpeed=0.003000
     VehicleYawRotSpeed=0.003000
     FlyingAnim="FinsOpen"
     ShotDownFXClass=Class'UT2k4AssaultFull.FX_SpaceFighter_ShotDownEmitter'
     ThrusterOffset=(X=-100.000000)
     RocketOffset=(X=-32.000000,Z=-64.000000)
     SpeedInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid'
     LandingGearsUp="TakeOff"
     LandingGearsDown="Landing"
     NumChaff=2
     LaunchSpeed=3200.000000
     FlybySound=Sound'APVerIV_Snd.SkarrjFighterFlyby'
     FlybyInterval=6.500000
     RequiredFighterEquipment(0)="CSAPVerIV.Weapon_UTSpaceFighter"
     VehicleProjSpawnOffset=(X=110.000000,Y=50.000000,Z=-64.000000)
     VehicleProjSpawnOffsetLeft=(Y=-190.000000)
     VehicleProjSpawnOffsetRight=(Y=190.000000)
     ExplosionEffectClass=Class'CSAPVerIV.FX_VehDeathUTSpaceFighterSkarj'
     IdleSound=Sound'AssaultSounds.SkaarjShip.SkShipEng01'
     StartUpSound=Sound'AssaultSounds.SkaarjShip.SkShipAccel01'
     ShutDownSound=Sound'AssaultSounds.SkaarjShip.SkShipDecel01'
     bCustomHealthDisplay=True
     ExitPositions(0)=(X=-1024.000000,Z=256.000000)
     ExitPositions(1)=(X=-1024.000000,Z=256.000000)
     ExitPositions(2)=(X=-1024.000000,Z=256.000000)
     ExitPositions(3)=(X=-1024.000000,Z=256.000000)
     FPCamPos=(X=15.000000,Z=20.000000)
     VehiclePositionString="in a Skaarjfighter"
     VehicleNameString="Skaarj Fighter"
     FlagBone="Engine_Fins02"
     FlagOffset=(Z=80.000000)
     AirSpeed=2650.000000
     AmbientSound=Sound'AssaultSounds.SkaarjShip.SkShipEng01'
     Mesh=SkeletalMesh'AS_VehiclesFull_M.SpaceFighter_Skaarj'
     DrawScale=1.200000
     SoundRadius=100.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=784.000000
     CollisionRadius=128.000000
     CollisionHeight=110.000000
     bUseCylinderCollision=True
}
