//=============================================================================
// AirPower_Fighter
//=============================================================================

class AirPower_Fighter extends AirPower_Vehicle
	abstract
	config(User);

#exec OBJ LOAD FILE=AS_FX_TX.utx
#exec OBJ LOAD FILE=APVerIV_Tex.utx
#exec OBJ LOAD FILE=..\Animations\APVerIV_Anim.ukx
#exec OBJ LOAD FILE=..\Sounds\APVerIV_Snd.uax
  //const
// Movement
var				Quat	SpaceFighterRotation;	// Space Fighter actual rotation (using quaternions instead of rotators)
var				float	YawAccel, PitchAccel, RollAccel;
var				float	DesiredVelocity;		// Range: EngineMinVelocity -> 1000
var()		    float	EngineMinVelocity;		// minimum forward velocity
var()           float   LandingEngineMinVelocity; // for no velocity
var()    	float	VehicleRotationSpeed;   //Speed of rotation
var()    	float   VehiclePitchRotSpeed;
var()    	float   VehicleYawRotSpeed;
var() const	    float	RotationInertia;
var()			float   StrafeAccel;
var()			float   RollAutoCorrectSpeed;
var   config    float   MenuYawSpeed;   // need to get players turnspeed
var   config    float   MenuPitchSpeed; // for Yaw pitch and roll
var   config    float   MenuRollSpeed;  // from config menu
var				bool	bInitialized;			// this to catch first tick when match is started and velocity reset (so ship would always have a rotation==(0,0,0))
var				bool	bPostNetCalled;
var				bool	bGearUp;				// Once flying animation is played
var				bool	bSpeedFilterWarmup;
var				int		TopGunCount;

var	name FlyingAnim;

// Camera
var Rotator		LastCamRot;
var	float		myDeltaTime;
var	float		LastTimeSeconds;
var	float		CamRotationInertia;

// FX
var Emitter ExplosionEffect;
var	Emitter		SmokeTrail;
var class<Emitter> ShotDownFXClass;
var FX_FighterThrusters Thruster;
var vector ThrusterOffset;
//// TEAM STATUS ////
var()               Material        RedSkin;
var()               Material        BlueSkin;
var()               Material        GlassMat;
// Engine Speed smooth filter (for velocity jerkyness on low and jerky FPS)
const			SpeedFilterFrames = 20;
var		float	SpeedFilter[SpeedFilterFrames];
var		int		NextSpeedFilterSlot;
var		float	SmoothedSpeedRatio;

// Rockets
var		Vector	RocketOffset;

// Target locking
var	Vehicle		CurrentTarget;
var	Vector		CrosshairPos;
var texture		WeaponInfoTexture, SpeedInfoTexture;

var float LandingSpeed;
var float TakeoffSpeed;
var bool bReadyForTakeOff,bLanded;
var bool bWasUsed;
var float Damage, DamageRadius, MomentumTransfer;
var class<DamageType> MyDamageType;
var bool bAfterburnOn;
var bool bGearsDown;
var float oldSpeed;
var config float AfterBurnSpeed;
var name FlyingMovementState;
var bool bLeftRocket;
var FX_RunningLight LeftWingLight,RightWingLight,BottomLight;
var bool bAfterburn,bOldAfterburn;
var bool bOldSmall;
var name				LandingGearsUp, LandingGearsDown;
var Proj_FighterChaff Decoy;
var() config int NumChaff;
var config float LaunchSpeed;
// Target locking
var color CrosshairColor;
var float CrosshairX, CrosshairY;
var Material CrosshairTexture;
var bool bInvisON;
var()               array<Sound>    ImpactDamageSounds;

var array <float> DeathSpiralRotation;
var bool          bDeathRotation;
var int           DeathRotation;
var rotator       DeathSpiral;
var () float fuel;
var () float baseFuelRate;
var bool bNoFuel;
//Flyby sound Stuff
var float   FlybyRange;
var pawn    FlybyPawn;
var bool    bflyby;
var() sound FlybySound;
var vector  Flybyoffset;
var float   FlybyCountdown;
var float   FlybyInterval;
var	float   FlybyTraceDistance;
var FX_EjectionSmokeTrail ejectiontrail;
var FX_DamageSmokeTrail  DamageSmoke;
replication
{
	reliable if ( bNetDirty && bNetOwner && Role==ROLE_Authority )
		CurrentTarget,oldSpeed;
    reliable if(Role==ROLE_Authority)
                  bAfterburn,bGearsDown,NumChaff,AutoLaunch;
	reliable if ( Role < ROLE_Authority )
	bLanded,LandingEngineMinVelocity,DesiredVelocity,EngineMinVelocity;
    reliable if( bNetDirty && (Role==ROLE_Authority) )
		      bInvisON,Thruster;
    reliable if ( Role < ROLE_Authority )
		DeployChaff;
}

function BlowUp( vector HitNormal )		// Blow up space ship
{
        Explode( Location, HitNormal );
		GotoState('Dying');
}

function bool SetVehicleRotationSpeed( float NewRollSpeed );
function bool SetVehiclePitchRotSpeed( float NewPitchSpeed );
function bool SetVehicleYawRotSpeed( float NewYawSpeed );
simulated function AdjustEngineFX();
simulated event PostBeginPlay()
{
   VehicleYawRotSpeed=MenuYawSpeed * 0.001;
    VehiclePitchRotSpeed=MenuPitchSpeed * 0.001;
    VehicleRotationSpeed=MenuRollSpeed * 0.001;

	super.PostBeginPlay();
}
simulated function PostNetBeginPlay()
{
    super.PostNetBeginPlay();

    DesiredVelocity = EngineMinVelocity + 10;
    bLanded =true;
	bPostNetCalled = true;
    DrivingStatusChanged();
}

simulated function SetTrailFX();
simulated function SetRunningLightsFX();
simulated function PlayTakeOff();
simulated function EngineIgnite()
{
  if (Role==Role_Authority)
     {
      if ( Thruster != none)
       Thruster.SetVisable();

  if ( RightWingLight != none )
       RightWingLight.SetVisable();
  if ( LeftWingLight != none )
       LeftWingLight.SetVisable();
  if ( BottomLight != none )
       BottomLight.SetVisable();
       }
  if ( Thruster != none)
       Thruster.SetVisable();

  if ( RightWingLight != none )
       RightWingLight.SetVisable();
  if ( LeftWingLight != none )
       LeftWingLight.SetVisable();
  if ( BottomLight != none )
       BottomLight.SetVisable();
}


simulated function EngineShutDown()
{
   if (Role==Role_Authority)
       {
         if (Thruster!= none)
       Thruster.SetInvisable();

   if ( RightWingLight != none )
        RightWingLight.SetInvisable();
   if ( LeftWingLight != none )
        LeftWingLight.SetInvisable();
   if ( BottomLight != none )
        BottomLight.SetInvisable();
    }
   if (Thruster!= none)
       Thruster.SetInvisable();

   if ( RightWingLight != none )
        RightWingLight.SetInvisable();
   if ( LeftWingLight != none )
        LeftWingLight.SetInvisable();
   if ( BottomLight != none )
        BottomLight.SetInvisable();
}

simulated function burnFuel(float delta)
{
	local float fr;
    local float dffx;
	// Burn fuel. Only do this on the server and owner client. The
	// owner client only does this to render the fuel gauge.
	if (role == ROLE_Authority)
     {
		if (fuel > 0.0)
         {
			dffx = (Health / HealthMax);
            fr = (baseFuelRate / dffx);
			fuel = fuel - fr * delta;
			fuel = fmax(0.0, fuel - fr * delta);
		 }

		if (fuel == 0.0)
          	bNoFuel = true;
	}
}

simulated event DrivingStatusChanged()
{
    local PlayerController PC;

	PC = Level.GetLocalPlayerController();

	if (bDriving && PC != None && (PC.ViewTarget == None || !(PC.ViewTarget.IsJoinedTo(self))))
        bDropDetail = (Level.bDropDetail || (Level.DetailMode == DM_Low));
    else
        bDropDetail = False;

    if (bDriving)
       {
       	EngineIgnite();
        Enable('Tick');
       }
    else
      {
        EngineShutDown();
        Disable('Tick');
      }
}


simulated event TeamChanged()
{
     // Add Trail FX
	if ( Level.NetMode != NM_DedicatedServer )
	{
		SetTrailFX();
		SetRunningLightsFX();
		AdjustFX();
	}

	if (Team == 0 && RedSkin != None)
	   {
	    Skins[0] = GlassMat;
        Skins[1] = RedSkin;
       }
    else if (Team == 1 && BlueSkin != None)
            {
             Skins[0] = GlassMat;
             Skins[1] = BlueSkin;
            }
}

simulated function Destroyed()
{
	if ( Thruster != None )
		Thruster.Destroy();
	if (LeftWingLight!=none)
        LeftWingLight.Destroy();
    if (RightWingLight!=none)
        RightWingLight.Destroy();
    if (BottomLight!=none)
        BottomLight.Destroy();
    if ( SmokeTrail != None )
		SmokeTrail.Destroy();
    if( DamageSmoke!=none)
        DamageSmoke.Destroy();
    if (Role==ROLE_Authority)
       {
        if ( Thruster != None )
	         Thruster.Destroy();
	    if (LeftWingLight!=none)
            LeftWingLight.Destroy();
        if (RightWingLight!=none)
            RightWingLight.Destroy();
        if (BottomLight!=none)
            BottomLight.Destroy();
        if( DamageSmoke!=none)
            DamageSmoke.Destroy();
        if ( SmokeTrail != None )
		     SmokeTrail.Destroy();
		}
	super.Destroyed();
}

function Fire( optional float F )
{
    local Playercontroller PC;
     PC=Playercontroller(Controller);
	if (bReadyForTakeOff==False)
    {

      DesiredVelocity = EngineMinVelocity + 260;
      Velocity = EngineMinVelocity * Vector(Rotation);
      Acceleration = Velocity;
      bLanded =false;
      bReadyForTakeOff=true;
      bGearUp=true;
      PlayAnim('GearUp');
     if ( LaunchSound != None )
        PlaySound(LaunchSound, SLOT_None, 2.0);
    }
}
function AutoLaunch()
{
  Fire();
}
function PossessedBy(Controller C)
{
	super.PossessedBy(C);
     AddDefaultInventory();

    if (Role==ROLE_Authority)
    {
    if (Controller.IsA('Bot'))
       {
        //Need to Blow up if it was used
        //and a bot gets in
        if(bWasUsed==true)
           BlowUp(Vect(0,0,1));
        EngineMinVelocity=1200.000000;
        MinFlySpeed=1100.000000;
        DesiredVelocity = EngineMinVelocity + 200;
	    SetPhysics(phys_Flying);
	    Velocity = EngineMinVelocity * Vector(Rotation);
        Acceleration = Velocity;
        AirSpeed=2000.000000;
        AccelRate=1200.000000;
	    bLanded =false;
        bReadyForTakeOff=true;
        bGearUp=true;
        PlayAnim(LandingGearsUp);
        NumChaff=1;
       }

    else
       {
        AirSpeed=LaunchSpeed;
        AccelRate=2000.000000;
       }
    }
}

function vector GetBotError(vector StartLocation)
{
	local vector ErrorDir, VelDir;

	Controller.ShotTarget = Pawn(Controller.Target);
	ErrorDir = Normal((Controller.Target.Location - Location) Cross vect(0,0,1));
	if ( Controller.Target != OldTarget )
	{
		BotError = (1500 - 100 * Level.Game.GameDifficulty) * ErrorDir;
		OldTarget = Controller.Target;
	}
	VelDir = Normal(Controller.Target.Velocity);
	BotError += (100 - 200 *FRand()) * (ErrorDir + VelDir);
	if ( (Level.Game.GameDifficulty < 6) && (VSize(BotError) < 120) )
	{
		if ( (BotError Dot VelDir) < 0 )
			BotError += 10 * VelDir;
		else
			BotError -= 10 * VelDir;
	}
	if ( (Pawn(OldTarget) != None) && Pawn(OldTarget).bStationary )
		BotError *= 0.6;
	BotError = Normal(BotError) * FMin(VSize(BotError), FMin(1500 - 100*Level.Game.GameDifficulty,0.2 * VSize(Controller.Target.Location - StartLocation)));

	return BotError;
}

simulated function ClientKDriverEnter(PlayerController PC)
{

	super.ClientKDriverEnter( PC );

	if( bReadyForTakeOff==true)
	    bReadyForTakeOff=true;
	else
    bReadyForTakeOff=False;

    if( bLanded==False)
	    bLanded=False;
	else
    bLanded =true;
    bWasUsed=true;

}

// Called from the PlayerController when player wants to get out.
function bool KDriverLeave( bool bForceLeave )
{
   local Controller C;
   local Pawn		OldPawn;
   local vector	EjectVel;

	OldPawn = Driver;

      C = Controller;
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
	       if(ejectiontrail==none)
             {
              ejectiontrail=Spawn(class'FX_EjectionSmokeTrail',OldPawn,,OldPawn.Location);
              ejectiontrail.SetBase(OldPawn);//AttachToBone(ejectiontrail,'spine');
             }
            return True;
          }
        else
         return False;
}

// return false if out of range, can't see target, etc.
function bool CanAttack(Actor Other)
{
    // check that can see target
    if ( Controller != None )
		return Controller.LineOfSightTo(Other);
    return false;
}

//=============================================================================
// Movement
//=============================================================================
simulated function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange)
{
	local vector	X,Y,Z;
	local float		CurrentSpeed;
	local float		EngineAccel;
	local float		RotationSmoothFactor;
	local float		RollChange;
	local Rotator	NewRotation;

    //-----------------------------------
	if ( !bPostNetCalled || Controller == None )
		return;

	if ( !bInitialized  )
	{
		// Laurent -- Velocity Override
		// When Player Spawns with the spaceship as Pawn, velocity is reset at start match
		// since Rotation is overwritten later by Rotator(Velocity), it gets reset to Rotation(0,0,0)
		// And therefore not using the one set in PlayerStart.Rotation
		Acceleration = EngineMinVelocity * Vector(Rotation);
		SpaceFighterRotation = QuatFromRotator( Rotation );
		bInitialized = true;
	}

	// Only allow space fighter to change gear once landing gear is up.
	// (small hack for fins animations)
	if ( bGearUp )
		DesiredVelocity	= FClamp( DesiredVelocity+PlayerController(Controller).aForward*DeltaTime/15.f,EngineMinVelocity, 1000.f);

	else
		DesiredVelocity	= EngineMinVelocity;

	CurrentSpeed	= FClamp( (Velocity dot Vector(Rotation)) * 1000.f / AirSpeed, 0.f, 1000.f);
	EngineAccel		= (DesiredVelocity - CurrentSpeed) * 100.f;

	RotationSmoothFactor = FClamp(1.f - RotationInertia * DeltaTime, 0.f, 1.f);

	if ( PlayerController(Controller).bDuck > 0 && Abs(Rotation.Roll) > 500 )
	{
		// Auto Correct Roll
		if ( Rotation.Roll < 0 )
			RollChange = RollAutoCorrectSpeed;
		else
			RollChange = -RollAutoCorrectSpeed;
	}
	    //No Roll till takeoff
	   if (bReadyForTakeOff==True)
	      {
  	      //Barrel Roll Right
  	    if ( PlayerController(Controller).aStrafe > 0 ) // Rolling
  	       {
  		     if(Health < HealthMax / 3) //Damage makes it hard to control
               {
               if ( FRand() < 0.75 )
                  RollChange = PlayerController(Controller).aStrafe * 0.12;
               else
                  RollChange = PlayerController(Controller).aStrafe * 0.33;
               }
             else
              RollChange = PlayerController(Controller).aStrafe * 0.66;
           }
         //Barrel Roll Left
        if ( PlayerController(Controller).aStrafe < 0 ) // Rolling
  		   {
  		     if(Health < HealthMax / 2.5) //Damage makes it hard to control
               {
               if ( FRand() < 0.65 )
                  RollChange = PlayerController(Controller).aStrafe * 0.12;
               else
                  RollChange = PlayerController(Controller).aStrafe * 0.33;
              }
             else
              RollChange = PlayerController(Controller).aStrafe * 0.66;
           }


          }
    // Rotation Acceleration
	if (Controller.IsA('PlayerController'))
	   {
        if(Health < HealthMax / 2.5) //Damage makes it hard to control
          {
            if ( FRand() < 0.75 )
           YawAccel = (1-2*DeltaTime)*YawAccel + DeltaTime*VehicleYawRotSpeed*YawChange /10;
            else
            YawAccel = (1-2*DeltaTime)*YawAccel + DeltaTime*VehicleYawRotSpeed*YawChange;

          }
        else
        YawAccel = (1-2*DeltaTime)*YawAccel + DeltaTime*VehicleYawRotSpeed*YawChange;

       }
     else
        YawAccel	= RotationSmoothFactor*YawAccel   + DeltaTime*VehicleYawRotSpeed*YawChange;

     if (Controller.IsA('PlayerController'))
        {
         if (bReadyForTakeOff==True)
         {
           if(Health < HealthMax / 2.5)//Damage makes it hard to control
            {
            if ( FRand() < 0.75 )
            PitchAccel = (1-2*DeltaTime)*PitchAccel + DeltaTime*VehiclePitchRotSpeed*PitchChange /10;
            else
            PitchAccel = (1-2*DeltaTime)*PitchAccel + DeltaTime*VehiclePitchRotSpeed*PitchChange;

           }
           else
           PitchAccel = (1-2*DeltaTime)*PitchAccel + DeltaTime*VehiclePitchRotSpeed*PitchChange;
        }
      }
     else
         PitchAccel	= RotationSmoothFactor*PitchAccel + DeltaTime*VehiclePitchRotSpeed*PitchChange;

    RollAccel	= RotationSmoothFactor*RollAccel  + DeltaTime*VehicleRotationSpeed*RollChange;

	YawAccel	= FClamp( YawAccel, -AirSpeed, AirSpeed );
	PitchAccel	= FClamp( PitchAccel, -AirSpeed, AirSpeed );
	RollAccel	= FClamp( RollAccel, -AirSpeed, AirSpeed );

	// Perform new rotation
	GetAxes( QuatToRotator(SpaceFighterRotation), X, Y, Z );
	SpaceFighterRotation = QuatProduct(SpaceFighterRotation,
								QuatProduct(QuatFromAxisAndAngle(Y, DeltaTime*PitchAccel),
								QuatProduct(QuatFromAxisAndAngle(Z, -1.0 * DeltaTime * YawAccel),
								QuatFromAxisAndAngle(X, DeltaTime * RollAccel))));

	NewRotation = QuatToRotator( SpaceFighterRotation );

	// If autoadjusting roll, clamp to 0
	if ( PlayerController(Controller).bDuck > 0 && ((NewRotation.Roll < 0 && Rotation.Roll > 0) || (NewRotation.Roll > 0 && Rotation.Roll < 0)) )
	{
		NewRotation.Roll = 0;
		RollAccel = 0;
	}

    if(Health < HealthMax / 2)//Damage makes it hard to control
      {
       if ( FRand() < 0.75 )
	    Acceleration = Vector(NewRotation) * DesiredVelocity /1.4;
	   else
	    Acceleration = Vector(NewRotation) * DesiredVelocity;
      }
    else
      Acceleration = Vector(NewRotation) * DesiredVelocity;

    if(bReadyForTakeOff==true && bLanded==false)
	 {
     if (DesiredVelocity <= EngineMinVelocity+200)
      {
		velocity.z=-200.0;
        Acceleration.Z =-200.0;
      }
     }

    // Adjust Rolling based on Stafing
	NewRotation.Roll += StrafeAccel * 15;

	// Take complete control on Rotation
	bRotateToDesired	= true;
	bRollToDesired		= true;
	DesiredRotation		= NewRotation;
	SetRotation( NewRotation );

	if(bLanded ==true)
      {
       //Log("*****************bLanded =true!*******************************");
        MinFlySpeed=LandingSpeed;
        EngineMinVelocity=LandingEngineMinVelocity;
        DesiredVelocity=LandingEngineMinVelocity;
      }
}

//==================================================
simulated function rotator GetViewRotation()
{
	  if ( IsLocallyControlled() && Health > 0)
		   return QuatToRotator(SpaceFighterRotation);	// true rotation
      else
            return rotation;
}

simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local vector	x, y, z;
	local rotator	R;

	CameraLocation = Location;
	ViewActor	= Self;
	R			= GetViewRotation();
    GetAxes(R, x, y, z);

    // First-person view.
    CameraRotation = Normalize(R + PC.ShakeRot); // amb
    CameraLocation = CameraLocation +
                     PC.ShakeOffset.X * x +
                     PC.ShakeOffset.Y * y +
                     PC.ShakeOffset.Z * z;

	// Camera position is locked to vehicle
	CameraLocation = CameraLocation + (FPCamPos >> GetViewRotation());
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
	CamDistance		= Vect(-612, 0, 128);
	CamDistance.X	-= CamDistFactor * 200.0;	// Adjust Camera location based on ship's velocity
	CameraLocation	= CamLookAt + (CamDistance >> CameraRotation);

	if ( Trace( HitLocation, HitNormal, CameraLocation, ViewActor.Location, false, vect(10, 10, 10) ) != None )
		CameraLocation = HitLocation + HitNormal * 10;

	return true;
}
//
// Targeting
//
simulated function DrawVehicleHUD( Canvas C, PlayerController PC )
{
    local Vehicle	V;
    local vector	ScreenPos;
	local string	VehicleInfoString;
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
            if(V.IsA('AirPower_Fighter') && AirPower_Fighter(V).bInvisON==True)
                 continue;

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
       DrawTargetting( C );

   if ( !PC.MyHUD.bShowScoreboard )
	  {
        if(Isa('Excalibur'))
        DrawFuelMeter( C, PC.myHUD, PC );
		DrawChaff( C, PC.myHUD );
      }
}

simulated function 	DrawChaff( Canvas C, HUD H )
{
  local string ChaffNumberMessage;
  local float		XL, YL;
  local float		XO, YO;
  local float		TexScale;
              //Left Right    Up Down
              //XL 53          YL 10
	TexScale = 0.6;
	C.Style = ERenderStyle.STY_Alpha;
	C.drawColor.G = 255;
    XL = 120 * TexScale * H.ResScaleX * H.HUDScale;
    YL = 84 * TexScale * H.ResScaleY * H.HUDScale;
    XO = C.ClipX - 57 * TexScale * H.ResScaleX * H.HUDScale;
    YO = C.ClipY - 63 * TexScale * H.ResScaleY * H.HUDScale;

    C.Font = class'HudBase'.static.GetConsoleFont( C );
    C.Style = ERenderStyle.STY_Translucent;
    ChaffNumberMessage = "Chaff: " $String (NumChaff);
    C.SetPos( XO - XL*0.5, YO - YL*0.5 );
    C.drawColor.G = 255;
    C.DrawText(ChaffNumberMessage);
}

/* Space Fighter Targetting HUD code */
simulated function 	DrawTargetting( Canvas C )
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
       C.DrawColor = CrosshairColor;
       C.DrawColor.A = 255;
       C.Style = ERenderStyle.STY_Alpha;

    SizeX = 30.0;
	SizeY = 30.0;

	ScreenPos = C.WorldToScreen( Weapon_Missiles(weapon).SeekTarget.Location );

	// Dont draw reticule if target is behind camera
	C.GetCameraLocation( CameraLocation, CameraRotation );
	CamDir = vector(CameraRotation);
	PosDotDir = (Weapon_Missiles(weapon).SeekTarget.Location - CameraLocation) dot CamDir;
	if( PosDotDir < 0)
		return;

	RatioX = C.SizeX / 640.0;
	RatioY = C.SizeY / 480.0;

	tileX = sizeX * RatioX;
	tileY = sizeY * RatioX;

	XPos = ScreenPos.X;
	YPos = ScreenPos.Y;

    C.DrawColor = CrosshairColor;
	C.DrawColor.A = 255;
	C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(XPos - tileX*0.5, YPos - tileY*0.5);
	C.DrawTile( CrosshairTexture, tileX, tileY, 0.0, 0.0, 128, 128); //--- TODO : Fix HARDCODED USIZE
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

simulated function DrawFuelMeter( Canvas C, HUD H, PlayerController PC )
{
	local string FuelMessage;
    local float		XL, YL, FuelPct;
    local float		TexScale,barWidth;
	local float		XO, YO;
	local float CurrentFuel;
	CurrentFuel= Default.fuel;
	barWidth=1.0;
    TexScale = 0.6;
	C.Style = ERenderStyle.STY_Alpha;

	XL = 256 * TexScale * H.ResScaleX * H.HUDScale;
	YL = 128 * TexScale * H.ResScaleY * H.HUDScale;

	// Team color overlay
	C.DrawColor = class'HUD_Assault'.static.GetTeamColor( Team );
	C.SetPos( C.ClipX - XL, C.ClipY - YL );
	C.DrawTile(Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey', XL, YL, 0, 0, 256, 128);

	// Solid Background
	C.DrawColor = class'Canvas'.Static.MakeColor(255, 255, 255);
	C.SetPos( C.ClipX - XL, C.ClipY - YL );
	C.DrawTile(WeaponInfoTexture, XL, YL, 0, 0, 256, 128);

    FuelPct =  Fuel / CurrentFuel * barWidth;

	XL = 53 * TexScale * H.ResScaleX * H.HUDScale;
	YL = 10 * TexScale * H.ResScaleY * H.HUDScale;
	XO = C.ClipX - 57 * TexScale * H.ResScaleX * H.HUDScale;
	YO = C.ClipY - 63 * TexScale * H.ResScaleY * H.HUDScale;

	C.DrawColor = class'HUD_Assault'.static.GetGYRColorRamp( FuelPct );
	C.DrawColor.A = 96;

	C.SetPos( XO - XL*0.5, YO - YL*0.5 );
	C.DrawTile(Texture'InterfaceContent.WhileSquare', XL*FuelPct, YL, 0, 0, 8, 8);
    //Fuel Text
    XL = 120 * TexScale * H.ResScaleX * H.HUDScale;
    YL = 42 * TexScale * H.ResScaleY * H.HUDScale;

    C.Font = class'HudBase'.static.GetConsoleFont( C );
    C.FontScaleX=0.8;
    C.FontScaleY=0.8;
    C.Style = ERenderStyle.STY_Translucent;
    FuelMessage = "Fuel: " $String (Fuel);
    C.SetPos( XO - XL*0.5, YO - YL*0.5 );
    C.drawColor.G = 255;
    C.DrawText(FuelMessage);
}

//=============================================================================
// Collision
//=============================================================================
// dealing damage based on impact normal and vehicle velocity
simulated function VehicleCollision(Vector HitNormal, Actor Other)
{
	local float		Damage;
	local float		NormalSpeed;
	local Pawn		Inst;

	if ( Role < Role_Authority )
		return;

	NormalSpeed = Abs( Velocity dot HitNormal );
	Damage		= (NormalSpeed-200) / 100.0;

	if ( Damage > 1.f )
	{
		Damage	    *= Damage;
        Inst		= Pawn(Other);
        TakeDamage(Damage, Inst, Location-HitNormal*CollisionRadius, HitNormal*Damage*100.f,class'DamType_AirCollision');
        if (ImpactDamageSounds.Length > 0)
		PlaySound(ImpactDamageSounds[Rand(ImpactDamageSounds.Length-1)],,TransientSoundVolume*3.5);
    }
	else if ( VSize(Velocity) < 100 )
		TakeDamage(default.Health*2, Self, Location, vect(0,0,0),class'DamType_AirCollision');
}

simulated function Landed( vector HitNormal )
{
     SetPhysics(PHYS_none);
     bLanded=true;
     bReadyForTakeOff=false;
}

simulated function HitWall(vector HitNormal, actor Wall)
{
    if (Controller==none)
       {
        BlowUp( vect(0,0,1));
        TakeDamage(default.Health*2, Self, Location, vect(0,0,0), None);
       }

     // if not Landing Take Damage
      if ( VSize(Velocity) < 800 )
          {
           bLanded =true;
           bReadyForTakeOff=false;
           return;
          }
      else
         VehicleCollision(HitNormal, Wall);
}

simulated singular function Touch(Actor Other)
{
     local Vector HitNormal;
   if(other!=None)
     {
      if (Other.IsA('xPawn') && xPawn(other).PlayerReplicationInfo.Team.TeamIndex!=Team)
         {
          if ( VSize(Velocity) > 100 )
           xPawn(other).TakeDamage(1000, Self, Location, vect(0,0,0), class'DamTypeFighterRoadkill');
	       return;
         }

      if ( Other!=None && !Other.IsA('Projectile') && Other.bBlockActors )
	    {
		 HitNormal = Normal(Location - Other.Location);
		 VehicleCollision(HitNormal, Other);
	    }
	  if (Other.IsA('Vehicle'))
         {
            Vehicle(other).TakeDamage(1000, Self, Location, vect(0,0,0), class'DamTypeFighterRoadkill');
	        BlowUp( vect(0,0,1));
            TakeDamage(default.Health*2, Self, Location, vect(0,0,0),class'DamType_AirCollision');
            return;
	     }
     }
}

simulated function Bump( Actor Other )
{
    local int i;
    if (Role==ROLE_Authority)
    {
      if(other!=None)
        {
         if (Other.IsA('xPawn') && xPawn(other).PlayerReplicationInfo.Team.TeamIndex!=Team)
            {
             if ( VSize(Velocity) > 100 )
		     xPawn(other).TakeDamage(1000, Self, Location, vect(0,0,0), class'DamTypeFighterRoadkill');
             return;
	        }
          else
            if (Other.IsA('xPawn') && xPawn(other).PlayerReplicationInfo.Team.TeamIndex==Team)
            {
             	for (i=0; i<WeaponPawns.length; i++)
                 if(Driver!=None && WeaponPawns[i].Driver == none)
                   {
                    WeaponPawns[i].TryToDrive(XPawn(other));
				    return;
			       }
	            else
	              {
	               if (Driver !=None)
                    xPawn(other).TakeDamage(1000, Self, Location, vect(0,0,0), class'DamTypeFighterRoadkill');
			        return;
                  }
             }

	     if (Other.IsA('Vehicle'))
            {
             Vehicle(other).TakeDamage(1000, Self, Location, vect(0,0,0), class'DamTypeFighterRoadkill');
	         BlowUp( vect(0,0,1));
             TakeDamage(default.Health*2, Self, Location, vect(0,0,0),class'DamType_AirCollision');
             return;
            }
         }
       }
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{

	if (Level.NetMode != NM_Client)
	{
		if ( Level.NetMode == NM_Standalone )
		{
			if ( (InstigatedBy != None) && (InstigatedBy != self) && (!bThumped || InstigatedBy.bStationary)
				&& (PlayerController(Instigator.Controller) == None)
				&& (PlayerReplicationInfo != None) && (Level.GetLocalPlayerController().PlayerReplicationInfo.Team != PlayerReplicationInfo.Team) )
				Damage *= 1.0;
		}
		else if ( Deathmatch(Level.Game).bPlayersVsBots )
		{
			if ( (InstigatedBy != None) && (InstigatedBy != self)
				&& (PlayerController(Instigator.Controller) == None) )
				Damage *= 1.0;
		}

	// Using HitFxTicker to play various client side deaths...
	if ( instigatedBy == None || bLanded==true)
		HitFxTicker = 0; //TearOffDeath = Death_Geometry;	// geometry collision
	else if ( instigatedBy == self || (instigatedBy == self && bLanded==true) )
		HitFxTicker = 1; //TearOffDeath = Death_Self;		// suicide
	else
		HitFxTicker = 2; //TearOffDeath = Death_Pawn;		// killed by player

     if(Damage > 100)
       {
         DamMomentum=Damage;
         Controller.DamageShake(DamMomentum);

       }
	super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
   }
}

//=============================================================================
// FX
//=============================================================================

event AnimEnd( int Channel )
{
	Disable('AnimEnd');
	bGearUp = true;
}

//simulated function UpdateEngineSound(float SpeedPct);
simulated function AdjustFX()
{
	local float			NewSpeed, VehicleSpeed, SpeedPct;
	local int			i, averageOver;

	// Smooth filter on velocity, which is very instable especially on Jerky frame rate.
	NewSpeed = Max(Velocity Dot Vector(Rotation), EngineMinVelocity);
	SpeedFilter[NextSpeedFilterSlot] = NewSpeed;
	NextSpeedFilterSlot++;

	if ( bSpeedFilterWarmup )
		averageOver = NextSpeedFilterSlot;
	else
		averageOver = SpeedFilterFrames;

	for (i=0; i<averageOver; i++)
		VehicleSpeed += SpeedFilter[i];

	VehicleSpeed /= float(averageOver);

	if ( NextSpeedFilterSlot == SpeedFilterFrames )
	{
		NextSpeedFilterSlot = 0;
		bSpeedFilterWarmup	= false;
	}

	SmoothedSpeedRatio = VehicleSpeed / AirSpeed;
	SpeedPct = VehicleSpeed - EngineMinVelocity*AirSpeed/1000.f;
	SpeedPct = FClamp( SpeedPct / (AirSpeed*( (1000.f-EngineMinVelocity)/1000.f )), 0.f, 1.f );

	UpdateEngineSound( SpeedPct );

	// Adjust FOV depending on speed
	if ( PlayerController(Controller) != None && IsLocallyControlled() )
		PlayerController(Controller).SetFOV( PlayerController(Controller).DefaultFOV + SpeedPct*SpeedPct*15  );
}

simulated function UpdateEngineSound( float SpeedPct )
{
	// Adjust Engine volume
	SoundVolume = 180 +  32 * SpeedPct;
	SoundPitch	=  86 +  16 * SpeedPct;
}

simulated function Timer()
{
	local float			NewTimerRate;
	if (Role==ROLE_Authority)
    {
	 AdjustFX();
	// Update Frequency (for super High details)
	if ( IsLocallyControlled() )
		NewTimerRate = 0.02;
	else if ( EffectIsRelevant(Location, false) ) // if this pawn is relevant to local player
		NewTimerRate = 0.04;
	else
		NewTimerRate = 0.08;		// Not relevant

	SetTimer(NewTimerRate, true);
  }
}

simulated function Vector GetRocketSpawnLocation()
{
    if(bLeftRocket)
      {
        bLeftRocket=False;
        return RocketOffsetA;
       }
    else
      {
       bLeftRocket=True;
	   return RocketOffsetB;
      }
}

simulated final function MyRandSpin(float spinRate)
{
   //stop landed planes from turning when destroyed
   if(bLanded ==true)
     return;

       if(bDeathRotation==false)
          DeathRotation = Rand(DeathSpiralRotation.Length);
     if(DeathRotation==0)
       {
        bDeathRotation=true;
        DeathSpiral.Yaw=Rotation.Yaw + 20;
	    DeathSpiral.pitch=Rotation.Pitch - 30;
	    DeathSpiral.Roll = Rotation.Roll + 500;
       }
     if(DeathRotation==1)
       {
        bDeathRotation=true;
        DeathSpiral.Yaw=Rotation.Yaw + 300;
	    DeathSpiral.pitch=Rotation.Pitch - 30;
	    DeathSpiral.Roll = Rotation.Roll - 500;
       }

     if(DeathRotation==2)
       {
        bDeathRotation=true;
        DeathSpiral.Yaw=Rotation.Yaw + 0;
	    DeathSpiral.pitch=Rotation.Pitch - 500;
	    DeathSpiral.Roll = Rotation.Roll + 200;
       }
     SetRotation(DeathSpiral);
}

// Spawn Explosion FX
simulated function Explode( vector HitLocation, vector HitNormal )
{
	if ( SmokeTrail != None )
	{
		SmokeTrail.Kill();
		SmokeTrail = None;
	}
	if ( Thruster != None )
	     Thruster.Destroy();
	if (LeftWingLight!=none)
        LeftWingLight.Destroy();
    if (RightWingLight!=none)
        RightWingLight.Destroy();
    if (BottomLight!=none)
        BottomLight.Destroy();
	bDynamicLight = false;
	LightType = LT_None;

	if ( Role == ROLE_Authority )
	{
	 if ( Thruster != None )
	    Thruster.Destroy();
	 if (LeftWingLight!=none)
         LeftWingLight.Destroy();
     if (RightWingLight!=none)
         RightWingLight.Destroy();
     if (BottomLight!=none)
         BottomLight.Destroy();
     }
    if ( Level.NetMode != NM_DedicatedServer )
	    {
         if(bLanded==false)
         ExplosionEffect= Spawn(ExplosionEffectClass, Self,, HitLocation, Rotation);
         HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
         PlaySound(sound'APVerIV_Snd.NKRadExp',SLOT_None,2.5);
         Spawn(class'CSAPVerIV.FX_NukeFlashFirst',,, Location, Rotation);
         Spawn(class'CSAPVerIV.FX_NukeFlash',,, Location, Rotation);
         Spawn(class'CSAPVerIV.FX_MissileHitGlow',,, Location, Rotation);
         PlaySound(sound'APVerIV_Snd.NKExp',SLOT_None,2.5);
        }
}

function DriverDied()
{
  TakeDamage(default.Health*2, Self, Location, vect(0,0,0), None);

}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local vector	HitNormal;

	if ( Level.Game != None )
		Level.Game.DiscardInventory( Self );
     if ( PlayerController(Controller) != none)
           PlayerController(Controller).StopViewShaking();
	// Make sure player controller is actually possessing the vehicle.. (since we forced it in ClientKDriverEnter)
	if ( PlayerController(Controller) != None && PlayerController(Controller).Pawn != Self )
		Controller = None;

	if ( PlayerController(Controller) != None )
	{
		PlayerController(Controller).SetViewTarget( Self );
		DestroyPrevController = Controller;
	}

	bCanTeleport = false;
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;

	if ( HitFxTicker == 2 )
	{
		if ( Level.NetMode != NM_DedicatedServer )
		{
			SmokeTrail = Spawn(ShotDownFXClass, Self,, Location);
			if ( SmokeTrail != None )
				SmokeTrail.SetBase( self );
		}
		GotoState('ShotDown');
	}
	else
	{
		if ( HitFxTicker == 0 )
			HitNormal = Normal( TearOffMomentum );	// Set Directional explosion based on HitNormal

		Explode( Location, HitNormal );
		GotoState('Dying');
	}
}

//
// Shot down in flames
//
state ShotDown
{
	ignores Trigger, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, name FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}
	event FellOutOfWorld(eKillZType KillType) {	}
	function ReduceCylinder() { }
	function LandThump() {	}
	event AnimEnd(int Channel) {	}
	function LieStill() {}
	singular function BaseChange() {	}
	function Died(Controller Killer, class<DamageType> damageType, vector HitLocation) {}
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType) {}

	function VehicleSwitchView(bool bUpdating) {}
	function DriverDied();
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);

	function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange);


	simulated function Timer()
	{
		BlowUp( vect(0,0,0) );
	}

	// Blow up Space Fighter
	simulated function BlowUp( vector HitNormal )
	{
		Explode( Location, HitNormal );
		GotoState('Dying');
	}

    simulated function BeginState()
	{
		local PlayerController	PC;

		Acceleration.Z -= VSize(Velocity)*0.67;
		PC = PlayerController(Controller);
		if(controller!=none)
		  {
           DamMomentum=0;
		   Controller.DamageShake(DamMomentum);
          }
        if ( PC != None && !PC.bBehindView )
		   {
			PC.bBehindView = true;// Force Behindview
            PC.StopViewShaking();
           }
		if ( Driver != None && bDrawDriverInTP )
			Destroyed_HandleDriver();

		if ( Controller != None )
			Controller.PawnDied( self );
	}

	simulated function EndState()
	{
		AmbientSound	= None;
		bDynamicLight	= false;
		LightType		= LT_None;
	}

Begin:
	SetTimer(4.0, false);
}

simulated function Flyby()
{
    local vector TraceStart, TraceEnd, HitLocation, HitNormal;
	local actor HitActor;
    if(bflyby!=True)
      {
  if (FlybyCountdown <=0)
     {
       foreach RadiusActors(class'Pawn', FlybyPawn, FlybyRange, Location)
             {
                if (FlybyPawn.IsA('XPawn') && XPawn(FlybyPawn).Controller!=none)
                   {
                    TraceStart = Location + (FlybyOffset >> Rotation);
			        TraceEnd = TraceStart - ( FlybyTraceDistance * vect(1,0,1) );
                    TraceEnd=FlybyPawn.Location;
                    HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, True);
                    if(HitActor==FlybyPawn && (((FlybyPawn.Location.X - Location.x) <= FlybyTraceDistance) || ((FlybyPawn.Location.z - Location.z) <= FlybyTraceDistance)))
                       {
                        FlybyPawn.PlaySound(FlybySound, SLOT_None,200,true, 600);
                        FlybyCountdown = 0.0;
                        FlybyCountdown += FlybyInterval;
                        bflyby=true;
                       }
                    }
              }
      }
     }
}

simulated function tick (float DeltaTime)
{
  local PlayerController PC;
  local	class<LocalMessage>	LockOnClass;
    if(Health < HealthMax / 2)
      {
       if( DamageSmoke==none)
         {
          DamageSmoke=Spawn(class'FX_DamageSmokeTrail',self,,location);
          DamageSmoke.Setbase(self);
         }
     }
  PC = PlayerController(Controller);
  if(IsInState('ShotDown'))
    {
     bRotateToDesired = true;
	 bRollToDesired	= true;
     MyRandSpin(800);
     return;
    }
 if (Role==ROLE_Authority)
    {
       // Missile Locking
      if ( Driver != None && Controller != None )
		  {
			if ( bEnemyLockedOn && PlayerController(Controller) != None && Level.TimeSeconds > LastLockWarningTime + 1.5)
        	   {
				 LockOnClass = class<LocalMessage>(DynamicLoadObject(LockOnClassString, class'class'));
				 PlayerController(Controller).ReceiveLocalizedMessage(LockOnClass, 12);
        		 LastLockWarningTime = Level.TimeSeconds;
			   }
		  }

     //Pilot has entered do stuff
     if (Controller!=none)
        {
         if ( AmbientSound != IdleSound )
              AmbientSound = IdleSound;

         AdjustEngineFX();
          if( bflyby==false)
          Flyby();
          if(Controller.IsA('Bot'))
              BotEject();
        }
    }
       //Landing Gears
       if ( VSize(Velocity) < 210 )
          {
           if(bGearsDown==False)
                {
                 bGearsDown=true;
                 PlayAnim(LandingGearsDown);
                }
            }
           else
            {
             if(bGearsDown==True)
               {
                bGearsDown=False;
                PlayAnim(LandingGearsUp);
               }
             }

          FlybyCountdown -= DeltaTime;
       if (FlybyCountdown <=0)
           bflyby=false;
}

exec function SwitchToLastWeapon()
{
    DeployChaff();
}
simulated function DeployChaff()
{
  if ( NumChaff > 0 )
     {
	   NumChaff --;
       Decoy=Spawn(Class'CSAPVerIV.Proj_FighterChaff',Self,,location + Vect(-228,0,0),Rotation);
       Decoy.SetOwner(Self);
       Decoy.SetOwner(Self);
     }
}
//Notify vehicle that an enemy has locked on to it
event NotifyEnemyLockedOn()
{
    if(Controller!=none)
    {
    if(controller.IsA('Bot'))
      SwitchToLastWeapon();
    }
	bEnemyLockedOn = true;
}
//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     VehicleRotationSpeed=0.016000
     VehiclePitchRotSpeed=0.001500
     VehicleYawRotSpeed=0.001000
     RotationInertia=20.000000
     RollAutoCorrectSpeed=3000.000000
     MenuYawSpeed=1.000000
     MenuPitchSpeed=1.500000
     MenuRollSpeed=16.000000
     bSpeedFilterWarmup=True
     CamRotationInertia=10.330000
     WeaponInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid'
     bLanded=True
     Damage=250.000000
     DamageRadius=1024.000000
     MomentumTransfer=6000.000000
     MyDamageType=Class'CSAPVerIV.DamType_FighterExplosion'
     AfterBurnSpeed=10000.000000
     CrossHairColor=(R=255,A=255)
     CrosshairX=40.000000
     CrosshairY=40.000000
     CrosshairTexture=TexRotator'APVerIV_Tex.AP_FX.CrossRot'
     ImpactDamageSounds(0)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision01'
     ImpactDamageSounds(1)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision02'
     ImpactDamageSounds(2)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     ImpactDamageSounds(3)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision04'
     ImpactDamageSounds(4)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision05'
     ImpactDamageSounds(5)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision06'
     ImpactDamageSounds(6)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision07'
     fuel=60.000000
     baseFuelRate=1.000000
     FlybyRange=3000.000000
     Flybyoffset=(Z=-60.000000)
     FlybyTraceDistance=4000.000000
     ExplosionEffectClass=Class'CSAPVerIV.FX_VehDeathExcalibur'
     DefaultCrosshair=Texture'Crosshairs.HUD.Crosshair_Circle1'
     CrosshairScale=0.500000
     bCHZeroYOffset=True
     bHasRadar=True
     EjectMomentum=2500.000000
     CenterSpringForce="SpringSpaceFighter"
     CenterSpringRangePitch=0
     CenterSpringRangeRoll=0
     DriverDamageMult=0.000000
     bCanFly=True
     bCanStrafe=True
     bSimulateGravity=False
     bDirectHitWall=True
     bServerMoveSetPawnRot=False
     bSpecialHUD=True
     bSpecialCalcView=True
     SightRadius=25000.000000
     AirSpeed=2450.000000
     AccelRate=2000.000000
     HealthMax=250.000000
     Health=300
     LandMovementState="PlayerSpaceFlying"
     MaxRotation=40.849998
     AmbientGlow=128
     CollisionRadius=60.000000
     CollisionHeight=30.000000
     RotationRate=(Pitch=32768,Yaw=32768,Roll=32768)
     ForceType=FT_DragAlong
     ForceRadius=100.000000
     ForceScale=5.000000
}
