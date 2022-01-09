//=============================================================================
// TankShellRed
//=============================================================================
class Proj_TankShellRed extends Proj_TankShell;


simulated function PostBeginPlay()
{
	if ( !PhysicsVolume.bWaterVolume && (Level.NetMode != NM_DedicatedServer) )
		Trail = Spawn(class'CSAdvancedArmor.FX_TankProjTrailRed',self);

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
}
