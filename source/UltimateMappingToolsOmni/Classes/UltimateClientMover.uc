// This is the following class, just with another name. Used by permission.

// ============================================================================
// JBClientMoverDualDestination
// Copyright 2007 by Wormbo <wormbo@online.de>
// $Id: JBMoverDualDestination.uc,v 1.5 2007/06/15 18:14:10 wormbo Exp $
//
// A mover with a multitude of improvements over standard movers:
//
// - can trigger an event when receiving damage (like my DamageTriggerMover)
//   See: http://wiki.beyondunreal.com/wiki/DamageTriggerMover
//
// - can trigger/untrigger an event when someone stands in it (not only in
//   StandOpenTimed state)
//
// - mapper can define two different movement paths (like tarquin's DecksMover)
//   with individual trigger tags, sounds and events
//
// - mapper can specify separate open and close times (like VitalOverdose's
//   VariableTimedMover)
//   See: http://wiki.beyondunreal.com/wiki/VitalOverdose/VariableTimedMover
//
// - mapper can specify indifid move times for every key (like SuperApe's
//   VariableTimedMover)
//   See: http://wiki.beyondunreal.com/wiki/VariableTimedMover
//
//
// The mover will ignore the AlternateTag event when it was opened with the Tag
// event and vice versa until it has closed again. AlternateTag doesn't make
// sense in some states.
// ============================================================================

class UltimateClientMover Extends UltimateMover;

event PostBeginPlay()
{
    Super.PostBeginPlay();

    if ( Level.NetMode == NM_DedicatedServer )
    {
        GotoState('ServerIdle');
        SetTimer(0,false);
        SetPhysics(PHYS_None);
    }
}

State ServerIdle
{
}

defaultproperties
{
     bAlwaysRelevant=False
     RemoteRole=ROLE_None
     bClientAuthoritative=True
}
