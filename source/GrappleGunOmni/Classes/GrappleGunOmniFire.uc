class GrappleGunOmniFire extends WeaponFire;

var() float distToStop;
var GrappleGunOmniBeamEffect          Beam;
var class<GrappleGunOmniBeamEffect>   BeamEffectClass;

var Sound   MakeLinkSound;
var float   UpTime;
var Pawn    LockedPawn;
var float   LinkBreakTime;
var() float LinkBreakDelay;
var float   LinkScale[6];

var String MakeLinkForce;

var() class<DamageType> DamageType;
var() int Damage;
var() float MomentumTransfer;

var() float TraceRange;
var() float LinkFlexibility;

var     bool bDoHit;
var()   bool bFeedbackDeath;
var     bool bInitAimError;
var     bool bLinkFeedbackPlaying;
var     bool bStartFire;
var byte    LinkVolume;
var byte    SentLinkVolume;
var() sound LinkedFireSound;

var rotator DesiredAimError, CurrentAimError;

var Sound BeamSounds[4];


simulated function DestroyEffects()
{
    super.DestroyEffects();

    if ( Level.NetMode != NM_Client )
    {
        if ( Beam != None )
            Beam.Destroy();
    }
}
//////////////// linkgun stuff
simulated function bool myHasAmmo( GrappleGunOmni GrappleGunOmni )
{
	return true;
}

simulated function Rotator  GetPlayerAim( vector StartTrace, float InAimError )
{
    return AdjustAim(StartTrace, InAimError);
}

simulated function ModeTick(float dt)
{
	local Vector StartTrace, EndTrace, V, X, Y, Z;
	local Vector HitLocation, HitNormal, EndEffect;
	local Actor Other;
	local Rotator Aim;
	local GrappleGunOmni GGunOmni;
	local float Step; //, ls;
	local bot B;
	local bool bShouldStop; //, bIsHealingObjective;
	local GrappleGunOmniBeamEffect LB;
	local DestroyableObjective HealObjective;


    if ( !bIsFiring )
    {
				bInitAimError = true;
        return;
    }

    GGunOmni = GrappleGunOmni(Weapon);

 ///   if ( LinkGun.Links < 0 )
 //   {
//        log("warning:"@Instigator@"linkgun had"@LinkGun.Links@"links");
//        LinkGun.Links = 0;
//    }

//    ls = LinkScale[Min(LinkGun.Links,5)];

    if ( myHasAmmo(GGunOmni) && ((UpTime > 0.0) || (Instigator.Role < ROLE_Authority)) )
    {
        UpTime -= dt;

		// the to-hit trace always starts right in front of the eye
		GGunOmni.GetViewAxes(X, Y, Z);
		StartTrace = GetFireStart( X, Y, Z);
        TraceRange = default.TraceRange + GGunOmni.Links*250;

        if ( Instigator.Role < ROLE_Authority )
        {
			if ( Beam == None )
				ForEach Weapon.DynamicActors(class'GrappleGunOmniBeamEffect', LB )
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
			return;
		}


      if ( Other != None && Other != Instigator )
      {
          // target can be linked to
          if ( IsLinkable(Other) )
          {
              if ( Other != lockedpawn )
                {
                //	log("SetLinkTo "@Other,'GrappleGunOmni');
                  SetLinkTo( Pawn(Other) );
                }  

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
              
                          // beam is updated every frame, but damage is only done based on the firing rate
                if ( bDoHit )
                {
                    if ( Beam != None )
                        Beam.bLockedOn = false;
                   
                    
                    if ( !Other.bWorldGeometry )
                    {
                    	  //log("In ModeTick, bDoHit=True, Other="@Other,'GrappleGunOmni');
                        HealObjective = DestroyableObjective(Other);
												if ( HealObjective == None ) // could be shield or sphere.
													HealObjective = DestroyableObjective(Other.Owner);
                        //log("In ModeTick, bDoHit=True, HealObjective="@HealObjective,'GrappleGunOmni');
                        if ( HealObjective != None && HealObjective.TeamLink(Instigator.GetTeamNum()) )
                        {
                            Instigator.MakeNoise(1.0);
                            //Message that this isn't LINK>
                            if ( PlayerController(Instigator.Controller) != None )
        											 PlayerController(Instigator.Controller).ReceiveLocalizedMessage(class'GrappleGunOmniNotLinkMessage',0);
                        }
                    }
                } // do hit.
		}
	}


 
    GGunOmni.Linking = (LockedPawn != None);
		
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
				
				
				if (GGunOmni != None && GGunOmni.Linking && Other != None && IsLinkable(other))// || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) )
				// this controls the changes on the LinkBeam when it attaches.   
				// Changed so it only attaches to the things IsLinkable, in this case only vehicles.
				{
					Beam.LinkColor = Instigator.PlayerReplicationInfo.Team.TeamIndex + 1;
					if ( GGunOmni.ThirdPersonActor != None )
					{
						if ( Instigator.PlayerReplicationInfo.Team == None || Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
							GrappleGunOmniAttachment(GGunOmni.ThirdPersonActor).SetLinkColor( LC_Red );
						else
							GrappleGunOmniAttachment(GGunOmni.ThirdPersonActor).SetLinkColor( LC_Blue );
					}
				}
				else
				{
					Beam.LinkColor = 0;
				
				}

				Beam.Links = 0;
				Instigator.AmbientSound = BeamSounds[1];
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

simulated function UpdateLinkColor( LinkAttachment.ELinkColor Color )
{
	if ( FlashEmitter == None ) return;
	
  FlashEmitter.Skins[0] = Texture'GrappleGunOmni_Tex.Weapon.link_muz_purple';  
}

function bool BoundError()
{
    CurrentAimError.Yaw = CurrentAimError.Yaw & 65535;
    if ( CurrentAimError.Yaw > 2048 )
    {
        if ( CurrentAimError.Yaw < 32768 )
        {
            CurrentAimError.Yaw = 2048;
            return true;
        }
        else if ( CurrentAimError.Yaw < 63487 )
        {
            CurrentAimError.Yaw = 63487;
            return true;
        }
    }
    return false;
}    

function DoFireEffect()
{
    bDoHit = true;
    UpTime = FireRate+0.1;
}


function PlayFiring()
{
//    if (LinkGun(Weapon).Links <= 0 && Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire)
    ClientPlayForceFeedback("BLinkGunBeam1");
    Super.PlayFiring();
}


function StopFiring()
{
    Instigator.AmbientSound = None;
    Instigator.SoundVolume = Instigator.Default.SoundVolume;
    if (Beam != None)
    {
        Beam.Destroy();
        Beam = None;
    }
    SetLinkTo(None);
    bStartFire = true;
    bFeedbackDeath = false;
    //if (LinkGun(Weapon).Links <= 0)
        StopForceFeedback("BLinkGunBeam1");
}

function SetLinkTo(Pawn Other)
{

    
    
    if (LockedPawn != None && Weapon != None)
    {
        GrappleGunOmni(Weapon).Linking = false;
    }
    
    LockedPawn = Other;
    
    if (LockedPawn != None)
    {
        //if (!AddLink(1 + LinkGun(Weapon).Links, Instigator))
        //{
        //    bFeedbackDeath = true;
        //}
        GrappleGunOmni(Weapon).Linking = true;
        LockedPawn.PlaySound(MakeLinkSound, SLOT_None);
        //log("SetLinkTo::LockedPawn="@LockedPawn,'GrappleGunOmni');
    }
}


function bool IsLinkable(Actor Other)
// from TrickBoard
{
	  //log("Actor="@Other,'GrappleGunOmni');
	  //log("IsONSPOwercore="@Other.IsA('ONSPowerCore'),'GrappleGunOmni');
	  //log("IsVehicle="@Other.IsA('KVehicle') || Other.IsA('SVehicle'),'GrappleGunOmni');
    //return Other.IsA('Pawn') && !Other.IsA('ONSPowerCore') && Other.bProjTarget;
    // Only attach to moveable vehicles.
    return Other.IsA('KVehicle') || Other.IsA('SVehicle');
}


simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Instigator.Location + Instigator.EyePosition() + X*Instigator.CollisionRadius;
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
     LinkBreakDelay=0.30000
     DamageType=None
     Damage=0
     FireRate=0.12
     MomentumTransfer=0.000000
     bInitAimError=True
     TraceRange=3000.000000
     LinkFlexibility=0.5500000
     LinkedFireSound=Sound'WeaponSounds.TAGRifle.TAGFireB'
     LinkVolume=200
     MakeLinkForce="LinkActivated"
     BeamSounds(1)=Sound'WeaponSounds.TAGRifle.TAGFireA'
     BeamSounds(2)=Sound'WeaponSounds.TAGRifle.TAGFireA'
     BeamSounds(3)=Sound'WeaponSounds.TAGRifle.TAGFireA'
     BeamEffectClass=Class'GrappleGunOmni.GrappleGunOmniBeamEffect'
     AmmoClass=Class'GrappleGunOmni.GrappleGunOmniAmmo'
     AmmoPerFire=0
     bPawnRapidFireAnim=True
     FlashEmitterClass=Class'GrappleGunOmni.GrappleGunOmniMuzFlash'
}
