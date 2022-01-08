//=============================================================================
// Phantom
// Stealth Fighter/Bomber
// Pilot Controls Guns,Air to Air Missiles and Invisability Cloak.
//  Bombs And Redeemer Bomb.
//=============================================================================

class Phantom extends AirPower_Fighter config(CSAPVerIV);

var bool bInvis,bBotStealth,bOldInvis;
var Info_StealthTimer Info_StealthTimer;
var float StealthTime;
var Material InvisMaterial;
var Material RealSkins[4];
var float CloakTime;

replication
{
    reliable if( bNetDirty && (Role== ROLE_Authority) && bNetOwner )
		CloakTime;
	reliable if( Role==ROLE_Authority )
		bInvis,bBotStealth;
}

function Fire( optional float F )
{
	if (bReadyForTakeOff==False)
    {
      DesiredVelocity = EngineMinVelocity + 260;
      Velocity = EngineMinVelocity * Vector(Rotation);
      Acceleration = Velocity;
      bLanded =false;
      bReadyForTakeOff=true;
      bGearUp=true;
      PlayAnim('GearsUp');
     if ( LaunchSound != None )
        PlaySound(LaunchSound, SLOT_None, 2.0);
    }
}

simulated function SetTrailFX()
{
	// Trail FX
	if ( Thruster==None && Health>0 && Team != 255  )
	   {
		    Thruster = Spawn(class'FX_FighterThrusters',Self);
            AttachToBone(Thruster, 'MidEngine');
      }
     if ( Thruster != None && (Team == 0 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==0)))
		  Thruster.SetRedColor();

     if ( Thruster != None && (Team == 1 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==1)))
		  Thruster.SetBlueColor();
}

simulated function SetRunningLightsFX()
{
 if (LeftWingLight==none && Health>0 && Team != 255 )
          {
           LeftWingLight=spawn(Class'FX_RunningLight',Self,,Location);
           AttachToBone(LeftWingLight, 'LWLight');

		   RightWingLight=spawn(Class'FX_RunningLight',Self,,Location);
           AttachToBone(RightWingLight,'RWLight');

           BottomLight=spawn(Class'FX_RunningLight',Self,,Location);
           AttachToBone(BottomLight,'BLight');
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

simulated function AdjustEngineFX()
{
  local vector FXAmount;
  local float CurrThrust;
  CurrThrust = FClamp( (Velocity dot Vector(Rotation)) * 1000.f / AirSpeed, 0.f, 1000.f);
      //0 to 1000
      FXAmount.Z=0.003 * CurrThrust;
      FXAmount.Y=0.002 * CurrThrust;
      FXAmount.X=1.1;
       FXAmount.Y=1.0;
  if ( Thruster != None )
   Thruster.SetDrawScale3D(FXAmount);
}

simulated function PlayTakeOff()
{
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    if(Controller.IsA('Bot') && Health <= 260 && bBotStealth==false)
      {
       StealthMode();
       bBotStealth=True;
      }
	super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

function PossessedBy(Controller C)
{
	super.PossessedBy(C);

    if (Controller.IsA('Bot'))
       {
        AirSpeed=2800.000000;
        AccelRate=1200.000000;
        bLanded =false;
         bReadyForTakeOff=true;
         bGearUp=true;
         PlayAnim(LandingGearsUp);
       }
    else
       {
        AirSpeed=3000.000000;
        AccelRate=2000.000000;
       }
}
//=========================================
// new StealthStuff
simulated function SetInvisibility(float time)
{
    local int i,NumSkins;
    bInvis = (time > 0.0);
    if (Role == ROLE_Authority)
    {
        if (bInvis)
		{
			Visibility = 0;
			bInvisON=True;
        }
        else
        {
 		 Visibility = Default.Visibility;
         bInvisON=false;
        }
    }

    if(bInvis && !bOldInvis) // Going invisible
             {
                bStealth=true;
                // Save the 'real' non-invis skin
		        NumSkins = Clamp(Skins.Length,2,4);

		        for ( i=0; i<NumSkins; i++ )
		            {
			         RealSkins[i] = Skins[i];
			         Skins[i] = InvisMaterial;
                    }
                 if ( Thruster != None )
		               Thruster.SetInvisable();

                 //--RunningLights----------------------------
                  RightWingLight.SetInvisable();
	              LeftWingLight.SetInvisable();
	              BottomLight.SetInvisable();
               }

    else if(!bInvis && bOldInvis) // Going visible
        {
          if ( Thruster != None )
		       Thruster.SetVisable();

		      bStealth=false;
		     //Make Running Lights Visable Again
		     if ( RightWingLight != none )
                  RightWingLight.SetVisable();

             if ( LeftWingLight != none )
                  LeftWingLight.SetVisable();

             if ( BottomLight != none )
                  BottomLight.SetVisable();

	         NumSkins = Clamp(Skins.Length,2,4);

		      for ( i=0; i<NumSkins; i++ )
			       Skins[i] = RealSkins[i];
		    bOldInvis = bInvis;
           }
}

function StealthMode()
{
  CloakTime=100;
  spawn(class'CSAPVerIV.Info_StealthTimer',self);
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
	CamDistance		= Vect(-686, 0, 128);
	CamDistance.X	-= CamDistFactor * 200.0;	// Adjust Camera location based on ship's velocity
	CameraLocation	= CamLookAt + (CamDistance >> CameraRotation);

	if ( Trace( HitLocation, HitNormal, CameraLocation, ViewActor.Location, false, vect(10, 10, 10) ) != None )
		CameraLocation = HitLocation + HitNormal * 10;

	return true;
}

defaultproperties
{
     InvisMaterial=FinalBlend'APVerIV_Tex.AP_FX.WraithInvisFB'
     CloakTime=100.000000
     FlyingAnim="Flying"
     ShotDownFXClass=Class'UT2k4AssaultFull.FX_SpaceFighter_ShotDownEmitter'
     SpeedInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid'
     LandingGearsUp="GearsUp"
     LandingGearsDown="GearsDown"
     NumChaff=4
     LaunchSpeed=2600.000000
     FlybySound=Sound'APVerIV_Snd.PhantomFlyby'
     FlybyInterval=6.500000
     RequiredFighterEquipment(0)="CSAPVerIV.Weapon_PhantomGuns"
     RequiredFighterEquipment(1)="CSAPVerIV.Weapon_StealthActivator"
     VehicleProjSpawnOffsetLeft=(X=-86.000000,Y=-132.000000,Z=18.000000)
     VehicleProjSpawnOffsetRight=(X=-86.000000,Y=132.000000,Z=18.000000)
     RocketOffsetA=(X=-20.000000,Y=-86.000000,Z=-25.000000)
     RocketOffsetB=(X=-20.000000,Y=86.000000,Z=-25.000000)
     GunOffsetA=(X=20.000000,Y=45.000000,Z=-5.000000)
     GunOffsetB=(X=20.000000,Y=-45.000000,Z=-5.000000)
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_PhantomBomber',WeaponBone="PassAttach")
     ExplosionEffectClass=Class'CSAPVerIV.FX_VehDeathPhantom'
     IdleSound=Sound'APVerIV_Snd.enginesB'
     StartUpSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftStartUp'
     ShutDownSound=Sound'APVerIV_Snd.LandingD'
     LaunchSound=Sound'APVerIV_Snd.EnginesLightupA'
     bCustomHealthDisplay=True
     ExitPositions(0)=(X=-1024.000000,Z=256.000000)
     ExitPositions(1)=(X=-1024.000000,Z=256.000000)
     ExitPositions(2)=(X=-1024.000000,Z=256.000000)
     ExitPositions(3)=(X=-1024.000000,Z=256.000000)
     FPCamPos=(X=15.000000,Z=20.000000)
     VehiclePositionString="in a Phantom Stealth Fighter"
     VehicleNameString="Phantom Stealth Fighter"
     FlagBone="PassAttach"
     FlagOffset=(Z=80.000000)
     AirSpeed=2600.000000
     AmbientSound=Sound'AssaultSounds.HumanShip.HnSpaceShipEng01'
     Mesh=SkeletalMesh'APVerIV_Anim.PhantomMesh'
     DrawScale=1.300000
     Skins(0)=Shader'APVerIV_Tex.ExcaliburSkins.GlassShader'
     Skins(1)=Texture'APVerIV_Tex.PhantomSkins.PhantomSkinA'
     Skins(2)=Texture'APVerIV_Tex.PhantomSkins.PhantomSkinB'
     AmbientGlow=86
     SoundRadius=100.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=784.000000
     CollisionRadius=120.000000
     CollisionHeight=68.000000
}
