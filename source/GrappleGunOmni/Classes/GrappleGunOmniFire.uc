class GrappleGunOmniFire extends LinkFire;

var() float distToStop;

//////////////// linkgun stuff
simulated function bool myHasAmmo( LinkGun LinkGun )
{
	return true;
}

simulated function ModeTick(float dt)
{
	local Vector StartTrace, EndTrace, V, X, Y, Z;
	local Vector HitLocation, HitNormal, EndEffect;
	local Actor Other;
	local Rotator Aim;
	local LinkGun LinkGun;
	local float Step, ls;
	local bot B;
	local bool bShouldStop, bIsHealingObjective;
	local int AdjustedDamage;
	local LinkBeamEffect LB;
	//local DestroyableObjective HealObjective;
	local Vehicle LinkedVehicle;

    if ( !bIsFiring )
    {
		bInitAimError = true;
        return;
    }

    LinkGun = LinkGun(Weapon);

    if ( LinkGun.Links < 0 )
    {
//        log("warning:"@Instigator@"linkgun had"@LinkGun.Links@"links");
        LinkGun.Links = 0;
    }

    ls = LinkScale[Min(LinkGun.Links,5)];

    if ( myHasAmmo(LinkGun) && ((UpTime > 0.0) || (Instigator.Role < ROLE_Authority)) )
    {
        UpTime -= dt;

		// the to-hit trace always starts right in front of the eye
		LinkGun.GetViewAxes(X, Y, Z);
		StartTrace = GetFireStart( X, Y, Z);
        TraceRange = default.TraceRange + LinkGun.Links*250;

        if ( Instigator.Role < ROLE_Authority )
        {
			if ( Beam == None )
				ForEach Weapon.DynamicActors(class'LinkBeamEffect', LB )
					if ( !LB.bDeleteMe && (LB.Instigator != None) && (LB.Instigator == Instigator) )
					{
						Beam = LB;
						break;
					}

			if ( Beam != None )
				LockedPawn = Beam.LinkedPawn;
		}

        if ( LockedPawn != None )
			TraceRange *= 1.5;

		if ( LockedPawn != None )
		{
			EndTrace = LockedPawn.Location + LockedPawn.BaseEyeHeight*Vect(0,0,0.5); // beam ends at approx gun height
			if ( Instigator.Role == ROLE_Authority )
			{
				V = Normal(EndTrace - StartTrace);
				if ( (V dot X < LinkFlexibility) || LockedPawn.Health <= 0 || LockedPawn.bDeleteMe || (VSize(EndTrace - StartTrace) > 1.5 * TraceRange) )
				{
					SetLinkTo( None );
				}
			}
		}

        if ( LockedPawn == None )
        {
            if ( Bot(Instigator.Controller) != None )
            {
				if ( bInitAimError )
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
				if ( DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw )
				{
					CurrentAimError.Yaw += Step;
					if ( !(DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw) )
					{
						CurrentAimError.Yaw = DesiredAimError.Yaw;
						DesiredAimError = AdjustAim(StartTrace, AimError);
					}
				}
				else
				{
					CurrentAimError.Yaw -= Step;
					if ( DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw )
					{
						CurrentAimError.Yaw = DesiredAimError.Yaw;
						DesiredAimError = AdjustAim(StartTrace, AimError);
					}
				}
				CurrentAimError.Yaw = CurrentAimError.Yaw - Instigator.Rotation.Yaw;
				if ( BoundError() )
					DesiredAimError = AdjustAim(StartTrace, AimError);
				CurrentAimError.Yaw = CurrentAimError.Yaw + Instigator.Rotation.Yaw;

				if ( Instigator.Controller.Target == None )
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

        Other = Weapon.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
        if ( Other != None && Other != Instigator )
			EndEffect = HitLocation;
		else
			EndEffect = EndTrace;

		if ( Beam != None )
			Beam.EndEffect = EndEffect;

		if ( Instigator.Role < ROLE_Authority )
		{
			if ( LinkGun.ThirdPersonActor != None )
			{
				if ( LinkGun.Linking || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) )
				{
					if (Instigator.PlayerReplicationInfo.Team == None || Instigator.PlayerReplicationInfo.Team.TeamIndex == 0)
						LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Red );
					else
						LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Blue );
				}
				else
				{
					if ( LinkGun.Links > 0 )
						LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Gold );
					else
						LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Green );
				}
			}
			return;
		}
        if ( Other != None && Other != Instigator )
        {
            // target can be linked to
            if ( IsLinkable(Other) )
            {
                if ( Other != lockedpawn )
                    SetLinkTo( Pawn(Other) );

                if ( lockedpawn != None )
                    LinkBreakTime = LinkBreakDelay;
            }
            else
            {
                // stop linking
                if ( lockedpawn != None )
                {
                    if ( LinkBreakTime <= 0.0 )
                        SetLinkTo( None );
                    else
                        LinkBreakTime -= dt;
                }
			}
		}

		// vehicle healing
		LinkedVehicle = Vehicle(LockedPawn);
		if ( LinkedVehicle != None && bDoHit )
		{
			AdjustedDamage = Damage * (1.5*Linkgun.Links+1) * Instigator.DamageScaling;
			if (Instigator.HasUDamage())
				AdjustedDamage *= 2;
			if (!LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType))
				LinkGun.ConsumeAmmo(ThisModeNum, -AmmoPerFire);
		}
		LinkGun(Weapon).Linking = (LockedPawn != None) || bIsHealingObjective;

		if ( bShouldStop )
			B.StopFiring();
		else
		{
			// beam effect is created and destroyed when firing starts and stops
			if ( (Beam == None) && bIsFiring )
			{
				Beam = Weapon.Spawn( BeamEffectClass, Instigator );
				// vary link volume to make sure it gets replicated (in case owning player changed it client side)
				if ( SentLinkVolume == Default.LinkVolume )
					SentLinkVolume = Default.LinkVolume + 1;
				else
					SentLinkVolume = Default.LinkVolume;
			}

			if ( Beam != None )
			{
				//set team color, and so it looks different than link beam (green/yellow)
				if (Instigator.PlayerReplicationInfo.Team.TeamIndex == 1) {
		 			Beam.mColorRange[0]=Class'Canvas'.static.MakeColor(40,10,240);
     			Beam.mColorRange[1]=Class'Canvas'.static.MakeColor(40,10,240);
        }
        else {
     			Beam.mColorRange[0]=Class'Canvas'.static.MakeColor(240,10,40);
     			Beam.mColorRange[1]=Class'Canvas'.static.MakeColor(240,10,40);
				}
				if ( LinkGun.Linking || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) )
				{
					Beam.LinkColor = Instigator.PlayerReplicationInfo.Team.TeamIndex + 1;
					if ( LinkGun.ThirdPersonActor != None )
					{
						if ( Instigator.PlayerReplicationInfo.Team == None || Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Red );
						else
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Blue );
					}
				}
				else
				{
					Beam.LinkColor = 0;
					if ( LinkGun.ThirdPersonActor != None )
					{
						if ( LinkGun.Links > 0 )
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Gold );
						else
							LinkAttachment(LinkGun.ThirdPersonActor).SetLinkColor( LC_Green );
					}
				}

				Beam.Links = LinkGun.Links;
				Instigator.AmbientSound = BeamSounds[Min(Beam.Links,3)];
				Instigator.SoundVolume = SentLinkVolume;
				Beam.LinkedPawn = LockedPawn;
				Beam.bHitSomething = (Other != None);
				Beam.EndEffect = EndEffect;
			}
		}
    }
    else
        StopFiring();

    bStartFire = false;
    bDoHit = false;
}


//////////////// grapplegun stuff
event ModeDoFire()
{
	super.ModeDoFire();
	if (LockedPawn != none)
	{
		doGrapplePull();
	}
}

simulated function doGrapplePull() 
{
    local Vector distance;
  
      if (Weapon.Owner.Physics == PHYS_Walking)
        	SetPlayerPhysics();

      	distance = LockedPawn.Location - Weapon.Owner.Location;
     	if (VSize(distance) <= distToStop)
     		gotoState('Swinging');
     	else {
     		gotoState('');
     		Weapon.Owner.Velocity = Normal(distance) * (VSize(Distance) - distToStop + (distToStop/3)) * 4;
     			//this math is important so that the player doesnt slow down too much
     	}
}

state Swinging
{

   simulated function BeginState()
   {
      Pawn(Weapon.Owner).bCanFly=True;
   }

   simulated function Tick(float DeltaTime)
   {
      local vector Direction;
      local vector PlayerV;
      local Vector deltavel;

        if (LockedPawn != None)	//this check gets us out of the state if needed
      	{
         SetPlayerPhysics();
         Direction = LockedPawn.Location - Owner.Location;
             Weapon.Owner.Velocity += DeltaVel;
             if ((Weapon.Owner.Velocity dot Direction) < 0)
             {
               PlayerV = (0.8*Direction*(Weapon.Owner.Velocity dot Direction)/(Direction dot Direction));
               Weapon.Owner.Velocity -= PlayerV;
             }
        }
        else
            GotoState('');
     }

     simulated function EndState()
     {
         Pawn(Weapon.Owner).bCanFly=False;
         SetPlayerPhysics();
     }
}

simulated function SetPlayerPhysics()
{
   if (weapon.Owner.PhysicsVolume.bWaterVolume)
      weapon.Owner.SetPhysics(PHYS_Swimming);
   else
      weapon.Owner.SetPhysics(PHYS_Falling);
}

defaultproperties
{
     distToStop=800.000000
     LinkScale(1)=0.000000
     LinkScale(2)=0.000000
     LinkScale(3)=0.000000
     LinkScale(4)=0.000000
     LinkScale(5)=0.000000
     DamageType=None
     Damage=0
     MomentumTransfer=0.000000
     TraceRange=3000.000000
     LinkFlexibility=0.5500000
     BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamEffectClass=Class'GrappleGunOmni.GrappleGunOmniBeamEffect'
     AmmoClass=Class'GrappleGunOmni.GrappleGunOmniAmmo'
     AmmoPerFire=0
}
