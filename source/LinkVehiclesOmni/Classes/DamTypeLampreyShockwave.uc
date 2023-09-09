// ============================================================================
// Ion Plasma Tank Shockwave Damage
// ============================================================================
class DamTypeLampreyShockwave extends VehicleDamageType;

// ============================================================================

defaultproperties
{
	   VehicleClass=Class'LinkVehiclesOmni.LampreyManta'
     DeathString="%o was bruised and battered too much by %k."
     FemaleSuicide="%o bruised and battered  herself around too much... oh dear"
     MaleSuicide="%o bruised and battered  himself around too much... oh dear"
     bArmorStops=False
     bDetonatesGoop=True
     bSkeletize=True
     DamageOverlayMaterial=Shader'UT2004Weapons.Shaders.ShockHitShader'
     DamageOverlayTime=1.000000
     VehicleDamageScaling=1.00000
}
