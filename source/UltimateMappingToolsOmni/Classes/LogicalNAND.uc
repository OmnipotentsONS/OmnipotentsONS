//-----------------------------------------------------------------------------
// Logical NAND
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:18:35 in Package: UltimateMappingTools$
//
// Does exactly the opposite of the Logical AND.
// That means that it triggers an Event if only one or none of the conditions is
// True and untriggers the Event if both conditions are False.
//-----------------------------------------------------------------------------
class LogicalNAND extends LogicalAND
    placeable;

function UpdateGate(Pawn EventInstigator)
{
    if (bFirstIsTrue && bSecondIsTrue)
    {
        UnTriggerEvent(event, self, EventInstigator);
        bWasAllTrue = true;
    }
    else if (bWasAllTrue)
    {
        TriggerEvent(event, self, EventInstigator);
        bWasAllTrue = false;
    }
}

defaultproperties
{
}
