/******************************************************************************
OdinLinkPlasmaProjectile

Creation date: 2012-10-24 19:15
Last change: $Id$
Copyright � 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class OdinLinkPlasmaProjectile extends ONSPlasmaProjectile;


//=============================================================================
// Imports
//=============================================================================

#exec audio import file=Sounds\OdinLinkPlasmaHit.wav
#exec audio import file=Sounds\OdinLinkPlasmaBounce.wav


//=============================================================================
// Variables
//=============================================================================

var byte RemainingBounces;


replication
{
	reliable if (bNetInitial)
		RemainingBounces;
}


simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	local vector X, RefDir, RefNormal;
	local OdinLinkPlasmaProjectile P;

	if (Other == Instigator || Vehicle(Instigator) != None && Vehicle(Instigator).Driver == Other)
		return;

	if (xPawn(Other) != None && xPawn(Other).CheckReflect(HitLocation, RefNormal, Damage * 0.25))
	{
		if (Role == ROLE_Authority)
		{
			X = Normal(Velocity);
			RefDir = X - 2.0 * RefNormal * (X dot RefNormal);
			P = Other.Spawn(Class, Other,, HitLocation + RefDir * 20, Rotator(RefDir));
			if (P != None)
			{
				P.LifeSpan = FMax(LifeSpan, default.LifeSpan * 0.25);
				P.RemainingBounces = RemainingBounces;
			}
		}
		Other.PlaySound(Sound'OdinLinkPlasmaBounce',, TransientSoundVolume,, TransientSoundRadius);
		Other.MakeNoise(0.3);
		Destroy();
	}
	else
	{
		Explode(HitLocation, Normal(HitLocation-Other.Location));
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (Role == ROLE_Authority)
		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);

	if (EffectIsRelevant(Location, false))
		Spawn(HitEffectClass,,, HitLocation + HitNormal * 5, rotator(-HitNormal));

	PlaySound(Sound'OdinLinkPlasmaHit');

	Destroy();
}

simulated function Bounce(vector HitLocation, vector HitNormal)
{
	RemainingBounces--;

	if (Role == ROLE_Authority)
		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);

	if (EffectIsRelevant(Location, false))
		Spawn(HitEffectClass,,, HitLocation + HitNormal * 5, rotator(-HitNormal));

	PlaySound(Sound'OdinLinkPlasmaBounce');

	Velocity = MirrorVectorByNormal(Velocity, HitNormal) * 0.5;
	Acceleration = AccelerationMagnitude * Normal(Velocity);
	SetRotation(rotator(Velocity));
	if (Plasma != None)
		Plasma.SetRotation(Rotation);

	if (Role == ROLE_Authority && InstigatorController != None && InstigatorController.ShotTarget != None && InstigatorController.ShotTarget.Controller != None)
		InstigatorController.ShotTarget.Controller.ReceiveProjectileWarning(Self);
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	local PlayerController PC;

	if (Role == ROLE_Authority)
	{
		if (!Wall.bStatic && !Wall.bWorldGeometry)
		{
			if (OdinLinkTurretPawn(Instigator) != None && Wall == OdinLinkTurretPawn(Instigator).VehicleBase)
			{
				if (Bot(InstigatorController) != None && Instigator.Controller == InstigatorController)
				{
					OdinLinkTurretPawn(Instigator).ConsiderSwitchingSides(InstigatorController.Pawn);
				}
			}
			else
			{
				if (Instigator == None || Instigator.Controller == None)
					Wall.SetDelayedDamageInstigatorController(InstigatorController);
				Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
				if (DamageRadius > 0 && Vehicle(Wall) != None && Vehicle(Wall).Health > 0)
					Vehicle(Wall).DriverRadiusDamage(Damage, DamageRadius, InstigatorController, MyDamageType, MomentumTransfer, Location);
			}
			HurtWall = Wall;
		}
		MakeNoise(1.0);
	}
	if (Wall.bProjTarget || RemainingBounces == 0)
		Explode(Location + ExploWallOut * HitNormal, HitNormal);
	else
		Bounce(Location + ExploWallOut * HitNormal, HitNormal);

	if (ExplosionDecal != None && Level.NetMode != NM_DedicatedServer)
	{
		if (ExplosionDecal.Default.CullDistance != 0)
		{
			PC = Level.GetLocalPlayerController();
			if (!PC.BeyondViewDistance(Location, ExplosionDecal.Default.CullDistance))
				Spawn(ExplosionDecal, self,, Location, rotator(-HitNormal));
			else if (Instigator != None && PC == Instigator.Controller && !PC.BeyondViewDistance(Location, 2 * ExplosionDecal.Default.CullDistance))
				Spawn(ExplosionDecal, self,, Location, rotator(-HitNormal));
		}
		else
			Spawn(ExplosionDecal, self,, Location, rotator(-HitNormal));
	}
	HurtWall = None;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     RemainingBounces=2
     PlasmaEffectClass=Class'Onslaught.ONSGreenPlasmaSmallFireEffect'
     AccelerationMagnitude=10000.000000
     Speed=1000.000000
     MaxSpeed=15000.000000
     Damage=25.000000
     DamageRadius=200.000000
     MomentumTransfer=12000.000000
     MyDamageType=Class'OdinV2Omni.DamTypeOdinLinkPlasma'
     LifeSpan=2.000000
     bBounce=True
}
