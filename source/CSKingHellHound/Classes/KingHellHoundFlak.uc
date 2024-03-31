class KingHellHoundFlak extends VehicleDamageType
	abstract;

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		if (PlayerController(Killer) != None)
			PlayerController(Killer).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 6);
	}
}

defaultproperties
{
     VehicleClass=Class'CSKingHellHound.KingHellHound'
     DeathString="%o was shredded by %k's King HellHound Flak."
     FemaleSuicide="%o was perforated by her own Flak."
     MaleSuicide="%o was perforated by his own Flak."
     bDelayedDamage=True
     bBulletHit=True
     VehicleMomentumScaling=0.750000
     VehicleDamageScaling=1.3
