/******************************************************************************
BansheeLinkBeamEffect

Creation date: 2012-10-24 15:12
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class BansheeLinkBeamEffect extends xEmitter;


var array<Material> TeamBeamSkins, TeamMuzzleFlashSkins;
var array<byte> TeamLightHues;


var vector StartEffect, EndEffect;
var Actor LinkedActor;
var byte LinkColor;
var bool bLeftBeam;
var bool bLockedOn, bHitSomething;

var array<LinkBeamChild> Children;
var vector PrevLoc;
var rotator PrevRot;
var float ScorchTime;
var xEmitter MuzFlash;
var BansheeLinkBeamEndEffect BeamEndEffect;


function SetUpBeam(byte BeamColor, bool bLeft)
{
	local int i, NumChildren;

	bLeftBeam = bLeft;
	LinkColor = BeamColor;

	Skins[0] = TeamBeamSkins[LinkColor];
	LightHue = TeamLightHues[LinkColor];

	if (Level.NetMode != NM_DedicatedServer)
	{
		if (MuzFlash == None)
		{
			MuzFlash = Spawn(class'LinkMuzFlashBeam3rd', self);
		}
		MuzFlash.Skins[0] = TeamMuzzleFlashSkins[LinkColor];

		NumChildren = Max(0, Level.DetailMode - int(Level.bDropDetail));
		if (Children.Length > NumChildren)
		{
			for (i = Children.Length - 1; i >= NumChildren; i--)
			{
				if (Children[i] != None)
					Children[i].Destroy();

				Children.Remove(i, 1);
			}
		}
		for (i = 0; i < NumChildren; i++)
		{
			if (Children.Length <= i || Children[i] == None)
				Children[i] = Spawn(class'LinkBeamChild', self);
			Children[i].mSizeRange[0] = 2.0 + 4.0 * (NumChildren - i);
			Children[i].Skins[0] = Skins[0];
		}
	}
}

simulated function Destroyed()
{
	local int i;

	for (i = 0; i < Children.Length; i++)
	{
		if (Children[i] != None)
			Children[i].Destroy();
	}
	Children.Length = 0;

	if (MuzFlash != None)
	{
		MuzFlash.mRegen = false;
	}
	MuzFlash = None;

	if (BeamEndEffect != None)
	{
		BeamEndEffect.Destroy();
	}
	BeamEndEffect = None;

	Super.Destroyed();
}

simulated function SetBeamPosition()
{
	local ONSWeapon Gun;
	local vector NewLocation, X, Y, Z;
	local coords WeaponBoneCoords;

	if (ONSWeaponPawn(Instigator) == None)
	{
		SetLocation(StartEffect);
		SetRotation(rotator(EndEffect - StartEffect));
	}
	else
	{
		Gun = ONSWeaponPawn(Instigator).Gun;
		if (Gun != None)
		{
			WeaponBoneCoords = Gun.GetBoneCoords(Gun.WeaponFireAttachmentBone);
			NewLocation = WeaponBoneCoords.Origin + Gun.WeaponFireOffset * WeaponBoneCoords.XAxis;
			if (bLeftBeam)
				NewLocation -= Abs(Gun.DualFireOffset) * WeaponBoneCoords.YAxis;
			else
				NewLocation += Abs(Gun.DualFireOffset) * WeaponBoneCoords.YAxis;
			SetLocation(NewLocation);
			SetRotation(OrthoRotation(WeaponBoneCoords.XAxis, WeaponBoneCoords.YAxis, WeaponBoneCoords.ZAxis));
		}
		else
		{
			GetAxes(rotator(EndEffect - Instigator.Location), X, Y, Z);
			NewLocation = Instigator.Location + 30 * X;
			if (bLeftBeam)
				NewLocation -= 18 * Y;
			else
				NewLocation += 18 * Y;
			SetLocation(NewLocation);
			SetRotation(Instigator.Rotation);
		}
	}

	if (Role == ROLE_Authority)
		StartEffect = Location;
}

simulated function bool CheckMaxEffectDistance(PlayerController P, vector SpawnLocation)
{
	return !P.BeyondViewDistance(SpawnLocation, 2000);
}

simulated function Tick(float DeltaTime)
{
	local float LocDiff, RotDiff, WiggleMe;
	local int i;
	local vector BeamDir, HitLocation, HitNormal;
	local Actor HitActor;

	if (Role == ROLE_Authority && (Instigator == None || Instigator.Controller == None))
	{
		Destroy();
		return;
	}

	// set beam start location
	SetBeamPosition();
	//StartEffect = Location;
	BeamDir = Normal(EndEffect - Location);

	if (LinkedActor != None)
	{
		EndEffect = LinkedActor.Location;
		/*
		if (!LinkedActor.TraceThisActor(HitLocation, HitNormal, LinkedActor.Location + LinkedActor.CollisionRadius * BeamDir, LinkedActor.Location - 1.5 * LinkedActor.CollisionRadius * BeamDir))
			EndEffect = HitLocation;
		else
			EndEffect = HitActor.Location;
		*/
	}

	mSpawnVecA = EndEffect;
	if (bLeftBeam && (bHitSomething || LinkedActor != None))
	{
		if (BeamEndEffect == None)
		{
			BeamEndEffect = Spawn(class'BansheeLinkBeamEndEffect', Self,, EndEffect);
			BeamEndEffect.LightHue = TeamLightHues[LinkColor];
		}
		else
		{
			BeamEndEffect.SetLocation(EndEffect);
		}
	}
	else if (BeamEndEffect != None)
	{
		BeamEndEffect.Destroy();
		BeamEndEffect = None;
	}

	mWaveLockEnd = bLockedOn;

	// magic wiggle code
	if (bLockedOn)
	{
		mWaveAmplitude = FMax(1.0, mWaveAmplitude - (mWaveAmplitude + 5) * 4.0 * DeltaTime);
	}
	else
	{
		LocDiff        = VSize((Location - PrevLoc) * Vect(1,1,5));
		RotDiff        = VSize(Vector(Rotation) - Vector(PrevRot));
		WiggleMe       = FMax(LocDiff * 0.02, RotDiff * 4.0);
		mWaveAmplitude = FMax(2.0, mWaveAmplitude - mWaveAmplitude * 0.5 * DeltaTime);
		mWaveAmplitude = FMin(16.0, mWaveAmplitude + WiggleMe);
	}

	PrevLoc = Location;
	PrevRot = Rotation;

	for (i = 0; i < Children.Length; i++)
	{
		Children[i].SetLocation(Location);
		Children[i].SetRotation(Rotation);
		Children[i].mSpawnVecA     = mSpawnVecA;
		Children[i].mWaveShift     = mWaveShift * 0.6;
		Children[i].mWaveAmplitude = (i + 1) * 4.0 + mWaveAmplitude * (12.0 - i * 4.0) / 16.0;
		Children[i].mWaveLockEnd   = mWaveLockEnd;
	}

	if (bHitSomething && Level.NetMode != NM_DedicatedServer && Level.TimeSeconds - ScorchTime > 0.07)
	{
		ScorchTime = Level.TimeSeconds;
		HitActor = Trace(HitLocation, HitNormal, EndEffect + 100 * BeamDir, EndEffect - 100 * BeamDir, true);
		if (HitActor != None && HitActor.bWorldGeometry)
			Spawn(class'LinkScorch',,, HitLocation, rotator(-HitNormal));
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     TeamBeamSkins(0)=FinalBlend'XEffectMat.Link.LinkBeamRedFB'
     TeamBeamSkins(1)=FinalBlend'XEffectMat.Link.LinkBeamBlueFB'
     TeamBeamSkins(2)=FinalBlend'XEffectMat.Link.LinkBeamGreenFB'
     TeamBeamSkins(3)=FinalBlend'XEffectMat.Link.LinkBeamYellowFB'
     TeamMuzzleFlashSkins(0)=Texture'XEffectMat.Link.link_muz_red'
     TeamMuzzleFlashSkins(1)=Texture'XEffectMat.Link.link_muz_blue'
     TeamMuzzleFlashSkins(2)=Texture'XEffectMat.Link.link_muz_green'
     TeamMuzzleFlashSkins(3)=Texture'XEffectMat.Link.link_muz_yellow'
     TeamLightHues(1)=160
     TeamLightHues(2)=100
     TeamLightHues(3)=40
     mParticleType=PT_Beam
     mMaxParticles=3
     mRegenDist=65.000000
     mSpinRange(0)=45000.000000
     mSizeRange(0)=17.000000
     mColorRange(0)=(B=240,G=240,R=240)
     mColorRange(1)=(B=240,G=240,R=240)
     mAttenuate=False
     mAttenKa=0.000000
     mWaveFrequency=0.060000
     mWaveAmplitude=8.000000
     mWaveShift=100000.000000
     mBendStrength=3.000000
     mWaveLockEnd=True
     LightType=LT_Steady
     LightHue=100
     LightSaturation=100
     LightBrightness=255.000000
     LightRadius=4.000000
     bDynamicLight=True
     Skins(0)=FinalBlend'XEffectMat.Link.LinkBeamGreenFB'
     Style=STY_Additive
}
