
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
    super(ONSWheeledCraft).AltFire(F);
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
    super(ONSWheeledCraft).ClientVehicleCeaseFire(bWasAltFire);
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	super(ONSWheeledCraft).ClientKDriverLeave(PC);
}


defaultproperties
{
    VehicleNameString="Mega Spanker 1.1"
    VehiclePositionString="in a Mega Spanker"
    RedSkin=Shader'CSSpankBadger.Badger.SpankBadgerRedShader'
    BlueSkin=Shader'CSSpankBadger.Badger.SpankBadgerBlueShader'

    DriverWeapons(0)=(WeaponClass=Class'CSMegaSpankerWeapon',WeaponBone="TurretSpawn")
}