//-----------------------------------------------------------
//	Skaarj Viper Speedboat
//	Colt Wohlers (aka CMan)
//	Beta 4.0 (July 2/2004)
//      Aditional Help: Mr-Slate (much coding help, and additions)
//-----------------------------------------------------------
class SkaarjViper extends ONSChopperCraft
    placeable;

//#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

var()   float	MaxPitchSpeed;

var(Boost) bool	bIsBoosting;
var(Boost) float BoostAmount;
var(Boost) float BoostTime;
var(Boost) sound BoosterSound;
var(Boost) float RechargeTime;
var(Boost) float WaterSearchDistance; //radius to look for water when checking for a boost
var(Boost) float BoostEffectFOVChange;

var()   array<vector>				TrailEffectPositions;
var     class<SkaarjViperExhaust>	TrailEffectClass;
var     array<SkaarjViperExhaust>	TrailEffects;

var()	array<vector>				StreamerEffectOffset;
var     class<SkaarjViperStreamer>	StreamerEffectClass;
var		array<SkaarjViperStreamer>	StreamerEffect;

var()		range		StreamerOpacityRamp;
var()		float		StreamerOpacityChangeRate;
var()		float		StreamerOpacityMax;
var			float		StreamerCurrentOpacity;
var			bool		StreamerActive;

var() bool bIsThrusting;

//Dodging Hacks
var bool		bWasLeft;
var bool		bWasRight;
var bool		bEdgeLeft;
var bool 		bEdgeRight;
var float DoubleClickTimer;
var float DoubleClickTime;
var float DodgeKarmaStrength;
var eDoubleClickDir DoubleClickDir;
var float LastDodgeTime;
var() float DelayBetweenDodges; //delay between dodges ;)

//Set this in default properties.. set closer to 0 sink faster ... 1 is neutral
var() float DeathBuoyancy;

//error correction stuff
var bool bSendingToDriving;
var float SendToDrivingTime;

replication
{
  reliable if(Role == Role_Authority) //server calls this on client
            SetBoostAndRechargeTime;
  reliable if(Role == Role_Authority) //for thrusting consider !bNetOwner as its possibly redundant?
           bIsBoosting, bIsThrusting;
  reliable if(Role < Role_Authority)   //fixes dodge nicely
           DodgeLeft,DodgeRight;
}

function Pawn CheckForHeadShot(Vector loc, Vector ray, float AdditionalScale)
{
    local vector X, Y, Z, newray;

    GetAxes(Rotation,X,Y,Z);

    if (Driver != None)
    {
        // Remove the Z component of the ray
        newray = ray;
        newray.Z = 0;
        if (abs(newray dot X) < 0.7 && Driver.IsHeadShot(loc, ray, AdditionalScale))
            return Driver;
    }

    return None;
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
    KarmaParams(KParams).KBuoyancy = DeathBuoyancy; //floating down to die.....
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
    KarmaParams(KParams).KBuoyancy = DeathBuoyancy; //floating down to die.....

    Super.Destroyed();
}

simulated event DrivingStatusChanged()
{
	local vector RotX, RotY, RotZ;
	local int i;

	Super.DrivingStatusChanged();

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{

        GetAxes(Rotation,RotX,RotY,RotZ);

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
    local float EnginePitch, DesiredOpacity, DeltaOpacity, MaxOpacityChange, FOVChange;
		local TrailEmitter T;
		local int i;
		local vector RelVel;
		local bool NewStreamerActive, bIsBehindView;
		local PlayerController PC;

        if((Role == Role_Authority || bNetOwner) && OutputThrust < 0.8 && bIsThrusting && !bIsBoosting)
            bIsThrusting = false;

        else if ((Role == Role_Authority || bNetOwner) && Controller != None && ((OutputThrust >= 0.8  && !bIsThrusting) || bIsBoosting))
            bIsThrusting = true;

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


        if(bIsThrusting)
        {
            TrailEffects.Length = TrailEffectPositions.Length;

        	for(i=0;i<TrailEffects.Length;i++)
        	{
            	if (TrailEffects[i] == None)
            	{
                	TrailEffects[i] = spawn(TrailEffectClass, self,, Location + (TrailEffectPositions[i] >> Rotation) );
                	TrailEffects[i].SetBase(self);
                    TrailEffects[i].SetRelativeRotation( rot(0,32768,0) );
                }
                else if(TrailEffects[i].bIsBoosting && !bIsBoosting)
                {
                     TrailEffects[i].SetThrustEnabled(True);
                     TrailEffects[i].SetThrust(0.0);
                }
                }
        }
        else if (!bIsBoosting && TrailEffects.Length > 0)
        {
            for(i=0;i<TrailEffects.Length;i++)
        	    TrailEffects[i].Destroy();
            TrailEffects.Length = 0;
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

        if(bIsBoosting)
        {

           if(TrailEffects.Length == 0)   //spawn them if they dont exist
               for(i=0;i<TrailEffectPositions.Length;i++)
               {
                  TrailEffects[i] = spawn(TrailEffectClass, self,, Location + (TrailEffectPositions[i] >> Rotation) );
                  TrailEffects[i].SetBase(self);
                  TrailEffects[i].SetRelativeRotation( rot(0,32768,0));
               }

              for(i=0; i<TrailEffects.Length; i++)
			   {
			    	TrailEffects[i].SetThrustEnabled(true);
				TrailEffects[i].SetThrust(1.0);
			   }



              if (PlayerController(Controller) != None && IsLocallyControlled())
              {
                 FOVChange = PlayerController(Controller).defaultFOV;
                 if(BoostTime / default.BoostTime <= 0.25)
                 FOVChange += (BoostTime / default.BoostTime)/0.25 * BoostEffectFovChange; //smooth change back
                 else if( BoostTime / default.BoostTime >= 0.75)
                 FOVChange += (1 - BoostTime / default.BoostTime)/ 0.25 * BoostEffectFovChange; //smooth fov change
                 else
                 FOVChange += BoostEffectFovChange;

	         PlayerController(Controller).SetFOV(FOVChange);
	      }
              if(BoostTime <= 0)
              {
              if(PlayerController(Controller) != None && IsLocallyControlled())
                   PlayerController(Controller).SetFOV(PlayerController(Controller).defaultFOV);
              }

        }




    }
     if(!bIsBoosting && RechargeTime < default.RechargeTime)       //these moved out to be performed on server
         {
              RechargeTime += DeltaTime;
         }
     else if(bIsBoosting)
              BoostTime -= DeltaTime;


     if(bIsBoosting && BoostTime <= 0 && Role == Role_Authority) //will be replicated
             bIsBoosting = false;  //all the server needs to know


    //fix for losing control of boat due to hitting Water
     if(PlayerController(Controller) != None && !(PlayerController(Controller).IsInState('PlayerDriving')) && (!bSendingToDriving || Level.TimeSeconds - SendToDrivingTime > 1.0))
     {
        PlayerController(Controller).GoToState('PlayerDriving');
        bSendingToDriving = true;
        SendToDrivingTime = Level.TimeSeconds;
     }
     else if(bSendingToDriving && PlayerController(Controller) != None && PlayerController(Controller).IsInState('PlayerDriving'))
        bSendingToDriving = false;
    //may want to check to see if this is still good online with multiple people ^
    Super.Tick(DeltaTime);
}

function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	local Bot B;
	local SquadAI Squad;
	local int Num;

	Squad = SquadAI(S);

	if (Squad.Size == 1)
	{
		if ( (Squad.Team != None) && (Squad.Team.Size == 1) && Level.Game.IsA('ASGameInfo') )
			return Super.BotDesireability(S, TeamIndex, Objective);
		return 0;
	}

	for (B = Squad.SquadMembers; B != None; B = B.NextSquadMember)
		if (Vehicle(B.Pawn) == None && (B.RouteGoal == self || B.Pawn == None || VSize(B.Pawn.Location - Location) < Squad.MaxVehicleDist(B.Pawn)))
			Num++;

	if ( Num < 2 )
		return 0;

	return Super.BotDesireability(S, TeamIndex, Objective);
}

function Vehicle FindEntryVehicle(Pawn P)
{
	local Bot B;
	local int i;

	B = Bot(P.Controller);
	if (B == None || WeaponPawns.length == 0 || !IsVehicleEmpty() || ((B.PlayerReplicationInfo.Team != None) && (B.PlayerReplicationInfo.Team.Size == 1) && Level.Game.IsA('ASGameInfo')) )
		return Super.FindEntryVehicle(P);

	for (i = WeaponPawns.length - 1; i >= 0; i--)
		if (WeaponPawns[i].Driver == None)
			return WeaponPawns[i];

	return Super.FindEntryVehicle(P);
}

simulated function SwitchWeapon(byte F)
{
    super.SwitchWeapon(F);
    //if(F == 10 && !bIsBoosting && BoostRechargeCounter>=BoostRechargeTime)
    if(F == 10 && !bIsBoosting)
    {
        Boost();
    }
}


function Boost()
{
    local bool WaterNearby;
    local WaterVolume WV;
    local vector HitLoc,HitNorm;

    WaterNearby = false;   //hack!!!



	 if(!PhysicsVolume.bWaterVolume)  //hack for gliding boat or UT rapidly switching volumes
	    {
               foreach TraceActors(class'WaterVolume',WV,HitLoc,HitNorm,Location - (vect(0,0,1)*WaterSearchDistance),Location)
               {
               if(WV != None)
                  WaterNearby = true;
               }
            }
            else
               WaterNearby = true;

            if (!bIsBoosting && (RechargeTime / default.RechargeTime >= 0.98) && WaterNearby)
            {
            bIsBoosting = true;
      	    RechargeTime = 0.0;
     	    SetBoostAndRechargeTime();  //set these on the client please
 	    BoostTime = default.BoostTime;
            }
  
}
function SetBoostAndRechargeTime() //executed on the client / instant action runs | should move to alt-fire
{
   PlaySound(BoosterSound, SLOT_None, 2*TransientSoundVolume);
   bIsBoosting = true;
   BoostTime = default.BoostTime;
   RechargeTime = 0.0;
}
simulated function KApplyForce(out vector Force, out vector Torque)
{
        local float ApplyThisForce;
        local float TimePercentage;

	if (bIsBoosting)
	{
	   TimePercentage = BoostTime / default.BoostTime;
           if(BoostTime / default.BoostTime <= 0.25)
           ApplyThisForce = (TimePercentage)/0.25 * BoostAmount; //smooth change back
           else if( BoostTime / default.BoostTime >= 0.75)
           ApplyThisForce = FClamp((1 - TimePercentage)/ 0.25 * BoostAmount,BoostAmount /3.0, BoostAmount); //nice initial boost
           else
           ApplyThisForce = BoostAmount;
           Force += (ApplyThisForce*vect(1, 0, 0)) >> Rotation;
        }


	Super.KApplyForce(Force, Torque);
}

simulated function float ChargeBar()
{
    // Clamp to 0.999 so charge bar doesn't blink when maxed
	if (bIsBoosting && BoostTime > 0)
        return (FMin(BoostTime / default.BoostTime, 0.999));
        else if(!bIsBoosting)
        {
         return (FMin(RechargeTime/default.RechargeTime, 0.999));
        }

}

//interesting dodge hack  Mr-Slate
simulated function RawInput(float DeltaTime,
							float aBaseX, float aBaseY, float aBaseZ, float aMouseX, float aMouseY,
							float aForward, float aTurn, float aStrafe, float aUp, float aLookUp)
{
        local eDoubleClickDir DodgeMove;

        if(!PhysicsVolume.bWaterVolume || (Level.TimeSeconds - LastDodgeTime) < DelayBetweenDodges)
                return;
	bEdgeLeft = (bWasLeft ^^ (aStrafe < 0));
	bEdgeRight = (bWasRight ^^ (aStrafe > 0));
        bWasLeft = (aStrafe < 0);
	bWasRight = (aStrafe > 0);
	DodgeMove = CheckForDoubleClickMove(DeltaTime);
	if(DodgeMove > DClick_None && DodgeMove < DClick_Active)
	{
	 if(DodgeMove == DClick_Left)
  	        DodgeLeft();
	 else if(DodgeMove == DClick_Right)
                DodgeRight();
        }
      Super.RawInput(DeltaTime,aBaseX,aBaseY,aBaseZ,aMouseX,aMouseY,aForward,aTurn,aStrafe,aUp,aLookUp);
}
//Checking what move im doing...
simulated function eDoubleClickDir CheckForDoubleClickMove(float DeltaTime)
{
	local eDoubleClickDir DoubleClickMove, OldDoubleClick;

        if ( DoubleClickDir == DCLICK_Active )
		DoubleClickMove = DCLICK_Active;
	else
		DoubleClickMove = DCLICK_None;

	if (DoubleClickTime > 0.0)
	{

		if ( DoubleClickDir != DCLICK_Done )
		{
			OldDoubleClick = DoubleClickDir;
			DoubleClickDir = DCLICK_None;

                       	if (bEdgeLeft && bWasLeft)
				DoubleClickDir = DCLICK_Left;
			else if (bEdgeRight && bWasRight)
				DoubleClickDir = DCLICK_Right;

			if ( DoubleClickDir == DCLICK_None)
				DoubleClickDir = OldDoubleClick;
			else if ( DoubleClickDir != OldDoubleClick )
				DoubleClickTimer = DoubleClickTime + 0.5 * DeltaTime;
			else
				DoubleClickMove = DoubleClickDir;
		}

		if (DoubleClickDir == DCLICK_Done)
		{
			DoubleClickTimer = FMin(DoubleClickTimer-DeltaTime,0);
			if (DoubleClickTimer < -0.35)
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;
			}
		}
		else if ((DoubleClickDir != DCLICK_None) && (DoubleClickDir != DCLICK_Active))
		{
			DoubleClickTimer -= DeltaTime;
			if (DoubleClickTimer < 0)
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;
			}
		}
	}
	return DoubleClickMove;
}
//Dodging Left by Mr-Slate
simulated function DodgeLeft()
{
    local vector X,Y,Z,Force;


    GetAxes(Rotation,X,Y,Z);
    Force = -DodgeKarmaStrength*Y + (Velocity Dot X)*X;
    KAddImpulse(Force,vect(0,0,0));
    LastDodgeTime = Level.TimeSeconds;
}
//Dodging Right by Mr-Slate
simulated function DodgeRight()
{
    local vector X,Y,Z,Force;

    GetAxes(Rotation,X,Y,Z);
    Force = DodgeKarmaStrength*Y + (Velocity Dot X)*X;
    KAddImpulse(Force,vect(0,0,0));
    LastDodgeTime = Level.TimeSeconds;
}

function KDriverEnter(Pawn P)
{
	p.ReceiveLocalizedMessage(class'CSBomber.CSBomberBoostMessage', 0);
	Super.KDriverEnter(P);
}


function DriverLeft()      //prevent that weird infinite bug
{
         bIsBoosting = false;
         bIsThrusting = false;
         bSendingToDriving = false;
         Super.DriverLeft();
}
static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlura');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
}

simulated function UpdatePrecacheStaticMeshes()
{
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
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlura');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     MaxPitchSpeed=2000.000000
     BoostAmount=1000.000000
     BoostTime=2.500000
     BoosterSound=Sound'GameSounds.Combo.ComboActivated'
     RechargeTime=5.000000
     WaterSearchDistance=250.000000
     BoostEffectFOVChange=20.000000
     TrailEffectPositions(0)=(X=-140.000000,Y=-141.149994,Z=23.100000)
     TrailEffectPositions(1)=(X=-140.000000,Y=141.149994,Z=23.100000)
     TrailEffectClass=Class'KopholusV2Omni.SkaarjViperExhaust'
     StreamerEffectOffset(0)=(X=-193.199997,Y=-40.900002,Z=103.800003)
     StreamerEffectOffset(1)=(X=-193.199997,Y=40.900002,Z=103.800003)
     StreamerEffectOffset(2)=(X=-190.800003,Y=-43.000000,Z=23.100000)
     StreamerEffectOffset(3)=(X=-190.800003,Y=43.000000,Z=23.100000)
     StreamerEffectClass=Class'KopholusV2Omni.SkaarjViperStreamer'
     StreamerOpacityRamp=(Min=1200.000000,Max=1600.000000)
     StreamerOpacityChangeRate=1.000000
     StreamerOpacityMax=0.700000
     DoubleClickTime=0.350000
     DodgeKarmaStrength=5000000.000000
     DelayBetweenDodges=0.500000
     DeathBuoyancy=0.500000
     UprightStiffness=400.000000
     UprightDamping=150.000000
     MaxThrustForce=250.000000
     LongDamping=0.050000
     MaxStrafeForce=100.000000
     LatDamping=0.050000
     UpDamping=0.500000
     TurnTorqueFactor=600.000000
     TurnTorqueMax=200.000000
     TurnDamping=50.000000
     MaxYawRate=1.500000
     PitchTorqueFactor=-200.000000
     PitchTorqueMax=10.000000
     PitchDamping=50.000000
     RollTorqueTurnFactor=50.000000
     RollTorqueStrafeFactor=20.000000
     RollTorqueMax=5.000000
     RollDamping=50.000000
     StopThreshold=100.000000
     MaxRandForce=3.000000
     RandForceInterval=0.750000
     DriverWeapons(0)=(WeaponClass=Class'CSBadgerFix.BadgerMinigun',WeaponBone="VFrontGun")
     PassengerWeapons(0)=(WeaponPawnClass=Class'KopholusV2Omni.SkaarjViperFrontGunPawn',WeaponBone="VFrontGun")
     PassengerWeapons(1)=(WeaponPawnClass=Class'KopholusV2Omni.SkaarjViperRearGunPawn',WeaponBone="VRearGun")
     IdleSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftIdle'
     StartUpSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftStartUp'
     ShutDownSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftShutDown'
     StartUpForce="AttackCraftStartUp"
     ShutDownForce="AttackCraftShutDown"
     DestroyedVehicleMesh=StaticMesh'KASPvehicleSM.SkaarjViperSM.SViper'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathAttackCraft'
     DestructionLinearMomentum=(Min=50000.000000,Max=150000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     DamagedEffectOffset=(X=-120.000000,Z=65.000000)
     ImpactDamageMult=0.000200
     HeadlightCoronaOffset(0)=(X=233.000000,Y=10.900000,Z=65.500000)
     HeadlightCoronaOffset(1)=(X=233.000000,Y=-10.900000,Z=65.500000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=60.000000
     VehicleMass=6.000000
     bDrawDriverInTP=True
     bTurnInPlace=True
     bShowDamageOverlay=True
     bDrawMeshInFP=True
     bShowChargingBar=True
     bDriverHoldsFlag=False
     bCanCarryFlag=False
     DrivePos=(X=45.000000,Y=18.000000,Z=110.000000)
     ExitPositions(0)=(X=50.000000,Z=100.000000)
     ExitPositions(1)=(X=-75.000000,Y=100.000000,Z=100.000000)
     ExitPositions(2)=(X=-75.000000,Y=-100.000000,Z=100.000000)
     ExitPositions(3)=(Z=125.000000)
     EntryRadius=250.000000
     FPCamPos=(X=115.000000,Z=100.000000)
     TPCamDistance=750.000000
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=120.000000)
     MomentumMult=0.300000
     DriverDamageMult=0.000000
     VehiclePositionString="in a Skaarj Viper"
     VehicleNameString="Skaarj Viper 2.0"
     RanOverDamageType=Class'KopholusV2Omni.DamTypeSkaarjViperRoadkill'
     CrushedDamageType=Class'KopholusV2Omni.DamTypeSkaarjViperPancake'
     FlagBone="VHull"
     FlagOffset=(Z=80.000000)
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn03'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn07'
     WaterDamage=0.000000
     bCanFly=False
     bCanBeBaseForPawns=True
     GroundSpeed=2000.000000
     HealthMax=300.000000
     Health=400
     Mesh=SkeletalMesh'KASPvehicles.SkaarjViper'
     SoundVolume=160
     CollisionRadius=150.000000
     CollisionHeight=70.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KBuoyancy=1.500000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=1.500000
         KMaxSpeed=3000.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=4.000000
         KImpactThreshold=300.000000
     End Object
     KParams=KarmaParamsRBFull'KopholusV2Omni.SkaarjViper.KParams0'

}
