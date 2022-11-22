//=============================================================================
// VehicleTeleporter v1.0 by KillBait! (10/2/05)
// Email - killbait_uk@hotmail.com
//
// Description
// -----------
//
// A teleport that can be used by players AND vehicles.
//
// I have already tested this on a dedicated (v3339) server and it runs O.K.
//
// Goals
// -----
// The aim was to have a teleport that was usable by both vehicles and players,
// and still used the normal telporter functions, to make it as easy as possible
// for LD's to use, and required no extra work on server admins for them to
// support these new features.
//
// I'm fairly new to coding..so excuse anything that looks like utter newb crap;D
// If your feeling charitable..e-mail me on how it can be done better :)
//
// Usage Restrictions
// ------------------
// You are Free to use this actor in whatever type of Map/Mod/TC you want,
// BUT, please do not rip out/remove the notes and comments. I have learnt
// a lot from looking at other peoples code, and i want to keep it here for
// others to look at. Maybe, even with my newbie coding skills, it will be
// of help to somebody.
//
//  And feel free to tell me if anything in the comments in wrong :D
//
// Credits
// -------
// - ROBO (UT2004ModList) Came up with the original SetPhysics workaround
//
// - Derek "HoMeRS}i{MpSoN" Altamirano (http://www.cyberrock.net) for the
//   hint on the velocity multipler code.
//
// - Steve Polge for the suggestion to widen the reachspec collision, stops
//  bots bailing out just before teleporting, because they could not find
//  a wide enough path.
//
// - UnrealWiki (http://www.UnrealWiki.com) for it's invaluable documentation
//   of some fuctions i've never used before this.
//
// - All other Code/bugs by Me (KillBait!)
//
//=============================================================================

class VehicleTeleporter extends Teleporter
placeable;


var() bool bTeleportVehiclesOnly;
var() bool bGroundVehiclesOnly;
var bool bKeepFlyingUpright;
var int ReachSpecCollHeight;
var int ReachSpecCollRadius;

function PostBeginPlay()
{
local int i;

if (URL ~= "")
 SetCollision(false, false, false); //destination only

if ( !bEnabled )
 FindTriggerActor();

// ----------------------------------------------------------------------------------------------------------
// Workaround for bots ejecting just before teleporting in vehicles. (Thanks to Steve Polge for the answer :)
//
// When paths are built in unrealed, the reachspecs created for each teleport actor seem to use the same
// collision radius/height of the actor they are created from, if a vehicles collision radius/height is
// greater than the reachspecs, the AI thinks the vehicle won't fit.
//
// We need to loop through all the Vehicle Teleporters and increase there reachspec collisions to make sure
// the AI and path finding code thinks they do fit. if you have a vehicle thats larger than 2000 in radius
// or height then you will have to increase the reachspec value to suit - but why have such an insanely
// large vehicle? :)
//
// NOTE
// ----
// This does NOT affect the actual teleport actors touch collision..so it's safe to increase it way beyond
// that
//
// also still included the epic hack to make bots call the SpecialCost() function when try to find a path
// through these ( by making reachspecs between teleporters forced, the SpecialCost() event will be called)
// it is usefull to implement some other options)
// ----------------------------------------------------------------------------------------------------------
for ( i=0; i<PathList.length; i++ )
 if ( VehicleTeleporter(PathList[i].End) != none )
 {
  pathList[i].bForced = true;  // most likely is already True..But just to make sure
  PathList[i].Distance = 2560; // 2560 is the distance set by UnrealED when using forced paths
  PathList[i].CollisionHeight = ReachSpecCollHeight; // hack-o-matic magic :)
  PathList[i].CollisionRadius = ReachSpecCollRadius; // ^^                 ^^
 }

super.PostBeginPlay();
}

// Accept an actor that has teleported in.
simulated function bool Accept( actor Incoming, Actor Source )
{
local rotator newRot, oldRot;
local float mag;
local vector oldDir;
local Controller P;

// Me stuff

local EPhysics oldPhysics;   // Stores physics of vehicle, restored after teleport  (Originaly by ROBO)
local vector oldVel;    // Stores old velocity of incoming vehicle
local bool bIsVehicleTeleporting; // default=False, makes executing vehicle code quicker
local vector ImpulseVelocity;  // used to multiply velocity, for KAddImpulse
local rotator oldDriverRotation; // Stores view rotation of the Driver controlling vehicle
local rotator newDriverRotation; // Stores final result of drivers view rotation after yaw change
local rotator oldPassengerRotation; // Used by changeYaw code to adjust passenger rotation
local rotator newPassengerRotation; // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
local int Num;
local PlayerController PC;

if ( Incoming == none )
 return false;

// Check if destination is blocked, and telefrag the poor souls who block it.
ClearDest(Incoming,Source);

// Is incoming actor a vehicle, sets a bool used to make vehicle code execution quicker
if ( Incoming.IsA('Vehicle') )
 bIsVehicleTeleporting = true;

// is incoming a vehicle, store it's properties that are lost/changed by SetPhysics()
if (bIsVehicleTeleporting)
{
 oldPhysics = Incoming.Physics; // Store old vehicle Physics
 oldVel = Incoming.Velocity;  // Store old vehicle velocity, lost after Physics set to PHYS_None
 // If incoming vehicle has a driver, store the view rotation to restore later
 if ( Pawn(Incoming).Controller != none )
  oldDriverRotation = Pawn(Incoming).Controller.Rotation; // store the drivers view rotation

 Incoming.SetPhysics(PHYS_none); // Set vehicles physics to none, stops native karma code messing up teleport (Originaly by ROBO)
}

Disable('Touch');
newRot = Incoming.Rotation;
if (bChangesYaw)
{
 // calculate the player/vehicles new outgoing yaw rotation..
 // does NOT affect the vehicles controller/passengers (is handled later on)
 oldRot = Incoming.Rotation;
 newRot.Yaw = Rotation.Yaw;
 if ( Source != none )
  newRot.Yaw += (32768 + Incoming.Rotation.Yaw - Source.Rotation.Yaw);
}

if ( Pawn(Incoming) != none )
{
 //tell enemies about teleport
 if ( Role == ROLE_Authority )
  for ( P=Level.ControllerList; P!=none; P=P.NextController )
   if ( P.Enemy == Incoming )
    P.LineOfSightTo(Incoming);

 if ( !Pawn(Incoming).SetLocation(Location) )
 {
  log(self$" Teleport failed for "$Incoming);

  // Restore the vehicles values after failed teleport
  if (bIsVehicleTeleporting)
  {
   Incoming.SetPhysics(oldPhysics);     // Restore Old physics
   ImpulseVelocity = oldvel * ( 100 * ONSVehicle(Incoming).VehicleMass);
   Incoming.KAddImpulse(ImpulseVelocity, vect(0,0,0)); //  apply force at center of gravity
  }

  return false;
 }

 if ( (Role == ROLE_Authority)
  || (Level.TimeSeconds - LastFired > 0.5) )
 {
  newRot.Roll = 0;
  Pawn(Incoming).SetRotation(newRot);
  Pawn(Incoming).SetViewRotation(newRot);
  Pawn(Incoming).ClientSetRotation(newRot);
  LastFired = Level.TimeSeconds;
 }

 // Vehicle Passengers never trigger this function, also has side effect of reseting the drivers rotation
 if ( Pawn(Incoming).Controller != none )
 {
  Pawn(Incoming).Controller.MoveTimer = -1.0;
  Pawn(Incoming).Anchor = self;
  Pawn(Incoming).SetMoveTarget(self);
 }


 Incoming.PlayTeleportEffect(false, true);

}
else
{
 if ( !Incoming.SetLocation(Location) )
 {
  Enable('Touch');

  log(self$" Teleport failed for "$Incoming);

  // Incoming is not a subclass of pawn, so probably is not a vehicle
  // ingore any reseting of vehicle values

  return false;
 }
 if ( bChangesYaw )
  Incoming.SetRotation(newRot);
}

Enable('Touch');

// Multiply vehicles old velocity for KAddImpulse now.. so can be overiden by bChangesVelocity if enabled
if (bIsVehicleTeleporting)
 // Calculate the impulse needed to reproduce the incoming velocity
 // To the player it looks like we never stopped;)
 ImpulseVelocity = oldvel * ( 100 * ONSVehicle(Incoming).VehicleMass);

// Set the vehicle/pawns velocity to LD specified value if bChangesVelocity=True
if (bChangesVelocity)
{
 if (bIsVehicleTeleporting)
  ImpulseVelocity = TargetVelocity * ( 100 * ONSVehicle(Incoming).VehicleMass);
 else
  Incoming.Velocity = TargetVelocity;
}
else
{
 // Change the vehicle drivers view rotation if LD specified it
 if ( bChangesYaw )
 {
  // Check if incoming is a Vehicle, or on foot player
  if (bIsVehicleTeleporting)
  {
   // Vehicle is already rotated to correct outgoing direction..but the velocity still points the
   // way we entered, change it now
   oldRot.Pitch = 0;
            oldDir = vector(oldRot);
   mag = ImpulseVelocity Dot oldDir;
   ImpulseVelocity = ImpulseVelocity - mag * oldDir + mag * vector(newRot);

   // If there was a driver for vehicle?, apply the ChangeYaw and set the drivers rotation

   if  (Pawn(Incoming).Controller != none)
   {
    newDriverRotation = oldDriverRotation; // copy to temp variable..so we can work on it

    // If the vehicle doesnt use PCRelativeFPRotation, we need to adjust the drivers yaw
    // in first + third person view
    //
    // If the vehicle DOES use PCRelativeFPRotation, we need only to adjust the yaw
    // rotation in third person view only, in first person we just restore the original
    // stored rotation

    PC = PlayerController(Pawn(Incoming).Controller);
    if ( PC !=none )
    {
     if ( (PC.bBehindview == true) || (ONSvehicle(Incoming).bPCRelativeFPRotation == false) )
     {
      //Log("changing Yaw rotation of driver for"@ONSVehicle(Incoming));
      newDriverRotation.Yaw = Rotation.Yaw;
      if ( Source != none )
       newDriverRotation.Yaw += (32768 + oldDriverRotation.Yaw - Source.Rotation.Yaw);
     }
    }

    // Set the new rotation now
    Pawn(Incoming).Controller.SetRotation(newDriverRotation);
//     Pawn(Incoming).SetViewRotation(newDriverRotation);
    // If running on dedicated server, force client to update, or it will look like it failed
    if ( Level.NetMode == NM_DedicatedServer)
     Pawn(Incoming).Controller.ClientSetRotation(newDriverRotation);
   }

   // Passangers also need there yaw rotation adjusted
   for(Num=0;Num<ONSVehicle(Incoming).WeaponPawns.length;Num++)
   {
    if ( ONSVehicle(Incoming).WeaponPawns[Num].Driver != none)
    {
     //Log("changing Yaw rotation for passenger slot"@Num);
     oldPassengerRotation = ONSVehicle(Incoming).WeaponPawns[Num].Rotation;
     newPassengerRotation = oldPassengerRotation;
     newPassengerRotation.Yaw = Rotation.Yaw;
     if ( Source != none )
      newPassengerRotation.Yaw += (32768 + oldPassengerRotation.Yaw - Source.Rotation.Yaw);
     ONSVehicle(Incoming).WeaponPawns[Num].SetRotation(newPassengerRotation);
     // If running on dedicated server, force client to update, or it will look like it failed
     if ( Level.NetMode == NM_DedicatedServer)
      ONSVehicle(Incoming).WeaponPawns[Num].Controller.ClientSetRotation(newPassengerRotation);
    }
   }
  }
  else
  {
   // Incoming actor isnt a vehicle..change it's velocity using default teleporter code.
   if ( Incoming.Physics == PHYS_Walking )
    OldRot.Pitch = 0;
   oldDir = vector(OldRot);
   mag = Incoming.Velocity Dot oldDir;
   Incoming.Velocity = Incoming.Velocity - mag * oldDir + mag * vector(Incoming.Rotation);
  }
 }

 // Reverse the velocity of X,Y,Z if needed

 if ( bReversesX )
  if (bIsVehicleTeleporting)
   ImpulseVelocity.X *= -1.0;
  else
   Incoming.Velocity.X *= -1.0;
 if ( bReversesY )
  if (bIsVehicleTeleporting)
   ImpulseVelocity.Y *= -1.0;
  else
   Incoming.Velocity.Y *= -1.0;
 if ( bReversesZ )
  if (bIsVehicleTeleporting)
   ImpulseVelocity.Z *= -1.0;
  else
   Incoming.Velocity.Z *= -1.0;
}

// check if bChangeYaw was not needed
if ( !bChangesYaw )
{
 // we still need to restore drivers view rotation as it was reset earlier
 if ( bIsVehicleTeleporting)
 {
  if ( Pawn(Incoming).Controller != none )
  {
   Pawn(Incoming).Controller.SetRotation(oldDriverRotation);
   Pawn(Incoming).SetViewRotation(oldDriverRotation);
   if ( Level.NetMode == NM_DedicatedServer)
    Pawn(Incoming).Controller.ClientSetRotation(oldDriverRotation);
  }
 }
}

// Restore old vehicle physics and apply a KAddImpulse to hide the fact it's velocity
// was lost during the teleport

if (bIsVehicleTeleporting)
{
 Incoming.SetPhysics(oldPhysics); // Restore Old physics of vehicle (original by ROBO)

 //======================================================================================
 // UGLY HACK ALAERT 1 !!!
 // -------------------
 // WTF.. for some reason setting the physics to none and back again resets bKStayUpright
 // to False and leaves all the other karma values intact!!
 //
 // All the epic air vehicles are unstable and unflyable with bKStayUpright false.
 //======================================================================================

 if ( bKeepFlyingUpright ) // should only be false if REARLY needed.
 {
  if ( Incoming.IsA('ONSChopperCraft') || Incoming.IsA('ONSHoverCraft') || Incoming.IsA('ONSPlaneCraft'))
  {
   // Log("ONS flying vehicle"@Incoming@"detected, it's bKStayUpright being set to True");
   Incoming.KSetStayUpright( true,True);
  }
 }
 Incoming.KAddImpulse(ImpulseVelocity, vect(0,0,0)); // apply impulse at centre of gravity
}

return true;
}

//-----------------------------------------------------------------------------
// Teleporter functions.

event Touch(Actor Other)
{
if ( !bEnabled || (Other == none) )
 return;

//============================================================================
// UGLY HACK ALERT 2 !!!
// ---------------------
// Orig code was - If ((Other.bCanTeleport) && Other.PreTeleport(Self)==false)
//
// Vehicle pawns have bCanTeleport=False by default, as you cannot change this
// due to LD's having to use factories to place vehicles in map, and not
// having direct access to the vehicle pawns themselves.
//
// Note
// ----
// No checks at all has the fun (but not intended) effect of everything being
// teleported.. weaponfire, projectiles + everything.
//
// Fire an avril and teleport it to the other end of map, it was intereseting
// too see it happen :)
//============================================================================

// check if non vehicles can use this teleporter
if ( (self.bTeleportVehiclesOnly) && (!Other.IsA('vehicle')) )
 return;

// check if only ground based vehicles can use this teleport
if ( Vehicle(Other) != none)
 if ( (self.bGroundVehiclesOnly) && (Vehicle(other).bCanFly) )
  return;

if( (Other.bCanTeleport || Other.IsA('vehicle')) && Other.PreTeleport(self)==false )
{
 PendingTouch = Other.PendingTouch;
 Other.PendingTouch = self;
}
}


// Teleporter was touched by an actor.
simulated function PostTouch( actor Other )
{
local VehicleTeleporter D,Dest[16];
local int i;

if( (InStr( URL, "/" ) >= 0) || (InStr( URL, "#" ) >= 0) )
{
 // Teleport to a level on the net.

 if( (Role == ROLE_Authority) && (Pawn(Other) != none)
  && Pawn(Other).IsHumanControlled() )
  Level.Game.SendPlayer(PlayerController(Pawn(Other).Controller), URL);
}
else
{
 // Teleport to a random teleporter in this local level, if more than one pick random.

 foreach AllActors( class 'VehicleTeleporter', D )
  if( string(D.tag)~=URL && D!=self )
  {
   Dest[i] = D;
   i++;
   if ( i > arraycount(Dest) )
    break;
  }

 i = rand(i);
 if( Dest[i] != none )
 {
  // Teleport the actor into the other teleporter.
  if ( Other.IsA('Pawn') )
   Other.PlayTeleportEffect(false, true);
  Dest[i].Accept( Other, self );
  if ( Pawn(Other) != none )
   TriggerEvent(event, self, Pawn(Other));
 }
}
}

/* SpecialHandling is called by the navigation code when the next path has been found.
It gives that path an opportunity to modify the result based on any special considerations
*/

function Actor SpecialHandling(Pawn Other)
{
local vector Dist2D;

if ( bEnabled && (VehicleTeleporter(Other.Controller.RouteCache[1]) != none)
 && (string(Other.Controller.RouteCache[1].tag)~=URL) )
{
 if ( Abs(Location.Z - Other.Location.Z) < CollisionHeight + Other.CollisionHeight )
 {
  Dist2D = Location - Other.Location;
  Dist2D.Z = 0;
  if ( VSize(Dist2D) < CollisionRadius + Other.CollisionRadius )
   PostTouch(Other);
 }
 return self;
}

if (TriggerActor == none)
{
 FindTriggerActor();
 if (TriggerActor == none)
  return none;
}

if ( (TriggerActor2 != none)
 && (VSize(TriggerActor2.Location - Other.Location) < VSize(TriggerActor.Location - Other.Location)) )
 return TriggerActor2;
return TriggerActor;
}

// SpecialCost() is called by path finding code
//
// e.g.
// We can use this event to stop bots finding a on foot path through it
// if the LD specified it's for vehicles only

event int SpecialCost(Pawn Other, ReachSpec Path)
{
 // can bots use this VehicleTeleporter if they on foot?
if ( ( Vehicle(Other) == none ) && ( self.bTeleportVehiclesOnly == true ) )
 return 10000000;

// can bots use this VehicleTeleporter depending on what type of vehicle they in
if ( Vehicle(Other) != none )
 if ( (Vehicle(Other).bCanFly == true ) && bGroundVehiclesOnly == true )
  return 10000000;

return 0;
}

// ----------------------------------------------------------------------------
// CheckDest() - checks the destination teleport for anything blocking it,
//
// Vehicles dont use the EncroachOn() function so , we have to check the
// destinations manually and telefrag them.. A pawn encroaching on a pawn
// is still handled properly by the xPawn code.
//
// So....if the incoming pawn is a vehicle or the pawn blocking the destination
// is a vehicle we have to telefrag them manually.
//
// I hate working around stuff like this :(
// ----------------------------------------------------------------------------

function ClearDest(actor Incoming, Actor Source)
{
local int CheckDistance;
local Pawn BlockingPawn;

// set the radius to check for colliding actors
// If incoming is a vehcile, use it's radius, otherwise use the vehicleteleport's default radius.
if ( Incoming.IsA('Vehicle') )
 CheckDistance = Incoming.default.CollisionRadius * 2;
else
 Checkdistance = self.collisionRadius;

// Check for anything blocking the destination.
foreach CollidingActors(class'Pawn', BlockingPawn, CheckDistance,self.location) // is self.location rearly needed?
{
 if ( BlockingPawn.IsA('Vehicle') )
 {
  // Just using BlockingPawn.Died() on a vehicle makes it still spawn the destruction effect
  // You can still be killed by the dead vehicle explosion/mesh. :(
  //
  // Set the blocking vehicles properties so it wont hurt the pawn that telefraged it :/

  ONSVehicle(Blockingpawn).DisintegrationHealth = 0; // will always cause it to disintergate
  ONSVehicle(Blockingpawn).ExplosionDamage = 0;  // dont cause any damage to anything near the explosion
  ONSVehicle(Blockingpawn).ExplosionRadius = 0;  // Just to make double sure no damage is caused
  ONSVehicle(Blockingpawn).ExplosionMomentum = 0;  // dont apply any force to anything near the explosion

  // even after settings the vehicles destruction properties above.. the outgoing actor will still
  // receive a non damaging kick from the explosion of the blocking vehicle..
  //
  // also stops a possible "DareDevil" level being awarded if actor is kicked enough distance

  ONSVehicle(Blockingpawn).SetCollision(false, false, false);

  if ( Pawn(Incoming).Controller != none )
   Blockingpawn.Died(Pawn(Incoming).Controller, class'DamTypeTelefragged', Location); // kill vehicle
  else
   BlockingPawn.KilledBy(Pawn(Incoming));
 }
 else
 {
  // Blocking actor is not a vehicle
  // If the incoming actor is a vehicle, kill the blocker.
  // If blocker and incoming are pawns, ignore it, let the xpawn EncroachOn() code do it's own telefrag thing
  if ( Incoming.IsA('Vehicle') )
  {
   if ( Pawn(Incoming).Controller != none )
    Blockingpawn.Died(Pawn(Incoming).Controller, class'DamTypeTelefragged', Location); // kill vehicle
   else
    BlockingPawn.KilledBy(Pawn(Incoming));
  }
 }
}
}

defaultproperties
{
}
