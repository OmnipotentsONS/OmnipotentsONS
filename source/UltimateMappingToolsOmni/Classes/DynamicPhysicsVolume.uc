//=============================================================================
// DynamicPhysicsVolume
//
// Copyright 2008 by Epic Games
//
// This is a movable PhysicsVolume. It can be attached to dynamic objects.
//=============================================================================
class DynamicPhysicsVolume extends PhysicsVolume;

defaultproperties
{
     BrushColor=(B=255,G=255,R=100,A=255)
     bColored=True
     bStatic=False
     Physics=PHYS_Interpolating
     RemoteRole=ROLE_None
}
