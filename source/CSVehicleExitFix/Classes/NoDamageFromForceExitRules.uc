class NoDamageFromForceExitRules extends GameRules;

function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
    local bool inSpawnProtection;

    inSpawnProtection = Level.TimeSeconds - injured.SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime;
    // if we are in spawn protection and crushed ourselves, no damage
    if(inSpawnProtection &&
        ((instigatedBy == None) || (Vehicle(instigatedBy) != None && Vehicle(instigatedBy).Driver == None)))
    {
        return 0;
    }

	if ( NextGameRules != None )
		return NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	return Damage;
}


defaultproperties
{
}