//-----------------------------------------------------------------------------
// UltimateRadarMap Tab
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:25:24 in Package: UltimateMappingTools$
//
// Displays a Tab with the RadarMap in big in the menu, just like in ONS.
//-----------------------------------------------------------------------------

class UT2K4Tab_UltimateRadarMap extends MidGamePanel;


var() float RadarMapCenterX, RadarMapCenterY, RadarMapRadius;


var automated GUIImage i_Background, i_Team;


var color TColor[2];


// Actor references - these must be cleared at level change
var PlayerReplicationInfo PRI;


function ShowPanel(bool bShow)
{
    local string colorname;
    Super.ShowPanel(bShow);

    if ( bShow )
    {
        if ( (PRI != None) && (PRI.Team != None) )
        {
            colorname = PRI.Team.ColorNames[PRI.Team.TeamIndex];

            i_Team.Image = PRI.Level.GRI.TeamSymbols[PRI.Team.TeamIndex];
            i_Team.ImageColor = TColor[PRI.Team.TeamIndex];
        }
    }
}


function bool PreDrawMap(Canvas C)
{
    local float L,T,W,H;
    RadarMapRadius = fmin( i_Background.ActualHeight(),i_Background.ActualWidth() ) / 2;
    RadarMapCenterX = i_Background.Bounds[0] + RadarMapRadius;
    RadarMapCenterY = i_Background.Bounds[1] + i_Background.ActualHeight() / 2;

    L = RadarMapCenterX + RadarMapRadius + (ActualWidth()*0.05);
    T = RadarMapCenterY - RadarMapRadius;

    W = ActualLeft() + ActualWidth() - L;
    H = ActualTop() + ActualHeight() - T;

    L = RadarMapCenterX + RadarMapRadius;
    W = ActualLeft() + ActualWidth() - L;

    i_Team.WinLeft = L;
    i_Team.WinWidth = W;
    i_Team.WinHeight = W;
    i_Team.WinTop = i_Background.ActualTop() + i_Background.ActualHeight() - i_Team.ActualHeight();


    return false;
}

function bool DrawMap(Canvas C)
{
    local UltimateRadarMapHUDOverlay URMHO;
    local float HS;
    local int i;


    HS = PlayerOwner().myHud.HudScale; // Save value
    PlayerOwner().myHud.HudScale = 1.0;

    for (i = 0; i < PlayerOwner().myHud.Overlays.Length; i++)
    {
        if (UltimateRadarMapHUDOverlay(PlayerOwner().myHud.Overlays[i]) != None)
            URMHO = UltimateRadarMapHUDOverlay(PlayerOwner().myHud.Overlays[i]);
    }

    URMHO.DrawRadar(C, RadarMapCenterX, RadarMapCenterY, RadarMapRadius, vect(0,0,0));

    PlayerOwner().myHud.HudScale = HS; // Reset our HudScale to saved value.


    return true;
}

function InternalOnPostDraw(Canvas Canvas)
{
    PRI = PlayerOwner().PlayerReplicationInfo;
    if (PRI != None)
    {
        bInit = False;
        OnRendered = None;
        ShowPanel(true);
    }
}


function Timer()
{
    local PlayerController PC;

    PC = PlayerOwner();
    PC.ServerRestartPlayer();
    PC.bFire = 0;
    PC.bAltFire = 0;
    Controller.CloseMenu(false);
}



function Free()
{
    Super.Free();

    PRI = None;
}

function LevelChanged()
{
    Super.LevelChanged();

    PRI = None;
}

defaultproperties
{
     RadarMapCenterX=0.650000
     RadarMapCenterY=0.400000
     RadarMapRadius=0.300000
     Begin Object Class=GUIImage Name=BackgroundImage
         Image=Texture'2K4Menus.Controls.outlinesquare'
         ImageStyle=ISTY_Stretched
         WinTop=0.070134
         WinLeft=0.029188
         WinWidth=0.634989
         WinHeight=0.747156
         bAcceptsInput=True
         OnPreDraw=UT2K4Tab_OnslaughtMap.PreDrawMap
         OnDraw=UT2K4Tab_OnslaughtMap.DrawMap
         OnClick=UT2K4Tab_OnslaughtMap.SpawnClick
         OnRightClick=UT2K4Tab_OnslaughtMap.SelectClick
     End Object
     i_Background=GUIImage'GUI2K4.UT2K4Tab_OnslaughtMap.BackgroundImage'

     Begin Object Class=GUIImage Name=iTeam
         ImageColor=(G=128,R=0,A=90)
         ImageStyle=ISTY_Scaled
         WinTop=0.400000
         WinLeft=0.619446
         WinWidth=0.338338
         WinHeight=0.405539
         TabOrder=10
     End Object
     i_Team=GUIImage'GUI2K4.UT2K4Tab_OnslaughtMap.iTeam'

     TColor(0)=(B=100,G=100,R=255,A=128)
     TColor(1)=(B=255,G=128,A=128)
     OnRendered=UT2k4Tab_UltimateRadarMap.InternalOnPostDraw
}
