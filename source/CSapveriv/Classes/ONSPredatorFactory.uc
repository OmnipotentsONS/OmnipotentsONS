//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPredatorFactory extends ONSVehicleFactory;
var(HUD) bool bEnhancedHud;
var(HUD) float EnhancedHudRange;

function SpawnVehicle()
{
    local Predator pred;
    super.SpawnVehicle();
    pred = Predator(LastSpawned);
    if(pred != none)
    {
        pred.bEnhancedHud=bEnhancedHud;
        pred.EnhancedHudRange=EnhancedHudRange;
    }
}

defaultproperties
{
     RedBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectBlue'
     VehicleClass=Class'CSAPVerIV.Predator'
     Mesh=SkeletalMesh'APVerIV_Anim.PredatorMesh'
     bEnhancedHud=false
     EnhancedHudRange=10000
}
