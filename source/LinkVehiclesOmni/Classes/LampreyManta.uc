
class LampreyManta extends ONSHoverBike


    placeable;

#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

var bool bLinking;
var int Links;



replication
{
    unreliable if (Role == ROLE_Authority)
        bLinking, Links;
}



defaultproperties
{
	/* Props from flying manta eg. based on ONSAttackCraft
	  bDrawMeshInFP=False
		 bCanFly = True
		 bFollowLookDir=True
     bCanHover=True
     bPCRelativeFPRotation=False
      TrailEffectPositions(0)=(X=-82.000000,Y=-24.000000,Z=40.000000)
     TrailEffectPositions(1)=(X=-82.000000,Y=24.000000,Z=40.000000)
     StreamerEffectOffset(0)=(X=-20.000000,Y=-28.000000,Z=-28.000000)
     StreamerEffectOffset(1)=(X=-20.000000,Y=28.000000,Z=-28.000000)
     StreamerEffectOffset(2)=(Y=-56.000000,Z=-16.000000)
     StreamerEffectOffset(3)=(Y=56.000000,Z=-16.000000)
     
   */  
   
   // Manta props modified
   
     MaxPitchSpeed=1200.000000
     JumpDuration=0.40000
     JumpForceMag=130.000000
     JumpDelay=1.500000
     DuckForceMag=250.000000
     RollTorqueStrafeFactor=75.000000
     RollTorqueMax=250.000000
     
     
     
     
     DriverWeapons(0)=(WeaponClass=Class'LampreyGun',WeaponBone="PlasmaGunAttachment")
     bHasAltFire=True
     
     
     RedSkin=Shader'LinkTank3Tex.Lamprey.LampreyChassisRED'
     BlueSkin=Shader'LinkTank3Tex.Lamprey.LampreyChassisBLUE'
        
        
     
     DriverDamageMult=0.000000
     VehiclePositionString="in a Lamprey Manta"
     VehicleNameString="Lamprey Manta 3.4"
     GroundSpeed=1650.000000
     HealthMax=300.000000
     Health=250
     Mesh=SkeletalMesh'ONSVehicles-A.HoverBike'
     
     
     
   

}
