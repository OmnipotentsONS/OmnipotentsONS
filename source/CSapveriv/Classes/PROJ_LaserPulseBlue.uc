//-----------------------------------------------------------
//    PROJ_LaserPulseBlue
//-----------------------------------------------------------
class PROJ_LaserPulseBlue extends PROJ_LaserPulse;

#exec OBJ LOAD FILE=XEffectMat.utx

simulated function SetupProjectile()
{
	// FX
	if ( Level.NetMode != NM_DedicatedServer )
	{
		Laser = Spawn(LaserClass, Self,, Location, Rotation);

		if ( Laser != None )
		{
			Laser.SetBase( Self );
			Laser.SetScale( 0.67, 0.67 );
		}
	}
}

defaultproperties
{
     LightHue=150
}
