class DamType_FighterMissile extends VehicleDamageType
	abstract;

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		if ( AirPower_Fighter(Killer.Pawn) == None )
			return;

		AirPower_Fighter(Killer.Pawn).TopGunCount++;

		//Maybe add to game stats?
		if ( AirPower_Fighter(Killer.Pawn).TopGunCount == 5 && PlayerController(Killer) != None )
		{
			AirPower_Fighter(Killer.Pawn).TopGunCount = 0;
			PlayerController(Killer).ReceiveLocalizedMessage(class'Message_ASKillMessages', 0);
		}
	}
}

defaultproperties
{
     VehicleClass=Class'CSAPVerIV.AirPower_Fighter'
     DeathString="%o couldn't avoid %k's missile."
     FemaleSuicide="%o blasted herself out of the Sky."
     MaleSuicide="%o blasted himself out of the Sky."
     bDelayedDamage=True
     KDamageImpulse=10000.000000
     VehicleMomentumScaling=1.300000
}
