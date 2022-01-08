//=====================================
//    Place holder for Engine Classes
//
//=======================================
#exec OBJ LOAD FILE=AW-2004Particles.utx
#exec OBJ LOAD FILE=jwDecemberArchitecture.utx
#exec OBJ LOAD FILE=APVerIV_Tex.utx

class FX_AirPowerEngineEffects extends Emitter
	placeable;


simulated function SetBlueColor();
simulated function SetRedColor();
simulated function Afterburn(bool bAfterburn);
simulated function SetInvisable()
{
   bHidden=true;
}

simulated function SetVisable()
{
   bHidden=False;
}

defaultproperties
{
     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=False
     RemoteRole=ROLE_SimulatedProxy
     AmbientGlow=180
     bHardAttach=True
     bDirectional=True
}
