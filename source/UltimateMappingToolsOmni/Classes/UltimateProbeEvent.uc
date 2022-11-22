// ============================================================================
// This actor is borrowed:
//// JBProbeEvent
//// Copyright 2002 by Mychaeel <mychaeel@planetjailbreak.com>
//// $Id: JBProbeEvent.uc,v 1.3 2004/02/16 17:17:02 mychaeel Exp $
////
//// Forwards handling of an event with a given Tag to another class.
//
// It is used by the EventLogicGates in this package and renamed to avoid
// problems with the original actor.
//
// Release date: 2010/01/27  in Package: UltimateONSTools-V2
// ============================================================================


class UltimateProbeEvent extends EventGate
  notplaceable;


// ============================================================================
// Delegates
// ============================================================================

delegate OnTrigger  (Actor ActorOther, Pawn PawnInstigator);
delegate OnUnTrigger(Actor ActorOther, Pawn PawnInstigator);


// ============================================================================
// Trigger
//
// Forwards triggering event to the delegate.
// ============================================================================

event Trigger(Actor ActorOther, Pawn PawnInstigator)
{
  OnTrigger(ActorOther, PawnInstigator);
}


// ============================================================================
// UnTrigger
//
// Forwards untriggering event to the delegate.
// ============================================================================

event UnTrigger(Actor ActorOther, Pawn PawnInstigator)
{
  OnUnTrigger(ActorOther, PawnInstigator);
}


// ============================================================================
// Defaults
// ============================================================================

defaultproperties
{
     Texture=Texture'Engine.S_Actor'
}
