class TeleporterReplicationInfo extends LinkedReplicationInfo;

var UT2K4Tab_OnslaughtMap Tab_ONSMap;
var Name VehicleClassName;
var FinalBlend VehicleIconRed;
var FinalBlend VehicleIconBlue;

delegate bool OldOnDraw(Canvas C);
delegate bool OldOnClick(GUIComponent sender);

replication
{
	reliable if(Role==ROLE_Authority)
        ClientCloseMenu;

    reliable if(Role<ROLE_Authority)
        ServerTeleportToVehicle, ServerTeleportToCore;

}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();

    if(Level.NetMode == NM_DedicatedServer)
        return;

    SetTimer(1.0, true);
}

simulated function Timer()
{
    if(Tab_ONSMap == None)
        DoSetup();
    else
    {
        SetTimer(0.0,false);
    }
}

static function AddInfo(Controller C)
{
    local LinkedReplicationInfo LRI;

    if(C != None && C.PlayerReplicationInfo != None)
    {
        if(C.PlayerReplicationInfo.CustomReplicationInfo == None)
        {
            C.PlayerReplicationInfo.CustomReplicationInfo = C.spawn(class'TeleporterReplicationInfo', C);
            return;
        }
        else
        {
            for(LRI = C.PlayerReplicationInfo.CustomReplicationInfo;LRI!=None;LRI = LRI.NextReplicationInfo)
            {
                if(TeleporterReplicationInfo(LRI) != None)
                    return;

                if(LRI.NextReplicationInfo == None)
                {
                    LRI.NextReplicationInfo = C.spawn(class'TeleporterReplicationInfo', C);
                    return;
                }
            }
        }
    }
}

static function TeleporterReplicationInfo GetInfo(Controller C)
{
    local LinkedReplicationInfo LRI;
    for(LRI = C.PlayerReplicationInfo.CustomReplicationInfo;LRI!=None;LRI = LRI.NextReplicationInfo)
    {
        if(TeleporterReplicationInfo(LRI) != None)
            return TeleporterReplicationInfo(LRI);
    }

    return None;
}

simulated function ClientCloseMenu()
{
    if(Tab_ONSMap != None && Tab_ONSMap.Controller != None)
        Tab_ONSMap.Controller.CloseMenu(false);
}

function bool ServerTeleportToVehicle(Vehicle V, PlayerController PC)
{
    local int i;
    local vector PrevLocation;

    if(Role<ROLE_Authority)
    {
        return false;
    }

    if(PC.Pawn == None || PC.IsInState('Dead'))
        Level.Game.RestartPlayer(PC);

    for(i=0;i<V.ExitPositions.Length;i++)
    {
        if(PC.Pawn != None && PC.IsInState('PlayerWalking'))
        {
            PrevLocation = PC.Pawn.Location;
            if(PC.Pawn.SetLocation(V.Location + V.ExitPositions[i]))
            {
                if(xPawn(PC.Pawn) != None)
                {
                    xPawn(PC.Pawn).DoTranslocateOut(PrevLocation);
                    xPawn(PC.Pawn).PlayTeleportEffect(false, false);
                }

                return true;
            }
        }
    }

    return false;
}

function ServerTeleportToCore(ONSPowerCore Core, PlayerController PC)
{
    local ONSPlayerReplicationInfo PRI;
    local GameRules GR;
    local ONSPowerCore OldStartCore;

    if(Role<ROLE_Authority)
    {
        return;
    }

    PRI = ONSPlayerReplicationInfo(PC.PlayerReplicationInfo);
    if(PRI != None && PC.IsInState('PlayerWalking'))
    {
        // SetStartCore won't work here because it checks if you 
        // are touching a node, here we are touching hospitaler
        //PRI.SetStartCore(Core, true);
        OldStartCore = PRI.StartCore;
        PRI.TemporaryStartCore = Core;
        PRI.StartCore = Core;

        // HUGE HACK HERE
        // DoTeleport calls FindPlayerStart which uses GameRulesModifiers if available
        // We want base ONS DoTeleport only, no modified version like ONSPlus 
        // so we temporarily remove game rules modifiers when calling these
        GR = Level.Game.GameRulesModifiers;
        Level.Game.GameRulesModifiers = None;

        //two tries (base engine code also does this)
        if(!PRI.DoTeleport() && !PRI.DoTeleport())
        {
        }
        // restore gamerulesmodifiers
        Level.Game.GameRulesModifiers = GR;

        // restore core
        PRI.StartCore = OldStartCore;

        ClientCloseMenu();
    }
}

// Replace GUITab map draw routine with custom
simulated function bool OnDraw(Canvas C)
{
    local bool retval;
    local ONSHUDOnslaught ONSHUD;
    local PlayerController PC;
    local float RadarWidth, CenterRadarPosX, CenterRadarPosY;
    local float HS;
    local FinalBlend VehicleIcon;
    local Vehicle V;

    retval =  OldOnDraw(C);

    if(Tab_ONSMap == None)
        foreach AllObjects(class'UT2K4Tab_OnslaughtMap', Tab_ONSMap)
             break;

    PC = Level.GetLocalPlayerController();
    if(PC != None)
        ONSHUD = ONSHUDOnslaught(PC.myHUD);

    V = LocateVehicle(Tab_ONSMap.Controller.MouseX - Tab_ONSMap.OnslaughtMapCenterX, Tab_ONSMap.Controller.MouseY - Tab_ONSMap.OnslaughtMapCenterY, Tab_ONSMap.OnslaughtMapRadius);
    if(V != None)
    {
        if(V.GetTeamNum() == PC.GetTeamNum())
        {
            VehicleIcon = VehicleIconRed;
            if(V.GetTeamNum() == 1)
                VehicleIcon = VehicleIconBlue;

            if(PC.IsInState('Dead'))
            {
                Tab_ONSMap.l_HintText.Caption = "Click on "$V.VehicleNameString$" to respawn";
                Tab_ONSMap.l_HelpText.Caption = V.VehicleNameString;
            }
            else
            {
                Tab_ONSMap.l_HintText.Caption = "Click on "$V.VehicleNameString$" to teleport";
                Tab_ONSMap.l_HelpText.Caption = V.VehicleNameString;
            }
            Tab_ONSMap.SetHintImage(VehicleIcon, 0, 0, 64, 64);
        }
    }

    foreach DynamicActors(class'Vehicle', V)
    {
        if (V != None && V.IsA(VehicleClassName) && Level.bShowRadarMap && ONSHUD != None && !ONSHUD.bMapDisabled && Tab_ONSMap != None && PC.GetTeamNum() == V.GetTeamNum())
        {
            if (Level.bShowRadarMap && !ONSHUD.bMapDisabled)
            {
                RadarWidth = Tab_ONSMap.OnslaughtMapRadius;
                CenterRadarPosX = Tab_ONSMap.OnslaughtMapCenterX;
                CenterRadarPosY = Tab_ONSMap.OnslaughtMapCenterY;
                HS=ONSHUD.HudScale;
                ONSHUD.HudScale=1.0;
                VehicleIcon = VehicleIconRed;
                if(V.GetTeamNum() == 1)
                    VehicleIcon = VehicleIconBlue;

                class'RadarMapUtils'.static.DrawRadarMap(C, ONSHUD, V, VehicleIcon, CenterRadarPosX, CenterRadarPosY, RadarWidth);
                ONSHUD.HudScale=HS;
            }    
        }  
    }

    return retval;
}

simulated function bool OnClick(GUIComponent sender)
{
    local Vehicle V;
    local PlayerController PC;
    local ONSPowerCore Core;

    PC = Level.GetLocalPlayerController();
    if(PC != None && PC.PlayerReplicationInfo != None && !PC.PlayerReplicationInfo.bOnlySpectator)
    {
        V = LocateVehicle(Tab_ONSMap.Controller.MouseX - Tab_ONSMap.OnslaughtMapCenterX, Tab_ONSMap.Controller.MouseY - Tab_ONSMap.OnslaughtMapCenterY, Tab_ONSMap.OnslaughtMapRadius);
        if(V != None && V.GetTeamNum() == PC.GetTeamNum())
        {
            ClientCloseMenu();

            if(CanTeleport(PC))
            {
                //two tries
                if(!ServerTeleportToVehicle(V, PC) && !ServerTeleportToVehicle(V, PC))
                {
                }
            }

            return true;
        }

        Core = LocateCore(Tab_ONSMap.Controller.MouseX - Tab_ONSMap.OnslaughtMapCenterX, Tab_ONSMap.Controller.MouseY - Tab_ONSMap.OnslaughtMapCenterY, Tab_ONSMap.OnslaughtMapRadius);
        if(Core != None && ((Core.PoweredBy(PC.GetTeamNum()) && Core.CoreStage==0) || (Core.bFinalCore && Core.DefenderTeamIndex == PC.GetTeamNum())))
        {
            ClientCloseMenu();

            if(CanTeleport(PC))
                ServerTeleportToCore(Core, PC);

            return true;
        }
    }

    return OldOnClick(sender);
}

// check if click on radar map clicked a hospitilar
simulated function Vehicle LocateVehicle(float PosX, float PosY, float RadarWidth)
{
    local float WorldToMapScaleFactor, Distance, LowestDistance;
    local vector WorldLocation, DistanceVector;
    local Vehicle BestV, V;
    local ONSHUDOnslaught ONSHUD;

    ONSHUD = ONSHUDOnslaught(Level.GetLocalPlayerController().myHUD);
    if(ONSHUD == None)
        return None;

    WorldToMapScaleFactor = ONSHUD.RadarRange/RadarWidth;

    WorldLocation.X = PosX * WorldToMapScaleFactor;
    WorldLocation.Y = PosY * WorldToMapScaleFactor;

    LowestDistance = 2500.0;

    foreach DynamicActors(class'Vehicle', V)
    {
        if(V.IsA(VehicleClassName))
        {
            DistanceVector = V.Location - WorldLocation;
            DistanceVector.Z = 0;
            Distance = VSize(DistanceVector);
            if (Distance < LowestDistance)
            {
                BestV = V;
                LowestDistance = Distance;
            }
        }
    }

    return BestV;   
}

// check if click on map clicked on a core
simulated function ONSPowerCore LocateCore(float PosX, float PosY, float RadarWidth)
{
    local float WorldToMapScaleFactor, Distance, LowestDistance;
    local vector WorldLocation, DistanceVector;
    local ONSPowerCore BestCore, Core;
    local ONSHUDOnslaught ONSHUD;

    ONSHUD = ONSHUDOnslaught(Level.GetLocalPlayerController().myHUD);
    if(ONSHUD == None)
        return None;

    WorldToMapScaleFactor = ONSHUD.RadarRange/RadarWidth;

    WorldLocation.X = PosX * WorldToMapScaleFactor;
    WorldLocation.Y = PosY * WorldToMapScaleFactor;

    LowestDistance = 2500.0;

    foreach DynamicActors(class'ONSPowerCore', Core)
    {
        DistanceVector = Core.Location - WorldLocation;
        DistanceVector.Z = 0;
		Distance = VSize(DistanceVector);
        if (Distance < LowestDistance)
        {
            BestCore = Core;
            LowestDistance = Distance;
        }
    }

    return BestCore;   
}

//return true if
// 1. we are next to one of our teams vehicles
// 2. we are touching power node/core
simulated function bool CanTeleport(PlayerController PC)
{
    local Vehicle V;
    local vector DistanceVector;
    local float Distance, LowestDistance;
    local ONSPlayerReplicationInfo PRI;
    local ONSPowerCore currentNode;

    if(PC.IsInState('Dead'))
    {
        return true;
    }


    LowestDistance=1000.0;
    foreach DynamicActors(class'Vehicle', V)
    {
        if(V != None && V.IsA(VehicleClassName) && PC.GetTeamNum() == V.GetTeamNum() && PC.Pawn != None)
        {
            DistanceVector = V.Location - PC.Pawn.Location;
            Distance = VSize(DistanceVector);
            if (Distance < LowestDistance)
            {
                return true;
            }
        }
    }

    PRI = ONSPlayerReplicationInfo(PC.PlayerReplicationInfo);
    if(PRI != None)
    {
        //currentNode = PRI.GetCurrentNode();
        currentNode = GetCurrentNode(PRI);
        return currentNode != None;
    }

    return false;
}

simulated function ONSPowerCore GetCurrentNode(ONSPlayerReplicationInfo PRI)
{
    local ONSPowerCore Core;
	local ONSPCTeleportTrigger T;
    local ONSTeleportPad Pad;
    local ONSPowerCoreShield Shield;

	if (Controller(PRI.Owner).Pawn != None)
	{
		if (Controller(PRI.Owner).Pawn.Base != None)
		{
			Core = ONSPowerCore(Controller(PRI.Owner).Pawn.Base);
			if (Core == None)
				Core = ONSPowerCore(Controller(PRI.Owner).Pawn.Base.Owner);
		}

		if (Core == None)
        {
			foreach Controller(PRI.Owner).Pawn.TouchingActors(class'ONSPCTeleportTrigger', T)
			{
				Core = ONSPowerCore(T.Owner);
				if (Core != None)
					break;
			}
        }
        
		if (Core == None)
        {
			foreach Controller(PRI.Owner).Pawn.TouchingActors(class'ONSPowerCore', Core)
                break;

        }
		if (Core == None)
        {
			foreach Controller(PRI.Owner).Pawn.TouchingActors(class'ONSTeleportPad', Pad)
                break;

            if(Pad != None)
                Core = ONSPowerCore(Pad.Owner);
        }
		if (Core == None)
        {
			foreach Controller(PRI.Owner).Pawn.TouchingActors(class'ONSPowerCoreShield', Shield)
                break;

            if(Shield != None)
                Core = ONSPowerCore(Shield.Owner);
        }
	}


	if (Core != None && Core.CoreStage == 0 && Core.DefenderTeamIndex == PRI.Team.TeamIndex)
		return Core;

	return None;
}

simulated function DoSetup()
{
    if(Tab_ONSMap == None)
        foreach AllObjects(class'UT2K4Tab_OnslaughtMap', Tab_ONSMap)
            break;

    if(Tab_ONSMap != None)
    {
        // thankfully the gui controls all use delegates so we can patch them up with
        // different function pointers
        OldOnDraw = Tab_ONSMap.i_Background.OnDraw;
        Tab_ONSMap.i_Background.OnDraw = OnDraw;
        OldOnClick = Tab_ONSMap.i_Background.OnClick;
        Tab_ONSMap.i_Background.OnClick = OnClick;
    }
}

defaultproperties
{
    VehicleClassName="HospitalerV3Omni"
    VehicleIconRed=FinalBlend'HosRedFB'
    VehicleIconBlue=FinalBlend'HosBlueFB'
    NetUpdateFrequency=100
}