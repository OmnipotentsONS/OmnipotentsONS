class HospitilarLinkGunFire extends LinkTLinkFire;


function DoFireEffect()
{
	local vector	Start;
	local rotator  rotat;

	Instigator.MakeNoise(1.0);

	LinkTWeapon = LinkTWeapon(HospitilarLinkGunPawn(Instigator).Gun);

    Start = LinkTWeapon(HospitilarLinkGunPawn(Instigator).Gun).GetFireStart();
    rotat = LinkTWeapon(HospitilarLinkGunPawn(Instigator).Gun).WeaponFireRotation;
	//LinkTWeapon(LinkTank(Instigator).Weapons[0]).SimulateTraceFire( start2, rota, HL, HN );
	Start=Start+(Normal(Vector(Rotat)))*20;

    SpawnProjectile(Start, rotat );//Rotator(HL-Start) );
}

defaultproperties
{
}
