//=============================================================================
// FlakChunk.
//=============================================================================
class HeavyTankFlak extends Projectile;

var xEmitter Trail;
var byte Bounces;
var float DamageAtten;
var sound ImpactSounds[6];

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        Bounces;
}

simulated function Destroyed()
{
    if (Trail !=None) Trail.mRegen=False;
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
    local float r;

    if ( Level.NetMode != NM_DedicatedServer )
    {
        if ( !PhysicsVolume.bWaterVolume )
        {
            Trail = Spawn(class'FlakTrail',self);
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

    Super.PostBeginPlay();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    if ( (FlakChunk(Other) == None) && ((Physics == PHYS_Falling) || (Other != Instigator)) )
    {
        speed = VSize(Velocity);
        if ( speed > 200 )
        {
            if ( Role == ROLE_Authority )
			{
				if ( Instigator == None || Instigator.Controller == None )
					Other.SetDelayedDamageInstigatorController( InstigatorController );

                Other.TakeDamage( Max(5, Damage - DamageAtten*FMax(0,(default.LifeSpan - LifeSpan - 1))), Instigator, HitLocation,
                    (MomentumTransfer * Velocity/speed), MyDamageType );
			}
        }
        Destroy();
    }
}

simulated function Landed( Vector HitNormal )
{
    SetPhysics(PHYS_None);
    LifeSpan = 1.0;
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
    if (Volume.bWaterVolume)
    {
        if ( Trail != None )
            Trail.mRegen=False;
        Velocity *= 0.65;
    }
}

defaultproperties
{
     Bounces=1
     DamageAtten=5.000000
     ImpactSounds(0)=Sound'XEffects.Impact4Snd'
     ImpactSounds(1)=Sound'XEffects.Impact6Snd'
     ImpactSounds(2)=Sound'XEffects.Impact7Snd'
     ImpactSounds(3)=Sound'XEffects.Impact3'
     ImpactSounds(4)=Sound'XEffects.Impact1'
     ImpactSounds(5)=Sound'XEffects.Impact2'
     Speed=17500.000000
     MaxSpeed=20000.000000
     Damage=18.000000
     MomentumTransfer=10000.000000
     MyDamageType=Class'HeavyTankV2Omni.DamTypeHeavyTankFlak'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakChunk'
     CullDistance=5000.000000
     LifeSpan=2.000000
     DrawScale=10.000000
     AmbientGlow=254
     Style=STY_Alpha
     bBounce=True
}
