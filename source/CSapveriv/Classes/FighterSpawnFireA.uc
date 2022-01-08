class FighterSpawnFireA extends RedeemerFire config(CSAPVerIV);
var config class<AirPower_Fighter> FighterClass;
function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local AirPower_Fighter Fighter;
	FighterClass=FighterSpawnRifle(weapon).GetFighterClass();
    Fighter = Weapon.Spawn(FighterClass, Instigator,, Start, Dir);
    if (Fighter == None)
		Fighter = Weapon.Spawn(FighterClass, Instigator,, Instigator.Location, Dir);
    if (Fighter != None)
    {

		Fighter.SetTeamNum(instigator.GetTeamNum());
        Fighter.TryToDrive(instigator);
	    Fighter.AutoLaunch();

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
