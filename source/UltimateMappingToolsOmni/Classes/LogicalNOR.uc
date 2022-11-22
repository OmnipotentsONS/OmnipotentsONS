//-----------------------------------------------------------------------------
// Logical NOR
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:18:41 in Package: UltimateMappingTools$
//
// Does exactly the opposite of the Logical OR.
// That means that it triggers an Event if none of the conditions is True and
// untriggers the Event if one or both conditions are False.
//-----------------------------------------------------------------------------
class LogicalNOR extends LogicalOR
    placeable;


function UpdateGate(Pawn EventInstigator)
{
    if (!bFirstIsTrue && !bSecondIsTrue)
    {
        TriggerEvent(event, self, EventInstigator);
        bWasAllTrue = false;
    }
    else if (!bWasAllTrue)
    {
        UnTriggerEvent(event, self, EventInstigator);
        bWasAllTrue = true;
    }
}

defaultproperties
{
     bWasAllTrue=True
}
