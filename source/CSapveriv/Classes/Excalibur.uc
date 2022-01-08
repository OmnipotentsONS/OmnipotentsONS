//=============================================================================
// Excalibur
// Air Superiority Fighter
// Pilot Controls Guns, Air to Air Missiles.
//=============================================================================

class Excalibur extends AirPower_Fighter config(CSAPVerIV);

var Deco_ExcaliburHeavy PowerupBooster;
var vector BoosterOffset;
var()               Material        RedSkinB,RedSkinC;
var()               Material        BlueSkinB,BlueSkinC;
var Material SpecialSkinA,SpecialSkinB;
var string NameVerify_M,NameVerify_E;
var bool bCurrentTarget;
var sound Afterburnsound;
var sound AfterBurnIgnite;
var bool bBooster,bBoosterOn,bAutoBooster;
var Excalibur_Robot Robot;
var Pawn NewDriver;
var bool bPhoenix;
replication
{
   	reliable if( Role==ROLE_Authority )
		Robot,NewDriver,bBooster;
}

simulated event TeamChanged()
{
	super.TeamChanged();

	if (Team == 0 && RedSkin != None)
	   {
	    Skins[0] = GlassMat;
        Skins[1] = RedSkin;
        Skins[3] = RedSkinC;
        if(controller!=none)
        EvilMonarchSpecial();
       }
    else
      {
     if (Team == 1 && BlueSkin != None)
            {
             Skins[0] = GlassMat;
             Skins[1] = BlueSkin;
             Skins[2] = BlueSkinB;
             Skins[3] = BlueSkinC;
             if(controller!=none)
             EvilMonarchSpecial();
            }
      }
}
simulated event EvilMonarchSpecial()
{
   if((PlayerReplicationInfo.PlayerName==NameVerify_M) || (PlayerReplicationInfo.PlayerName==NameVerify_E))
      {
       Skins[0] = GlassMat;
       Skins[1] = SpecialSkinA;
       Skins[2] = SpecialSkinB;
       Skins[3] = BlueSkinC;
      }
}
function AltFire( optional float F )
{
    Super.AltFire(F);
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

            //if ( LaunchSound != None )
            // PlaySound(LaunchSound, SLOT_None, 2.0);
           }
         else
           {
            // if no fuel no afterburn
            if (bNoFuel==true)
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
    	   {
    	    bWeaponIsFiring = True;


           }

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
           WingsAnim();
           airspeed=LaunchSpeed;
           DesiredVelocity=oldSpeed;
         }
     }
   else
      {
        if (Role == ROLE_Authority)
         {
          WingsAnim();
          AirSpeed=AfterBurnSpeed;
          oldSpeed=DesiredVelocity;
          DesiredVelocity=AfterburnSpeed;
          PlaySound(AfterBurnIgnite, SLOT_None, 4.0);
         }
      }
}

function WingsAnim()
{
 if(bAfterBurn==True)
    PlayAnim('WingsClose');
 else
    PlayAnim('WingsOpen');
}

simulated function tick (float DeltaTime)
{
  super.Tick(DeltaTime);

    if(!bNoFuel && bAfterburn==true)
       burnFuel(DeltaTime);

     if (bNoFuel==true)
        {
         if (bAfterburn==true)
		    {
             bAfterburn=false;
             Afterburner();
            }
        }
        bOldAfterburn = bAfterburn;

        if(bPhoenix==false)
          {
           if(Controller!=none && Controller.Adrenaline== 100)
             Phoenix();
          }
}

function Phoenix()
{
  bPhoenix=true;
  CreateInventory("CSAPVerIV.Weapon_Phoenix");
  if (PlayerController(Controller) != None)
	  PlayerController(Controller).ReceiveLocalizedMessage(class'MSG_PredatorMessages', 0);
}

function DiscardPhoenix()
{
  bPhoenix=false;

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
      if(PowerupBooster==None &&  bBooster==True)
         DecoBooster();
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

function KDriverEnter(Pawn p)
{
    super.KDriverEnter( P );
     if(Driver.ShieldStrength >= 100)
      {
       if(Driver.Health >= 100)
         {
          if(Driver.HasUDamage())
            {
             PlaneBooster();
             bBooster=true;
            }
          }
       }

      if(controller!=none && Controller.IsA('Bot'))
        {
         if ( Level.Game != None )
		      Level.Game.DiscardInventory( self );
          CreateInventory("CSAPVerIV.Weapon_ExcaliburBotFighter");
        }

     if(bAutoBooster==true)
        PlaneBooster();
}

simulated function PlaneBooster()
{
  if(bAutoBooster==false)
     {
      Health=500;
      AddShieldStrength(200);
     }
  CreateInventory("CSAPVerIV.Weapon_IonGun");
}

simulated function DecoBooster()
{
  if ( PowerupBooster == None)
	{
		PowerupBooster = Spawn(class'Deco_ExcaliburHeavy',self,,Location);
		AttachToBone(PowerupBooster,'PassAttach');
        PowerupBooster.SetRelativeLocation(BoosterOffset);
     }
}

simulated function Destroyed()
{
	if (PowerupBooster!=none)
        PowerupBooster.Destroy();

    if (Role==ROLE_Authority)
       {
        if (PowerupBooster!=none)
            PowerupBooster.Destroy();
       }
	super.Destroyed();
}

// Spawn Explosion FX
simulated function Explode( vector HitLocation, vector HitNormal )
{
    if (PowerupBooster!=none)
        PowerupBooster.Destroy();

	if ( Role == ROLE_Authority )
	{
	 if (PowerupBooster!=none)
        PowerupBooster.Destroy();
    }
    super.Explode(HitLocation,HitNormal);
}

state Transform
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function Timer()
     {}
    function BeginState()
    {
		bHidden = true;
        SetPhysics(PHYS_None);
		SetCollision(false,false,false);
    }
Begin:
	//Instigator = self;
	Destroy();
    super.destroyed();
}

function Excalibur_Robot SpawnExcalibur_Robot(Vector Start, Rotator Dir)
{
    NewDriver=Driver;
	Robot = Spawn(Class'CSAPVerIV.Excalibur_Robot', self,, Start, Dir);
    if (Robot == None)
		Robot = Spawn(Class'CSAPVerIV.Excalibur_Robot', Self,, Location, Dir);
    if (Robot != None)
    {
        Robot.SetTeamNum(GetTeamNum());
		Robot.Health=Health;
		Robot.Velocity=Velocity;
		if(bBooster==true)
		Robot.bIonCannon=true;
        KDriverLeave(true);
		Robot.TryToDrive(NewDriver);
		GotoState('Transform');
	}
	return Robot;
}
static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );

	L.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.AP_Weapons_ST.Interceptor');
	L.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.AP_Robot_ST.ExbotPartsB');
	L.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.AP_FX_ST.chutemesh');
	L.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.AP_FX_ST.FighterEnginesRed');
    L.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.Excalibur_ST.NoseDestroy');
    L.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.Excalibur_ST.LWingDestroy');
    L.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.Excalibur_ST.RWingDestroy');
    L.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.Excalibur_ST.ExFusalge');
    L.AddPrecacheStaticMesh( StaticMesh'APVerIV_ST.Excalibur_ST.EX_Cockpit' );

    L.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human1_Tex' );		// Skins
	L.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human2_Tex' );
    L.AddPrecacheMaterial( Combiner'APVerIV_Tex.ExcaliburSkins.ExcaliCombB' );
    L.AddPrecacheMaterial( Combiner'APVerIV_Tex.ExcaliburSkins.ExcaliCombA' );
    L.AddPrecacheMaterial( Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Skaarj2_C' );
    L.AddPrecacheMaterial( Shader'APVerIV_Tex.ExcaliburSkins.GlassShader' );
    L.AddPrecacheMaterial( TexOscillator'APVerIV_Tex.AP_FX.EngineRedFlux' );
    L.AddPrecacheMaterial( TexRotator'APVerIV_Tex.AP_FX.RedCoreRot' );
    L.AddPrecacheMaterial( TexOscillator'APVerIV_Tex.AP_FX.EngineBlueFlux' );
    L.AddPrecacheMaterial( TexRotator'APVerIV_Tex.AP_FX.BlueCoreRot' );

    L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	L.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	L.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	L.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid' );
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.AssaultRadar' );
}

simulated function UpdatePrecacheStaticMeshes()
{
    Level.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.AP_Weapons_ST.Interceptor');
	Level.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.AP_Robot_ST.ExbotPartsB');
	Level.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.AP_FX_ST.chutemesh');
	Level.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.AP_FX_ST.FighterEnginesRed');
    Level.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.Excalibur_ST.NoseDestroy');
    Level.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.Excalibur_ST.LWingDestroy');
    Level.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.Excalibur_ST.RWingDestroy');
    Level.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.Excalibur_ST.ExFusalge');
	Level.AddPrecacheStaticMesh( StaticMesh'APVerIV_ST.Excalibur_ST.EX_Cockpit' );
    super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human1_Tex' );		// Skins
	Level.AddPrecacheMaterial( Material'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human2_Tex' );
    Level.AddPrecacheMaterial( Combiner'APVerIV_Tex.ExcaliburSkins.ExcaliCombB' );
    Level.AddPrecacheMaterial( Combiner'APVerIV_Tex.ExcaliburSkins.ExcaliCombA' );
    Level.AddPrecacheMaterial( Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Skaarj2_C' );
    Level.AddPrecacheMaterial( Shader'APVerIV_Tex.ExcaliburSkins.GlassShader' );
    Level.AddPrecacheMaterial( TexOscillator'APVerIV_Tex.AP_FX.EngineRedFlux' );
    Level.AddPrecacheMaterial( TexRotator'APVerIV_Tex.AP_FX.RedCoreRot' );
    Level.AddPrecacheMaterial( TexOscillator'APVerIV_Tex.AP_FX.EngineBlueFlux' );
    Level.AddPrecacheMaterial( TexRotator'APVerIV_Tex.AP_FX.BlueCoreRot' );

	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	Level.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	Level.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	Level.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid' );
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.AssaultRadar' );
	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     BoosterOffset=(X=-2.200000,Y=0.050000,Z=-0.800000)
     RedSkinB=Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human1_C'
     RedSkinC=Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Skaarj2_C'
     BlueSkinB=Combiner'APVerIV_Tex.ExcaliburSkins.ExcaliCombA'
     BlueSkinC=Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Skaarj2_C'
     SpecialSkinA=Texture'APVerIV_Tex.ExcaliburSkins.EvilMonarchSkinB'
     SpecialSkinB=Texture'APVerIV_Tex.ExcaliburSkins.EvilMonarchSkinA'
     NameVerify_M="**Monarch**"
     NameVerify_E="XEvilWyvernX"
     Afterburnsound=Sound'APVerIV_Snd.afterburner_loop'
     AfterBurnIgnite=Sound'APVerIV_Snd.AfterburnLgtUpB'
     FlyingAnim="Flying"
     ShotDownFXClass=Class'CSAPVerIV.FX_Fighter_ShotDownEmitter'
     ThrusterOffset=(X=0.500000)
     RedSkin=Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human2_C'
     BlueSkin=Combiner'APVerIV_Tex.ExcaliburSkins.ExcaliCombB'
     GlassMat=Shader'APVerIV_Tex.ExcaliburSkins.GlassShader'
     SpeedInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Speed_Solid'
     AfterBurnSpeed=5500.000000
     LandingGearsUp="GearUp"
     LandingGearsDown="GearDown"
     NumChaff=3
     LaunchSpeed=3000.000000
     CrosshairX=32.000000
     CrosshairY=32.000000
     CrosshairTexture=Texture'ONSInterface-TX.tankBarrelAligned'
     FlybySound=Sound'APVerIV_Snd.ExcaliburFlybyB'
     FlybyInterval=8.500000
     RequiredFighterEquipment(0)="CSAPVerIV.Weapon_FighterGuns"
     RequiredFighterEquipment(1)="CSAPVerIV.Weapon_Missiles"
     RequiredFighterEquipment(2)="CSAPVerIV.Weapon_FRockets"
     RequiredFighterEquipment(3)="CSAPVerIV.EXFighterTransformRifle"
     VehicleProjSpawnOffsetLeft=(X=60.000000,Y=-37.500000,Z=-7.000000)
     VehicleProjSpawnOffsetRight=(X=60.000000,Y=37.500000,Z=-7.000000)
     RocketOffsetA=(X=-20.000000,Y=-86.000000,Z=-32.000000)
     RocketOffsetB=(X=-20.000000,Y=86.000000,Z=-32.000000)
     GunOffsetA=(X=20.000000,Y=45.000000,Z=-5.000000)
     GunOffsetB=(X=20.000000,Y=-45.000000,Z=-5.000000)
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_Passenger',WeaponBone="PassAttach")
     IdleSound=Sound'APVerIV_Snd.enginesB'
     StartUpSound=Sound'APVerIV_Snd.jetstart'
     ShutDownSound=Sound'APVerIV_Snd.LandingA'
     LaunchSound=Sound'APVerIV_Snd.EnginesLightupB'
     bCustomHealthDisplay=True
     ExitPositions(0)=(X=-1024.000000,Z=256.000000)
     ExitPositions(1)=(X=-1024.000000,Z=256.000000)
     ExitPositions(2)=(X=-1024.000000,Z=256.000000)
     ExitPositions(3)=(X=-1024.000000,Z=256.000000)
     FPCamPos=(X=15.000000,Z=20.000000)
     VehiclePositionString="in a Excalibur"
     VehicleNameString="Excalibur"
     FlagBone="PassAttach"
     FlagOffset=(Z=80.000000)
     AirSpeed=3000.000000
     HealthMax=300.000000
     AmbientSound=Sound'AssaultSounds.HumanShip.HnSpaceShipEng01'
     Mesh=SkeletalMesh'APVerIV_Anim.ExcaliburMesh'
     DrawScale=1.300000
     AmbientGlow=86
     SoundRadius=100.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=784.000000
     CollisionRadius=96.000000
     CollisionHeight=68.000000
}
