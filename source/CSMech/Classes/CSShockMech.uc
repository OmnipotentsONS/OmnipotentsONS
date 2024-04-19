class CSShockMech extends CSHoverMech
    placeable;

#exec AUDIO IMPORT FILE=Sounds\EngStop5.wav
#exec AUDIO IMPORT FILE=Sounds\EngStart5.wav
#exec AUDIO IMPORT FILE=Sounds\FootStepMegaManX.wav
#exec AUDIO IMPORT FILE=Sounds\rideofvalkyries.wav
#exec AUDIO IMPORT FILE=Sounds\cavalry.wav
#exec AUDIO IMPORT FILE=Sounds\EngIdle7.wav

defaultproperties
{    
    VehicleNameString="Shockatron 2.1"
    VehiclePositionString="in a Shockatron"
    Mesh=Mesh'CSMech.BotD'
    RedSkin=Texture'CSMech.ShockMechBodyRed';
    RedSkinHead=Texture'CSMech.ShockMechHeadRed';
    BlueSkin=Texture'CSMech.ShockMechBodyBlue';
    BlueSkinHead=Texture'CSMech.ShockMechHeadBlue';    
	Health=2000
	HealthMax=2000
	DriverWeapons(0)=(WeaponClass=class'CSShockMechWeapon',WeaponBone=righthand)
    HornAnims(0)=gesture_cheer
    HornAnims(1)=gesture_point
    HornSounds(0)=sound'CSMech.rideofvalkyries'
    HornSounds(1)=sound'CSMech.cavalry'
    IdleSound=sound'CSMech.EngIdle7'            
    StartUpSound=sound'CSMech.EngStart5'
	ShutDownSound=sound'CSMech.EngStop5'
    FootStepSound=sound'CSMech.FootStepMegaManX'
    DodgeAnims(2)=DoubleJumpL
    DodgeAnims(3)=DoubleJumpR
}