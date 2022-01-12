
class CSNephthysGravityVortex extends NephthysGravityVortex;

function bool ShouldSuckActor(Actor Other)
{
    if(Instigator != None && Instigator.Controller != None)
    {
        if(Pawn(Other) != None)
            return Instigator.Controller.GetTeamNum() != Pawn(Other).GetTeamNum();

        if(Vehicle(Other) != None)
            return Instigator.Controller.GetTeamNum() != Pawn(Other).GetTeamNum();
    }

    return true;
}


simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (SuckingStartTime > 0 && ShouldSuckActor(Other))
	{
		if (Vehicle(Other) != None && Vehicle(Other).bSpawnProtected)
			Vehicle(Other).bSpawnProtected = False; // if it can get sucked in, it should die

		Spawn(class'ONSShockTankShockExplosion');
		PlaySound(ImpactSound, SLOT_Interact);
		HurtRadius(TouchDamage * (0.15 * VortexLevel + 0.55), 0.5 * DamageRadius, TouchDamageType, MomentumTransfer * (0.15 * VortexLevel + 0.55), Location);
		AttractionInverseTime = Level.TimeSeconds;
	}
}

simulated function Attract(float DeltaTime, float RadiusScale, float StrengthScale)
{
	const WantedPhysicsModes = 0xEA5E; // each bit stands for a physics mode to be considered
	local Actor A;
	local Pawn P;
	local float actualAttractRadius, actualAttractStrength, dist;
	local vector dir, attraction;

	actualAttractRadius = AttractionRadius * RadiusScale;
	actualAttractStrength = AttractionStrength * StrengthScale;

	foreach DynamicActors(class'Actor', A)
	{
		if (A.Role != ROLE_Authority && !A.bNetTemporary || A.Location == Location || (1 << A.Physics & WantedPhysicsModes) == 0)
			continue;

		dir = Location - A.Location;
		dist = VSize(dir);
		dir /= dist;

		if (dist > actualAttractRadius)
			continue;

		attraction = dir * (actualAttractStrength * Square(1 - dist / actualAttractRadius));

		P = Pawn(A);

        if(Instigator != None && Instigator.Controller != None && P != None && Instigator.Controller.GetTeamNum() == P.GetTeamNum())
            continue;

		if (P != None)
		{
			if (P.Physics == PHYS_Ladder && P.OnLadder != None)
			{
				if (vector(P.OnLadder.WallDir) dot attraction < -100)
					P.SetPhysics(PHYS_Falling);
			}
			else if (P.Physics == PHYS_Walking)
			{
				if (P.PhysicsVolume.Gravity dot attraction < -100)
					P.SetPhysics(PHYS_Falling);
			}
			else if (P.Physics == PHYS_Spider)
			{
				// probably not a good idea as I have no idea what people use spider physics for
				if (P.Floor dot attraction > 1000)
					P.SetPhysics(PHYS_Falling);
			}
			if (P == None)
				continue;
		}

		// check this, in case physics change
		if (A.Physics == PHYS_Karma || A.Physics == PHYS_KarmaRagdoll)
		{
			A.KAddImpulse(DeltaTime * 10 * Sqrt(A.KGetMass()) * attraction, vect(0,0,0));
		}
		else if (Pawn(A) != None)
		{
			A.Velocity += DeltaTime * attraction / Sqrt(A.Mass);
		}
		else if (NephthysPointSingularity(A) != None && dist < 3 * (CollisionRadius + A.CollisionRadius))
		{
			A.Velocity -= DeltaTime * attraction / Sqrt(A.Mass);
		}
		else
		{
			A.Velocity += DeltaTime * attraction / Sqrt(A.Mass);
		}
	}
}


function DischargeLightningAt(Actor Target, float DamageAmount)
{
	local xEmitter DischargeEffect;
	local vector HL, HN;

	if (Target != None)
	{
		if (!Target.TraceThisActor(HL, HN, Target.Location, Location))
		{
			HL = Target.Location;
		}

		DischargeEffect = Spawn(class'NephthysSingularityDischarge',,, Location, rotator(HL - Location));
		if (DischargeEffect != None)
			DischargeEffect.mSpawnVecA = HL;

		if (Instigator == None || Instigator.Controller == None)
			Target.SetDelayedDamageInstigatorController(InstigatorController);

        if(Instigator != None && Instigator.Controller != None && Pawn(Target) != None 
        && Instigator.Controller.GetTeamNum() == Pawn(Target).GetTeamNum())
            DamageAmount = 0;

		Target.TakeDamage(DamageAmount, Instigator, HL, vect(0,0,0), LightningDamageType);
	}
}


defaultproperties
{
}