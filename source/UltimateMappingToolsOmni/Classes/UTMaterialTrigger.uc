// This is the following class, just with another name. Used by permission.

//=============================================================================
// JBMaterialTrigger
// Copyright 2003 by Wormbo <wormbo@onlinehome.de>
// $Id: JBMaterialTrigger.uc,v 1.1 2003/10/17 07:20:09 wormbo Exp $
//
// A MaterialTrigger that works in network games.
//=============================================================================


class UTMaterialTrigger extends MaterialTrigger;


//=============================================================================
// Variables
//=============================================================================

// whether triggering resets or triggers the materials
var(MaterialTrigger) enum ETriggerAction {
  TriggerTriggers,
  TriggerResets,
  TriggerDoesNothing
} TriggerAction;

// whether untriggering resets or triggers the materials
var(MaterialTrigger) enum EUnriggerAction {
  UntriggerDoesNothing,
  UntriggerTriggers,
  UntriggerResets
} UntriggerAction;

// array holding the ReplicationInfos for clientside triggering
var array<UTMaterialTriggerReplicationInfo> ReplicatedMaterialTriggers;


//=============================================================================
// PostBeginPlay
//
// Spawns an UTMaterialTriggerReplicationInfo for each triggered material.
//=============================================================================

function PostBeginPlay()
{
  local int i;

  ReplicatedMaterialTriggers.Length = MaterialsToTrigger.Length;

  for (i = 0; i < MaterialsToTrigger.Length; i++) {
    ReplicatedMaterialTriggers[i] = Spawn(class'UTMaterialTriggerReplicationInfo', Self);
    ReplicatedMaterialTriggers[i].SetMaterialToTrigger(string(MaterialsToTrigger[i]));
  }
}


//=============================================================================
// Trigger
//
// Tells the MTRIs about the Instigators and triggering actors and tells them
// to trigger the material.
//=============================================================================

function Trigger(Actor Other, Pawn EventInstigator)
{
  local int i;

  if ( Other == None )
    Other = Self;

  if ( TriggerAction == TriggerTriggers ) {
    for (i = 0; i < ReplicatedMaterialTriggers.Length; i++)
      if ( ReplicatedMaterialTriggers[i] != None )
        ReplicatedMaterialTriggers[i].TriggerMaterial(Other, EventInstigator);
  }
  else if ( TriggerAction == TriggerResets ) {
    for (i = 0; i < ReplicatedMaterialTriggers.Length; i++)
      if ( ReplicatedMaterialTriggers[i] != None )
        ReplicatedMaterialTriggers[i].ResetMaterial();
  }
}


//=============================================================================
// Untrigger
//
// Triggers or resets the materials depending on the UntriggerAction property.
//=============================================================================

function Untrigger(Actor Other, Pawn EventInstigator)
{
  local int i;

  if ( Other == None )
    Other = Self;

  if ( UntriggerAction == UntriggerTriggers ) {
    for (i = 0; i < ReplicatedMaterialTriggers.Length; i++)
      if ( ReplicatedMaterialTriggers[i] != None )
        ReplicatedMaterialTriggers[i].TriggerMaterial(Other, EventInstigator);
  }
  else if ( UntriggerAction == UntriggerResets ) {
    for (i = 0; i < ReplicatedMaterialTriggers.Length; i++)
      if ( ReplicatedMaterialTriggers[i] != None )
        ReplicatedMaterialTriggers[i].ResetMaterial();
  }
}

defaultproperties
{
}
