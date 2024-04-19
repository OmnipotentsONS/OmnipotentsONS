class CSBioMech extends CSHoverMech 
    placeable;

#exec AUDIO IMPORT FILE=Sounds\twiki.wav
#exec AUDIO IMPORT FILE=Sounds\byyourcommand.wav

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
    /*
    if (DamageType == class'BiotankKill')
        return;

    if (DamageType == class'BioBeam')
        return;

    if (ClassIsChildOf(DamageType,class'BioBeam'))
        return;

    if (DamageType == class'DamTypeBioGlob')
        return;

    if (ClassIsChildOf(DamageType,class'DamTypeBioGlob'))
        return;

    if (DamageType == class'BioBadgerBeamKill')
        return;
        */

    if(class'BioHandler'.static.IsBioDamage(DamageType))
        return;


    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

defaultproperties
{    
    VehicleNameString="Biotron 2.1"
    VehiclePositionString="in a Biotron"
    bExtraTwist=false

    Mesh=Mesh'CSMech.XanM03'
    RedSkin=Texture'UT2004PlayerSkins.Xan.XanM3_Body_0'
    RedSkinHead=Texture'UT2004PlayerSkins.Xan.XanM3_Head'
    BlueSkin=Texture'UT2004PlayerSkins.Xan.XanM3_Body_1'
    BlueSkinHead=Texture'UT2004PlayerSkins.Xan.XanM3_Head

	Health=1800
	HealthMax=1800
	DriverWeapons(0)=(WeaponClass=class'CSBioMechWeapon',WeaponBone=righthand)
    HornAnims(0)=AssSmack
    HornAnims(1)=ThroatCut
    HornSounds(0)=sound'CSMech.twiki'
    HornSounds(1)=sound'CSMech.byyourcommand'
    IdleSound=sound'CSMech.EngIdle6'            
    StartUpSound=sound'CSMech.EngStart3'
	ShutDownSound=sound'CSMech.EngStop4'
    FootStepSound=sound'CSMech.FootStep2'

    HoverCheckDist=150
    ThrusterOffsets(0)=(X=-140,Y=-150,Z=-290)
	ThrusterOffsets(1)=(X=-140,Y=-50,Z=-290)
	ThrusterOffsets(2)=(X=-140,Y=50,Z=-290)
	ThrusterOffsets(3)=(X=-140,Y=150,Z=-290)

	//front row
	ThrusterOffsets(4)=(X=90,Y=-150,Z=-290)
	ThrusterOffsets(5)=(X=90,Y=-50,Z=-290)
	ThrusterOffsets(6)=(X=90,Y=50,Z=-290)
	ThrusterOffsets(7)=(X=90,Y=150,Z=-290)
}
