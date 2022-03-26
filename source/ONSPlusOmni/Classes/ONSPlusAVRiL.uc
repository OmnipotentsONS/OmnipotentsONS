// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusAVRiL extends ONSAVRiL;

var vehicle DelLockonTarget;
delegate DelNotifyPlusEnemyLostLock(optional actor UnLockedActor);
delegate DelNotifyPlusEnemyLockedOn(actor LockedActor);


// Priority fix
simulated function PostBeginPlay()
{
	if (Level.Netmode != NM_DedicatedServer)
	{
		Class'ONSPlusAvril'.default.Priority = Class'ONSAvril'.default.Priority;
		CustomCrosshair = Class'ONSAvril'.default.CustomCrosshair;
		CustomCrosshairColor = Class'ONSAvril'.default.CustomCrosshairColor;
		CustomCrosshairScale = Class'ONSAvril'.default.CustomCrosshairScale;
		CustomCrosshairTextureName = Class'ONSAvril'.default.CustomCrosshairTextureName;
		SaveConfig();
	}

	Super.PostBeginPlay();
}

simulated function WeaponTick(float deltaTime)
{
	local vector StartTrace, LockTrace;
	local rotator Aim;
	local float BestAim, BestDist;
	local bool bLastLockedOn, bBotLock;
	local Vehicle LastHomingTarget;
	local Vehicle AIFocus;
	local Vehicle V;
	local Actor AlternateTarget;

	if (Role < ROLE_Authority)
	{
		ActivateReticle(bLockedOn);
		return;
	}

	if (Instigator == None || Instigator.Controller == None)
	{
		LoseLock();
		ActivateReticle(false);

		return;
	}

	if (Level.TimeSeconds < LockCheckTime)
		return;

	LockCheckTime = Level.TimeSeconds + LockCheckFreq;

	bLastLockedOn = bLockedOn;
	LastHomingTarget = HomingTarget;
	bBotLock = true;

	if (AIController(Instigator.Controller) != None)
	{
		AIFocus = Vehicle(AIController(Instigator.Controller).Focus);

		if (CanLockOnTo(AIFocus) && ((AIFocus.Controller != None) || (AIFocus != Instigator.Controller.MoveTarget) || AIFocus.HasOccupiedTurret())
			&& FastTrace(AIFocus.Location, Instigator.Location + Instigator.EyeHeight * vect(0,0,1)))
		{
			HomingTarget = AIFocus;
			bLockedOn = true;
		}
		else
		{
			bLockedOn = false;
			bBotLock = false;
		}
	}
	else if (HomingTarget == None || Normal(HomingTarget.Location - Instigator.Location) Dot vector(Instigator.Controller.Rotation) < LockAim
			|| VSize(HomingTarget.Location - Instigator.Location) > MaxLockRange
			|| !FastTrace(HomingTarget.Location, Instigator.Location + Instigator.EyeHeight * vect(0,0,1)))
	{
		StartTrace = Instigator.Location + Instigator.EyePosition();
		Aim = Instigator.GetViewRotation();
		BestAim = LockAim;

		HomingTarget = Vehicle(Instigator.Controller.PickTarget(BestAim, BestDist, Vector(Aim), StartTrace, MaxLockRange));
	}

	// If no homing target, check for alternate targets
	if (HomingTarget == None)
	{
		StartTrace = Instigator.Location + Instigator.EyePosition();
		Aim = Instigator.GetViewRotation();

		for (V=Level.Game.VehicleList; V!=None; V=V.NextVehicle)
		{
			AlternateTarget = V.AlternateTarget();

			if (AlternateTarget != None)
			{
				LockTrace = AlternateTarget.Location - StartTrace;

				if (Normal(LockTrace) dot Vector(Aim) > LockAim && VSize(LockTrace) < MaxLockRange && FastTrace(AlternateTarget.Location,StartTrace))
				{
					HomingTarget = V;

					if (AIController(Instigator.Controller) != none)
						AIController(Instigator.Controller).Focus = V;

					break;
				}
			}
		}
	}

	bLockedOn = CanLockOnTo(HomingTarget);

	ActivateReticle(bLockedOn);

	if (!bLastLockedOn && bLockedOn)
	{
		if (bBotLock && HomingTarget != None)
			GiveLockedOnNotification(HomingTarget);

		if (PlayerController(Instigator.Controller) != None)
			PlayerController(Instigator.Controller).ClientPlaySound(Sound'WeaponSounds.LockOn');
	}
	else if (bLastLockedOn && !bLockedOn && LastHomingTarget != None)
			GiveLostLockNotification(LastHomingTarget);
}

function LoseLock()
{
	if (bLockedOn && HomingTarget != None)
		GiveLostLockNotification(HomingTarget);

	bLockedOn = false;
}

function GiveLostLockNotification(vehicle V)
{
	local int i;

	if (Pawn(Owner) != none && Pawn(Owner).Controller != none && ONSPlusxPlayer(Pawn(Owner).Controller) != none
		&& ONSPlusxPlayer(Pawn(Owner).Controller).bInitializedClientPlugins)
	{
		if (DelLockOnTarget != V)
		{
			for (i=0; i<ONSPlusxPlayer(Pawn(Owner).Controller).VehiclePlugins.Length; ++i)
			{
				if (ONSPlusxPlayer(Pawn(Owner).Controller).VehiclePlugins[i].static.SetupVehicleDelegates(None, Self, None, V))
				{
					DelLockOnTarget = V;
					break;
				}
			}
		}

		if (DelLockOnTarget == V)
			DelNotifyPlusEnemyLostLock(Self);
		else
			V.NotifyEnemyLostLock();
	}
	else
	{
		V.NotifyEnemyLostLock();
	}
}

function GiveLockedOnNotification(vehicle V)
{
	local int i;

	if (Pawn(Owner) != none && Pawn(Owner).Controller != none && ONSPlusxPlayer(Pawn(Owner).Controller) != none
		&& ONSPlusxPlayer(Pawn(Owner).Controller).bInitializedClientPlugins)
	{
		if (DelLockOnTarget != V)
		{
			for (i=0; i<ONSPlusxPlayer(Pawn(Owner).Controller).VehiclePlugins.Length; ++i)
			{
				if (ONSPlusxPlayer(Pawn(Owner).Controller).VehiclePlugins[i].static.SetupVehicleDelegates(None, Self, None, V))
				{
					DelLockOnTarget = V;
					break;
				}
			}
		}

		if (DelLockOnTarget == V)
			DelNotifyPlusEnemyLockedOn(Self);
		else
			V.NotifyEnemyLockedOn();
	}
	else
	{
		V.NotifyEnemyLockedOn();
	}
}

defaultproperties
{
	PickupClass=Class'ONSPlusAVRiLPickup'
	FireModeClass(0)=ONSPlusAVRiLFire
}