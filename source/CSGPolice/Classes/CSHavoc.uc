class CSHavoc extends Havoc;

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
    VehicleNameString="Havoc"
    Health=350
    HealthMax=350
    MaxThrustForce=150.0
    MaxStrafeForce=100.0
    MaxRiseForce=125.00
}