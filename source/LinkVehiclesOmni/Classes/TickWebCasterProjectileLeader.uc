/**
A 2D web reimplementation of the stock Scorpion's web launcher.

Copyright (c) 2016, Wormbo

(1) This source code and any binaries compiled from it are provided "as-is",
without warranty of any kind. (In other words, if it breaks something for you,
that's entirely your problem, not mine.)
(2) You are allowed to reuse parts of this source code and binaries compiled
from it in any way that does not involve making money, breaking applicable laws
or restricting anyone's human or civil rights.
(3) You are allowed to distribute binaries compiled from modified versions of
this source code only if you make the modified sources available as well. I'd
prefer being mentioned in the credits for such binaries, but please do not make
it seem like I endorse them in any way.
*/

class TickWebCasterProjectileLeader extends TickWebCasterProjectile;


//=============================================================================
// Properties
//=============================================================================

var() float SpringStiffness;
var() float StuckSpringStiffness; //when a projectile in this web gets stuck, SpringStiffness is set to this
var() float SpringDamping;
var() float SpringMaxForce;
var() float SpringExplodeLength; // Max stretch length before web explodes.
var() float ProjVelDamping; //
var() float ProjStuckNeighbourVelDamping; // Extra damping applied when a neighbour is attached to something.
var() InterpCurve ProjGravityScale; // Function of time since launched.

// To make the web stuff particularly effective against Mantas, it is sucked into the top of the fans.
var() bool bEnableSuckTargetForce;
var() bool bSuckFriendlyActor; // Don't get sucked towards actors on own team.
var() float SuckTargetSearchRange; // Radius to search suck target vehicles
var() array<struct TSuckTarget {
	var() bool bOnlySuckToDriven; // Only suck to an actor if bDriving is true.
	var() bool bSymmetricSuckTarget; // Suck to SuckTargetOffset mirrored across Y as well (eg. for manta fans)
	var() bool bNoSuckFromBelow; // If the projectile is 'below' the suck target (ie. negative local Z) it won't get sucked.
	var() class<Vehicle> SuckTargetClass; // Class of actors that projectile should get sucked towards.
	var() float SuckTargetRange; // Distance from SuckTarget before projectile starts getting sucked.
	var() float SuckTargetForce; // Force applied to suck projectile towards target.
	var() vector SuckTargetOffset; // Location in target ref frame that projectile will be sucked too
	var() float SuckReduceVelFactor; // Once a particle is getting sucked, how much to kill velocity that is not in the suck direction.
}> SuckTargets;


//=============================================================================
// Variables
//=============================================================================

var byte ProjTeam;
var float FireTime;
var	array<TickWebCasterProjectile> Projectiles;
var	array<TickWebCasterProjectile> Links1;
var	array<TickWebCasterProjectile> Links2;
var bool bStuckToAnything;


//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		ProjTeam;
}


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	FireTime = Level.TimeSeconds;
}


// Walk over entire web, detonating projectiles. Only called on server.
function DetonateWeb()
{
	local int i;

	// We want to destroy ourself last!
	for (i = 1; i < Projectiles.Length; i++)
	{
		if (Projectiles[i] != None)
			Projectiles[i].Explode(Projectiles[i].Location, Projectiles[i].StuckNormal);
	}

	Explode(Location, StuckNormal);
}

simulated function NotifyStuck()
{
	SpringStiffness = StuckSpringStiffness;
	bStuckToAnything = True;
}

simulated function TryPreAllProjectileTick(float DeltaTime)
{
	local int i;
	
	for (i = 0; i < Projectiles.Length; i++) {
		if (Projectiles[i] != None && Projectiles[i].LastTickTime == Level.TimeSeconds)
			return; // Some projectiles have already been ticked this frame...
	}
	
	// If we get here - this is the first projectile in this web to be ticked.
	// We do all the spring forces now, before physics is done.
	SetUpLinks();
	ApplySpringForces(DeltaTime);
	UpdateBeams(DeltaTime);
}


simulated function SetUpLinks()
{
	local int i, NumProjectiles, j;
	
	NumProjectiles = Projectiles.Length;
	
	// beams "web" structure:
	Links1.Length = NumProjectiles;
	Links2.Length = NumProjectiles;
	
	// 0 -> 1, 2
	if (NumProjectiles > 1)
		Links1[0] = Projectiles[1];
	if (NumProjectiles > 2)
		Links2[0] = Projectiles[2];
	
	// i -> +2, (i%4->)[-1, +1, +1, +3]
	for (i = 1; i < NumProjectiles - 1; i++) {
		if (NumProjectiles > i + 2)
			Links1[i] = Projectiles[i+2];
		
		j = ((i & 3) - 1) | 1; // 0 -> -1; 1,2 -> +1; 3 -> +3
		if (NumProjectiles > i+j)
			Links2[i] = Projectiles[i+j];
	}
}


simulated function ApplySpringForces(float DeltaTime)
{
	local float FlyTime;
	local vector ProjGravity;
	local int i;
	local TickWebCasterProjectile P, P1, P2;
	local bool bOldBeingSucked;
	local Vehicle SuckVehicle;
	local TSuckTarget SuckTargetParams, ClosestSuckParams;
	local vector ClosestSuckLocation, ActorSuckLocation, SuckDir, DeltaDir, RelVel;
	local float ClosestSuckDist, SuckDist, DeltaMag, ErrorMag, RelVelMag, ForceMag, SpringLength;
	local Vehicle ClosestSuckVehicle;
	
	// Work out how much gravity to apply to projectiles (function of fly time)
	FlyTime = Level.TimeSeconds - FireTime;
	ProjGravity = InterpCurveEval(ProjGravityScale, FlyTime) * PhysicsVolume.Gravity;
	
	// Walk list and reset all accelerations.
	for (i = 0; i < Projectiles.Length; i++) {
		if (Projectiles[i] != None) {
			P = Projectiles[i];
			
			if (P.Velocity.Z < -450.0 && P.LifeSpan < 8.0)
				P.LifeSpan = FMin(P.LifeSpan, 0.01);
			
			if (NeighborIsAttached(i))
				P.Acceleration = ProjGravity - ((ProjVelDamping + ProjStuckNeighbourVelDamping) * P.Velocity);
			else
				P.Acceleration = ProjGravity - ProjVelDamping * P.Velocity;
			
			bOldBeingSucked = P.bBeingSucked;
			P.bBeingSucked = False;
			
			if (P.StuckActor == None) {
				ClosestSuckDist = SuckTargetSearchRange;
				
				foreach CollidingActors(class'Vehicle', SuckVehicle, SuckTargetSearchRange, P.Location) {
					if (SuckVehicle.Team != ProjTeam && IsSuckableVehicle(SuckVehicle, SuckTargetParams) && (!SuckTargetParams.bOnlySuckToDriven || SuckVehicle.bDriving)) {
						ActorSuckLocation = SuckVehicle.Location + (SuckTargetParams.SuckTargetOffset >> SuckVehicle.Rotation);
						SuckDist = VSize(ActorSuckLocation - P.Location);
						
						if (SuckDist < SuckTargetParams.SuckTargetRange && SuckDist < ClosestSuckDist) {
							ClosestSuckDist = SuckDist;
							ClosestSuckLocation = ActorSuckLocation;
							ClosestSuckVehicle = SuckVehicle;
							ClosestSuckParams = SuckTargetParams;
							P.bBeingSucked = True;
						}
						
						// Check the mirrored suck location
						if (SuckTargetParams.bSymmetricSuckTarget) {
							
							ActorSuckLocation = SuckVehicle.Location + (SuckTargetParams.SuckTargetOffset * vect(1,-1,1) >> SuckVehicle.Rotation);
							SuckDist = VSize(ActorSuckLocation - P.Location);
							
							if (SuckDist < SuckTargetParams.SuckTargetRange && SuckDist < ClosestSuckDist) {
								ClosestSuckDist = SuckDist;
								ClosestSuckLocation = ActorSuckLocation;
								ClosestSuckVehicle = SuckVehicle;
								ClosestSuckParams = SuckTargetParams;
								P.bBeingSucked = True;
							}
						}
					}
				}
				
				if (P.bBeingSucked) {
					SuckDir = Normal(ClosestSuckLocation - P.Location);
					P.Acceleration += ClosestSuckParams.SuckTargetForce * SuckDir;
					
					if (!bOldBeingSucked) {
						P.NetUpdateTime = Level.TimeSeconds - 1;
						P.Velocity = ClosestSuckParams.SuckReduceVelFactor * ClosestSuckVehicle.Velocity + (1.0 - ClosestSuckParams.SuckReduceVelFactor) * P.Velocity;
					}
				}
			}
		}
	}
	
	
	// Then calculate forces for each spring.
	for (i = 0; i < Projectiles.Length; i++) {
		
		P1 = Projectiles[i];
		P2 = Links1[i];
		
		if (P1 != None && P2 != None && !(P1.bBeingSucked && P2.bBeingSucked)) {
			DeltaDir = P2.Location - P1.Location;
			DeltaMag = VSize(DeltaDir);
			
			if (DeltaMag > 0.01)
				DeltaDir /= DeltaMag;
			else
				DeltaDir = vect(1,0,0);
			
			if (Role == ROLE_Authority && DeltaMag > SpringExplodeLength) {
				DetonateWeb();
				return;
			}
			
			// Find 'stretch' of spring
			SpringLength = P1.SpringLength1;
			if (P1.StuckActor != None || P2.StuckActor != None)
				SpringLength *= 0.01; // contract web when caught on something
			else if (bStuckToAnything)
				SpringLength *= 0.3; // contract web when caught on something
			ErrorMag = DeltaMag - SpringLength;
			//if (!bStuckToAnything && ErrorMag < -0.9 * SpringLength)
			//	ErrorMag *= 10; // initally extend the web
			
			// Find relative velocity along error vector.
			RelVel = P2.Velocity - P1.Velocity;
			RelVelMag = RelVel dot DeltaDir;
			
			// Make force to push/pull particles apart.
			ForceMag = FClamp(-SpringStiffness * ErrorMag + -SpringDamping * RelVelMag, -SpringMaxForce, SpringMaxForce);

			// Equal and opposite
			P1.Acceleration += -ForceMag * DeltaDir;
			P2.Acceleration += ForceMag * DeltaDir;
		}
		
		P2 = Links2[i];
		
		if (P1 != None && P2 != None && !(P1.bBeingSucked && P2.bBeingSucked)) {
			DeltaDir = P2.Location - P1.Location;
			DeltaMag = VSize(DeltaDir);
			
			if (DeltaMag > 0.01)
				DeltaDir /= DeltaMag;
			else
				DeltaDir = vect(1,0,0);
			
			// Find 'stretch' of spring
			SpringLength = P1.SpringLength2;
			if (P1.StuckActor != None || P2.StuckActor != None)
				SpringLength *= 0.01; // contract web when caught on something
			else if (bStuckToAnything)
				SpringLength *= 0.3; // contract web when caught on something
			ErrorMag = DeltaMag - SpringLength;
			//if (!bStuckToAnything && ErrorMag < -0.9 * SpringLength)
			//	ErrorMag *= 10; // initally extend the web
			
			// Find relative velocity along error vector.
			RelVel = P2.Velocity - P1.Velocity;
			RelVelMag = RelVel dot DeltaDir;
			
			// Make force to push/pull particles apart.
			ForceMag = FClamp(-SpringStiffness * ErrorMag + -SpringDamping * RelVelMag, -SpringMaxForce, SpringMaxForce);

			// Equal and opposite
			P1.Acceleration += -ForceMag * DeltaDir;
			P2.Acceleration += ForceMag * DeltaDir;
		}
	}
}


simulated function bool NeighborIsAttached(int ProjNum)
{
	return ProjNum >= 0
		&& (ProjNum < Links1.Length && Links1[ProjNum] != None && Links1[ProjNum].StuckActor != None
		|| ProjNum < Links2.Length && Links2[ProjNum] != None && Links2[ProjNum].StuckActor != None);
}


simulated function bool IsSuckableVehicle(Vehicle SuckVehicle, out TSuckTarget SuckTargetParams)
{
	local int i;
	
	if (SuckVehicle != None) {
		for (i = 0; i < SuckTargets.Length; i++) {
			if (ClassIsChildOf(SuckVehicle.Class, SuckTargets[i].SuckTargetClass)) {
				SuckTargetParams = SuckTargets[i];
				return true;
			}
		}
	}
	return false;
}


simulated function UpdateBeams(float DeltaTime)
{
	local int i;
	local TickWebCasterProjectile P1;
	
	for (i = 0; i < Projectiles.Length; i++) {
		P1 = Projectiles[i];
		
		// first target
		if (P1 != None && P1.ProjectileEffect != None && P1.ProjectileEffect.Emitters.Length > P1.BeamSubEmitterIndex1)
			UpdateBeam(DeltaTime, BeamEmitter(P1.ProjectileEffect.Emitters[P1.BeamSubEmitterIndex1]), Links1[i]);
		
		// second target
		if (P1 != None && P1.ProjectileEffect != None && P1.ProjectileEffect.Emitters.Length > P1.BeamSubEmitterIndex2)
			UpdateBeam(DeltaTime, BeamEmitter(P1.ProjectileEffect.Emitters[P1.BeamSubEmitterIndex2]), Links2[i]);
	}
}


simulated function UpdateBeam(float DeltaTime, BeamEmitter BE, TickWebCasterProjectile P2)
{
	local vector PredictedVel, PredictedPos;
	
	if (BE != None && P2 != None) {
		PredictedVel = P2.Velocity + (P2.Acceleration * DeltaTime);
		PredictedPos = P2.Location + (PredictedVel * DeltaTime);
		
		if (BE.BeamEndPoints.Length > 0)
		{
			BE.BeamEndPoints[0].Offset.X.Min = PredictedPos.X;
			BE.BeamEndPoints[0].Offset.X.Max = PredictedPos.X;
			BE.BeamEndPoints[0].Offset.Y.Min = PredictedPos.Y;
			BE.BeamEndPoints[0].Offset.Y.Max = PredictedPos.Y;
			BE.BeamEndPoints[0].Offset.Z.Min = PredictedPos.Z;
			BE.BeamEndPoints[0].Offset.Z.Max = PredictedPos.Z;

			BE.BeamTextureUScale = RandRange(0.5, 2.5);
			if (FRand() > 0.5)
				BE.BeamTextureUScale *= -1;
			
			BE.Disabled = False;
		}
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     SpringStiffness=5.000000
     StuckSpringStiffness=50.000000
     SpringDamping=6.000000
     SpringMaxForce=4500.000000
     SpringExplodeLength=1500.000000
     ProjStuckNeighbourVelDamping=5.000000
     ProjGravityScale=(Points=(,(InVal=4.000000),(InVal=5.000000,OutVal=0.500000),(InVal=1000000.000000,OutVal=0.500000)))
     bEnableSuckTargetForce=True
     SuckTargetSearchRange=490.000000
     SuckTargets(0)=(bOnlySuckToDriven=True,bSymmetricSuckTarget=True,SuckTargetClass=Class'Onslaught.ONSHoverBike',SuckTargetRange=275.000000,SuckTargetForce=6500.000000,SuckTargetOffset=(X=25.000000,Y=80.000000,Z=-10.000000),SuckReduceVelFactor=0.900000)
     SuckTargets(1)=(bOnlySuckToDriven=True,bSymmetricSuckTarget=True,SuckTargetClass=Class'OnslaughtBP.ONSDualAttackCraft',SuckTargetRange=350.000000,SuckTargetForce=6000.000000,SuckTargetOffset=(X=-96.000000,Y=90.000000,Z=50.000000),SuckReduceVelFactor=0.900000)
     SuckTargets(2)=(bOnlySuckToDriven=True,bSymmetricSuckTarget=True,SuckTargetClass=Class'Onslaught.ONSAttackCraft',SuckTargetRange=300.000000,SuckTargetForce=6500.000000,SuckTargetOffset=(X=-96.000000,Y=25.000000,Z=50.000000),SuckReduceVelFactor=0.900000)
     SuckTargets(3)=(SuckTargetClass=Class'Engine.Vehicle',SuckTargetRange=150.000000,SuckTargetForce=6500.000000,SuckReduceVelFactor=0.900000)
}
