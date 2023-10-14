class ONSMobreaker extends ONSHoverTank;

#exec AUDIO IMPORT NAME=TankLobreaker-Fire FILE=sounds\TankLobreaker-Fire.wav
#exec AUDIO IMPORT NAME=Lob-RockFire01 FILE=sounds\Lob-RockFire01.wav
#exec AUDIO IMPORT NAME=MobreakerCannonFireUpdated FILE=sounds\MobreakerCannonFireUpdated.wav

#exec OBJ LOAD FILE=..\Animations\VHRFLobreaker.ukx
#exec OBJ LOAD FILE=..\StaticMeshes\VHRFLobreakerSM.usx

defaultproperties
{
     MaxGroundSpeed=750.000000
     HoverSoftness=0.060000
     MaxThrust=100.000000
     MaxSteerTorque=104.000000
     DriverWeapons(0)=(WeaponClass=Class'Mobreaker.ONSMobreakCannon')
     PassengerWeapons(0)=(WeaponPawnClass=Class'Mobreaker.ONSMobreakerSecondaryTurretPawn',WeaponBone="Roof")
     RedSkin=Texture'Minotaur_Tex.MinotaurRed'
     BlueSkin=Texture'Minotaur_Tex.MinotaurBlue'
     DestroyedVehicleMesh=StaticMesh'VHRFLobreakerSM.LobreakerDead'
     bDrawDriverInTP=True
     DrivePos=(X=-19.000000,Y=58.000000,Z=183.000000)
     TPCamDistance=700.000000
     VehiclePositionString="in a Mobreaker"
     VehicleNameString="Mobreaker 1.21"
     FlagBone="Roof"
     HornSounds(0)=Sound'Minotaur_Sound.Minotaurhorn'
     HealthMax=1600.000000
     Health=1600
     Mesh=SkeletalMesh'VHRFLobreaker.RFLobreaker'
     Skins(1)=Texture'Minotaur_Tex.MinotaurTreads'
     Skins(2)=Texture'Minotaur_Tex.MinotaurTreads'
}
