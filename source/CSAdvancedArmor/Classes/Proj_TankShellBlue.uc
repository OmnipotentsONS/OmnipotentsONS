//=============================================================================
// Proj_TankShellBlue
//=============================================================================
class Proj_TankShellBlue extends Proj_TankShell;


simulated function PostBeginPlay()
{
	if ( !PhysicsVolume.bWaterVolume && (Level.NetMode != NM_DedicatedServer) )
		Trail = Spawn(class'CSAdvancedArmor.FX_TankProjTrailBlue',self);

	Super.PostBeginPlay();
	Velocity = Vector(Rotation) * Speed;
	initialDir = Velocity;
}

simulated function destroyed()
{
	if (Trail!=None)
		Trail.mRegen=False;
	Super.Destroyed();
}

defaultproperties
{
     Texture=Texture'AdvancedArmor_Tex.FlashBlue'
     Skins(0)=Texture'AdvancedArmor_Tex.FlashBlue'
}
