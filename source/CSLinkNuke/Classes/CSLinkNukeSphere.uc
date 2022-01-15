class CSLinkNukeSphere extends MeshEffect;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetRotation(RotRand());
}

defaultproperties
{
     FadeInterp=(InTime=0.150000,OutTime=0.750000)
     ScaleInterp=(Start=0.100000,Mid=0.800000,InTime=0.500000,OutTime=0.500000,InStyle=IS_InvExp,OutStyle=IS_InvExp)
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Editor.TexPropSphere'
     //DrawScale3D=(X=8.500000,Y=8.500000,Z=8.500000)
     DrawScale3D=(X=12.500000,Y=12.500000,Z=12.500000)
     Skins(0)=FinalBlend'XEffectMat.Shield.RedShell'
     bUnlit=True
}
