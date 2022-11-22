//-----------------------------------------------------------------------------
// CountdownHUDOverlay
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 16.08.2011 19:52:30 in Package: UltimateMappingTools$
//
// Allows to specify a custom position to display the countdown in the HUD.
//-----------------------------------------------------------------------------
class CountdownHUDOverlay extends HudOverlay;

var PlayerController PCOwner;
// The PlayerController that owns this HUD.

var CountdownEventGate ParentCountdown;
// The CountdownEventGate that created this HUDOverlay.

var int CountdownProgressInt;
// The current countdown, cut down to an int value.

var int ScoreFontSize;
// This int size controls how big the font is at different resolutions. -2 is normally quite good.


function Render(Canvas C)
{
    C.Font = HUD(Owner).GetFontSizeIndex(C, ParentCountdown.ScoreFontSize);

    CountdownProgressInt = int(ParentCountdown.CountdownProgress);

    if (ParentCountdown.bSubtileCounting)
    {
        // Make the interval between messages smaller when it's running short
        if ((CountdownProgressInt >= 60) && (CountdownProgressInt % 20 == 0))
            DisplayCountdown(C);
        else if ((CountdownProgressInt >= 10) && (CountdownProgressInt % 10 == 0))
            DisplayCountdown(C);
        else if ((CountdownProgressInt < 10) && (CountdownProgressInt % 1 == 0))
            DisplayCountdown(C);
    }
    else
    {
        DisplayCountdown(C);
    }
}

function DisplayCountdown(Canvas C)
{
    C.SetPos(ParentCountdown.CountdownPosX, ParentCountdown.CountdownPosY);
    C.DrawText(Repl(ParentCountdown.CountdownString, "%c", string(CountdownProgressInt)), false);
}

defaultproperties
{
}
