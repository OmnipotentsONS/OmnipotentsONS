class CSDarkLeviFlakChunk extends FlakChunk;

simulated function PostBeginPlay()
{
    local float r;

    if ( Level.NetMode != NM_DedicatedServer )
    {
        if ( !PhysicsVolume.bWaterVolume )
        {
            Trail = Spawn(class'CSDarkLeviFlakTrail',self);
            Trail.Lifespan = Lifespan;
        }
            
    }

    Velocity = Vector(Rotation) * (Speed);
    if (PhysicsVolume.bWaterVolume)
        Velocity *= 0.65;

    r = FRand();
    if (r > 0.75)
        Bounces = 2;
    else if (r > 0.25)
        Bounces = 1;
    else
        Bounces = 0;

    SetRotation(RotRand());

    Super(Projectile).PostBeginPlay();
}

defaultproperties
{
    speed=2500.000000
    MaxSpeed=2700.000000
    Damage=13
    DamageAtten=5.0 
    MomentumTransfer=10000
    DrawScale=14.0

    MyDamageType=class'CSDarkLeviDamTypeFlakChunk'
}
