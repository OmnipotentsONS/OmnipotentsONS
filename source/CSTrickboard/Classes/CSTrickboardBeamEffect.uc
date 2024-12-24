class CSTrickboardBeamEffect extends xEmitter;

var Vector	StartEffect, EndEffect;
var byte	Links, OldLinks;
var byte	LinkColor, OldLinkColor;
var bool	bLockedOn, bHitSomething;
var Pawn	LinkedPawn;
var Vector	EffectOffset;
var Vector	PrevLoc;
var Rotator PrevRot;
var float	scorchtime;

var CSTrickboardBeamSparks			Sparks;
var CSTrickboardMuzFlash MuzFlash, OldMuzFlash;

replication
{
    unreliable if (Role == ROLE_Authority)
        Links, LinkColor, LinkedPawn, bLockedOn, bHitSomething;

    unreliable if ( (Role == ROLE_Authority) && (!bNetOwner || bDemoRecording || bRepClientDemo)  )
        StartEffect, EndEffect;
}

simulated function Destroyed()
{
    if ( Sparks != None )
    {
        Sparks.SetTimer(0, false);
        Sparks.mRegen = false;
        Sparks.LightType = LT_None;
    }

    if ( MuzFlash != None )
        MuzFlash.mRegen = false;

    Super.Destroyed();
}

simulated function SetBeamLocation()
{
	if ( Level.NetMode == NM_DedicatedServer )
    {
        StartEffect = Instigator.Location + Instigator.EyeHeight*Vect(0,0,1);
        SetLocation( StartEffect );
        return;
    }

    if ( Instigator == None )
    {
        SetLocation( StartEffect );
    }
    else
    {
		if ( Instigator.IsFirstPerson() )
        {
            if ( (Instigator.Weapon == None) || Instigator.Weapon.WeaponCentered() || (Instigator.Weapon.Instigator == None) )
 		        SetLocation( Instigator.Location );
            else
				SetLocation(Instigator.Weapon.GetEffectStart() - 60 * vector(Instigator.Controller.Rotation));
        }
        else
        {
            SetLocation( Instigator.Location + Normal(EndEffect - Instigator.Location) * 25.0 );
        }
        if ( Role == ROLE_Authority ) // what clients will use if their instigator is not relevant yet
            StartEffect = Location;
    }
}

simulated function Vector SetBeamRotation()
{
    if ( (Instigator != None) && PlayerController(Instigator.Controller) != None )
        SetRotation( Instigator.Controller.GetViewRotation() );
    else
        SetRotation( Rotator(EndEffect - Location) );

	return Normal(EndEffect - Location);
}

simulated function bool CheckMaxEffectDistance(PlayerController P, vector SpawnLocation)
{
	return !P.BeyondViewDistance(SpawnLocation,1000);
}


simulated function Tick(float dt)
{
    local float LocDiff, RotDiff, WiggleMe,ls;
    local Vector BeamDir, HitLocation, HitNormal;
    local actor HitActor;
	local PlayerController P;

    if ( Role == ROLE_Authority && (Instigator == None || Instigator.Controller == None) )
    {
        Destroy();
        return;
    }

	// set beam start location
	SetBeamLocation();
	BeamDir = SetBeamRotation();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( (Instigator != None) && !Instigator.IsFirstPerson() )
		{
			if ( MuzFlash == None )
				MuzFlash = Spawn(class'CSTrickboardMuzFlash', self);
		}
		else if ( MuzFlash != None )
			MuzFlash.Destroy();

		if ( Sparks == None && EffectIsRelevant(EndEffect, false) )
		{
			P = Level.GetLocalPlayerController();
			if ( (P == Instigator.Controller) || CheckMaxEffectDistance(P, Location) )
				Sparks = Spawn(class'CSTrickboardBeamSparks', self);
		}
	}
    ls = class'LinkFire'.default.LinkScale[Min(Links,5)];

    if ( Links != OldLinks || LinkColor != OldLinkColor || MuzFlash != OldMuzFlash )
    {
        // beam size
        mSizeRange[0] = default.mSizeRange[0] * (ls*0.6 + 1);

        mWaveShift = default.mWaveShift * (ls*0.6 + 1);

        if ( LinkColor == 0 )
        {
            Skins[0] = FinalBlend'XEffectMat.ShockCoilFB';
        }
        else if ( LinkColor == 1 )
        {
            Skins[0] = FinalBlend'CSTrickboard.BeamFB';
        }
        else
        {
            Skins[0] = FinalBlend'CSTrickboard.BeamFB';
        }

		if ( MuzFlash != None )
		{
			MuzFlash.mSizeRange[0] = MuzFlash.default.mSizeRange[0] * (ls*0.5 + 1);
			MuzFlash.mSizeRange[1] = MuzFlash.mSizeRange[0];
		}

        LightBrightness = 180 + 40*ls;
        LightRadius = 6 + 3*ls;

        if ( Sparks != None )
        {
            Sparks.SetLinkStatus(Links, (LinkColor > 0), ls);
            Sparks.bHidden = (LinkColor > 0);
            Sparks.LightHue = LightHue;
            Sparks.LightBrightness = LightBrightness;
            Sparks.LightRadius = LightRadius - 3;
        }

        OldLinks		= Links;
        OldLinkColor	= LinkColor;
		OldMuzFlash		= MuzFlash;
    }

    if ( Level.bDropDetail || Level.DetailMode == DM_Low )
    {
		bDynamicLight = false;
        LightType = LT_None;
    }
    else if ( bDynamicLight )
        LightType = LT_Steady;

    if ( LinkedPawn != None )
    {
        EndEffect = LinkedPawn.Location + LinkedPawn.EyeHeight*Vect(0,0,0.5) - BeamDir*30.0;
    }

    mSpawnVecA = EndEffect;

    mWaveLockEnd = bLockedOn || (LinkColor > 0);

    // magic wiggle code
    if ( bLockedOn || (LinkColor > 0) )
    {
        mWaveAmplitude = FMax(0.0, mWaveAmplitude - (mWaveAmplitude+5)*4.0*dt);
    }
    else
    {
        LocDiff			= VSize((Location - PrevLoc) * Vect(1,1,5));
        RotDiff			= VSize(Vector(Rotation) - Vector(PrevRot));
        WiggleMe		= FMax(LocDiff*0.02, RotDiff*4.0);
        mWaveAmplitude	= FMax(1.0, mWaveAmplitude - mWaveAmplitude*1.0*dt);
        mWaveAmplitude	= FMin(16.0, mWaveAmplitude + WiggleMe);
    }

    PrevLoc = Location;
    PrevRot = Rotation;

    if ( Sparks != None )
    {
        Sparks.SetLocation( EndEffect - BeamDir*10.0 );
        if ( bHitSomething )
            Sparks.SetRotation( Rotation);
        else
            Sparks.SetRotation( Rotator(-BeamDir) );
        Sparks.mRegenRange[0] = Sparks.DesiredRegen;
        Sparks.mRegenRange[1] = Sparks.DesiredRegen;
        Sparks.bDynamicLight = true;
    }

    if ( bHitSomething && (Level.NetMode != NM_DedicatedServer) && (Level.TimeSeconds - ScorchTime > 0.07) )
    {
		ScorchTime = Level.TimeSeconds;
		HitActor = Trace(HitLocation, HitNormal, EndEffect + 100*BeamDir, EndEffect - 100*BeamDir, true);
		if ( (HitActor != None) && HitActor.bWorldGeometry )
			spawn(class'ShockImpactScorch',,,HitLocation,rotator(-HitNormal));
	}
}

defaultproperties
{
    EffectOffset=(X=22.000000,Y=11.000000,Z=1.400000)
    mParticleType=PT_Beam
    mMaxParticles=8
    mRegenDist=35.000000
    mSpinRange(0)=0.000000
    mSizeRange(0)=4.000000
    mColorRange(0)=(B=240,G=240,R=240)
    mColorRange(1)=(B=240,G=240,R=240)
    mAttenuate=False
    mAttenKa=0.000000
    mWaveFrequency=0.060000
    mWaveAmplitude=8.000000
    mWaveShift=100000.000000
    mBendStrength=6.000000
    mWaveLockEnd=True
    LightType=LT_Steady
    LightHue=195
    LightSaturation=100
    LightBrightness=255.000000
    LightRadius=4.000000
    bDynamicLight=True
    bNetTemporary=False
    bReplicateInstigator=True
    RemoteRole=ROLE_SimulatedProxy
    Skins(0)=FinalBlend'XEffectMat.ShockCoilFB'

    Style=STY_Additive
}