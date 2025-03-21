class CSShockMechShockComboVortex extends ShockComboVortex;

defaultproperties
{
    DrawType=DT_Mesh
    Mesh=VertMesh'ShockVortexMesh'
    Skins(0)=FinalBlend'XEffectMat.ShockElecRingFB'
    bUnlit=true
    bAlwaysFaceCamera=true

    LifeTime=1.0
    FadeInterp=(InTime=0.0,InStyle=IS_Linear,OutTime=0.9,OutStyle=IS_Linear)
    ScaleInterp=(Start=0.4,Mid=1.6,End=0.2,InTime=0.4,InStyle=IS_InvExp,OutTime=0.4,OutStyle=IS_InvExp)
    DrawScale=4.0
    DrawScale3D=(X=4.0,Y=4.0,Z=4.0)
    InitialRot=(Roll=16384)
}                      
