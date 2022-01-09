

class CSBioBomber extends CSBomber
    placeable;



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
    */
    if(class'BioHandler'.static.IsBioDamage(DamageType))
        return;


    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}


//no boost for biobomber
Function RawInput(float DeltaTime,
                            float aBaseX, float aBaseY, float aBaseZ, float aMouseX, float aMouseY,
                            float aForward, float aTurn, float aStrafe, float aUp, float aLookUp)
{
    super(ONSChopperCraft).RawInput(DeltaTime, aBaseX, aBaseY, aBaseZ, aMouseX, aMouseY, aForward, aTurn, aStrafe, aUp, aLookUp);
}

defaultproperties
{
    VehicleNameString="Bio Bomber 1.1"
    VehiclePositionString="in a Bio Bomber"
    DriverWeapons(0)=(WeaponClass=class'CSBomber.CSBioBomberWeapon',WeaponBone=FrontGunMount)
    RedSkin=Shader'CSBomber.CSBioBomberRedShader'
    BlueSkin=Shader'CSBomber.CSBioBomberBlueShader'
    bShowChargingBar=False

    MaxThrustForce=125.000000
    MaxStrafeForce=90.000000
    MaxRiseForce=55.000000
    Health=400
    HealthMax=400

}