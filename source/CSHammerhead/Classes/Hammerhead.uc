//-----------------------------------------------------------
// Tau Hammer Head with Railgun from the Warhammer 40k universe.
//-----------------------------------------------------------
class HammerHead extends ONSAttackCraft
    placeable;

#exec OBJ LOAD FILE=..\Animations\HammerHead_Animations.ukx PACKAGE=CSHammerhead
#exec OBJ LOAD FILE=..\Sounds\HammerHead_Sounds.uax PACKAGE=CSHammerhead
//#exec OBJ LOAD FILE=..\textures\HammerHead_Textures.utx PACKAGE=CSHammerhead
#exec OBJ LOAD FILE=textures\CSHammerHead_Tex.utx PACKAGE=CSHammerhead
#exec OBJ LOAD FILE=StaticMeshes\HammerHead_StaticMeshes.usx PACKAGE=CSHammerhead

function AltFire(optional float F)
{
    if (bWeaponIsAltFiring)
        return;

    VehicleFire(True);
}

//Switch weapons when alt-fire is pressed and display a message.
function VehicleFire(bool bWasAltFire)
{
    if (!bWasAltFire)
    {
        super.VehicleFire(bWasAltFire);
        return;
    }

    if(ActiveWeapon == 0)
    {
        if(PlayerController(Controller) != None)
            PlayerController(Controller).ReceiveLocalizedMessage(class'HammerMessage', 1);

        SetActiveWeapon(1);
    }
    else
    {
        if(PlayerController(Controller) != None)
            PlayerController(Controller).ReceiveLocalizedMessage(class'HammerMessage', 0);

        SetActiveWeapon(0);
    }
}


//Switch back to main gun when driver leaves.
function UnPossessed()
{
    Super.UnPossessed();

    SetActiveWeapon(0);
}

function bool PlaceExitingDriver()
{
	local int		i, j;
	local vector	tryPlace, Extent, HitLocation, HitNormal, ZOffset, RandomSphereLoc;
	local float BestDir, NewDir;

	if ( Driver == None )
		return false;

	Extent = Driver.default.CollisionRadius * vect(1,1,0);
	Extent.Z = Driver.default.CollisionHeight;
	ZOffset = Driver.default.CollisionHeight * vect(0,0,1);

	for( i=0; i<ExitPositions.Length; i++)
	{
		if ( ExitPositions[0].Z != 0 )
			ZOffset = Vect(0,0,1) * ExitPositions[0].Z;
		else
			ZOffset = Driver.default.CollisionHeight * vect(0,0,2);

		tryPlace = Location + ( (ExitPositions[i]-ZOffset) >> Rotation) + ZOffset;

		// First, do a line check (stops us passing through things on exit).
		if ( Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) != None )
			continue;

		// Then see if we can place the player there.
		if ( !Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}
	return false;
}


defaultproperties
{
     TrailEffectPositions(0)=(X=-315.765350,Y=-189.703873,Z=63.143875)
     TrailEffectPositions(1)=(X=-315.765350,Y=189.703873,Z=63.143875)
     TrailEffectPositions(2)=(X=-315.614075,Y=-184.911285,Z=21.313364)
     TrailEffectPositions(3)=(X=-315.614075,Y=184.911285,Z=21.313364)
     StreamerEffectOffset(0)=(X=-157.943192,Y=-230.908951,Z=89.714783)
     StreamerEffectOffset(1)=(X=-157.943192,Y=230.908951,Z=89.714783)
     StreamerEffectOffset(2)=(X=175.045227,Y=-265.933014,Z=-74.389023)
     StreamerEffectOffset(3)=(X=175.045227,Y=265.933014,Z=-74.389023)
     DriverWeapons(0)=(WeaponClass=Class'CSHammerhead.HammerCannon',WeaponBone="Cannon")
     DriverWeapons(1)=(WeaponClass=Class'CSHammerhead.HammerMinigunMaster',WeaponBone="leftminigun")
     DriverWeapons(2)=(WeaponClass=Class'CSHammerhead.HammerMinigun',WeaponBone="rightminigun")
     //RedSkin=Texture'CSHammerhead.hammerdead.hummertex_red'
     //BlueSkin=Texture'CSHammerhead.hammerdead.hummertex_blue'
     RedSkin=Texture'CSHammerhead.hummertex_red'
     BlueSkin=Texture'CSHammerhead.hummertex_blue'
     StartUpForce="Hammerhead is up"
     ShutDownForce="Hammerhead is down"
     DestroyedVehicleMesh=StaticMesh'CSHammerhead.HammerheadDeadSM'
     //DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.AttackCraftDead'

     DisintegrationHealth=-100.000000
     DestructionLinearMomentum=(Min=125000.000000,Max=200000.000000)
     DestructionAngularMomentum=(Min=75.000000,Max=200.000000)
     HeadlightCoronaOffset(0)=(X=289.538422,Y=4.749050,Z=-74.851456)
     HeadlightCoronaOffset(1)=(X=210.839508,Y=-159.415634,Z=-74.851456)
     HeadlightCoronaOffset(2)=(X=210.839508,Y=159.415634,Z=-74.851456)
     VehicleMass=3.000000
     //ExitPositions(0)=(X=40.230000,Y=-310.029999,Z=-59.630001)
     //ExitPositions(1)=(X=40.200001,Y=310.029999,Z=-59.630001)
     ExitPositions(0)=(X=20.230000,Y=-410.029999,Z=-59.630001)
     ExitPositions(1)=(X=20.200001,Y=410.029999,Z=-59.630001)
     bRelativeExitPos=true
     EntryRadius=375.000000
     TPCamDistance=351.843262
     MomentumMult=2.000000
     VehiclePositionString="in a Hammerhead"
     VehicleNameString="Hammerhead"
     MaxDesireability=0.800000
     HealthMax=800.000000
     Health=800
     Mesh=SkeletalMesh'CSHammerhead.hammer'
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.250000)
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=0.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=300.000000
     End Object
     KParams=KarmaParamsRBFull'CSHammerhead.Hammerhead.KParams0'

}
