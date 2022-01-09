class AlligatorSecondaryTurretPawn extends ONSWeaponPawn;

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoom();
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

function KDriverEnter(Pawn p)
{
    local PlayerController PC;
    PC = PlayerController(P.Controller);

    Super.KDriverEnter(p);

    if(PC != None)
        PC.GotoState('PlayerDriving');
    //SVehicleUpdateParams();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	PC.EndZoom();
}

function ShouldTargetMissile(Projectile P)
{
	if ( Bot(Controller) != None && Bot(Controller).Skill >= 5.0 )
	{
		if ( (Controller.Enemy != None) && Bot(Controller).EnemyVisible() && (Bot(Controller).Skill < 5) )
			return;
		ShootMissile(P);
	}
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
	if (DamageType == class'Drowned')
		Damage = 0;

	//if (DamageType == class'MinotaurTurretkill')
	if (DamageType.Name == 'MinotaurTurretkill')
		Damage *= 0.30;

	//if (DamageType == class'MinotaurSecondaryTurretKill')
	if (DamageType.Name == 'MinotaurSecondaryTurretKill')
		Damage *= 0.30;

	if (DamageType == class'DamTypeAlligatorBeam')
		Damage *= 0.70;

	//if (DamageType == class'HeatRay')
	if (DamageType.Name == 'HeatRay')
		Damage *= 0.30;

	//if (DamageType == class'FireKill')
	if (DamageType.Name == 'FireKill')
		Damage *= 0.30;

	//if (ClassIsChildOf(DamageType,class'DamTypeAirPower'))
	if (DamageType.name == 'AuroraLaser' || DamageType.name == 'WaspFlak')
		Damage *= 0.70;

	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.70;

	if (DamageType == class'DamTypeONSCicadaRocket')
		Damage *= 0.70;

	if (DamageType == class'DamTypeAttackCraftPlasma')
		Damage *= 0.70;

	if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.60;

        Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

defaultproperties
{
     WaterDamage=0
     GunClass=Class'CSAlligator.AlligatorSecondaryGun'
     bHasAltFire=False
     CameraBone="Object02"
     bDrawDriverInTP=False
     DrivePos=(Z=130.000000)
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryRadius=130.000000
     FPCamViewOffset=(X=10.000000,Z=30.000000)
     TPCamDistance=300.000000
     TPCamLookat=(X=-25.000000,Z=0.000000)
     TPCamWorldOffset=(Z=120.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in an Alligator turret"
     VehicleNameString="Alligator twinbeam Turret"
}
