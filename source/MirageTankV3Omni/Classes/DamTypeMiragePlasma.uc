class DamTypeMiragePlasma extends VehicleDamageType
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
     VehicleClass=Class'MirageTankV3Omni.MirageTankV3Omni'
     DeathString="%k's Panzer filled %o with hot plasma."
     FemaleSuicide="%o filled herself with her own hot load."
     MaleSuicide="%o filled himself with his own hot load."
     bDetonatesGoop=True
     FlashFog=(X=700.000000)
    // VehicleDamageScaling=0.300000
    // Why!  This reduces damage to vehicles only...
}
