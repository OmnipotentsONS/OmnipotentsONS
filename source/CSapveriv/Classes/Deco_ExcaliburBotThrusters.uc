//=============================================================================
// Deco_ExcaliburHeavy.
//=============================================================================
class Deco_ExcaliburBotThrusters extends Decoration;


var FX_EXRoboExhaust EngineA, EngineB;
var bool bThrust;
var rotator ExhaustRot;
var Material RedSkin,RedSkinB;
var Material BlueSkin,BlueSkinB;
var vector IonFirePoint;
var coords IonFirePointCoords,IonFireBaseCoords;
var()	class<FX_Turret_IonCannon_BeamFire> BeamEffectClass;
var bool bPowerSlide;
var Material SpecialSkinA,SpecialSkinB;
simulated function PostNetBeginPlay()
{
  if (Role == ROLE_Authority)
     {
        EngineA = Spawn(class'FX_EXRoboExhaust',self,,Location);
        EngineA.SetBase(self);
		AttachToBone(EngineA,'ThrusterA');
		EngineA.SetThrustEnabled(false);
        EngineA.SetRelativeRotation(ExhaustRot);

        EngineB = Spawn(class'FX_EXRoboExhaust',self,,Location);
        EngineA.SetBase(self);
	    AttachToBone(EngineB,'ThrusterB');
	    EngineB.SetThrustEnabled(false);
	    EngineB.SetRelativeRotation(ExhaustRot);

     }
    super.PostBeginPlay();
}

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

simulated function SetThruster()
{
	if(bThrust==false)
	  {
	   bThrust=true;
       EngineA.SetThrustEnabled(True);
       EngineB.SetThrustEnabled(True);
      if(bPowerSlide==true)
         SetTimer(10.0,false);
      else
       SetTimer(4.0,false);
      }
}

simulated function Timer()
{
   if(bThrust==True)
	  {
	   bThrust=False;
       EngineA.SetThrustEnabled(False);
       EngineB.SetThrustEnabled(False);
       bPowerSlide=False;
      }
}
singular function BaseChange();





simulated function Destroyed()
{
   if (Role == ROLE_Authority)
    {
        // Destroy Engines
         EngineA.Destroy();
         EngineB.Destroy();
    }
}
simulated event EvilMonarchSpecial()
{
       Skins[0] = SpecialSkinA;
       Skins[1] = SpecialSkinB;
}

defaultproperties
{
     ExhaustRot=(Pitch=-16384)
     RedSkin=Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human2_C'
     RedSkinB=Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human1_C'
     BlueSkin=Combiner'APVerIV_Tex.ExcaliburSkins.ExcaliCombB'
     BlueSkinB=Combiner'APVerIV_Tex.ExcaliburSkins.ExcaliCombA'
     BeamEffectClass=Class'OnslaughtFull.ONSHoverTank_IonPlasma_BeamFire'
     SpecialSkinA=Texture'APVerIV_Tex.ExcaliburSkins.EvilMonarchSkinB'
     SpecialSkinB=Texture'APVerIV_Tex.ExcaliburSkins.EvilMonarchSkinA'
     bStatic=False
     bStasis=False
     bReplicateAnimations=True
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'APVerIV_Anim.IonThrusterMesh'
     DrawScale=5.000000
     Skins(0)=Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human2_C'
     Skins(1)=Combiner'AS_Vehicles_TX.SpaceFighter.SpaceFighter_Human1_C'
     bShouldBaseAtStartup=False
     bHardAttach=True
     Mass=1.000000
}
