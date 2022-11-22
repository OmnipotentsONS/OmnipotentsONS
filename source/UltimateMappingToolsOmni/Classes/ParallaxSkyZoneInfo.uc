//=============================================================================
// ParallaxSkyZoneInfo by Party Boy. Place this instead of a SkyZoneInfo.
//=============================================================================

class ParallaxSkyZoneInfo extends SkyZoneInfo
    placeable;

var() vector SkyBoxRelativeOffset;
var() float SkyScale;
var ParallaxSkyboxMover MyMover;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    if( MyMover==None && Level.NetMode!=NM_DedicatedServer )
    {
        MyMover = Spawn(Class'ParallaxSkyboxMover');
        MyMover.MovingSky = Self;
        MyMover.Offset = SkyBoxRelativeOffset+Location;
        MyMover.Scale = SkyScale;
    }
}

defaultproperties
{
     SkyScale=0.062500
     bStatic=False
     RemoteRole=ROLE_None
     Texture=Texture'UltimateMappingTools_Tex.Icons.ParallaxSkyZone_Icon'
}
