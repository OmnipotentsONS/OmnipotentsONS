//=============================================================================
// BlockingVolumeToggleable
//
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:39:48 in Package: UltimateMappingTools$
//
// The collision of this BlockingVolume can be toggled when it gets triggered.
//=============================================================================
class BlockingVolumeToggleable extends BlockingVolume;


// The following collision types are changed on triggering.
var() bool bChangeCollideActors;
var() bool bChangeBlockActors;
var() bool bChangeBlockPlayers;

var() bool bTriggerControlled;
// If True, untriggering will disable all collision and triggering will enable all.
// If False, triggering will toggle.

var bool bBlockActorsCopy, bCollideActorsCopy, bBlockPlayersCopy;


replication
{
    reliable if ( (Role==ROLE_Authority) && bNetDirty)
        bBlockActorsCopy, bCollideActorsCopy, bBlockPlayersCopy;
}


simulated event PostNetRecieve()
{
    if ((bBlockActors != bBlockActorsCopy) || (bCollideActors != bCollideActorsCopy) || (bBlockPlayers != bBlockPlayersCopy))
        SetCollision(bCollideActorsCopy, bBlockActorsCopy, bBlockPlayersCopy);
}


event Trigger(Actor Other, Pawn EventInstigator)
{
  local bool bNewBlockActors, bNewCollideActors, bNewBlockPlayers;

  if (bTriggerControlled)
  {
    if (bChangeBlockActors)
        bNewBlockActors = !bBlockActors;

    if (bChangeBlockPlayers)
        bNewBlockPlayers = !bBlockPlayers;

    if (bChangeCollideActors)
        bNewCollideActors = !bCollideActors;
  }
  else
  {
    if (bChangeBlockActors)
        bNewBlockActors = True;

    if (bChangeBlockPlayers)
        bNewBlockPlayers = True;

    if (bChangeCollideActors)
        bNewCollideActors = True;
  }

  SetCollision(bNewCollideActors, bNewBlockActors, bNewBlockPlayers);

  bBlockActorsCopy = bBlockActors;
  bCollideActorsCopy = bCollideActors;
  bBlockPlayersCopy = bBlockPlayers;

}

event UnTrigger(Actor Other, Pawn EventInstigator)
{
  local bool bNewBlockActors, bNewCollideActors, bNewBlockPlayers;

  if (bTriggerControlled)
  {
    if (bChangeBlockActors)
        bNewBlockActors = False;

    if (bChangeBlockPlayers)
        bNewBlockPlayers = False;

    if (bChangeCollideActors)
        bNewCollideActors = False;

    SetCollision(bNewCollideActors, bNewBlockActors, bNewBlockPlayers);

    bBlockActorsCopy = bBlockActors;
    bCollideActorsCopy = bCollideActors;
    bBlockPlayersCopy = bBlockPlayers;
  }
}

defaultproperties
{
     bChangeCollideActors=True
     bChangeBlockActors=True
     bTriggerControlled=True
     bStatic=False
     bNoDelete=False
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=10.000000
     NetPriority=2.000000
     bNetNotify=True
}
