class HellHoundPlasmaProjectile extends ONSPlasmaProjectile;

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		if (PlayerController(Killer) != None)
			PlayerController(Killer).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 5);
	}
}

defaultproperties
{
     HitEffectClass=Class'Onslaught.ONSPlasmaHitPurple'
     PlasmaEffectClass=Class'Onslaught.ONSPurplePlasmaSmallFireEffect'
     AccelerationMagnitude=16000.000000
     Speed=17000.000000
     Damage=30.000000
     DamageRadius=190.000000
     MyDamageType=Class'CSHellHound.HellHoundPlasma'
     LifeSpan=1.20000
}
