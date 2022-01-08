class RoboRifleAttachment extends xWeaponAttachment;
var FX_SpaceFighter_3rdpMuzzle	MuzFlash[2];
var	float						MuzzleScale;
var	bool						bSwitch;
var vector fireoffset;
var class<FX_SpaceFighter_3rdpMuzzle>		MuzzleFlashClass;

var byte	OldSpawnHitCount;
var vector	mOldHitLocation;
var float	LastFireTime;
var class<ONSTurretBeamEffect> BeamEffectClass[2];
var	byte Team;


//function InitFor(Inventory I)
//{
//    Super.InitFor(I);

//	if ( (Instigator.PlayerReplicationInfo == None) || (Instigator.PlayerReplicationInfo.Team == None)
//		|| (Instigator.PlayerReplicationInfo.Team.TeamIndex > 1) )
//		REffect = Spawn(class'ShieldEffect3rd', I.Instigator);
//	else if ( Instigator.PlayerReplicationInfo.Team.TeamIndex == 0 )
//		REffect = Spawn(class'ShieldEffect3rdRED', I.Instigator);
//	else
//		REffect = Spawn(class'ShieldEffect3rdBLUE', I.Instigator);
 //   REffect.SetBase(I.Instigator);
//}



simulated function Destroyed()
{
    if ( MuzFlash[0] != None )
        MuzFlash[0].Destroy();

	if ( MuzFlash[1] != None )
        MuzFlash[1].Destroy();

    super.Destroyed();
}

/* UpdateHit
- used to update properties so hit effect can be spawn client side
*/
function UpdateHit(Actor HitActor, vector HitLocation, vector HitNormal)
{
   NetUpdateTime = Level.TimeSeconds - 1;
	SpawnHitCount++;
	mHitLocation	= HitLocation;
	mHitActor		= HitActor;
	mHitNormal		= HitNormal;
}


simulated event ThirdPersonEffects()
{
    if (Level.NetMode != NM_DedicatedServer)
    {
		if ( Excalibur_Robot(Instigator) == None )
			return;
        if (FlashCount == 0)
        {
            Excalibur_Robot(Instigator).StopFiring();
        }
        else if (FiringMode == 0)
        {
            Excalibur_Robot(Instigator).StartFiring(bHeavy, bRapidFire);
        }
        else
        {
            Excalibur_Robot(Instigator).StartFiring(bHeavy, bAltRapidFire);
        }
    }
	bSwitch = ( (FlashCount % 2) == 1 );

    if ( Level.NetMode != NM_DedicatedServer && Instigator != None && FlashCount > 0 )
	{
        if ( FiringMode == 0 )
        {
			if ( bSwitch )
				MuzzleFlashEffect( 0, 1 );		// Right Muzzle
			else
				MuzzleFlashEffect( 1,-1 );		// Left Muzzle
        }
        // have pawn play firing anim
		if ( Instigator != None && FiringMode == 0 && FlashCount > 0 )
		{
			if ( bSwitch )
				Instigator.PlayFiring(1.0, '1');
			else
				Instigator.PlayFiring(1.0, '0');
		}
    }



    super.ThirdPersonEffects();
}


simulated function MuzzleFlashEffect( int number, float fSide )
{
	local vector					Start;

	Start = GetMyFireStart();

    if ( MuzFlash[number] == None )
    {
		// Spawn Team colored Muzzle Flash effect
		MuzFlash[number] = Spawn(MuzzleFlashClass,,, Start, Instigator.Rotation);

		if ( MuzFlash[number] != None )
		{
			MuzFlash[number].SetScale( MuzzleScale );
			MuzFlash[number].SetBase( Instigator );

			if ( Instigator.GetTeamNum() == 0 ) // Red color version
				MuzFlash[number].SetRedColor();
		}
    }
	else
	{
		// Revive dead particles...
		MuzFlash[number].Emitters[0].SpawnParticle( 3 );
	}

	PlayNewFireFX();
}


simulated function PlayNewFireFX()
{
	local vector					Start;
	local FX_PlasmaImpact			FX_Impact;
	local ONSTurretBeamEffect Beam;
    Team=Instigator.GetTeamNum();
	if ( Instigator != None && Excalibur_Robot(Instigator) != None )
	{
		Start = GetMyFireStart();
		//HitActor = Excalibur_Robot(Instigator).CalcWeaponFire( HL, HN );
		Beam = Spawn(BeamEffectClass[Team],,,Start,Rotator(mHitLocation - Start));

          BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Min = VSize(Start - mHitLocation);
		  BeamEmitter(Beam.Emitters[0]).BeamDistanceRange.Max = VSize(Start - mHitLocation);
		  BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(Start - mHitLocation);
		  BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(Start - mHitLocation);
		  Beam.SpawnEffects(mHitLocation, mHitNormal);
	}

	// Impact effect
	if ( OldSpawnHitCount != SpawnHitCount )
	{
		OldSpawnHitCount = SpawnHitCount;
		GetHitInfo();

		if ( EffectIsRelevant(mHitLocation, false) && mHitNormal != vect(0,0,0) )
		{
			FX_Impact = Spawn(class'FX_PlasmaImpact',,, mHitLocation + mHitNormal * 2, rotator(mHitNormal));

			if ( Instigator != None && Instigator.GetTeamNum() == 0 )
				FX_Impact.SetRedColor();

			FX_Impact.PlaySound(Sound'WeaponSounds.BioRifle.BioRifleGoo2');

			if ( mHitActor != None && mHitActor.IsA('Pawn') )
			{
				FX_Impact.SetScale( 2.5 );
				FX_Impact.SetBase( mHitActor );
			}
			else
				FX_Impact.SetScale( 1.5 );
		}
	}
}


simulated function vector GetMyFireStart()
{
	local vector	X, Y, Z;

    fireoffset = Excalibur_Robot(Instigator).VehicleProjSpawnOffset;
    GetAxes( Instigator.Controller.Rotation, X, Y, Z );
    return Instigator.Location + Instigator.EyePosition() + X*fireoffset.X + Y*fireoffset.Y + Z*fireoffset.Z;
}

defaultproperties
{
     BeamEffectClass(0)=Class'CSAPVerIV.FX_GunEffectRed'
     BeamEffectClass(1)=Class'CSAPVerIV.FX_GunEffectBlue'
     bRapidFire=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=200
     LightSaturation=70
     LightBrightness=150.000000
     LightRadius=4.000000
     LightPeriod=3
     Mesh=SkeletalMesh'Weapons.Painter_3rd'
     DrawScale=1.000000
     DrawScale3D=(X=2.000000,Y=2.000000,Z=1.500000)
}
