//=============================================================================
// HUDOverlay for UltimateONSFactory
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 13.10.2011 21:31:52 in Package: UltimateMappingTools$
//
// This Overlay displays the location of a Vehicle on the RadarMap in realtime.
//=============================================================================
class UltimateRadarVehicleHUDOverlay extends HudOverlay
    dependson(UltimateRadarVehicleLRI);



var PlayerController PCOwner;
// The PlayerController that owns this HUDOverlay in his HUD.

var ONSHudOnslaught ONSHUD;


var UltimateRadarVehicleLRIMaster VehicleLRIMaster;
// The manager of all radar-related vehicle replication. There should be only one at a time.


var float RadarScale, RadarPosX, RadarPosY, RadarTrans, RadarRange, OnsIconScale;


// ============================================================================
// Tick
//
// Finds the one and only VehicleLRIMaster and reference it. Sets some variables
// to values with which we can work. We can't use PostBeginPlay for this because
// the actor is not yet ready at that time.
// ============================================================================

simulated event Tick(float DeltaTime)
{
   foreach DynamicActors(class'UltimateRadarVehicleLRIMaster',VehicleLRIMaster)
   {
      PCOwner = HUD(Owner).PlayerOwner;
      ONSHUD = ONSHUDOnslaught(Owner);

      RadarRange = ONSHUD.RadarRange;

      RadarScale = class'ONSHUDOnslaught'.default.RadarScale;
      RadarPosX = class'ONSHUDOnslaught'.default.RadarPosX;
      RadarPosY = class'ONSHUDOnslaught'.default.RadarPosY;
      RadarTrans = class'ONSHUDOnslaught'.default.RadarTrans;
      OnsIconScale = class'ONSHUDOnslaught'.default.IconScale;
      Disable('Tick');
      break;
   }
}


// ============================================================================
// bDrawRadar
//
// This function determines if we want to draw the radar or not.
// ============================================================================

simulated function bool bDrawRadar()
{
    if (ONSHUD == None) { return false; }
    if (!ONSHUD.Level.bShowRadarMap) { return false; }
    if (ONSHud.bMapDisabled) { return false; }

    //Code to set radar size for when the tab pops up
    // FIXME: This is probably not working, so either fix or remove it.
    RadarPosX = ONSHUD.RadarPosX;
    RadarPosY = ONSHUD.RadarPosY;
    RadarScale = ONSHUD.RadarScale;
    RadarTrans = ONSHUD.RadarTrans;
    ONSIconScale = ONSHUD.IconScale;

    if (PCOwner == None) {return false; }
    if (PCOwner.MyHud.bShowScoreboard) { return false; }
    if (PCOwner.MyHud.bShowDebugInfo) { return false; }
    if (PCOwner.MyHud.bShowVoteMenu) { return false; }
    if (PCOwner.MyHud.bShowLocalStats) { return false; }
    if (PCOwner.MyHud.bHideHud) { return false; }
    if (PCOwner.Pawn == None) { return false; }
    if (PCOwner.Pawn.bSpecialHud && !PCOwner.Pawn.IsA('Vehicle')) { return false; }  // Player is a Redeemer missile.
    if (PCOwner.ViewTarget != PCOwner.Pawn && ONSMortarCamera(PCOwner.ViewTarget) == None) { return false; }

    return true;
}


// ============================================================================
// Render
//
// Do some calculations on the shape of the radar map and deliver the Canvas to
// the DrawRadar-function.
// ============================================================================

simulated function Render(Canvas C)
{
    local float RadarWidth, CenterRadarPosX, CenterRadarPosY;
    local vector MapCenter;
//  local int i;
//  local Player ViewportOwner;
//  local GUITabControl LoginMenuTabs;
//  local UT2K4Tab_OnslaughtMap Panel;

    if (bDrawRadar())
    {
        C.Reset();

        RadarWidth = 0.5 * RadarScale * PCOwner.MyHud.HUDScale * C.ClipX;
        CenterRadarPosX = (RadarPosX * C.ClipX) - RadarWidth;
        CenterRadarPosY = (RadarPosY * C.ClipY) + RadarWidth;
        DrawRadar(C, CenterRadarPosX, CenterRadarPosY, RadarWidth, MapCenter);
    }

    /*
        Log("Checking MidGamePanel1");
        if (Level.GetLocalPlayerController() != None)
            ViewportOwner = Level.GetLocalPlayerController().Player;

        Log("Checking MidGamePanel2");

        // ActivePage is always None, that's why I don't implement this.
        if (ONSHUD != None && ViewportOwner != None && GUIController(ViewportOwner.GUIController) != None && UT2K4PlayerLoginMenu(GUIController(ViewportOwner.GUIController).ActivePage) != None)
        {
            LoginMenuTabs = UT2K4PlayerLoginMenu(GUIController(ViewportOwner.GUIController).ActivePage).c_Main;
            if (LoginMenuTabs != None)
            {
            Log("Checking MidGamePanel3");
                for (i = 0; i < LoginMenuTabs.TabStack.Length; ++i)
                {
                    if (UT2K4Tab_OnslaughtMap(LoginMenuTabs.TabStack[i].MyPanel) != None)
                    {
                        Log("Checking MidGamePanel4");
                        Panel = UT2K4Tab_OnslaughtMap(LoginMenuTabs.TabStack[i].MyPanel);
                        DrawRadar(C, Panel.OnslaughtMapCenterX, Panel.OnslaughtMapCenterY, Panel.OnslaughtMapRadius, MapCenter);
                        break;
                    }
                }
            }
        }
    */
}


// ============================================================================
// DrawRadar
//
// Iterates through all VehicleLRIs and determines according to their settings
// if the owner of this HUDOverlay should draw the vehicle on the radar or not.
// Then it draws the TexRotator of the VehicleLRI at the correct position on the
// radar map by scaling it by the correct factor. (World to Map)
// ============================================================================

simulated function DrawRadar (Canvas C, float CenterRadarPosX, float CenterRadarPosY, float RadarWidth, vector MapCenter)
{
    local float MapScale, PlayerIconSize;
    local int ViewTeam, PawnTeam;
    local vector HUDLocation;
    local Vehicle V;
    local UltimateRadarVehicleLRI CurLRI;

    if (PCOwner.Pawn == None)
        return;

    PlayerIconSize = ONSIconScale * 16 * C.ClipX * PCOwner.myHUD.HUDScale / 1600 * 1.5;
    MapScale = RadarWidth / RadarRange;
    ViewTeam = PCOwner.Pawn.GetTeamNum();

    for (CurLRI = VehicleLRIMaster.FirstVehicleLRI; CurLRI != None; CurLRI = CurLRI.NextVehicleLRI)
    {
        if (!CurLRI.bMarkerMode)
        {
            V = CurLRI.TrackedVehicle;
            if (V == None || CurLRI.RadarTexRot == None || (!CurLRI.bRadarVisibleToDriver && V.Controller == Level.GetLocalPlayerController()))
                continue;

            PawnTeam = V.GetTeamNum();
        }
        else
        {
            PawnTeam = 255;
        }

        switch(PawnTeam) // Team colour of the vehicle.
        {
            case 0:
                C.DrawColor = class'HUD'.default.RedColor;
                break;
            case 1:
                C.DrawColor = class'HUD'.default.BlueColor;
                break;
            case 2:
                C.DrawColor = class'HUD'.default.GreenColor;
                break;
            case 3:
                C.DrawColor = class'HUD'.default.GoldColor;
                break;
            default:
                C.DrawColor = class'HUD'.default.WhiteColor;
                break;
        }

        if (ViewTeam == PawnTeam)
        {
            if (CurLRI.bRadarFadeWithOwnerUpdateTime)
                C.SetDrawColor(C.DrawColor.R, C.DrawColor.G, C.DrawColor.B, Int(Lerp((CurLRI.PassedTime/CurLRI.RadarOwnerUpdateTime), 0, 255, True)));
        }
        else if (CurLRI.bRadarFadeWithEnemyUpdateTime)
            C.SetDrawColor(C.DrawColor.R, C.DrawColor.G, C.DrawColor.B, Int(Lerp((CurLRI.PassedTimeEnemy/CurLRI.RadarEnemyUpdateTime), 0, 255, True)));

        switch(CurLRI.RadarVehicleVisibility)
        {
            case RVV_Always:
                if (ViewTeam == PawnTeam)
                {
                    HUDLocation = CurLRI.VehicleLocation - MapCenter;
                    HUDLocation.Z = 0;
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2,
                              CenterRadarPosY + HUDLocation.Y * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2);
                    C.DrawTileScaled(CurLRI.RadarTexRot, PlayerIconSize/CurLRI.RadarMaterial.MaterialUSize() * CurLRI.RadarTextureScale, PlayerIconSize/CurLRI.RadarMaterial.MaterialVSize() * CurLRI.RadarTextureScale);
                }
                else if (ViewTeam != PawnTeam)
                {
                    HUDLocation = CurLRI.VehicleLocationEnemy - MapCenter;
                    HUDLocation.Z = 0;
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2,
                              CenterRadarPosY + HUDLocation.Y * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2);
                    C.DrawTileScaled(CurLRI.RadarTexRot, PlayerIconSize/CurLRI.RadarMaterial.MaterialUSize() * CurLRI.RadarTextureScale, PlayerIconSize/CurLRI.RadarMaterial.MaterialVSize() * CurLRI.RadarTextureScale);
                }
                break;
            case RVV_DriverTeam:
                if (ViewTeam == PawnTeam)
                {
                    if (PawnTeam == CurLRI.OldOwnerTeam)
                        HUDLocation = CurLRI.VehicleLocation - MapCenter;
                    else
                        HUDLocation = CurLRI.VehicleLocationEnemy - MapCenter;
                    HUDLocation.Z = 0;
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2,
                              CenterRadarPosY + HUDLocation.Y * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2);
                    C.DrawTileScaled(CurLRI.RadarTexRot, PlayerIconSize/CurLRI.RadarMaterial.MaterialUSize() * CurLRI.RadarTextureScale, PlayerIconSize/CurLRI.RadarMaterial.MaterialVSize() * CurLRI.RadarTextureScale);
                }
                break;
            case RVV_DriverEnemy:
                if (ViewTeam != PawnTeam)
                {
                    if (PawnTeam == CurLRI.OldOwnerTeam)
                        HUDLocation = CurLRI.VehicleLocation - MapCenter;
                    else
                        HUDLocation = CurLRI.VehicleLocationEnemy - MapCenter;
                    HUDLocation.Z = 0;
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2,
                              CenterRadarPosY + HUDLocation.Y * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2);
                    C.DrawTileScaled(CurLRI.RadarTexRot, PlayerIconSize/CurLRI.RadarMaterial.MaterialUSize() * CurLRI.RadarTextureScale, PlayerIconSize/CurLRI.RadarMaterial.MaterialVSize() * CurLRI.RadarTextureScale);
                }
                break;
            case RVV_OriginalTeam:
                if (ViewTeam == CurLRI.OldOwnerTeam)
                {
                    if (PawnTeam == CurLRI.OldOwnerTeam)
                        HUDLocation = CurLRI.VehicleLocation - MapCenter;
                    else
                        HUDLocation = CurLRI.VehicleLocationEnemy - MapCenter;
                    HUDLocation.Z = 0;
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2,
                              CenterRadarPosY + HUDLocation.Y * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2);
                    C.DrawTileScaled(CurLRI.RadarTexRot, PlayerIconSize/CurLRI.RadarMaterial.MaterialUSize() * CurLRI.RadarTextureScale, PlayerIconSize/CurLRI.RadarMaterial.MaterialVSize() * CurLRI.RadarTextureScale);
                }
                break;
            case RVV_OriginalTeamAndHijacker:
                if (ViewTeam == CurLRI.OldOwnerTeam || ViewTeam == PawnTeam)
                {
                    if (ViewTeam == CurLRI.OldOwnerTeam)
                        HUDLocation = CurLRI.VehicleLocation - MapCenter;
                    else
                        HUDLocation = CurLRI.VehicleLocationEnemy - MapCenter;
                    HUDLocation.Z = 0;
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2,
                              CenterRadarPosY + HUDLocation.Y * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2);
                    C.DrawTileScaled(CurLRI.RadarTexRot, PlayerIconSize/CurLRI.RadarMaterial.MaterialUSize() * CurLRI.RadarTextureScale, PlayerIconSize/CurLRI.RadarMaterial.MaterialVSize() * CurLRI.RadarTextureScale);
                }
                break;
            case RVV_OriginalEnemy:
                if (ViewTeam != CurLRI.OldOwnerTeam)
                {
                    if (PawnTeam == CurLRI.OldOwnerTeam)
                        HUDLocation = CurLRI.VehicleLocation - MapCenter;
                    else
                        HUDLocation = CurLRI.VehicleLocationEnemy - MapCenter;
                    HUDLocation.Z = 0;
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2,
                              CenterRadarPosY + HUDLocation.Y * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2);
                    C.DrawTileScaled(CurLRI.RadarTexRot, PlayerIconSize/CurLRI.RadarMaterial.MaterialUSize() * CurLRI.RadarTextureScale, PlayerIconSize/CurLRI.RadarMaterial.MaterialVSize() * CurLRI.RadarTextureScale);
                }
                break;
            case RVV_OriginalEnemyAndHijacker:
                if (ViewTeam != CurLRI.OldOwnerTeam || ViewTeam == PawnTeam)
                {
                    if (ViewTeam == CurLRI.OldOwnerTeam)
                        HUDLocation = CurLRI.VehicleLocation - MapCenter;
                    else
                        HUDLocation = CurLRI.VehicleLocationEnemy - MapCenter;
                    HUDLocation.Z = 0;
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2,
                              CenterRadarPosY + HUDLocation.Y * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2);
                    C.DrawTileScaled(CurLRI.RadarTexRot, PlayerIconSize/CurLRI.RadarMaterial.MaterialUSize() * CurLRI.RadarTextureScale, PlayerIconSize/CurLRI.RadarMaterial.MaterialVSize() * CurLRI.RadarTextureScale);
                }
                break;
            case RVV_OnlyWhenOwned:
                if (ViewTeam == CurLRI.OldOwnerTeam && ViewTeam == PawnTeam)
                {
                    HUDLocation = CurLRI.VehicleLocation - MapCenter;
                    HUDLocation.Z = 0;
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2,
                              CenterRadarPosY + HUDLocation.Y * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2);
                    C.DrawTileScaled(CurLRI.RadarTexRot, PlayerIconSize/CurLRI.RadarMaterial.MaterialUSize() * CurLRI.RadarTextureScale, PlayerIconSize/CurLRI.RadarMaterial.MaterialVSize() * CurLRI.RadarTextureScale);
                }
                break;
            case RVV_OnlyWhenHijacked:
                if (ViewTeam == CurLRI.OldOwnerTeam && ViewTeam != PawnTeam)
                {
                    HUDLocation = CurLRI.VehicleLocation - MapCenter;
                    HUDLocation.Z = 0;
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2,
                              CenterRadarPosY + HUDLocation.Y * MapScale - PlayerIconSize * CurLRI.RadarTextureScale / 2);
                    C.DrawTileScaled(CurLRI.RadarTexRot, PlayerIconSize/CurLRI.RadarMaterial.MaterialUSize() * CurLRI.RadarTextureScale, PlayerIconSize/CurLRI.RadarMaterial.MaterialVSize() * CurLRI.RadarTextureScale);
                }
                break;
        }
    }
}


//=============================================================================
// Default Values
//=============================================================================

defaultproperties
{
}
