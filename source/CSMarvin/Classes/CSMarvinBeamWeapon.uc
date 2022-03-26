class CSMarvinBeamWeapon extends ONSWeapon;

#exec AUDIO IMPORT File=Sounds\ProjectileShoot.wav 
#exec AUDIO IMPORT File=Sounds\ProjectileShootLow.wav 
#exec AUDIO IMPORT File=Sounds\Transporter.wav 
#exec AUDIO IMPORT File=Sounds\TransporterLoop.wav 

var CSMarvinAbductBeamEffect AbductBeam;
var ONSHeadlightCorona BeamCorona;
var Material BeamCoronaMaterial;

var CSMarvinAbductBeamRockEffect AbductBeamRocks;

var CSMarvinBeamProjector BeamProjector;
var Material BeamProjectorMaterial;
var sound BeamSoundClass;
var bool bBeamOn, bOldBeamOn;

var float AttractionRadius;
var float AttractionStrength;

replication
{
    reliable if(Role == ROLE_Authority)
        bBeamOn;

    reliable if(Role < ROLE_Authority)
        ServerCancelBeam, ServerSpawnBeam;
}

simulated function Destroyed()
{
    if(AbductBeam != none)
        AbductBeam.Kill();

    if(BeamProjector != None)
        BeamProjector.Destroy();

    if(BeamCorona != None)
        BeamCorona.Destroy();

    if(AbductBeamRocks != None)
        AbductBeamRocks.Destroy();

    super.Destroyed();
}

simulated function rotator BeamRotation()
{
    return Rotation + rot(-16384,0,0);
}

simulated function vector BeamLocation()
{
    return Location;
}

function TraceBeam(Vector Start, Rotator Dir, out Vector HitLocation, out Vector HitNormal, out Actor Other)
{
    local Vector X, End;

    MaxRange();
    X = Vector(Dir);
    End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, True);
}


state InstantFireMode
{
	function Fire(Controller C)
	{
        SpawnProjectile(ProjectileClass, False);
	}

    function AltFire(Controller C)
    {
        local vector start, hitlocation, hitnormal;
        local rotator dir;
        local actor victim;

        if(bBeamOn)
            return;

        start = BeamLocation();
        dir = BeamRotation();

        TraceBeam(start, dir, hitlocation, hitnormal, victim);
        SpawnBeamEffect(start, dir, hitlocation, hitnormal, 0);

        bBeamOn=!bBeamOn;
        AmbientSound = BeamSoundClass;
        SetTimer(AltFireInterval, true);
    }

    function CeaseFire(Controller C)
    {
        if(bIsAltFire)
        {
            CancelBeam();
            SetTimer(0.0,false);
            AmbientSound=None;
        }
        else
        {
            super.CeaseFire(C);
        }
    }

    simulated function ClientStartFire(Controller C, bool bWasAltFire)
    {
        super.ClientStartFire(C, bWasAltFire);
        if(bWasAltFire && Role < ROLE_Authority)
            ServerSpawnBeam();
    }


    simulated function ClientStopFire(Controller C, bool bWasAltFire)
    {
        super.ClientStopFire(C, bWasAltFire);
        if(bWasAltFire)
            ServerCancelBeam();
    }

    function Timer()
    {
        local vector HitLocation, HitNormal;
        local Actor victim;
        local int Damage;

        TraceBeam(BeamLocation(), BeamRotation(), HitLocation, HitNormal, victim);
        if(victim != none)
        {
            Damage = (DamageMin + Rand(DamageMax - DamageMin));
            victim.TakeDamage(Damage, Instigator, HitLocation, Momentum * vect(0,0,1), DamageType);
        }
    }

    simulated function ClientSpawnHitEffects()
    {}

    simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
    {}
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{

	if (ReflectNum == 0)
		Start = Owner.Location;

    if(AbductBeam != none)
    {
        AbductBeam.EndEffect = HitLocation;
    }
    else
    {
        AbductBeam = spawn(class'CSMarvinAbductBeamEffect',self,, Start, Dir);
        AbductBeam.SetBase(Owner);
        AbductBeam.SetRelativeRotation(rot(-16384,0,0));
    }

    if(BeamCorona == None)
    {
		BeamCorona = spawn( class'ONSHeadlightCorona', self,, Start + vect(0,0,-30), Dir);
        BeamCorona.SetBase(Owner);
        BeamCorona.SetRelativeRotation( rot(-16384,0,0));
        BeamCorona.Skins[0] = BeamCoronaMaterial;    
        BeamCorona.ChangeTeamTint(Team);
        BeamCorona.MaxCoronaSize = 800 * Level.HeadlightScaling;
        BeamCorona.bCorona = true;
    }
    if(BeamProjector == None)
    {
		BeamProjector = spawn( class'CSMarvinBeamProjector', self,, Start + vect(0,0,-30), Dir);
        BeamProjector.SetBase(Owner);
        BeamProjector.SetRelativeRotation( rot(-16384,0,0));
        BeamProjector.ProjTexture = BeamProjectorMaterial;    

        BeamProjector.SetDrawScale(1.0);
        BeamProjector.CullDistance	= 4000;
        BeamProjector.AttachProjector();
    }
    if(AbductBeamRocks == none)
    {
        AbductBeamRocks = spawn(class'CSMarvinAbductBeamRockEffect',self,, HitLocation, rotator(-HitNormal));
    }
}

simulated function OwnerEffects()
{
    local vector start,hitlocation,hitnormal;
    local rotator dir;
    local actor victim;

    super.OwnerEffects();

    if(bIsAltFire)
    {
        start = BeamLocation();
        dir = BeamRotation();

        TraceBeam(start,dir,hitlocation,hitnormal,victim);

        if(BeamCorona == None)
        {
            BeamCorona = spawn( class'ONSHeadlightCorona', self,, Start + vect(0,0,-30), Dir);
            BeamCorona.SetBase(Owner);
            BeamCorona.SetRelativeRotation( rot(-16384,0,0));
            BeamCorona.Skins[0] = BeamCoronaMaterial;    
            BeamCorona.ChangeTeamTint(Team);
            BeamCorona.MaxCoronaSize = 800 * Level.HeadlightScaling;
            BeamCorona.bCorona = true;
        }
        if(BeamProjector == None)
        {
            BeamProjector = spawn( class'CSMarvinBeamProjector', self,, Start + vect(0,0,-30), Dir);
            BeamProjector.SetBase(Owner);
            BeamProjector.SetRelativeRotation( rot(-16384,0,0));
            BeamProjector.ProjTexture = BeamProjectorMaterial;    

            BeamProjector.SetDrawScale(1.0);
            BeamProjector.CullDistance	= 4000;
            BeamProjector.AttachProjector();
        }
        if(AbductBeamRocks == none)
        {
            AbductBeamRocks = spawn(class'CSMarvinAbductBeamRockEffect',self,, HitLocation, rotator(-HitNormal));
        }
    }
}

simulated function CancelBeam()
{
    if(AbductBeam != None)
    {
        AbductBeam.Cancel();
        AbductBeam = None;
    }

    if(BeamCorona != None)
    {
        BeamCorona.Destroy();
        BeamCorona = None;
    }

    if(BeamProjector != None)
    {
        BeamProjector.Destroy();
        BeamProjector = None;
    }

    if(AbductBeamRocks != None)
    {
        AbductBeamRocks.Cancel();
        AbductBeamRocks = None;
    }
}

simulated function ServerCancelBeam()
{
    bBeamOn=false;
}

simulated function ServerSpawnBeam()
{
    local vector start, hitlocation, hitnormal;
    local rotator dir;
    local actor victim;

    start = BeamLocation();
    dir = BeamRotation();

    TraceBeam(start, dir, hitlocation, hitnormal, victim);
    SpawnBeamEffect(start, dir, hitlocation, hitnormal, 0);
}

simulated function Tick(float Delta)
{
    local vector HitLocation, HitNormal, Start, End, X;

    Super.Tick(Delta);

    Start = BeamLocation();
    X = Vector(BeamRotation());
    End = Start + TraceRange * X;

    if(bBeamOn)
    {
        Trace(HitLocation, HitNormal, End, Start, true);
        if(AbductBeam != None)
        {
            AbductBeam.EndEffect = HitLocation;
        }

        if(AbductBeamRocks != None)
        {
            AbductBeamRocks.SetLocation(HitLocation);
        }

        Attract(Delta, 1.0, 1.0);
    }

    if(BeamProjector != none)
    {
        BeamProjector.DetachProjector();
        BeamProjector.AttachProjector();
    }

    if(bBeamOn != bOldBeamOn)
    {
        if(!bBeamOn)
        {
            CancelBeam();
        }

        bOldBeamOn = bBeamOn;
    }
}


//borrowed parts from nephthys
simulated function Attract(float DeltaTime, float RadiusScale, float StrengthScale)
{
	const WantedPhysicsModes = 0xEA5E; // each bit stands for a physics mode to be considered
	local Actor A;
	local Pawn P;
	local float actualAttractRadius, actualAttractStrength, dist, zclamp;
	local vector dir, attraction, N;

	actualAttractRadius = AttractionRadius * RadiusScale;
	actualAttractStrength = AttractionStrength * StrengthScale;
    N = Normal(vector(BeamRotation()));

	foreach DynamicActors(class'Actor', A)
	{
		if (A.Role != ROLE_Authority && !A.bNetTemporary || A.Location == Location || (1 << A.Physics & WantedPhysicsModes) == 0)
			continue;

		dir = Location - A.Location;
        
        // use dist to line (instead of distance to point from mephthys) 
        dist = VSize((A.Location - Location) - ((a.Location - Location) * N) * N);
		dir /= dist;

		if (dist > actualAttractRadius)
			continue;

		attraction = dir * (actualAttractStrength * Square(1 - dist / actualAttractRadius));
        zclamp=0.7;
        if(XPawn(A) != None)
            zclamp=0.35;
        attraction.Z = Clamp(attraction.Z, 0, actualAttractStrength*zclamp);

		P = Pawn(A);
		if (P != None)
		{
			if (P.Physics == PHYS_Ladder && P.OnLadder != None)
			{
				if (vector(P.OnLadder.WallDir) dot attraction < -100)
					P.SetPhysics(PHYS_Falling);
			}
			else if (P.Physics == PHYS_Walking)
			{
				if (P.PhysicsVolume.Gravity dot attraction < -100)
					P.SetPhysics(PHYS_Falling);
			}
			else if (P.Physics == PHYS_Spider)
			{
				// probably not a good idea as I have no idea what people use spider physics for
				if (P.Floor dot attraction > 1000)
					P.SetPhysics(PHYS_Falling);
			}
			if (P == None)
				continue;
		}

		// check this, in case physics change
		if (A.Physics == PHYS_Karma || A.Physics == PHYS_KarmaRagdoll)
		{
			A.KAddImpulse(DeltaTime * 10 * Sqrt(A.KGetMass()) * attraction, vect(0,0,0));
		}
		else if (Pawn(A) != None)
		{
			A.Velocity += DeltaTime * attraction / Sqrt(A.Mass);
		}
		else
		{
			A.Velocity += DeltaTime * attraction / Sqrt(A.Mass);
		}
	}
}

defaultproperties
{
    bInstantFire=true
    Mesh=Mesh'ONSWeapons-A.PlasmaGun'
    YawBone=PlasmaGunBarrel
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchBone=PlasmaGunBarrel
    PitchUpLimit=18000
    PitchDownLimit=49153
    FireSoundClass=sound'CSMarvin.ProjectileShoot'
    AltFireSoundClass=sound'CSMarvin.Transporter'
    FireForce="Laser01"
    AltFireForce="Laser01"
    ProjectileClass=Class'CSMarvin.CSMarvinMissileProjectile'

    FireInterval=0.22
    AltFireInterval=0.1
    WeaponFireAttachmentBone=PlasmaGunAttachment
    WeaponFireOffset=0.0
    bAimable=True
    RotationsPerSecond=1.2
    DualFireOffset=44

    TraceRange=20000
    bDoOffsetTrace=True
    DamageMin=5
    DamageMax=5

    BeamCoronaMaterial=Material'EpicParticles.flashflare1'
	BeamProjectorMaterial=Texture'AW-2004Particles.Energy.LargeSpot'

    AttractionRadius=1000.000000
    AttractionStrength=50000.000000
    BeamSoundClass=sound'CSMarvin.TransporterLoop'
    DamageType=class'CSMarvinAbductBeamDamType'
}