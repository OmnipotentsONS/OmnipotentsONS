class IonTankTeamColorWeapon extends ONSHoverTank_IonPlasma_Weapon;

var float ShockDamage;

function SpawnLaserBeam()
{
	CalcWeaponFire();

	if (Instigator.GetTeamNum() == 1)
        AimLaser = Spawn(class'IonTankTeamColorAimLaserBlue', Self,, WeaponFireLocation, WeaponFireRotation);
	else
        AimLaser = Spawn(class'OnslaughtFull.FX_IonPlasmaTank_AimLaser', Self,, WeaponFireLocation, WeaponFireRotation);
}

state ProjectileFireMode
{
	function AltFire(Controller C)
	{
		local actor		Shock;
		local float		DistScale, dist;
		local vector	dir, StartLocation;
		local Pawn		Victims;

		NetUpdateTime = Level.TimeSeconds - 1;
		bFireMode = true;
		//log("AltFire");
		StartLocation = Instigator.Location;

		PlaySound(ShockSound, SLOT_None, 128/255.0,,, 2.5, False);

		Shock = Spawn(class'FX_IonPlasmaTank_ShockWave', Self,, StartLocation);
		Shock.SetBase( Instigator );

		foreach VisibleCollidingActors( class'Pawn', Victims, ShockRadius, StartLocation )
		{
			//log("found:" @ Victims.GetHumanReadableName() );
			// don't let Shock affect fluid - VisibleCollisingActors doesn't really work for them - jag
			if( (Victims != Instigator) /*&& (Victims.Controller != None)*/
				&& (Victims.Controller.GetTeamNum() != Instigator.GetTeamNum())
				&& (Victims.Role == ROLE_Authority) )
			{

				dir = Victims.Location - StartLocation;
				dir.Z = 0;
				dist = FMax(1,VSize(dir));
				dir = Normal(Dir)*0.5 + vect(0,0,1);
				DistScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/ShockRadius);
				if (Vehicle(Victims) == None)
					Victims.AddVelocity( DistScale * -ShockMomentum * dir );
				else
					Victims.AddVelocity( DistScale * -ShockMomentum * dir * 20);
				Victims.TakeDamage(DistScale * ShockDamage, Instigator, Victims.Location, DistScale * ShockMomentum * dir, class'DamTypeIonTankShockwave');
				//Victims.Velocity = (DistScale * ShockMomentum * dir);
				//Victims.TakeDamage(0, Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				//(DistScale * ShockMomentum * dir), None	);
				//log("Victims:" @ Victims.GetHumanReadableName() @ "DistScale:" @ DistScale );
			}
		}
	}
}

defaultproperties
{
     ShockDamage=250.000000
     ShockMomentum=60000.000000
     ShockRadius=1000.000000
     RedSkin=Combiner'ONSToys1Tex.IonTankTurretRed_C'
     BlueSkin=Combiner'ONSToys1Tex.IonTankTurretBlue_C'
  
}
