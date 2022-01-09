class FlameKill extends VehicleDamageType
	abstract;

#exec OBJ LOAD FILE=BarrensTerrain.utx

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
	HitEffects[0] = class'HitFlameBig';
}

static function class<Emitter> GetPawnDamageEmitter(vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail)
{
	if(Damage >= Victim.Health + Damage)
		Victim.SetOverlayMaterial(Texture'BarrensTerrain.Ground.rock09BA', 60, true);

	return none;
}

defaultproperties
{
     VehicleClass=Class'CSBadgerFix.FlameTank'
     DeathString="%o was burnt to a crisp."
     FemaleSuicide="%o shouldn't have played with fire."
     MaleSuicide="%o shouldn't have played with fire."
     bDetonatesGoop=True
     bCausesBlood=False
     bDelayedDamage=True
     GibModifier=0.000000
}
