class DamTypeBioHoundMissile extends DamTypeBioGlobVehicle
	abstract;

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		if ( ONSVehicle(Killer.Pawn) == None )
			return;

	}
}

defaultproperties
{
     VehicleClass=Class'BioHoundOmni.BioHoundRearGunPawn'
     DeathString="%o got splattered and gooey by %k's Bio missile."
     FemaleSuicide="%o blasted herself."
     MaleSuicide="%o blasted himself."
}
