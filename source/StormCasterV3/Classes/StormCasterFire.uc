/******************************************************************************
Storm Caster fire mode

Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class StormCasterFire extends PainterFire;


//=============================================================================
// Properties
//=============================================================================

var() float MinTraceHeight;
var() float MinOtherStormDistance;


/**
Check for valid ion cannon target location.
*/
state Paint
{
	function BeginState()
	{
		IonCannon = None;
		Super.BeginState();
	}

	function bool StormNearby(vector TestLocation)
	{
		local ThunderStorm Storm;
		local StormCasterBlast Blast;

		foreach Weapon.DynamicActors(class'ThunderStorm', Storm)
		{
			if (VSize((Storm.Location - TestLocation) * vect(1,1,0)) < MinOtherStormDistance)
				return true;
		}

		foreach Weapon.DynamicActors(class'StormCasterBlast', Blast)
		{
			if (VSize((Blast.Location - TestLocation) * vect(1,1,0)) < MinOtherStormDistance)
				return true;
		}

		return false;
	}

	function ModeTick(float DeltaTime)
	{
		local Vector StartTrace, EndTrace, X,Y,Z;
		local Vector HitLocation, HitNormal;
		local Actor Other;
		local Rotator Aim;
		local bool bEngageCannon;

		if (!bIsFiring)
			StopFiring();

		Weapon.GetViewAxes(X, Y, Z);

		// the to-hit trace always starts right in front of the eye
		StartTrace = Instigator.Location + Instigator.EyePosition() + X * Instigator.CollisionRadius;

		Aim = AdjustAim(StartTrace, AimError);
		X = Vector(Aim);
		EndTrace = StartTrace + TraceRange * X;

		Other = Weapon.Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

		if (Other != None && Other != Instigator)
		{
			if (bDoHit)
			{
				bValidMark = false;

				if (Other.bWorldGeometry && HitNormal dot vect(0,0,1) > 0.7 && Weapon.FastTrace(HitLocation + MinTraceHeight * vect(0,0,1), HitLocation) && !StormNearby(HitLocation))
				{
					if (VSize(HitLocation - MarkLocation) < 50.0)
					{
						Instigator.MakeNoise(3.0);
						if (Level.TimeSeconds - MarkTime > 0.3)
						{
							bEngageCannon = Level.TimeSeconds - MarkTime > PaintDuration;
							if (bEngageCannon)
							{
								Instigator.PendingWeapon = None;
								Painter(Weapon).ReallyConsumeAmmo(ThisModeNum, 1);
								Instigator.Controller.ClientSwitchToBestWeapon();

								Spawn(class'StormCasterBlast', Instigator,, MarkLocation + vect(0,0,10));

								if (Beam != None)
									Beam.SetTargetState(PTS_Aquired);

								StopForceFeedback(TAGMarkForce);
								ClientPlayForceFeedback(TAGAquiredForce);

								StopFiring();
							}
							else
							{
								bValidMark = true;

								if (!bMarkStarted)
								{
									bMarkStarted = true;
									ClientPlayForceFeedback(TAGMarkForce);
								}
							}
						}
					}
					else
					{
						bAlreadyMarked = true;
						MarkTime = Level.TimeSeconds;
						MarkLocation = HitLocation;
						bValidMark = false;
						bMarkStarted = false;
					}
				}
				else
				{
					MarkTime = Level.TimeSeconds;
					bValidMark = false;
					bMarkStarted = false;
				}
				bDoHit = false;
			}
			EndEffect = HitLocation;
		}
		else
		{
			EndEffect = EndTrace;
		}

		Painter(Weapon).EndEffect = EndEffect;

		if (Beam != None)
		{
			Beam.EndEffect = EndEffect;
			if (bValidMark)
				Beam.SetTargetState(PTS_Marked);
			else
				Beam.SetTargetState(PTS_Aiming);
		}
	}
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     MinTraceHeight=5000.000000
     MinOtherStormDistance=10000.000000
}
