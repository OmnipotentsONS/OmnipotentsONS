class CSRocketMech extends CSHoverMech
    placeable;

#exec AUDIO IMPORT FILE=Sounds\operationdestruction.wav
#exec AUDIO IMPORT FILE=Sounds\increaseefficiency.wav
#exec AUDIO IMPORT FILE=Sounds\EngStop2.wav
#exec AUDIO IMPORT FILE=Sounds\EngStart2.wav
#exec AUDIO IMPORT FILE=Sounds\FootStep2.wav
#exec AUDIO IMPORT FILE=Sounds\EngIdle5.wav

defaultproperties
{
    RedSkin=Texture'CSMech.RocketMechBodyRed';
    RedSkinHead=Texture'CSMech.RocketMechHeadRed';
    BlueSkin=Texture'CSMech.RocketMechBodyBlue';
    BlueSkinHead=Texture'CSMech.RocketMechHeadBlue';

    VehicleNameString="Rocketron 1.8"
    VehiclePositionString="in a Rocketron"
    Mesh=Mesh'CSMech.BotC'
	Health=1800
	HealthMax=1800
	DriverWeapons(0)=(WeaponClass=class'CSRocketMechWeapon',WeaponBone=righthand)
    HornAnims(0)=gesture_beckon
    HornAnims(1)=ThroatCut
    HornSounds(0)=sound'CSMech.operationdestruction'
    HornSounds(1)=sound'CSMech.increaseefficiency'
    IdleSound=sound'CSMech.EngIdle5'        
    StartUpSound=sound'CSMech.EngStart2'
	ShutDownSound=sound'CSMech.EngStop2'
    FootStepSound=sound'CSMech.FootStep2'

    DodgeAnims(2)=DoubleJumpL
    DodgeAnims(3)=DoubleJumpR
}