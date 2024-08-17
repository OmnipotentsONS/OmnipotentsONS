//-----------------------------------------------------------
// Project Lead & Design: Wicked Penguin (Mark Rossmore)
//
// ©2004
//-----------------------------------------------------------
class FireBladeOmni extends ONSChopperCraft
    placeable;
    //ONSChopperCraft
 

#exec OBJ LOAD FILE=..\textures\FireBladeOmniTex.utx
#exec OBJ LOAD FILE=..\animations\FireBladeOmni.ukx


var()   float							MaxPitchSpeed;

var()   array<vector>					TrailEffectPositions;
var     class<ONSAttackCraftExhaust>	TrailEffectClass;
var     array<ONSAttackCraftExhaust>	TrailEffects;

var()	array<vector>					StreamerEffectOffset;
var     class<ONSAttackCraftStreamer>	StreamerEffectClass;
var		array<ONSAttackCraftStreamer>	StreamerEffect;

var()	range							StreamerOpacityRamp;
var()	float							StreamerOpacityChangeRate;
var()	float							StreamerOpacityMax;
var		float							StreamerCurrentOpacity;
var		bool							StreamerActive;
var float FireWhichGun;

// Rotation code
var float JetRotation;
var float EngineRotation;



function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	if ( FRand() < 0.7 )
	{
		VehicleMovingTime = Level.TimeSeconds + 1;
		Rise = 1;
	}
	return (Rise != 0);
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

simulated event DrivingStatusChanged()
{
	local vector RotX, RotY, RotZ;
	local int i;

	Super(ONSChopperCraft).DrivingStatusChanged();

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
                    if (i == 0) {
                      attachtobone(TrailEffects[i],'EngineLeftFlame');
                    }
                    if (i == 1) {
                      attachtobone(TrailEffects[i],'EngineRightFlame');
                    }
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


// ROTATION SOURCE

	local Rotator R;
	local Rotator R2;
	local rotator SBrake;
	local int MoveDirection;
	local int sbanimate;

//Added pooty, from Cicada, seems like good idea to call super.
/*
    local actor     HitActor;
    local vector    HitLocation, HitNormal;
    local float GroundDist;
    
		super.Tick(DeltaTime);

    if ( !IsVehicleEmpty() )
        Enable('tick');
        
 if ( (Bot(Controller) != None) && !Controller.InLatentExecution(Controller.LATENT_MOVETOWARD)  )
    {
        if ( Rise < 0 )
        {
            if ( Velocity.Z < 0 )
            {
                if ( Velocity.Z < -2000 )
                    Rise = -0.1;

                // FIX - use dist to adjust down as get closer
                HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,2000), Location, false);
                if ( HitActor != None )
                {
                    GroundDist = Location.Z - HitLocation.Z;
                    if ( GroundDist/(-1*Velocity.Z) < 0.85 )
                        Rise = 1.0;
                }
            }
        }
        else if ( Rise == 0 )
        {
            if ( !FastTrace(Location - vect(0,0,300),Location) )
                Rise = FClamp((-1 * Velocity.Z)/MaxRiseForce,0.f,1.f);
        }
    }
// from cicada
*/

	//ThrustAmount = FClamp(OutputThrust, -1.0, 1.0);
  ThrustAmount = FClamp(OutputThrust, 0.0, 1.0);
  
    // if press backwards
	if (EngineRotation > ThrustAmount)  {
		EngineRotation = EngineRotation - 0.2;

		}
	// if press forwards1
	if (EngineRotation < ThrustAmount) {
		EngineRotation = EngineRotation + 0.2;

        }
	// if static
	if (EngineRotation - ThrustAmount > -0.2 && EngineRotation - ThrustAmount < 0.2)   {
		EngineRotation = ThrustAmount;

       }
// Speedbrakes logic

/// The AnimBlendParams spams the UT log with Warnings blend parameters on skeletal mesh or some othebs... the little vents don't open and close now.. but no log spam.
// commented it out.  pooty 02/2024
   //  Forward Thrust
    if ( ThrustAmount > 0  ) {
        MoveDirection = 1;
		    SBrake.Roll = 0;
        if (sbanimate != 1) {
     //      AnimBlendParams(0, 1.0,,, 'EngineLeft');  // TrackLeftSB
           PlayAnim('LSBopen',,, 0);
      //     AnimBlendParams(1, 1.0,,, 'EngineRight'); // TrackRightSB
           PlayAnim('RSBopen',,, 1);
        }
        sbanimate = 1;
       }
   //  No Thrust
    if ( ThrustAmount == 0 ) {
        MoveDirection = 2;
		    SBrake.Roll = 0;
        if (sbanimate != 2) {
      //     AnimBlendParams(0, 1.0,,, 'EngineLeft');  // TrackLeftSB
           PlayAnim('LSBopen',,, 0);
      //     AnimBlendParams(1, 1.0,,, 'EngineRight'); // TrackRightSB
           PlayAnim('RSBopen',,, 1);
        }
        sbanimate = 2;
       }
   //  Reverse Thrust
    if ( ThrustAmount < 0 ) {
         MoveDirection = 0;
	     	SBrake.Roll = -10800;
        if (sbanimate != 0) {
        //   AnimBlendParams(0, 1.0,,, 'EngineLeft');  // TrackLeftSB
           PlayAnim('LSBclose',,, 0);
       //    AnimBlendParams(1, 1.0,,, 'EngineRight'); // TrackRightSB
           PlayAnim('RSBclose',,, 1);
        }
        sbanimate = 0;
       }
// Move speedbrakes to desired rotation


       //   SetBoneRotation('SB1', SBrake, 0, 1);
       //   SetBoneRotation('SB2', SBrake, 0, 1);
       //   SetBoneRotation('SB3', SBrake, 0, 1);
       //   SetBoneRotation('SB4', SBrake, 0, 1);
       //   SetBoneRotation('SB5', SBrake, 0, 1);
       //   SetBoneRotation('SB6', SBrake, 0, 1);
       //   SetBoneRotation('SB7', SBrake, 0, 1);
       //   SetBoneRotation('SB8', SBrake, 0, 1);


    // Move engines
	R2.Pitch = 5000 * EngineRotation;
	SetBoneRotation('EngineLeft', R2, 0, 1);
	R2.Pitch = 5000 * EngineRotation;
	SetBoneRotation('EngineRight', R2, 0, 1);

	JetRotation += DeltaTime * 655.350 * (35 + VSize(Velocity) * 0.02);

	R.Pitch = JetRotation;

	//SetBoneRotation('LProp2', R, 0, 1);
	//SetBoneRotation('RPropA2', R, 0, 1);
	//SetBoneRotation('joint5', R, 0, 1);
// END ROTATION SOURCE



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

    	// Adjust Engine FX depending on being drive/velocity
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

		// Update streamer opacity (limit max change speed)
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



// ..........................
// Alternating Fire
// THIS NEEDS FIXING OR COMPLETE REDOING - THE WEAPONS DO NOT WORK RIGHT
// ..........................
   //       Weapons[Activeweapon].bActive = False;

   //       ActiveWeapon = (Activeweapon + 1) % 2;

   //       Weapons[Activeweapon].bActive = True;

   // Super.Tick(DeltaTime);
// ..........................
// End Alternating Fire
// ..........................
}

// Alternating Fire

function WhichGun() {
if (FireWhichGun == 0 )
    {
       Weapons[0].bActive = True;
       Weapons[1].bActive = False;
       FireWhichGun = 1;
       }
 else
    {
       Weapons[0].bActive = False;
       Weapons[1].bActive = True;
       FireWhichGun = 0;
       }

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

//FIXME Fix to not be specific to this class after demo
function bool PlaceExitingDriver()
{
	local int i;
	local vector tryPlace, Extent, HitLocation, HitNormal, ZOffset;

	Extent = Driver.default.CollisionRadius * vect(1,1,0);
	Extent.Z = Driver.default.CollisionHeight;
	Extent *= 2;
	ZOffset = Driver.default.CollisionHeight * vect(0,0,1);
	if (Trace(HitLocation, HitNormal, Location + (ZOffset * 5), Location, false, Extent) != None)
		return false;

	//avoid running driver over by placing in direction perpendicular to velocity
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

		// First, do a line check (stops us passing through things on exit).
		if ( bRelativeExitPos && Trace(HitLocation, HitNormal, tryPlace, Location + ZOffset, false, Extent) != None )
			continue;

		// Then see if we can place the player there.
		if ( !Driver.SetLocation(tryPlace) )
			continue;

		return true;
	}
	return false;
}


/*
function DriverLeft()
{
    Super.DriverLeft();
    SVehicleUpdateParams();
}
*/

// ..........................
// Play TakeOff Animation
// ..........................

function KDriverEnter(Pawn P)
{
AnimBlendParams(0, 1.0,,, 'EngineLeft');  // TrackLeftSB
PlayAnim('LSBclose',,, 0);

AnimBlendParams(1, 1.0,,, 'EngineRight'); // TrackRightSB
PlayAnim('RSBclose',,, 1);

AnimBlendParams(2, 1.0,,, 'LGLeft');  // TrackLG
PlayAnim('LGup',,, 2);

AnimBlendParams(3, 1.0,,, 'LGRight');  // TrackLG
PlayAnim('LGup',,, 3);

     Super.KDriverEnter(P);
}

// ..........................
// Play Landing Animation
// ..........................

function bool KDriverLeave (bool bForceLeave) {

if (Super.KDriverLeave(bForceLeave)) {

		AnimBlendParams(0, 1.0,,, 'EngineLeft');  // TrackLeftSB
		PlayAnim('LSBopen',,, 0);

		AnimBlendParams(1, 1.0,,, 'EngineRight'); // TrackRightSB
		PlayAnim('RSBopen',,, 1);

		AnimBlendParams(2, 1.0,,, 'LGLeft');  // TrackLG
		PlayAnim('LGdown',,, 2);

		AnimBlendParams(3, 1.0,,, 'LGRight');  // TrackLG
		PlayAnim('LGdown',,, 3);

    return true;
} else return false;
    
}


// ..................................................
// ATTEMPT AT GETTING SPEEDBRAKES TO RESPOND TO INPUT
// ...................................................
// Never USed commented out 02/24 pooty
/*
function Animation() {
           if (Steering == 1) {
              AnimBlendParams(0, 1.0,,, 'EngineLeft');  // TrackLeftSB
              PlayAnim('LSBclose',,, 0);
              AnimBlendParams(1, 1.0,,, 'EngineRight'); // TrackRightSB
              PlayAnim('RSBopen',,, 1);
           }
           if (Steering == -1) {
              AnimBlendParams(0, 1.0,,, 'EngineLeft');  // TrackLeftSB
              PlayAnim('LSBopen',,, 0);
              AnimBlendParams(1, 1.0,,, 'EngineRight'); // TrackRightSB
              PlayAnim('RSBclose',,, 1);
           }
           if (Steering == 0) {
              AnimBlendParams(0, 1.0,,, 'EngineLeft');  // TrackLeftSB
              PlayAnim('LSBclose',,, 0);
              AnimBlendParams(1, 1.0,,, 'EngineRight'); // TrackRightSB
              PlayAnim('RSBclose',,, 1);
           }
   }

*/





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
    L.AddPrecacheMaterial(Material'VMVehicles-TX.AttackCraftGroup.RaptorColorRed');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.AttackCraftGroup.RaptorColorBlue');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.AttackCraftGroup.AttackCraftNoColor');
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
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.AttackCraftGroup.RaptorColorRed');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.AttackCraftGroup.RaptorColorBlue');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.AttackCraftGroup.AttackCraftNoColor');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlura');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.AttackCraftGroup.raptorCOLORtest');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     MaxPitchSpeed=3000.000000
     TrailEffectClass=Class'Onslaught.ONSAttackCraftExhaust'
     StreamerEffectOffset(0)=(X=-219.000000,Y=-35.000000,Z=57.000000)
     StreamerEffectOffset(1)=(X=-219.000000,Y=35.000000,Z=57.000000)
     StreamerEffectOffset(2)=(X=-52.000000,Y=-24.000000,Z=142.000000)
     StreamerEffectOffset(3)=(X=-52.000000,Y=24.000000,Z=142.000000)
     StreamerEffectClass=Class'Onslaught.ONSAttackCraftStreamer'
     StreamerOpacityRamp=(Min=1200.000000,Max=1600.000000)
     StreamerOpacityChangeRate=1.000000
     StreamerOpacityMax=0.700000
     UprightStiffness=500.000000
     UprightDamping=300.000000
     MaxThrustForce=100.000000
     LongDamping=0.050000
     MaxStrafeForce=160.000000
     LatDamping=0.050000
     MaxRiseForce=100.000000
     UpDamping=0.050000
     TurnTorqueFactor=600.000000
     TurnTorqueMax=200.000000
     TurnDamping=50.000000
     MaxYawRate=1.500000
     PitchTorqueFactor=200.000000
     PitchTorqueMax=35.000000
     PitchDamping=20.000000
     RollTorqueTurnFactor=450.000000
     RollTorqueStrafeFactor=50.000000
     RollTorqueMax=50.000000
     RollDamping=30.000000
     StopThreshold=100.000000
     MaxRandForce=3.000000
     RandForceInterval=0.750000
     DriverWeapons(0)=(WeaponClass=Class'FireBladeOmni.FireBladeOmniCannon',WeaponBone="root")
     // Stub for multiple weapons, never got it working, so we don't need to keep adding Dummys.
    // DriverWeapons(1)=(WeaponClass=Class'FireBladeOmni.FireBladeOmniDummyCannon',WeaponBone="LeftGun")
    // DriverWeapons(2)=(WeaponClass=Class'FireBladeOmni.FireBladeOmniDummyCannon',WeaponBone="RightGun")
     PassengerWeapons(0)=(WeaponPawnClass=Class'FireBladeOmni.FireBladeOmniTopTurretPawn',WeaponBone="root")
     RedSkin=Texture'FireBladeOmniTex.GunShipTextureRed'
     BlueSkin=Texture'FireBladeOmniTex.GunShipTextureBlue'
     IdleSound=Sound'FireBladeAudioB001.EngineIdle'
     StartUpSound=Sound'FireBladeAudioB001.EngineStartUp'
     ShutDownSound=Sound'FireBladeAudioB001.EngineShutDown'
     StartUpForce="AttackCraftStartUp"
     ShutDownForce="AttackCraftShutDown"
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.AttackCraftDead'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathAttackCraft'
     DestructionLinearMomentum=(Min=50000.000000,Max=150000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     DamagedEffectOffset=(X=-120.000000,Y=10.000000,Z=65.000000)
     ImpactDamageMult=0.001000
     HeadlightCoronaOffset(0)=(X=40.000000,Y=34.000000,Z=-20.000000)
     HeadlightCoronaOffset(1)=(X=40.000000,Y=-34.000000,Z=-20.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=60.000000
     VehicleMass=5.000000
     bTurnInPlace=True
     bShowDamageOverlay=True
     bDriverHoldsFlag=False
     bCanCarryFlag=False
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     EntryPosition=(X=-40.000000)
     EntryRadius=210.000000
     TPCamDistance=450.000000
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=200.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a FireBlade"
     VehicleNameString="FireBlade 2.1"
     RanOverDamageType=Class'Onslaught.DamTypeAttackCraftRoadkill'
     CrushedDamageType=Class'Onslaught.DamTypeAttackCraftPancake'
     FlagBone="LeftGun"
     FlagOffset=(Z=80.000000)
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn03'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn07'
     GroundSpeed=1200.000000
     HealthMax=600.000000
     Health=600
     Mesh=SkeletalMesh'FireBladeOmni.GunShip'
     //Mesh=SkeletalMesh'ONSVehicles-A.AttackCraft'
     CollisionRadius=150.000000
     CollisionHeight=70.000000
     PushForce=100000.000000
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
     KParams=KarmaParamsRBFull'FireBladeOmni.FireBladeOmni.KParams0'
     

}
