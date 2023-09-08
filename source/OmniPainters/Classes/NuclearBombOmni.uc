//=============================================================================
// Even bigger than the Redeemer warhead. ~MiracleMatter
//=============================================================================
class NuclearBombOmni extends RedeemerProjectile;

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType)
{
	if ( (Damage > 0) && ((InstigatedBy == None) || (InstigatedBy.Controller == None) || (Instigator == None) || (Instigator.Controller == None) || !InstigatedBy.Controller.SameTeamAs(Instigator.Controller)) )
	{
		if ( (InstigatedBy == None) || DamageType.Default.bVehicleHit || (DamageType == class'Crushed') )
			BlowUp(Location);
		else
		{
	 		Spawn(class'RedeemerExplosion');
		    SetCollision(false,false,false);
		    HurtRadius(Damage, DamageRadius*0.3, MyDamageType, MomentumTransfer, Location);
		    Destroy();
		}
	}
}

state Dying
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType) {}
	function Timer() {}

    function BeginState()
    {
		bHidden = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		Spawn(class'IonCore',,, Location, Rotation);
		ShakeView();
		InitialState = 'Dying';
		if ( SmokeTrail != None )
			SmokeTrail.Destroy();
		SetTimer(0, false);
    }

    function ShakeView()
    {
        local Controller C;
        local PlayerController PC;
        local float Dist, Scale;

        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
            PC = PlayerController(C);
            if ( PC != None && PC.ViewTarget != None )
            {
                Dist = VSize(Location - PC.ViewTarget.Location);
                if ( Dist < DamageRadius * 4.0)
                {
                    if (Dist < DamageRadius*2.0)
                        scale = 1.0;
                    else
                        scale = (DamageRadius*2.0 - Dist) / (DamageRadius);
                    C.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
                }
            }
        }
    }

Begin:
    PlaySound(sound'WeaponSounds.redeemer_explosionsound');
    Sleep(0.3);
    HurtRadius(Damage, DamageRadius*0.100, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage, DamageRadius*0.200, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage, DamageRadius*0.300, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage, DamageRadius*0.400, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage, DamageRadius*0.500, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage, DamageRadius*0.600, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage, DamageRadius*0.700, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage, DamageRadius*0.800, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage, DamageRadius*0.900, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage*0.66, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage*0.40, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage*0.20, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage*0.10, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);
    Destroy();
}

defaultproperties
{
     ShakeRotRate=(Z=1000.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(Z=20.000000)
     ShakeOffsetRate=(Z=250.000000)
     ShakeOffsetTime=3.000000
     ExplosionEffectClass=Class'OmniPainters.NuclearExplosionOmni'
     Speed=1200.000000
     MaxSpeed=1200.000000
     Damage=500.000000
     DamageRadius=6500.000000
     MomentumTransfer=500000.000000
     MyDamageType=Class'OmniPainters.DamTypeOmniNukeStrike'
     DrawScale=0.700000
     CollisionRadius=30.000000
     CollisionHeight=15.000000
}
