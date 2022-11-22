class DWLightningEmitter extends Emitter
    notplaceable;

#exec OBJ LOAD FILE="..\Textures\UltimateMappingTools_Tex.utx"

defaultproperties
{
     Emitters(0)=BeamEmitter'UltimateMappingToolsOmni.DWLightning.BeamEmitter3'

     Emitters(1)=BeamEmitter'UltimateMappingToolsOmni.DWLightning.BeamEmitter4'

     Emitters(2)=BeamEmitter'UltimateMappingToolsOmni.DWLightning.BeamEmitter5'

     Emitters(3)=SpriteEmitter'UltimateMappingToolsOmni.DWLightning.SpriteEmitter1'

     AutoDestroy=True
     bNoDelete=False
     LifeSpan=2.000000
}
