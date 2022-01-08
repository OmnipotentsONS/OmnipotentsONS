//-----------------------------------------------------------
//
//-----------------------------------------------------------
class APWeaponPawn extends ONSWeaponPawn;


var AirPower_Vehicle          VehicleBaseB;


replication
{
    unreliable if (Role == ROLE_Authority)
        VehicleBaseB;
}


function AttachFlag(Actor FlagActor)
{
	if ( VehicleBaseB != None )
		VehicleBaseB.AttachFlag(FlagActor);
	else
		Super.AttachFlag(FlagActor);
}

function Vehicle GetMoveTargetFor(Pawn P)
{
	if ( VehicleBaseB != None )
		return VehicleBaseB;
	return self;
}

function Pawn GetAimTarget()
{
	if ( VehicleBaseB != None )
		return VehicleBaseB;
	return self;
}

function Vehicle GetVehicleBase()
{
	return VehicleBaseB;
}

function AttachToVehicleB(AirPower_Vehicle VehiclePawn, name WeaponBone)
{
    if (Level.NetMode != NM_Client)
    {
        VehicleBaseB = VehiclePawn;
        VehicleBaseB.AttachToBone(Gun, WeaponBone);

    }
}


simulated function vector GetCameraLocationStart()
{
	if (VehicleBaseB != None && Gun != None)
		return VehicleBaseB.GetBoneCoords(Gun.AttachmentBone).Origin;
	else
		return Super.GetCameraLocationStart();
}

function bool TryToDrive(Pawn P)
{
	if (VehicleBaseB != None)
	{
		if (VehicleBaseB.NeedsFlip())
		{
			VehicleBaseB.Flip(vector(P.Rotation), 1);
			return false;
		}

		if (P.GetTeamNum() != Team)
		{
			if (VehicleBaseB.Driver == None)
				return VehicleBaseB.TryToDrive(P);

			VehicleLocked(P);
			return false;
		}
	}

	return Super.TryToDrive(P);
}

function KDriverEnter(Pawn P)
{
	local rotator NewRotation;

	Super.KDriverEnter(P);

	if (VehicleBaseB != None && VehicleBaseB.bTeamLocked && VehicleBaseB.bEnterringUnlocks)
		VehicleBaseB.bTeamLocked = false;

	Gun.bActive = True;
	if (!bHasOwnHealth && VehicleBaseB == None)
	{
		Health = Driver.Health;
		HealthMax = Driver.HealthMax;
	}

        if (xPawn(Driver) != None && Driver.HasUDamage())
		Gun.SetOverlayMaterial(xPawn(Driver).UDamageWeaponMaterial, xPawn(Driver).UDamageTime - Level.TimeSeconds, false);

	NewRotation = Controller.Rotation;
	NewRotation.Pitch = LimitPitch(NewRotation.Pitch);
	SetRotation(NewRotation);
	Driver.bSetPCRotOnPossess = false; //so when driver gets out he'll be facing the same direction as he was inside the vehicle

	if (Gun != None)
		Gun.NetUpdateFrequency = 10;

		Driver.CreateInventory("CSAPVerIV.edo_ChuteInv");
}

function bool KDriverLeave( bool bForceLeave )
{
    local Controller C;

    // We need to get the controller here since Super.KDriverLeave() messes with it.
    C = Controller;
    if (Super.KDriverLeave(bForceLeave) || bForceLeave)
    {
        bWeaponIsFiring = False;

	if (!bHasOwnHealth && VehicleBaseB == None)
	{
		HealthMax = default.HealthMax;
		Health = HealthMax;
	}

	if (C != None)
	{
		if (Gun != None && xPawn(C.Pawn) != None && C.Pawn.HasUDamage())
		    Gun.SetOverlayMaterial(xPawn(C.Pawn).UDamageWeaponMaterial, 0, false);

		C.Pawn.bSetPCRotOnPossess = C.Pawn.default.bSetPCRotOnPossess;

		if (Bot(C) != None)
			Bot(C).ClearTemporaryOrders();
	}

	if (Gun != None)
	{
		Gun.bActive = False;
		Gun.FlashCount = 0;
		Gun.NetUpdateFrequency = Gun.default.NetUpdateFrequency;
	}

        return True;
    }
    else
    {
        Log("Cannot leave "$self);
        return False;
    }
}

function bool PlaceExitingDriver()
{
	local int i;
	local vector tryPlace, Extent, HitLocation, HitNormal, ZOffset;

	Extent = Driver.default.CollisionRadius * vect(1,1,0);
	Extent.Z = Driver.default.CollisionHeight;
	ZOffset = Driver.default.CollisionHeight * vect(0,0,0.5);

	//avoid running driver over by placing in direction perpendicular to velocity
	if (VehicleBaseB != None && VSize(VehicleBaseB.Velocity) > 100)
	{
		tryPlace = Normal(VehicleBaseB.Velocity cross vect(0,0,1)) * (VehicleBaseB.CollisionRadius * 1.25);
		if (FRand() < 0.5)
			tryPlace *= -1; //randomly prefer other side
		if ( (VehicleBaseB.Trace(HitLocation, HitNormal, VehicleBaseB.Location + tryPlace + ZOffset, VehicleBaseB.Location + ZOffset, false, Extent) == None && Driver.SetLocation(VehicleBaseB.Location + tryPlace + ZOffset))
		     || (VehicleBaseB.Trace(HitLocation, HitNormal, VehicleBaseB.Location - tryPlace + ZOffset, VehicleBaseB.Location + ZOffset, false, Extent) == none && Driver.SetLocation(VehicleBaseB.Location - tryPlace + ZOffset)) )
			return true;
	}

	for(i=0; i<ExitPositions.Length; i++)
	{
		if ( bRelativeExitPos )
		{
		    if (VehicleBaseB != None)
		    	tryPlace = VehicleBaseB.Location + (ExitPositions[i] >> VehicleBaseB.Rotation) + ZOffset;
        	    else if (Gun != None)
                	tryPlace = Gun.Location + (ExitPositions[i] >> Gun.Rotation) + ZOffset;
	            else
        	        tryPlace = Location + (ExitPositions[i] >> Rotation);
	        }
		else
			tryPlace = ExitPositions[i];

		// First, do a line check (stops us passing through things on exit).
		if ( bRelativeExitPos )
		{
			if (VehicleBaseB != None)
			{
				if (VehicleBaseB.Trace(HitLocation, HitNormal, tryPlace, VehicleBaseB.Location + ZOffset, false, Extent) != None)
					continue;
			}
			else
				if (Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) != None)
					continue;
		}

		// Then see if we can place the player there.
		if ( !Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}
	return false;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local PlayerController PC;
	local Controller C;

	if ( bDeleteMe || Level.bLevelChange )
		return; // already destroyed, or level is being cleaned up

	if ( Level.Game.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
	Health = Min(0, Health);

	if ( Controller != None )
	{
		C = Controller;
		C.WasKilledBy(Killer);
		Level.Game.Killed(Killer, C, self, damageType);
		if( C.bIsPlayer )
		{
			PC = PlayerController(C);
			if ( PC != None )
				ClientKDriverLeave(PC); // Just to reset HUD etc.
			else
                ClientClearController();
			if ( (bRemoteControlled || bEjectDriver) && (Driver != None) && (Driver.Health > 0) )
			{
				C.Unpossess();
				C.Possess(Driver);
				if ( bEjectDriver )
					EjectDriver();
				Driver = None;
			}
			else
			{
                		if (PC != None && VehicleBaseB != None)
		                {
                		    PC.SetViewTarget(VehicleBaseB);
		                    PC.ClientSetViewTarget(VehicleBaseB);
                		}
				C.PawnDied(self);
			}
		}
		else
			C.Destroy();
	}
	else
		Level.Game.Killed(Killer, Controller(Owner), self, damageType);

	if ( Killer != None )
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	if ( IsHumanControlled() )
		PlayerController(Controller).ForceDeathUpdate();

	Destroy();
}

event TakeDamage(int Damage, Pawn EventInstigator, Vector HitLocation, Vector Momentum, class<DamageType> DamageType)
{
    if (bHasOwnHealth)
    	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
    else if (Driver != None)
    {
        Driver.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
        if (VehicleBaseB == None)
	        Health = Driver.Health;
    }
}


simulated function SwitchWeapon(byte F)
{
	if (VehicleBaseB != None)
		ServerChangeDriverPosition(F);
}

function ServerChangeDriverPosition(byte F)
{
	local Pawn OldDriver, Bot;

	if (Driver == None || VehicleBaseB == None)
		return;

	if (F == 1 && (VehicleBaseB.Driver == None || AIController(VehicleBaseB.Controller) != None))
	{
		OldDriver = Driver;
		//if human player wants a bot's seat, bot swaps with him
		if (AIController(VehicleBaseB.Controller) != None)
		{
			Bot = VehicleBaseB.Driver;
			VehicleBaseB.KDriverLeave(true);
		}
		KDriverLeave(true);
		if (!VehicleBaseB.TryToDrive(OldDriver))
		{
			KDriverEnter(OldDriver);
			if (Bot != None)
				VehicleBaseB.KDriverEnter(Bot);
		}
		else if (Bot != None)
			TryToDrive(Bot);
		return;
	}

	F -= 2;
	if (F < VehicleBaseB.WeaponPawns.length && (VehicleBaseB.WeaponPawns[F].Driver == None || AIController(VehicleBase.WeaponPawns[F].Controller) != None))
	{
		OldDriver = Driver;
		//if human player wants a bot's seat, bot swaps with him
		if (AIController(VehicleBaseB.WeaponPawns[F].Controller) != None)
		{
			Bot = VehicleBaseB.WeaponPawns[F].Driver;
			VehicleBaseB.WeaponPawns[F].KDriverLeave(true);
		}
		KDriverLeave(true);
		if (!VehicleBaseB.WeaponPawns[F].TryToDrive(OldDriver))
		{
			KDriverEnter(OldDriver);
			if (Bot != None)
				VehicleBaseB.WeaponPawns[F].KDriverEnter(Bot);
		}
		if (Bot != None)
			TryToDrive(Bot);
	}
}


function int LimitPitch(int pitch)
{
	if (VehicleBaseB == None || Gun == None)
		return Super.LimitPitch(pitch);

	return Gun.LimitPitch(pitch, VehicleBaseB.Rotation);
}

function bool TeamLink(int TeamNum)
{
	if (VehicleBaseB != None && !bHasOwnHealth)
		return VehicleBaseB.TeamLink(TeamNum);

	return Super.TeamLink(TeamNum);
}

simulated function PostNetReceive()
{
	local int i;

	if (VehicleBaseB != None)
	{
		bNetNotify = false;
		for (i = 0; i < VehicleBaseB.WeaponPawns.Length; i++)
			if (VehicleBaseB.WeaponPawns[i] == self)
				return;
		VehicleBaseB.WeaponPawns[VehicleBaseB.WeaponPawns.length] = self;
	}
}

defaultproperties
{
     bHardAttach=True
}
