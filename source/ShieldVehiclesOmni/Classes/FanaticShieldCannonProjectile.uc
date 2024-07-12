//-----------------------------------------------------------
//
//-----------------------------------------------------------
class FanaticShieldCannonProjectile extends ShockProjectile;

var ONSShockBall ONSShockBallEffect;

simulated function PostBeginPlay()
{
	Super(Projectile).PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
	{
        ONSShockBallEffect = Spawn(class'ONSShockBall', self);
        ONSShockBallEffect.SetBase(self);
	}

	Velocity = Speed * Vector(Rotation); // starts off slower so combo can be done closer

    tempStartLoc = Location;
}

simulated function Destroyed()
{
    if (ONSShockBallEffect != None)
    {
		if ( bNoFX )
			ONSShockBallEffect.Destroy();
		else
			ONSShockBallEffect.Kill();
	}

	Super.Destroyed();
}

simulated function DestroyTrails()
{
    if (ONSShockBallEffect != None)
        ONSShockBallEffect.Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    if (Owner != None && FanaticShieldCannon(Owner) != None && Other == FanaticShieldCannon(Owner).ShockShield)
        ProximityExplode();
    else
        Super.ProcessTouch(Other, HitLocation);
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	local PlayerController PC;

    if (Owner != None && FanaticShieldCannon(Owner) != None && Wall == FanaticShieldCannon(Owner).ShockShield)
        ProximityExplode();
    else
    {
        if ( Role == ROLE_Authority )
    	{
    		if ( !Wall.bStatic && !Wall.bWorldGeometry )
    		{
    			if ( Instigator == None || Instigator.Controller == None )
    				Wall.SetDelayedDamageInstigatorController( InstigatorController );
    			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
    			if (DamageRadius > 0 && Vehicle(Wall) != None && Vehicle(Wall).Health > 0)
    				Vehicle(Wall).DriverRadiusDamage(Damage, DamageRadius, InstigatorController, MyDamageType, MomentumTransfer, Location);
    			HurtWall = Wall;
    		}
    		MakeNoise(1.0);
    	}
    	Explode(Location + ExploWallOut * HitNormal, HitNormal);
    	if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer)  )
    	{
    		if ( ExplosionDecal.Default.CullDistance != 0 )
    		{
    			PC = Level.GetLocalPlayerController();
    			if ( !PC.BeyondViewDistance(Location, ExplosionDecal.Default.CullDistance) )
    				Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    			else if ( (Instigator != None) && (PC == Instigator.Controller) && !PC.BeyondViewDistance(Location, 2*ExplosionDecal.Default.CullDistance) )
    				Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    		}
    		else
    			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    	}
    	HurtWall = None;
    }
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
    SuperExplosion();
}

function ProximityExplode()
{
    PlaySound(ComboSound, SLOT_None,1.0,,800);
    FanaticShieldCannon(Owner).ProximityExplosion();
    Destroy();
}

function SuperExplosion()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HurtRadius(ComboDamage, ComboRadius, class'DamTypeShockTankShockBall', ComboMomentumTransfer, Location );

	Spawn(class'FanaticShockExplosion');
	if ( (Level.NetMode != NM_DedicatedServer) && EffectIsRelevant(Location,false) )
	{
		HitActor = Trace(HitLocation, HitNormal,Location - Vect(0,0,120), Location,false);
		if ( HitActor != None )
			Spawn(class'ComboDecal',self,,HitLocation, rotator(vect(0,0,-1)));
	}
	PlaySound(ComboSound, SLOT_None,1.0,,800);
    DestroyTrails();
    Destroy();
}

defaultproperties
{
     ComboSound=Sound'ONSBPSounds.ShockTank.ShockBallExplosion'
     ComboRadius=400.000000
     ComboMomentumTransfer=150000.000000
     Speed=11000.000000
     MaxSpeed=11000.000000
     Damage=100.000000
     DamageRadius=225.000000
     DrawType=DT_None
     AmbientSound=Sound'ONSBPSounds.ShockTank.ShockBallAmbient'
     Texture=None
     DrawScale=1.750000
     Skins(0)=None
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
