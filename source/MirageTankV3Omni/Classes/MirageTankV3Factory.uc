//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MirageTankV3Factory extends ONSVehicleFactory;

defaultproperties
{
     RespawnTime=30.000000
     RedBuildEffectClass=Class'Onslaught.ONSTankBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSTankBuildEffectBlue'
     VehicleClass=Class'MirageTankV3Omni.MirageTankV3Omni'
     bUseDynamicLights=True
     Mesh=SkeletalMesh'MirageTankIIAnim.Panzer'
     Skins(0)=Texture'MirageTankII.TankRed'
     AmbientGlow=12
     bShadowCast=True
     bStaticLighting=True
}
