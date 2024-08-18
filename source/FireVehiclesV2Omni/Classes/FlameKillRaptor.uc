class FlameKillRaptor extends FlameKill
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
     VehicleClass=Class'FireVehiclesV2Omni.FireRaptor'
     VehicleDamageScaling=1.2
}
