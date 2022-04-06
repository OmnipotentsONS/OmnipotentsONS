//-----------------------------------------------------------
// Helix ESV (extended support vehicle), made by hyperforce.
// with some help form:
// -Jonathan Zepp helped me with the Items Coding (from Combat ambulance Beta 2)
// -Rens2Sea For helping out with the mutator
// -and all ppl from the ICE (infensus Clan Europe) Clan that helped me test this vehicle
// Edits for OMNI, removed annoying giant muzzle flashes..left int the tracers...
//-----------------------------------------------------------
class HelixESVOmni extends ONSchopperCraft
    placeable;
//The Plane pre-load options                                           // <- files and packages that will be loaded with the vehicle
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx
#exec OBJ LOAD FILE=..\textures\ESV2.utx
#exec OBJ LOAD FILE=..\animations\Helix2_final.ukx
#exec OBJ LOAD FILE=..\Sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=..\StaticMeshes\Helix2.usx
//The Item pre-load options
#exec OBJ LOAD FILE=..\textures\VehicleFX.utx
#exec OBJ LOAD FILE=..\textures\EpicParticles.utx
#exec OBJ LOAD FILE=..\Sounds\PickupSounds.uax
#exec OBJ LOAD FILE=..\StaticMeshes\E_Pickups.usx
//The Reardoor deploy Pre-load options
#exec OBJ LOAD FILE=..\Sounds\MenuSounds.uax
#exec OBJ LOAD FILE=..\Textures\ONSFullTextures.utx
#exec OBJ LOAD FILE=..\Sounds\IndoorAmbience.uax

#exec AUDIO IMPORT FILE="Sounds\GetSomeFullMetalJacket.wav"
#exec AUDIO IMPORT FILE="Sounds\LetsRockVasquezALIENS.wav"
// plane options
//-------------------------------------------------------------------------------------------------
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

//--- advanced plane options ---

var	bool	bHeatSeeker;
var byte 	LastThrust;
var float 	DesiredPitch;
var float 	CurrentPitch;
var float 	PitchTime;

var rotator	FanYaw,TailYaw;
var float 	FanYawRate;

var int		LastYaw, DesiredYaw;
var float	YawTime;

var 			Material 	LockedTexture;
var 			Material 	LockedEffect;
var localized 	string	 	LockedMsg;

var() HudBase.SpriteWidget HudMissileCount, HudMissileIcon;
var() HudBase.NumericWidget HudMissileDigits;
var() HudBase.DigitSet DigitsBig;

var vector OldLockedTarget;

var bool bFreelanceStart;
//-------------------------------------------------------------------------------------------------
//  Item options
var name ShieldPickupBone, HealthPickupBone, LinkGunPickupBone, LinkAmmoBone1 ;    //bone names
var name LinkAmmoBone2, LinkAmmoBone3, FlakAmmoBone, RocketAmmoBone ;
var Pickup a,b,c ;
var UTAmmoPickup d,e,f,g,h ;
var float aCurrentSpin, bCurrentSpin ;                                            //Pickup Spins
//-------------------------------------------------------------------------------------------------
//  Rear door options
var()       sound   DeploySound;
var()       sound   HideSound;
var()		string	DeployForce;
var()		string	HideForce;
var         EPhysics    ServerPhysics;

var			bool	bDeployed;
var			bool	bOldDeployed;

var			vector  UnDeployedTPCamLookat;
var			vector  UnDeployedTPCamWorldOffset;
var			vector  DeployedTPCamLookat;
var			vector  DeployedTPCamWorldOffset;

var			vector  UnDeployedFPCamPos;
var			vector  DeployedFPCamPos;
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------


replication
{
	unreliable if(Role==ROLE_Authority)
        ServerPhysics, bDeployed;
}

//  Vehicle Horn options:
function VehicleFire(bool bWasAltFire)
{

	if (bWasAltFire && PlayerController(Controller) != None)
		PlayerController(Controller).ClientPlaySound(sound'MenuSounds.Denied1');

            }

//-------------------------------------------------------------------------------------------------
//  Rear Door options:
function ChooseFireAt(Actor A)
{
	local Bot B;

	B = Bot(Controller);
	if ( B == None || B.Squad == None || B.Squad.SquadObjective == None
	     || (IsInState('UnDeployed') != B.LineOfSightTo(B.Squad.SquadObjective)) )
		Fire(0);
	else
		AltFire(0);
}

state Deployed
{
    function VehicleFire(bool bWasAltFire)
    {
    	if (bWasAltFire)
            GotoState('UnDeploying');

    	else
    		bWeaponIsFiring = True;
    }
}

auto state UnDeployed
{
    function VehicleFire(bool bWasAltFire)
    {
    	if (bWasAltFire)
            GotoState('Deploying');

        else
    		bWeaponIsFiring = True;
    }
}

 

state Deploying                                // for closing the rear door (status=closed)
{
Begin:
    if (Controller != None)
    {
    	bMovable = true;
    	bStationary = false;
    	if (PlayerController(Controller) != None)
    	{
	        PlayerController(Controller).ClientPlaySound(DeploySound);
        	if (PlayerController(Controller).bEnableGUIForceFeedback)
			PlayerController(Controller).ClientPlayForceFeedback(DeployForce);
	}
        PlayAnim('Bclose');
        sleep(2.50);
        bEnableProximityViewShake = False;
    	bDeployed = false;
        GotoState('Deployed');
    }
}

state UnDeploying                             // for opening the rear door (status=opened)
{
Begin:
    if (Controller != None)                   // if driver clicks to open backdoor
    {
    	if (PlayerController(Controller) != None)
    	{
	        PlayerController(Controller).ClientPlaySound(HideSound);
        	if (PlayerController(Controller).bEnableGUIForceFeedback)
			PlayerController(Controller).ClientPlayForceFeedback(HideForce);
	}
        PlayAnim('Aopen');
        sleep(3.00);
        bMovable = True;
    	bStationary = False;
    	bDeployed = False;
        GotoState('UnDeployed');
    }
    else                                               // else driver exits open backdoor
    {
        PlayAnim('Aopen');
        sleep(3.00);
        bMovable = True;
    	bStationary = False;
    	bDeployed = False;
        GotoState('UnDeployed');
    }
}
// && Weapons[1].bActive == False && Weapons[2].bActive == False && Weapons[3].bActive == False
/*
else  ((IsInState('Deployed')) && Weapons[ActiveWeapon].bActive == true)
            {
             GotoState('Deployed');
            }

else  ((IsInState('Deploying')) && Weapons[ActiveWeapon].bActive == true)
            {
             GotoState('Deployed');
            }*/
Function DriverLeft()
{
           Super.DriverLeft();

     if  ((IsInState('Undeployed')))
            {
             GotoState('UnDeployed');
            }

     else

        {
    	if ((IsInState('Deployed')) && Weapons[1].bActive == False && Weapons[2].bActive == False && Weapons[3].bActive == False)

           {
             GotoState('UnDeploying');
           }

        else

                if ((IsInState('Deployed')) && Weapons[1].bActive == False && Weapons[2].bActive == False && Weapons[3].bActive == False);

                GotoState('UnDeploying');
        }


}

//-------------------------------------------------------------------------------------------------
// some plane options
function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	if ( FRand() < 0.7 )
	{
		VehicleMovingTime = Level.TimeSeconds + 1;
		Rise = 1;
	}
	return (Rise != 0);
}
//-------------------------------------------------------------------------------------------------
// Item options
/*  This causes strange artifacts when the driver hits f4....its cool, but not a bigdeal.
 simulated function PostNetBeginPlay()
{

    a = spawn(class 'HelixShield', self) ;                                        //Pickupz
    AttachToBone(a, ShieldPickupBone) ;
    b = spawn(class 'HelixHealth', self) ;
    AttachToBone(b, HealthPickupBone) ;
    c = spawn(class 'xWeapons.LinkGunPickup', self) ;            //<- the green lines r the pickups bening spawned on the pickup bones
    AttachToBone(c, LinkGunPickupBone) ;
    d = spawn(class 'xWeapons.LinkAmmoPickup', self) ;
    AttachToBone(d, LinkAmmoBone1) ;
    e = spawn(class 'xWeapons.LinkAmmoPickup', self) ;
    AttachToBone(e, LinkAmmoBone2) ;
    f = spawn(class 'xWeapons.LinkAmmoPickup', self) ;
    AttachToBone(f, LinkAmmoBone3) ;
    g = spawn(class 'Onslaught.ONSAVRiLAmmoPickup', self) ;
    AttachToBone(g, FlakAmmoBone) ;
    h = spawn(class 'Onslaught.ONSAVRiLAmmoPickup', self) ;
    AttachToBone(h, RocketAmmoBone) ;

    Super.PostNetBeginPlay();


}

function UpdateRoll()                                          //Update Pickup Spins
{
    local rotator r;

    if (Level.NetMode == NM_DedicatedServer)
        return;
    aCurrentSpin += 800;
    aCurrentSpin = aCurrentSpin % 65536.f;
    r.Yaw = int(aCurrentSpin);
    SetBoneRotation(HealthPickupBone, r, 0, 1.f);

    bCurrentSpin += 900;
    bCurrentSpin = bCurrentSpin % 65536.f;
    r.Yaw = int(bCurrentSpin);
    SetBoneRotation(ShieldPickupBone, r, 0, 1.f);
}

*/


// --- Added to give driver an edo chute 02-28-21
// Requires APVerIV class

function KDriverEnter(Pawn p)
{

    super.KDriverEnter( P );

   Driver.CreateInventory("APVerIV.edo_ChuteInv");

}


//--------------------------------------------------------------------------------------------------

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
  bDriving = False;
	Super.Died(Killer, damageType, HitLocation);
}

// added this the bulk of it was in Died function, but ,..
simulated function Destroyed()
{
    local int i;

   	for(i=0;i<TrailEffects.Length;i++)
        	TrailEffects[i].Destroy();
        TrailEffects.Length = 0;

		for(i=0; i<StreamerEffect.Length; i++)
			StreamerEffect[i].Destroy();
		StreamerEffect.Length = 0;

// moved this if from above the Trail/Streamer effects.
    if(Level.NetMode != NM_DedicatedServer)
	{  //Remove Pickups
        a.destroy() ;        
        b.destroy() ;
        c.destroy() ;
        d.destroy() ;
        e.destroy() ;
        f.destroy() ;
        g.destroy() ;
        h.destroy() ;

        }
Super.Destroyed();

}



//-------------------------------------------------------------------------------------------------
// Plane options
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
//--------------------------------------------

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
                    TrailEffects[i].SetRelativeRotation( rot(-16384,32768,0) );
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
        }
    }
}
//-----------------------------------


simulated function Tick(float DeltaTime)
{
    local float EnginePitch, DesiredOpacity, DeltaOpacity, MaxOpacityChange, ThrustAmount;
	local TrailEmitter T;
	local int i;
	local vector RelVel;
	local bool NewStreamerActive, bIsBehindView;
	local PlayerController PC;
	local int 		Yaw;
	local actor		HitActor;
	local vector	HitLocation, HitNormal;
	local float GroundDist;

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

    Super.Tick(DeltaTime);
//---------------
//---------------
//---------------
//---------------
//---------------
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
}
//---------------
//---------------
//---------------
//---------------
//---------------
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





static function StaticPrecache(LevelInfo L)                     // important stuff for vehicle subsystems (don't alter unless you add/delete subsystems)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorWing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorTailWing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorGun');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');
	L.AddPrecacheStaticMesh(StaticMesh'Helix2.Dead.Deadhelix');

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

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'VMWeaponsTX.ManualBaseGun.baseGunEffectcopy');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

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

    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'VMWeaponsTX.ManualBaseGun.baseGunEffectcopy');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     MaxPitchSpeed=1700.000000
     TrailEffectPositions(0)=(X=-365.000000,Y=-54.000000,Z=190.000000)
     TrailEffectPositions(1)=(X=-365.000000,Y=54.000000,Z=190.000000)
     TrailEffectPositions(2)=(X=-43.367729,Y=-110.964638,Z=212.659424)
     TrailEffectPositions(3)=(X=-43.367729,Y=110.125702,Z=212.659424)
     TrailEffectClass=Class'Onslaught.ONSAttackCraftExhaust'
     StreamerEffectOffset(0)=(X=-350.000000,Y=-85.000000,Z=130.000000)
     StreamerEffectOffset(1)=(X=-350.000000,Y=85.000000,Z=130.000000)
     StreamerEffectOffset(2)=(X=-383.000000,Y=-87.000000,Z=285.000000)
     StreamerEffectOffset(3)=(X=-383.000000,Y=87.000000,Z=285.000000)
     StreamerEffectOffset(4)=(X=-327.000000,Y=-16.500000,Z=222.000000)
     StreamerEffectOffset(5)=(X=-327.000000,Y=16.500000,Z=222.000000)
     StreamerEffectClass=Class'Onslaught.ONSAttackCraftStreamer'
     StreamerOpacityRamp=(Min=1200.000000,Max=1600.000000)
     StreamerOpacityChangeRate=1.000000
     StreamerOpacityMax=0.700000
     DeploySound=Sound'IndoorAmbience.door3'
     HideSound=Sound'IndoorAmbience.door14'
     ServerPhysics=PHYS_Karma
     UprightStiffness=500.000000
     UprightDamping=200.000000
     MaxThrustForce=100.000000
     LongDamping=0.050000
     MaxStrafeForce=80.000000
     LatDamping=0.050000
     MaxRiseForce=75.000000
     UpDamping=0.100000
     TurnTorqueFactor=300.000000
     TurnTorqueMax=52.000000
     TurnDamping=100.000000
     MaxYawRate=1.500000
     PitchTorqueFactor=50.000000
     PitchTorqueMax=23.000000
     PitchDamping=500.000000
     RollTorqueTurnFactor=450.000000
     RollTorqueStrafeFactor=25.000000
     RollTorqueMax=32.000000
     RollDamping=50.000000
     StopThreshold=50.000000
     MaxRandForce=3.000000
     RandForceInterval=0.750000
     PassengerWeapons(0)=(WeaponPawnClass=Class'helixesvOmni.HelixMinigunPawn',WeaponBone="MinigunGunAttachment1")
     PassengerWeapons(1)=(WeaponPawnClass=Class'helixesvOmni.HelixMinigunsidePawn',WeaponBone="MinigunHardPoint2")
     PassengerWeapons(2)=(WeaponPawnClass=Class'helixesvOmni.HelixMinigunsidePawn',WeaponBone="MinigunHardPoint1")
     RedSkin=Texture'ESV2.Texture.Helix_0'
     BlueSkin=Texture'ESV2.Texture.Helix_1'
     IdleSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftIdle'
     StartUpSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftStartUp'
     ShutDownSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftShutDown'
     StartUpForce="AttackCraftStartUp"
     ShutDownForce="AttackCraftShutDown"
     DestroyedVehicleMesh=StaticMesh'Helix2.Dead.DeadHelix'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathAttackCraft'
     DestructionLinearMomentum=(Min=50000.000000,Max=150000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     DamagedEffectOffset=(X=-120.000000,Y=10.000000,Z=210.000000)
     ImpactDamageMult=0.001000
     HeadlightCoronaOffset(0)=(X=295.000000,Y=125.000000,Z=90.000000)
     HeadlightCoronaOffset(1)=(X=295.000000,Y=-125.000000,Z=90.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=70.000000
     VehicleMass=10.000000
     bDrawDriverInTP=True
     bTurnInPlace=True
     bShowDamageOverlay=True
     bDriverHoldsFlag=False
     bCanCarryFlag=False
     DrivePos=(X=294.500000,Y=-37.000000,Z=105.000000)
     ExitPositions(0)=(Z=195.000000)
     ExitPositions(1)=(X=-50.000000,Z=195.000000)
     EntryPosition=(X=135.000000)
     EntryRadius=210.000000
     TPCamDistance=950.000000
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=300.000000)
     MomentumMult=0.250000
     DriverDamageMult=0.000000
     VehiclePositionString="in a OmniHelix"
     VehicleNameString="OmniHelix 1.1"
     RanOverDamageType=Class'helixesvOmni.DamTypeHelixRoadkill'
     CrushedDamageType=Class'helixesvOmni.DamTypeHelixPancake'
     FlagBone="PlasmaGunAttachment"
     FlagOffset=(Z=175.000000)
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'helixesvOmni.GetSomeFullMetalJacket'
     HornSounds(1)=Sound'helixesvOmni.LetsRockVasquezALIENS'
     bCanBeBaseForPawns=True
     GroundSpeed=2000.000000
     HealthMax=1500.000000
     Health=1500
     bReplicateAnimations=True
     Mesh=SkeletalMesh'Helix2_final.ESV2'
     bHardAttach=True
     SoundVolume=160
     CollisionRadius=150.000000
     CollisionHeight=70.000000
     KParams=KarmaParamsRBFull'Onslaught.ONSAttackCraft.KParams0'

}
