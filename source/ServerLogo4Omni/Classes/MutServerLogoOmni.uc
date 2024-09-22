//=============================================================================
// MutServerLogo
// Copyright (c) 2004 by Wormbo <wormbo@onlinehome.de>
//
// Spawns the ServerLogo actor.
//=============================================================================

// MutServerLogoOmni
// extended by pooty for random music
// depends on textures etc. in ServerLogo4
class MutServerLogoOmni extends Mutator;


//=============================================================================
// PostBeginPlay
//
// Spawn the ServerLogo actor if it doesn't already exist.
//=============================================================================

function PostBeginPlay()
{
  local ServerLogoOmni S;
  
  LifeSpan = 0.01;  // destroy the mutator afterwards
  
  foreach DynamicActors(class'ServerLogoOmni', S)
    return;
  
  Spawn(class'ServerLogoOmni');
}


//=============================================================================
// GetServerDetails
//
// Don't show in server details.
//=============================================================================

function GetServerDetails(out GameInfo.ServerResponseLine ServerState);


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     bAddToServerPackages=True
     GroupName="ServerLogoOmni"
     FriendlyName="Server Logo 4 Omni"
     Description="Displays a logo, play intro sound on clients that connected to the server."
}
