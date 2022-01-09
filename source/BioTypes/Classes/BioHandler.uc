class BioHandler extends Object
    abstract;

static function bool IsBioDamage(class<DamageType> DamageType)
{
    if (ClassIsChildOf(DamageType,class'DamTypeBioBeam'))
        return true;

    if (ClassIsChildOf(DamageType,class'DamTypeBioGlobVehicle'))
        return true;

    if (ClassIsChildOf(DamageType,class'DamTypeBioGlob'))
        return true;

    if (DamageType == class'DamTypeBioGlob')
        return true;

    return false;
}

defaultproperties
{
}