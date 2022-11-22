// This is the following class, just with another name. Used by permission.

// ============================================================================
// JBAction_WaitOnlyForTimer
// Copyright (c) 2007 by Wormbo <wormbo@online.de>
// $Id: JBAction_WaitOnlyForTimer.uc,v 1.1 2007/05/12 11:25:45 wormbo Exp $
//
// Waits exclusively for timer and unlike its superclass NOT for triggering.
// ============================================================================


class UTAction_WaitOnlyForTimer extends Action_WaitForTimer;


// ============================================================================
// CompleteWhenTriggered
//
// Does NOT react to triggering. (Why should it anyway?)
// ============================================================================

function bool CompleteWhenTriggered()
{
  return false;
}

defaultproperties
{
}
