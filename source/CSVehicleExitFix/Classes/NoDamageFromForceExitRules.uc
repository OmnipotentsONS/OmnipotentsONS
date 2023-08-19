class NoDamageFromForceExitRules extends GameRules;

function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
    // if we are in spawn protection and crushed ourselves, no damage
    log("NetDamage: injured="$injured$" instigatedBy="$instigatedBy$" damagetype="$DamageType);
    if(((Level.TimeSeconds - injured.SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime)) &&
        ((instigatedBy == None) || (Vehicle(instigatedBy) != None)))
    {
        log("NO DMG SpawnTime="$injured.SpawnTime$" Level.TimeSeconds="$Level.TimeSeconds$" spawnprotection="$DeathMatch(Level.Game).SpawnProtectionTime);
        return 0;
    }

	if ( NextGameRules != None )
		return NextGameRules.NetDamage( OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	return Damage;
}


defaultproperties
{
}