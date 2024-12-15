//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MonsterTruckIIOmniFactory extends ONSVehicleFactory;

defaultproperties
{
     RedBuildEffectClass=Class'Onslaught.ONSRVBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSRVBuildEffectBlue'
     VehicleClass=Class'MonsterTruckOmni.MonsterTruckIIOmni'
     bUseDynamicLights=True
     Mesh=SkeletalMesh'MTII.MTB'
     Skins(0)=Texture'MTII.MTUnderside'
     Skins(1)=Texture'MTII.MTRed'
     Skins(2)=Shader'MTII.MTIIGlass'
     Skins(3)=Texture'MTII.MTSusp'
     Skins(4)=Texture'MTII.MTWheel'
     AmbientGlow=2
     bShadowCast=True
}
