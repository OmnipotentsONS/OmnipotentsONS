class CSFlakMech extends CSHoverMech
    placeable;

#exec AUDIO IMPORT FILE=Sounds\EngStop3.wav
#exec AUDIO IMPORT FILE=Sounds\EngStart3.wav
#exec AUDIO IMPORT FILE=Sounds\FootStep3.wav
#exec AUDIO IMPORT FILE=Sounds\rogerroger.wav
#exec AUDIO IMPORT FILE=Sounds\goodbadugly.wav
#exec AUDIO IMPORT FILE=Sounds\EngIdle6.wav

defaultproperties
{    
    VehicleNameString="Flakatron 1.8"
    VehiclePositionString="in a Flakatron"
    Mesh=Mesh'CSMech.BotB'
    RedSkin=Texture'CSMech.FlakMechBodyRed';
    RedSkinHead=Texture'CSMech.FlakMechHeadRed';
    BlueSkin=Texture'CSMech.FlakMechBodyBlue';
    BlueSkinHead=Texture'CSMech.FlakMechHeadBlue';    
	Health=1600
	HealthMax=1600
	DriverWeapons(0)=(WeaponClass=class'CSFlakMechWeapon',WeaponBone=righthand)
    HornAnims(0)=ThroatCut
    HornAnims(1)=AssSmack
    HornSounds(0)=sound'CSMech.goodbadugly'
    HornSounds(1)=sound'CSMech.rogerroger'    
    IdleSound=sound'CSMech.EngIdle6'
    StartUpSound=sound'CSMech.EngStart3'
	ShutDownSound=sound'CSMech.EngStop3'
    FootStepSound=sound'CSMech.FootStep3'

    DodgeAnims(2)=DoubleJumpL
    DodgeAnims(3)=DoubleJumpR
}