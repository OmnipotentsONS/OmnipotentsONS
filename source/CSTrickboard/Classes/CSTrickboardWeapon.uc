class CSTrickboardWeapon extends ONSWeapon;

var() sound LinkedFireSound;

var() class<CSTrickboardBeamEffect>	BeamEffectClass;
var() Sound	MakeLinkSound;
var() float LinkBreakDelay;
var() float MomentumTransfer;
var() class<DamageType> AltDamageType;
var() int AltDamage;
var() String MakeLinkForce;
var() float LinkFlexibility;
var() byte	LinkVolume;
var() Sound BeamSounds[4];
var() float VehicleDamageMult;

var float UpTime;
var Pawn LockedPawn;
var float LinkBreakTime;

var bool bInitAimError;
var	bool bDoHit;
var	bool bFeedbackDeath;
var	bool bLinkFeedbackPlaying;
var	bool bStartFire;
var byte SentLinkVolume;

var rotator DesiredAimError, CurrentAimError;
var Sound OldAmbientSound;

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
	local CSTrickboardBeamEffect ThisBeam;
	local CSTrickboardBeamEffect FoundBeam;

	if (CSTrickboard(Owner) != None)
		FoundBeam = CSTrickboard(Owner).Beam;

	if (FoundBeam == None || FoundBeam.bDeleteMe)
	{
		foreach DynamicActors(class'CSTrickboardBeamEffect', ThisBeam)
			if (ThisBeam.Instigator == Instigator)
				FoundBeam = ThisBeam;
	}

	if (FoundBeam == None)
	{
		FoundBeam = Spawn(BeamEffectClass, Owner,,WeaponFireLocation);
		if (CSTrickboard(Owner) != None)
			CSTrickboard(Owner).Beam = FoundBeam;
	}

	bDoHit = true;
	UpTime = FireInterval + 0.1;
}

simulated function ClientStartFire(Controller C, bool bAltFire)
{
	Super.ClientStartFire(C, bAltFire);
	if (!bAltFire && Role < ROLE_Authority)
	{
		UpTime = FireInterval + 0.1;
	}
}

function WeaponCeaseFire(Controller C, bool bWasAltFire)
{
	local CSTrickboardBeamEffect Beam;

	if (CSTrickboard(Owner) != None)
		Beam = CSTrickboard(Owner).Beam;

	if (!bWasAltFire && Beam != None)
	{
		Beam.Destroy();
		Beam = None;
		if (CSTrickboard(Owner) != None)
		{
			CSTrickboard(Owner).Beam = None;
			CSTrickboard(Owner).bBeaming = false;
		}

		Owner.AmbientSound = OldAmbientSound;
		OldAmbientSound = None;
		SetLinkTo(None);

		if (CSTrickboard(Owner) != None)
		{
			CSTrickboard(Owner).bLinking = false;
		}
	}
}

simulated event Tick(float dt)
{
	local Vector StartTrace, EndTrace, V, X, Y, Z;
	local Vector HitLocation, HitNormal, EndEffect;
	local Actor Other;
	local Rotator Aim;
	local CSTrickboard Trickboard;
	local CSTrickboardBeamEffect Beam;

	Super.Tick(dt);

	if (CSTrickboard(Owner) != None)
	{
		Trickboard = CSTrickboard(Owner);
		Beam = CSTrickboard(Owner).Beam;
	}
	
	if (Beam == None && Role == ROLE_Authority)
	{
		bInitAimError = true;
		return;
	}

	if (Trickboard != None && Trickboard.GetLinks() < 0)
	{
        Trickboard.ResetLinks();
    }

    if ( (UpTime > 0.0) || (Role < ROLE_Authority) )
    {
		UpTime -= dt;

		CalcWeaponFire();
		GetAxes( WeaponFireRotation, X, Y, Z );
		StartTrace = WeaponFireLocation;
		TraceRange = default.TraceRange + 250;

		if ( Role < ROLE_Authority )
        {
			if ( Beam != None )
            {
				LockedPawn = Beam.LinkedPawn;
            }
		}

		// If we're locked onto a pawn increase our trace distance
        if ( LockedPawn != None )
			TraceRange *= 1.5;

		if ( LockedPawn != None )
		{
			EndTrace = LockedPawn.Location + LockedPawn.BaseEyeHeight*Vect(0,0,0.5);
			if ( Role == ROLE_Authority )
			{
				V = Normal(EndTrace - StartTrace);
				if ( LockedPawn.Health <= 0 || LockedPawn.bDeleteMe || (VSize(EndTrace - StartTrace) > 2.5 * TraceRange) )
				{
					SetLinkTo( None );
				}
			}
		}

        if ( LockedPawn == None )
        {
	        if (Role == ROLE_Authority)
	        	Aim = AdjustAim(true);
	        else
	        	Aim = WeaponFireRotation;

            X = Vector(Aim);
            EndTrace = StartTrace + TraceRange * X;
        }

        Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
        if ( Other != None && Other != Instigator )
			EndEffect = HitLocation;
		else
			EndEffect = EndTrace;

		if ( Beam != None )
			Beam.EndEffect = EndEffect;

		if ( Role < ROLE_Authority )
		{
			return;
		}

        if ( Other != None && Other != Instigator )
        {
            // target can be linked to
            if ( IsLinkable(Other) )
            {
                if ( Other != lockedpawn )
                    SetLinkTo( Pawn(Other) );

                if ( lockedpawn != None )
                    LinkBreakTime = LinkBreakDelay;
            }
            else
            {
                // stop linking
                if ( lockedpawn != None )
                {
                    if ( LinkBreakTime <= 0.0 )
                        SetLinkTo( None );
                    else
                        LinkBreakTime -= dt;
                }

                // beam is updated every frame, but damage is only done based on the firing rate
                if ( bDoHit )
                {
                    if ( Beam != None )
						Beam.bLockedOn = false;

                    Instigator.MakeNoise(1.0);

                    if ( !Other.bWorldGeometry )
                    {
						if ( Beam != None )
							Beam.bLockedOn = true;

					}
				}
			}
		}

		if (Trickboard != None && bDoHit)
		{
			Trickboard.bLinking = (LockedPawn != None);
		}

		// Handle color changes
		if ( Beam != None )
		{
			if ( (Trickboard != None && Trickboard.bLinking) || ((Other != None) && (Instigator.PlayerReplicationInfo.Team != None) && Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)) )
			{
				Beam.LinkColor = Instigator.PlayerReplicationInfo.Team.TeamIndex + 1;
			}
			else
			{
				Beam.LinkColor = 0;
			}

			if (OldAmbientSound == None)
			{
				OldAmbientSound = Owner.AmbientSound;
				Owner.AmbientSound = BeamSounds[Min(Beam.Links,3)];
			}

			if (Trickboard != None)
				Trickboard.bBeaming = true;

			Soundvolume = FireSoundVolume;
			Beam.LinkedPawn = LockedPawn;
			Beam.bHitSomething = (Other != None);
			Beam.EndEffect = EndEffect;
		}
	}

    DoPullEffect(dt);
	bDoHit = false;
}

simulated function DoPullEffect(float dt)
{
     local vector PawnDir;
    local vector dist;
    local vector TargetPos, TargetDir;

    if(LockedPawn != None && Vehicle(LockedPawn) == None)
    {
        PawnDir = Normal(LockedPawn.Velocity - Velocity);
        TargetPos = LockedPawn.Location - PawnDir * class'CSTrickboard'.default.grappleDistToStop;

        dist = Owner.Location - TargetPos;
        TargetDir = Normal(Owner.Location - TargetPos);

        if(VSize(LockedPawn.Location - Owner.Location) > class'CSTrickboard'.default.grappleDistToStop)
            Owner.Velocity += TargetDir * FClamp(VSize(dist)*VSize(dist), 0, class'CSTrickboard'.default.grappleMaxForceFactor) * class'CSTrickboard'.default.grappleFscale;

    }
}
function SetLinkTo(Pawn Other)
{
	if (LockedPawn != Other)
	{
	    if (LockedPawn != None && CSTrickboard(Owner) != None)
	    {
            CSTrickboard(Owner).bLinking = false;
	    }

	    LockedPawn = Other;

	    if (LockedPawn != None)
	    {
			if (CSTrickboard(Owner) != None)
			{
		        CSTrickboard(Owner).bLinking = true;
			}
	
	        LockedPawn.PlaySound(MakeLinkSound, SLOT_None);
	    }
	}   
}

function bool IsLinkable(Actor Other)
{
    return Other.IsA('Pawn') && Other.bProjTarget;
}

function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local ONSWeaponPawn WeaponPawn;
    local Vehicle VehicleInstigator;
    local bool bDoReflect;
    local int ReflectNum;

    MaxRange();
    if ( bDoOffsetTrace )
    {
    	WeaponPawn = ONSWeaponPawn(Owner);
	    if ( WeaponPawn != None && WeaponPawn.VehicleBase != None )
    	{
    		if ( !WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else
			if ( !Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
				Start = HitLocation;
    }

    ReflectNum = 0;
    while ( true )
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;

        VehicleInstigator = Vehicle(Instigator);
        if ( ReflectNum == 0 && VehicleInstigator != None && VehicleInstigator.Driver != None )
        {
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = false;
        	Other = Trace(HitLocation, HitNormal, End, Start, true);
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = true;
        }
        else
        	Other = Trace(HitLocation, HitNormal, End, Start, True);

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

        if ( bDoReflect && ++ReflectNum < 4 )
        {
            Start = HitLocation;
            Dir	= Rotator(RefNormal);
        }
        else
        {
            break;
        }
    }

    NetUpdateTime = Level.TimeSeconds - 1;
}

defaultproperties
{
    LinkedFireSound=Sound'WeaponSounds.LinkGun.BLinkedFire'
    BeamEffectClass=Class'CSTrickboard.CSTrickboardBeamEffect'
    MakeLinkSound=Sound'WeaponSounds.LinkGun.LinkActivated'
    LinkBreakDelay=0.500000
    MomentumTransfer=2000.000000
    MakeLinkForce="LinkActivated"
    LinkFlexibility=0.050000
    LinkVolume=240
    BeamSounds(0)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
    BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam2'
    BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam3'
    BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam4'
    VehicleDamageMult=1.500000
    bInitAimError=True
    YawBone="Object02"
    PitchBone="Object02"
    PitchUpLimit=16384
    WeaponFireAttachmentBone="Muzzle"
    RotationsPerSecond=0.500000
    FireInterval=0.120000
    FireSoundClass=None
    FireSoundVolume=256.000000
    FireForce="Explosion05"
    DamageMin=0
    DamageMax=0
    TraceRange=5000.000000
    ShakeRotMag=(X=40.000000)
    ShakeRotRate=(X=2000.000000)
    ShakeRotTime=2.000000
    ShakeOffsetMag=(Y=1.000000)
    ShakeOffsetRate=(Y=-2000.000000)
    ShakeOffsetTime=4.000000
    AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.990000,RefireRate=0.990000)
    AIInfo(1)=(bInstantHit=True,WarnTargetPct=0.990000,RefireRate=0.990000)
    Mesh=SkeletalMesh'AS_VehiclesFull_M.LinkBody'
    DrawType=DT_None
    RedSkin=Shader'VMVehicles-TX.RVGroup.RVbladesSHAD'
    BlueSkin=Shader'VMVehicles-TX.RVGroup.RVbladesSHAD'
    DrawScale=0.100000
    SoundPitch=112
    SoundRadius=512.000000
    TransientSoundRadius=1024.000000
    bInstantFire=true
}