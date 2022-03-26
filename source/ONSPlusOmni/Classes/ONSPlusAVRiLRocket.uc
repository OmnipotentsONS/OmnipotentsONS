Class ONSPlusAVRiLRocket extends ONSAVRiLRocket;

// Used to credit any kill to the player who shot down the rocket
var pawn ShootingInstigator;


function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	if (Damage > 0 && (instigatedBy == none || Instigator == none || instigatedBy.GetTeamNum() != Instigator.GetTeamNum()))
	{
		if (instigatedBy != none)
			ShootingInstigator = instigatedBy;

		Explode(HitLocation, vect(0,0,0));
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local pawn OldInstigator;
	local controller OldInstigatorController;

	if (ShootingInstigator != none && ShootingInstigator.Controller != none)
	{
		// Save the current instigator and replace with the instigator of the explosion
		OldInstigator = Instigator;
		OldInstigatorController = InstigatorController;

		Instigator = ShootingInstigator;
		InstigatorController = ShootingInstigator.Controller;


		// Now blow it up
		BlowUp(HitLocation);


		// Reset the original instigator
		Instigator = OldInstigator;
		InstigatorController = OldInstigatorController;


		// And finally, destroy it
		Destroy();
	}
	else
	{
		BlowUp(HitLocation);
		Destroy();
	}
}