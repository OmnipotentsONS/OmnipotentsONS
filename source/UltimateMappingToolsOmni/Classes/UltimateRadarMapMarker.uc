//-----------------------------------------------------------------------------
// UltimateRadarMapMarker
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 13.10.2011 21:32:25 in Package: UltimateMappingTools$
//
// Draws a texture on the radar map, representing the location and rotation of this Actor.
// Can be turned on and off with triggering.
//-----------------------------------------------------------------------------
class UltimateRadarMapMarker extends Info
    placeable
    DependsOn(UltimateRadarVehicleLRI);

var() UltimateRadarVehicleLRI.ERadarVehicleVisibility RadarMarkerVisibility;
var() float    RadarUpdateTime;
var() bool     bRadarFadeWithUpdateTime; // If True, the icon on the radar map will interpolate between opaque and translucent as time passes between location updates on the radar.
                                         // If False, the icon will always stay fully opaque.
var() Material RadarMaterial;
var() float    RadarTextureScale;    // The image will be scaled by this factor.
var() int      RadarTextureRotationOffset; // A base rotation that is added to the rotation of the texture.

var() bool     bInitiallyEnabled;


var   UltimateRadarVehicleLRI LRI;      // Reference to the LRI that represents this texture.
var   vector   OriginalLocation;
var   rotator  OriginalRotation;

var UltimateONSRadarHUDRI RadarRI;
var UltimateRadarMap URM;


event PostBeginPlay()
{
    OriginalLocation = Location;
    OriginalRotation = Rotation;
}


event SetInitialState()
{
    super.SetInitialState();

    if (ONSOnslaughtGame(Level.Game) != None)
    {
        foreach DynamicActors(class'UltimateONSRadarHUDRI', RadarRI)
        {
            break;
        }
    }
    else
    {
        foreach DynamicActors(class'UltimateRadarMap', URM)
        {
            break;
        }
    }

    if (bInitiallyEnabled)
    {
        CreateLRI();
    }
}


event Trigger(Actor Other, Pawn EventInstigator)
{
    if (LRI == None)
        CreateLRI();
}

event UnTrigger(Actor Other, Pawn EventInstigator)
{
    if (LRI != None)
        LRI.Destroy();
}


function CreateLRI()
{
    if ((RadarRI != None && RadarRI.bRadarMutatorEnabled) || (URM != None && URM.bDisabled))
        return;

    LRI = spawn(class'UltimateRadarVehicleLRI');

    LRI.bMarkerMode = True;
    LRI.RadarMaterial = RadarMaterial;
    LRI.RadarTextureScale = RadarTextureScale;
    LRI.RadarTextureRotationOffset = RadarTextureRotationOffset;
    LRI.RadarVehicleVisibility = RadarMarkerVisibility;
    LRI.RadarOwnerUpdateTime = RadarUpdateTime;
    LRI.bRadarFadeWithOwnerUpdateTime = bRadarFadeWithUpdateTime;
    LRI.SetBase(self);
}

function Reset()
{
    if (!bInitiallyEnabled)
    {
        if (LRI != None)
            LRI.Destroy();
    }
    else if (LRI == None)
    {
        CreateLRI();
    }

    SetLocation(OriginalLocation);
    SetRotation(OriginalRotation);
}

defaultproperties
{
     RadarUpdateTime=1.000000
     RadarTextureScale=1.000000
     bInitiallyEnabled=True
}
