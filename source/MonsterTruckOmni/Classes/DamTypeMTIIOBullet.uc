class DamTypeMTIIOBullet extends VehicleDamageType
	abstract;

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		//Maybe add to game stats?
		if (PlayerController(Killer) != None)
			PlayerController(Killer).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 6);
	}
}

defaultproperties
{
     VehicleClass=Class'MonsterTruckOmni.MonsterTruckIIOmni'
     DeathString="%k's Super Beast gun filled %o with hot lead."
     FemaleSuicide="%o filled herself with her own bullets."
     MaleSuicide="%o filled himself with his own bullets."
     bDetonatesGoop=True
     FlashFog=(X=700.000000)
     VehicleDamageScaling=1.10000
}
