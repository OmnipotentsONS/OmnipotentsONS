//-----------------------------------------------------------------------------
// Ultimate Radar Map Overlay
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.09.2011 17:56:52 in Package: UltimateMappingTools$
//
// Shows the Radar Map in the player's HUD.
//-----------------------------------------------------------------------------
class UltimateRadarMapHUDOverlay extends HudOverlay
    dependsOn(UltimateRadarVehicleLRI);

#exec OBJ LOAD FILE=..\textures\UltimateMappingTools_Tex.utx



var bool bShowOwnObjectiveCarrier ;
var bool bShowEnemyObjectiveCarrier ;
var bool bShowNonClassifiedGameObjectives;
var bool bTrackVehiclesOnRadar;
var vector MapCenterLocation;


var PlayerController PCOwner ;
// The PlayerController that owns this HUDOverlay in his HUD.


var bool bMapDisabled ; // Can be toggled by the player.
var float RadarScale, RadarPosX, RadarPosY, RadarTrans, RadarRange, IconScale;


var UltimateRadarVehicleLRIMaster VehicleLRIMaster; // The manager of all radar-related vehicle replication. There should be only one at a time.


var array<GameObjective> Objectives; // Remember the Objectives for faster access.





// ============================================================================
// BeginPlay
//
// Initialize Interaction to bind F12 to toggle the RadarMap.
// ============================================================================

simulated event BeginPlay()
{
    local Interaction MyInteraction;

    PCOwner = Level.GetLocalPlayerController();


    if (PCOwner != None)
    {
        MyInteraction = PCOwner.Player.InteractionMaster.AddInteraction("UltimateMappingToolsOmni.UltimateRadarMapInteraction", PCOwner.Player); // Create the interaction.
        UltimateRadarMapInteraction(MyInteraction).ParentRadarMapHUDOverlay = self;
    }
}


// ============================================================================
// PostBeginPlay
//
// Set default values from ONSHUDOnslaught and find Flags.
// ============================================================================

simulated event PostBeginPlay()
{
    local GameObjective GO;
    local TerrainInfo T, PrimaryTerrain;


    // Determine primary terrain
    foreach AllActors(class'TerrainInfo', T)
    {
        PrimaryTerrain = T;
        if (T.Tag == 'PrimaryTerrain')
            Break;
    }

    // Set RadarMaxRange to size of primary terrain
    if (Level.bUseTerrainForRadarRange && PrimaryTerrain != None)
        RadarRange = abs(PrimaryTerrain.TerrainScale.X * PrimaryTerrain.TerrainMap.USize) / 2.0;
    else if (Level.CustomRadarRange > 0)
        RadarRange = Clamp(Level.CustomRadarRange, 500.0, class'ONSHUDOnslaught'.default.RadarMaxRange);


    RadarScale = class'ONSHUDOnslaught'.default.RadarScale;
    RadarPosX = class'ONSHUDOnslaught'.default.RadarPosX;
    RadarPosY = class'ONSHUDOnslaught'.default.RadarPosY;
    RadarTrans = class'ONSHUDOnslaught'.default.RadarTrans; // 255 by default.
    IconScale = class'ONSHUDOnslaught'.default.IconScale;


    foreach AllActors(class'GameObjective', GO)
    {
        if (GO != None)
        {
            Log(name @ "- found GameObjective" @ GO.name);
            Objectives[Objectives.Length] = GO;
        }
    }
}



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
    if (!Level.bShowRadarMap) { return false; }
    if (bMapDisabled) { return false; }

    if (PCOwner == None) { return false; }
    if (PCOwner.MyHud.bShowScoreboard) { return false; }
    if (PCOwner.MyHud.bShowDebugInfo) { return false; }
    if (PCOwner.MyHud.bShowVoteMenu) { return false; }
    if (PCOwner.MyHud.bShowLocalStats) { return false; }
    if (PCOwner.MyHud.bHideHud) { return false; }
    if (PCOwner.Pawn == None) { return false; }
    if (PCOwner.Pawn.bSpecialHud && !PCOwner.Pawn.IsA('Vehicle')) { return false; }  // Player is a Redeemer missile.
    if (PCOwner.ViewTarget != PCOwner.Pawn && ONSMortarCamera(PCOwner.ViewTarget) == None) { return false; }
    if (HUD_Assault(PCOwner.myHud) != None && !HUD_Assault(PCOwner.myHud).ObjectiveBoard.IsInState('Hidden')) { return false; }

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

    if (bDrawRadar())
    {
        C.Reset();

        RadarWidth = 0.5 * RadarScale * PCOwner.MyHud.HUDScale * C.ClipX;
        CenterRadarPosX = (RadarPosX * C.ClipX) - RadarWidth;
        CenterRadarPosY = (RadarPosY * C.ClipY) + RadarWidth;
        DrawRadar(C, CenterRadarPosX, CenterRadarPosY, RadarWidth, MapCenterLocation);
    }
}


// ============================================================================
// DrawRadar
//
// Draw the background image, the Flags, the Player and the border of the Radar
// Map screen.
// ============================================================================

simulated function DrawRadar (Canvas C, float CenterRadarPosX, float CenterRadarPosY, float RadarWidth, vector MapCenter)
{
    local float MapScale, PlayerIconSize, ObjectiveIconSize;
    local FinalBlend PlayerIcon;
    local byte ViewTeam, ObjectiveTeam, PawnTeam;
    local vector HUDLocation, ObjectiveLocation;
    local plane SavedModulation;
    local GameObjective CurGO;
    local Actor A;
    local int i;
    local Vehicle V;
    local UltimateRadarVehicleLRI CurLRI;

    if (PCOwner.Pawn == None)
        return;

    SavedModulation = C.ColorModulate; // Remember for later restoring.
    ObjectiveIconSize = IconScale * 16 * C.ClipX * PCOwner.myHUD.HUDScale / 1600;
    PlayerIconSize = ObjectiveIconSize * 1.5;
    MapScale = RadarWidth / RadarRange; // World-to-Map-scale
    ViewTeam = PCOwner.Pawn.GetTeamNum();


    // Make sure that the canvas style is alpha
    C.Style = ERenderStyle.STY_Alpha;

    // This draws all vehicles from UltimateVCTFFactories on the radar, if they are tracked.
    if (bTrackVehiclesOnRadar)
    {
        for (CurLRI = VehicleLRIMaster.FirstVehicleLRI; CurLRI != None; CurLRI = CurLRI.NextVehicleLRI)
        {
            V = CurLRI.TrackedVehicle;
            if (V == None || CurLRI.RadarTexRot == None)
                continue;

            PawnTeam = V.GetTeamNum();

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


    // Actually it's always 0,0,0
    if (PCOwner.myHUD.PawnOwner != None)
    {
        MapCenter.X = 0.0;
        MapCenter.Y = 0.0;
    }
    else
        MapCenter = vect(0,0,0);


    // At this point does the vector only store different informations that are
    // important to the background image.
    HUDLocation.X = RadarWidth;
    HUDLocation.Y = RadarRange;
    HUDLocation.Z = RadarTrans;

    // Draw the background image. Make sure you set one in the LevelProperties.
    class'ONSHUDOnslaught'.static.DrawMapImage(C, Level.RadarMapImage, CenterRadarPosX, CenterRadarPosY, MapCenter.X, MapCenter.Y, HUDLocation);



    // Draw Objectives
    for (i = 0; i < Objectives.Length; i++)
    {

        CurGO = Objectives[i];

        if (CurGO == None || !CurGO.IsActive())
        {
            continue;
        }


        // Draw Flags
        if (CTFBase(CurGO) != None)
        {
            if (CTFBase(CurGO).myFlag != None)
            {
                ObjectiveLocation = CTFBase(CurGO).myFlag.Position().Location;
                // Is either the location of the FlagBase, the FlagCarrier or the Flag itself.

                ObjectiveTeam = CurGO.DefenderTeamIndex;

                switch(ObjectiveTeam) // Team colour of the Flag.
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



                if (ObjectiveLocation == CTFBase(CurGO).Location) // Flag is home.
                {
                    HUDLocation = ObjectiveLocation - MapCenter;
                    HUDLocation.Z = 0;
                    if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
                    {
                        C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - ObjectiveIconSize/2,
                                  CenterRadarPosY + HUDLocation.Y * MapScale - 2 * ObjectiveIconSize );
                        C.DrawTile(Texture'HUDContent.Generic.HUD', ObjectiveIconSize * 2, ObjectiveIconSize * 2, 332, 128, 64, 80);
                    }
                }
                else // Flag is stolen!
                {
                    if ((CurGO.DefenderTeamIndex == ViewTeam && bShowOwnObjectiveCarrier)
                        || (CurGO.DefenderTeamIndex != ViewTeam && bShowEnemyObjectiveCarrier))
                    {
                        HUDLocation = ObjectiveLocation - MapCenter;
                        HUDLocation.Z = 0;
                        if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
                        {
                            C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - ObjectiveIconSize/2,
                                      CenterRadarPosY + HUDLocation.Y * MapScale - 2 * ObjectiveIconSize);
                            C.DrawTile(Material'HUDContent.Generic.HUDPulse', ObjectiveIconSize * 2, ObjectiveIconSize * 2, 332, 128, 64, 80);
                        }
                    }
                }
            }
        }
        else if (xBombSpawn(CurGO) != None) // Draw Bomb
        {
            if (xBombSpawn(CurGO).myFlag != None && xBombSpawn(CurGO).myFlag.HolderPRI != None && xBombSpawn(CurGO).myFlag.HolderPRI.Team != None)
                ObjectiveTeam = xBombSpawn(CurGO).myFlag.HolderPRI.Team.TeamIndex; // That's a freaky way to get a team number.
            else
                ObjectiveTeam = 255;

            switch(ObjectiveTeam) // Team colour of the Bomb.
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


            if (xBombSpawn(CurGO).myFlag != None)
            {
                if (ObjectiveTeam == 255 || (ObjectiveTeam == ViewTeam && bShowOwnObjectiveCarrier)
                        || (ObjectiveTeam != ViewTeam && bShowEnemyObjectiveCarrier))
                {

                    ObjectiveLocation = xBombSpawn(CurGO).myFlag.Position().Location;
                    // Is either the location of the BombSpawn, the BombCarrier or the Bomb itself.


                    HUDLocation = ObjectiveLocation - MapCenter;
                    HUDLocation.Z = 0;
                    if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
                    {
                        C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - ObjectiveIconSize * 0.75,
                                  CenterRadarPosY + HUDLocation.Y * MapScale - ObjectiveIconSize * 0.75 );
                        C.DrawTile(Texture'InterfaceContent.HUD.SkinA', ObjectiveIconSize * 1.5, ObjectiveIconSize * 1.5, 738, 536, 116, 116);
                    }
                }
            }
        }
        else if (xBombDelivery(CurGO) != None) // Draw Bomb goals
        {

            C.DrawColor = class'HUD'.default.WhiteColor;

            HUDLocation = CurGO.Location - MapCenter;
            HUDLocation.Z = 0;
            if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
            {
                C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - ObjectiveIconSize * 0.875,
                          CenterRadarPosY + HUDLocation.Y * MapScale - ObjectiveIconSize * 0.875 );
                C.DrawTile(FinalBlend'UltimateMappingTools_Tex.RadarMapIcons.BombingRunDeliveryRadar', ObjectiveIconSize * 1.75, ObjectiveIconSize * 1.75, 0, 0, 256, 256);
            }
        }
        else if (DominationPoint(CurGO) != None) // Draw Double Domination points
        {
            ObjectiveTeam = CurGO.DefenderTeamIndex;

            switch(ObjectiveTeam) // Team colour of the DomPoint.
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

            if (xDomPointA(CurGO) != None)
            {
                HUDLocation = CurGO.Location - MapCenter;
                HUDLocation.Z = 0;
                if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
                {
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - ObjectiveIconSize * 0.875,
                              CenterRadarPosY + HUDLocation.Y * MapScale - ObjectiveIconSize * 0.875 );
                    C.DrawTile(Texture'InterfaceContent.HUD.SkinA', ObjectiveIconSize * 1.75, ObjectiveIconSize * 1.75, 334, 512, 56, 56);
                }
            }
            else if (xDomPointB(CurGO) != None)
            {
                HUDLocation = CurGO.Location - MapCenter;
                HUDLocation.Z = 0;
                if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
                {
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - ObjectiveIconSize * 0.875,
                              CenterRadarPosY + HUDLocation.Y * MapScale - ObjectiveIconSize * 0.875 );
                    C.DrawTile(Texture'InterfaceContent.HUD.SkinA', ObjectiveIconSize * 1.75, ObjectiveIconSize * 1.75, 392, 512, 56, 56);
                }
            }
            else // Triple Domination point
            {
                HUDLocation = CurGO.Location - MapCenter;
                HUDLocation.Z = 0;
                if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
                {
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - ObjectiveIconSize * 0.4375,
                              CenterRadarPosY + HUDLocation.Y * MapScale - ObjectiveIconSize * 0.4375 );
                    C.DrawTile(Texture'HUDContent.Reticles.DomRing', ObjectiveIconSize * 1.75, ObjectiveIconSize * 0.875, 0, 0, 128, 128);
                }
            }
        }
        else if (bShowNonClassifiedGameObjectives) // Everything else that is currently active.
        {
            if (ASGameReplicationInfo(PCOwner.GameReplicationInfo) != None)
            {
                if (CurGO.ObjectivePriority == ASGameReplicationInfo(PCOwner.GameReplicationInfo).ObjectiveProgress)
                {
                    C.DrawColor = class'HUD'.default.WhiteColor;

                    HUDLocation = CurGO.Location - MapCenter;
                    HUDLocation.Z = 0;
                    if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
                    {
                        C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - ObjectiveIconSize * 0.75,
                                  CenterRadarPosY + HUDLocation.Y * MapScale - ObjectiveIconSize * 0.75 );
                        C.DrawTile(TexRotator'HUDContent.Reticles.rotReticle001', ObjectiveIconSize * 1.5, ObjectiveIconSize * 1.5, 0, 0, 256, 256);
                    }
                }
            }
            else // GameType is not Assault - last chance to draw the objectives.
            {
                C.DrawColor = class'HUD'.default.WhiteColor;

                HUDLocation = CurGO.Location - MapCenter;
                HUDLocation.Z = 0;
                if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
                {
                    C.SetPos( CenterRadarPosX + HUDLocation.X * MapScale - ObjectiveIconSize * 0.75,
                              CenterRadarPosY + HUDLocation.Y * MapScale - ObjectiveIconSize * 0.75 );
                    C.DrawTile(TexRotator'HUDContent.Reticles.rotReticle001', ObjectiveIconSize * 1.5, ObjectiveIconSize * 1.5, 0, 0, 256, 256);
                }
            }
        }
    }


    // Draw PlayerIcon
    if (PCOwner.myHUD.PawnOwner != None)
        A = PCOwner.myHUD.PawnOwner;
    else if (PCOwner.IsInState('Spectating'))
        A = PCOwner;
    else if (PCOwner.Pawn != None)
        A = PCOwner.Pawn;

    if (A != None)
    {
        PlayerIcon = FinalBlend'CurrentPlayerIconFinal';
        TexRotator(PlayerIcon.Material).Rotation.Yaw = -A.Rotation.Yaw - 16384;
        HUDLocation = A.Location - MapCenter;
        HUDLocation.Z = 0;
        if (HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
        {
            C.SetPos(CenterRadarPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5,
                      CenterRadarPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5);

            C.DrawColor = C.MakeColor(40,255,40);
            C.DrawTile(PlayerIcon, PlayerIconSize, PlayerIconSize, 0, 0, 64, 64);
        }
    }


    // Draw Border
    C.DrawColor = C.MakeColor(200,200,200);
    C.SetPos(CenterRadarPosX - RadarWidth, CenterRadarPosY - RadarWidth);
    C.DrawTile(Texture'ONSInterface-TX.MapBorderTEX', RadarWidth * 2.0, RadarWidth * 2.0, 0, 0, 256, 256);

    C.ColorModulate = SavedModulation;
}



/*
simulated function Tick(float DeltaTime)
{
    local UT2K4PlayerLoginMenu LoginMenu;
    local MidGamePanel Panel;

    // Check for login menu
    if (GUIController(PCOwner.Player.GUIController) != None && UT2K4PlayerLoginMenu(GUIController(PCOwner.Player.GUIController).ActivePage) != None)
    {
        LoginMenu = UT2K4PlayerLoginMenu(GUIController(PCOwner.Player.GUIController).ActivePage);
        if (LoginMenu != None)
        {
            Panel = MidGamePanel(LoginMenu.c_Main.AddTabItem(UltimateRadarMapPanel));
        }
        Disable('Tick');
    }
}
*/




// ============================================================================
// ToggleRadarMap
//
// Allows the user to disable the Radar Map if he doesn't like it.
// ============================================================================

function ToggleRadarMap()
{
    bMapDisabled = !bMapDisabled;
}

defaultproperties
{
}
