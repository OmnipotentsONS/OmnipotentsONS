// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusLinkProjectile extends LinkProjectile;

var array<Pawn> LockingPawns;
var bool bShareNodeDamage;

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	local Vector X, RefNormal, RefDir;
	local int i, DamageAmount;
	local DestroyableObjective HealObjective;

	if (Instigator != none && Other == Instigator)
		return;

	if (Other == Owner)
		return;

	if (Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, Damage * 0.25))
	{
		if (Role == ROLE_Authority)
		{
			X = Normal(Velocity);
			RefDir = X - 2.0 * RefNormal * (X dot RefNormal);

			Spawn(Class, Other,, HitLocation + RefDir * 20, Rotator(RefDir));
		}

		Destroy();
	}
	else if (!Other.IsA('Projectile') || Other.bProjTarget)
	{
		if (Role == ROLE_Authority)
		{
			if (Instigator == None || Instigator.Controller == None)
				Other.SetDelayedDamageInstigatorController(InstigatorController);

			HealObjective = DestroyableObjective(Other);

			if (HealObjective == None)
				HealObjective = DestroyableObjective(Other.Owner);

			if (HealObjective != None && bShareNodeDamage)
			{
				DamageAmount = Damage * (LockingPawns.Length + 1);

				if (MyDamageType != None)
					DamageAmount *= MyDamageType.default.VehicleDamageScaling;

				if (Instigator != None)
				{
					if (Instigator.HasUDamage())
						DamageAmount *= 2;

					DamageAmount *= Instigator.DamageScaling;
				}

				DamageAmount = FMin(HealObjective.Health, DamageAmount) / HealObjective.DamageCapacity;

				for (i=0; i<LockingPawns.Length; i++)
					if (LockingPawns[i] != None)
						HealObjective.AddScorer(LockingPawns[i].Controller, float(DamageAmount) / float(LockingPawns.Length + 1));

				if (Instigator != none)
					HealObjective.AddScorer(Instigator.Controller, -(DamageAmount - (DamageAmount / (LockingPawns.Length + 1))));

				Other.TakeDamage(Damage * (LockingPawns.Length + 1), Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
			}
			else
			{
				Other.TakeDamage(Damage * (1.0 + float(Links)), Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
			}
		}

		Explode(HitLocation, vect(0,0,1));
	}
}