//=============================================================================
// Deco_ExcaliburHeavy.
//=============================================================================
class Deco_ExcaliburHeavy extends Decoration;


var FX_EXRoboExhaust EngineA, EngineB;
simulated function PostNetBeginPlay()
{
  local rotator EngineRot;
  EngineRot.Pitch=32768;
  if (Role == ROLE_Authority)
     {
        EngineA = Spawn(class'FX_EXRoboExhaust',self,,Location);
		EngineA.SetBase(self);
        AttachToBone(EngineA,'REngine');
        EngineA.SetRelativeRotation(EngineRot);
        EngineA.SetThrustEnabled(True);

        EngineB = Spawn(class'FX_EXRoboExhaust',self,,Location);
	    EngineB.SetBase(self);
	    AttachToBone(EngineB,'LEngine');
	    EngineB.SetRelativeRotation(EngineRot);
	    EngineB.SetThrustEnabled(True);
     }
    super.PostBeginPlay();
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

defaultproperties
{
     bStatic=False
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'APVerIV_Anim.ECBoosters'
     bShouldBaseAtStartup=False
     bHardAttach=True
     Mass=1.000000
}
