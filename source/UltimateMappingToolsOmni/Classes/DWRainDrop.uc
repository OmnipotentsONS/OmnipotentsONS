//=============================================================================
// DWRainDrop.
//=============================================================================
class DWRainDrop extends Projectile;

#exec OBJ LOAD FILE="DWeather-smesh.usx"

var vector Dir;

simulated function Destroyed()
{
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	self.SetDrawScale(RandRange(0.0015, 0.0025));
    
	Dir = vector(Rotation);
	Velocity = speed * Dir;
    
    if (PhysicsVolume.bWaterVolume)
        Destroy();

    Super.PostBeginPlay();
}

simulated function Landed( Vector HitNormal )
{
   	spawn(class'DWRainDropSplash',,,Location,rotator(HitNormal));
   	Destroy();
}

simulated function HitWall( vector HitNormal, actor Wall )
{
   	spawn(class'DWRainDropSplash',,,Location,rotator(HitNormal));
   	Destroy();
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
    if (Volume.bWaterVolume)
		Destroy();
}

defaultproperties
{
     Speed=4000.000000
     MaxSpeed=4000.000000
     MomentumTransfer=3000.000000
     MyDamageType=Class'UltimateMappingToolsOmni.DamTypeHailChunk'
     DrawType=DT_StaticMesh
     CullDistance=1500.000000
     Physics=PHYS_Falling
     LifeSpan=10.000000
     DrawScale=0.004000
     AmbientGlow=140
     Style=STY_Alpha
     bFixedRotationDir=True
}
