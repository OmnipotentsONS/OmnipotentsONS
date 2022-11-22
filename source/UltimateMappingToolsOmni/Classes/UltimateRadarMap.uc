//-----------------------------------------------------------------------------
// Ultimate Radar Map
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 12.10.2011 15:52:21 in Package: UltimateMappingTools$
//
// Enables the Radar Map in any gametype.
//-----------------------------------------------------------------------------
class UltimateRadarMap extends Info
    placeable;


var() bool bShowOwnObjectiveCarrier;
// Shows the location of the own flag/bomb carrier (i.e. your teammember that stole
// the enemy flag) on radar.

var() bool bShowEnemyObjectiveCarrier;
// Shows the location of the enemy flag/bomb carrier on radar.

var() bool bShowNonClassifiedGameObjectives;
// Shows GameObjectives on the radar that are neither Flags, nor DomintationPoints, nor Bombs, nor BombDeliveries.
// I.e. Assault Objectives.

var() bool bUseActorLocationAsMapCenter;
// If true, the map center is not assumed to be at 0,0,0 but at the location of this Actor.
// This way you don't have to adjust the entire rest of your map to match the center of the editor.


//var GUI.GUITabItem UltimateRadarMapPanel; // The menu tab with the RadarMap.
//var bool bAddedPanel;
var bool bAddedOverlay;

var bool bHasRadarVehicles;
var bool bDisabled;


replication
{
    reliable if (Role == ROLE_Authority)
        bDisabled;
}



//=============================================================================
// Initialisation
//=============================================================================
event BeginPlay()
{
    if (ONSOnslaughtGame(Level.Game) != None || MutatorCheck()) // avoid messing with ONS
    {
        bDisabled = True; // Nasty hack here. Because bNoDelete is set to True for replication purposes, we can't simply destroy this Actor.
        NetUpdateTime = Level.TimeSeconds - 1;
    }
}

// Returns True if a loaded Mutator affects the radar.
function bool MutatorCheck()
{
    local Mutator M;

    for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
    {
        if (InStr(M.GroupName,"Radar") != -1)
            return True;
    }

    return False;
}

simulated event PostBeginPlay()
{
    local UltimateVCTFFactory UVF;
    local int i;

    if (bDisabled)
    {
        return;
    }

//  UltimateRadarMapPanel.ClassName = string(class'UT2K4Tab_UltimateRadarMap');

    foreach AllActors(class'UltimateVCTFFactory', UVF)
    {
        if (bHasRadarVehicles)
            break;

        for (i = 0; i < UVF.VehicleList.Length; i++)
        {
            if (UVF.VehicleList[i].bTrackVehicleOnRadar)
            {
                bHasRadarVehicles = True;
                break;
            }
        }
    }

    if (Level.NetMode != NM_DedicatedServer) // don't spawn the overlay and menu panel on dedicated servers
    {
        Enable ('Tick');
    }
    else
    {
        Disable ('Tick');
    }
}

//=============================================================================
simulated event Tick(float DeltaTime)
{
    local PlayerController  PC;
    local UltimateRadarMapHUDOverlay Overlay;
//  local MidGamePanel Panel;
//  local UT2K4PlayerLoginMenu LoginMenu;
    PC = Level.GetLocalPlayerController();

    if (bDisabled || PC == None)
        return;

    if (!bAddedOverlay)
    {
        Overlay = Spawn(class'UltimateRadarMapHUDOverlay');
        if (Overlay != None)
        {
            PC.myHUD.AddHudOverlay(Overlay);
            if (bUseActorLocationAsMapCenter)
                Overlay.MapCenterLocation = Location;
            Overlay.MapCenterLocation.Z = 0;
            Overlay.bShowOwnObjectiveCarrier = bShowOwnObjectiveCarrier;
            Overlay.bShowEnemyObjectiveCarrier = bShowEnemyObjectiveCarrier;
            Overlay.bShowNonClassifiedGameObjectives = bShowNonClassifiedGameObjectives;
            Overlay.bTrackVehiclesOnRadar = bHasRadarVehicles;

            bAddedOverlay = True;
        }
    }

/* Blow it, for some reason is LoginMenu always None, so I give up on this.
    if (!bAddedPanel)
    {
        // check for login menu
        if (GUIController(PC.Player.GUIController) != None && UT2K4PlayerLoginMenu(GUIController(PC.Player.GUIController).ActivePage) != None)
        {
            LoginMenu = UT2K4PlayerLoginMenu(GUIController(PC.Player.GUIController).ActivePage);
            if (LoginMenu != None && UT2k4OnslaughtLoginMenu(LoginMenu) == None)
            {
                Panel = MidGamePanel(LoginMenu.c_Main.AddTabItem(UltimateRadarMapPanel));
                if (Panel != None)
                    Panel.ModifiedChatRestriction = LoginMenu.UpdateChatRestriction;
            }
            bAddedPanel = True;
        }
    }
*/
}



// ============================================================================
// Hack:
// If some Mutator knows about us but doesn't want to deal with our
// variables and functions in particular because he doesn't want to compile us
// with him, he can use this method.
//
// By calling this very basic function that exists in the Actor class, he can use
// a plain A.IsA('UltimateRadarMap') and then A.HealDamage() to disable the
// radar stuff.
//
// I simply assume that no code out there would ever attempt to heal damage on
// an unknown Info class for whatever reason.
// But to be absolutely sure, the Amount must be less than 0. ;)
//
// I recommend this to happen before PostBeginPlay().
// ============================================================================
function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
    if (Amount < 0)
    {
        return True;
        bDisabled = True;
    }
    return False;
}

defaultproperties
{
     bShowOwnObjectiveCarrier=True
     bShowNonClassifiedGameObjectives=True
     bUseActorLocationAsMapCenter=True
     bNoDelete=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=1.000000
}
