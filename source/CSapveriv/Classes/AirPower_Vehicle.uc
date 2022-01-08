//=============================================================================
// AirPower_Vehicle       AP ver 4
//=============================================================================
// Base class for non Karma vehicles
//=============================================================================

class AirPower_Vehicle extends Vehicle
	abstract config(CSAPVerIV);

//========WEAPONS===============================
var()	string	RequiredFighterEquipment[4];	// Default vehicle weapon class
var()	vector	VehicleProjSpawnOffset;		// Projectile Spawn Offset
var()	vector  VehicleProjSpawnOffsetLeft;
var()	vector  VehicleProjSpawnOffsetRight;
// Rockets
var		Vector	RocketOffsetA;
var     vector  RocketOffsetB;
// Guns
var		vector GunOffsetA;
var		Vector GunOffsetB;
//Passenger Stuff Taken from OnsVehicle
struct export PassengerWeaponStruct
{
    var()           class<APWeaponPawn>            WeaponPawnClass;
    var()           name                            WeaponBone;
};
var(AirPower_Vehicle)       array<PassengerWeaponStruct>    PassengerWeapons;
var                 array<APWeaponPawn>            WeaponPawns;

var Actor OldTarget;
var	float		LastCalcWeaponFire;	// avoid multiple traces the same tick
var	Actor		LastCalcHA;
var	vector		LastCalcHL, LastCalcHN;
//========================================================

//========Special FX======================================
//---Engines

var bool      bPrePareforLanding;
var()   class<Emitter>				ExplosionEffectClass;
//=========================================================

//========SOUNDS===========================================
var()               sound           IdleSound;
var()               sound           StartUpSound;
var()               sound           ShutDownSound;
var()               sound           LaunchSound;
var()	sound	LockedOnSound;
//========================================================

//========HUD=============================================
var	Material	DefaultCrosshair, CrosshairHitFeedbackTex;
var float		CrosshairScale;
var	bool		bCHZeroYOffset;		// For dual cannons, just trace from the center.
var bool	bCustomHealthDisplay;

//========Damage==========================================
var Pawn	DamLastInstigator;
var float	DamLastDamageTime;

//========Misc============================================
var Controller	DestroyPrevController;
var vector BotError;
var	float	ResetTime;	//if vehicle has no driver, CheckReset() will be called at this time
//========================================================

//========Bools===========================================
var bool bNeverReset;
var bool bStealth;
//========================================================

var float  DamMomentum;
replication
{
    reliable if (Role < ROLE_Authority)
    	ServerChangeDriverPosition;

        reliable if(Role==ROLE_Authority)
                  bStealth;

}

// function override
function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum) {}
function ClientDying(class<DamageType> DamageType, vector HitLocation) {}
simulated function Tick(float DeltaTime);
simulated event EvilMonarchSpecial();
simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	if ( Level.Game != None )
		BotError = (1000 - 50 * Level.Game.GameDifficulty) * VRand();
	// Hack to instance correctly the skeletal collision boxes
    GetBoneCoords('');
    SetCollision(false, false);
    SetCollision(true, true);

}

simulated function PostNetBeginPlay()
{
	local vector RotX, RotY, RotZ;
	local int i;
    Super.PostNetBeginPlay();
    GetAxes(Rotation,RotX,RotY,RotZ);
   if (Role == ROLE_Authority)
    {
      // Spawn the Passenger Weapons
        for(i=0;i<PassengerWeapons.Length;i++)
        {
            // Spawn WeaponPawn
            WeaponPawns[i] = spawn(PassengerWeapons[i].WeaponPawnClass, self,, Location);
            WeaponPawns[i].AttachToVehicleB(self, PassengerWeapons[i].WeaponBone);
            AttachToBone(WeaponPawns[i], PassengerWeapons[i].WeaponBone);

            if (!WeaponPawns[i].bHasOwnHealth)
            	WeaponPawns[i].HealthMax = HealthMax;
            WeaponPawns[i].ObjectiveGetOutDist = ObjectiveGetOutDist;
        }

    }
    SetTeamNum(Team);
	TeamChanged();
}


simulated event Destroyed()
{
    local int i;
    super.Destroyed();
	if ( Level.Game != None )
		Level.Game.DiscardInventory( Self );
    // Destroy the weapons
    if (Role == ROLE_Authority)
    {
	    for(i=0;i<WeaponPawns.Length;i++)
        	WeaponPawns[i].Destroy();
    }
    WeaponPawns.Length = 0;
	TriggerEvent(Event, self, None);
}

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

function KDriverEnter(Pawn p)
{
    ResetTime = Level.TimeSeconds - 1;
    Instigator = self;
    super.KDriverEnter( P );
    if ( StartUpSound != None )
        PlaySound(StartUpSound, SLOT_None, 3.0);
    if ( IdleSound != None )
        AmbientSound = IdleSound;

        Driver.CreateInventory("CSAPVerIV.edo_ChuteInv");
}

event bool KDriverLeave( bool bForceLeave )
{
	local Controller C;
     C = Controller;
	 C.StopFiring();

    if ( Super.KDriverLeave(bForceLeave) || bForceLeave )
    {
    	if (C != None)
    	{
	       	C.Pawn.bSetPCRotOnPossess = C.Pawn.default.bSetPCRotOnPossess;
            Instigator = C.Pawn;  //so if vehicle continues on and runs someone over, the appropriate credit is given
        }
        //if ( !bDeleteMe && !IsInState('Dying') )
		//		Destroy();
        return True;
    }
    else
        return False;
}

simulated function ClientKDriverEnter( PlayerController PC )
{
	super.ClientKDriverEnter( PC );
	// force controller here, because it's not replicated yet...
	PC.Pawn = Self;
	Controller = PC;
	SetOwner( PC );
	if ( Weapon != none )
	{
		PendingWeapon = None;
		Weapon.BringUp();
	}
	else
		PC.SwitchToBestWeapon();
	EvilMonarchSpecial();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	if ( PC != None && Weapon != None )
		Weapon.PawnUnpossessed();

	super.ClientKDriverLeave( PC );
}

// DriverLeft() called by KDriverLeave()
function DriverLeft()
{
    if (AmbientSound != None)
        AmbientSound = None;
    if (ShutDownSound != None)
        PlaySound(ShutDownSound, SLOT_None, 3.0);

    if (!bNeverReset && ParentFactory != None && (VSize(Location - ParentFactory.Location) > 5000.0 || !FastTrace(ParentFactory.Location, Location)))
    {
    	if (bKeyVehicle)
    		ResetTime = Level.TimeSeconds + 15;
    	else
		ResetTime = Level.TimeSeconds + 30;
    }
    Super.DriverLeft();
}
//Vehicle has been in the middle of nowhere with no driver for a while, so consider resetting it
event CheckReset()
{
	local Pawn P;
    if ( bKeyVehicle && IsVehicleEmpty() )
	{
		Died(None, class'DamageType', Location);
		return;
	}
	if ( !IsVehicleEmpty() )
	{
    	ResetTime = Level.TimeSeconds + 10;
    	return;
	}

	foreach CollidingActors(class 'Pawn', P, 2500.0)
		if (P != self && P.GetTeamNum() == GetTeamNum() && FastTrace(P.Location + P.CollisionHeight * vect(0,0,1), Location + CollisionHeight * vect(0,0,1)))
		{
			ResetTime = Level.TimeSeconds + 10;
			return;
		}

	//if factory is active, we want it to spawn new vehicle NOW
	if ( ParentFactory != None )
	{
		ParentFactory.VehicleDestroyed(self);
		ParentFactory.Timer();
		ParentFactory = None; //so doesn't call ParentFactory.VehicleDestroyed() again in Destroyed()
	}
	Destroy();
}
//==========================================================

//========Passenger Systems=================================
//Passenger Functions
function int NumPassengers()
{
	local int i, num;

	if ( Driver != None )
		num = 1;

	for (i=0; i<WeaponPawns.length; i++)
		if ( WeaponPawns[i].Driver != None )
			num++;
	return num;
}

function AIController GetBotPassenger()
{
	local int i;

	for (i=0; i<WeaponPawns.length; i++)
		if ( AIController(WeaponPawns[i].Controller) != None )
			return AIController(WeaponPawns[i].Controller);
	return None;
}

function Pawn GetInstigator()
{
	local int i;

	if ( Controller != None )
		return Self;

	for (i=0; i<WeaponPawns.length; i++)
		if ( WeaponPawns[i].Controller != None )
			return WeaponPawns[i];

	return Self;
}

function bool IsVehicleEmpty()
{
	local int i;

	if ( Driver != None )
		return false;

	for (i=0; i<WeaponPawns.length; i++)
		if ( WeaponPawns[i].Driver != None )
			return false;

	return true;
}

function Vehicle FindEntryVehicle(Pawn P)
{
	local int x;
	local float Dist, ClosestDist;
	local APWeaponPawn ClosestWeaponPawn;
	local Bot B;
	local Vehicle VehicleGoal;

	//bots know what they want
	B = Bot(P.Controller);
	if (B != None)
	{
		VehicleGoal = Vehicle(B.RouteGoal);
		if (VehicleGoal == None)
			return None;
		if (VehicleGoal == self)
		{
			if (Driver == None)
				return self;

			return None;
		}
		for (x = 0; x < WeaponPawns.length; x++)
			if (VehicleGoal == WeaponPawns[x])
			{
				if (WeaponPawns[x].Driver == None)
					return WeaponPawns[x];
				if (Driver == None)
					return self;

				return None;
			}

		return None;
	}

    // Always go with driver's seat if no driver
    if (Driver == None)
    {
	Dist = VSize(P.Location - (Location + (EntryPosition >> Rotation)));
	if (Dist < EntryRadius)
		return self;
	for (x = 0; x < WeaponPawns.length; x++)
	{
        	Dist = VSize(P.Location - (WeaponPawns[x].Location + (WeaponPawns[x].EntryPosition >> Rotation)));
		if (Dist < WeaponPawns[x].EntryRadius)
			return self;
	}

	return None;
    }

    // Check WeaponPawns to see if we are in radius
    ClosestDist = 100000.0;
    for (x = 0; x < WeaponPawns.length; x++)
    {
        Dist = VSize(P.Location - (WeaponPawns[x].Location + (WeaponPawns[x].EntryPosition >> Rotation)));
        if (Dist < WeaponPawns[x].EntryRadius && Dist < ClosestDist)
        {
            // WeaponPawn is within radius
            ClosestDist = Dist;
            ClosestWeaponPawn = WeaponPawns[x];
        }
    }

    if (ClosestWeaponPawn != None || VSize(P.Location - (Location + (EntryPosition >> Rotation))) < EntryRadius)
    {
        // WeaponPawn slot is closest
        if (ClosestWeaponPawn != None && ClosestWeaponPawn.Driver == None)
            return ClosestWeaponPawn;          // If closest WeaponPawn slot is open we try it
        else                                   // Otherwise we try to find another open WeaponPawn slot
        {
            for (x = 0; x < WeaponPawns.length; x++)
            {
                if (WeaponPawns[x].Driver == None)
                    return WeaponPawns[x];
            }
        }
    }

	// No slots in range
	return None;
}


function Vehicle OpenPositionFor(Pawn P)
{
	local int i;

	if ( Controller == None )
		return self;

	if ( !Controller.SameTeamAs(P.Controller) )
		return None;
	for ( i=0; i<WeaponPawns.Length; i++ )
		if ( WeaponPawns[i].Controller == None )
			return WeaponPawns[i];

	return None;
}

function ServerChangeDriverPosition(byte F)
{
	local Pawn OldDriver, Bot;

	if (Driver == None)
		return;

	F -= 2;

	if (F < WeaponPawns.length && (WeaponPawns[F].Driver == None || AIController(WeaponPawns[F].Controller) != None))
	{
		OldDriver = Driver;
		//if human player wants a bot's seat, bot swaps with him
		if (AIController(WeaponPawns[F].Controller) != None)
		{
			Bot = WeaponPawns[F].Driver;
			WeaponPawns[F].KDriverLeave(true);
		}
		KDriverLeave(true);
		if (!WeaponPawns[F].TryToDrive(OldDriver))
		{
			KDriverEnter(OldDriver);
			if (Bot != None)
				WeaponPawns[F].KDriverEnter(Bot);
		}
		else if (Bot != None)
			TryToDrive(Bot);
	}
}
function bool HasOccupiedTurret()
{
	local int i;

	for (i = 0; i < WeaponPawns.length; i++)
		if (WeaponPawns[i].Driver != None)
			return true;

	return false;
}

function SetTeamNum(byte T)
{
    local byte	Temp;
	local int	x;
    Temp = Team;
	PrevTeam = T;
    Team	= T;
	if ( Temp != T )
		TeamChanged();
	for (x = 0; x < WeaponPawns.length; x++)
      	WeaponPawns[x].SetTeamNum(T);
}

function array<Vehicle> GetTurrets()
{
	return WeaponPawns;
}

//========Imput Commands====================================
simulated function SwitchWeapon(byte F)
{
	ServerChangeDriverPosition(F);
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

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	local int			actualDamage;
	local bool			bAlreadyDead;
	local Controller	Killer;

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	if ( Level.Game == None )
		return;

	// Spawn Protection: Cannot be destroyed by a player until possessed
	if ( bSpawnProtected && instigatedBy != None && instigatedBy != Self )
		return;

	// Prevent multiple damage the same tick (for splash damage deferred by turret bases for example)
	if ( Level.TimeSeconds == DamLastDamageTime && instigatedBy == DamLastInstigator )
		return;

	DamLastInstigator = instigatedBy;
	DamLastDamageTime = Level.TimeSeconds;

	if ( damagetype == None )
		DamageType = class'DamageType';

	Damage		*= DamageType.default.VehicleDamageScaling;
	momentum	*= DamageType.default.VehicleMomentumScaling * MomentumMult;
	bAlreadyDead = (Health <= 0);
	NetUpdateTime = Level.TimeSeconds - 1; // force quick net update

    if ( Weapon != None )
        Weapon.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
    if ( (InstigatedBy != None) && InstigatedBy.HasUDamage() )
        Damage *= 2;

	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

	if ( DamageType.default.bArmorStops && (actualDamage > 0) )
		actualDamage = ShieldAbsorb( actualDamage );

    if ( bShowDamageOverlay && DamageType.default.DamageOverlayMaterial != None && actualDamage > 0 )
        SetOverlayMaterial( DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true );

	Health -= actualDamage;

	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if ( bAlreadyDead )
		return;

	PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, Momentum);
	if ( Health <= 0 )
	{

		if ( bRemoteControlled && Driver != None )
	       	KDriverLeave( false );

		// pawn died
		if ( instigatedBy != None )
			Killer = instigatedBy.GetKillerController();
		else if ( (DamageType != None) && DamageType.default.bDelayedDamage )
			Killer = DelayedDamageInstigatorController;

		Health = 0;

		TearOffMomentum = momentum;

		Died(Killer, damageType, HitLocation);
	}
	else
	{
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
	}

	MakeNoise(1.0);
}


// Spawn Explosion FX
simulated function Explode( vector HitLocation, vector HitNormal );



simulated final function float	CalcInertia(float DeltaTime, float FrictionFactor, float OldValue, float NewValue)
{
	local float	Friction;
	Friction = 1.f - FClamp( (0.02*FrictionFactor) ** DeltaTime, 0.f, 1.f);
	return	OldValue*Friction + NewValue;
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

function name GetWeaponBoneFor(Inventory I)
{
	return '';
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
        if(Controller!=none)
          {
           DamMomentum=0;
		   Controller.DamageShake(DamMomentum);
          }
         if ( PlayerController(Controller) != none)
           PlayerController(Controller).StopViewShaking();
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
		DrawWeaponInfo( C, PC.myHUD );
		if ( bCustomHealthDisplay )
			DrawHealthInfo( C, PC );
	}
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

simulated function DrawVehicleHUD( Canvas C, PlayerController PC );
simulated function DrawWeaponInfo( Canvas C, HUD H );
simulated function DrawHealthInfo( Canvas C, PlayerController PC );

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


function vector GetBotError(vector StartLocation)
{
	Controller.ShotTarget = Pawn(Controller.Target);
	if ( Controller.Target != OldTarget )
	{
		BotError = (1500 - 100 * Level.Game.GameDifficulty) * VRand();
		OldTarget = Controller.Target;
	}
	BotError += 100 * VRand() + (100 - 200 *FRand()) * Normal(Controller.Target.Velocity);
	if ( (Pawn(OldTarget) != None) && Pawn(OldTarget).bStationary )
		BotError *= 0.6;
	BotError = Normal(BotError) * FMin(VSize(BotError), FMin(1500 - 100*Level.Game.GameDifficulty,0.2 * VSize(Controller.Target.Location - StartLocation)));
	return BotError;
}
/* Return world location of crosshair's == vehicle's focus point */
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


function BotEject()
{
    local xRealCTFBase FlagBase;
    local float Range;
    Range=1500;
  // Ejectbot When Near Flag
  foreach RadiusActors(class'xRealCTFBase', FlagBase, range, Location)
		{
			if ((FlagBase.IsA('xRedFlagBase') && (Team == 0) && Controller.PlayerReplicationInfo.HasFlag == None) || (FlagBase.IsA('xBlueFlagBase') && (Team == 0) && Controller.PlayerReplicationInfo.HasFlag != None))
                 Return;

			if ((FlagBase.IsA('xBlueFlagBase') && (Team == 1) && Controller.PlayerReplicationInfo.HasFlag == None) || (FlagBase.IsA('xRedFlagBase') && (Team == 1) && Controller.PlayerReplicationInfo.HasFlag != None))
                 Return;
            KDriverLeave(True);
		}
}

static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );

	L.AddPrecacheMaterial( default.NoEntryTexture );
	L.AddPrecacheMaterial( default.TeamBeaconTexture );
	L.AddPrecacheMaterial( default.TeamBeaconBorderMaterial );
	L.AddPrecacheMaterial( default.CrosshairHitFeedbackTex );
	L.AddPrecacheMaterial( default.DefaultCrosshair );
	L.AddPrecacheMaterial( default.VehicleIcon.Material );
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( default.NoEntryTexture );
	Level.AddPrecacheMaterial( default.TeamBeaconTexture );
	Level.AddPrecacheMaterial( default.TeamBeaconBorderMaterial );
	Level.AddPrecacheMaterial( default.CrosshairHitFeedbackTex );
	Level.AddPrecacheMaterial( default.DefaultCrosshair );
	Level.AddPrecacheMaterial( VehicleIcon.Material );

	super.UpdatePrecacheMaterials();
}
function RemovePowerups()
{
    Super.RemovePowerups();
}

// check before throwing
simulated function bool CanThrowWeapon()
{
    return ( (Weapon != None) && Weapon.CanThrow() && Level.Game.bAllowWeaponThrowing );
}




//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     LockedOnSound=Sound'WeaponSounds.BaseGunTech.BSeekLost1'
     DefaultCrosshair=FinalBlend'InterfaceContent.HUD.fbBombFocus'
     CrosshairHitFeedbackTex=Texture'ONSInterface-TX.tankBarrelAligned'
     CrosshairScale=0.125000
     bDrawVehicleShadow=False
     bShowDamageOverlay=True
     bAdjustDriversHead=False
     bDesiredBehindView=False
     EntryRadius=250.000000
     TeamBeaconTexture=Texture'ONSInterface-TX.HealthBar'
     NoEntryTexture=Texture'HUDContent.Generic.NoEntry'
     TeamBeaconBorderMaterial=Texture'InterfaceContent.Menu.BorderBoxD'
     VehicleIcon=(Material=Texture'AS_FX_TX.HUD.TrackedVehicleIcon',SizeX=64.000000,SizeY=64.000000)
     bSpecialCrosshair=True
     BaseEyeHeight=0.000000
     EyeHeight=0.000000
     bStasis=False
     bReplicateAnimations=True
     bNetInitialRotation=True
     bCanTeleport=False
     bBlockKarma=True
}
