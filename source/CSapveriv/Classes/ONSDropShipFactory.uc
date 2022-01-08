//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSDropShipFactory extends ONSVehicleFactory;

var(HUD) bool bEnhancedHud;
var(HUD) float EnhancedHudRange;

function SpawnVehicle()
{
    local DropShipKarma dropship;
    super.SpawnVehicle();
    dropship = DropShipKarma(LastSpawned);
    if(dropship != none)
    {
        dropship.bEnhancedHud=bEnhancedHud;
        dropship.EnhancedHudRange=EnhancedHudRange;
    }
}

defaultproperties
{
     RedBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectBlue'
     VehicleClass=Class'CSAPVerIV.DropShipKarma'
     Mesh=SkeletalMesh'APVerIV_Anim.UTDropShip'
     bEnhancedHud=false
     EnhancedHudRange=10000
}
