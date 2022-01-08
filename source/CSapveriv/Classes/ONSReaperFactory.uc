//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSReaperFactory extends ONSVehicleFactory;
var(HUD) bool bEnhancedHud;
var(HUD) float EnhancedHudRange;
var(HUD) float CloakTime;

function SpawnVehicle()
{
    local Reaper reap;
    super.SpawnVehicle();
    reap = Reaper(LastSpawned);
    if(reap != none)
    {
        reap.bEnhancedHud=bEnhancedHud;
        reap.EnhancedHudRange=EnhancedHudRange;
        reap.ConfigCloakTime=CloakTime;
    }
}

defaultproperties
{
     RedBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectBlue'
     VehicleClass=Class'CSAPVerIV.Reaper'
     Mesh=SkeletalMesh'APVerIV_Anim.ReaperMesh'
     bEnhancedHud=false
     EnhancedHudRange=10000
     CloakTime=60
}
