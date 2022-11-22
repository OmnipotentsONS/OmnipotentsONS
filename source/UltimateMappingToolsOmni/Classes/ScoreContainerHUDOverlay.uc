//-----------------------------------------------------------------------------
// HUDOverlay for ScoreContainer
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 16.08.2011 19:54:42 in Package: UltimateMappingTools$
// Big thanks to INIQUITOUS who almost completely rewrote this one.
//
// This is used to set a proper position for the Score to show up.
//-----------------------------------------------------------------------------
class ScoreContainerHUDOverlay extends HudOverlay
    dependson(ScoreContainer);

var float RedPosX, RedPosY, BluePosX, BluePosY, SpectatorPosX, SpectatorPosY;

var int ScoreFontSize;
// This int size controls how big the font is at different resolutions. -2 is normally quite good.

var PlayerController PCOwner;
// The PlayerController that owns this HUD.

var ScoreContainer ParentScoreContainer;
// Get all your informations autonomously from this ScoreContainer.

var string RedString, BlueString;


//=============================================================================
simulated function Render(Canvas C)
{
    if(PCOwner != None && ParentScoreContainer != None)
    {
        C.Reset(); // Reset to stop other actors messing the HUD settings.
        C.Style = ERenderStyle.STY_Normal; // Set style here, don't think Reset() resets the style.
        C.Font = HUD(Owner).GetFontSizeIndex(C, ScoreFontSize);


        if (PCOwner != None)
        {
            CreateMessageString();

            switch (PCOwner.GetTeamNum())
            {
                case 0:
                    C.DrawColor = class'HUD'.default.RedColor;
                    C.SetPos(RedPosX * C.ClipX, RedPosY * C.ClipY);
                    C.DrawText(RedString,true);
                    break;
                case 1:
                    C.DrawColor = class'HUD'.default.BlueColor;
                    C.SetPos(BluePosX * C.ClipX, BluePosY * C.ClipY);
                    C.DrawText(BlueString,true);
                    break;
                default:
                    C.DrawColor = class'HUD'.default.RedColor;
                    C.SetPos(SpectatorPosX * C.ClipX, SpectatorPosY * C.ClipY);
                    C.DrawText(RedString,true);
                    C.DrawColor = class'HUD'.default.BlueColor;
                    C.SetPos(SpectatorPosX * C.ClipX, (SpectatorPosY + 0.05) * C.ClipY);
                    C.DrawText(BlueString,true);
                    break;
            }
        }
    }
}


simulated function CreateMessageString()
{
    if (ONSOnslaughtGame(Level.Game) != None && ONSOnslaughtGame(Level.Game).bSidesAreSwitched)
    {
        RedString = Repl(ParentScoreContainer.BlueScoreString, "%s", string(ParentScoreContainer.BlueTeamScore));
        BlueString = Repl(ParentScoreContainer.RedScoreString, "%s", string(ParentScoreContainer.RedTeamScore));
    }
    else
    {
        RedString = Repl(ParentScoreContainer.RedScoreString, "%s", string(ParentScoreContainer.RedTeamScore));
        BlueString = Repl(ParentScoreContainer.BlueScoreString, "%s", string(ParentScoreContainer.BlueTeamScore));
    }
}

//=============================================================================
// Default Values
//=============================================================================

defaultproperties
{
}
