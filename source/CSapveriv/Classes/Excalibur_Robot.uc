class Excalibur_Robot extends Vehicle placeable;

#exec OBJ LOAD FILE=GameSounds.uax
#exec OBJ LOAD FILE=PlayerSounds.uax
#exec OBJ LOAD FILE=PlayerFootSteps.uax
#exec OBJ LOAD FILE=DanFX.utx
#exec OBJ LOAD FILE=GeneralAmbience.uax
#exec OBJ LOAD FILE=GeneralImpacts.uax
#exec OBJ LOAD FILE=WeaponSounds.uax
#exec OBJ LOAD FILE="..\Textures\PlayerSkins.utx"
var Excalibur		FighterTrans;
var(Sounds) float GruntVolume;
var(Sounds) float FootstepVolume;
var		float	LastFootStepTime;
var config bool bPlayOwnFootsteps;
var eDoubleClickDir CurrentDir;
var float MinTimeBetweenPainSounds;
var localized string HeadShotMessage;
// Common sounds
var(Sounds) Sound   SoundFootsteps[11]; // Indexed by ESurfaceTypes (sorry about the literal).
var(Sounds) class<xPawnSoundGroup> SoundGroupClass;
// allowed voices
var string VoiceType;


var xWeaponAttachment WeaponAttachment;

var int  MultiJumpRemaining;
var int  MaxMultiJump;
var int  MultiJumpBoost; // depends on the tolerance (100)
var name WallDodgeAnims[4];
var name IdleHeavyAnim;
var name IdleRifleAnim;
var name FireHeavyRapidAnim;
var name FireHeavyBurstAnim;
var name FireRifleRapidAnim;
var name FireRifleBurstAnim;
var name FireRootBone;
var enum EFireAnimState
{
    FS_None,
    FS_PlayOnce,
    FS_Looping,
    FS_Ready
} FireState;
var Mesh SkeletonMesh;
var	xEmitter DamageTrail;
var	Pawn    Oldpawn;
 //------------------
// Damage Systems
var () sound			DestroyedSound;
//--DAMAGE SYSTEMS--------------------------------------------------------------
//

var float Damage, DamageRadius, MomentumTransfer;
var class<DamageType> MyDamageType;

//// TEAM STATUS ////
var()               Material        RedSkin;
var()               Material        BlueSkin;
var Material RedSkinB;  //Red Team Skins
var Material BlueSkinB;  //Blue Team Skins
var vector HitVelocity;
var bool bTransform;
var float			FireInterval;
var	float			FireCountdown;
var Weapon lastWeapon;
var bool bIonCannon;
var()	vector	VehicleProjSpawnOffset;		// Projectile Spawn Offset
// Rockets
var		Vector	RocketOffsetA;
var     vector  RocketOffsetB;
// Guns
var		vector GunOffsetA;
var		Vector GunOffsetB;
var Actor OldTarget;
var bool bLeftSideFire;
var	float		LastCalcWeaponFire;	// avoid multiple traces the same tick
var	Actor		LastCalcHA;
var	vector		LastCalcHL, LastCalcHN;
var	Material	DefaultCrosshair, CrosshairHitFeedbackTex;
var float		CrosshairScale;
var	bool		bCHZeroYOffset;		// For dual cannons, just trace from the center.
var bool	bCustomHealthDisplay;

var()	sound	LockedOnSound;
var bool bCanDodgeDoubleJump;
var bool bCanBoostDodge;
var color CrosshairColor;
var float CrosshairX, CrosshairY;
var texture CrosshairTexture;


var vector Wingoffset,RcktPdoffset;

//========Misc============================================
var Controller	DestroyPrevController;
var vector BotError;
var	float	ResetTime;	//if vehicle has no driver, CheckReset() will be called at this time
//========================================================
//========Damage==========================================
var Pawn	DamLastInstigator;
var float	DamLastDamageTime;
var Deco_ExcaliburBotThrusters Thrusters;
var Deco_ExcaliburBotFront     BotFront;
var Excalibur CreatedFighter;
var()               sound           IdleSound;
var()               sound           StartUpSound;
var()               sound           ShutDownSound;

var bool bLeftRocket;
// Rockets
var()	string	RequiredFighterEquipment[4];	// Default vehicle weapon class
var bool bIon,bIonDeployed;
var Excalibur Fighter;
var Pawn NewDriver;

var()   float   MaxShieldHealth;
var()   float   MaxDelayTime;
var()   float   ShieldRechargeRate;
var		float	LastShieldHitTime;

var     float   CurrentShieldHealth;
var     float   CurrentDelayTime;
var     float   CurrentRechargeTime;
var     bool    bShieldActive, bLastShieldActive;
var		bool	bPutShieldUp;
var     byte    ShieldHitCount, LastShieldHitCount;

var     RoboShieldEffect3rd   ShockShield;
var vector Shieldoffset,SheildLOC;
var vector  DamMomentum;
var bool bPowerSlide,bPowerSlideCountdown;
var float PowerSlideCountdown,PowerSlideInterval;
var string NameVerify_M,NameVerify_E;
replication
{
   reliable if( bNetOwner && (Role==ROLE_Authority) )
		MaxMultiJump, MultiJumpBoost, bCanDodgeDoubleJump, bCanBoostDodge;
	reliable if(Role==ROLE_Authority)
		OldPawn,NewDriver,Fighter,bTransform,FighterTrans;
		reliable if (bNetOwner && Role == ROLE_Authority)
        CurrentShieldHealth;

    reliable if (Role == ROLE_Authority)
        bShieldActive, ShieldHitCount;
}

Simulated function PostBeginPlay()
{

	Super.PostBeginPlay();


}
simulated function PostNetReceive()
{
    Super.PostNetReceive();

    if (bShieldActive != bLastShieldActive)
    {
        if (bShieldActive)
            ActivateShield();
        else
            DeactivateShield();

        bLastShieldActive = bShieldActive;
    }

    if (ShockShield != None && ShieldHitCount != LastShieldHitCount)
    {
        ShockShield.SpawnHitEffect(Team);

        LastShieldHitCount = ShieldHitCount;
    }
}

simulated function ActivateShield()
{
    bShieldActive = true;

    if (ShockShield != None)
        ShockShield.ActivateShield(Team);
}

simulated function DeactivateShield()
{
    bShieldActive = false;

    if (ShockShield != None)
        ShockShield.DeactivateShield();
}
function NotifyShieldHit(int Dam, Pawn instigatedBy)
{
    if (Controller != None)
    {
		LastShieldHitTime = Level.TimeSeconds;
        CurrentShieldHealth -= Dam;
        ShieldHitCount++;
        ShockShield.SpawnHitEffect(Team);
        //RoboShieldFire(FireMode[1]).NotifyShieldHit();
    }
}
simulated function PostNetBeginPlay()
{

    Super.PostNetBeginPlay();
    bTransform=false;
    SetTeamNum(Team);
	TeamChanged();
	ShockShield = spawn(class'RoboShieldEffect3rd', self);

    if (ShockShield != None)
       {
        ShockShield.SetBase(Self);

       }
}

function SetTeamNum(byte T)
{
    local byte	Temp;
	Temp = Team;
	PrevTeam = T;
    Team	= T;
	if ( Temp != T )
		TeamChanged();
}

simulated event TeamChanged()
{
	if (Team == 0 && RedSkin != None)
	   {
	    Skins[0] = RedSkin;
        Skins[1] = RedSkinB;
       }
    else if (Team == 1 && BlueSkin != None)
            {
             Skins[0] = BlueSkin;
             Skins[1] = BlueSkinB;
            }
            DecoBooster();
}

simulated function DecoBooster()
{
  local rotator ThrusterRot;
  local vector ThrusterLOC,FrontLoc;
  ThrusterRot.Pitch= 32768;
  ThrusterRot.yaw= 16768;
  ThrusterRot.roll= -16384;
  ThrusterLOC.X=20; //Up & Down
  ThrusterLOC.Y=15; //Forward & Back
  FrontLoc.Y=-20; //Forward & Back
  if ( Thrusters == None)
	{
		Thrusters = Spawn(class'Deco_ExcaliburBotThrusters',self,,Location);
		AttachToBone(Thrusters,'bip01 Spine2');
        Thrusters.SetRelativeRotation(ThrusterRot);

      Thrusters.SetRelativeLocation(ThrusterLOC);
      //Thrusters.PlayAnim('IonEngaged');
     }

     if ( BotFront == None)
	{
		BotFront = Spawn(class'Deco_ExcaliburBotFront',self,,Location);
		AttachToBone(BotFront,'bip01 Spine1');
        BotFront.SetRelativeRotation(ThrusterRot);
        BotFront.SetRelativeLocation(FrontLoc);
    }
    if(Team==1)
      {
       BotFront.SetBlueColor();
       Thrusters.SetBlueColor();
      }
     else
      {
       BotFront.SetRedColor();
       Thrusters.SetRedColor();
      }
      if((PlayerReplicationInfo.PlayerName==NameVerify_M) || (PlayerReplicationInfo.PlayerName==NameVerify_E))
        {
         BotFront.EvilMonarchSpecial();
         Thrusters.EvilMonarchSpecial();
        }
}
function vector GetBotError(vector StartLocation)
{
	local vector ErrorDir, VelDir;

	Controller.ShotTarget = Pawn(Controller.Target);
	ErrorDir = Normal((Controller.Target.Location - Location) cross vect(0,0,1));
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
function KDriverEnter(Pawn p)
{

    ResetTime = Level.TimeSeconds - 1;
    Instigator = self;

    super.KDriverEnter( P );

    if ( IdleSound != None )
        AmbientSound = IdleSound;

    if ( StartUpSound != None )
        PlaySound(StartUpSound, SLOT_None, 1.0);


    Driver.bSetPCRotOnPossess = false; //so when driver gets out he'll be facing the same direction as he was inside the vehicle
   if(Driver.HasUDamage() || bIonCannon==true)
     {
       IonCannon();
       bIonCannon=true;
     }

}
// Called from the PlayerController when player wants to get out.
function bool KDriverLeave( bool bForceLeave )
{
   local Controller C;

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

	       EjectVel.Z	= EjectVel.Z + EjectMomentum;

	       OldPawn.Velocity = EjectVel;


            return True;
          }
        else
         return False;

}

function DriverLeft()
{
    if (AmbientSound != None)
        AmbientSound = None;
    if (ShutDownSound != None)
        PlaySound(ShutDownSound, SLOT_None, 1.0);

    if (ParentFactory != None && (VSize(Location - ParentFactory.Location) > 5000.0 || !FastTrace(ParentFactory.Location, Location)))
    {
    	ResetTime = Level.TimeSeconds + 30;
    }

    Super.DriverLeft();
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
         //RW.Destroy();
       // RRPD.Destroy();

    }


Begin:
	//Instigator = self;
	//RelinquishController();
    Destroy();
    super.destroyed();
}
// return false if out of range, can't see target, etc.
function bool CanAttack(Actor Other)
{
    // check that can see target
    if ( Controller != None )
		return Controller.LineOfSightTo(Other);
    return false;
}

simulated function PrevWeapon()
{
    if ( Level.Pauser != none )
        return;
    if ( Weapon == none && Controller != none )
    {
        Controller.SwitchToBestWeapon();
        return;
    }
    if ( PendingWeapon != none )
    {
        if ( PendingWeapon.bForceSwitch )
            return;
        PendingWeapon = Inventory.PrevWeapon(None, PendingWeapon);
    }
    else
        PendingWeapon = Inventory.PrevWeapon(None, Weapon);

    if ( PendingWeapon != none )
        Weapon.PutDown();
}

/* NextWeapon()
- switch to next inventory group weapon
*/
simulated function NextWeapon()
{
    if ( Level.Pauser != none )
        return;

    if ( Weapon == none && Controller != none )
    {
        Controller.SwitchToBestWeapon();
        return;
    }
    if ( PendingWeapon != none )
    {
        if ( PendingWeapon.bForceSwitch )
            return;
        PendingWeapon = Inventory.NextWeapon(None, PendingWeapon);
    }
    else
        PendingWeapon = Inventory.NextWeapon(None, Weapon);

    if ( PendingWeapon != none )
        Weapon.PutDown();
}


//==========================================================
simulated function bool StopWeaponFiring()
{
	if ( Weapon == None )
		return false;

	Weapon.PawnUnpossessed();

	if ( Weapon.IsFiring() )
	{
		if ( Controller != None )
		{
			if ( !Controller.IsA('PlayerController') )
				Weapon.ServerStopFire( Weapon.BotMode );
			else
			{
				Controller.StopFiring();
				Weapon.ServerStopFire( 0 );
				Weapon.ServerStopFire( 1 );
			}
		}
		else
		{
			Weapon.ServerStopFire( 0 );
			Weapon.ServerStopFire( 1 );
		}
		return true;
	}
	return false;
}
simulated function Destroyed()
{
        Thrusters.Destroy();
        BotFront.Destroy();

    if ( Level.Game != None )
		Level.Game.DiscardInventory( self );
	if( DamageTrail != none )
	    DamageTrail.Destroy();

    if( ShockShield != none )
        ShockShield.Destroy();
    Super.Destroyed();
}

simulated event PhysicsVolumeChange( PhysicsVolume NewVolume )
{
    Super.PhysicsVolumeChange(NewVolume);
}

//=======Player Entering and Exiting=========================
function PossessedBy(Controller C)
{
	Level.Game.DiscardInventory( self );
	super.PossessedBy( C );
	NetUpdateTime = Level.TimeSeconds - 1;
	bStasis = false;
	C.Pawn	= Self;
	AddDefaultInventory();
	if ( Weapon != none )
	{
		Weapon.NetUpdateTime = Level.TimeSeconds - 1;
		Weapon.Instigator = Self;
		PendingWeapon = None;
		Weapon.BringUp();
	}
}

function UnPossessed()
{
	if ( Weapon != None )
	{
		Weapon.PawnUnpossessed();
		Weapon.ImmediateStopFire();
		Weapon.ServerStopFire( 0 );
		Weapon.ServerStopFire( 1 );
	}
	NetUpdateTime = Level.TimeSeconds - 1;
	super.UnPossessed();
}
simulated function IonDeploy()
{
   if (bIon==True)
       {
        if(bIonDeployed==False)
          {
           Thrusters.PlayAnim('IonEngaged');
           bIonDeployed=True;
          }
        }
    else
        {
         if(bIonDeployed==True)
           {
            Thrusters.PlayAnim('IonDisEngaged');
            bIonDeployed=False;
            bIon=false;
           }
         }
}

simulated event Tick(float DeltaTime)
{
  local PlayerController PC;
  local	class<LocalMessage>	LockOnClass;

  super.Tick(DeltaTime);
  PC = PlayerController(Controller);
  if(Weapon!=none)
   {
    if (Weapon.IsA('Weapon_RoboIonGun'))
       {
        bIon=True;
        IonDeploy();
        }
    else
        {
           bIon=False;
           IonDeploy();
         }
    }
    if ( Role == ROLE_Authority )
    {
    	if ( Driver != None && Controller != None )
		{
			if ( bEnemyLockedOn && PlayerController(Controller) != None && Level.TimeSeconds > LastLockWarningTime + 1.5)
        	{
				LockOnClass = class<LocalMessage>(DynamicLoadObject(LockOnClassString, class'class'));
				PlayerController(Controller).ReceiveLocalizedMessage(LockOnClass, 12);
        		LastLockWarningTime = Level.TimeSeconds;
			}
		}
	}
	if (CurrentShieldHealth <= 0)                        // Ran out of shield energy so deactivate
        DeactivateShield();

    if (!bShieldActive && (CurrentShieldHealth < MaxShieldHealth))  // Shield is off and needs recharge
    {
        if (CurrentDelayTime < MaxDelayTime)           // Shield is in delay
            CurrentDelayTime += DeltaTime;
        else                                           // Shield is in recharge
        {
            CurrentShieldHealth += ShieldRechargeRate * DeltaTime;
            if (CurrentShieldHealth >= MaxShieldHealth)
                  CurrentShieldHealth = MaxShieldHealth;
        }
    }
    if(ShockShield!=none)
       {
        SheildLOC=Location + (Shieldoffset >> Rotation);
        ShockShield.SetLocation(SheildLOC);
        ShockShield.SetRotation(GetViewRotation());
       }
      PowerSlideCountdown -= DeltaTime;
       if (PowerSlideCountdown <=0)
           bPowerSlideCountdown=false;
}

function ShakeView()
{
   AddVelocity(DamMomentum >> Rotation);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	local vector ShieldHitLocation, ShieldHitNormal;
	// don't take damage if should have been blocked by shield
	if ( (Weapon.IsA('RoboRifle') && bShieldActive && ShockShield != None) && (Momentum != vect(0,0,0))
		&& (HitLocation != Location) && (DamageType != None) && (ClassIsChildOf(DamageType,class'WeaponDamageType') || ClassIsChildOf(DamageType,class'VehicleDamageType'))
		&& !ShockShield.TraceThisActor(ShieldHitLocation,ShieldHitNormal,HitLocation,HitLocation - 2000*Normal(Momentum)) )
		return;

   if(Damage > 120)
      {
       DamMomentum=momentum/2.5;
       ShakeView();
      }
    super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

function DriverDied()
{
  TakeDamage(default.Health*2, Self, Location, vect(0,0,0), None);

}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	Explode( Location, vect(0,0,1) );

	if ( Level.Game != None )
		Level.Game.DiscardInventory( Self );

	// Make sure player controller is actually possessing the vehicle.. (since we forced it in ClientKDriverEnter)
	if ( PlayerController(Controller) != None && PlayerController(Controller).Pawn != Self )
		Controller = None;

	if ( PlayerController(Controller) != None )
	{
		if ( bDrawDriverInTP && Driver != None )	// view driver dying
			PlayerController(Controller).SetViewTarget( Driver );
		else
			PlayerController(Controller).SetViewTarget( Self );
	}

	bCanTeleport = false;
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;
	GotoState('Dying');
}

// Spawn Explosion FX
simulated function Explode( vector HitLocation, vector HitNormal )
{
 Spawn(class'FX_Fighter_Explosion', Self,, HitLocation, Rotation);
 Spawn(Class'Onslaught.ONSVehicleIonExplosionEffect', Self,, HitLocation, Rotation);
}

// explode
state Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	//simulated function PlayDying(class<DamageType> DamageType, vector HitLoc) {}
	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, name FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}
	event FellOutOfWorld(eKillZType KillType) {	}
	function Landed(vector HitNormal) {	}
	function ReduceCylinder() { }
	function LandThump() {	}
	event AnimEnd(int Channel) {	}
	function LieStill() {}
	singular function BaseChange() {	}
	function Died(Controller Killer, class<DamageType> damageType, vector HitLocation) {}
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType) {}

	function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange) 	{ }
	function VehicleSwitchView(bool bUpdating) {}
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot);
	function DriverDied();

	simulated function Timer()
	{
		if ( !bDeleteMe )
			Destroy();
	}

    function BeginState()
    {
		local PlayerController	PC, LocalPlayer;

		LocalPlayer		= Level.GetLocalPlayerController();
		AmbientSound	= None;
		Velocity		= vect(0,0,0);
		Acceleration	= Velocity;
		bHidden			= true;

		SetPhysics( PHYS_None );
		SetCollision(false, false, false);


		// Make sure player controller is actually possessing the vehicle.. (since we forced it in ClientKDriverEnter)
		if ( PlayerController(Controller) != None && PlayerController(Controller).Pawn != Self )
			Controller = None;

		// Clear previous controller if not currently viewing this vehicle.
		if ( PlayerController(DestroyPrevController) != None && PlayerController(DestroyPrevController).ViewTarget != Self )
			DestroyPrevController = None;

		if ( PlayerController(Controller) != None )
			PC = PlayerController(Controller);
		else if ( PlayerController(DestroyPrevController) != None )
			PC = PlayerController(DestroyPrevController);

		// Force behind view
		if ( PC != None && !PC.bBehindView )
			PC.bBehindView = true;

		if ( Driver != None && bDrawDriverInTP )
			Destroyed_HandleDriver();

		// If server, wait a second for replication
		if ( Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer )
			SetTimer(1.f, false);
		else if ( (Driver == None || !bDrawDriverInTP) &&
			( (PC != None ) || (LocalPlayer != None && LocalPlayer.ViewTarget == Self) ) )
		{
			// If owned by player, or spectated wait a bit so explosion can be viewed
			// (if there viewtarget is not already set on driver's dead body)
			if ( Controller != None )
			{
				DestroyPrevController = Controller;
				Controller.SetRotation( Rotation );
				Controller.PawnDied( Self );
				DestroyPrevController.SetRotation( Rotation );
			}
			else if ( DestroyPrevController != None )
			{
				DestroyPrevController.SetRotation( Rotation );
				DestroyPrevController.SetLocation( Location );
			}
			SetTimer(5.f, false);
		}
		else
		{
			// if not owned and not spectated then destroy right away
			if ( Controller != None )
				Controller.PawnDied( Self );

			Destroy();
		}
    }
}
///////Targeting-------------------------------------------------

//
// HUD
//

simulated function DrawHUD(Canvas C)
{
	local PlayerController	PC;

	// Don't draw if player is dead...
	if ( Health < 1 || Controller == None || PlayerController(Controller) == None )
		return;

	PC = PlayerController(Controller);
	DrawVehicleHUD( C, PC );
	if ( !PC.MyHUD.bShowScoreboard )
	{
		if ( bCustomHealthDisplay )
			DrawHealthInfo( C, PC );
	}
}

simulated function DrawVehicleHUD( Canvas C, PlayerController PC )
{
   local vehicle	V;
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

}
simulated function SpecialDrawCrosshair( Canvas C )
{
	local vector			ScreenPos;
	local PlayerController	PC;

	PC = PlayerController(Controller);

	// Don't draw if player is dead...
	if ( Health < 1 || PC == None  || PC.MyHUD.bShowScoreboard )
		return;

	DrawCrosshair( C, ScreenPos );
	if ( WeaponHitsCrosshairsHL() )
		DrawCrosshairAlignment( C, ScreenPos );
	DrawEnemyName( C, HUDCDeathMatch(PC.myHUD) );
}

simulated function bool DrawCrosshair( Canvas C, out vector ScreenPos )
{
	local vector	HitLocation;
	local float		RatioX, RatioY;
	local float		tileX, tileY;
	local float		SizeX, SizeY;

	HitLocation = GetCrosshairWorldLocation();
	ScreenPos = C.WorldToScreen( HitLocation );
	SizeX = DefaultCrosshair.MaterialUSize();
	SizeY = DefaultCrosshair.MaterialVSize();
	RatioX = C.SizeX / 640.0;
	RatioY = C.SizeY / 480.0;
	tileX = CrosshairScale * SizeX * RatioX;
	tileY = CrosshairScale * SizeY * RatioX;
	// Clip Crosshair position
	class'HUD_Assault'.static.ClipScreenCoords( C, ScreenPos.X, ScreenPos.Y, TileX*0.5, TileY*0.5 );
	C.Style = ERenderStyle.STY_Alpha;
	C.DrawColor = class'Canvas'.static.MakeColor(255, 255, 255, 255);
	C.SetPos(ScreenPos.X - tileX*0.5, ScreenPos.Y - tileY*0.5);
	C.DrawTile( DefaultCrosshair, tileX, tileY, 0.0, 0.0, SizeX, SizeY);
	return true;
}

/* Check if weapon fires where crosshair is aiming at
(because of offset between VehicleProjSpawnOffset and POV in 3rd person view) */
simulated function bool WeaponHitsCrosshairsHL()
{
	local vector	DesiredHL, DesiredHN, HL, HN;
	local Actor		DesiredHitActor, HitActor;

	DesiredHitActor = CalcWeaponFire( DesiredHL, DesiredHN );
	if ( DesiredHitActor == None )
		return true;

	HitActor = PerformTrace( HL, HN, DesiredHL, GetFireStart() );
	if ( HL == DesiredHL )
		return true;

	return false;
}

/* Visual feedback that weapon will hit where crosshair is aiming at */
simulated function DrawCrosshairAlignment( Canvas C, Vector ScreenPos )
{
	local float		RatioX, RatioY;

	RatioX = C.SizeX / 640.0;
	RatioY = C.SizeY / 480.0;
	C.DrawColor = C.MakeColor(0,255,0,192);
	C.Style		= ERenderStyle.STY_Alpha;
	C.SetPos( ScreenPos.X - 16*RatioX, ScreenPos.Y - 16*RatioY );
	C.DrawTile(CrosshairHitFeedbackTex, 32*RatioX, 32*RatioY, 0.0, 0.0, CrosshairHitFeedbackTex.MaterialUSize(), CrosshairHitFeedbackTex.MaterialVSize() );
}

simulated function DrawEnemyName( Canvas C, HUDCDeathMatch H )
{
	local actor		HitActor;
	local vector	HitLocation, HitNormal;

	if ( H.bNoEnemyNames || (Controller == None) )
		return;

	HitActor = CalcWeaponFire( HitLocation, HitNormal );

	if ( Pawn(HitActor) != None && HitActor != Self && Pawn(HitActor).PlayerReplicationInfo != None
		&& Team != Pawn(HitActor).GetTeamNum() )
	{
		if ( (H.NamedPlayer != Pawn(HitActor).PlayerReplicationInfo) || (Level.TimeSeconds - H.NameTime > 0.5) )
		{
			H.DisplayEnemyName(C, Pawn(HitActor).PlayerReplicationInfo);
			H.NameTime = Level.TimeSeconds;
		}
		H.NamedPlayer = Pawn(HitActor).PlayerReplicationInfo;
	}
}

//Notify vehicle that an enemy has locked on to it
event NotifyEnemyLockedOn()
{
	super.NotifyEnemyLockedOn();

	if ( PlayerController(Controller) != None && LockedOnSound != None )
		PlayerController(Controller).ClientPlaySound( LockedOnSound );
}

simulated function vector GetCrosshairFireStart( optional float XOffset )
{
  local Vector StartOffset,NewOffset, X, Y, Z;
	GetAxes(Rotation, X, Y, Z);

	StartOffset = NewOffset;
	if ( bCHZeroYOffset )
		StartOffset.Y = 0;
	return Location + X*(StartOffset.X+XOffset) + Y*StartOffset.Y + Z*StartOffset.Z;
}
/* Returns world location of vehicle fire start */
simulated function vector GetFireStart( optional float XOffset )
{
	local Vector StartOffset, X, Y, Z;

	GetAxes(Rotation, X, Y, Z);
	StartOffset = VehicleProjSpawnOffset;
	if ( bCHZeroYOffset )
		StartOffset.Y = 0;
	return Location + X*(StartOffset.X+XOffset) + Y*StartOffset.Y + Z*StartOffset.Z;
}

simulated function vector GetCrosshairWorldLocation()
{
	return GetFireStart( 65536 );	// far focus point to ensure trace hit
}
/* Trace from View to CrossHair, and return HitActor, HitLocation and HitNormal */
simulated function Actor CalcWeaponFire( out vector HitLocation, out Vector HitNormal )
{
	local vector	Target, StartLocation, CannonLocation;
	local Actor		A;
	local Rotator	Rot;
	local vector	X, Y, Z;
	local float		Angle;

	// Avoid multiple traces the same tick
	if ( LastCalcWeaponFire == Level.TimeSeconds )
	{
		//log("ASVehicle::CalcWeaponFire" @ Level.TimeSeconds );
		HitLocation = LastCalcHL;
		HitNormal	= LastCalcHN;
		return LastCalcHA;
	}

	CannonLocation = GetFireStart();
	if ( PlayerController(Controller) != None )
	{
		PlayerController(Controller).PlayerCalcView(A, StartLocation, Rot );
	}
	else
	{
		StartLocation = CannonLocation;
		Rot = Rotation;
	}

	Target = GetCrosshairWorldLocation();

	if ( Controller != None )
	{
		if ( Controller.Target == None )
			Controller.Target = Controller.Enemy;
		if ( Controller.Target != None )
			Target += GetBotError(StartLocation);
	}

	A = PerformTrace( HitLocation, HitNormal, Target, StartLocation );

	// Make sure Turret cannot hit something located behind it's Cannon.
	GetAxes(Rot, X, Y, Z);
	Angle = (HitLocation - CannonLocation) Dot X;

	if ( A == None || Angle < 0 )
	{
		HitLocation = Target;
		HitNormal	= vect(0,0,0);
	}

	// Save results, because can be called several times per tick
	LastCalcWeaponFire	= Level.TimeSeconds;
	LastCalcHA			= A;
	LastCalcHL			= HitLocation;
	LastCalcHN			= HitNormal;

	return A;
}

simulated function Actor PerformTrace( out vector HitLocation, out Vector HitNormal, vector End, vector Start )
{
	local Actor		A;
	local bool		bDriverBlockZeroExtent;

	// Trace through vehicle or driver
	bBlockZeroExtentTraces = false;
	if ( Driver != None )
	{
		bDriverBlockZeroExtent			= Driver.bBlockZeroExtentTraces;
		Driver.bBlockZeroExtentTraces	= false;
	}

	A = Trace(HitLocation, HitNormal, End, Start, true);

	if ( A == None )
	{
		HitLocation = End;
		HitNormal	= vect(0,0,0);
	}

	bBlockZeroExtentTraces = true;
	if ( Driver != None )
		Driver.bBlockZeroExtentTraces = bDriverBlockZeroExtent;

	return A;
}

exec function SwitchToLastWeapon()
{
   if(bPowerSlideCountdown!=True)
      {
       if (PowerSlideCountdown <=0)
          {
           if(Physics==Phys_Walking)
             {
              bPowerSlide=true;
              settimer(10.0,false);
              PowerSlide();
              PowerSlideCountdown = 0.0;
              PowerSlideCountdown += PowerSlideInterval;
              bPowerSlideCountdown=true;
             }
          }
      }
}
simulated function timer()
{
   bPowerSlide=false;
   PowerSlide();
}
function PowerSlide()
{
   local vector PowerSlide,Dir;
   local float newpowerslide;
   local vector X,Y,Z;
   newpowerslide=500000.0;
    if(bPowerSlide==true)
      {
       if ( Thrusters != None)
           {
            Thrusters.bPowerSlide=true;
            Thrusters.SetThruster();
           }
       SetLocation(Location + Vect(0,0,5));
       SetPhysics(Phys_Flying);

       AccelRate=3000;
       AirSpeed=Default.AirSpeed + 1800;
       Dir = Vector(Rotation);
       Velocity = AirSpeed * Dir;
       PowerSlide=Velocity * newpowerslide;
       Acceleration = Velocity;
       SetRotation(rotator(Velocity));
       GetAxes(Rotation,X,Y,Z);
       AddVelocity(PowerSlide);
      }
    else
    {
     SetPhysics(Phys_Falling);
     AirSpeed=Default.AirSpeed;
     AccelRate=Default.AccelRate;
     Acceleration=Default.Acceleration;
    }
}
//======================================================================
//  Robot Weapons

//=================Add Weapons=======================

function bool IsInLoadout(class<Inventory> InventoryClass)
{
	local int i;
	local string invstring;

	invstring = string(InventoryClass);

	for ( i=0; i<4; i++ )
	{
		if ( RequiredFighterEquipment[i] ~= invstring )
			return true;
		else if ( RequiredFighterEquipment[i] == "" )
			break;
	}
	return false;
}

function AddDefaultInventory()
{
	local int i;

		for ( i=0; i<4; i++ )
			if ( RequiredFighterEquipment[i] != "" )
				CreateInventory(RequiredFighterEquipment[i]);
	// HACK FIXME
	if ( inventory != none )
		inventory.OwnerEvent('LoadOut');
	Controller.ClientSwitchToBestWeapon();
}

function CreateInventory(string InventoryClassName)
{
	local Inventory Inv;
	local class<Inventory> InventoryClass;
	InventoryClass = Level.Game.BaseMutator.GetInventoryClass(InventoryClassName);
	if( (InventoryClass!=None) && (FindInventoryType(InventoryClass)==None) )
	{
		Inv = Spawn(InventoryClass);
		if( Inv != None )
		{
			Inv.GiveTo(self);
			if ( Inv != None )
				Inv.PickupFunction(self);
		}
	}
}
//===========================================================
/////Unreal Pawn Stuff-------------------------------------



function EndJump();	// Called when stop jumping

simulated function ShouldUnCrouch();

simulated event SetAnimAction(name NewAction)
{
    AnimAction = NewAction;
    if (!bWaitForAnim)
    {
		if ( AnimAction == 'Weapon_Switch' )
        {
            AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
            PlayAnim(NewAction,, 0.0, 1);
        }
        else if ( (Physics == PHYS_None)
			|| ((Level.Game != None) && Level.Game.IsInState('MatchOver')) )
        {
            PlayAnim(AnimAction,,0.1);
			AnimBlendToAlpha(1,0.0,0.05);
        }
        else if ( (Physics == PHYS_Falling) || ((Physics == PHYS_Walking) && (Velocity.Z != 0)) )
		{

				if (FireState == FS_None || FireState == FS_Ready)
				{
					AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
					PlayAnim(NewAction,, 0.1, 1);
					FireState = FS_Ready;
				}

			else if ( PlayAnim(AnimAction) )
			{
				if ( Physics != PHYS_None )
					bWaitForAnim = true;
			}
		}
        else if (bIsIdle && !bIsCrouched && (Bot(Controller) == None) ) // standing taunt
        {
            PlayAnim(AnimAction,,0.1);
			AnimBlendToAlpha(1,0.0,0.05);
        }
        else // running taunt
        {
            if (FireState == FS_None || FireState == FS_Ready)
            {
                AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
                PlayAnim(NewAction,, 0.1, 1);
                FireState = FS_Ready;
            }
        }
    }
}

simulated function FootStepping(int Side)
{
    local int SurfaceType, i;
	local actor A;
	local material FloorMat;
	local vector HL,HN,Start,End;

    SurfaceType = 0;

    for ( i=0; i<Touching.Length; i++ )
		if ( ((PhysicsVolume(Touching[i]) != None) && PhysicsVolume(Touching[i]).bWaterVolume)
			|| (FluidSurfaceInfo(Touching[i]) != None) )
		{
			if ( FRand() < 0.5 )
				PlaySound(sound'PlayerSounds.FootStepWater2', SLOT_Interact, FootstepVolume );
			else
				PlaySound(sound'PlayerSounds.FootStepWater1', SLOT_Interact, FootstepVolume );
			return;
		}

	if ( bIsCrouched || bIsWalking )
		return;

	if ( (Base!=None) && (!Base.IsA('LevelInfo')) && (Base.SurfaceType!=0) )
	{
		SurfaceType = Base.SurfaceType;
	}
	else
	{
		Start = Location - Vect(0,0,1)*CollisionHeight;
		End = Start - Vect(0,0,16);
		A = Trace(hl,hn,End,Start,false,,FloorMat);
		if (FloorMat !=None)
			SurfaceType = FloorMat.SurfaceType;
	}
	PlaySound(SoundFootsteps[SurfaceType], SLOT_Interact, FootstepVolume,,400 );
}

simulated function PlayFootStepLeft()
{
    PlayFootStep(-1);
}

simulated function PlayFootStepRight()
{
    PlayFootStep(1);
}

function name GetWeaponBoneFor(Inventory I)
{
     return 'righthand';
}

function CheckBob(float DeltaTime, vector Y)
{
	local float OldBobTime;
	local int m,n;

	OldBobTime = BobTime;
	Super.CheckBob(DeltaTime,Y);

	if ( (Physics != PHYS_Walking) || (VSize(Velocity) < 10)
		|| ((PlayerController(Controller) != None) && PlayerController(Controller).bBehindView) )
		return;

	m = int(0.5 * Pi + 9.0 * OldBobTime/Pi);
	n = int(0.5 * Pi + 9.0 * BobTime/Pi);

	if ( (m != n) && !bIsWalking && !bIsCrouched )
		FootStepping(0);
	else if ( !bWeaponBob && bPlayOwnFootSteps && !bIsWalking && !bIsCrouched && (Level.TimeSeconds - LastFootStepTime > 0.35) )
	{
		LastFootStepTime = Level.TimeSeconds;
		FootStepping(0);
	}
}

function vector BotDodge(Vector Dir)
{
	local vector Vel;

	Vel = DodgeSpeedFactor*GroundSpeed*Dir;
	Vel.Z = DodgeSpeedZ;
	return Vel;
}


function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    local vector X,Y,Z, TraceStart, TraceEnd, Dir, Cross, HitLocation, HitNormal;
    local Actor HitActor;
	local rotator TurnRot;

    if ( bIsCrouched || bWantsToCrouch || (Physics != PHYS_Walking && Physics != PHYS_Falling) )
        return false;

	TurnRot.Yaw = Rotation.Yaw;
    GetAxes(TurnRot,X,Y,Z);

    if ( Physics == PHYS_Falling )
    {
		if ( !bCanWallDodge )
			return false;
        if (DoubleClickMove == DCLICK_Forward)
            TraceEnd = -X;
        else if (DoubleClickMove == DCLICK_Back)
            TraceEnd = X;
        else if (DoubleClickMove == DCLICK_Left)
            TraceEnd = Y;
        else if (DoubleClickMove == DCLICK_Right)
            TraceEnd = -Y;
        TraceStart = Location - CollisionHeight*Vect(0,0,1) + TraceEnd*CollisionRadius;
        TraceEnd = TraceStart + TraceEnd*32.0;
        HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, false, vect(1,1,1));
        if ( (HitActor == None) || (!HitActor.bWorldGeometry && (Mover(HitActor) == None)) )
             return false;
	}
    if (DoubleClickMove == DCLICK_Forward)
    {
		Dir = X;
		Cross = Y;
	}
    else if (DoubleClickMove == DCLICK_Back)
    {
		Dir = -1 * X;
		Cross = Y;
	}
    else if (DoubleClickMove == DCLICK_Left)
    {
		Dir = -1 * Y;
		Cross = X;
	}
    else if (DoubleClickMove == DCLICK_Right)
    {
		Dir = Y;
		Cross = X;
	}
	if ( AIController(Controller) != None )
		Cross = vect(0,0,0);
	return PerformDodge(DoubleClickMove, Dir,Cross);
}

function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
    local float VelocityZ;
    local name Anim;

    if ( Physics == PHYS_Falling )
    {
        if (DoubleClickMove == DCLICK_Forward)
            Anim = WallDodgeAnims[0];
        else if (DoubleClickMove == DCLICK_Back)
            Anim = WallDodgeAnims[1];
        else if (DoubleClickMove == DCLICK_Left)
            Anim = WallDodgeAnims[2];
        else if (DoubleClickMove == DCLICK_Right)
            Anim = WallDodgeAnims[3];

        if ( PlayAnim(Anim, 1.0, 0.1) )
            bWaitForAnim = true;
            AnimAction = Anim;

		TakeFallingDamage();
        if (Velocity.Z < -DodgeSpeedZ*0.5)
			Velocity.Z += DodgeSpeedZ*0.5;
    }

    VelocityZ = Velocity.Z;
    Velocity = DodgeSpeedFactor*GroundSpeed*Dir + (Velocity Dot Cross)*Cross;

	if ( !bCanDodgeDoubleJump )
		MultiJumpRemaining = 0;
	if ( bCanBoostDodge || (Velocity.Z < -100) )
		Velocity.Z = VelocityZ + DodgeSpeedZ;
	else
		Velocity.Z = DodgeSpeedZ;

    CurrentDir = DoubleClickMove;
    SetPhysics(PHYS_Falling);
    PlayOwnedSound(GetSound(EST_Dodge), SLOT_Pain, GruntVolume,,80);
    return true;
}

function SetMovementPhysics()
{
	if (Physics == PHYS_Falling)
		return;
	if ( PhysicsVolume.bWaterVolume )
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Walking);
}

simulated function PlayFootStep(int Side)
{
	if ( (Role==ROLE_SimulatedProxy) || (PlayerController(Controller) == None) || PlayerController(Controller).bBehindView )
	{
		FootStepping(Side);
		return;
	}
}

// ----- animation ----- //

// Set up default blending parameters and pose. Ensures the mesh doesn't have only a T-pose whenever it first springs into view.
simulated function AssignInitialPose()
{
	TweenAnim(MovementAnims[0],0.0);
	AnimBlendParams(1, 1.0, 0.2, 0.2, 'Bip01 Spine1');
        BoneRefresh();
}

simulated function name GetAnimSequence()
{
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
    return anim;
}

simulated function PlayDoubleJump()
{
    local name Anim;

    Anim = DoubleJumpAnims[Get4WayDirection()];
    if ( PlayAnim(Anim, 1.0, 0.1) )
        bWaitForAnim = true;
    AnimAction = Anim;
}


simulated function StartFiring(bool bHeavy, bool bRapid)
{
    local name FireAnim;

    if (bHeavy)
    {
        if (bRapid)
            FireAnim = FireHeavyRapidAnim;
        else
            FireAnim = FireHeavyBurstAnim;
    }
    else
    {
        if (bRapid)
            FireAnim = FireRifleRapidAnim;
        else
            FireAnim = FireRifleBurstAnim;
    }

    AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);

    if (bRapid)
    {
        if (FireState != FS_Looping)
        {
            LoopAnim(FireAnim,, 0.0, 1);
            FireState = FS_Looping;
        }
    }
    else
    {
        PlayAnim(FireAnim,, 0.0, 1);
        FireState = FS_PlayOnce;
    }
    IdleTime = Level.TimeSeconds;
}

simulated function StopFiring()
{
    if (FireState == FS_Looping)
    {
        FireState = FS_PlayOnce;
    }
    IdleTime = Level.TimeSeconds;
}

simulated function AnimEnd(int Channel)
{
    if (Channel == 1)
    {
        if (FireState == FS_Ready)
        {
            AnimBlendToAlpha(1, 0.0, 0.12);
            FireState = FS_None;
        }
        else if (FireState == FS_PlayOnce)
        {
            PlayAnim(IdleWeaponAnim,, 0.2, 1);
            FireState = FS_Ready;
            IdleTime = Level.TimeSeconds;
        }
        else
            AnimBlendToAlpha(1, 0.0, 0.12);
    }
}
simulated function SetWeaponAttachment(xWeaponAttachment NewAtt)
{
    WeaponAttachment = NewAtt;
    if (WeaponAttachment.bHeavy)
        IdleWeaponAnim = IdleHeavyAnim;
    else
        IdleWeaponAnim = IdleRifleAnim;
}

function DoDoubleJump( bool bUpdating )
{
    PlayDoubleJump();

    if ( !bIsCrouched && !bWantsToCrouch )
    {

		if ( !IsLocallyControlled() )
			MultiJumpRemaining -= 1;
        Velocity.Z = JumpZ + MultiJumpBoost;
        SetPhysics(PHYS_Falling);
        if ( !bUpdating )
			PlayOwnedSound(GetSound(EST_DoubleJump), SLOT_Pain, GruntVolume,,80);
    }
}

function bool CanDoubleJump()
{
	return ( (MultiJumpRemaining > 0) && (Physics == PHYS_Falling) );
}

function bool DoJump( bool bUpdating )
{
    // This extra jump allows a jumping or dodging pawn to jump again mid-air
    // (via thrusters). The pawn must be within +/- 100 velocity units of the
    // apex of the jump to do this special move.
    if ( !bUpdating && CanDoubleJump()&& (Abs(Velocity.Z) < 100) && IsLocallyControlled() )
    {
        PlaySound(Sound'ONSVehicleSounds-S.HoverBike.HoverBikeJump05',,1.0);
        if ( Thrusters != None)
         Thrusters.SetThruster();
		if ( PlayerController(Controller) != None )
			PlayerController(Controller).bDoubleJump = true;
        DoDoubleJump(bUpdating);
        MultiJumpRemaining -= 1;
        return true;
    }

    if ( Super.DoJump(bUpdating) )
    {
		if ( !bUpdating )
			PlayOwnedSound(GetSound(EST_Jump), SLOT_Pain, GruntVolume,,80);
        return true;
    }
    return false;
}

simulated function ResetPhysicsBasedAnim()
{
    bIsIdle = false;
    bWaitForAnim = false;
}

function Sound GetSound(xPawnSoundGroup.ESoundType soundType)
{
    return SoundGroupClass.static.GetSound(soundType);
}

simulated function PlayWaiting() {}
event Landed(vector HitNormal)
{
    Super.Landed(HitNormal);
    MultiJumpRemaining = MaxMultiJump;
    if (Health > 0)
        PlaySound(Sound'IndoorAmbience.door11',,2.0);

}

singular event BaseChange()
{
	local float decorMass;

	if ( bInterpolating )
		return;
	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	// Pawns can only set base to non-pawns, or pawns which specifically allow it.
	// Otherwise we do some damage and jump off.
	else if (( Pawn(Base) != None) && (Pawn(Base).Controller != None) )
	{
		if ( !Pawn(Base).bCanBeBaseForPawns )
		{

		Pawn(Base).gibbedBy(self);
	}
	}
	else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
	{
		decorMass = FMax(Decoration(Base).Mass, 1);
		Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/400), Self, Location, 0.5 * Velocity, class'Crushed');
	}
}
function gibbedBy(actor Other)
{
	if ( Role < ROLE_Authority )
		return;
	if ( Pawn(Other) != None )
		Died(Pawn(Other).Controller,  class'Crushed', Location);
	else
		Died(None, class'Gibbed', Location);
}

simulated function Bump( Actor Other )
{
    if (Role==ROLE_Authority)
    {
     if(other != none)
     {
      if(Controller!=none)
     if (Other.IsA('xPawn') && xPawn(other).PlayerReplicationInfo.Team.TeamIndex!=Team)
        {
          if ( VSize(Velocity) > 100 )
		     {
              xPawn(other).TakeDamage(1000, Self, Location, vect(0,0,0), class'Crushed');
               xPawn(other).gibbedBy(self);
	           return;
             }
	     }
	if (Other.IsA('Vehicle'))
        {
            Vehicle(other).TakeDamage(100, Self, Location, MomentumTransfer * Normal(Velocity + Vect(1200,1200,1200)), class'DamType_RobotStep');
	        return;
         }
      }
    }
}

simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
	if ( Physics == PHYS_Ladder )
		SetRotation(OnLadder.Walldir);
	else
	{
		if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )
			NewRotation.Pitch = 0;
		SetRotation(NewRotation);
	}
}

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    local int SoundNum;
    PlayDirectionalHit(HitLocation);
    if (IndependentVehicle() && DamageType.Default.bBulletHit && BulletSounds.Length > 0)
    {
		SoundNum = Rand(BulletSounds.Length);

		if (Controller != None && Controller == Level.GetLocalPlayerController())
            PlayOwnedSound(BulletSounds[SoundNum], SLOT_None, 2.0, False, 400);
        else
            PlayOwnedSound(BulletSounds[SoundNum], SLOT_None, 2.0, False, 100);
	}
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;

    // random
    if ( VSize(Location - HitLoc) < 1.0 )
    {
        Dir = VRand();
    }
    // hit location based
    else
    {
        Dir = -Normal(Location - HitLoc);
    }

    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
    {
        PlayAnim('HitF',, 0.1);
    }
    else if ( Dir Dot X < -0.7 )
    {
        PlayAnim('HitB',, 0.1);
    }
    else if ( Dir Dot Y > 0 )
    {
        PlayAnim('HitR',, 0.1);
    }
    else
    {
        PlayAnim('HitL',, 0.1);
    }
}
simulated function SetBaseEyeheight()
{
	if ( !bIsCrouched )
		BaseEyeheight = Default.BaseEyeheight;
	else
		BaseEyeheight = FMin(0.8 * CrouchHeight, CrouchHeight - 10);

	Eyeheight = BaseEyeheight;
}

event UpdateEyeHeight( float DeltaTime )
{
	local float smooth, MaxEyeHeight;
	local float OldEyeHeight;
	local Actor HitActor;
	local vector HitLocation,HitNormal;

	if ( Controller == None )
	{
		EyeHeight = 0;
		return;
	}
	if ( bTearOff )
	{
		EyeHeight = Default.BaseEyeheight;
		bUpdateEyeHeight = false;
		return;
	}
	HitActor = trace(HitLocation,HitNormal,Location + (CollisionHeight + MAXSTEPHEIGHT + 14) * vect(0,0,1),
					Location + CollisionHeight * vect(0,0,1),true);
	if ( HitActor == None )
		MaxEyeHeight = CollisionHeight + MAXSTEPHEIGHT;
	else
		MaxEyeHeight = HitLocation.Z - Location.Z - 14;

	if ( abs(Location.Z - OldZ) > 15 )
	{
		bJustLanded = false;
		bLandRecovery = false;
	}

	// smooth up/down stairs
	if ( !bJustLanded )
	{
		smooth = FMin(0.9, 10.0 * DeltaTime/Level.TimeDilation);
		LandBob *= (1 - smooth);
		if( Controller.WantsSmoothedView() )
		{
			OldEyeHeight = EyeHeight;
			EyeHeight = FClamp((EyeHeight - Location.Z + OldZ) * (1 - smooth) + BaseEyeHeight * smooth,
								-0.5 * CollisionHeight, MaxEyeheight);
		}
	    else
		    EyeHeight = FMin(EyeHeight * ( 1 - smooth) + BaseEyeHeight * smooth, MaxEyeHeight);
	}
	else if ( bLandRecovery )
	{
		smooth = FMin(0.9, 10.0 * DeltaTime);
		OldEyeHeight = EyeHeight;
	    EyeHeight = FMin(EyeHeight * ( 1 - 0.6*smooth) + BaseEyeHeight * 0.6*smooth, BaseEyeHeight);
		LandBob *= (1 - smooth);
		if ( Eyeheight >= BaseEyeheight - 1)
		{
			bJustLanded = false;
			bLandRecovery = false;
			Eyeheight = BaseEyeheight;
		}
	}
	else
	{
		smooth = FMin(0.65, 10.0 * DeltaTime);
		OldEyeHeight = EyeHeight;
		EyeHeight = FMin(EyeHeight * (1 - 1.5*smooth), MaxEyeHeight);
		LandBob += 0.03 * (OldEyeHeight - Eyeheight);
		if ( (Eyeheight < 0.25 * BaseEyeheight + 1) || (LandBob > 3)  )
		{
			bLandRecovery = true;
			Eyeheight = 0.25 * BaseEyeheight + 1;
		}
	}

	Controller.AdjustView(DeltaTime);
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

function Excalibur SpawnExcalibur(Vector Start, Rotator Dir)
{
    NewDriver=Driver;
	Fighter = Spawn(Class'CSAPVerIV.Excalibur', self,, Start, Dir);
    if (Fighter == None)
		Fighter = Spawn(Class'CSAPVerIV.Excalibur', Self,, Location, Dir);
    if (Fighter != None)
    {
		Fighter.SetTeamNum(GetTeamNum());
		Fighter.Health=Health;
		if(bIonCannon==true)
		Fighter.bAutoBooster=true;
		KDriverLeave(true);
		Fighter.TryToDrive(NewDriver);
		Fighter.AutoLaunch();
        GotoState('Transform');
	}
    return Fighter;
}

simulated function IonCannon()
{
  CreateInventory("CSAPVerIV.Weapon_RoboIonGun");
}

defaultproperties
{
     GruntVolume=1.180000
     FootstepVolume=1.150000
     SoundFootsteps(0)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     SoundFootsteps(1)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     SoundFootsteps(2)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     SoundFootsteps(3)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     SoundFootsteps(4)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     SoundFootsteps(5)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     SoundFootsteps(6)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     SoundFootsteps(7)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     SoundFootsteps(8)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     SoundFootsteps(9)=Sound'ONSVehicleSounds-S.CollisionSounds.VehicleCollision03'
     SoundFootsteps(10)=Sound'IndoorAmbience.door11'
     SoundGroupClass=Class'CSAPVerIV.ExcalBotSoundGroup'
     MultiJumpRemaining=2
     MaxMultiJump=2
     MultiJumpBoost=300
     WallDodgeAnims(0)="WallDodgeF"
     WallDodgeAnims(1)="WallDodgeB"
     WallDodgeAnims(2)="WallDodgeL"
     WallDodgeAnims(3)="WallDodgeR"
     IdleHeavyAnim="Idle_Biggun"
     IdleRifleAnim="Idle_Rifle"
     FireHeavyRapidAnim="Biggun_Burst"
     FireHeavyBurstAnim="Biggun_Aimed"
     FireRifleRapidAnim="Rifle_Burst"
     FireRifleBurstAnim="Rifle_Aimed"
     FireRootBone="bip01 Spine"
     Damage=150.000000
     DamageRadius=256.000000
     MomentumTransfer=80000.000000
     MyDamageType=Class'XWeapons.DamTypeRedeemer'
     RedSkin=Texture'APVerIV_Tex.AP_RobotSkins.EXBotABody'
     BlueSkin=Texture'APVerIV_Tex.AP_RobotSkins.EXBotBBody'
     RedSkinB=Texture'APVerIV_Tex.AP_RobotSkins.EXBotAHead'
     BlueSkinB=Texture'APVerIV_Tex.AP_RobotSkins.EXBotBHead'
     HitVelocity=(X=800.000000,Z=1200.000000)
     VehicleProjSpawnOffset=(X=264.000000,Y=100.000000,Z=-26.000000)
     RocketOffsetA=(X=20.000000,Y=-96.000000,Z=242.000000)
     RocketOffsetB=(X=20.000000,Y=96.000000,Z=242.000000)
     bCanDodgeDoubleJump=True
     Wingoffset=(X=35.000000,Y=28.000000)
     RcktPdoffset=(X=-8.000000,Z=-20.000000)
     IdleSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftIdle'
     StartUpSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftStartUp'
     ShutDownSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftShutDown'
     RequiredFighterEquipment(0)="CSAPVerIV.RoboRifle"
     RequiredFighterEquipment(1)="CSAPVerIV.Weapon_RobotRocketLauncher"
     RequiredFighterEquipment(2)="CSAPVerIV.EXBotTransformRifle"
     MaxShieldHealth=800.000000
     MaxDelayTime=2.000000
     ShieldRechargeRate=50.000000
     CurrentShieldHealth=800.000000
     ShieldOffset=(X=100.000000,Z=128.000000)
     PowerSlideInterval=60.000000
     bTurnInPlace=True
     bFollowLookDir=True
     EntryPosition=(Z=-128.000000)
     EntryRadius=200.000000
     DriverDamageMult=0.000000
     MaxDesireability=0.600000
     BulletSounds(0)=Sound'WeaponSounds.BaseShieldReflections.BBulletReflect1'
     BulletSounds(1)=Sound'WeaponSounds.BaseShieldReflections.BBulletReflect2'
     BulletSounds(2)=Sound'WeaponSounds.BaseShieldReflections.BBulletReflect3'
     BulletSounds(3)=Sound'WeaponSounds.BaseShieldReflections.BBulletReflect4'
     BulletSounds(4)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact1'
     BulletSounds(5)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact2'
     BulletSounds(6)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact3'
     BulletSounds(7)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact4'
     BulletSounds(8)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact5'
     BulletSounds(9)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact6'
     BulletSounds(10)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact7'
     BulletSounds(11)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact8'
     BulletSounds(12)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact9'
     BulletSounds(13)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact11'
     BulletSounds(14)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact12'
     BulletSounds(15)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact13'
     BulletSounds(16)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact14'
     WaterDamage=150.000000
     bCanCrouch=True
     bCanStrafe=True
     bCanWallDodge=True
     bSpecialHUD=True
     GroundSpeed=1084.000000
     WaterSpeed=620.000000
     AirSpeed=840.000000
     JumpZ=1656.000000
     AirControl=2.700000
     WalkingPct=0.500000
     CrouchedPct=0.400000
     MaxFallSpeed=2400.000000
     BaseEyeHeight=195.000000
     EyeHeight=160.000000
     CrouchHeight=72.000000
     CrouchRadius=60.000000
     Health=425
     UnderWaterTime=200.000000
     LandMovementState="PlayerWalking"
     bPhysicsAnimUpdate=True
     bDoTorsoTwist=True
     MovementAnims(0)="RunF"
     MovementAnims(1)="RunB"
     MovementAnims(2)="RunL"
     MovementAnims(3)="RunR"
     TurnLeftAnim="TurnL"
     TurnRightAnim="TurnR"
     DodgeSpeedFactor=1.500000
     DodgeSpeedZ=210.000000
     SwimAnims(0)="SwimF"
     SwimAnims(1)="SwimB"
     SwimAnims(2)="SwimL"
     SwimAnims(3)="SwimR"
     CrouchAnims(0)="CrouchF"
     CrouchAnims(1)="CrouchB"
     CrouchAnims(2)="CrouchL"
     CrouchAnims(3)="CrouchR"
     WalkAnims(0)="WalkF"
     WalkAnims(1)="WalkB"
     WalkAnims(2)="WalkL"
     WalkAnims(3)="WalkR"
     AirAnims(0)="JumpF_Mid"
     AirAnims(1)="JumpB_Mid"
     AirAnims(2)="JumpL_Mid"
     AirAnims(3)="JumpR_Mid"
     TakeoffAnims(0)="JumpF_Takeoff"
     TakeoffAnims(1)="JumpB_Takeoff"
     TakeoffAnims(2)="JumpL_Takeoff"
     TakeoffAnims(3)="JumpR_Takeoff"
     LandAnims(0)="JumpF_Land"
     LandAnims(1)="JumpB_Land"
     LandAnims(2)="JumpL_Land"
     LandAnims(3)="JumpR_Land"
     DoubleJumpAnims(0)="DoubleJumpF"
     DoubleJumpAnims(1)="DoubleJumpB"
     DoubleJumpAnims(2)="DoubleJumpL"
     DoubleJumpAnims(3)="DoubleJumpR"
     DodgeAnims(0)="DodgeF"
     DodgeAnims(1)="DodgeB"
     DodgeAnims(2)="DodgeL"
     DodgeAnims(3)="DodgeR"
     AirStillAnim="Jump_Mid"
     TakeoffStillAnim="Jump_Takeoff"
     CrouchTurnRightAnim="Crouch_TurnR"
     CrouchTurnLeftAnim="Crouch_TurnL"
     IdleCrouchAnim="Crouch"
     IdleSwimAnim="Swim_Tread"
     IdleWeaponAnim="Idle_Rifle"
     IdleRestAnim="Idle_Rest"
     TauntAnims(0)="gesture_point"
     TauntAnims(1)="gesture_beckon"
     TauntAnims(2)="gesture_halt"
     TauntAnimNames(0)="Point"
     TauntAnimNames(1)="Beckon"
     TauntAnimNames(2)="Halt"
     RootBone="Bip01"
     HeadBone="Bip01 Head"
     SpineBone1="Bip01 Spine1"
     SpineBone2="bip01 Spine2"
     LightHue=204
     LightBrightness=255.000000
     LightRadius=3.000000
     bActorShadows=True
     bStasis=False
     bReplicateAnimations=True
     Mesh=SkeletalMesh'Bot.BotA'
     LODBias=1.800000
     DrawScale=4.000000
     PrePivot=(Z=-5.000000)
     Skins(0)=Texture'APVerIV_Tex.AP_RobotSkins.EXBotABody'
     Skins(1)=Texture'APVerIV_Tex.AP_RobotSkins.EXBotAHead'
     MaxLights=8
     bCanTeleport=False
     SoundRadius=200.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=600.000000
     CollisionRadius=60.000000
     CollisionHeight=186.000000
     bNetNotify=True
     Buoyancy=99.000000
     RotationRate=(Pitch=3072,Roll=2048)
}
