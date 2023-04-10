class LampreyGun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var bool bIsFiring;
var LampreyManta MyLamprey;
var()	float	InheritVelocityScale; // Amount of vehicles velocity

var LampreyBeamEffect			Beam1, Beam2;
var class<LampreyBeamEffect>	BeamEffectClass;

var Sound	MakeLinkSound;
var float	UpTime;
var Pawn	LockedPawn;
var float	LinkBreakTime;
var() float LinkBreakDelay;

var String MakeLinkForce;

var() int Damage;


var() float LinkFlexibility;
var float SelfHealMultiplier; 
var float VehicleDamageMultiplier;

var		bool bDoHit;
var()	bool bFeedbackDeath;
var		bool bInitAimError;
var		bool bLinkFeedbackPlaying;
var		bool bStartFire;
var byte	LinkVolume;
var byte	SentLinkVolume;

var rotator DesiredAimError, CurrentAimError;

var Sound BeamSounds[4];


var float MinAim;


replication
{
    reliable if (Role == ROLE_Authority)
		bIsFiring;
}


simulated function ClientStopFire(Controller C, bool bWasAltFire)
{

	Super.ClientStopfire(C,bWasAltFire);
	if(!bWasAltFire)
	{
		bIsFiring=False;
	}

}

simulated function ClientStartFire(Controller C, bool bWasAltFire)
{

	Super.ClientStartfire(C,bWasAltFire);
	if(!bWasAltFire)
	{
		bIsFiring=true;
	}

}

function byte BestMode()
{
	return 0;
}

simulated function float MaxRange()
{
	AimTraceRange = 6000;

	return AimTraceRange;
}

simulated function DestroyEffects()
{
	super.DestroyEffects();

    if ( Level.NetMode != NM_Client )
    {
        if ( Beam1 != None ) Beam1.Destroy();
        if ( Beam2 != None ) Beam2.Destroy();
    }
}

function float AdjustLinkDamage(  Actor Other, float Damage )
{
	local float AdjDamage;
		
	if ( Other.IsA('Vehicle') ) AdjDamage *= VehicleDamageMultiplier;
	if ( Other.IsA('Minotaur') ||Other.IsA('Omnitaur')  ) AdjDamage *= 2.5;
  if (Instigator.HasUDamage()) 	AdjDamage *= 2;
	
	return AdjDamage;
}
//============================ STATE INSTANT FIRE
state InstantFireMode
{

simulated function ClientSpawnHitEffects()
	{     }

function SpawnHitEffects(Actor HitActor, vector HitLocation, vector HitNormal)
    {    }
	
	
	
simulated function tick(float dt)
{
		local Vector StartTrace, EndTrace, V, X; 
		local Vector HitLocation, HitNormal, EndEffect;
		local Actor Other;
		local Rotator Aim;
		//local float ls;
		local bot B;
		local bool bShouldStop, bIsHealingObjective;
		local int AdjustedDamage;
		local LampreyBeamEffect LB;
		local DestroyableObjective HealObjective;
		local Vehicle LinkedVehicle;
	
		Super.Tick(dt);
		
		
		MyLamprey = LampreyManta(Owner);
		If (MyLamprey == None) return; // no driver nothing to do.
		
				
		if ( !bIsFiring ) {
			  bInitAimError = true;
	      return;
	  }
		
		if ( (UpTime > 0.0) || (Instigator.Role < ROLE_Authority) ) 	{
				UpTime -= dt;
				StartTrace=WeaponFireLocation;
							
		    if ( Instigator.Role < ROLE_Authority )   {
					 if ( Beam1 == None )
						  ForEach DynamicActors(class'LampreyBeamEffect', LB )
							    if ( !LB.bDeleteMe && (LB.Instigator != None) && (LB.Instigator == Instigator) ) {
								      Beam1 = LB;
								      break;
							    }
				if ( Beam1 != None ) LockedPawn = Beam1.LinkedPawn;
				} // RoleAuth

		    if ( LockedPawn != None ) TraceRange *= 1.5;

	   		if ( LockedPawn != None ) {
						EndTrace = LockedPawn.Location + LockedPawn.BaseEyeHeight*Vect(0,0,0.5); // beam ends at approx gun height
						if ( Instigator.Role == ROLE_Authority ) {
							 V = Normal(EndTrace - StartTrace);
							 if (  (V dot Vector(WeaponFireRotation) < LinkFlexibility) || LockedPawn.Health <= 0 || LockedPawn.bDeleteMe || (VSize(EndTrace - StartTrace) > 1.5 * TraceRange) ) 	{
								SetLinkTo( None );
							 }
						}
			  }

	      if ( LockedPawn == None ) {
           Aim = WeaponFireRotation;//GetPlayerAim(StartTrace, AimError); ANOTHER FUNCTION FOR WEAPONS WE DON'T HAVE.'
	         X = Vector(Aim);
	          EndTrace = StartTrace + TraceRange * X;
	      } // Locked Pawn None

	      Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	      if ( Other != None && Other != Instigator ) EndEffect = HitLocation;
			  else 	EndEffect = EndTrace;

			if ( Beam1 != None ) 	Beam1.EndEffect = EndEffect;
			if ( Beam2 != None ) 	Beam2.EndEffect = EndEffect;
			
			if ( Instigator.Role < ROLE_Authority ) return;
			
			
	    if ( Other != None && Other != Instigator )   {
	       // target can be linked to
	       if ( IsLinkable(Other) )    {
	          if ( Other != lockedpawn )  SetLinkTo( Pawn(Other) );
	          if ( LockedPawn != None )   LinkBreakTime = LinkBreakDelay;
	       }
	       else {   // stop linking
	          if ( lockedpawn != None )  {
	            if ( LinkBreakTime <= 0.0 ) SetLinkTo( None );
	            else   LinkBreakTime -= dt;
	          }

	       // beam is updated every frame, but damage is only done based on the firing rate
		       if ( bDoHit ) {
		          if ( Beam1 != None ) 	Beam1.bLockedOn = false;
		          Instigator.MakeNoise(1.0);
		          AdjustedDamage = AdjustLinkDamage(Other, Damage );
	            if ( !Other.bWorldGeometry )  {
	               if ( Level.Game.bTeamGame && Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None && Pawn(Other).PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team) // so even if friendly fire is on you can't' hurt teammates
	                  AdjustedDamage = 0;

							  	HealObjective = DestroyableObjective(Other);
									if ( HealObjective == None )  HealObjective = DestroyableObjective(Other.Owner);
									if ( HealObjective != None && HealObjective.TeamLink(Instigator.GetTeamNum()) ) 	{
										//	SetLinkTo(None);
											bIsHealingObjective = true;
											HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType);
				
									}
									else {
											Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, Momentum*X, DamageType);
											// heal itself
				 							if (MyLamprey!=None&&MyLamprey.Health<MyLamprey.HealthMax&&(ONSPowerCore(HealObjective)==None||ONSPowerCore(HealObjective).PoweredBy(Team)&&!LockedPawn.IsInState('NeutralCore')))
			       								MyLamprey.HealDamage(Round(AdjustedDamage * SelfHealMultiplier), Instigator.Controller, DamageType);
									}

									if ( Beam1 != None )		Beam1.bLockedOn = true;
									if ( Beam2 != None )		Beam2.bLockedOn = true;
							}  // world geo
					 } // do hit
		  	} // stop linking
	  } // other none

		// vehicle healing
		LinkedVehicle = Vehicle(LockedPawn);
		if ( LinkedVehicle != None && bDoHit ) 	{
				AdjustedDamage = AdjustLinkDamage(Other, Damage );
				LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType);
		}
		MyLamprey.Linking = (LockedPawn != None) || bIsHealingObjective;

		if ( bShouldStop ) 	B.StopFiring();
		else 		{
				// beam effect is created and destroyed when firing starts and stops
				if ( (Beam1 == None) && bIsFiring ) 	{
					 Beam1 = Spawn( BeamEffectClass, Instigator );
					 Beam2 = Spawn( BeamEffectClass, Instigator );
					 // vary link volume to make sure it gets replicated (in case owning player changed it client side)
					 if ( SentLinkVolume == Default.LinkVolume )
						  SentLinkVolume = Default.LinkVolume + 1;
					else
						  SentLinkVolume = Default.LinkVolume;
				}

				if ( Beam1 != None )
				{
					 if ( MyLamprey.Linking || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) ) 	 {
			  			Beam1.LinkColor = Instigator.PlayerReplicationInfo.Team.TeamIndex + 1;
				  		Beam2.LinkColor = Instigator.PlayerReplicationInfo.Team.TeamIndex + 1;
					}
					else {
						Beam1.LinkColor = 0;
						Beam2.LinkColor = 0;
					}

					if(Vehicle(Instigator) != None)
					{
						//Vehicle(Instigator).Driver.AmbientSound = BeamSounds[Min(Beam.Links,3)];//changes
						Vehicle(Instigator).Driver.SoundVolume = SentLinkVolume;//changes
					}
					Beam1.LinkedPawn = LockedPawn;
					Beam1.bHitSomething = (Other != None);
					Beam1.EndEffect = EndEffect;
					Beam1.LampGun=Self;
					
					If (Beam2 != None ) {
						 Beam2.LinkedPawn = LockedPawn;
					   Beam2.bHitSomething = (Other != None);
					   Beam2.EndEffect = EndEffect;
					   Beam2.LampGun=Self;
					} // beam 2
					
				} // No beam
			} // else stop
   }
   else   WeaponCeaseFire(Instigator.Controller, False);//StopFiring();

	 bStartFire = false;
	  bDoHit = false;
	}  // end tick


function Fire(Controller C)   {

  	bIsFiring = true;

	  bDoHit = true;
		UpTime = FireInterval+0.1;

    ShakeView();
    FlashMuzzleFlash();

    if (AmbientEffectEmitter != None)   AmbientEffectEmitter.SetEmitterStatus(true);
    // Play firing noise
    if (bAmbientFireSound)  AmbientSound = FireSoundClass;
    else  PlayOwnedSound(AltFireSoundClass, SLOT_None, AltFireSoundVolume/255.0,, AltFireSoundRadius,, False);
		}

} // End Stat
//================= End State Instant Fire

function SetLinkTo(Pawn Other)
{
    if (LockedPawn != None && MyLamprey != None)
    {
//        RemoveLink(1 + MyLamprey.Links, Instigator);
        MyLamprey.Linking = false;
    }

    LockedPawn = Other;

    if (LockedPawn != None)
    {
  //      if (!AddLink(1 + MyLamprey.Links, Instigator))
  //      {
  //          bFeedbackDeath = true;
  //      }
        MyLamprey.Linking = true;
        LockedPawn.PlaySound(MakeLinkSound, SLOT_None);
    }
}

/*
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
			//add code that checks for linkscorp.
            Inv = LockedPawn.FindInventoryType(class'LinkGun');
            if (Inv != None)
            {
                if (LinkFire(LinkGun(Inv).GetFireMode(1)).AddLink(Size, Starter))
                    LinkGun(Inv).Links += Size;
                else
                    return false;
            }
        }
    }
    return true;
}

function RemoveLink(int Size, Pawn Starter)
{
    local Inventory Inv;
    if (LockedPawn != None && !bFeedbackDeath)
    {
        if (LockedPawn != Starter)
        {
			//add code that checks for linkscorp.

            Inv = LockedPawn.FindInventoryType(class'LinkGun');
            if (Inv != None)
            {
                LinkFire(LinkGun(Inv).GetFireMode(1)).RemoveLink(Size, Starter);
                LinkGun(Inv).Links -= Size;
            }
        }
    }
}
*/

function bool IsLinkable(Actor Other)
{
    local Pawn P;
    local LinkGun LG;
    local LinkFire LF;
    local int sanity;

    if ( Other.IsA('Pawn') && Other.bProjTarget )
    {
        P = Pawn(Other);
        if ( P.Weapon == None || !P.Weapon.IsA('LinkGun') )
		{
			if ( Vehicle(P) != None )
				return P.TeamLink( Instigator.GetTeamNum() );

            return false;
		}

        // pro-actively prevent link cycles from happening
        LG = LinkGun(P.Weapon);
        LF = LinkFire(LG.GetFireMode(1));
        while ( LF != None && LF.LockedPawn != None && LF.LockedPawn != P && sanity < 32 )
        {
            if ( LF.LockedPawn == Instigator )
                return false;

            LG = LinkGun(LF.LockedPawn.Weapon);
            if ( LG == None )
                break;
            LF = LinkFire(LG.GetFireMode(1));
            sanity++;
        }

        return ( Level.Game.bTeamGame && P.GetTeamNum() == Instigator.GetTeamNum() );
    }

    return false;
}

function WeaponCeaseFire(Controller C, bool bWasAltFire)
{
		Super.WeaponCeaseFire(C, bWasAltFire);
		if (!bWasAltFire) 	{
			bIsFiring = false;
			if (Vehicle(Instigator) != None) 	{
				 Vehicle(Instigator).Driver.AmbientSound = None;//changes
				Vehicle(Instigator).Driver.SoundVolume = Instigator.Default.SoundVolume;//changes
		  }
	    if (Beam1 != None)   {
	        Beam1.Destroy();
	        Beam1 = None;
	    }
			if (Beam2 != None)   {	        
	        Beam2.Destroy();
	        Beam2 = None;
	    }
//	    SetLinkTo(None);
			bStartFire = true;
			bFeedbackDeath = false;
		
	}
}

defaultproperties
{
     BeamEffectClass=Class'LinkVehiclesOmni.LampreyBeamEffect'
     MakeLinkSound=Sound'WeaponSounds.LinkGun.LinkActivated'
     LinkBreakDelay=0.500000
     //
     //LinkScale(1)=0.500000
     //LinkScale(2)=0.900000
     //LinkScale(3)=1.200000
     //LinkScale(4)=1.400000
     //LinkScale(5)=1.500000
     MakeLinkForce="LinkActivated"
     Damage=12  //link gun shaft is 9
     DamageMin=12 
     Momentum=-10000  //sucking u in 
     LinkFlexibility=0.300000
     bInitAimError=True
     LinkVolume=240
     BeamSounds(0)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     //BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam2'
     //BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam3'
     //BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam4'
     YawBone="PlasmaGunBarrel"
     YawStartConstraint=57344.000000
     YawEndConstraint=8192.000000
     PitchBone="PlasmaGunBarrel"
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     WeaponFireOffset=25.000000
     DualFireOffset=25.000000
     RotationsPerSecond=0.800000
     FireInterval=0.200000
    
     
     PitchUpLimit=18000
     PitchDownLimit=49153
     bInstantRotation=True
     bInstantFire=True
     bDualIndependantTargeting=True
     bDoOffsetTrace=True
     bAmbientFireSound=True
     bIsRepeatingFF=True
    
     
     
     FireSoundVolume=255.000000
     DamageType=Class'DamTypeLampreyBeam'
     TraceRange=3000.000000  // 1100 is link gun's trace range
     ShakeRotMag=(Z=60.000000)
     ShakeRotRate=(Z=4000.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Y=1.000000,Z=1.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     AIInfo(0)=(bInstantHit=True,aimerror=1200.000000)
     AIInfo(1)=(bInstantHit=True,aimerror=1200.000000)
     CullDistance=7500.000000
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
     SoundVolume=150
    
		 SelfHealMultiplier = 1.1;
		 VehicleDamageMultiplier = 1.1; //  increased damage to vehicles might add some specific vehicles here?
     
}

