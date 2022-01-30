
class CSMegaSpankerProjectile extends CSSpankBadgerProj;
simulated function PostBeginPlay()
{
	super(Projectile).PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
	{
        //ONSShockBallEffect = Spawn(class'CSSpankBadgerProjectileEffect', self);
        ONSShockBallEffect = Spawn(class'CSMegaSpankerProjEffect', self);
        ONSShockBallEffect.SetBase(self);
	}

    if(Role == ROLE_Authority)
    {
        Velocity = Speed * Vector(Rotation); 
        RandSpin(900000);
    }

    SetTimer(0.4, false);
}

function Timer()
{
    SetCollisionSize(160, 160);
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
    UltraExplosion();
}


defaultproperties
{
}