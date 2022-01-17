class DamTypeHeavyShell extends VehicleDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
    HitEffects[0] = class'HitSmoke';

    if( VictimHealth <= 0 )
        HitEffects[1] = class'HitFlameBig';
    else if ( FRand() < 0.8 )
        HitEffects[1] = class'HitFlame';
}

static function ScoreKill(Controller Killer, Controller Killed)
{
	if (Killed != None && Killer != Killed && Vehicle(Killed.Pawn) != None && Vehicle(Killed.Pawn).bCanFly)
	{
		//Maybe add to game stats?
		if (PlayerController(Killer) != None)
			PlayerController(Killer).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 5);
	}
}

defaultproperties
{
     VehicleClass=Class'HeavyTankV2Omni.HeavyTankV2Omni'
     DeathString="%k's Heavy tank shell blew %o into itty bitty bits."
     FemaleSuicide="%o fired her rocket prematurely."
     MaleSuicide="%o fired his rocket prematurely."
     bDetonatesGoop=True
     bDelayedDamage=True
     bThrowRagdoll=True
     bFlaming=True
     GibPerterbation=0.150000
     KDamageImpulse=20000.000000
}
