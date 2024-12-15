//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MTIIOMachineGun extends ONSWeapon;

var class<Projectile> TeamProjectileClasses[2];
var float MinAim;
var		float	StartHoldTime, MaxHoldTime, ShockMomentum, ShockRadius;
var		bool	bHoldingFire, bFireMode;
var	sound	ChargingSound, ShockSound;
var float AltFireDamage;

state ProjectileFireMode
{
	function Fire(Controller C)
	{
		if (Vehicle(Owner) != None && Vehicle(Owner).Team < 2)
			ProjectileClass = TeamProjectileClasses[Vehicle(Owner).Team];
		else
			ProjectileClass = TeamProjectileClasses[0];

		Super.Fire(C);
	}


function AltFire(Controller C)
	{
		local actor		Shock;
		local float		DistScale, dist;
		local vector	dir, StartLocation;
		local Actor		Victims;
		local Pawn		VictimPawn;

		NetUpdateTime = Level.TimeSeconds - 1;
		bFireMode = true;
		//log("AltFire");
		StartLocation = Instigator.Location;

		PlaySound(ShockSound, SLOT_None, 255/255.0,,, 2.5, False);

		Shock = Spawn(class'FX_IonPlasmaTank_ShockWave', Self,, StartLocation);
		Shock.SetBase( Instigator );

		
		foreach VisibleCollidingActors( class'Actor', Victims, ShockRadius, StartLocation )
		{
			//log("found:" @ Victims.GetHumanReadableName() );
			// don't let Shock affect fluid - VisibleCollisingActors doesn't really work for them - jag
			
			//log("Victims:" @ Victims.GetHumanReadableName() @ "DistScale:" @ DistScale );
				if (Victims != Instigator && !Victims.IsA('FluidSurfaceInfo')) { //&& (Victims.Controller != None)
					dir = Victims.Location - StartLocation;
					dir.Z = 0;
					dist = FMax(1,VSize(dir));
					dir = Normal(Dir)*0.5 + vect(0,0,1);
					DistScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/ShockRadius);
				
					VictimPawn = Pawn(Victims);
				
				//log("VictimPawn:"@ "Victim Team:" @ VictimPawn.Controller.GetTeamNum() @ "Instigator Team:" @ Instigator.GetTeamNum()  );
					if (VictimPawn != None && VictimPawn.Controller != None 
			   		 && VictimPawn.Controller.GetTeamNum() != Instigator.GetTeamNum()  // spare your team
				 		&& (Victims.Role == ROLE_Authority) )
				 		// only does damage if there's instigators/controllers doesn't affect empty stuff. so no blast against empty vehicles.
				  { // Handle Vehicles/Infantry (pawns)
					//log("PawnVictims:" @ Victims.GetHumanReadableName() @ "DistScale:" @ DistScale );
				
					if (Vehicle(Victims) == None)
							 {
								//Victims.AddVelocity( DistScale * -AltFireMomentum * dir );
								// I think add velocity was bypassing spawn protection.
								VictimPawn.TakeDamage(DistScale * AltFireDamage, Instigator, VictimPawn.Location, DistScale * ShockMomentum * dir, DamageType);
							 }
							 else
							 { // Vehicles
						  		VictimPawn.AddVelocity( DistScale * ShockMomentum * dir );
									VictimPawn.TakeDamage(DistScale * AltFireDamage, Instigator, VictimPawn.Location, DistScale * ShockMomentum * dir, DamageType);
							 }

				
				} // end pawns
				// non pawns (eg. Nodes here)
				//log("Actor, Not Pawns" @ Victims);
				if (Victims.IsA('ONSPowerCore') || Victims.IsA('ONSPowerNodeEnergySphere')) 
				{
					//log("FoundPowerCode/Node - Do Damage" $ Victims);
					Victims.TakeDamage(DistScale * AltFireDamage, Instigator, Victims.Location, DistScale * ShockMomentum * dir, DamageType);
				}
			}
		}
 }
}

defaultproperties
{
     TeamProjectileClasses(0)=Class'MonsterTruckOmni.MTIIORedProjectile'
     TeamProjectileClasses(1)=Class'MonsterTruckOmni.MTIIOGunProjectile'
     ShockMomentum=8500.000000
     ShockRadius=2000.000000
     ShockSound=Sound'MTII.SuperSuck'
     YawBone="PlasmaGunBarrel"
     YawStartConstraint=57344.000000
     YawEndConstraint=8192.000000
     PitchBone="PlasmaGunBarrel"
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     WeaponFireOffset=25.000000
     DualFireOffset=25.000000
     RotationsPerSecond=0.800000
     FireInterval=0.100000
     AltFireInterval=3.500000
     AltFireDamage=100
     FireSoundClass=Sound'MTII.Static_AA_fire_3p'
     AltFireSoundClass=Sound'MTII.SuperSuck'
     FireForce="Laser01"
     AltFireForce="Laser01"
     ProjectileClass=Class'MonsterTruckOmni.MTIIORedProjectile'
     DamageType=class'MonsterTruckOmni.DamTypeMTIIOShockwave'
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
