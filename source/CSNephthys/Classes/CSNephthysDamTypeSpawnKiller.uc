
class CSNephthysDamTypeSpawnKiller extends VehicleDamageType abstract;


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     VehicleClass=Class'CSNephthys.CSNephthys'
     DeathString="%o violated the server rules by spawn killing, tsk tsk"
     FemaleSuicide="%o violated the server rules by spawn killing, tsk tsk"
     MaleSuicide="%o violated the server rules by spawn killing, tsk tsk"
     bDelayedDamage=True
     DamageOverlayMaterial=Shader'UT2004Weapons.Shaders.ShockHitShader'
     DeathOverlayMaterial=Shader'UT2004Weapons.Shaders.ShockHitShader'
     DamageOverlayTime=0.800000
     DeathOverlayTime=1.500000
     VehicleDamageScaling=1.500000
     VehicleMomentumScaling=2.000000
}
