// ============================================================================
// Link Tank laser turret.
// ============================================================================
class LinkTank3HeavyTertiaryTurret extends ONSWeapon;

var() sound LinkedFireSound;

var class<ONSTurretBeamEffect> BeamEffectClass[2];
var float LinkMultiplier;
var float LinkMultiplierCap;
var float VehicleDamageMult;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'TurretParticles.Beams.TurretBeam5');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaMuzzleBlue');
    L.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_core');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'TurretParticles.Beams.TurretBeam5');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaMuzzleBlue');
    Level.AddPrecacheMaterial(Material'EpicParticles.Flares.SoftFlare');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_flare_a');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_b');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_mark_heat');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_core');

    Super.UpdatePrecacheMaterials();
}

//do effects (muzzle flash, force feedback, etc) immediately for the weapon's owner (don't wait for replication)
simulated event OwnerEffects()
{
	local int NumLinks;

	if (!bIsRepeatingFF)
	{
		if (bIsAltFire)
			ClientPlayForceFeedback( AltFireForce );
		else
			ClientPlayForceFeedback( FireForce );
	}
    ShakeView();

	if (Role < ROLE_Authority)
	{
		if (LinkTank3Heavy(ONSWeaponPawn(Owner).VehicleBase) != None)
			NumLinks = LinkTank3Heavy(ONSWeaponPawn(Owner).VehicleBase).GetLinks();
		else
			NumLinks = 0;

		// Swap out fire sound
		if (NumLinks > 0)
			FireSoundClass = LinkedFireSound;
		else
			FireSoundClass = default.FireSoundClass;


		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		else
			FireCountdown = FireInterval;

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

     //   FlashMuzzleFlash();

		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);

        // Play firing noise
        if (!bAmbientFireSound)
        {
            if (bIsAltFire)
                PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
            else
                PlaySound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
	}
}

function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;
    local int Damage;
    local int NumLinks;

	if (LinkTank3Heavy(ONSWeaponPawn(Owner).VehicleBase) != None)
		NumLinks = LinkTank3Heavy(ONSWeaponPawn(Owner).VehicleBase).GetLinks();
	else
		NumLinks = 0;

    X = Vector(Dir);
    End = Start + TraceRange * X;

    //skip past vehicle driver
    if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
    {
      	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
       	Other = Trace(HitLocation, HitNormal, End, Start, True);
       	ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
    }
    else
       	Other = Trace(HitLocation, HitNormal, End, Start, True);

    if (Other != None)
    {
	if (!Other.bWorldGeometry)
        {
            Damage = (DamageMin + Rand(DamageMax - DamageMin));
            Damage = AdjustLinkDamage(NumLinks,Other,Damage);
            Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
            HitNormal = vect(0,0,0);
        }
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

    HitCount++;
    LastHitLocation = HitLocation;
    SpawnHitEffects(Other, HitLocation, HitNormal);
}


// ============================================================================
// AdjustLinkDamage
// Return adjusted damage based on number of links
// Takes a NumLinks argument instead of an actual LinkGun
// ============================================================================
function float AdjustLinkDamage( int NumLinks, Actor Target, float Damage)
{
	local float AdjDamage;
	
	AdjDamage = Damage * FMin(LinkMultiplier*NumLinks+1,LinkMultiplierCap);
	// no matter how many linkers Multiplier Cap

	if (Target != None && Target.IsA('Vehicle') ) 	AdjDamage *= VehicleDamageMult;
  if (Instigator.HasUDamage()) 	AdjDamage *= 2;
	
	return AdjDamage;
	
}



state InstantFireMode
{
    function Fire(Controller C)
    {
		local int NumLinks;
	
		if (LinkTank3Heavy(ONSWeaponPawn(Owner).VehicleBase) != None)
			NumLinks = LinkTank3Heavy(ONSWeaponPawn(Owner).VehicleBase).GetLinks();
		else
			NumLinks = 0;
	
		// Swap out fire sound
		if (NumLinks > 0)
			FireSoundClass = LinkedFireSound;
		else
			FireSoundClass = default.FireSoundClass;

        //FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        // Play firing noise
        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
            PlayOwnedSound(FireSoundClass, SLOT_None, FireSoundVolume/255.0,, FireSoundRadius, FireSoundPitch, False);

        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }

	simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
	{
		local ONSTurretBeamEffect Beam;
		local int NumLinks;
		local int BeamColor;

		if (Level.NetMode != NM_DedicatedServer)
		{

			if (LinkTank3Heavy(ONSWeaponPawn(Owner).VehicleBase) != None)
				NumLinks = LinkTank3Heavy(ONSWeaponPawn(Owner).VehicleBase).GetLinks();
			else
				NumLinks = 0;

			// Swap out fire sound
			if (NumLinks > 0)
				BeamColor = 1;
			else
				BeamColor = 0;

			if (Role < ROLE_Authority)
			{
				CalcWeaponFire();
				DualFireOffset *= -1;
			}
/* Not needed  Just spams client
// not used on other lasers. only on turrets.
      if (!Level.bDropDetail && Level.DetailMode != DM_Low)
            {
    			if (DualFireOffset < 0)
    				PlayAnim('RightFire');
    			else
    				PlayAnim('LeftFire');
    		}
*/
			Beam = Spawn(BeamEffectClass[BeamColor],,, WeaponFireLocation, rotator(HitLocation - WeaponFireLocation));
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(WeaponFireLocation - HitLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(WeaponFireLocation - HitLocation);
			Beam.SpawnEffects(HitLocation, HitNormal);
		}
	}
}

function byte BestMode()
{
	return 0;
}

// ============================================================================

defaultproperties
{
     LinkedFireSound=Sound'WeaponSounds.LinkGun.BLinkedFire'
     BeamEffectClass(0)=Class'LinkVehiclesOmni.Link3TurretBeamEffectGreen'
     BeamEffectClass(1)=Class'LinkVehiclesOmni.Link3TurretBeamEffectGold'
     YawBone="Object01"
     PitchBone="Object02"
     PitchUpLimit=12500
     PitchDownLimit=59500
     WeaponFireAttachmentBone="Object02"
     WeaponFireOffset=150.000000
     DualFireOffset=5.000000
     RotationsPerSecond=2.000000
     bInstantRotation=True
     bInstantFire=True
     RedSkin=Texture'LinkTank3Tex.LinkTankTex.LinkTankLaserRed'
     BlueSkin=Texture'LinkTank3Tex.LinkTankTex.LinkTankLaserBlue'
     FireInterval=0.20000
     FireSoundClass=Sound'WeaponSounds.Misc.instagib_rifleshot'
     AmbientSoundScaling=1.300000
     FireForce="Laser01"
     DamageType=Class'LinkVehiclesOmni.DamTypeLinkTank3HeavyTurretLasers'
     DamageMin=17
     DamageMax=25
     TraceRange=20000.000000
     Momentum=10000.000000
     AIInfo(0)=(bInstantHit=True,aimerror=750.000000)
     Mesh=SkeletalMesh'ONSWeapons-A.TankMachineGun'
     LinkMultiplier = 0.55000
     LinkMultiplierCap = 3.75
     VehicleDamageMult = 1.5
     bDoOffsetTrace=True
     DrawScale3D=(X=1.1000,Y=1.1000,Z=1.60000)
}
