class TurtleProjectile extends ShockProjectile;

var TurtleShockBall ONSShockBallEffect;

simulated function PostBeginPlay()
{
	Super(Projectile).PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
	{
        ONSShockBallEffect = Spawn(class'TurtleShockBall', self);
        ONSShockBallEffect.SetBase(self);
	}

	Velocity = Speed * Vector(Rotation);
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
    if (Owner != None && TurtleCannon(Owner) != None && Other == TurtleCannon(Owner).ShockShield)
        ProximityExplode();
    else
        Super.ProcessTouch(Other, HitLocation);
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	local PlayerController PC;

    if (Owner != None && TurtleCannon(Owner) != None && Wall == TurtleCannon(Owner).ShockShield)
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
    TurtleCannon(Owner).ProximityExplosion();
    Destroy();
}

function SuperExplosion()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HurtRadius(ComboDamage, ComboRadius, class'TurtleKill', ComboMomentumTransfer, Location );

	Spawn(class'TurtleShockExplosion');
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
     ComboDamage=486.000000
     ComboRadius=800.000000
     ComboMomentumTransfer=700000.000000
     Speed=11000.000000
     MaxSpeed=11000.000000
     Damage=400.000000
     DamageRadius=555.000000
     DrawType=DT_None
     AmbientSound=Sound'ONSBPSounds.ShockTank.ShockBallAmbient'
     Texture=None
     DrawScale=5.000000
     Skins(0)=None
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
