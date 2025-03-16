//-----------------------------------------------------------
//
//-----------------------------------------------------------
class NodeRunOmniGun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var class<Projectile> TeamProjectileClasses[2];
var float MinAim;
var float AltFireCountdown;  // sep timing for missles primary

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStarRed');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadRed');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadBlue');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    L.AddPrecacheMaterial(Material'EpicParticles.Flares.FlashFlare1');
    L.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStarRed');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadRed');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaHeadBlue');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    Level.AddPrecacheMaterial(Material'EpicParticles.Flares.FlashFlare1');
    Level.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaFlare');

    Super.UpdatePrecacheMaterials();
}

function byte BestMode()
{
	if ( Vehicle(Instigator.Controller.Enemy) != None
	     && (Instigator.Controller.Enemy.bCanFly || Instigator.Controller.Enemy.IsA('ONSHoverCraft')) && FRand() < 0.75 )
		return 1;
	else
		return 0;
}

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
		local NodeRunOmniMissle M;
		local Vehicle V, Best;
		local float CurAim, BestAim;

		M = NodeRunOmniMissle(SpawnProjectile(AltFireProjectileClass, True));
		if (M != None)
		{
			if (AIController(Instigator.Controller) != None)
			{
				V = Vehicle(Instigator.Controller.Enemy);
				if (V != None && (V.bCanFly || V.IsA('ONSHoverCraft')) && Instigator.FastTrace(V.Location, Instigator.Location))
					M.SetHomingTarget(V);
			}
			else
			{
				BestAim = MinAim;
				for (V = Level.Game.VehicleList; V != None; V = V.NextVehicle)
					if ((V.bCanFly || V.IsA('ONSHoverCraft')) && V != Instigator && Instigator.GetTeamNum() != V.GetTeamNum())
					{
						CurAim = Normal(V.Location - WeaponFireLocation) dot vector(WeaponFireRotation);
						if (CurAim > BestAim && Instigator.FastTrace(V.Location, Instigator.Location))
						{
							Best = V;
							BestAim = CurAim;
						}
					}
				if (Best != None)
					M.SetHomingTarget(Best);
			}
		}
	}
}


/******** Code for independent weapon fire times*************************/

simulated function Tick(float DT)
{
    local ONSVehicle V;
    super.Tick(DT);

    V = ONSVehicle(Owner);
    if(AltFireCountdown > 0)
    {
        AltFireCountdown -= DT;
        if(AltFireCountdown <= 0 && Level.NetMode != NM_DedicatedServer)
        {
            if(V != None && V.IsLocallyControlled() && V.IsHumanControlled() && V.bWeaponIsAltFiring)
            {
                OwnerEffects();
            }
        }
    }

    if(Instigator != None && Instigator.Controller != None)
    {
        if (Role == ROLE_Authority && AltFireCountdown <= 0)
        {
            if (V != None && V.bWeaponisAltFiring)
            {
                if (AttemptFire(Instigator.Controller, true))
                    V.ApplyFireImpulse(true);
            }
        }
    }
}

event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;

	if (FireCountdown <= 0 && !bAltFire)
	{
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

        	DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
        FireCountdown = FireInterval;
        Fire(C);
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	if (AltFireCountdown <= 0 && bAltFire)
	{
		DualFireOffset=0; // Rail gun no offset
		CalcWeaponFire();
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);

		if (Spread > 0)
			WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);

		Instigator.MakeNoise(1.0);
        AltFireCountdown = AltFireInterval;
        AltFire(C);
		AimLockReleaseTime = Level.TimeSeconds + AltFireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}

// End Seperate Countdown for Firing.

defaultproperties
{
     TeamProjectileClasses(0)=Class'NodeRunnerOmni.NodeRunOmniPlasmaProjectileRed'
     TeamProjectileClasses(1)=Class'NodeRunnerOmni.NodeRunOmniPlasmaProjectileBlue'
     MinAim=0.900000
     YawBone="PlasmaGunBarrel"
     YawStartConstraint=42344.000000
     YawEndConstraint=23192.000000
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=28000
     PitchDownLimit=39153
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     DualFireOffset=6.000000
     RotationsPerSecond=0.800000
     FireInterval=0.16000
     AltFireInterval=3.000000
     FireSoundClass=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeFire01'
     AltFireSoundClass=Sound'ONSVehicleSounds-S.AVRiL.AvrilFire01'
     FireForce="Laser01"
     AltFireForce="Laser01"
     ProjectileClass=Class'NodeRunnerOmni.NodeRunOmniPlasmaProjectileRed'
     AltFireProjectileClass=Class'NodeRunnerOmni.NodeRunOmniMissle'
     AIInfo(0)=(bLeadTarget=True,RefireRate=0.950000)
     AIInfo(1)=(bLeadTarget=True,aimerror=400.000000,RefireRate=0.500000)
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
