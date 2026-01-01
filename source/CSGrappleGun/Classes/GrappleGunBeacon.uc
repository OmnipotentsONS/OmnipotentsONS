class GrappleGunBeacon extends Projectile;

var bool bCanHitOwner, bHitWater;
var bool bDamaged;
var bool bNoAI;
var xEmitter Trail;
var xEmitter Flare;
var Emitter Line;
var TransBeaconSparks Sparks;
var class<TransTrail> TransTrailClass;
var class<TransFlareBlue> TransFlareClass;
var class<GrappleLineEffect> TransLineClass;
var Sound HitWallSounds[6];

simulated function Destroyed()
{
    if ( Trail != None )
        Trail.mRegen = false;
    if ( Flare != None )
    {
		Flare.mRegen = false;
        Flare.Destroy();
    }
    if ( Line != None )
    {
        Line.Destroy();
        Line=None;
    }
    if ( Sparks != None )
    {
        Sparks.Destroy();
        Sparks = None;
    }

	Super.Destroyed();
}

event EncroachedBy( actor Other )
{
	if ( Mover(Other) != None )
		Destroy();
}

simulated function PostBeginPlay()
{
    local Rotator r;

    Super.PostBeginPlay();
    if ( Role == ROLE_Authority )
    {
		R = Rotation;
        Velocity = Speed * Vector(R);
        R.Yaw = Rotation.Yaw;
        R.Pitch = 0;
        R.Roll = 0;
        SetRotation(R);
        bCanHitOwner = false;
    }

    Trail = Spawn(TransTrailClass, self,, Location, Rotation);
}

function bool AimUp()
{
	if ( xPlayer(Instigator.Controller) == None )
		return false;

	return xPlayer(Instigator.Controller).bHighBeaconTrajectory;
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
}

simulated function Landed( vector HitNormal )
{
    HitWall( HitNormal, None );
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	local vector Vel2D;

    if ( Other == Instigator && Physics == PHYS_None )
        return;
    else if ( (Other != Instigator) || bCanHitOwner )
    {
   		if ( (Pawn(Other) != None) && (Vehicle(Other) == None) )
		{
			Vel2D = Velocity;
			Vel2D.Z = 0;
			if ( VSize(Vel2D) < 200 )
				return;
		}
		HitWall( -Normal(Velocity), Other );
    }
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    if ( Level.Game.bTeamGame && (EventInstigator != None)
		&& (EventInstigator.PlayerReplicationInfo != None)
		&& ((Instigator == None) || (EventInstigator.PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team)) )
    {
		return;
    }

    super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    Lifespan=0.0;
    bCanHitOwner = true;

    bBounce=false;
    Velocity=vect(0,0,0);
    SetPhysics(PHYS_None);
    SetBase(Wall);
	Speed = VSize(Velocity);
    PlaySound(HitWallSounds[Rand(6)], SLOT_Misc,2.0);

    // no grapple to blocking volumes
    if(BlockingVolume(Wall) != None)
    {
        Destroy();
        return;
    }

	if ( Speed < 20 && Wall.bWorldGeometry && (HitNormal.Z >= 0.7) )
	{
		if ( Level.NetMode != NM_DedicatedServer )
			PlaySound(ImpactSound, SLOT_Misc );

		if (Trail != None)
			Trail.mRegen = false;

		if ( (Level.NetMode != NM_DedicatedServer) && (Flare == None) )
		{
			Flare = Spawn(TransFlareClass, self,, Location - vect(0,0,5), rot(16384,0,0));
			Flare.SetBase(self);
		}
	}
    //if ( (Level.NetMode != NM_DedicatedServer) && (Line == None) )
    if ( (Level.NetMode != NM_DedicatedServer) && (Line == None) )
    {
        if(Trail != none)
            Trail.bHidden=true;

        Line = Spawn(TransLineClass, self,, Location, Rotation);
        Line.SetOwner(self);
        Line.SetBase(self);
        Line.Instigator = Instigator;
    }
}

defaultproperties
{
     TransTrailClass=Class'XEffects.TransTrail'
     TransFlareClass=Class'XEffects.TransFlareRed'
     TransLineClass=Class'GrappleLineEffect'
     HitWallSounds(0)=Sound'PlayerSounds.BFootsteps.BFootstepMetal1'
     HitWallSounds(1)=Sound'PlayerSounds.BFootsteps.BFootstepMetal2'
     HitWallSounds(2)=Sound'PlayerSounds.BFootsteps.BFootstepMetal3'
     HitWallSounds(3)=Sound'PlayerSounds.BFootsteps.BFootstepMetal4'
     HitWallSounds(4)=Sound'PlayerSounds.BFootsteps.BFootstepMetal5'
     HitWallSounds(5)=Sound'PlayerSounds.BFootsteps.BFootstepMetal6'
     Speed=15000.000000
     DamageRadius=100.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'XWeapons.DamTypeTeleFrag'
     ImpactSound=ProceduralSound'WeaponSounds.PGrenFloor1.P1GrenFloor1'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'E_Pickups.BombBall.FullBomb'
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     bOnlyDirtyReplication=True
     Physics=PHYS_Falling
     NetUpdateFrequency=8.000000
     AmbientSound=Sound'WeaponSounds.Misc.redeemer_flight'
     LifeSpan=0.250000
     DrawScale=0.350000
     PrePivot=(Z=25.000000)
     AmbientGlow=64
     bUnlit=False
     bOwnerNoSee=True
     bHardAttach=True
     SoundVolume=250
     SoundPitch=128
     SoundRadius=7.000000
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     bProjTarget=True
     bNetNotify=True
     bBounce=True
}
