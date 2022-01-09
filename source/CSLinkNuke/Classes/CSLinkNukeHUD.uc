class CSLinkNukeHUD extends ONSHUDOnslaught;

#exec TEXTURE IMPORT FILE=Textures\nuke-icon.tga FLAGS=2

simulated static function bool WorldToScreen( vector worldLocation, out vector ScreenPos, float ScreenX, float ScreenY, float RadarWidth, float Range, vector Center, optional bool bIgnoreRange )
{
	local vector ScreenLocation;
	local float Dist;

	if ( worldLocation == vect(0,0,0) )
		return false;

    ScreenLocation = worldLocation - Center;
    ScreenLocation.Z = 0;
	Dist = VSize(ScreenLocation);
	if ( bIgnoreRange || (Dist < (Range * 0.95)) )
	{
        ScreenPos.X = ScreenX + ScreenLocation.X * (RadarWidth/Range);
        ScreenPos.Y = ScreenY + ScreenLocation.Y * (RadarWidth/Range);
        ScreenPos.Z = 0;
        return true;
    }

    return false;
}

simulated function DrawNukeOnMap(Canvas C, float CenterPosX, float CenterPosY, float RadarWidth, vector worldLocation)
{
	local vector screenPos;

    if(worldLocation == vect(0,0,0))
        return;

    if(WorldToScreen(worldLocation, screenPos, CenterPosX-16, CenterPosY-16, RadarWidth, self.RadarRange, self.MapCenter))
    {
        C.Style = ERenderStyle.STY_Alpha;
        C.SetPos(screenPos.X , screenPos.Y);
        C.DrawIcon(Texture'CSLinkNuke.nuke-icon', 1.0);
    }
}

simulated function DrawRadarMap(Canvas C, float CenterPosX, float CenterPosY, float RadarWidth, bool bShowDisabledNodes)
{
    local MutLinkNukeRadar radar;
    super.DrawRadarMap(C, CenterPosX, CenterPosY, RadarWidth, bShowDisabledNodes);

    foreach DynamicActors(class'CSLinkNuke.MutLinkNukeRadar', radar)
    {
        DrawNukeOnMap(C, CenterPosX, CenterPosY, RadarWidth, radar.p0);
        DrawNukeOnMap(C, CenterPosX, CenterPosY, RadarWidth, radar.p1);
        DrawNukeOnMap(C, CenterPosX, CenterPosY, RadarWidth, radar.p2);
        DrawNukeOnMap(C, CenterPosX, CenterPosY, RadarWidth, radar.p3);
        DrawNukeOnMap(C, CenterPosX, CenterPosY, RadarWidth, radar.p4);
        DrawNukeOnMap(C, CenterPosX, CenterPosY, RadarWidth, radar.p5);
        DrawNukeOnMap(C, CenterPosX, CenterPosY, RadarWidth, radar.p6);
        DrawNukeOnMap(C, CenterPosX, CenterPosY, RadarWidth, radar.p7);
        DrawNukeOnMap(C, CenterPosX, CenterPosY, RadarWidth, radar.p8);
        DrawNukeOnMap(C, CenterPosX, CenterPosY, RadarWidth, radar.p9);
    }
}

defaultproperties
{
}