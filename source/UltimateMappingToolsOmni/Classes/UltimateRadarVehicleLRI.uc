//=============================================================================
// ReplicationInfo for a Vehicle from the UltimateONSFactory
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 13.10.2011 21:32:25 in Package: UltimateMappingTools$
//
// Stores the radar-relevant values and updates and replicates the location of
// vehicle to the client so that it can be read by the UltimateRadarVehicleHUDOverlay.
//=============================================================================
class UltimateRadarVehicleLRI extends ReplicationInfo;


var Vehicle  TrackedVehicle;       // The vehicle whose location and rotation is tracked.

var bool   bRadarVisibleToDriver;  // Should the vehicle be shown on the radar to it's driver?
var bool   bRadarNeutralWhenEmpty; // If true, the vehicle is drawn with white team color when it's left.
var bool   bRadarHideWhenEmpty;    // If true, the vehicle is not drawn when it's empty.

var enum   ERadarVehicleVisibility
{
      RVV_Always,                  // Always to everyone.
      RVV_DriverTeam,              // Always to the team that drives the vehicle.
      RVV_DriverEnemy,             // Always to the enemy team of the driver.
      RVV_OriginalTeam,            // Always to the team that originally owned the vehicle.
      RVV_OriginalTeamAndHijacker, // Always to the team that originally owned the vehicle and to the enemy when he hijacks.
      RVV_OriginalEnemy,           // Always to the team that not originally owned the vehicle.
      RVV_OriginalEnemyAndHijacker,// Always to the team that not originally owned the vehicle and to the owners when it got hijacked.
      RVV_OnlyWhenOwned,           // Only show to the team that originally owned the vehicle when it's not hijacked.
      RVV_OnlyWhenHijacked,        // Only show to the team that originally owned the vehicle when it got hijacked.
} RadarVehicleVisibility;
var byte     OldOwnerTeam;         // The original TeamNum that the vehicle had.

var float    RadarOwnerUpdateTime; // How many seconds have to pass before the location and rotation of the vehicle is updated for the owning team.
var float    RadarEnemyUpdateTime; // Same as above, just for enemies.
var bool     bRadarFadeWithOwnerUpdateTime; // If True, the icon on the radar map will interpolate between opaque and translucent as time passes between location updates on the radar.
var bool     bRadarFadeWithEnemyUpdateTime; // If False, the icon will always stay fully opaque.

var Material RadarMaterial;
var TexRotator RadarTexRot;        // This image will represent the vehicle on the Radar.
var float    RadarTextureScale;    // The image will be scaled by this factor.
var int    RadarTextureRotationOffset; // A base rotation that is added to the rotation of the texture.

var vector   VehicleLocation, VehicleLocationEnemy;      // The location of the vehicle. (replicated)

var float    PassedTime, PassedTimeEnemy; // The time that has passed since the location and rotation have been updated.

var UltimateRadarVehicleLRI NextVehicleLRI; // The next ReplicationInfo. This way we create a dynamic linked list that can change at runtime.

var bool bAdded;
var bool bMarkerMode; // If True, this is used by the UltimateRadarMapMarker and thus doesn't require a vehicle.
var UltimateRadarVehicleLRIMaster VehicleLRIMaster;
//-----------------------------------------------------------------------------

replication
{
    reliable if ( bNetDirty )
        TrackedVehicle, RadarVehicleVisibility, RadarMaterial,
        RadarTextureScale, VehicleLocation, VehicleLocationEnemy, OldOwnerTeam, bMarkerMode;
}


// ============================================================================
// BeginPlay
//
// Create an anchor for the linked list, if it doesn't exist yet.
// ============================================================================

event BeginPlay()
{
     foreach DynamicActors(class'UltimateRadarVehicleLRIMaster',VehicleLRIMaster)
     {
         return;
     }

     if (VehicleLRIMaster == None)
     {
         VehicleLRIMaster = Spawn(class'UltimateRadarVehicleLRIMaster');
     }


     VehicleLocation = Location;
     VehicleLocationEnemy = Location;
     NetUpdateTime = Level.TimeSeconds-1;
}


// ============================================================================
// PostBeginPlay
//
// Create a new TexRotator material right when this thing is spawned. The
// UltimateONSFactory will then directly set the RadarTexture as Material of this
// TexRotator.
// ============================================================================

simulated event PostBeginPlay()
{
    RadarTexRot = new class'TexRotator';
}


// ============================================================================
// BaseChange
//
// Called when the Base of this actor changed. This is done by the UltimateONSFactory
// after this has been spawned, i.e. after PostBeginPlay has been called.
// Or when the tracked vehicle has been destroyed, so we can start to destory
// ourself as well.
// ============================================================================

simulated event BaseChange()
{
    if (Base == None) // Tracked vehicle got destroyed.
    {
        LifeSpan = 0.1;
    }
    else if (!bAdded)
    {
        foreach DynamicActors(class'UltimateRadarVehicleLRIMaster',VehicleLRIMaster)
        {
            VehicleLRIMaster.AddVehicleLRI(self);
            RadarTexRot.Material = RadarMaterial;
            RadarTexRot.UOffset = RadarMaterial.MaterialUSize() / 2;
            RadarTexRot.VOffset = RadarMaterial.MaterialVSize() / 2;
            bAdded = True;
            break;
        }
    }
}


// ============================================================================
// Tick
//
// Updates the location and rotation in regular intervals, according to the
// settings. The rotation affects directly the rotation of the TexRotator and
// doesn't need to be replicated this way (hope the updated TexRotator doesn't
// need to be replicated too in some way if it changed it's rotation).
// ============================================================================

simulated event Tick(float DeltaTime)
{
    PassedTime += DeltaTime;
    PassedTimeEnemy += DeltaTime;


    if (PassedTime >= RadarOwnerUpdateTime)
    {
        if (TrackedVehicle != None)
        {
            if (TrackedVehicle.IsInState('VehicleDestroyed'))
            {
                Destroy();
            }

            VehicleLocation = TrackedVehicle.Location;
            RadarTexRot.Rotation.Yaw = -TrackedVehicle.Rotation.Yaw - 16384 + RadarTextureRotationOffset;
        }
        else if (bMarkerMode)
        {
            VehicleLocation = Location;
            RadarTexRot.Rotation.Yaw = -Rotation.Yaw - 16384 + RadarTextureRotationOffset;
        }
        PassedTime -= RadarOwnerUpdateTime;
    }

    if (PassedTimeEnemy >= RadarEnemyUpdateTime)
    {
        if (TrackedVehicle != None)
        {
            VehicleLocationEnemy = TrackedVehicle.Location;
            RadarTexRot.Rotation.Yaw = -TrackedVehicle.Rotation.Yaw - 16384 + RadarTextureRotationOffset;
        }
        PassedTimeEnemy -= RadarEnemyUpdateTime;
    }
}

simulated event Destroyed()
{
    if (VehicleLRIMaster != None)
        VehicleLRIMaster.RemoveVehicleLRI(self);

    NetUpdateTime = Level.TimeSeconds-1;
}


//-----------------------------------------------------------------------------

defaultproperties
{
     bSkipActorPropertyReplication=False
     NetPriority=2.000000
}
