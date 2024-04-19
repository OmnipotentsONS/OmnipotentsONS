class CSBombMech extends CSHoverMech 
    placeable;

#exec AUDIO IMPORT FILE=Sounds\berbils.wav
#exec AUDIO IMPORT FILE=Sounds\battleoftheplanets1.wav

simulated function DrawHUD(Canvas Canvas)
{
    local CSBombMechWeapon weap;
    super.DrawHUD(Canvas);
    weap = CSBombMechWeapon(Weapons[ActiveWeapon]);
    if(weap != none)
    {
        weap.NewDrawWeaponInfo(Canvas, 0.92 * Canvas.ClipY);
    }
}
  
defaultproperties
{
    VehicleNameString="Bombotron 2.1"
    VehiclePositionString="in an Bombotron"
    bExtraTwist=false
    Mesh=Mesh'CSMech.XanF02'
    RedSkin=Texture'UT2004PlayerSkins.XanFem2.XanF2_Body_0'
    RedSkinHead=Texture'UT2004PlayerSkins.XanFem2.XanF2_Head_0'
    BlueSkin=Texture'UT2004PlayerSkins.XanFem2.XanF2_Body_1'
    BlueSkinHead=Texture'UT2004PlayerSkins.XanFem2.XanF2_Head_1'

	Health=2000
	HealthMax=2000
	DriverWeapons(0)=(WeaponClass=class'CSBombMechWeapon',WeaponBone=righthand)
    HornAnims(0)=gesture_halt
    HornAnims(1)=gesture_point
    HornSounds(0)=sound'CSMech.berbils'
    HornSounds(1)=sound'CSMech.battleoftheplanets1'
    IdleSound=sound'CSMech.EngIdle5'        
    StartUpSound=sound'CSMech.EngStart5'
	ShutDownSound=sound'CSMech.EngStop4'
    FootStepSound=sound'CSMech.FootStepMegaManX'
}