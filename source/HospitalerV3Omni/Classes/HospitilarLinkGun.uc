//-----------------------------------------------------------
//
//-----------------------------------------------------------
class HospitilarLinkGun extends LinkTWeapon;

var HospitilarLinkGunAltFire Hospitilarlinkconfirming1;
var HospitilarLinkGunBeamEffect Hospitilarlinkconfirming2;
var HospitilarLinkGunFire Hospitilarlinkconfirming3;

simulated function SetInitialState()
{
	local vector V;

	V.X = 0.0;
	V.Y = 0.0;
	V.Z = 100.0;
        SetBoneLocation('Object02', V);

	Super.SetInitialState();
}

simulated function ClientStopFire(Controller C, bool bWasAltFire)
{
          super(ONSweapon).ClientStopFire( C,  bWasAltFire);

}

defaultproperties
{
     Mesh=SkeletalMesh'ANIM_Hospitaler.LinkBody'
     DrawScale=0.100000
     Skins(0)=Texture'IllyHospitalerSkins.Hospitaler.LinkTurret_skin2'
     Skins(1)=Texture'IllyHospitalerSkins.Hospitaler.LinkTurret_skin1'
}
