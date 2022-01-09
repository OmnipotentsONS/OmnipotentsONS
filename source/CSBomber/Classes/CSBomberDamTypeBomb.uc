class CSBomberDamTypeBomb extends VehicleDamageType
	abstract;

defaultproperties
{
    DeathString="%o couldn't avoid %k's bomb volley."
    MaleSuicide="%o blasted himself out of the sky."
    FemaleSuicide="%o blasted herself out of the sky."

    VehicleDamageScaling=1.5
    VehicleMomentumScaling=0.75
    bDelayedDamage=true
    VehicleClass=class'CSBomber.CSBomber'
}
