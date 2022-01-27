
class CSMegaSpanker extends Badgertaur;

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
	SetBoneLocation('TurretSpawn', (vect(0,0,8)));
}

simulated function PostNetBeginPlay()
{
    PassengerWeapons.Length = 0;
    super.PostNetBeginPlay();
}


function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	//PC.ToggleZoom();
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire)
	{
		super(ONSWheeledCraft).ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	//PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	super(ONSWheeledCraft).ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
	//PC.EndZoom();
}


defaultproperties
{
    VehicleNameString="Mega Spanker 1.0"
    VehiclePositionString="in a Mega Spanker"
    RedSkin=Shader'CSSpankBadger.Badger.SpankBadgerRedShader'
    BlueSkin=Shader'CSSpankBadger.Badger.SpankBadgerBlueShader'

    DriverWeapons(0)=(WeaponClass=Class'CSMegaSpankerWeapon',WeaponBone="TurretSpawn")
}