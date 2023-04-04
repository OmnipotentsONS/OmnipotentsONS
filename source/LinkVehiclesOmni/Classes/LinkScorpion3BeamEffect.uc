//-----------------------------------------------------------
// (c) RBThinkTank 07
//  Coded by milk & Charybdis + Significant chunks of code from the original link gun.
//   LinkScorponBeamEffect.uc - ooo Pretty.
//-----------------------------------------------------------
#exec obj load File=LinkScorpion3Tex.utx
class LinkScorpion3BeamEffect extends LinkBeamEffect;

var LinkScorpion3Gun LinkScorp3Gun;

replication
{
    unreliable if (Role == ROLE_Authority)
		LinkScorp3Gun;
}

simulated function SetBeamLocation()
{

	if ( Level.NetMode == NM_DedicatedServer )
    {
		LinkScorp3Gun.CalcWeaponFire();
        StartEffect = LinkScorp3Gun.WeaponFireLocation;
        SetLocation( StartEffect );
        return;
    }
    if ( Instigator == None )
    {
        SetLocation( StartEffect );
    }
	else
	{
		LinkScorp3Gun.CalcWeaponFire();
	    StartEffect = LinkScorp3Gun.WeaponFireLocation;
        SetLocation( StartEffect );
	}
	/*
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
            Attachment = xPawn(Instigator).WeaponAttachment;
            if ( Attachment != None && (Level.TimeSeconds - Attachment.LastRenderTime) < 1 )
                SetLocation( Attachment.GetTipLocation() );
            else
                SetLocation( Instigator.Location + Normal(EndEffect - Instigator.Location) * 25.0 );
        }
        if ( Role == ROLE_Authority ) // what clients will use if their instigator is not relevant yet
            StartEffect = Location;
    }
	*/
}

simulated function Vector SetBeamRotation()
{
    if ( (Instigator != None) && PlayerController(Instigator.Controller) != None )
        SetRotation( LinkScorp3Gun.WeaponFireRotation);
    else
        SetRotation( LinkScorp3Gun.WeaponFireRotation );
	//LOG("EndEffectBeam:"$EndEffect);
	 mSpawnVecA = EndEffect;
	return Normal(EndEffect - Location);
}

simulated function Tick(float dt)
{
    local float LocDiff, RotDiff, WiggleMe,linkscale;
    local int c, n;
    local Vector BeamDir, HitLocation, HitNormal;
    local actor HitActor;
    local PlayerController P;
	
    if ( Role == ROLE_Authority && (Instigator == None || Instigator.Controller == None) )  {
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
				MuzFlash = Spawn(class'LinkMuzFlashBeam3rd', self);
		}
		else if ( MuzFlash != None )
			MuzFlash.Destroy();

		if ( Sparks == None && EffectIsRelevant(EndEffect, false) )
		{
			P = Level.GetLocalPlayerController();
			if ( (P == Instigator.Controller) || CheckMaxEffectDistance(P, Location) )
				Sparks = Spawn(class'LinkScorp3Sparks', self);
		}
	}
    linkscale = class'LinkFire'.default.LinkScale[Min(Links,5)];

    if ( Links != OldLinks || LinkColor != OldLinkColor || MuzFlash != OldMuzFlash )
    {
        // beam size
        mSizeRange[0] = default.mSizeRange[0] * (linkscale*0.6 + 1);

        mWaveShift = default.mWaveShift * (linkscale*0.6 + 1);

        // create/destroy children
        NumChildren = Min(Links+1, MAX_CHILDREN);
		if ( Level.NetMode != NM_DedicatedServer )
		{
			for (c=0; c<MAX_CHILDREN; c++)
			{
				if ( c < NumChildren && !Level.bDropDetail && Level.DetailMode != DM_Low )
				{
					if ( Child[c] == None )
						Child[c] = Spawn(class'LinkScorpion3BeamChild', self);

					Child[c].mSizeRange[0] = 2.0 + 4.0 * (NumChildren - c);
				}
				else if ( Child[c] != None )
					Child[c].Destroy();
			}
		}

        if ( LinkColor == 0 )
        {
            if ( Links > 0 )
            {
                Skins[0] = FinalBlend'XEffectMat.LinkBeamYellowFB';//was yellow
                if ( MuzFlash != None )
					         MuzFlash.Skins[0] = Texture'XEffectMat.link_muz_yellow';
                LightHue = 40;
            }
            else
            {
                Skins[0] = FinalBlend'XEffectMat.LinkBeamGreenFB'; //green
                if ( MuzFlash != None )
	                MuzFlash.Skins[0] = Texture'XEffectMat.link_muz_green';
                LightHue = 179;
            }
        }
        else if ( LinkColor == 1 )
        {
            Skins[0] = FinalBlend'XEffectMat.LinkBeamRedFB';
            if ( MuzFlash != None )
				MuzFlash.Skins[0] = Texture'XEffectMat.link_muz_red';
            LightHue = 0;
        }
        else
        {
            Skins[0] = FinalBlend'XEffectMat.LinkBeamBlueFB';
            if ( MuzFlash != None )
	            MuzFlash.Skins[0] = Texture'XEffectMat.link_muz_blue';
            LightHue = 160;
        }

		if ( MuzFlash != None )
		{
			MuzFlash.mSizeRange[0] = MuzFlash.default.mSizeRange[0] * (linkscale*0.5 + 1);
			MuzFlash.mSizeRange[1] = MuzFlash.mSizeRange[0];
		}

        LightBrightness = 180 + 40*linkscale;
        LightRadius = 6 + 3*linkscale;

        if ( Sparks != None )
        {
            Sparks.SetLinkStatus(Links, (LinkColor > 0), linkscale);
            Sparks.bHidden = (LinkColor > 0);
            Sparks.LightHue = LightHue;
            Sparks.LightBrightness = LightBrightness;
            Sparks.LightRadius = LightRadius - 3;
        }

        if ( LinkColor > 0 && LinkedPawn != None )
        {
            if ( (ProtSphere == None) && (Level.NetMode != NM_DedicatedServer) )
            {
                ProtSphere = Spawn(class'LinkProtSphere');
                if (LinkColor == 2)
                    ProtSphere.Skins[0] = Texture'XEffectMat.link_muz_blue';
            }
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

    for (c=0; c<NumChildren; c++)
    {
        if ( Child[c] != None )
        {
            n = c+1;
            Child[c].SetLocation( Location );
            Child[c].SetRotation( Rotation );
            Child[c].mSpawnVecA		= mSpawnVecA;
            Child[c].mWaveShift		= mWaveShift*0.6;
            Child[c].mWaveAmplitude = n*4.0 + mWaveAmplitude*((16.0-n*4.0)/16.0);
            Child[c].mWaveLockEnd	= (LinkColor > 0); //mWaveLockEnd;
            Child[c].Skins[0]		= Skins[0];
			if(Links > 0)
			{
				Child[c].Skins[0]=FinalBlend'LinkScorpion3Tex.LinkBeamOrangeFB';			
				}
        }
    }

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

    if ( LinkColor > 0 && LinkedPawn != None )
    {
        if ( ProtSphere != None )
        {
            ProtSphere.SetLocation( EndEffect );
            ProtSphere.SetRotation( Rotation );
            ProtSphere.bHidden = false;
            if ( LinkedPawn.IsFirstPerson() )
                ProtSphere.mSizeRange[0] = 20.0;
            else
                ProtSphere.mSizeRange[0] = 35.0;
            ProtSphere.mSizeRange[1] = ProtSphere.mSizeRange[0];
        }
    }
    else
    {
        if ( ProtSphere != None )
			ProtSphere.bHidden = true;
    }
    if ( bHitSomething && (Level.NetMode != NM_DedicatedServer) && (Level.TimeSeconds - ScorchTime > 0.07) )
    {
		ScorchTime = Level.TimeSeconds;
		HitActor = Trace(HitLocation, HitNormal, EndEffect + 100*BeamDir, EndEffect - 100*BeamDir, true);
		if ( (HitActor != None) && HitActor.bWorldGeometry )
			spawn(class'LinkScorch',,,HitLocation,rotator(-HitNormal));
	}
}

simulated function bool CheckMaxEffectDistance(PlayerController P, vector SpawnLocation)
{
	return !P.BeyondViewDistance(SpawnLocation,1000);
}

defaultproperties
{
     Skins(0)=FinalBlend'XEffectMat.Link.LinkBeamGreenFB'
     
}
