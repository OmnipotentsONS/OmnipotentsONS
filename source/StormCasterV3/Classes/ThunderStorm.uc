/******************************************************************************
ThunderStorm

Creation date: 2013-09-08 17:48
Last change: $Id$
Copyright � 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class ThunderStorm extends AvoidMarker dependson(LightningTraceHelper);


//=============================================================================
// Imports
//=============================================================================

#exec audio import file=Sounds\StormStart.wav


//=============================================================================
// Properties
//=============================================================================

var() float MinDamage, MaxDamage, DamageRadius;
var() class<DamageType> MyDamageType;
var() float LightningOriginRadius;
var() float CloudTargetRadius, GroundTargetRadius, GroundTraceRange;
var() bool bAvoidTargetingTeammates;


//=============================================================================
// Variables
//=============================================================================

//var byte TeamNum;  Redundant
var Controller InstigatorController;
var int NumShadows;
var Emitter ThunderStormEffects;


function BeginPlay()
{
	StartleBots();
}

simulated function PostNetBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		ThunderStormEffects = Spawn(class'ThunderStormEmitter');
		PlaySound(Sound'StormStart', SLOT_Interact, 1.0, True, 4000.0);
		Spawn(class'StormShadowProjector',,, Location, rot(-15000,0,0));
	}
	SetTimer(1.0, False);
}

function Reset()
{
	LifeSpan = 1.0;
	bTearOff = True;
	TornOff();
}

simulated event TornOff()
{
	SetTimer(0.0, false);
	if (ThunderStormEffects != None)
	{
		ThunderStormEffects.Kill();
		ThunderStormEffects = None;
	}
}

simulated function Timer()
{
	local vector HitLocation, HitNormal, StartLocation, EndLocation;
	local LightningEmitterGround GLE;
	local LightningEmitterAir ALE;
	local Actor Victim;
	local bool bGroundHit;
	local Pawn P;
	local DestroyableObjective O;
	local array<Actor> PotentialVictims;
	local array<LightningTraceHelper.THitInfo> Hits;
	local int i;
	local byte TeamN;

	if (NumShadows++ < 3 && !bTearOff)
	{
		SetTimer(1.0, False);
		if (Level.NetMode != NM_DedicatedServer)
			Spawn(class'StormShadowProjector',,, Location, rot(-15000,0,0) + rot(0,22000,0) * NumShadows);
		return;
	}
	else if (bTearOff || Role != ROLE_Authority)
	{
		SetTimer(0.0, false);
		return;
	}

	SetTimer(RandRange(0.4, 0.6), False);

	if (Rand(2) == 0)
	{
		// only pick target about half of the time

		foreach DynamicActors(class'Pawn', P)
		{
			//log(self@"Pawn="@Pawn@" TeamNum="@TeamNum@" Pawn.GetTeamNum="@P.GetTeamNum);
			if (bAvoidTargetingTeammates && TeamNum != 255 && P.GetTeamNum() == TeamNum) {
				continue; // don't target teammates directly
			}
			
			if (P.Health > 0 && P.bCollideActors && P.bProjTarget && (VSize(vect(1,1,2) * (P.Location - Location)) < CloudTargetRadius || P.Location.Z < Location.Z && Location.Z - P.Location.Z < GroundTraceRange && VSize((P.Location - Location) * vect(1,1,0)) < GroundTargetRadius))
			{
				StartLocation = P.Location * vect(1,1,0) + vect(0,0,1) * Location.Z;
				if (VSize(StartLocation - Location) > LightningOriginRadius)
					StartLocation = Location + LightningOriginRadius * Normal(StartLocation - Location);
				if (FastTrace(P.Location, StartLocation) || FastTrace(P.Location, Location))
					PotentialVictims[PotentialVictims.Length] = P;
			}
		}

		foreach DynamicActors(class'DestroyableObjective', O)
		{
			if (bAvoidTargetingTeammates && TeamNum != 255 && O.DefenderTeamIndex == TeamNum)
				continue; // don't target own objectives directly
			
			EndLocation = O.GetShootTarget().Location;
			if (O.Health > 0 && O.bCollideActors && O.bProjTarget && (VSize(vect(1,1,2) * (EndLocation - Location)) < CloudTargetRadius || EndLocation.Z < Location.Z && Location.Z - EndLocation.Z < GroundTraceRange && VSize((EndLocation - Location) * vect(1,1,0)) < GroundTargetRadius))
			{
				StartLocation = EndLocation * vect(1,1,0) + vect(0,0,1) * Location.Z;
				if (VSize(StartLocation - Location) > LightningOriginRadius)
					StartLocation = Location + LightningOriginRadius * Normal(StartLocation - Location);
				if (FastTrace(EndLocation, StartLocation) || FastTrace(EndLocation, Location))
					PotentialVictims[PotentialVictims.Length] = O.GetShootTarget();
			}
		}
	}

	// magic randomization code to have less targeted hits when there are fewer targets
	if (Rand(Sqrt(PotentialVictims.Length) + 1) == 0)
	{
		// no target picked, let random lightning strike ground
		StartLocation = Location + vect(1,1,0) * VRand() * GroundTargetRadius;
		if (Trace(EndLocation, HitNormal, StartLocation - GroundTraceRange * vect(0,0,1), StartLocation, False) == None)
		{
			bGroundHit = False;
			EndLocation = StartLocation - GroundTraceRange * vect(0,0,1);
		}
		else
		{
			bGroundHit = True;
		}
	}
	else
	{
		// pick a victim, then decide whether to do ground lightning through victim or strike victim directly
		Victim = PotentialVictims[Rand(PotentialVictims.Length)];

		EndLocation = Victim.Location;

		StartLocation = EndLocation * vect(1,1,0) + vect(0,0,1) * Location.Z;

		if (VSize(StartLocation - Location) > LightningOriginRadius)
			StartLocation = Location + LightningOriginRadius * Normal(StartLocation - Location);

		if (Normal(EndLocation - StartLocation).Z > -0.5 || Normal(EndLocation - StartLocation).Z > -0.7 && FastTrace(EndLocation + 0.25 * (EndLocation - StartLocation), Startlocation))
		{
			// looks like an air target
			bGroundHit = False;
		}
		else
		{
			// somewhere between cloud and ground
			bGroundHit = !FastTrace(StartLocation + GroundTraceRange * Normal(EndLocation - StartLocation), StartLocation);
		}
	}

	// try random start location first
	StartLocation = Location + vect(1,1,0) * VRand() * LightningOriginRadius;

	if (VSize(vect(1,1,0) * (EndLocation - StartLocation)) > VSize(vect(1,1,0) * (EndLocation - Location)) || !FastTrace(EndLocation, StartLocation))
	{
		// second attempt
		StartLocation = Location + vect(1,1,0) * VRand() * LightningOriginRadius;
		if (VSize(vect(1,1,0) * (EndLocation - StartLocation)) > VSize(vect(1,1,0) * (EndLocation - Location)) || !FastTrace(EndLocation, StartLocation))
		{
			// try right above target
			StartLocation = EndLocation * vect(1,1,0) + vect(0,0,1) * Location.Z;

			if (VSize(StartLocation - Location) > LightningOriginRadius)
				StartLocation = Location + LightningOriginRadius * Normal(StartLocation - Location);

			if (!FastTrace(EndLocation, StartLocation))
				// fall back to center
				StartLocation = Location;
		}
	}

	if (bGroundHit)
	{
		// try tracing an end location on the actual ground
		Trace(EndLocation, HitNormal, StartLocation + GroundTraceRange * Normal(EndLocation - StartLocation), StartLocation, False);

		GLE = Spawn(class'LightningEmitterGround',,, EndLocation);
		GLE.SetLightningStart(StartLocation);

		Spawn(class'LightningScorch',,, EndLocation + vect(0,0,10), rotator(-HitNormal));
	}
	else
	{
		ALE = Spawn(class'LightningEmitterAir',,, EndLocation);
		ALE.SetLightningStart(StartLocation);
	}

	Hits = class'LightningTraceHelper'.static.TraceHits(Self, StartLocation, EndLocation, DamageRadius);
	for (i = 0; i < Hits.Length; i++)
	{
		Victim = Hits[i].HitActor;

		if (Victim.IsA('Pawn')) TeamN = Pawn(Victim).GetTeamNum();
		 else TeamN = 255; // no team
		
		if (bAvoidTargetingTeammates && TeamNum != 255 && TeamN == TeamNum) {
				continue; // don't target teammates directly
		}
			
		if ((Victim.bProjTarget || Victim.bBlockActors))
		{
			Victim.SetDelayedDamageInstigatorController(InstigatorController);

			if (Victim.TraceThisActor(HitLocation, HitNormal, EndLocation, StartLocation))
				Victim.TakeDamage(RandRange(MinDamage, MaxDamage), Instigator, Hits[i].HitLocation, vect(0,0,0), MyDamageType);
			else
				Victim.TakeDamage(0.5 * RandRange(MinDamage, MaxDamage), Instigator, Hits[i].HitLocation, vect(0,0,0), MyDamageType);

			// show damage overlay if vehicle doesn't do that on its own
			if (Victim != None && Vehicle(Victim) != None && !Vehicle(Victim).bShowDamageOverlay)
				Victim.SetOverlayMaterial(MyDamageType.default.DamageOverlayMaterial, MyDamageType.default.DamageOverlayTime, false);
		}
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     MinDamage=200.000000
     MaxDamage=400.000000
     DamageRadius=350.000000
     MyDamageType=Class'StormCasterV3.DamTypeStormCasterLightning'
     LightningOriginRadius=1500.000000
     CloudTargetRadius=4000.000000
     GroundTargetRadius=2750.000000
     GroundTraceRange=20000.000000
     bAvoidTargetingTeammates=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=20.000000
     CollisionRadius=4000.000000
     CollisionHeight=2000.000000
     bTraceWater=True
}
