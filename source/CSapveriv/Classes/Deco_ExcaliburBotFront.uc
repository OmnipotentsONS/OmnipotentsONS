//=============================================================================
// Deco_ExcaliburHeavy.
//=============================================================================
class Deco_ExcaliburBotFront extends Decoration;

var Material RedSkin,RedSkinB;
var Material BlueSkin,BlueSkinB;
var Material SpecialSkinA;

simulated function SetBlueColor()
{
    Skins[0] = BlueSkin;
    Skins[1] = BlueSkinB;
}

simulated function SetRedColor()
{
	Skins[0] = RedSkin;
    Skins[1] = RedSkinB;
}

simulated event EvilMonarchSpecial()
{
       Skins[0] = RedSkin;
       Skins[1] = SpecialSkinA;
}

singular function BaseChange();

defaultproperties
{
     RedSkin=Shader'APVerIV_Tex.ExcaliburSkins.GlassShader'
     RedSkinB=Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human1_C'
     BlueSkin=Shader'APVerIV_Tex.ExcaliburSkins.GlassShader'
     BlueSkinB=Combiner'APVerIV_Tex.ExcaliburSkins.ExcaliCombA'
     SpecialSkinA=Texture'APVerIV_Tex.ExcaliburSkins.EvilMonarchSkinA'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'APVerIV_ST.AP_Robot_ST.ExbotPartsB'
     bStatic=False
     bStasis=False
     RemoteRole=ROLE_None
     Skins(0)=Shader'APVerIV_Tex.ExcaliburSkins.GlassShader'
     Skins(1)=Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human1_C'
     bShouldBaseAtStartup=False
     bHardAttach=True
     Mass=1.000000
}
