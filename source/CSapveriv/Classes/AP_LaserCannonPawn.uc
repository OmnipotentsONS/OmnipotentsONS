class AP_LaserCannonPawn extends ONSStationaryWeaponPawn;

#exec OBJ LOAD FILE=..\Animations\APVerIV_Anim.ukx
var rotator OriginalRotation;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	// Remember Original Spawn Rotation
    OriginalRotation=Rotation;

}
simulated function ActivateOverlay(bool bActive)
{
    Super.ActivateOverlay(bActive);
}
state Dead
{
	function BeginState()
	{
		if (Level.NetMode != NM_DedicatedServer)
			spawn(DestructionEffectClass, self).SetBase(self);
	    SetRotation(OriginalRotation);
    	bClientTrigger = true;
		bNoTeamBeacon = true;
		bHidden = false;
		Gun.bHidden = true;
		SetCollision(false, false);
		bBlockZeroExtentTraces = false;
		bBlockNonZeroExtentTraces = false;
		SetTimer(RespawnTime, false);
	}

	function SetTeamNum(byte T)
	{
		GotoState('');
		Global.SetTeamNum(T);
	}

	function Timer()
	{
		GotoState('');
	}

	function EndState()
	{
		local Controller NewController;

		bClientTrigger = false;
		bNoTeamBeacon = false;
		bHidden = default.bHidden;
		Gun.bHidden = Gun.default.bHidden;
		SetCollision(default.bCollideActors, default.bBlockActors);
		bBlockZeroExtentTraces = default.bBlockZeroExtentTraces;
		bBlockNonZeroExtentTraces = default.bBlockNonZeroExtentTraces;
		Health = HealthMax;
		SetTimer(0, false);
		if (bAutoTurret && Controller == None && AutoTurretControllerClass != None)
		{
			NewController = spawn(AutoTurretControllerClass);
			if ( NewController != None )
				NewController.Possess(self);
		}
	}
}

defaultproperties
{
     bPowered=True
     RespawnTime=60.000000
     GunClass=Class'CSAPVerIV.Weapon_LaserCannon'
     CameraBone="joint4"
     bDrawDriverInTP=False
     bTeamLocked=False
     DrivePos=(X=-50.000000,Z=48.000000)
     ExitPositions(0)=(X=-250.000000)
     ExitPositions(1)=(X=-200.000000,Y=250.000000,Z=64.000000)
     ExitPositions(2)=(X=-200.000000,Y=-250.000000,Z=64.000000)
     ExitPositions(3)=(X=-64.000000,Y=250.000000,Z=64.000000)
     ExitPositions(4)=(X=-64.000000,Y=-250.000000,Z=64.000000)
     EntryRadius=300.000000
     FPCamPos=(X=-132.000000,Z=116.000000)
     TPCamDistance=450.000000
     TPCamLookat=(X=-300.000000,Z=256.000000)
     DriverDamageMult=0.000000
     HealthMax=400.000000
     Health=400
     StaticMesh=StaticMesh'APVerIV_ST.AP_Weapons_ST.TurretDead'
     Mesh=SkeletalMesh'APVerIV_Anim.APLaserCannonMesh'
     DrawScale=0.700000
     CollisionRadius=160.000000
     CollisionHeight=128.000000
     bPathColliding=True
}
