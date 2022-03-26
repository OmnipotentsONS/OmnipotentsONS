// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusLinkFire extends LinkFire;

var ONSPlusGameReplicationInfo OPGRI;

simulated function ModeTick(float dt)
{
	local Vector StartTrace, EndTrace, V, X, Y, Z;
	local Vector HitLocation, HitNormal, EndEffect;
	local Actor Other;
	local Rotator Aim;
	local ONSPlusLinkGun LinkGun;
	local float Step, ls;
	local bot B;
	local bool bShouldStop, bIsHealingObjective;
	local int AdjustedDamage, i, DamageAmount;
	local LinkBeamEffect LB;
	local DestroyableObjective HealObjective;
	local Vehicle LinkedVehicle;

	if (!bIsFiring)
	{
		bInitAimError = true;
		return;
	}

	if (Weapon != none)
		LinkGun = ONSPlusLinkGun(Weapon);

	if (LinkGun.Links < 0)
	{
		Log("warning:"@Instigator@"linkgun had"@LinkGun.Links@"links");
		LinkGun.Links = 0;
	}

	ls = LinkScale[Min(LinkGun.Links, 5)];

	// Clean out the lockingpawns list
	for (i=0; i<LinkGun.LockingPawns.Length; i++)
		if (LinkGun.LockingPawns[i] == none)
			LinkGun.LockingPawns.Remove(i, 1);

	if (myHasAmmo(LinkGun) && (UpTime > 0.0 || Instigator.Role < ROLE_Authority))
	{
		UpTime -= dt;

		// the to-hit trace always starts right in front of the eye
		LinkGun.GetViewAxes(X, Y, Z);
		StartTrace = GetFireStart(X, Y, Z);
		TraceRange = default.TraceRange + LinkGun.Links * 250;

		if (Instigator.Role < ROLE_Authority)
		{
			if (Beam == None && Weapon != none)
			{
				foreach Weapon.DynamicActors(class'LinkBeamEffect', LB)
				{
					if (!LB.bDeleteMe && LB.Instigator != None && LB.Instigator == Instigator)
					{
						Beam = LB;
						break;
					}
				}
			}

			if (Beam != None)
				LockedPawn = Beam.LinkedPawn;
		}

		if (LockedPawn != None)
			TraceRange *= 1.5;

		if (Instigator.Role == ROLE_Authority)
		{
			if (bDoHit)
				LinkGun.ConsumeAmmo(ThisModeNum, AmmoPerFire);

			B = Bot(Instigator.Controller);

			if (B != None && PlayerController(B.Squad.SquadLeader) != None && B.Squad.SquadLeader.Pawn != None)
			{
				if (IsLinkable(B.Squad.SquadLeader.Pawn) && B.Squad.SquadLeader.Pawn.Weapon != None && B.Squad.SquadLeader.Pawn.Weapon.GetFireMode(1).bIsFiring
					&& VSize(B.Squad.SquadLeader.Pawn.Location - StartTrace) < TraceRange)
				{
					if (Weapon != none)
						Other = Weapon.Trace(HitLocation, HitNormal, B.Squad.SquadLeader.Pawn.Location, StartTrace, true);

					if (Other == B.Squad.SquadLeader.Pawn)
					{
						B.Focus = B.Squad.SquadLeader.Pawn;

						if (B.Focus != LockedPawn)
							SetLinkTo(B.Squad.SquadLeader.Pawn);

						B.SetRotation(Rotator(B.Focus.Location - StartTrace));
 						X = Normal(B.Focus.Location - StartTrace);
 					}
 					else if (B.Focus == B.Squad.SquadLeader.Pawn)
						bShouldStop = true;
				}
 				else if (B.Focus == B.Squad.SquadLeader.Pawn)
					bShouldStop = true;
			}
		}

		if (LockedPawn != None)
		{
			EndTrace = LockedPawn.Location + LockedPawn.BaseEyeHeight * Vect(0,0,0.5); // beam ends at approx gun height

			if (Instigator.Role == ROLE_Authority)
			{
				V = Normal(EndTrace - StartTrace);

				if (V dot X < LinkFlexibility || LockedPawn.Health <= 0 || LockedPawn.bDeleteMe || VSize(EndTrace - StartTrace) > 1.5 * TraceRange)
					SetLinkTo(None);
			}
		}

		if (LockedPawn == None)
		{
			if (Bot(Instigator.Controller) != None)
			{
				if (bInitAimError)
				{
					CurrentAimError = AdjustAim(StartTrace, AimError);
					bInitAimError = false;
				}
				else
				{
					BoundError();
					CurrentAimError.Yaw = CurrentAimError.Yaw + Instigator.Rotation.Yaw;
				}

				// smooth aim error changes
				Step = 7500.0 * dt;

				if (DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw)
				{
					CurrentAimError.Yaw += Step;

					if (!(DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw))
					{
						CurrentAimError.Yaw = DesiredAimError.Yaw;
						DesiredAimError = AdjustAim(StartTrace, AimError);
					}
				}
				else
				{
					CurrentAimError.Yaw -= Step;

					if (DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw)
					{
						CurrentAimError.Yaw = DesiredAimError.Yaw;
						DesiredAimError = AdjustAim(StartTrace, AimError);
					}
				}

				CurrentAimError.Yaw = CurrentAimError.Yaw - Instigator.Rotation.Yaw;

				if (BoundError())
					DesiredAimError = AdjustAim(StartTrace, AimError);

				CurrentAimError.Yaw = CurrentAimError.Yaw + Instigator.Rotation.Yaw;

				if (Instigator.Controller.Target == None)
					Aim = Rotator(Instigator.Controller.FocalPoint - StartTrace);
				else
					Aim = Rotator(Instigator.Controller.Target.Location - StartTrace);

				Aim.Yaw = CurrentAimError.Yaw;

				// save difference
				CurrentAimError.Yaw = CurrentAimError.Yaw - Instigator.Rotation.Yaw;
			}
			else
				Aim = GetPlayerAim(StartTrace, AimError);

			X = Vector(Aim);
			EndTrace = StartTrace + TraceRange * X;
		}

		if (Weapon != none)
			Other = Weapon.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (Other != None && Other != Instigator)
			EndEffect = HitLocation;
		else
			EndEffect = EndTrace;

		if (Beam != None)
			Beam.EndEffect = EndEffect;

		if (Instigator.Role < ROLE_Authority)
		{
			if (LinkGun.ThirdPersonActor != None)
			{
				if (LinkGun.Linking || (Other != None && Instigator.PlayerReplicationInfo.Team != None && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)))
				{
					if (Instigator.PlayerReplicationInfo.Team == None || Instigator.PlayerReplicationInfo.Team.TeamIndex == 0)
						LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Red);
					else
						LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Blue);
				}
				else
				{
					if (LinkGun.Links > 0)
						LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Gold);
					else
						LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Green);
				}
			}

			return;
		}

		if (Other != None && Other != Instigator)
		{
			// target can be linked to
			if (IsLinkable(Other))
			{
				if (Other != lockedpawn)
					SetLinkTo(Pawn(Other));

				if (lockedpawn != None)
					LinkBreakTime = LinkBreakDelay;
			}
			else
			{
				// stop linking
				if (lockedpawn != None)
				{
					if (LinkBreakTime <= 0.0)
						SetLinkTo(None);
					else
						LinkBreakTime -= dt;
				}

				// beam is updated every frame, but damage is only done based on the firing rate
				if (bDoHit)
				{
					if (Beam != None)
						Beam.bLockedOn = false;

					Instigator.MakeNoise(1.0);

					AdjustedDamage = AdjustLinkDamage(LinkGun, Other, Damage);

					if (!Other.bWorldGeometry)
					{
						if (Level.Game.bTeamGame && Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None
							&& Pawn(Other).PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team) // even if friendly fire is on you can't hurt teammates
							AdjustedDamage = 0;

						HealObjective = DestroyableObjective(Other);

						if (HealObjective == None)
							HealObjective = DestroyableObjective(Other.Owner);


						if (OPGRI == none && Weapon != none && Pawn(Weapon.Owner).Controller != None &&
							PlayerController(Pawn(Weapon.Owner).Controller) != None &&
							PlayerController(Pawn(Weapon.Owner).Controller).GameReplicationInfo != None)
							OPGRI = ONSPlusGameReplicationInfo(PlayerController(Pawn(Weapon.Owner).Controller).GameReplicationInfo);


						if (HealObjective != None && HealObjective.TeamLink(Instigator.GetTeamNum()))
						{
							SetLinkTo(None);
							bIsHealingObjective = true;

							if (OPGRI != none && OPGRI.bNodeHealScoreFix)
							{
								if (!HealObjective.HealDamage(AdjustedDamage / (LinkGun.LockingPawns.Length + 1), Instigator.Controller, DamageType))
									LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
								else
									for (i=0; i<LinkGun.LockingPawns.Length; i++)
										HealObjective.HealDamage(AdjustedDamage / (LinkGun.LockingPawns.Length + 1),
														LinkGun.LockingPawns[i].Controller, DamageType);
							}
							else
							{
								if (!HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
									LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
							}
						}
						else if (HealObjective != None && OPGRI != none && OPGRI.bNodeHealScoreFix)
						{
							DamageAmount = AdjustedDamage;

							if (DamageType != None)
								DamageAmount *= DamageType.default.VehicleDamageScaling;

							if (Instigator != None)
							{
								if (Instigator.HasUDamage())
									DamageAmount *= 2;

								DamageAmount *= Instigator.DamageScaling;
							}

							DamageAmount = FMin(HealObjective.Health, DamageAmount) / HealObjective.DamageCapacity;

							for (i=0; i<LinkGun.LockingPawns.Length; i++)
								HealObjective.AddScorer(LinkGun.LockingPawns[i].Controller, DamageAmount / (LinkGun.LockingPawns.Length + 1));

							// Remove players added score but give him credit for destruction of node :)
							if (Weapon != none)
								HealObjective.AddScorer(Pawn(Weapon.Owner).Controller, -(DamageAmount - (DamageAmount / (LinkGun.LockingPawns.Length + 1))));

							Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, MomentumTransfer * X, DamageType);
						}
						else
						{
                            Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, MomentumTransfer * X, DamageType);
						}

						if (Beam != None)
							Beam.bLockedOn = true;
					}
				}
			}
		}

		// vehicle healing
		LinkedVehicle = Vehicle(LockedPawn);

		if (LinkedVehicle != None && bDoHit)
		{
			AdjustedDamage = Damage * (1.5 * Linkgun.Links + 1) * Instigator.DamageScaling;

			if (Instigator.HasUDamage())
				AdjustedDamage *= 2;

			if (!LinkedVehicle.HealDamage(AdjustedDamage / (LinkGun.LockingPawns.Length + 1), Instigator.Controller, DamageType))
				LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
			else
				for (i=0; i<LinkGun.LockingPawns.Length; i++)
					LinkedVehicle.HealDamage(AdjustedDamage / (LinkGun.LockingPawns.Length + 1), LinkGun.LockingPawns[i].Controller, DamageType);
		}

		if (Weapon != none)
			LinkGun(Weapon).Linking = LockedPawn != None || bIsHealingObjective;

		if (bShouldStop)
		{
			B.StopFiring();
		}
		else
		{
			// beam effect is created and destroyed when firing starts and stops
			if (Beam == None && bIsFiring)
			{
				if (Weapon != none)
					Beam = Weapon.Spawn(BeamEffectClass, Instigator);

				// vary link volume to make sure it gets replicated (in case owning player changed it client side)
				if (SentLinkVolume == Default.LinkVolume)
					SentLinkVolume = Default.LinkVolume + 1;
				else
					SentLinkVolume = Default.LinkVolume;
			}

			if (Beam != None)
			{
				if (LinkGun.Linking || (Other != None && Instigator.PlayerReplicationInfo.Team != None && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)))
				{
					Beam.LinkColor = Instigator.PlayerReplicationInfo.Team.TeamIndex + 1;

					if (LinkGun.ThirdPersonActor != None)
					{
						if (Instigator.PlayerReplicationInfo.Team == None || Instigator.PlayerReplicationInfo.Team.TeamIndex == 0)
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Red);
						else
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Blue);
					}
				}
				else
				{
					Beam.LinkColor = 0;

					if (LinkGun.ThirdPersonActor != None)
					{
						if (LinkGun.Links > 0)
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Gold);
						else
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor(LC_Green);
					}
				}

				Beam.Links = LinkGun.Links;
				Instigator.AmbientSound = BeamSounds[Min(Beam.Links, 3)];
				Instigator.SoundVolume = SentLinkVolume;
				Beam.LinkedPawn = LockedPawn;
				Beam.bHitSomething = Other != None;
				Beam.EndEffect = EndEffect;
			}
		}
	}
	else
	{
		StopFiring();
	}

	bStartFire = false;
	bDoHit = false;
}

function bool AddLink(int Size, Pawn Starter)
{
	local Inventory Inv;

	if (LockedPawn != None && !bFeedbackDeath)
	{
		if (LockedPawn == Starter)
		{
			return false;
		}
		else
		{
			Inv = LockedPawn.FindInventoryType(class'ONSPlusLinkGun');

			if (Inv != None)
			{
				if (LinkFire(LinkGun(Inv).GetFireMode(1)).AddLink(Size, Starter))
				{
					LinkGun(Inv).Links += Size;

					if (Weapon != None && Weapon.Owner != None && Pawn(Weapon.Owner) != None)
					{
						ONSPlusLinkGun(Weapon).LockingPawns[ONSPlusLinkGun(Weapon).LockingPawns.Length] = Pawn(Weapon.Owner);

						ONSPlusLinkGun(Inv).LockingPawns = ONSPlusLinkGun(Weapon).LockingPawns;

						ONSPlusLinkGun(Weapon).LockingPawns.Length = 0;
					}
				}
				else
				{
					return false;
				}
			}
		}
	}

	return true;
}

function SetLinkTo(Pawn Other)
{
	if (LockedPawn != None && Weapon != None)
	{
		RemoveLinkPlus(1 + LinkGun(Weapon).Links, Instigator, Pawn(Weapon.Owner));
		LinkGun(Weapon).Linking = false;
	}

	LockedPawn = Other;

	if (Weapon != none && LockedPawn != None)
	{
		if (!AddLink(1 + LinkGun(Weapon).Links, Instigator))
			bFeedbackDeath = true;

		LinkGun(Weapon).Linking = true;

		LockedPawn.PlaySound(MakeLinkSound, SLOT_None);
	}
}

function RemoveLinkPlus(int Size, Pawn Starter, Pawn LostLinker)
{
	local Inventory Inv;
	local int i;

	if (Weapon != none && Weapon.Owner != LostLinker)
	{
		for (i=0; i<ONSPlusLinkGun(Weapon).LockingPawns.Length; i++)
		{
			if (ONSPlusLinkGun(Weapon).LockingPawns[i] == LostLinker)
			{
				ONSPlusLinkGun(Weapon).LockingPawns.Remove(i, 1);
				i--;
			}
		}
	}

	if (LockedPawn != None && !bFeedbackDeath)
	{
		if (LockedPawn != Starter)
		{
			Inv = LockedPawn.FindInventoryType(class'ONSPlusLinkGun');

			if (Inv != None)
			{
				ONSPlusLinkFire(ONSPlusLinkGun(Inv).GetFireMode(1)).RemoveLinkPlus(Size, Starter, LostLinker);
				LinkGun(Inv).Links -= Size;
			}
		}
	}
}