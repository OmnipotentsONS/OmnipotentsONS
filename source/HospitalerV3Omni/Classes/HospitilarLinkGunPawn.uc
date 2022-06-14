//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HospitilarLinkGunPawn extends ONSWeaponPawn;

var class<LinkTWeapon> linkweaponcheck;

var vector AttachOffset;
var()	string	DefaultWeaponClassName;
//var() name CameraBone;
var bool bIsShooting;

simulated function UpdateLinkColor( LinkAttachment.ELinkColor color )
{
	if ( Gun != none && Gun.Class == linkweaponcheck)
	HospitilarLinkGun(Gun).UpdateLinkColor( color );
}

function AddDefaultInventory()
{
	GiveWeapon( DefaultWeaponClassName );
	if ( Controller != None )
		Controller.ClientSwitchToBestWeapon();
}

function PossessedBy(Controller C)
{
	Level.Game.DiscardInventory( Self );

	super.PossessedBy( C );

	NetUpdateTime = Level.TimeSeconds - 1;
	bStasis = false;
	C.Pawn	= Self;
	AddDefaultInventory();
	if ( Weapon != None )
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
	Super.UnPossessed();
}

event bool KDriverLeave( bool bForceLeave )
{
	local bool			bLeft;
	local Pawn			ExDriver;
	local Controller	ExController;

	if ( Controller != None )
		Controller.StopFiring();
	ExController	= Controller;
	ExDriver		= Driver;

	bLeft = super.KDriverLeave( bForceLeave );
	if ( bLeft && ExDriver != None && ExDriver.Weapon == None && ExController != None && ExController.Pawn == ExDriver )
		ExController.SwitchToBestWeapon();

	return bLeft;
}

simulated function ClientKDriverEnter( PlayerController PC )
{
	super.ClientKDriverEnter( PC );

	// force controller here, because it's not replicated yet...
	PC.Pawn = Self;
	Controller = PC;
	SetOwner( PC );
	if ( Weapon != None )
	{
		PendingWeapon = None;
		Weapon.BringUp();
	}
	else
		PC.SwitchToBestWeapon();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	if ( PC != None && Weapon != None )
		Weapon.PawnUnpossessed();

	super.ClientKDriverLeave( PC );
}

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

defaultproperties
{
     linkweaponcheck=Class'HospitalerV3Omni.LinkTWeapon'
     DefaultWeaponClassName="HospitalerV3Omni.HospitilarLinkTW"
     GunClass=Class'HospitalerV3Omni.HospitilarLinkGun'
     CameraBone="("
     bDrawDriverInTP=False
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryPosition=(X=40.000000,Y=50.000000,Z=-100.000000)
     EntryRadius=500.000000
     FPCamPos=(Z=20.000000)
     TPCamDistance=500.000000
     TPCamLookat=(X=0.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Hospitaler 3 Link turret"
     VehicleNameString="Hospitaler Link Turret"
}
