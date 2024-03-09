class Tyrant extends ONSRV;

//!!!TEXTURE DEPENDENCY (optimal)
#exec OBJ LOAD FILE=..\textures\KainTex_Tyrant.utx

simulated function SetInitialState()
{
	local vector V;
	V.X = 27.0;
	V.Y = 0.0;
	V.Z = 7.0;
        SetBoneLocation('ChainGunAttachment', V);
	Super.SetInitialState();
}

simulated function Tick(float DT)
{
    local Coords ArmBaseCoords, ArmTipCoords;
    local vector HitLocation, HitNormal;
    local actor Victim;

    Super(ONSWheeledCraft).Tick(DT);

    // Left Blade Arm System
    if (Role == ROLE_Authority && bWeaponIsAltFiring && !bLeftArmBroke)
    {
        ArmBaseCoords = GetBoneCoords('CarLShoulder');
        ArmTipCoords = GetBoneCoords('LeftBladeDummy');
        Victim = Trace(HitLocation, HitNormal, ArmTipCoords.Origin, ArmBaseCoords.Origin);

        if (Victim != None && Victim.bBlockActors)
        {
            if (Victim.IsA('Pawn') && !Victim.IsA('Vehicle'))
                Pawn(Victim).TakeDamage(1000, self, HitLocation, Velocity * 100, class'DamTypeONSRVBlade');
            else
            {
                bLeftArmBroke = True;
                bClientLeftArmBroke = True;
                BladeBreakOff(4, 'CarLSlider', class'ONSRVLeftBladeBreakOffEffect');
				// We use slot 4 here because slots 0-3 can be used by BigWheels mutator.
            }
        }
    }
    if (Role < ROLE_Authority && bClientLeftArmBroke)
    {
        bLeftArmBroke = True;
        bClientLeftArmBroke = False;
        BladeBreakOff(4, 'CarLSlider', class'ONSRVLeftBladeBreakOffEffect');
    }

    // Right Blade Arm System
    if (Role == ROLE_Authority && bWeaponIsAltFiring && !bRightArmBroke)
    {
        ArmBaseCoords = GetBoneCoords('CarRShoulder');
        ArmTipCoords = GetBoneCoords('RightBladeDummy');
        Victim = Trace(HitLocation, HitNormal, ArmTipCoords.Origin, ArmBaseCoords.Origin);

        if (Victim != None && Victim.bBlockActors)
        {
            if (Victim.IsA('Pawn') && !Victim.IsA('Vehicle'))
                Pawn(Victim).TakeDamage(1000, self, HitLocation, Velocity * 100, class'DamTypeONSRVBlade');
            else
            {
                bRightArmBroke = True;
                bClientRightArmBroke = True;
                BladeBreakOff(5, 'CarRSlider', class'ONSRVRightBladeBreakOffEffect');
            }
        }
    }
    if (Role < ROLE_Authority && bClientRightArmBroke)
    {
        bRightArmBroke = True;
        bClientRightArmBroke = False;
        BladeBreakOff(5, 'CarRSlider', class'ONSRVRightBladeBreakOffEffect');
    }
}

defaultproperties
{
     DriverWeapons(0)=(WeaponClass=Class'Tyrants.TyrantCannon')
     RedSkin=Shader'KainTex_Tyrant.Tyrant.TyrantRED_Final'
     BlueSkin=Shader'KainTex_Tyrant.Tyrant.TyrantBLUE_Final'
     VehiclePositionString="in a Tyrant"
     VehicleNameString="Tyrant 1.1"
     Mesh=SkeletalMesh'Kain_Tyrant.Tyrant.TyrantVehicle'
     DriverDamageMult=0.00000  // driver taking damage while in it.  zero'd pooty 02/2024
     GroundSpeed=1050.000000
     HealthMax=375.000000
     Health=375
}
