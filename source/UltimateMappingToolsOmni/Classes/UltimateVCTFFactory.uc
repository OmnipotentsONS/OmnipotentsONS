//=============================================================================
// UltimateVCTFFactory
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 10.09.2011 20:07:40 in Package: UltimateMappingTools$
//
// Ultimate Factory for VCTF, giving the mapper more control
// over vehicle balancing and the functionality of the vehicle itself.
//=============================================================================
class UltimateVCTFFactory extends SVehicleFactory
    DependsOn(UltimateRadarVehicleLRI) placeable;


// IMPORTANT: The default Event will be triggered when a vehicle is spawned!
var(Events) name   PreSpawnEvent;         // Event to trigger before spawn.



var() bool   bRandomFlip;  // Vehicle may be rotated by the AlternativeRotation.
var() int    AlternativeRotation; /* If bRandomFlip, the Vehicle may be rotated by
                                   * this value in relation to it's original rotation.
                                   * 8192 = 45°; 16384 = 90°; 32768 = 180°; etc..
                                   * Negative values will rotate in the opposite direction.
                                   */

var() bool   bAutoTeam;       // Uses the TeamNum of the closest GameObjective.
var() byte   TeamNum;         // 0= red, 1= blue, 255= neutral / none

var() bool   bSwitchSidesOnReset;   // Automatically adjust variables in this actor to consider switched sides.

var() byte   NotLockedForTeam;      /* This will always lock the Vehicles for the TeamNum that is NOT entered here.
                                      * 255 is default, 0 will always lock this for Blue, 1 always for Red
                                      * (Hack for MinigunTurrets - use this with them!)
                                      */

var() bool   bEnabled;              // Factory is triggered "on" at the beginning

var() bool   bTriggeredSpawn;       /* If True, this factory will immediately spawn a vehicle when being triggered.
                                      * If False, triggering will enable the factory and untriggering will disable it.
                                      */


var() bool   bUniqueVehicle;        /* Factory spawns only a limited number of vehicles,
                                      * there will be no second one when they are destroyed.
                                      * MaxVehicleCount determines the number of vehicles that can be spawned.
                                      */

var() float  PreSpawnTime;          // Time before spawn to trigger PrepSpawn-Event and -Effect.
var() float  RespawnTime;            // How long it takes the vehicle to respawn after destruction.

var() bool   bCrushable;            // Allow spawning over colliding actors.
var() float  RetrySpawnTime;        // Interval to wait if spawn area is blocked.


var() enum EVehicleSelectionType     // Which method should be used to select the vehicle for spawning.
{
    VST_Random,                      // Random from list, equal chances for everyone.
    VST_Probability,                 // Use Probability values of the vehicle, so some vehicles are more likely than others.
    VST_Sequential,                  // Always select the next entry from the list when spawning a new vehicle.
    VST_OnceRandom,                  // Random as above, just that the choice will be used for the whole match.
    VST_OnceProbability              // Use Probablity as above, just that the choice will be used for the whole match.
} VehicleSelectionType;


struct _SpawnedVehicleProperties
{
  var() class<Vehicle>   Vehicle;   // Selected random vehicle class.
  var() int    Health;              // Give the spawned Vehicle a custom Health value. 0 will use the Vehicle's default.
  var() float  SpawnProbability;    // Used with bUseSpawnProbability.
  var() name   VehicleSpawnedEvent;   // Tag to be triggered upon spawning of this particular vehicle (additionally to the one of the factory itself). The vehicle will be the instigator.
  var() name   VehicleDestroyedEvent; // Tag to be triggered upon destruction of the vehicle.
                                       // Vehicle must be a subclass of ONSVehicle for this to happen.

  var() enum    ESpawnSize     // The size of the spawneffect around the vehicle to use.
  {
      SIZE_None,
      SIZE_Scorpion,
      SIZE_Manta,
      SIZE_Raptor,
      SIZE_Hellbender,
      SIZE_Goliath,
      SIZE_Leviathan
  } SpawnEffectSize;

  var() bool   bCanCarryFlag;           // This vehicle can carry the flag.
  var() bool   bEjectDriver;            // Eject driver when vehicle gets destroyed instead of killing him.
  var() bool   bEnterringDoesNotUnlock; // Vehicle is not unlocked when a player enters it.
  var() float  SpawnProtectionTime;     // The vehicle is shielded from any damage for this many seconds after spawn (spawn protection is lift immediately when a driver enters)
  var() bool   bChangeMaxDesireability; // If True, use the MaxDesirability value to tell bots if they should use the vehicle or not.
  var() float  MaxDesireability;        // Default values are: Scorpion - 0.4; Hellbender - 0.5; Raptor, Cicada, Manta, SPMA, Paladin - 0.6; Goliath, Ion Tank - 0.8; Leviathan - 2.0

  var() bool   bTrackVehicleOnRadar;  // The vehicle's location will be shown in realtime on the RadarMap.
  var() bool   bRadarVisibleToDriver; // Should the vehicle be shown on the radar to it's driver?
  var() bool   bRadarNeutralWhenEmpty;// If true, the vehicle is drawn with white team color when it's left.
  var() bool   bRadarHideWhenEmpty;   // If true, the vehicle is not drawn when it's empty.

  var() UltimateRadarVehicleLRI.ERadarVehicleVisibility RadarVehicleVisibility;

  var() float  RadarOwnerUpdateTime; // How many seconds have to pass before the location of vehicle is updated for the owning team.
  var() float  RadarEnemyUpdateTime; // Same as above, just for enemies.
  var() bool   bRadarFadeWithOwnerUpdateTime; // If True, the icon on the radar map will interpolate between opaque and translucent as time passes between location updates on the radar.
  var() bool   bRadarFadeWithEnemyUpdateTime; // If False, the icon will always stay fully opaque.

  var() Material RadarTexture;       // This image will represent the vehicle on the Radar.
                                     // The texture shouldn't have any other colours than white and transparent, otherwise you will get an ugly dark square.
  var() float  RadarTextureScale;    // The image will be scaled by this factor.
  var() int    RadarTextureRotationOffset;
};

var() array<_SpawnedVehicleProperties>  VehicleList;


/*  How to change the appearance of this actor to something you are more used to:
 *  Open this Actor's properties.
 *  Open the Animation Browser. Choose the package that contains the Mesh of your
 *  wished Vehicle, for example ONSVehicle-A. Then choose the Mesh of the Vehicle there.
 *  While having it selected go to 'Display' -> 'mesh' of the Actor and click 'Use'.
 *  Now click on 'DrawType' and select 'DT_Mesh'. You should see it now instead of the car symbol.
 *  if you want, you can also search the Mesh's correct Texture (if it's a custom Vehicle)
 *  and add it in the 'Skins'-table to see it on the vehicle mesh in the editor.
 */




/* Intern */
var    int    RandomArrayNumber;      // For accessing the properties of the individual vehicle
var    int    SequentialArrayNumber;  // Same, but in a sequential order.
var    bool   bInitiallyEnabled;      // Needed for Reset().
var    bool   bPreSpawn; // Neither the vehicle or build effect have been spawned yet
var    Vehicle  LastSpawned;            // The last vehicle that has been spawned.

var   UltimateRadarMap URM;


//=============================================================================
// Initialisation
//=============================================================================
// ============================================================================
// PostBeginPlay
//
// Performs a check to notify the mapper if this actor is useless.
// Eenables the factory if necessary and precaches all the vehicles in the array.
// ============================================================================
event PostBeginPlay()
{
    if (VehicleList.length == 0)
        Log(name $ " - no entries in VehicleList", 'Warning');

    foreach AllActors(class'UltimateRadarMap', URM)
    {
        break;
    }


    VehicleClass = None; // Just to make sure that only the array is used.

    bInitiallyEnabled = bEnabled;

    // Precache of super class will mostly throw errors for this factory, so use this instead.
    VehicleArrayPrecache();
}


// ============================================================================
// Precache functions
//
// Preload necessary textures and effects in cache for quick access.
// ============================================================================
simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'VMParticleTextures.buildEffects.PC_buildBorderNew');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.buildEffects.PC_buildStreaks');
    VehicleArrayPrecache();
}

simulated function VehicleArrayPrecache()
{
    local int i;

    for (i = 0; i < VehicleList.length; i++)
    {
        if (VehicleList[i].Vehicle != None)
            VehicleList[i].Vehicle.static.StaticPrecache(Level);
    }
}


// ============================================================================
// PostNetBeginPlay
//
// Activates the factory, either according to the closest GameObjective or with
// a fixed team number.
// ============================================================================
event PostNetBeginPlay()
{
    local GameObjective O, Best;
    local float BestDist, NewDist;

    if (bAutoTeam)
    {
        if ( !bDeleteMe && !Level.Game.IsA('ONSOnslaughtGame') )
        {
            ForEach AllActors(class'GameObjective',O)
            {
                NewDist = class'UltimateMathAux'.static.VSizeSq(Location - O.Location);
                if ((Best == None) || (NewDist < BestDist))
                {
                    Best = O;
                    BestDist = NewDist;
                }
            }

            if ( Best != None )
                Activate(Best.DefenderTeamIndex);
        }
    }
    else
        Activate(TeamNum);
}


// ============================================================================
// Activate the Factory
// ============================================================================
function Activate(byte T)
{
    TeamNum = T;
    bPreSpawn = True;
    Timer();
}


// ============================================================================
// Activation depending on triggering
// ============================================================================
event Trigger(Actor Other, Pawn EventInstigator)
{
    if (!bTriggeredSpawn)
        bEnabled = True;
    else
    {
        ChooseVehicle();

        // If empty slot was chosen, I consider that bad luck at spawning. :P
        if (VehicleClass == None)
            return;

        SpawnBuildEffect();
        bPreSpawn = False;
        SpawnVehicle();
    }
}

event UnTrigger(Actor Other, Pawn EventInstigator)
{
    if (!bTriggeredSpawn)
        bEnabled = False;
}


// ============================================================================
// Timer
//
// The main function of this actor. It handles when to call which other function.
// ============================================================================
event Timer()
{
    if (VehicleCount < MaxVehicleCount && bEnabled)
    {
        if (bPreSpawn)
        {
            bPreSpawn = False;
            ChooseVehicle(); // Choose the vehicle before the SpawnEffect is activated.
            if (VehicleClass != None)
            {
                TriggerEvent(PreSpawnEvent, self, None);
                SpawnBuildEffect();
                SetTimer(PreSpawnTime, False);
            }
            else // Empty slot in the vehicle array, but still a slot.
            {
                bPreSpawn = True;
                SetTimer(RespawnTime, False); // Wait for the length of a full RespawnTime for another chance.
            }
        }
        else
            SpawnVehicle();
    }
    if (!bEnabled)
        SetTimer(1, False); // Update time to check whether the status of bEnabled has changed.
}


// ============================================================================
// ChooseVehicle
//
// Sets the VehicleClass to a Vehicle from the currently valid array. The class
// can be chosen randomly or sequential. In any case is RandomArrayNumber the
// index of the chosen entry in the array, so that we can find the matching
// properties for this vehicle when it's spawned.
// ============================================================================
function ChooseVehicle()
{
    local float AccumulatedProbability;
    local float RandomSelectionValue;
    local int i;

    if (VehicleList.length > 0)
    {
        if (VehicleSelectionType == VST_Random || VehicleSelectionType == VST_OnceRandom)
            RandomArrayNumber = Rand(VehicleList.length);
        else if (VehicleSelectionType == VST_Sequential)
        {
            RandomArrayNumber = SequentialArrayNumber;
            SequentialArrayNumber++;
            if (SequentialArrayNumber >= VehicleList.length)
                SequentialArrayNumber -= VehicleList.length;
        }
        else // Probability value selection.
        {
            for (i = 0; i < VehicleList.length; i++)
                AccumulatedProbability += VehicleList[i].SpawnProbability;

            RandomSelectionValue = FRand() * AccumulatedProbability;
            AccumulatedProbability = 0;

            for (i = 0; i < VehicleList.length; i++)
            {
                if (RandomSelectionValue >= AccumulatedProbability &&
                    RandomSelectionValue <= AccumulatedProbability + VehicleList[i].SpawnProbability)
                {
                    RandomArrayNumber = i;
                    break;
                }
            }
        }
        VehicleClass = VehicleList[RandomArrayNumber].Vehicle;
        return;
    }
}


// ============================================================================
// SpawnBuildEffect
//
// A lot of unnecessary code - just to give the mapper an intuitive interface
// for choosing the size of the vehicle's spawn effect.
// ============================================================================
function SpawnBuildEffect()
{
    local rotator YawRot;
    local class<Emitter> BuildEffectClass;

    YawRot = Rotation;
    YawRot.Roll = 0;
    YawRot.Pitch = 0;

    if (TeamNum == 255 || TeamNum == 0)
    {
        switch (VehicleList[RandomArrayNumber].SpawnEffectSize)
        {
            case SIZE_Scorpion:
                BuildEffectClass = Class'Onslaught.ONSRVBuildEffectRed';
                break;
            case SIZE_Manta:
                BuildEffectClass = Class'Onslaught.ONSHoverBikeBuildEffectRed';
                break;
            case SIZE_Raptor:
                BuildEffectClass = Class'Onslaught.ONSAttackCraftBuildEffectRed';
                break;
            case SIZE_Hellbender:
                BuildEffectClass = Class'Onslaught.ONSPRVBuildEffectRed';
                break;
            case SIZE_Goliath:
                BuildEffectClass = Class'Onslaught.ONSTankBuildEffectRed';
                break;
            case SIZE_Leviathan:
                BuildEffectClass = Class'OnslaughtFull.ONSMASBuildEffectRed';
                break;
            default:
                BuildEffectClass = None;
                break;
        }
        if (BuildEffectClass != None)
            spawn(BuildEffectClass,,, Location, YawRot);
    }
    else
    {
        switch (VehicleList[RandomArrayNumber].SpawnEffectSize)
        {
            case SIZE_Scorpion:
                BuildEffectClass = Class'Onslaught.ONSRVBuildEffectBlue';
                break;
            case SIZE_Manta:
                BuildEffectClass = Class'Onslaught.ONSHoverBikeBuildEffectBlue';
                break;
            case SIZE_Raptor:
                BuildEffectClass = Class'Onslaught.ONSAttackCraftBuildEffectBlue';
                break;
            case SIZE_Hellbender:
                BuildEffectClass = Class'Onslaught.ONSPRVBuildEffectBlue';
                break;
            case SIZE_Goliath:
                BuildEffectClass = Class'Onslaught.ONSTankBuildEffectBlue';
                break;
            case SIZE_Leviathan:
                BuildEffectClass = Class'OnslaughtFull.ONSMASBuildEffectBlue';
                break;
            default:
                BuildEffectClass = None;
                break;
        }
        if (BuildEffectClass != None)
            spawn(BuildEffectClass,,, Location, YawRot);
    }
}


// ============================================================================
// SpawnVehicle
//
// Spawns the chosen VehicleClass and applies the properties from the matching
// entry in the array. The creation of a LinkedReplicationInfo for the radar is
// also handled here, if necessary.
// If the ChooseVehicle function chose an entry with an empty vehicle class,
// then the Timer is set back to the lenght of a RespawnTime to try it again.
// ============================================================================
function SpawnVehicle()
{
    local bool  bBlocked;
    local Pawn  P;
    local VehicleSpawnProtectionTimer VSPT;
    local UltimateRadarVehicleLRI NewVehicleLRI;
    local rotator  AltRot;
    AltRot.Yaw = AlternativeRotation;

        if (VehicleClass != None)
        {
            foreach CollidingActors(class'Pawn', P, VehicleClass.default.CollisionRadius * 1.25)
            {
                bBlocked = True;
                if (PlayerController(P.Controller) != None)
                    PlayerController(P.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 11);
            }
        } // Big hack.. breaking the scope here has a reason.
          // I don't remember exactly which reason but there is definitely one.

        if (bBlocked && !bCrushable)
            SetTimer(RetrySpawnTime, false); // Try again later.
        else
        {
            /* Spawn it now! */
            if (bRandomFlip && Rand(2) == 1)
                LastSpawned = spawn(VehicleClass,,,Location, Rotation + AltRot);
            else
                LastSpawned = spawn(VehicleClass,,,Location, Rotation);


            /* Set attributes of the spawned vehicle */
            if (LastSpawned != None)
            {
                VehicleCount++;
                LastSpawned.ParentFactory = self;
                LastSpawned.SetTeamNum(TeamNum);
                LastSpawned.bTeamLocked = false; // Unlock neutral vehicles.

                // Apply bTeamLocked, if specified for a team.
                if (NotLockedForTeam != 255)
                    if (LastSpawned.Team != NotLockedForTeam)
                        LastSpawned.bTeamLocked = True;

                if (VehicleList[RandomArrayNumber].Health > 0)
                {
                    LastSpawned.HealthMax = VehicleList[RandomArrayNumber].Health;
                    LastSpawned.Health = VehicleList[RandomArrayNumber].Health;
                }

                if (VehicleList[RandomArrayNumber].bChangeMaxDesireability)
                {
                    LastSpawned.MaxDesireability = VehicleList[RandomArrayNumber].MaxDesireability;
                }

                LastSpawned.bSpawnProtected = (VehicleList[RandomArrayNumber].SpawnProtectionTime != 0);
                if (VehicleList[RandomArrayNumber].SpawnProtectionTime > 0)
                {
                    VSPT = Spawn(class'VehicleSpawnProtectionTimer', LastSpawned);
                    VSPT.SetTimer(VehicleList[RandomArrayNumber].SpawnProtectionTime, False);
                }

                LastSpawned.Event = VehicleList[RandomArrayNumber].VehicleDestroyedEvent;
                LastSpawned.bEnterringUnlocks = !VehicleList[RandomArrayNumber].bEnterringDoesNotUnlock;
                LastSpawned.bEjectDriver = VehicleList[RandomArrayNumber].bEjectDriver;

                TriggerEvent(VehicleList[RandomArrayNumber].VehicleSpawnedEvent, self, LastSpawned);

                // Add vehicle to RadarTrackingSystem.
                if (URM != None && VehicleList[RandomArrayNumber].bTrackVehicleOnRadar)
                {
                    NewVehicleLRI = spawn(class'UltimateRadarVehicleLRI');

                    NewVehicleLRI.TrackedVehicle = LastSpawned;
                    NewVehicleLRI.OldOwnerTeam = LastSpawned.Team;
                    NewVehicleLRI.RadarMaterial = VehicleList[RandomArrayNumber].RadarTexture;
                    NewVehicleLRI.RadarTextureScale = VehicleList[RandomArrayNumber].RadarTextureScale;
                    NewVehicleLRI.RadarTextureRotationOffset = VehicleList[RandomArrayNumber].RadarTextureRotationOffset;
                    NewVehicleLRI.RadarVehicleVisibility = VehicleList[RandomArrayNumber].RadarVehicleVisibility;
                    NewVehicleLRI.bRadarVisibleToDriver = VehicleList[RandomArrayNumber].bRadarVisibleToDriver;
                    NewVehicleLRI.bRadarNeutralWhenEmpty = VehicleList[RandomArrayNumber].bRadarNeutralWhenEmpty;
                    NewVehicleLRI.bRadarHideWhenEmpty = VehicleList[RandomArrayNumber].bRadarHideWhenEmpty;
                    NewVehicleLRI.RadarOwnerUpdateTime = VehicleList[RandomArrayNumber].RadarOwnerUpdateTime;
                    NewVehicleLRI.RadarEnemyUpdateTime = VehicleList[RandomArrayNumber].RadarEnemyUpdateTime;
                    NewVehicleLRI.bRadarFadeWithOwnerUpdateTime = VehicleList[RandomArrayNumber].bRadarFadeWithOwnerUpdateTime;
                    NewVehicleLRI.bRadarFadeWithEnemyUpdateTime = VehicleList[RandomArrayNumber].bRadarFadeWithEnemyUpdateTime;
                    NewVehicleLRI.SetBase(LastSpawned);
                }
            }

            TriggerEvent(Event, self, None);
        }
}


// ============================================================================
// VehicleDestroyed
//
// VehicleCount gets reduced (if wished) and the LinkedReplicationInfo for the
// radar is removed, if one for this vehicle existed.
// ============================================================================
event VehicleDestroyed(Vehicle V)
{
    Super.VehicleDestroyed(V);

    bPreSpawn = True;
    SetTimer(RespawnTime - PreSpawnTime, False);


    if (bUniqueVehicle)
        VehicleCount++; // It was decreased in the super function.
}


// ============================================================================
// Reset
//
// Adjust this actor if the sides are switched in ONS and deletes all remaining
// vehicles on the map.
// ============================================================================
function Reset()
{
    local Vehicle V;

    Super.Reset();

    if (VehicleCount > 0)
    {
        foreach DynamicActors (class 'Vehicle', V)
            if (V.ParentFactory == self)
                V.Destroy();
        if (bUniqueVehicle)
            VehicleCount = 0;
    }

    if (bSwitchSidesOnReset && TeamNum != 255)
    {
        if (TeamNum % 2.0 == 0) // Allows this to also work with other team numbers than 0 and 1.
            TeamNum++;
        else
            TeamNum--;
    }

    if (bSwitchSidesOnReset && NotLockedForTeam != 255)
    {
        if (NotLockedForTeam % 2.0 == 0) // Allows this to also work with other team numbers than 0 and 1.
            NotLockedForTeam++;
        else
            NotLockedForTeam--;
    }

    SequentialArrayNumber = 0;

    bEnabled = bInitiallyEnabled;
}


// ============================================================================
// Default Values
// ============================================================================

defaultproperties
{
     NotLockedForTeam=255
     bEnabled=True
     PreSpawnTime=2.000000
     RetrySpawnTime=1.000000
}
