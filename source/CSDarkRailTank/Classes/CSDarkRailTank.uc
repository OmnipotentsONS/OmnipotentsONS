class CSDarkRailTank extends  RailgunTank;

#exec obj load file=Textures\CSDarkRailTank_Tex.utx package=CSDarkRailTank

#exec AUDIO IMPORT FILE="Sounds\vaderbreath.wav"
#exec AUDIO IMPORT FILE="Sounds\imperialmarch.wav"
defaultproperties
{
    VehicleNameString="Dark Railtank 1.0"
    VehiclePositionString="in a Dark Railtank"
    DriverWeapons(0)=(WeaponClass=Class'CSDarkRailTank.CSDarkRailTankTurret')
    PassengerWeapons(0)=(WeaponPawnClass=Class'CSDarkRailTank.CSDarkRailSecondaryTurretPawn')
    RedSkin=Texture'CSDarkRailTank.DarkRailTankBody0'
    BlueSkin=Texture'CSDarkRailTank.DarkRailTankBody1'
	HornSounds(0)=sound'CSDarkRailTank.vaderbreath'
	HornSounds(1)=sound'CSDarkRailTank.imperialmarch'
    MaxThrust=150
    GroundSpeed=2300
    MaxGroundSpeed=2800
    MaxAirSpeed=8500
    Health=600
    HealthMax=600

    Begin Object Class=KarmaParamsRBFull Name=KParams0
		KStartEnabled=True
		KFriction=0.5
		KLinearDamping=0
		KAngularDamping=0
		bKNonSphericalInertia=False
        bHighDetailOnly=False
        bClientOnly=False
		bKDoubleTickRate=True
		bKStayUpright=True
		bKAllowRotate=True
		kMaxSpeed=2800.0
		KInertiaTensor(0)=1.3
		KInertiaTensor(1)=0.0
		KInertiaTensor(2)=0.0
		KInertiaTensor(3)=4.0
		KInertiaTensor(4)=0.0
		KInertiaTensor(5)=4.5
		KCOMOffset=(X=0.0,Y=0.0,Z=0.0)
		bDestroyOnWorldPenetrate=True
		bDoSafetime=True
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'


}