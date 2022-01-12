class CSVenom extends Venom;

function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{
     if (DamageType == class'DamTypeONSAVRiLRocket')
            Damage *= 1.5;
            
     if (DamageType.name == 'DamTypeBatteryRocket')
            Damage *= 1.5;

     if (DamageType == class'DamTypeSniperShot')
            Damage *= 2.0;

    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
}

defaultproperties
{
    VehicleNameString="Venom"
    Health=450
    HealthMax=450
    MaxThrustForce=130.0
    MaxStrafeForce=90.0
    MaxRiseForce=100.0
}