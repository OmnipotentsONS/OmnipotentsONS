//=============================================================================
// UltimateONSFactory
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 12.10.2011 23:59:59 in Package: UltimateMappingTools$
//
// Ultimate Factory for ONS, giving the mapper more control
// over vehicle balancing and the functionality of the vehicle itself.
//=============================================================================
class UltimateONSFactory extends ONSVehicleFactory
    DependsOn(UltimateRadarVehicleLRI) placeable;


/* NOTE:
 * "Red" and "Blue" can be considered to have a static location.
 * That means that the arrays refer always to the same teamside, I'll give you an example:
 * Red has a Tank in their array, Blue has a Raptor instead. In the first round
 * Red build the Node and get the Tank. If Blue would build it, then they would
 * get the Raptor.
 * Now the sides switch due to the setting of the server. Red is now at the position
 * of the other Core. If Blue would now build the Node for this factory, they would
 * not get the Raptor as one could think, but the Tank instead, although it's in the Red
 * array. Red would get the Raptor now, if they'd build the Node.
 *
 * So just forget about the Reset and switched teams when building your map, most
 * of that stuff will be handled by my actors.
 */

// IMPORTANT: The default Event will be triggered when a vehicle is spawned!
var(Events) name   PreSpawnEvent;         // Event to trigger before spawn. Not activated when the vehicle was trigger-spawned.

var(ONSVehicleFactory) int BlueTeamRotation; /* If bReverseBlueTeamDirection,
                                              * the Vehicle will not turn by 180 degrees but by this value.
                                              * 8192 = 45°; 16384 = 90°; 32768 = 180°; etc..
                                              * Negative values will rotate in the opposite direction.
                                              */

var() byte   StaticTeamNum;         // 0= red, 1= blue, 255= neutral / none
                                     // TeamNums are switched automatically on Reset, if necessary

var() bool   bUseStaticTeams;       // Factory works only for one team
var() bool   bIndependentFactory;   // Powernode has no influence on the factory's activity or teamnumber

var() bool   bRandomFlip;           // Neutral vehicles may face in BlueTeamRotation.

var() byte   NotLockedForTeam;      /* This will always lock the Vehicles for the TeamNum that is NOT entered here.
                                      * 255 is normal ONS, 0 will always lock this for Blue, 1 always for Red
                                      * (Hack for MinigunTurrets - use this with them!)
                                      */

var() bool   bTriggeredSpawn;       /* If True, this factory will immediately spawn a vehicle when being triggered.
                                      * If False, triggering will enable the factory and untriggering will disable it.
                                      */
var() bool   bEnabled;              // Factory is triggered "on" at the beginning
var() bool   bUniqueVehicle;        /* Factory spawns only a limited number of vehicles,
                                      * there will be no second one when they are destroyed.
                                      * MaxVehicleCount determines the number of vehicles that can be spawned.
                                      */

var() float  PreSpawnTime;          // Time before spawn to trigger PrepSpawn-Event and -Effect.

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


struct SpawnedVehicleProperties
{
  var() class<Vehicle>   Vehicle;   // The vehicle that is spawned with this entry.
  var() int    Health;              // Give the spawned Vehicle a custom Health value. 0 will use the Vehicle's default.
  var() float  SpawnProbability;    // Used with bUseSpawnProbability.
  var() name   VehicleSpawnedEvent;   // Tag to be triggered upon spawning of this particular vehicle (additionally to the one of the factory itself). The vehicle will be the instigator.
  var() name   VehicleDestroyedEvent; // Tag to be triggered upon destruction of the vehicle.
                                       // Vehicle must be a subclass of ONSVehicle for this to happen.

  var() enum    ESpawnSize           // The size of the spawneffect around the vehicle to use.
  {
      SIZE_None,
      SIZE_Scorpion,
      SIZE_Manta,
      SIZE_Raptor,
      SIZE_Hellbender,
      SIZE_Goliath,
      SIZE_Leviathan
  } SpawnEffectSize;

  var() bool   bEjectDriver;            // Eject driver when vehicle gets destroyed instead of killing him.
  var() bool   bEnterringDoesNotUnlock; // Vehicle is not unlocked when a player enters it.
  var() float  SpawnProtectionTime;     // The vehicle is shielded from any damage for this many seconds after spawn (spawn protection is lift immediately when a driver enters)
  var() bool   bChangeMaxDesireability; // If True, use the MaxDesirability a value to tell bots if they should use the vehicle or not.
  var() float  MaxDesireability;        // Default values are: Scorpion - 0.4; Hellbender - 0.5; Raptor, Cicada, Manta, SPMA, Paladin - 0.6; Goliath, Ion Tank - 0.8; Leviathan - 2.0

  var() bool   bTrackVehicleOnRadar; // The vehicle's location will be shown in realtime on the RadarMap.
  var() bool   bRadarVisibleToDriver;// Should the vehicle be shown on the radar to it's driver?
  var() bool   bRadarNeutralWhenEmpty;// If true, the vehicle is drawn with white team color when it's left.
  var() bool   bRadarHideWhenEmpty;       // If true, the vehicle is not drawn when it's empty.

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

var() array<SpawnedVehicleProperties>  VehicleListRed;   // List for random vehicle spawn if red or neutral has the factory
var() array<SpawnedVehicleProperties>  VehicleListBlue;  // List for random vehicle spawn if blue has the factory


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
var    int    SequentialArrayNumberRed;  // Same, but in a sequential order.
var    int    SequentialArrayNumberBlue; // Need seperate ones for Red and Blue.
var    bool   bInitiallyEnabled;      // Needed for Reset().

var   UltimateONSRadarHUDRI RadarRI; // Takes care of spawning the HUDOverlay on the client.


//=============================================================================
// Initialisation
//=============================================================================
// ============================================================================
// PostBeginPlay
//
// Performs a check to notify the mapper if this actor is useless.
// References the one and only VehicleLRIMaster in the map. If it doesn't exist
// yet, a new one is spawned.
// Sets some inherited variables to the correct values, enables the
// factory if necessary and precaches all the vehicles in the array.
// ============================================================================
event PostBeginPlay()
{
    if (VehicleListRed.length == 0 && VehicleListBlue.length == 0)
        Log(name $ " - no entries in both VehicleLists", 'Warning');


    // Search for LRIMasters and spawn one if it doesn't exist yet.
    foreach DynamicActors(class'UltimateONSRadarHUDRI', RadarRI)
    {
        break;
    }
    if (RadarRI == None)
        RadarRI = Spawn(class'UltimateONSRadarHUDRI');


    VehicleClass = None; // Just to make sure that only the arrays are used.
    PreSpawnEffectTime = PreSpawnTime; // Use the correct value in the superclass' function.

    bInitiallyEnabled = bEnabled;

    if (Level.NetMode != NM_DedicatedServer)
        // Precache of super class will mostly throw errors for this factory, so use this instead.
        VehicleArrayPrecache();
}


// ============================================================================
// Precache functions
//
// Basically the same as in the subclass, just modified to take all vehicle classes
// in the arrays into account.
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

    for (i = 0; i < VehicleListRed.length; i++)
    {
        if (VehicleListRed[i].Vehicle != None)
            VehicleListRed[i].Vehicle.static.StaticPrecache(Level);
    }

    for (i = 0; i < VehicleListBlue.length; i++)
    {
        if (VehicleListBlue[i].Vehicle != None)
            VehicleListBlue[i].Vehicle.static.StaticPrecache(Level);
    }
}


// ============================================================================
// PostNetBeginPlay
//
// Activates the factory, either according to the closest ONSPowerNode (uses
// super function) or with a fixed team number, making the factory effectively
// independent from a PowerNode.
// ============================================================================
event PostNetBeginPlay()
{
    if (!bIndependentFactory)
        Super.PostNetBeginPlay(); // DefenderTeamIndex of closest node is delivered to the Activate-function.
    else
        Activate(StaticTeamNum);
}


// ============================================================================
// SetInitialState
//
// Remove this factory from the PowerCore's dynamic 'CloseActors'-array.
// By doing this, destroying the closest Node will no longer disable this factory.
// Executing at this point makes sure that the PostNetBeginPlay() of the
// PowerCore has been called already.
// ============================================================================
event SetInitialState()
{
    local ONSPowerCore O;
    local int i;

    if (bIndependentFactory)
    {
        foreach DynamicActors(Class 'ONSPowerCore', O)
        {
            for (i = 0; i < O.CloseActors.length; i++)
            {
                if (O.CloseActors[i] == Self)
                    O.CloseActors.Remove(i, 1);
            }
        }
    }

    super.SetInitialState(); // To set bScriptInitialized to True.
}

// ============================================================================
// Activation depending on close Nodes
// ============================================================================
function Activate(byte T)
{
    // bUseStaticTeams will make the vehicle only appear, when the matching team has the node.
    // StaticTeamNum = 255 makes only sense with bIndependentFactory, so use the node's teams instead.
    if ((bUseStaticTeams && (StaticTeamNum == T || StaticTeamNum == 255)) || !bUseStaticTeams)
        Super.Activate(T);
}

function Deactivate()
{
    if (!bIndependentFactory)
        Super.Deactivate();
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
    if (bActive && Level.Game.bAllowVehicles && VehicleCount < MaxVehicleCount && bEnabled)
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
        SetTimer(1, True); // Update time to check whether the status of bEnabled has changed.
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

    if (bUseStaticTeams || bIndependentFactory)
        TeamNum = StaticTeamNum;

    if (VehicleListRed.length > 0 && (TeamNum == 255 ||
        (!SidesAreSwitched() && TeamNum == 0) || (SidesAreSwitched() && TeamNum == 1)))
    {
        if (VehicleSelectionType == VST_Random || VehicleSelectionType == VST_OnceRandom)
            RandomArrayNumber = Rand(VehicleListRed.length);
        else if (VehicleSelectionType == VST_Sequential)
        {
            RandomArrayNumber = SequentialArrayNumberRed;
            SequentialArrayNumberRed++;
            if (SequentialArrayNumberRed >= VehicleListRed.length)
                SequentialArrayNumberRed -= VehicleListRed.length;
        }
        else // Probability value selection.
        {
            for (i = 0; i < VehicleListRed.length; i++)
                AccumulatedProbability += VehicleListRed[i].SpawnProbability;

            RandomSelectionValue = FRand() * AccumulatedProbability;
            AccumulatedProbability = 0;

            for (i = 0; i < VehicleListRed.length; i++)
            {
                if (RandomSelectionValue >= AccumulatedProbability &&
                    RandomSelectionValue <= AccumulatedProbability + VehicleListRed[i].SpawnProbability)
                {
                    RandomArrayNumber = i;
                    break;
                }
            }
        }
        VehicleClass = VehicleListRed[RandomArrayNumber].Vehicle;
        return;
    }
    else if (VehicleListBlue.length > 0 &&
        ((!SidesAreSwitched() && TeamNum == 1) || (SidesAreSwitched() && TeamNum == 0)))
    {
        if (VehicleSelectionType == VST_Random || VehicleSelectionType == VST_OnceRandom)
            RandomArrayNumber = Rand(VehicleListBlue.length);
        else if (VehicleSelectionType == VST_Sequential)
        {
            RandomArrayNumber = SequentialArrayNumberBlue;
            SequentialArrayNumberBlue++;
            if (SequentialArrayNumberBlue >= VehicleListBlue.length)
                SequentialArrayNumberBlue -= VehicleListBlue.length;
        }
        else // Probability value selection.
        {
            for (i = 0; i < VehicleListBlue.length; i++)
                AccumulatedProbability += VehicleListBlue[i].SpawnProbability;

            RandomSelectionValue = FRand() * AccumulatedProbability;
            AccumulatedProbability = 0;

            for (i = 0; i < VehicleListBlue.length; i++)
            {
                if (RandomSelectionValue >= AccumulatedProbability &&
                    RandomSelectionValue <= AccumulatedProbability + VehicleListBlue[i].SpawnProbability)
                {
                    RandomArrayNumber = i;
                    break;
                }
            }
        }
        VehicleClass = VehicleListBlue[RandomArrayNumber].Vehicle;
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

    YawRot = Rotation;
    YawRot.Roll = 0;
    YawRot.Pitch = 0;

    if (TeamNum == 255 || (!SidesAreSwitched() && TeamNum == 0) || (SidesAreSwitched() && TeamNum == 1))
    {
        switch (VehicleListRed[RandomArrayNumber].SpawnEffectSize)
        {
            case SIZE_Scorpion:
                RedBuildEffectClass = Class'Onslaught.ONSRVBuildEffectRed';
                break;
            case SIZE_Manta:
                RedBuildEffectClass = Class'Onslaught.ONSHoverBikeBuildEffectRed';
                break;
            case SIZE_Raptor:
                RedBuildEffectClass = Class'Onslaught.ONSAttackCraftBuildEffectRed';
                break;
            case SIZE_Hellbender:
                RedBuildEffectClass = Class'Onslaught.ONSPRVBuildEffectRed';
                break;
            case SIZE_Goliath:
                RedBuildEffectClass = Class'Onslaught.ONSTankBuildEffectRed';
                break;
            case SIZE_Leviathan:
                RedBuildEffectClass = Class'OnslaughtFull.ONSMASBuildEffectRed';
                break;
            default:
                RedBuildEffectClass = None;
                break;
        }
        if (RedBuildEffectClass != None)
            BuildEffect = spawn(RedBuildEffectClass,,, Location, YawRot);
    }

    else
    {
        switch (VehicleListBlue[RandomArrayNumber].SpawnEffectSize)
        {
            case SIZE_Scorpion:
                BlueBuildEffectClass = Class'Onslaught.ONSRVBuildEffectBlue';
                break;
            case SIZE_Manta:
                BlueBuildEffectClass = Class'Onslaught.ONSHoverBikeBuildEffectBlue';
                break;
            case SIZE_Raptor:
                BlueBuildEffectClass = Class'Onslaught.ONSAttackCraftBuildEffectBlue';
                break;
            case SIZE_Hellbender:
                BlueBuildEffectClass = Class'Onslaught.ONSPRVBuildEffectBlue';
                break;
            case SIZE_Goliath:
                BlueBuildEffectClass = Class'Onslaught.ONSTankBuildEffectBlue';
                break;
            case SIZE_Leviathan:
                BlueBuildEffectClass = Class'OnslaughtFull.ONSMASBuildEffectBlue';
                break;
            default:
                BlueBuildEffectClass = None;
                break;
        }
        if (BlueBuildEffectClass != None)
            BuildEffect = spawn(BlueBuildEffectClass,,, Location, YawRot);
    }
}


// ============================================================================
// SpawnVehicle
//
// Spawns the chosen VehicleClass and applies the properties from the matching
// entry in the array. The creation of a LinkedReplicationInfo for the radar is
// also handled here, if necessary.
// If the ChooseVehicle function chose an entry with an empty vehicle class,
// then the Timer is set back to the length of a RespawnTime to try it again.
// ============================================================================
function SpawnVehicle()
{
    local bool  bBlocked;
    local Pawn  P;
    local VehicleSpawnProtectionTimer VSPT;
    local UltimateRadarVehicleLRI NewVehicleLRI;
    local rotator  BlueRot;
    BlueRot.Yaw = BlueTeamRotation;

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
            if (TeamNum == 255)
            {
                if (bRandomFlip && Rand(2) == 1)
                    LastSpawned = spawn(VehicleClass,,,Location, Rotation + BlueRot);
                else
                    LastSpawned = spawn(VehicleClass,,,Location, Rotation);

               // Set below after spawn - pOOty
               // LastSpawned.bTeamLocked = false; // Unlock neutral vehicles.
            }
            else
            {
                // When does the spawning vehicle face the other direction?
                if (bReverseBlueTeamDirection && ((TeamNum == 1 && !SidesAreSwitched()) ||
                   (TeamNum == 0 && SidesAreSwitched())))
                    LastSpawned = spawn(VehicleClass,,, Location, Rotation + BlueRot);
                else
                    LastSpawned = spawn(VehicleClass,,, Location, Rotation);
            }

            /* Set attributes of the spawned vehicle */
            if (LastSpawned != None)
            {
                VehicleCount++;
                LastSpawned.ParentFactory = self;
                LastSpawned.SetTeamNum(TeamNum);
                // Crusha No, No, make the Default True (always locked to the team unless otherwise coded) - pooty
                LastSpawned.bTeamLocked = True;

                // Apply bTeamLocked, if specified for a team.
                if (NotLockedForTeam != 255)
                    if (LastSpawned.Team == NotLockedForTeam)
                        LastSpawned.bTeamLocked = False;

                if (LastSpawned.Team == 255 || ((!SidesAreSwitched() && LastSpawned.Team == 0) ||
                    (SidesAreSwitched() && LastSpawned.Team == 1)))
                {
                    if (VehicleListRed[RandomArrayNumber].Health > 0)
                    {
                        LastSpawned.HealthMax = VehicleListRed[RandomArrayNumber].Health;
                        LastSpawned.Health = VehicleListRed[RandomArrayNumber].Health;
                    }

                    if (VehicleListRed[RandomArrayNumber].bChangeMaxDesireability)
                    {
                        LastSpawned.MaxDesireability = VehicleListRed[RandomArrayNumber].MaxDesireability;
                    }

                    LastSpawned.bSpawnProtected = (VehicleListRed[RandomArrayNumber].SpawnProtectionTime != 0);
                    if (VehicleListRed[RandomArrayNumber].SpawnProtectionTime > 0)
                    {
                        VSPT = Spawn(class'VehicleSpawnProtectionTimer', LastSpawned);
                        VSPT.SetTimer(VehicleListRed[RandomArrayNumber].SpawnProtectionTime, False);
                    }

                    LastSpawned.Event = VehicleListRed[RandomArrayNumber].VehicleDestroyedEvent;
                    LastSpawned.bEnterringUnlocks = !VehicleListRed[RandomArrayNumber].bEnterringDoesNotUnlock;
                    LastSpawned.bEjectDriver = VehicleListRed[RandomArrayNumber].bEjectDriver;

                    TriggerEvent(VehicleListRed[RandomArrayNumber].VehicleSpawnedEvent, self, LastSpawned);

                    // Add vehicle to Radar Tracking System.
                    if (VehicleListRed[RandomArrayNumber].bTrackVehicleOnRadar && !RadarRI.bRadarMutatorEnabled)
                    {
                        NewVehicleLRI = spawn(class'UltimateRadarVehicleLRI');

                        NewVehicleLRI.TrackedVehicle = LastSpawned;
                        NewVehicleLRI.OldOwnerTeam = LastSpawned.Team;
                        NewVehicleLRI.RadarMaterial = VehicleListRed[RandomArrayNumber].RadarTexture;
                        NewVehicleLRI.RadarTextureScale = VehicleListRed[RandomArrayNumber].RadarTextureScale;
                        NewVehicleLRI.RadarTextureRotationOffset = VehicleListRed[RandomArrayNumber].RadarTextureRotationOffset;
                        NewVehicleLRI.RadarVehicleVisibility = VehicleListRed[RandomArrayNumber].RadarVehicleVisibility;
                        NewVehicleLRI.bRadarVisibleToDriver = VehicleListRed[RandomArrayNumber].bRadarVisibleToDriver;
                        NewVehicleLRI.bRadarNeutralWhenEmpty = VehicleListRed[RandomArrayNumber].bRadarNeutralWhenEmpty;
                        NewVehicleLRI.bRadarHideWhenEmpty = VehicleListRed[RandomArrayNumber].bRadarHideWhenEmpty;
                        NewVehicleLRI.RadarOwnerUpdateTime = VehicleListRed[RandomArrayNumber].RadarOwnerUpdateTime;
                        NewVehicleLRI.RadarEnemyUpdateTime = VehicleListRed[RandomArrayNumber].RadarEnemyUpdateTime;
                        NewVehicleLRI.bRadarFadeWithOwnerUpdateTime = VehicleListRed[RandomArrayNumber].bRadarFadeWithOwnerUpdateTime;
                        NewVehicleLRI.bRadarFadeWithEnemyUpdateTime = VehicleListRed[RandomArrayNumber].bRadarFadeWithEnemyUpdateTime;
                        NewVehicleLRI.SetBase(LastSpawned);
                    }
                }
                else
                {
                    if (VehicleListBlue[RandomArrayNumber].Health > 0)
                    {
                        LastSpawned.HealthMax = VehicleListBlue[RandomArrayNumber].Health;
                        LastSpawned.Health = VehicleListBlue[RandomArrayNumber].Health;
                    }

                    if (VehicleListBlue[RandomArrayNumber].bChangeMaxDesireability)
                    {
                        LastSpawned.MaxDesireability = VehicleListBlue[RandomArrayNumber].MaxDesireability;
                    }

                    LastSpawned.bSpawnProtected = (VehicleListBlue[RandomArrayNumber].SpawnProtectionTime != 0);
                    if (VehicleListBlue[RandomArrayNumber].SpawnProtectionTime > 0)
                    {
                        VSPT = Spawn(class'VehicleSpawnProtectionTimer', LastSpawned);
                        VSPT.SetTimer(VehicleListBlue[RandomArrayNumber].SpawnProtectionTime, False);
                    }

                    LastSpawned.Event = VehicleListBlue[RandomArrayNumber].VehicleDestroyedEvent;
                    LastSpawned.bEnterringUnlocks = !VehicleListBlue[RandomArrayNumber].bEnterringDoesNotUnlock;
                    LastSpawned.bEjectDriver = VehicleListBlue[RandomArrayNumber].bEjectDriver;

                    TriggerEvent(VehicleListBlue[RandomArrayNumber].VehicleSpawnedEvent, self, LastSpawned);

                    // Add vehicle to Radar Tracking System.
                    if (VehicleListBlue[RandomArrayNumber].bTrackVehicleOnRadar && !RadarRI.bRadarMutatorEnabled)
                    {
                        NewVehicleLRI = spawn(class'UltimateRadarVehicleLRI');

                        NewVehicleLRI.TrackedVehicle = LastSpawned;
                        NewVehicleLRI.OldOwnerTeam = LastSpawned.Team;
                        NewVehicleLRI.RadarMaterial = VehicleListBlue[RandomArrayNumber].RadarTexture;
                        NewVehicleLRI.RadarTextureScale = VehicleListBlue[RandomArrayNumber].RadarTextureScale;
                        NewVehicleLRI.RadarTextureRotationOffset = VehicleListBlue[RandomArrayNumber].RadarTextureRotationOffset;
                        NewVehicleLRI.RadarVehicleVisibility = VehicleListBlue[RandomArrayNumber].RadarVehicleVisibility;
                        NewVehicleLRI.bRadarVisibleToDriver = VehicleListBlue[RandomArrayNumber].bRadarVisibleToDriver;
                        NewVehicleLRI.bRadarNeutralWhenEmpty = VehicleListBlue[RandomArrayNumber].bRadarNeutralWhenEmpty;
                        NewVehicleLRI.bRadarHideWhenEmpty = VehicleListBlue[RandomArrayNumber].bRadarHideWhenEmpty;
                        NewVehicleLRI.RadarOwnerUpdateTime = VehicleListBlue[RandomArrayNumber].RadarOwnerUpdateTime;
                        NewVehicleLRI.RadarEnemyUpdateTime = VehicleListBlue[RandomArrayNumber].RadarEnemyUpdateTime;
                        NewVehicleLRI.bRadarFadeWithOwnerUpdateTime = VehicleListBlue[RandomArrayNumber].bRadarFadeWithOwnerUpdateTime;
                        NewVehicleLRI.bRadarFadeWithEnemyUpdateTime = VehicleListBlue[RandomArrayNumber].bRadarFadeWithEnemyUpdateTime;
                        NewVehicleLRI.SetBase(LastSpawned);
                    }
                }
                TriggerEvent(Event, self, None);
            }
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

    if (bUniqueVehicle)
        VehicleCount++; // It was decreased in the super function.
}


// ============================================================================
// SidesAreSwitched
//
// Just to make the code more surveillable.
// ============================================================================
function bool SidesAreSwitched()
{
    if (ONSOnslaughtGame(Level.Game) != None && ONSOnslaughtGame(Level.Game).bSidesAreSwitched)
        return true;
    return false;
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

    if ((ONSOnslaughtGame(Level.Game) != None && ONSOnslaughtGame(Level.Game).bSwapSidesAfterReset) && StaticTeamNum != 255)
        StaticTeamNum = abs(StaticTeamNum-1);

    if ((ONSOnslaughtGame(Level.Game) != None && ONSOnslaughtGame(Level.Game).bSwapSidesAfterReset) && NotLockedForTeam != 255)
        NotLockedForTeam = abs(NotLockedForTeam-1);

    SequentialArrayNumberRed = 0;
    SequentialArrayNumberBlue = 0;

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
     DrawType=DT_Sprite
}
