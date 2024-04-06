class FireHoundSideGun extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx

var class<ShockBeamEffect> BeamEffectClass;
var FireHoundSkyMine ComboTarget;
var float MinAim;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'XEffectMat.shock_mark_heat');
    L.AddPrecacheMaterial(Material'XEffectMat.shock_flash');
    L.AddPrecacheMaterial(Material'XEffectMat.purple_line');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_a');
    L.AddPrecacheMaterial(Material'XWeapons_rc.ShockBeamTex');
    L.AddPrecacheMaterial(Material'XEffects.SaDScorcht');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core_low');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_flare_a');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core');
    L.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_Energy_green_faded');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.EclipseCircle');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_mark_heat');
    Level.AddPrecacheMaterial(Material'XEffectMat.shock_flash');
    Level.AddPrecacheMaterial(Material'XEffectMat.purple_line');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock_ring_a');
    Level.AddPrecacheMaterial(Material'XWeapons_rc.ShockBeamTex');
    Level.AddPrecacheMaterial(Material'XEffects.SaDScorcht');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core_low');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_flare_a');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_core');
    Level.AddPrecacheMaterial(Material'XEffectMat.Shock.shock_Energy_green_faded');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.EclipseCircle');

    Super.UpdatePrecacheMaterials();
}

function byte BestMode()
{
	local Bot B;

	if (ComboTarget != None && Vehicle(Instigator).bWeaponIsAltFiring)
	{
		B = Bot(Instigator.Controller);
		if ( (B == None) || (B.Enemy == None) || (B.Enemy != B.Target) || B.EnemyVisible() ) 
			return 1;
		return 0;
	}
	else
		return 0;
}

function rotator AdjustAim(bool bAltFire)
{
	if (bAltFire && ComboTarget != None)
		return rotator(ComboTarget.Location - WeaponFireLocation);

	return Super.AdjustAim(bAltFire);
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local ShockBeamEffect Beam;

    Beam = Spawn(BeamEffectClass,,, Start, Dir);
    Beam.Instigator = None;
    Beam.AimAt(HitLocation, HitNormal);
}

function SetComboTarget(FireHoundSkyMine S)
{
	if (Bot(Instigator.Controller) == None || Instigator.Controller.Enemy == None)
		return;

	ComboTarget = S;
	ComboTarget.Monitor(Bot(Instigator.Controller).Enemy);
}

function DoCombo()
{
	if (Vehicle(Instigator) != None && Instigator.Controller != None)
	{
		Instigator.StopWeaponFiring();
		Vehicle(Instigator).bWeaponIsAltFiring = true;
	}
}

state InstantFireMode
{
    simulated function ClientSpawnHitEffects()
    {
    }

    function SpawnHitEffects(Actor HitActor, vector HitLocation, vector HitNormal)
    {
    }

    function AltFire(Controller C)
    {
        local float CurAim, BestAim;
        local int x;
        local Projectile BestMine;

        ShakeView();
        FlashMuzzleFlash();

        if (AmbientEffectEmitter != None)
        {
            AmbientEffectEmitter.SetEmitterStatus(true);
        }

        if (bAmbientFireSound)
            AmbientSound = FireSoundClass;
        else
            PlayOwnedSound(AltFireSoundClass, SLOT_None, AltFireSoundVolume/255.0,, AltFireSoundRadius,, False);

	BestAim = MinAim;
	for (x = 0; x < Projectiles.length; x++)
	{
		if (Projectiles[x] == None)
		{
			Projectiles.Remove(x, 1);
			x--;
		}
		else
		{
			CurAim = Normal(Projectiles[x].Location - WeaponFireLocation) dot vector(WeaponFireRotation);
			if (CurAim > BestAim)
			{
				BestMine = Projectiles[x];
				BestAim = CurAim;
			}
		}
	}
	if (BestMine != None)
		TraceFire(WeaponFireLocation, rotator(BestMine.Location - WeaponFireLocation));
	else
	        TraceFire(WeaponFireLocation, WeaponFireRotation);
    }

    function Fire(Controller C)
    {
    	local FireHoundSkyMine S;

    	S = FireHoundSkyMine(SpawnProjectile(ProjectileClass, False));
    	if ( S != None && Bot(Instigator.Controller) != None )
        	SetComboTarget(S);
    }
}

defaultproperties
{
     BeamEffectClass=Class'XWeapons.ShockBeamEffect'
     MinAim=0.925000
     YawBone="SIDEgunBASE"
     PitchBone="SIDEgunBARREL"
     PitchUpLimit=8000
     PitchDownLimit=62500
     WeaponFireAttachmentBone="Firepoint"
     GunnerAttachmentBone="SideGunnerLocation"
     bInstantRotation=True
     bInstantFire=True
     bDoOffsetTrace=True
     RedSkin=Texture'FireHound_Tex.FireHound.FireHoundRed'
     BlueSkin=Texture'FireHound_Tex.FireHound.FireHoundBlue'
     FireInterval=0.330000
     AltFireInterval=0.500000
     FlashEmitterClass=Class'FireVehiclesV2Omni.FireHoundMuzzleFlash'
     AltFireSoundClass=Sound'ONSVehicleSounds-S.Explosions.VehicleExplosion03'
     FireForce="PRVSideFire"
     AltFireForce="PRVSideAltFire"
     DamageType=Class'FireVehiclesV2Omni.FireHoundLaser'
     DamageMin=27
     DamageMax=37
     ProjectileClass=Class'FireVehiclesV2Omni.FireHoundSkyMine'
     ShakeRotMag=(X=60.000000,Y=20.000000)
     ShakeRotRate=(X=1000.000000,Y=1000.000000)
     ShakeRotTime=2.000000
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.200000,RefireRate=1.000000)
     AIInfo(1)=(bInstantHit=True,RefireRate=0.000000)
     CullDistance=6000.000000
     Mesh=SkeletalMesh'ONSWeapons-A.PRVsideGun'
     DrawScale=0.800000
}
