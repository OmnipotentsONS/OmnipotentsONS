// ============================================================================
// TeamSpecificPhysicsVolume_v2, v2.0 @ 14-11-2005 13:33:37
// Shamelessly copied from PhysicsVolume to keep the number of groups to a 
// minimun by Robin 'Jrubzjeknf' van Olst <rrvanolst@hotmail.com>
// (with some extra stuff of course ;)
//
// Damaging players on different teams are treated differenly. Players of one
// team can walk through the volume with no harm done, while players of the
// other team immediately turn into ragdolls. Damaging can be combined with
// several ways of notifying the player. These are: playing a sound, flashing
// the player's screen and sending a message. The message's color and lifetime
// can be modified. Works for vehicles as well.
//
// Explanation General Variables:
// bPainCausing:      Does this volume cause pain on mapload? When triggering
//                    this volume, this variable is modified.
//
// Explanation Team variables (number suffix reflects team, in this case red):
// bGetHurtByVolume0: Can this team be hurt by this volume?
// bScreenFlash0:     When hurt, does the player's screen flash?
// DamagePerSec0:     How much pain caused every second.
// DamageType0:       How to damage player.
// InPainMessage0:    Message to send to the player when he's hurt.
// MessageColor0:     Color of the message.
// MessageLifetime0:  How long the message should be displayed, in seconds.
// PlaySound0:        Plays a sound.
//
// Full documentation on TeamSpecificActors_v2.u can be downloaded from:
// http://unrealized-potential.com/forum/index.php?act=Attach&type=post&id=5135
//=============================================================================
class TeamSpecificPhysicsVolume extends Volume;

replication
{
   reliable if ( Role == ROLE_Authority )
      bGetHurtByVolume0, bScreenFlash0, DamagePerSec0, DamageType0,
      InPainMessage0, MessageColor0, MessageLifetime0, PlaySound0,
      bGetHurtByVolume1, bScreenFlash1, DamagePerSec1, DamageType1,
      InPainMessage1, MessageColor1, MessageLifetime1, PlaySound1,
      CurrentMessage0, CurrentMessage1, Gravity;
}

//=============================================================================
// Variables
//=============================================================================
var() bool bPainCausing;
var() bool bSwitchColorOnReset;
var   bool bChangeOnNextReset;
var   bool bIsASPractiseRound;
var   bool bIsASorONS;

var(TeamSpecificPhysicsVolume_Red)  bool	      bGetHurtByVolume0;
var(TeamSpecificPhysicsVolume_Red)  bool              bScreenFlash0;
var(TeamSpecificPhysicsVolume_Red)  float	      DamagePerSec0;
var(TeamSpecificPhysicsVolume_Red)  class<DamageType> DamageType0;
var(TeamSpecificPhysicsVolume_Red)  string            InPainMessage0;
var                                 string            CurrentMessage0;
var(TeamSpecificPhysicsVolume_Red)  color             MessageColor0;
var(TeamSpecificPhysicsVolume_Red)  int               MessageLifetime0;
var(TeamSpecificPhysicsVolume_Red)  sound             PlaySound0;

var(TeamSpecificPhysicsVolume_Blue) bool	      bGetHurtByVolume1;
var(TeamSpecificPhysicsVolume_Blue) bool              bScreenFlash1;
var(TeamSpecificPhysicsVolume_Blue) float	      DamagePerSec1;
var(TeamSpecificPhysicsVolume_Blue) class<DamageType> DamageType1;
var(TeamSpecificPhysicsVolume_Blue) string            InPainMessage1;
var                                 string            CurrentMessage1;
var(TeamSpecificPhysicsVolume_Blue) color             MessageColor1;
var(TeamSpecificPhysicsVolume_Blue) int               MessageLifetime1;
var(TeamSpecificPhysicsVolume_Blue) sound             PlaySound1;

//variables beyond this point are consistent with the ones in PhysicsVolume

var()	vector	                 ZoneVelocity;
var()	vector	                 Gravity;
var	vector	                 BACKUP_Gravity;
var()	float	                 GroundFriction;
var()	float	                 TerminalVelocity;
var()	int		         Priority;	        // determines which PhysicsVolume takes precedence if they overlap
var()   sound	                 EntrySound;            //only if waterzone
var()   sound	                 ExitSound;		// only if waterzone
var()   editinline I3DL2Listener VolumeEffect;
var()   class<actor>             EntryActor;	        // e.g. a splash (only if water zone)
var()   class<actor>             ExitActor;	        // e.g. a splash (only if water zone)
var()   class<actor>             PawnEntryActor;        // when pawn center enters volume
var()   float                    FluidFriction;
var()   vector                   ViewFog;

var	bool		         BACKUP_bPainCausing;
var()	bool	                 bDestructive;          // Destroys most actors which enter it.
var()	bool	                 bNoInventory;
var()	bool	                 bMoveProjectiles;      // this velocity zone should impart velocity to projectiles and effects
var()	bool	                 bBounceVelocity;	// this velocity zone should bounce actors that land in it
var()	bool	                 bWaterVolume;
var()	bool	                 bNoDecals;
var()	bool	                 bDamagesVehicles;

// Distance Fog
var(VolumeFog) bool  bDistanceFog;	                // There is distance fog in this physicsvolume.
var(VolumeFog) color DistanceFogColor;
var(VolumeFog) float DistanceFogStart;
var(VolumeFog) float DistanceFogEnd;

// Karma
var(Karma)	   float KExtraLinearDamping;           // Extra damping applied to Karma actors in this volume.
var(Karma)	   float KExtraAngularDamping;
var(Karma)	   float KBuoyancy;			// How buoyant Karma things are in this volume (if bWaterVolume true). Multiplied by Actors KarmaParams->KBuoyancy.
var	Info PainTimer;
var PhysicsVolume NextPhysicsVolume;


//=============================================================================
// PostBeginPlay
//=============================================================================
simulated function PostBeginPlay()
{
   if ( Role == ROLE_Authority ) //can only be done on server
   {
      if ( Level.Game.IsA('ASGameInfo') )
      {
         bIsASPractiseRound = false;
         bIsASorONS = true;
      }
      
      if ( Level.Game.IsA('ONSOnslaughtGame') )
      {
         bChangeOnNextReset = true;
         bIsASorONS = true;
      }

      CurrentMessage0 = class'TeamSpecificLocalMessage'.static.MakeDynamicString(InPainMessage0, 1);
      CurrentMessage1 = class'TeamSpecificLocalMessage'.static.MakeDynamicString(InPainMessage1, 0);
   }

	super.PostBeginPlay();

	BACKUP_Gravity		= Gravity;
	BACKUP_bPainCausing	= bPainCausing;
	if( VolumeEffect == None && bWaterVolume )
		VolumeEffect = new(Level.xLevel) class'EFFECT_WaterVolume';
}


//=============================================================================
// Reset
//
// Switch around settings when this actor is used in AS, since teams switch too
//=============================================================================
function Reset()
{
   local bool              BACKUP_bGetHurtByVolume0;
   local bool              BACKUP_bScreenFlash0;
   local float             BACKUP_DamagePerSec0;
   local class<DamageType> BACKUP_DamageType0;
   local string            BACKUP_InPainMessage0;
   local color             BACKUP_MessageColor0;
   local int               BACKUP_MessageLifetime0;
   local sound             BACKUP_PlaySound0;

   Gravity       = BACKUP_Gravity;
   bPainCausing  = BACKUP_bPainCausing;
   NetUpdateTime = Level.TimeSeconds - 1;

   if ( bIsASorONS )
   {
      if ( !bIsASPractiseRound &&
           Level.Game.IsA('ASGameInfo') &&
           ASGameInfo(Level.Game).PracticeTimeLimit > 0 )
      {
         bIsASPractiseRound = true;
         return;
      }

      if ( bChangeOnNextReset )
      {
         BACKUP_bGetHurtByVolume0 = bGetHurtByVolume0;
         BACKUP_bScreenFlash0 = bScreenFlash0;
         BACKUP_DamagePerSec0 = DamagePerSec0;
         BACKUP_DamageType0 = DamageType0;
         BACKUP_InPainMessage0 = InPainMessage0;
         BACKUP_MessageColor0 = MessageColor0;
         BACKUP_MessageLifetime0 = MessageLifetime0;
         BACKUP_PlaySound0 = PlaySound0;
      
         bGetHurtByVolume0 = bGetHurtByVolume1;
         bScreenFlash0 = bScreenFlash1;
         DamagePerSec0 = DamagePerSec1;
         DamageType0 = DamageType1;
         InPainMessage0 = InPainMessage1;
         MessageColor0 = MessageColor1;
         MessageLifetime0 = MessageLifetime1;
         PlaySound0 = PlaySound1;
         
         bGetHurtByVolume1 = BACKUP_bGetHurtByVolume0;
         bScreenFlash1 = BACKUP_bScreenFlash0;
         DamagePerSec1 = BACKUP_DamagePerSec0;
         DamageType1 = BACKUP_DamageType0;
         InPainMessage1 = BACKUP_InPainMessage0;
         MessageColor1 = BACKUP_MessageColor0;
         MessageLifetime1 = BACKUP_MessageLifetime0;
         PlaySound1 = BACKUP_PlaySound0;
      
         if ( bSwitchColorOnReset )
         {
            MessageColor0 = class'TeamSpecificLocalMessage'.static.RGBtoBGR(MessageColor0);
            MessageColor1 = class'TeamSpecificLocalMessage'.static.RGBtoBGR(MessageColor1);
         }
      }
   }

   CurrentMessage0 = class'TeamSpecificLocalMessage'.static.MakeDynamicString(InPainMessage0, 1);
   CurrentMessage1 = class'TeamSpecificLocalMessage'.static.MakeDynamicString(InPainMessage1, 0);
   bChangeOnNextReset = true;
}


// Called when an actor in this PhysicsVolume changes its physics mode
event PhysicsChangedFor(Actor Other);
event ActorEnteredVolume(Actor Other);
event ActorLeavingVolume(Actor Other);


//=============================================================================
// PawnEnteredVolume
//=============================================================================
simulated event PawnEnteredVolume(Pawn Other)
{
	local vector HitLocation,HitNormal;
	local Actor SpawnedEntryActor;

	if ( bWaterVolume && (Level.TimeSeconds - Other.SplashTime > 0.3) && (PawnEntryActor != None) && !Level.bDropDetail && (Level.DetailMode != DM_Low) && EffectIsRelevant(Other.Location,false) )
	{
		if ( !TraceThisActor(HitLocation, HitNormal, Other.Location - Other.CollisionHeight*vect(0,0,1), Other.Location + Other.CollisionHeight*vect(0,0,1)) )	
			SpawnedEntryActor = Spawn(PawnEntryActor,Other,,HitLocation,rot(16384,0,0));
	}

	if ( (Role == ROLE_Authority) && Other.IsPlayerPawn() )
		TriggerEvent(Event,self, Other);
}


//=============================================================================
// PawnLeavingVolume
//=============================================================================
event PawnLeavingVolume(Pawn Other)
{
	if ( Other.IsPlayerPawn() )
		UntriggerEvent(Event,self, Other);
}


//=============================================================================
// PlayerPawnDiedInVolume
//=============================================================================
function PlayerPawnDiedInVolume(Pawn Other)
{
   UntriggerEvent(Event,self, Other);
}


//=============================================================================
// TimerPop
//=============================================================================
function TimerPop(VolumeTimer T)
{
	local actor A;
	local bool bFound;

	if ( T == PainTimer )
	{
		if ( !bPainCausing )
		{
			PainTimer.Destroy();
			return;
		}
		ForEach TouchingActors(class'Actor', A)
			if ( A.bCanBeDamaged && !A.bStatic )
			{
				CausePainTo(A);
				bFound = true;
			}

		if ( !bFound )
			PainTimer.Destroy();
	}
}


//=============================================================================
// Trigger
//
// Turns damaging on or off.
//=============================================================================
function Trigger( actor Other, pawn EventInstigator )
{
   local Pawn P;

   bPainCausing = !bPainCausing;
   if ( bPainCausing )
   {
      if ( PainTimer == None )
         PainTimer = spawn(class'VolumeTimer', self);

      foreach TouchingActors(class'Pawn', P)
         CausePainTo(P);
   }
}


//=============================================================================
// Touch
//=============================================================================
simulated event Touch(Actor Other)
{
	local Pawn P;
	local bool bFoundPawn;

	Super.Touch(Other);
	
        if ( Other == None )
		return;

	if ( (Other.Role == ROLE_Authority) || Other.bNetTemporary )
	{
		if ( bNoInventory && (Pickup(Other) != None) && (Other.Owner == None) )
		{
			Other.LifeSpan = 1.5;
			return;
		}
		if ( bMoveProjectiles && (ZoneVelocity != vect(0,0,0)) )
		{
			if ( Other.Physics == PHYS_Projectile )
				Other.Velocity += ZoneVelocity;
			else if ( (Other.Base == None) && Other.IsA('Emitter') && (Other.Physics == PHYS_None) )
			{
				Other.SetPhysics(PHYS_Projectile);
				Other.Velocity += ZoneVelocity;
			}
		}
		if ( bPainCausing )
		{
			if ( Other.bDestroyInPainVolume )
			{
				Other.Destroy();
				return;
			}

			if ( Other.bCanBeDamaged && !Other.bStatic )
			{
				CausePainTo(Other);
				if ( Role == ROLE_Authority )
				{
					if ( PainTimer == None )
						PainTimer = Spawn(class'VolumeTimer', self);
					else if ( Pawn(Other) != None )
					{
						ForEach TouchingActors(class'Pawn', P)
							if ( (P != Other) && P.bCanBeDamaged )
							{
								bFoundPawn = true;
								break;
							}
						if ( !bFoundPawn )
							PainTimer.SetTimer(1.0,true);
					}
				}
			}
		}
	}
	if ( bWaterVolume && Other.CanSplash() )
		PlayEntrySplash(Other);
}


//=============================================================================
// PlayEntrySplash
//=============================================================================
simulated function PlayEntrySplash(Actor Other)
{
	local vector StartLoc, Vel2D;
	
	if( EntrySound != None )
	{
		Other.PlaySound(EntrySound, SLOT_Interact, Other.TransientSoundVolume);
		if ( Other.Instigator != None )
			MakeNoise(1);
	}
	if( (EntryActor != None) && (Level.NetMode != NM_DedicatedServer) )
	{
		StartLoc = Other.Location - Other.CollisionHeight*vect(0,0,0.8);
		if ( Other.CollisionRadius > 0 )
		{
			Vel2D = Other.Velocity;
			Vel2D.Z = 0;
			if ( VSize(Vel2D) > 100 )
				StartLoc = StartLoc + Normal(Vel2D) * CollisionRadius;
		}
		Spawn(EntryActor,,,StartLoc,rot(16384,0,0));
	}
}


//=============================================================================
// untouch
//=============================================================================
simulated event untouch(Actor Other)
{
	if ( bWaterVolume && Other.CanSplash() )
		PlayExitSplash(Other);
}



//=============================================================================
// PlayExitSplash
//=============================================================================
simulated function PlayExitSplash(Actor Other)
{
	if( ExitSound != None )
		Other.PlaySound(ExitSound, SLOT_Interact, Other.TransientSoundVolume);
	if( (ExitActor != None) && (Level.NetMode != NM_DedicatedServer) )
		Spawn(ExitActor,,,Other.Location - Other.CollisionHeight*vect(0,0,0.8),rot(16384,0,0));
}


//=============================================================================
// CausePainTo
//
// Check on what team the player is and damage him according to settings. Send
// a message, play a sound and view a flash if the mappers wants that.
//=============================================================================
function CausePainTo(Actor Other)
{
   local Pawn P;
   local Controller C;
   local PlayerController PC;

   if ( Pawn(Other) == None )
      return;

   P = Pawn(Other);

   if ( Pawn(Other).Controller != None )
      C = P.Controller;

   if ( C != None &&
        PlayerController(C) != None )
      PC = PlayerController(C);

   if ( P.GetTeamNum() == 0 && bGetHurtByVolume0 )
   {
      if ( DamagePerSec0 > 0 )
      {
         if ( InPainMessage0 != "" )
            P.ReceiveLocalizedMessage(class'TeamSpecificLocalMessage',,P.PlayerReplicationInfo,,Self);

         if ( PC != None &&
              default.bScreenFlash0 )
            PC.ClientFlash(0.25, vect(800,400,100));

         if ( C != None )
         {     
            if ( PlaySound0 != None )
               Other.PlaySound(PlaySound0); //Plays a fun sound! Woohoo!!

            C.IsInPain();
         }

         if ( Region.Zone.bSoftKillZ && (Other.Physics != PHYS_Walking) )
            return;

         Other.TakeDamage(DamagePerSec0, None, Location, vect(0,0,0), DamageType0);
      }
   }

   if ( P.GetTeamNum() == 1 && bGetHurtByVolume1 )
   {
      if ( DamagePerSec1 > 0 )
      {
         if ( InPainMessage1 != "" )
            P.ReceiveLocalizedMessage(class'TeamSpecificLocalMessage',,P.PlayerReplicationInfo,,Self);
                    
         if ( PC != None &&
              default.bScreenFlash1 )
            PC.ClientFlash(0.25, vect(800,400,100));
         
         if ( C != None )
         {     
            if ( PlaySound1 != None )
               Other.PlaySound(PlaySound1);

            C.IsInPain();
         }

         if ( Region.Zone.bSoftKillZ && (Other.Physics != PHYS_Walking) )
            return;
         
         Other.TakeDamage(DamagePerSec1, None, Location, vect(0,0,0), DamageType1);
      }
   }
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     bPainCausing=True
     bSwitchColorOnReset=True
     bIsASPractiseRound=True
     MessageColor0=(A=255)
     MessageColor1=(A=255)
     bStatic=False
     bAlwaysRelevant=True
     bSkipActorPropertyReplication=False
}
