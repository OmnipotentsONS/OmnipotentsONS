
class WraithLinkTurret extends WraithWeapon;

#exec audio import file=Sounds\WraithLinkAmbient.wav


var() float DamagePerSecond;
var() int MinDamageAmount;
var() float HealMultiplier;
var() float SelfHealMultiplier;
var() float LinkBreakError;
var class<WraithLinkBeamEffect> BeamEffectClass;
var array<class<Projectile> > TeamProjectileClasses;

var WraithLinkBeamEffect Beam1, Beam2;
var bool bIsFiringBeam;
var Actor LinkedActor;
var float SavedDamage, SavedHeal;
var float DamageModifier;

replication
{
    reliable if (Role == ROLE_Authority)
		bIsFiringBeam;
}

/*  Not needed spawns extra beams on the client. - pooty
simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
	Super.ClientStopfire(C,bWasAltFire);
	//if(!bWasAltFire) 	{
		bIsFiringBeam=False; // Always turn off beam
		DestroyEffects(); // Try this kill extra client effects?
	//}
}

simulated function ClientStartFire(Controller C, bool bWasAltFire)
{
	Super.ClientStartfire(C,bWasAltFire);
	if(bWasAltFire) 	{
		bIsFiringBeam=True;
	}
	else {
		bIsFiringBeam=False;
	}
	
}  
*/

function byte BestMode()
{
	if (Instigator == None || Instigator.Controller == None)
		return 0;

	if (Instigator.Controller.Target != None && VSize(Instigator.Controller.Target.Location - Location) < TraceRange)
		return 1;

	if (Instigator.Controller.Enemy != None && VSize(Instigator.Controller.Enemy.Location - Location) < TraceRange)
		return 1;

	return 0;
}


simulated function float MaxRange()
{
	if (bIsFiringBeam) 	{
		if (Instigator != None && Instigator.Region.Zone != None && Instigator.Region.Zone.bDistanceFog)
			TraceRange = FClamp(Instigator.Region.Zone.DistanceFogEnd, 8000, default.TraceRange);
		else
			TraceRange = default.TraceRange;

		AimTraceRange = TraceRange;
	}
	else if (ProjectileClass != None)
		AimTraceRange = ProjectileClass.static.GetRange();
	else
		AimTraceRange = 10000;

	return AimTraceRange;
}


simulated function DestroyEffects()
{
	
	Super.DestroyEffects();
	//Log("Wraith-DestroyEffects");
	//if ( Level.NetMode != NM_Client ) 	 {
		if (Beam1 != None) {
		//  Log("Wraith-DestroyEffects-DestroyBeam1");
			Beam1.Destroy();
		}	
		if (Beam2 != None) {
			Beam2.Destroy();
		}	
	//}		
	Beam1 = None;
	Beam2 = None;

	
}


function bool CanAttack(Actor Other)
{
	local vector HL, HN;
	local ONSWeaponPawn WeaponPawn;

	if (Super.CanAttack(Other))
	{
		WeaponPawn = ONSWeaponPawn(Owner);
		if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
			return WeaponPawn.VehicleBase.TraceThisActor(HL, HN, WeaponFireLocation, Other.Location);
		else
			return Owner.TraceThisActor(HL, HN, WeaponFireLocation, Other.Location);
	}

	return false;
}


simulated function CalcWeaponFire()
{
	local coords WeaponBoneCoords;
	local vector CurrentFireOffset;

	// Calculate fire offset in world space
	WeaponBoneCoords = GetBoneCoords(WeaponFireAttachmentBone);
	CurrentFireOffset = WeaponFireOffset * WeaponBoneCoords.XAxis;
	// Calculate rotation of the gun
	WeaponFireRotation = rotator(vector(CurrentAim) >> Rotation);
	// Calculate exact fire location
	//WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset /*>> WeaponFireRotation*/);
	WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> WeaponFireRotation);
}

//------------------------------------------
function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	local Projectile P1, P2;
	local ONSWeaponPawn WeaponPawn;
	local vector StartLocation, HitLocation, HitNormal, Extent, X, Y, Z;


	if (bDoOffsetTrace)
	{
		Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
		Extent.Z = ProjClass.default.CollisionHeight;
		WeaponPawn = ONSWeaponPawn(Owner);
		if (WeaponPawn != None && WeaponPawn.VehicleBase != None) 	{
			if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5), Extent))
				StartLocation = HitLocation;
			else
				StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
		}
		else 	{
			if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
				StartLocation = HitLocation;
			else
				StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
		}
	}
	else 	{
		StartLocation = WeaponFireLocation;
	}

	GetAxes(WeaponFireRotation, X, Y, Z);
	
  //Log("WraithSpawnProjectile: ProjClass="@ProjClass);
	P1 = Spawn(ProjClass, self,, StartLocation + DualFireOffset * Y, WeaponFireRotation);
	P2 = Spawn(ProjClass, self,, StartLocation - DualFireOffset * Y, WeaponFireRotation);

	if (P1 != None || P2 != None) 	{
		if (bInheritVelocity) 		{
			if (P1 != None)
				P1.Velocity += Instigator.Velocity;
			if (P2 != None)
				P2.Velocity += Instigator.Velocity;
		}
		FlashMuzzleFlash();

		// Play firing noise
		if (bAltFire) 	{
			if (bAmbientAltFireSound)
				AmbientSound = AltFireSoundClass;
			else
				PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
		}
		else 		{
			if (bAmbientFireSound)
				AmbientSound = FireSoundClass;
			else
				PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
		}
	}

	if (P1 != None)
		return P1;
	else
		return P2;
}

simulated event OwnerEffects()
{
	if (!bIsRepeatingFF) 	{
		if (bIsAltFire)
			ClientPlayForceFeedback( AltFireForce );
		else
			ClientPlayForceFeedback( FireForce );
	}
	ShakeView();

	if (Role < ROLE_Authority && !bIsAltFire) 	{
		FireCountdown = FireInterval;
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;
		FlashMuzzleFlash();
		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);
		if (!bAmbientFireSound)
			PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
	}
}


//simulated function UpdateBeamState()
// THIS SHOULD NOT HAVE BEEN simultaed.. it doesn't need to run on both!!!
function UpdateBeamState()
{
	local int TeamNum;
	
  
  //Log("Wraith-UpdateBeamState-bIsFiring "$bIsFiringBeam$"Beam1="@Beam1);
	if (!bIsFiringBeam) 	{
		
		if (Beam1 != None) {
			Beam1.Destroy();
			//g("Wraith-UpdateBeamState-DestoryBeam1");
		}	
		if (Beam2 != None)
			Beam2.Destroy();
		Beam1 = None;
		Beam2 = None;
		LinkedActor = None;
		
	}
	else if (bIsFiringBeam && (Beam1 == None))  //we'll just check beam1 but we create destroy in pairs
	{
		//if (Level.NetMode != NM_DedicatedServer)
		//{
		  TeamNum = Instigator.GetTeamNum(); // for beam colors
		  //Log("Wraith-UpdateBeamState-Firing");
			//TraceBeamFire(0);
			if (Beam1 == None) 	{
				//Log("Wraith-UpdateBeamState-SpawnBeam1");
				Beam1 = Spawn(BeamEffectClass, Self);
				Beam1.SetUpBeam(TeamNum, False);
				Beam1.SetBeamPosition();
			}
			//AttachToBone(Beam1, WeaponFireAttachmentBone);
			//Beam1.SetRelativeLocation((vect(1,0,0) * WeaponFireOffset + vect(0,1,0) * DualFireOffset) * DrawScale);

			if (Beam2 == None)	{
				Beam2 = Spawn(BeamEffectClass, Self);
				Beam2.SetUpBeam(TeamNum, True);  //Left
				Beam2.SetBeamPosition();
			}
			//AttachToBone(Beam2, WeaponFireAttachmentBone);
			//Beam2.SetRelativeLocation((vect(1,0,0) * WeaponFireOffset - vect(0,1,0) * DualFireOffset) * DrawScale);
		//} //Dedicated
		//bIsFiringBeam = True;
		MaxRange();
	}
}



//simulated function bool IsValidLinkTarget(Actor Target, Actor ThisVehicle)
function bool IsValidLinkTarget(Actor Target, Actor ThisVehicle)
{
	local DestroyableObjective HealObjective;
	
	
	//Log("Wraith-IsValidLinkTarget Target"$Target$" ThisVehicle"$ThisVehicle);
	if (Target == None || !Target.bCollideActors || !Target.bProjTarget || ThisVehicle == Target ) // Added Vehicle(Instigator)== Target so it doesn't lock itself to itself
		return false;

	if (Vehicle(Target) != None && Vehicle(Target).Health > 0)
		return true; // link both friendly and enemy vehicles

	HealObjective = DestroyableObjective(Target);
	if (HealObjective == None)
		HealObjective = DestroyableObjective(Target.Owner);  // Energy sphere or any other class with healable owner

	//if (HealObjective != None && HealObjective.TeamLink(Instigator.GetTeamNum()))
	if (HealObjective != None && !HealObjective.IsInState('NeutralCore'))
		 // lock on to enemy nodes, but whether damage/heal is determined by trace, don't lock neutral nodes
		return true;
	

	return false;
}

//simulated function TraceBeamFire(float DeltaTime)
function TraceBeamFire(float DeltaTime)
{
	local vector HL, HN, Dir, HL2, HN2, EndPoint;
	local Actor HitActor, NewLinkedActor;
	local ONSWeaponPawn WeaponPawn;
	local Vehicle BaseVehicle;
	local int DamageAmount, PrevHealth;
	local DestroyableObjective Node;
  //Log("In WraithLinkTurret=TraceBeamFire");
  local int TeamNum;
  

  LinkedActor = None;
	CalcWeaponFire();
  EndPoint = WeaponFireLocation + vector(WeaponFireRotation) * TraceRange;
	WeaponPawn = ONSWeaponPawn(Owner);
	
	
	if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
		BaseVehicle = WeaponPawn.VehicleBase;
	else
		BaseVehicle = Vehicle(Owner);
  
  //Log("In WraithLinkTurret=TraceBeamFire-AfterWeaponPawn-BaseVehicle"@BaseVehicle);
  
   //skip past vehicle driver, not sure this works, but from DualACGatlingGun
    if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
    {
        ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
        HitActor = Trace(HL, HN, EndPoint, WeaponFireLocation, True,vect(10,10,10));
        ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
    }
    else
        HitActor = Trace(HL, HN, EndPoint, WeaponFireLocation, True, vect(10,10,10));

         
	//HitActor = Trace(HL, HN, EndPoint, WeaponFireLocation, True, vect(10,10,10));
	 //Log("In WraithLinkTurret=TraceBeamFire-AfterHitActorSet"@HitActor);
	
	//if (HitActor == None || HitActor == BaseVehicle || HitActor.bWorldGeometry) 	{
	if (HitActor == None || HitActor == BaseVehicle || HitActor.bWorldGeometry) 	{
		// try again with zero extent
		HitActor = Trace(HL, HN, WeaponFireLocation + vector(WeaponFireRotation) * TraceRange, WeaponFireLocation, True, vect(10,10,10));
		if (HitActor == None) 		{
			HL = WeaponFireLocation + vector(WeaponFireRotation) * TraceRange;
			HN = vector(WeaponFireRotation);
		}
	}
	
	
	//Log("In WraithLinkTurret=TraceBeamFire-AfterHitActorSetZE"@HitActor$"BaseVehicle"@BaseVehicle);
	if (HitActor != BaseVehicle && IsValidLinkTarget(HitActor, BaseVehicle)) 	{
		NewLinkedActor = HitActor;
		//Log("In WraithLinkTurret=TraceBeamFire-ValidLinkActor"@HitActor);
	}
	else if (IsValidLinkTarget(LinkedActor,BaseVehicle))	{
				Dir = LinkedActor.Location - WeaponFireLocation;
				if (VSize(Dir) < TraceRange && Normal(Dir) dot vector(WeaponFireRotation) > LinkBreakError)		{
					HitActor = Trace(HL2, HN, LinkedActor.Location, WeaponFireLocation, True, vect(0,0,0));
					if (HitActor == None || HitActor == LinkedActor) 			{
						HL = HL2;
						HN = HN2;
						NewLinkedActor = LinkedActor;
					}
				}
			}
			else 	{
				NewLinkedActor = None;
			}
	
	
	LinkedActor = NewLinkedActor;
	
  //Log("In WraithLinkTurret=TraceBeamFire-AfterLinkedActor"@LinkedActor);

	if (Beam1 != None ) 	{ 
		Beam1.EndEffect = HL;
		Beam1.LinkedActor = LinkedActor;
		Beam1.bLockedOn = LinkedActor != None;
		Beam1.bHitSomething = HitActor != None && HitActor.bWorldGeometry;
	}
	if (Beam2 != None ) 	{
		Beam2.EndEffect = HL;
		Beam2.LinkedActor = LinkedActor;
		Beam2.bLockedOn = LinkedActor != None;
		Beam2.bHitSomething = HitActor != None && HitActor.bWorldGeometry;
	}

	if (Role == ROLE_Authority) 	{
		SavedDamage += DamagePerSecond * DeltaTime * DamageModifier;
		DamageAmount = int(SavedDamage);

		if (DamageAmount > MinDamageAmount) 		{
			SavedDamage -= DamageAmount;
			TeamNum = Instigator.GetTeamNum();
			
			If (LinkedActor != None) HitActor = LinkedActor; 
			
			if (HitActor != None && !HitActor.bWorldGeometry && Level.Game.bTeamGame) {
				
				 //log("WraithLinkTurret:HitActor"$HitActor$"MyTeam="$TeamNum);
				 if (Vehicle(HitActor) != None  && Vehicle(HitActor).Health > 0 && !HitActor.IsA('ONSSpecialLinkBeamCatcher')) { // VEhicle , except Dumbass ONSSpecials made stupid beamcatcher as subclsss of vehicle!  Dumb.  03/2023 pooty
				 	  if (Vehicle(HitActor).GetTeamNum() == TeamNum) { // Team Vehicle
				 	  	//log("WraithLinkTurret:HealFriendlyVehicle");
				 	  	HitActor.HealDamage(Round(DamageAmount * HealMultiplier), Instigator.Controller, DamageType);
				 	  }
				 	  else { // Enemy Vehicle
				 	  	if (Vehicle(HitActor).GetTeamNum() < 2 && Vehicle(HitActor).Health > 0) {  //Check for enemy Turrets are neutral 255, Team is either 0 red or 1 blue
				 	  		//log("WraithLinkTurret:DamageEnemyVehicle Team="$Vehicle(HitActor).GetTeamNum());
				 	  		HitActor.TakeDamage(DamageAmount, Instigator, HL, DeltaTime * Momentum * vector(WeaponFireRotation), DamageType);
				   	 		if (BaseVehicle.Health < BaseVehicle.HealthMax) BaseVehicle.HealDamage(Round(DamageAmount * SelfHealMultiplier), Instigator.Controller, DamageType);
				   	 	}	
				 	  } // Enemy Vehicle
				 }//Vehicle
				 else { // Node or Other Actor
				 	
				 	 Node = DestroyableObjective(HitActor);
				 //	 log("WraithLinkTurret:Node="$Node$" HitActor.Owner"$HitActor.Owner );
				 	 // shield or sphere Make the hit the node itself, so heals can construct
				 	 //if ((ONSPowerNodeEnergySphere(HitActor) != None) || (ONSPowerNodeShield(HitActor) != None)) Node = DestroyableObjective(HitActor.Owner);
				 	 if (HitActor.IsA('ONSPowerNodeEnergySphere') 
				 	    || HitActor.IsA('ONSPowerNodeShield') 
				 	    || HitActor.IsA('ONSSpecialLinkBeamCatcher')
				 	    || HitActor.IsA('ONSSpecialPowerNodeShield') 
				 	    || HitActor.IsA('ONSSpecialPowerNodeEnergySphere')) 
				 	    Node = DestroyableObjective(HitActor.Owner);
				 	 			 	
				 	 
				 	 //log("WraithLinkTurret:Node,AfterSphere/Shield="$Node );
				   if (Node != None) {
				  	//log("WraithLinkTurret:HitActorNode"$HitActor$"ONSPowerCore(Node).PoweredBy(TeamNum"$TeamNum$")="$ONSPowerCore(Node).PoweredBy(TeamNum));
				  	// While its constructing PoweredBy(TeamNum) doesn't get set right.  It only gets set when node fully powers up.
				  				 
              if (Node.IsA('ONSPowerNode')  && (Node.DefenderTeamIndex == TeamNum) && Node.Health > 0 )
						  //if (ONSPowerNode(Node) != None && ONSPowerNode(Node).PoweredBy(TeamNum) && Node.Health > 0 )
				  		{ // Friendly Node
				  			//log("WraithLinkTurret:HealFriendlyNode");
				  	   	Node.HealDamage(Round(DamageAmount * HealMultiplier), Instigator.Controller, DamageType);
				     	}
				   	else { // Enemy Node, core or team core.
				   		 PrevHealth = Node.Health;
				   		 //log("WraithLinkTurret:EnemyNode" );
				   		 if (!Node.IsInState('NeutralCore') && Node.Health > 0 && !(Node.DefenderTeamIndex == TeamNum) ) {
				   	 			//log("WraithLinkTurret:EnemyNode-TakeDamage" );
				   	 	 		Node.TakeDamage(DamageAmount, Instigator, HL, DeltaTime * Momentum * vector(WeaponFireRotation), DamageType);
				   	 	 		// Only heal if damage was dealt
				   	 	 		if (BaseVehicle.Health < BaseVehicle.HealthMax && Node.Health < PrevHealth) BaseVehicle.HealDamage(Round(DamageAmount * SelfHealMultiplier), Instigator.Controller, DamageType);
				   	 		} 
				   	} // Enemy Node
				  } // Node 	
				  else { // some other actor, not linkable 
				  	if (Pawn(HitActor)!=None) {
				  		PrevHealth = Pawn(HitActor).Health;
				  	}
				  	HitActor.TakeDamage(DamageAmount, Instigator, HL, DeltaTime * Momentum * vector(WeaponFireRotation), DamageType);
				  	if (Pawn(HitActor) != None && BaseVehicle.Health < BaseVehicle.HealthMax && PrevHealth > Pawn(HitActor).Health) {
				  		BaseVehicle.HealDamage(Round(DamageAmount * SelfHealMultiplier), Instigator.Controller, DamageType);
				  	}
				  	//log("WraithLinkTurret:SomeActor="$HitActor);
				  	// bots xPawn.  real players?
				  } // Other Actor
				} // Node or ACTOR
			}	// Hit
		} // Damage Amount
	} // Role_Authority
			
} // Trace BeamFire END							
							
							

							
	    //Old shit code, mix of orignal code and few tweaks by pooty.
	    /*
			if (LinkedActor != None)	{
				if (Level.Game.bTeamGame && (Vehicle(LinkedActor) != None && Vehicle(LinkedActor).GetTeamNum() == Instigator.GetTeamNum()) || DestroyableObjective(LinkedActor) != None || DestroyableObjective(LinkedActor.Owner) != None)	{
				// Bug was here... LinkedActor might be EnergySphere, or shield on locked node, ..redirect to allow node building faster
				// both do have healdamage function but they do NOTHING.
				  if ((ONSPowerNodeEnergySphere(LinkedActor) != None) || (ONSPowerNodeShield(LinkedActor) != None)) {
				  		LinkedActor = DestroyableObjective(LinkedActor.Owner);
							LinkedActor.HealDamage(Round(DamageAmount * HealMultiplier), Instigator.Controller, DamageType);
						}
					else { // other healable actors (powernode itself or vehicles
							LinkedActor.HealDamage(Round(DamageAmount * HealMultiplier), Instigator.Controller, DamageType);		
					}		
		//			log("Wraith WraithLinkTurret HealDamage"@LinkedActor);
				}
				else	{
					if (Vehicle(LinkedActor) != None && BaseVehicle.Health < BaseVehicle.HealthMax) 					{
						BaseVehicle.HealDamage(Round(DamageAmount * SelfHealMultiplier), Instigator.Controller, DamageType);
		//				Log("Wraith:WraithLinkTurret-HealDamage1");
					}
			//		 Log("In WraithLinkTurret=TakeDamage1");
					LinkedActor.TakeDamage(DamageAmount, Instigator, HL, DeltaTime * Momentum * vector(WeaponFireRotation), DamageType);
				}
			}
			else if (HitActor != None && !HitActor.bWorldGeometry && HitActor != BaseVehicle)	{
				Node = DestroyableObjective(HitActor);
				if (Node == None)
					Node = DestroyableObjective(HitActor.Owner);
				if (Node != None && Node.Health > 0 && BaseVehicle.Health < BaseVehicle.HealthMax && (ONSPowerCore(Node) == None || ONSPowerCore(Node).PoweredBy(Team) && !Node.IsInState('NeutralCore')))
				{
				//if (DestroyableObjective(HitActor) != None && DestroyableObjective(HitActor).Health > 0 || DestroyableObjective(HitActor.Owner) != None && DestroyableObjective(HitActor.Owner).Health > 0 && BaseVehicle.Health < BaseVehicle.HealthMax) {
					BaseVehicle.HealDamage(Round(DamageAmount * SelfHealMultiplier), Instigator.Controller, DamageType);
					//Need to check if its locked powernode/core...
	//				Log("Wraith:WraithLinkTurret-HealDamage2");
				}
		//		Log("In WraithLinkTurret=TakeDamage2");
				HitActor.TakeDamage(DamageAmount, Instigator, HL, DeltaTime * Momentum * vector(WeaponFireRotation), DamageType);
			}
		}
	}
	*/



//----------------------------------------- State INSTANT FIRE

state InstantFireMode
{
	  simulated function ClientSpawnHitEffects()
    {
    }

    function SpawnHitEffects(Actor HitActor, vector HitLocation, vector HitNormal)
    {
    }
    
		simulated function Tick(float DeltaTime)
		{
			
			Super.Tick(DeltaTime);

		  UpdateBeamState();  // Turns on/off beam based on bIsFiring
			if (bIsFiringBeam  && Beam1 != None)
			{
				TraceBeamFire(DeltaTime);
			}
			
		} // End Tick

	function Fire(Controller C)
	{
		//if (!bClientTrigger)
		//{
		  //Log("Wraith-ProjectileFire");
			bIsFiringBeam = False;
			if (Team < TeamProjectileClasses.Length && TeamProjectileClasses[Team] != None)
				SpawnProjectile(TeamProjectileClasses[Team], False);
			else
				SpawnProjectile(ProjectileClass, False);
		}

	function AltFire(Controller C)
	{
		//Log("Wraith-InstantFire-AltFire");
		AmbientSound = AltFireSoundClass;
    bIsFiringBeam = True;

		// NetUpdateTime = Level.TimeSeconds - 1;
		// Why was this messing with NetUpdateTime?!
		// Doesn't seem to change anything and not seen it in other weapons.
	}

	function WeaponCeaseFire(Controller C, bool bWasAltFire)
	{
		Super.WeaponCeaseFire(C,bWasAltFire);
		
		//if (Wraith(Owner)!=None)
    //    Beam=Wraith(Owner).Beam;
        
		if (bWasAltFire && (Beam1 != None))
		{
			AmbientSound = None;
//			bClientTrigger = False;
		  //Log("WraithLinkTurret-WeaponCeaseFire:bWasAltFire"@bWasAltFire);
			bIsFiringBeam = False;
			UpdateBeamState();
			// destory beams.
			
			//NetUpdateTime = Level.TimeSeconds - 1;
			// in ONSLinkTank, but not in UT2004 LinkFire, so not sure what it does?
		}
	}
}
//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     DamagePerSecond=150.000000
     MinDamageAmount=10
     HealMultiplier=0.800000
     SelfHealMultiplier=0.800000
     LinkBreakError=0.950000
     BeamEffectClass=Class'PVWraith.WraithLinkBeamEffect'
     TeamProjectileClasses(0)=Class'PVWraith.WraithLinkPlasmaProjectileRed'
     TeamProjectileClasses(1)=Class'PVWraith.WraithLinkPlasmaProjectileBlue'
     DamageModifier=1.000000
     //YawBone="Object83"
     //PitchBone="Object84"
     //PitchUpLimit=15000
     
     YawBone="GatlingGun"
     PitchBone="GatlingGun"
     PitchUpLimit=-1950  // 0 is fine on client, but on Server it hits the vehicle hitbox
     PitchDownLimit=50000
     WeaponFireAttachmentBone="GatlingGunFirePoint"

     //WeaponFireAttachmentBone="Object85"
     //GunnerAttachmentBone="Object83"
     WeaponFireOffset=0.000000  // was 30, doesn't need to be offset want it centered on the turret
     DualFireOffset=5.000000 //18
     bAmbientAltFireSound=True
     FireInterval=0.200000
     AltFireInterval=0.100000
     FireSoundClass=Sound'ONSVehicleSounds-S.LaserSounds.Laser17'
     AltFireSoundClass=Sound'PVWraith.WraithLinkAmbient'
     FireForce="Laser01"
     DamageType=Class'PVWraith.DamTypeWraithLinkBeam'
     DamageMin=15
     DamageMax=15
     TraceRange=4000.000000
     Momentum=-30000.000000
     ProjectileClass=Class'PVWraith.WraithLinkPlasmaProjectile'
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.200000,RefireRate=0.700000)
     AIInfo(1)=(bInstantHit=True,WarnTargetPct=0.200000)
     //Mesh=SkeletalMesh'ONSFullAnimations.MASPassengerGun'
     Mesh=SkeletalMesh'ONSBPAnimations.DualAttackCraftGatlingGunMesh'
     DrawScale=0.600000
     CullDistance=15000
     Skins(0)=Texture'ONSFullTextures.MASGroup.LEVnoColor'
     
     // Added for InstantFire
     bInstantRotation=True
     bInstantFire=True
}
