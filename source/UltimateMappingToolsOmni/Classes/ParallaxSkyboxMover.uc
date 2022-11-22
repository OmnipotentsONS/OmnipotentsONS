//=============================================================================
// SkyboxMover by Party Boy for the ParralaxSkyZoneInfo.
//=============================================================================

Class ParallaxSkyboxMover extends Info
    NotPlaceable;

var PlayerController CachedPlayer;
var vector Offset;
var float Scale;
var Actor MovingSky;

simulated function Tick( float Delta )
{

local Actor CamActor;
local vector CamLocation;
local rotator CamRotation;

    if( CachedPlayer==None )
    {
        CachedPlayer = Level.GetLocalPlayerController();
        if( CachedPlayer==None )
        {
            Destroy();
            Return;
        }
    }
    CachedPlayer.PlayerCalcView( CamActor,  CamLocation, CamRotation );
    MovingSky.SetLocation( CamLocation*Scale+Offset  );
}

defaultproperties
{
}
