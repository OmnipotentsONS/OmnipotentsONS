/******************************************************************************
WraithLinkBeamEffect

Creation date: 2012-10-24 15:12
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/
#exec obj load File=LinkScorpionTex.utx
class WraithLinkBeamEffect extends xEmitter;


var array<Material> TeamBeamSkins, TeamMuzzleFlashSkins;
var array<byte> TeamLightHues;


var vector StartEffect, EndEffect;
var Actor LinkedActor;  //why is this actor and not Pawn like in linkbeameffect?
var byte LinkColor, OldLinkColor;
var bool bLeftBeam;
var bool bLockedOn, bHitSomething;

var array<LinkBeamChild> Children;
var int NumChildren;
var vector PrevLoc;
var rotator PrevRot;
var float ScorchTime;
var xEmitter MuzFlash;
var WraithLinkBeamEndEffect BeamEndEffect;

// from LinkBeamEffect
replication
{
    unreliable if (Role == ROLE_Authority)
       LinkColor, LinkedActor,  bLockedOn, bHitSomething, bLeftBeam;

    unreliable if ( (Role == ROLE_Authority) && (!bNetOwner || bDemoRecording || bRepClientDemo)  )
        StartEffect, EndEffect;
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

	if (MuzFlash != None) 	{
		MuzFlash.mRegen = false;
	}
	MuzFlash = None;

	if (BeamEndEffect != None) 	{
		BeamEndEffect.Destroy();
	}
	BeamEndEffect = None;

	Super.Destroyed();
}


function SetUpBeam(byte BeamColor, bool bLeft)
{
	local int i;
	local float LocDiff, RotDiff, WiggleMe;

  //Log("WraithLinkBeamEffect-SetupBeam");	
	bLeftBeam = bLeft;
	LinkColor = BeamColor;

	Skins[0] = TeamBeamSkins[LinkColor];
	LightHue = TeamLightHues[LinkColor];
	LocDiff        = VSize((Location - PrevLoc) * Vect(1,1,5));
	RotDiff        = VSize(Vector(Rotation) - Vector(PrevRot));
	WiggleMe       = FMax(LocDiff * 0.02, RotDiff * 4.0);
	mWaveAmplitude = default.mWaveAmplitude;
	mWaveAmplitude = FMin(16.0, mWaveAmplitude + WiggleMe);
  mWaveShift=default.mWaveShift;

 
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



simulated function SetBeamPosition()
{
	local ONSWeapon Gun;
	local vector NewLocation, X, Y, Z;
	local coords WeaponBoneCoords;

  //Log("Wraith UpdateBeamState-SetBeamPosition bLeftBeam"@bLeftBeam);
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
			//Log("Wraith UpdateBeamState-SetBeamPosition-have Gun, setting up");
			WeaponBoneCoords = Gun.GetBoneCoords(Gun.WeaponFireAttachmentBone);
			NewLocation = WeaponBoneCoords.Origin + Gun.WeaponFireOffset * WeaponBoneCoords.XAxis;
			if (bLeftBeam)
				NewLocation -= Abs(Gun.DualFireOffset) * WeaponBoneCoords.YAxis;
			else
				NewLocation += Abs(Gun.DualFireOffset) * WeaponBoneCoords.YAxis;
			//Log("Wraith UpdateBeamState-SetBeamPostion-NewLocation"@NewLocation);	
			SetLocation(NewLocation);
			SetRotation(OrthoRotation(WeaponBoneCoords.XAxis, WeaponBoneCoords.YAxis, WeaponBoneCoords.ZAxis));
		}
		else
		{
			// if theres no gun why do anything!!
			// maybe serverside?
			// WeaponFireOffset=6.000000  // 30
      //DualFireOffset=5.000000 //18
			GetAxes(rotator(EndEffect - Instigator.Location), X, Y, Z);
			NewLocation = Instigator.Location + 6 * X;
			if (bLeftBeam)
				NewLocation -= 5 * Y;
			else
				NewLocation += 5 * Y;
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

  LinkColor = Instigator.GetTeamNum();
	// set beam start location
	//Log("Calling SetBeamPosition from Tick()");
	SetBeamPosition();
// not in LinkBeamcode	StartEffect = Location;
	BeamDir = Normal(EndEffect - Location);

	if (LinkedActor != None)
	{
		EndEffect = LinkedActor.Location;
		if (!LinkedActor.TraceThisActor(HitLocation, HitNormal, LinkedActor.Location + LinkedActor.CollisionRadius * BeamDir, LinkedActor.Location - 1.5 * LinkedActor.CollisionRadius * BeamDir))
			EndEffect = HitLocation;
		else
			EndEffect = HitActor.Location;
		bLockedOn = True;
	  }
	else 
	  {
	   bLockedOn = False;
	  }


	mSpawnVecA = EndEffect;
	if (bLeftBeam && (bHitSomething || LinkedActor != None))
	{
		if (BeamEndEffect == None)
		{
			BeamEndEffect = Spawn(class'WraithLinkBeamEndEffect', Self,, EndEffect);
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



	// magic wiggle code
	
	if (bLockedOn)
	{
		mWaveAmplitude = FMax(1.0, mWaveAmplitude - (mWaveAmplitude + 5) * 4.0 * DeltaTime);
    mWaveShift = default.mWaveShift * 3;
    LightHue = TeamLightHues[2];  // show different hue for lock
    Skins[0] = TeamBeamSkins[4]; // Purple!
	}
	else
	{
		// not locked reset from locked type
    Skins[0] = TeamBeamSkins[LinkColor]; // reset to normal teams
		LightHue = TeamLightHues[LinkColor]; // reset to normal hue
		LocDiff        = VSize((Location - PrevLoc) * Vect(1,1,5));
		RotDiff        = VSize(Vector(Rotation) - Vector(PrevRot));
		WiggleMe       = FMax(LocDiff * 0.02, RotDiff * 4.0);
		mWaveAmplitude = default.mWaveAmplitude;
		//mWaveAmplitude = FMax(2.0, mWaveAmplitude - mWaveAmplitude * 0.5 * DeltaTime);
		mWaveAmplitude = FMin(16.0, mWaveAmplitude + WiggleMe);
    mWaveShift=default.mWaveShift;
	}

	PrevLoc = Location;
	PrevRot = Rotation;

	mWaveLockEnd = bLockedOn;
  mSpawnVecA = EndEffect;

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
     TeamBeamSkins(4)=FinalBlend'LinkScorpionTex.LinkBeamPurpleFB'
     TeamMuzzleFlashSkins(0)=Texture'XEffectMat.Link.link_muz_red'
     TeamMuzzleFlashSkins(1)=Texture'XEffectMat.Link.link_muz_blue'
     TeamMuzzleFlashSkins(2)=Texture'XEffectMat.Link.link_muz_green'
     TeamMuzzleFlashSkins(3)=Texture'XEffectMat.Link.link_muz_yellow'
     TeamLightHues(0)=120
     TeamLightHues(1)=100
     TeamLightHues(2)=210
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
     RemoteRole=ROLE_SimulatedProxy
     bNetTemporary=False
     bReplicateInstigator=True
     Skins(0)=FinalBlend'XEffectMat.Link.LinkBeamGreenFB'
     Style=STY_Additive
}
