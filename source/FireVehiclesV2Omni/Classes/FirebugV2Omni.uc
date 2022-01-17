
class FirebugV2Omni extends FirebugTank
placeable;

simulated function ReduceShake()
{
	local float ShakeScaling;
	local PlayerController Player;

	if (Controller == None || PlayerController(Controller) == None)
		return;

	Player = PlayerController(Controller);
	ShakeScaling = VSize(Player.ShakeRotMax) / 7500;

	if (ShakeScaling > 1)
	{
		Player.ShakeRotMax /= ShakeScaling;
		Player.ShakeRotTime /= ShakeScaling;
		Player.ShakeOffsetMax /= ShakeScaling;
	}
}


function TakeDamage(int Damage, Pawn instigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType)
{

  if (DamageType.name == 'DamTypeBioGlob')
            Damage *= 2.0;

	if (DamageType == class'DamTypeHoverBikePlasma')
		Damage *= 0.70;

	if (DamageType == class'DamTypeONSCicadaRocket')
		Damage *= 0.50;

	if (DamageType.name == 'AuroraLaser' || DamageType.name == 'WaspFlak')
		Damage *= 0.50;


	if (DamageType == class'DamTypeShockBeam')
		Damage *= 0.75;

	if (DamageType.name == 'DamTypeMinotaurClassicTurret')
		Damage *= 0.50;

	if (DamageType.name == 'DamTypeMinotaurClassicSecondaryTurret')
		Damage *= 0.50;

if (DamageType.name == 'OmnitaurTurretkill')
		Damage *= 0.50;

	if (DamageType.name == 'OmnitaurSecondaryTurretKill')
		Damage *= 0.50;

if (DamageType.name == 'MinotaurTurretkill')
		Damage *= 0.50;

	if (DamageType.name == 'MinotaurSecondaryTurretKill')
		Damage *= 0.50;

if (DamageType.name == 'FireKill')
		Damage *= 0.10;

if (DamageType.name == 'FlameKill')
		Damage *= 0.1;
				
if (DamageType.name == 'Burned')
		Damage *= 0.10;
		
if (DamageType.name == 'DamTypeFirebugFlame')
		Damage *= 0.10;

if (DamageType.name == 'FireBall')
		Damage *= 0.10;

if (DamageType.name == 'FlameKillRaptor')
		Damage *= 0.10;

if (DamageType.name == 'HeatRay')
		Damage *= 0.10;

if (DamageType.name == 'DamTypeDracoFlamethrower')
		Damage *= 0.05;

if (DamageType.name == 'DamTypeDracoNapalmRocket')
		Damage *= 0.10;

if (DamageType.name == 'DamTypeDracoNapalmGlob')
		Damage *= 0.10;



	//Momentum *= 0.00;

    Super.TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	ReduceShake();
}





//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     Build="2021-10-17 11:28"
     VehicleNameString="Firebug 2.6"
     JumpDuration=0.800000
     JumpDelay=2.500000
     JumpForceMag=500.000000
     JumpTorqueMag=600.000000
     FlamerForceMag=80.000000
     MaxGroundSpeed=1800.000000
     
}