class RadarMapUtils extends Actor
    notplaceable;

// Draw our actor on the map using iconmat 
static function DrawRadarMap(
    Canvas C, 
    ONSHUDOnslaught ONSHUD, 
    Actor A, 
    FinalBlend IconMat,
    float CenterPosX, 
    float CenterPosY, 
    float RadarWidth)
{
	local float CoreIconSize, MapScale, MapRadarWidth;
	local vector HUDLocation;
	local plane SavedModulation;
    local vector MapCenter;

	SavedModulation = C.ColorModulate;
    MapCenter = ONSHUD.MapCenter;

	C.ColorModulate.X = 1;
	C.ColorModulate.Y = 1;
	C.ColorModulate.Z = 1;
	C.ColorModulate.W = 1;
	C.Style = ERenderStyle.STY_Alpha;

    CoreIconSize = ONSHUD.IconScale * 64 * C.ClipX * ONSHUD.HUDScale/1600;
    CoreIconSize = CoreIconSize * 1.0;
	MapRadarWidth = RadarWidth;
    MapScale = MapRadarWidth/ONSHUD.RadarRange;

    HUDLocation = A.Location - MapCenter;
    HUDLocation.Z = 0;
    C.SetDrawColor(255,255,255,255);
    C.SetPos(CenterPosX + HUDLocation.X * MapScale - CoreIconSize * 0.5 * 0.5, CenterPosY + HUDLocation.Y * MapScale - CoreIconSize * 0.5 * 0.5);
    if(TexRotator(IconMat.Material) != None)
        TexRotator(IconMat.Material).Rotation.Yaw = -A.Rotation.Yaw - 16384;
    C.DrawTile(IconMat, CoreIconSize * 0.5, CoreIconSize * 0.5, 0, 0, 64, 64);

    C.ColorModulate = SavedModulation;
}

defaultproperties
{
    bHidden=true
    RemoteRole=ROLE_None
}