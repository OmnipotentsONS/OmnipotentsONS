class Aurora extends ONSAttackCraft
    placeable;

#exec OBJ LOAD FILE=..\textures\GorzBirds_Tex.utx

var()   float							MaxPitchSpeed;

var()   array<vector>					TrailEffectPositions;
var     class<AuroraExhaust>	TrailEffectClass;
var     array<AuroraExhaust>	TrailEffects;

var()	array<vector>					StreamerEffectOffset;
var     class<AuroraStreamer>	StreamerEffectClass;
var		array<AuroraStreamer>	StreamerEffect;

var()	range							StreamerOpacityRamp;
var()	float							StreamerOpacityChangeRate;
var()	float							StreamerOpacityMax;
var		float							StreamerCurrentOpacity;
var		bool							StreamerActive;

function bool FastVehicle()
{
	return true;
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	if ( FRand() < 0.7 )
	{
		VehicleMovingTime = Level.TimeSeconds + 1;
		Rise = 1;
	}
	return false;
}

function KDriverEnter(Pawn P)
{
	bHeadingInitialized = False;

	Super.KDriverEnter(P);
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	bHeadingInitialized = False;

	Super.ClientKDriverEnter(PC);
}

simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local vector CamLookAt, HitLocation, HitNormal, OffsetVector;
	local Actor HitActor;
    local vector x, y, z;

	if (DesiredTPCamDistance < TPCamDistance)
		TPCamDistance = FMax(DesiredTPCamDistance, TPCamDistance - CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));
	else if (DesiredTPCamDistance > TPCamDistance)
		TPCamDistance = FMin(DesiredTPCamDistance, TPCamDistance + CameraSpeed * (Level.TimeSeconds - LastCameraCalcTime));

    GetAxes(PC.Rotation, x, y, z);
	ViewActor = self;
	CamLookAt = GetCameraLocationStart() + (TPCamLookat >> Rotation) + TPCamWorldOffset;

	OffsetVector = vect(0, 0, 0);
	OffsetVector.X = -1.0 * TPCamDistance;

	CameraLocation = CamLookAt + (OffsetVector >> PC.Rotation);

	HitActor = Trace(HitLocation, HitNormal, CameraLocation, Location, true, vect(40, 40, 40));
	if ( HitActor != None
	     && (HitActor.bWorldGeometry || HitActor == GetVehicleBase() || Trace(HitLocation, HitNormal, CameraLocation, Location, false, vect(40, 40, 40)) != None) )
			CameraLocation = HitLocation;

    CameraRotation = Normalize(PC.Rotation + PC.ShakeRot);
    CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local int i;

    if(Level.NetMode != NM_DedicatedServer)
	{
    	for(i=0;i<TrailEffects.Length;i++)
        	TrailEffects[i].Destroy();
        TrailEffects.Length = 0;

		for(i=0; i<StreamerEffect.Length; i++)
			StreamerEffect[i].Destroy();
		StreamerEffect.Length = 0;
    }

	Super.Died(Killer, damageType, HitLocation);
}

simulated function Destroyed()
{
    local int i;

    if(Level.NetMode != NM_DedicatedServer)
	{
    	for(i=0;i<TrailEffects.Length;i++)
        	TrailEffects[i].Destroy();
        TrailEffects.Length = 0;

		for(i=0; i<StreamerEffect.Length; i++)
			StreamerEffect[i].Destroy();
		StreamerEffect.Length = 0;
    }

    Super.Destroyed();
}

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    if (DamageType == class'AuroraCombo' && EventInstigator != None && EventInstigator == self)
        return;

    Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

simulated event DrivingStatusChanged()
{
	local vector RotX, RotY, RotZ;
	local int i;

	Super.DrivingStatusChanged();

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
        GetAxes(Rotation,RotX,RotY,RotZ);

        if (TrailEffects.Length == 0)
        {
            TrailEffects.Length = TrailEffectPositions.Length;

        	for(i=0;i<TrailEffects.Length;i++)
            	if (TrailEffects[i] == None)
            	{
                	TrailEffects[i] = spawn(TrailEffectClass, self,, Location + (TrailEffectPositions[i] >> Rotation) );
                	TrailEffects[i].SetBase(self);
                    TrailEffects[i].SetRelativeRotation( rot(0,32768,0) );
                }
        }

        if (StreamerEffect.Length == 0)
        {
    		StreamerEffect.Length = StreamerEffectOffset.Length;

    		for(i=0; i<StreamerEffect.Length; i++)
        		if (StreamerEffect[i] == None)
        		{
        			StreamerEffect[i] = spawn(StreamerEffectClass, self,, Location + (StreamerEffectOffset[i] >> Rotation) );
        			StreamerEffect[i].SetBase(self);
        		}
    	}
    }
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
    	{
        	for(i=0;i<TrailEffects.Length;i++)
        	   TrailEffects[i].Destroy();

        	TrailEffects.Length = 0;

    		for(i=0; i<StreamerEffect.Length; i++)
                StreamerEffect[i].Destroy();

            StreamerEffect.Length = 0;
        }
    }
}

simulated function Tick(float DeltaTime)
{
    local float EnginePitch, DesiredOpacity, DeltaOpacity, MaxOpacityChange, ThrustAmount;
	local TrailEmitter T;
	local int i;
	local vector RelVel;
	local bool NewStreamerActive, bIsBehindView;
	local PlayerController PC;

    if(Level.NetMode != NM_DedicatedServer)
	{
        EnginePitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 32.0;
        SoundPitch = FClamp(EnginePitch, 64, 96);

        RelVel = Velocity << Rotation;

        PC = Level.GetLocalPlayerController();
		if (PC != None && PC.ViewTarget == self)
			bIsBehindView = PC.bBehindView;
		else
            bIsBehindView = True;

		if (!bIsBehindView)
		{
			for(i=0; i<TrailEffects.Length; i++)
				TrailEffects[i].SetThrustEnabled(false);
		}
        else
        {
			ThrustAmount = FClamp(OutputThrust, 0.0, 1.0);

			for(i=0; i<TrailEffects.Length; i++)
			{
				TrailEffects[i].SetThrustEnabled(true);
				TrailEffects[i].SetThrust(ThrustAmount);
			}
		}

		DesiredOpacity = (RelVel.X - StreamerOpacityRamp.Min)/(StreamerOpacityRamp.Max - StreamerOpacityRamp.Min);
		DesiredOpacity = FClamp(DesiredOpacity, 0.0, StreamerOpacityMax);

		MaxOpacityChange = DeltaTime * StreamerOpacityChangeRate;

		DeltaOpacity = DesiredOpacity - StreamerCurrentOpacity;
		DeltaOpacity = FClamp(DeltaOpacity, -MaxOpacityChange, MaxOpacityChange);

		if(!bIsBehindView)
            StreamerCurrentOpacity = 0.0;
        else
    		StreamerCurrentOpacity += DeltaOpacity;

		if(StreamerCurrentOpacity < 0.01)
			NewStreamerActive = false;
		else
			NewStreamerActive = true;

		for(i=0; i<StreamerEffect.Length; i++)
		{
			if(NewStreamerActive)
			{
				if(!StreamerActive)
				{
					T = TrailEmitter(StreamerEffect[i].Emitters[0]);
					T.ResetTrail();
				}

				StreamerEffect[i].Emitters[0].Disabled = false;
				StreamerEffect[i].Emitters[0].Opacity = StreamerCurrentOpacity;
			}
			else
			{
				StreamerEffect[i].Emitters[0].Disabled = true;
				StreamerEffect[i].Emitters[0].Opacity = 0.0;
			}
		}

		StreamerActive = NewStreamerActive;
    }

    Super.Tick(DeltaTime);
}

function float ImpactDamageModifier()
{
    local float Multiplier;
    local vector X, Y, Z;

    GetAxes(Rotation, X, Y, Z);
    if (ImpactInfo.ImpactNorm Dot Z > 0)
        Multiplier = 1-(ImpactInfo.ImpactNorm Dot Z);
    else
        Multiplier = 1.0;

    return Super.ImpactDamageModifier() * Multiplier;
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function bool PlaceExitingDriver()
{
	local int i;
	local vector tryPlace, Extent, HitLocation, HitNormal, ZOffset;

	Extent = Driver.default.CollisionRadius * vect(1,1,0);
	Extent *= 2;
	Extent.Z = Driver.default.CollisionHeight;
	ZOffset = Driver.default.CollisionHeight * vect(0,0,1);
	if (Trace(HitLocation, HitNormal, Location + (ZOffset * 6), Location, false, Extent) != None)
		return false;

	if ( VSize(Velocity) > 100 )
	{
		tryPlace = Normal(Velocity cross vect(0,0,1)) * (CollisionRadius + Driver.default.CollisionRadius ) * 1.25 ;
		if ( FRand() < 0.5 )
			tryPlace *= -1; //randomly prefer other side
		if ( (Trace(HitLocation, HitNormal, Location + tryPlace + ZOffset, Location + ZOffset, false, Extent) == None && Driver.SetLocation(Location + tryPlace + ZOffset))
		     || (Trace(HitLocation, HitNormal, Location - tryPlace + ZOffset, Location + ZOffset, false, Extent) == None && Driver.SetLocation(Location - tryPlace + ZOffset)) )
			return true;
	}

	for( i=0; i<ExitPositions.Length; i++)
	{
		if ( ExitPositions[0].Z != 0 )
			ZOffset = Vect(0,0,1) * ExitPositions[0].Z;
		else
			ZOffset = Driver.default.CollisionHeight * vect(0,0,2);

		if ( bRelativeExitPos )
			tryPlace = Location + ( (ExitPositions[i]-ZOffset) >> Rotation) + ZOffset;
		else
			tryPlace = ExitPositions[i];

		if ( bRelativeExitPos && Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) != None )
			continue;

		if ( !Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}
	return false;
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorWing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorTailWing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorGun');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'Gorzbirds_Tex.Aurora.AuroraRed');
    L.AddPrecacheMaterial(Material'Gorzbirds_Tex.Aurora.AuroraBlue');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlura');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.AttackCraftGroup.raptorCOLORtest');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorWing');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorTailWing');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorGun');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

	Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'Gorzbirds_Tex.Aurora.AuroraRed');
    Level.AddPrecacheMaterial(Material'Gorzbirds_Tex.Aurora.AuroraBlue');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlura');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     MaxPitchSpeed=2000.000000
     TrailEffectPositions(0)=(X=-148.000000,Y=-26.000000,Z=51.000000)
     TrailEffectPositions(1)=(X=-148.000000,Y=26.000000,Z=51.000000)
     TrailEffectClass=Class'AuroraOmni.AuroraExhaust'
     StreamerEffectOffset(0)=(X=-219.000000,Y=-35.000000,Z=57.000000)
     StreamerEffectOffset(1)=(X=-219.000000,Y=35.000000,Z=57.000000)
     StreamerEffectOffset(2)=(X=-52.000000,Y=-24.000000,Z=142.000000)
     StreamerEffectOffset(3)=(X=-52.000000,Y=24.000000,Z=142.000000)
     StreamerEffectClass=Class'AuroraOmni.AuroraStreamer'
     StreamerOpacityRamp=(Min=1200.000000,Max=1600.000000)
     StreamerOpacityChangeRate=1.000000
     StreamerOpacityMax=0.700000
     DriverWeapons(0)=(WeaponClass=Class'AuroraOmni.AuroraBigGun')
     RedSkin=Texture'GorzBirds_Tex.Aurora.AuroraRed'
     BlueSkin=Texture'GorzBirds_Tex.Aurora.AuroraBlue'
     VehiclePositionString="in an Aurora"
     VehicleNameString="Aurora 2.1"
     RanOverDamageType=Class'AuroraOmni.AuroraDamTypeRoadkill'
     CrushedDamageType=Class'AuroraOmni.AuroraDamTypePancake'
     HealthMax=350.000000
     Health=350
     Mesh=SkeletalMesh'Gorz_BB_Mesh.Birds.Aurora'
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.250000)
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=0.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=300.000000
     End Object
     KParams=KarmaParamsRBFull'AuroraOmni.Aurora.KParams0'

}
