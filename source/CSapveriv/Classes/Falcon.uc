//=============================================================================
// Falcon
// Basic Fighter
// Pilot Controls Guns,Air to Air Missiles
//=============================================================================

class Falcon extends AirPower_Fighter config(CSAPVerIV);

var()               Material        RedSkinB;
var()               Material        BlueSkinB;
var sound Afterburnsound;
var sound AfterBurnIgnite;

simulated event TeamChanged()
{
	super.TeamChanged();

	if (Team == 0 && RedSkin != None)
	   {
	    Skins[0] = RedSkin;
        Skins[1] = RedSkinB;
        Skins[2] = GlassMat;
       }
    else if (Team == 1 && BlueSkin != None)
            {
             Skins[0] = BlueSkin;
             Skins[1] = BlueSkinB;
             Skins[2] = GlassMat;
            }
}

function VehicleFire(bool bWasAltFire)
{
    	if (bWasAltFire)
    	{
         if (bReadyForTakeOff==False)
            {
             DesiredVelocity = EngineMinVelocity + 260;
             Velocity = EngineMinVelocity * Vector(Rotation);
             Acceleration = Velocity;
             bLanded =false;
             bReadyForTakeOff=true;
             bGearUp=true;

            if ( LaunchSound != None )
             PlaySound(LaunchSound, SLOT_None, 2.0);
           }
         else
           {
            // if no fuel no afterburn
            if (bNoFuel)
		        return;
            if (!bAfterburn)
               {
                bAfterburn=true;
                Afterburner();
               }
            else
               {
                bAfterburn=false;
                Afterburner();
               }
            }
        }
    	else
    	  bWeaponIsFiring = True;
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


simulated function Afterburner()
{
  local vector RotX, RotY, RotZ;

    GetAxes(Rotation,RotX,RotY,RotZ);

  if (bAfterburn==False)
     {
       if (Role == ROLE_Authority)
         {
           airspeed=LaunchSpeed;
           DesiredVelocity=oldSpeed;
         }
     }
   else
      {
        if (Role == ROLE_Authority)
         {
          AirSpeed=AfterBurnSpeed;
          oldSpeed=DesiredVelocity;
          DesiredVelocity=AfterburnSpeed;
          PlaySound(AfterBurnIgnite, SLOT_None, 4.0);
         }
      }
}

simulated function tick (float DeltaTime)
{
  super.Tick(DeltaTime);
    if(!bNoFuel && bAfterburn==true)
       burnFuel(DeltaTime);
     if (bNoFuel)
        {
         if (bAfterburn==true)
		    {
             bAfterburn=false;
             Afterburner();
            }
        }
        bOldAfterburn = bAfterburn;
}

simulated function SetTrailFX()
{
	// Trail FX
	if ( Thruster==None && Health>0 && Team != 255  )
	   {
		    Thruster = Spawn(class'FX_FighterThrusters',Self);
            AttachToBone(Thruster, 'REngine');
            Thruster.SetRelativeLocation(ThrusterOffset);
      }
     if ( Thruster != None && (Team == 0 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==0)))
		  Thruster.SetRedColor();

     if ( Thruster != None && (Team == 1 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==1)))
		  Thruster.SetBlueColor();
}

simulated function SetRunningLightsFX()
{
 if (BottomLight==none && Health>0 && Team != 255 )
          {
           BottomLight=spawn(Class'FX_RunningLight',Self,,Location);
           AttachToBone(BottomLight,'BLight');
          }
       if (BottomLight!=none)
          {
           if ( Team == 1 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==1) )	// Blue version
			   {
				BottomLight.SetBlueColor();
               }
            else
               if ( Team == 0 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==0) )	// Blue version
			   {
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
  if(bAfterburn==True)
     {
      FXAmount.X=0.003 * CurrThrust;
      FXAmount.Z=0.002 * CurrThrust;
     }
  else
     {
      FXAmount.X=0.0014 * CurrThrust;
      FXAmount.Z=0.00115 * CurrThrust;
     }
  FXAmount.Y=1.0;

  if ( Thruster != None )
   Thruster.SetDrawScale3D(FXAmount);
}

//
// HUD
//
simulated function DrawVehicleHUD( Canvas C, PlayerController PC )
{
   local vehicle	V;
	local vector	ScreenPos;
	local string	VehicleInfoString;
    super.DrawVehicleHUD( C, PC );
	C.Style		= ERenderStyle.STY_Alpha;

		// Draw Weird cam
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.DrawColor.A = 64;
		C.SetPos(0,0);
		C.DrawColor	= class'HUD_Assault'.static.GetTeamColor( Team );

        // Draw Reticle around visible vehicles
		foreach DynamicActors(class'Vehicle', V )
		{
			if ((V==Self) || (V.Health < 1) || V.bDeleteMe || V.GetTeamNum() == Team || V.bDriving==false || !V.IndependentVehicle())
                 continue;
             if (V.IsA('Phantom'))
                {
                 if(Phantom(V).bInvisON==True)
                    continue;
                }
			if ( !class'HUD_Assault'.static.IsTargetInFrontOfPlayer( C, V, ScreenPos, Location, Rotation ) )
				continue;

			if ( !FastTrace( V.Location, Location ) )
				continue;
            C.SetDrawColor(255, 0, 0, 192);

			C.Font = class'HudBase'.static.GetConsoleFont( C );
			VehicleInfoString = V.VehicleNameString $ ":" @ int(VSize(Location-V.Location)*0.01875.f) $ class'HUD_Assault'.default.MetersString;
			class'HUD_Assault'.static.Draw_2DCollisionBox( C, V, ScreenPos, VehicleInfoString, 1.5f, true );
		}
   if (Weapon.IsA('Weapon_Missiles'))
     RenderTarget(C);
}

simulated event RenderTarget( Canvas Canvas )
{
    local int XPos, YPos;
	local vector ScreenPos;
	local float RatioX, RatioY;
	local float tileX, tileY;
	local float SizeX, SizeY, PosDotDir;
	local vector CameraLocation, CamDir;
	local rotator CameraRotation;

    if (Weapon_Missiles(weapon).bLockedOn==true)
    {
       if(Weapon_Missiles(weapon).SeekTarget == None)
		return;
       Canvas.DrawColor = CrosshairColor;
       Canvas.DrawColor.A = 255;
       Canvas.Style = ERenderStyle.STY_Alpha;

    SizeX = 30.0;
	SizeY = 30.0;

	ScreenPos = Canvas.WorldToScreen( Weapon_Missiles(weapon).SeekTarget.Location );

	// Dont draw reticule if target is behind camera
	Canvas.GetCameraLocation( CameraLocation, CameraRotation );
	CamDir = vector(CameraRotation);
	PosDotDir = (Weapon_Missiles(weapon).SeekTarget.Location - CameraLocation) dot CamDir;
	if( PosDotDir < 0)
		return;

	RatioX = Canvas.SizeX / 640.0;
	RatioY = Canvas.SizeY / 480.0;

	tileX = sizeX * RatioX;
	tileY = sizeY * RatioX;

	XPos = ScreenPos.X;
	YPos = ScreenPos.Y;

    Canvas.DrawColor = CrosshairColor;
	Canvas.DrawColor.A = 255;
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.SetPos(XPos - tileX*0.5, YPos - tileY*0.5);
	Canvas.DrawTile( CrosshairTexture, tileX, tileY, 0.0, 0.0, 128, 128); //--- TODO : Fix HARDCODED USIZE

    }
}

simulated function DrawHealthInfo( Canvas C, PlayerController PC )
{
	class'HUD_Assault'.static.DrawCustomHealthInfo( C, PC, false );
	DrawSpeedMeter( C, PC.myHUD, PC );
}

simulated function DrawSpeedMeter( Canvas C, HUD H, PlayerController PC )
{
	local float		XL, YL, XL2, YL2, YOffset, XOffset, SpeedPct;

	C.Style = ERenderStyle.STY_Alpha;

	XL = 256 * 0.5 * H.ResScaleX * H.HUDScale;
	YL =  64 * 0.5 * H.ResScaleY * H.HUDScale;

	// Team color overlay
	C.DrawColor = class'HUD_Assault'.static.GetTeamColor( Team );
	C.SetPos( (C.ClipX - XL) * 0.5, C.ClipY - YL );
	C.DrawTile(Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Grey', XL, YL, 0, 0, 256, 64);

	// Speed Bar
	SpeedPct = DesiredVelocity - EngineMinVelocity;
	SpeedPct = FClamp( SpeedPct / (1000.f - EngineMinVelocity), 0.f, 1.f );
	XOffset =  1 * 0.5 * H.ResScaleX * H.HUDScale;
	YOffset = 27 * 0.5 * H.ResScaleY * H.HUDScale;
	XL2		= 84 * 0.5 * H.ResScaleY * H.HUDScale;
	YL2		= 18 * 0.5 * H.ResScaleX * H.HUDScale;

	C.DrawColor = class'HUD_Assault'.static.GetGYRColorRamp( SpeedPct );
	C.DrawColor.A = 96;

	C.SetPos( (C.ClipX - XL2) * 0.5 - XOffset, C.ClipY - YOffset - YL2 * 0.5 );
	C.DrawTile(Texture'InterfaceContent.WhileSquare', XL2*SpeedPct, YL2, 0, 0, 8, 8);

	// Solid Background
	C.DrawColor = class'Canvas'.Static.MakeColor(255, 255, 255);
	C.SetPos( (C.ClipX - XL) * 0.5, C.ClipY - YL );
	C.DrawTile(SpeedInfoTexture, XL, YL, 0, 0, 256, 64);
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
     RedSkinB=Texture'APVerIV_Tex.StarFalconSkins.StarFalconSkinB'
     BlueSkinB=Texture'APVerIV_Tex.StarFalconSkins.StarfighterMapBBlue'
     Afterburnsound=Sound'APVerIV_Snd.afterburner_loop'
     AfterBurnIgnite=Sound'APVerIV_Snd.AfterburnLgtUpB'
     FlyingAnim="LGearUp"
     ThrusterOffset=(X=1.000000)
     RedSkin=Texture'APVerIV_Tex.StarFalconSkins.StarFalconSkinA'
     BlueSkin=Texture'APVerIV_Tex.StarFalconSkins.StarFalconSkinABlue'
     GlassMat=Shader'APVerIV_Tex.ExcaliburSkins.GlassShader'
     SpeedInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid'
     AfterBurnSpeed=5500.000000
     LandingGearsUp="LGearUp"
     LandingGearsDown="LGearDown"
     NumChaff=6
     LaunchSpeed=2600.000000
     CrosshairX=32.000000
     CrosshairY=32.000000
     CrosshairTexture=Texture'ONSInterface-TX.tankBarrelAligned'
     RequiredFighterEquipment(0)="CSAPVerIV.Weapon_FalconWeapon"
     RequiredFighterEquipment(1)="CSAPVerIV.Weapon_FalconMissiles"
     VehicleProjSpawnOffsetLeft=(X=-86.000000,Y=-132.000000,Z=18.000000)
     VehicleProjSpawnOffsetRight=(X=86.000000,Y=132.000000,Z=18.000000)
     RocketOffsetA=(X=100.000000,Y=66.000000,Z=9.000000)
     RocketOffsetB=(X=100.000000,Y=-66.000000,Z=9.000000)
     GunOffsetA=(X=128.000000,Y=-100.000000,Z=18.000000)
     GunOffsetB=(X=128.000000,Y=100.000000,Z=18.000000)
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_Passenger',WeaponBone="PassAttach")
     ExplosionEffectClass=Class'CSAPVerIV.FX_VehDeathFalcon'
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
     VehiclePositionString="in a Falcon Star Fighter"
     VehicleNameString="Falcon Star Fighter"
     FlagBone="PassAttach"
     FlagOffset=(Z=80.000000)
     AirSpeed=2600.000000
     HealthMax=300.000000
     AmbientSound=Sound'AssaultSounds.HumanShip.HnSpaceShipEng01'
     Mesh=SkeletalMesh'APVerIV_Anim.StarFighterMesh'
     DrawScale=0.800000
     Skins(0)=Texture'APVerIV_Tex.StarFalconSkins.StarFalconSkinA'
     Skins(1)=Texture'APVerIV_Tex.StarFalconSkins.StarFalconSkinB'
     Skins(2)=Shader'APVerIV_Tex.ExcaliburSkins.GlassShader'
     AmbientGlow=86
     SoundRadius=100.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=784.000000
     CollisionRadius=96.000000
     CollisionHeight=68.000000
}
