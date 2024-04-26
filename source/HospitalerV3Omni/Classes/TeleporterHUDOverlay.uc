class TeleporterHUDOverlay extends HUDOverlay;

var Vehicle Vehicle;
var FinalBlend VehicleIconRed;
var FinalBlend VehicleIconBlue;

simulated function Render(Canvas C)
{
    local ONSHUDOnslaught ONSHUD;
    local float RadarWidth, CenterRadarPosX, CenterRadarPosY;
    local FinalBlend Icon;

    ONSHUD = ONSHUDOnslaught(Owner);
    if(ONSHUD != None 
        && ONSHUD.PlayerOwner != None 
        && ONSHUD.PlayerOwner.GetTeamNum() == Vehicle.GetTeamNum() 
        && !ONSHUD.PlayerOwner.IsInState('Dead')
        && !ONSHUD.PlayerOwner.IsInState('PlayerWaiting'))
    {
        if (Level.bShowRadarMap && !ONSHUD.bMapDisabled)
        {
            Icon = VehicleIconRed;
            if(Vehicle.GetTeamNum() == 1)
                Icon = VehicleIconBlue;

            RadarWidth = 0.5 * ONSHUD.RadarScale * ONSHUD.HUDScale * C.ClipX;
            CenterRadarPosX = (ONSHUD.RadarPosX * C.ClipX) - RadarWidth;
            CenterRadarPosY = (ONSHUD.RadarPosY * C.ClipY) + RadarWidth;
            class'RadarMapUtils'.static.DrawRadarMap(C, ONSHUD, Vehicle, Icon, CenterRadarPosX, CenterRadarPosY, RadarWidth);
        }        
    }
}

defaultproperties
{
    VehicleIconRed=FinalBlend'HosRedFB'
    VehicleIconBlue=FinalBlend'HosBlueFB'
}