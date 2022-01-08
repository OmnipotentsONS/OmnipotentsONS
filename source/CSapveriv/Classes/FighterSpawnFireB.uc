class FighterSpawnFireB extends RedeemerFire config(CSAPVerIV);
var config class<Vehicle> VehicleClass;
function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Vehicle SpawnVehicle;
    VehicleClass=FighterSpawnRifle(weapon).GetVehicleClass();

    SpawnVehicle = Weapon.Spawn(VehicleClass, Instigator,, Start, Dir);
    if (SpawnVehicle == None)
		SpawnVehicle = Weapon.Spawn(VehicleClass, Instigator,, Instigator.Location, Dir);
    if (SpawnVehicle != None)
    {

		SpawnVehicle.SetTeamNum(instigator.GetTeamNum());
        SpawnVehicle.TryToDrive(instigator);
	    SpawnVehicle.Fire();

	}
    else
    {
	 	Weapon.Spawn(class'SmallRedeemerExplosion');
		Weapon.HurtRadius(500, 400, class'DamTypeRedeemer', 100000, Instigator.Location);
	}

	bIsFiring = false;
    StopFiring();
    return None;
}

defaultproperties
{
     ProjSpawnOffset=(X=300.000000,Z=128.000000)
}
