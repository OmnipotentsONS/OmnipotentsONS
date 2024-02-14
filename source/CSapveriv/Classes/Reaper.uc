//-----------------------------------------------------------
// Reaper Stealth Attack Helicopter
// 2 Man Attack Helicopter
//-----------------------------------------------------------
class Reaper extends ONSChopperCraft
    placeable;

#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx
#exec OBJ LOAD FILE=..\Sounds\APVerIV_Snd.uax
var()   float							MaxPitchSpeed;

var Deco_PredatorBlades blades;
var()	array<vector>					ChopperDustOffset;
var()	float							ChopperDustTraceDistance;
var		array<FX_PredatorHoverDust>	ChopperDust;
var		array<vector>					ChopperDustLastNormal;
var FX_RunningLight LeftRunningLight,RightRunningLight,BottomRunningLight;
var vector LeftRunningLightOffset,RightRunningLightOffset,BottomRunningLightOffset;
var Deco_PredatorStillBlades BladesStill;
// Target locking
var	Vehicle		CurrentTarget;
var	float		MaxTargetingRange;
var	float		LastAutoTargetTime;
var	Vector		CrosshairPos;
var sound		TargetAcquiredSound;

var texture		WeaponInfoTexture, SpeedInfoTexture;
var float               mCurrentRoll;
var float               mRollInc;
var float               mRollUpdateTime;
var Info_ReaperStealthTimer stealthTimer;
var Proj_FighterChaff Decoy;
var() config int NumChaff;

var bool bGearsUp;

var bool bInvis,bOldInvis;
var Info_ReaperStealthTimer Info_ReaperStealthTimer;
var float StealthTime;
var Material InvisMaterial;
var Material RealSkins[4];
var float CloakTime, LastCloakTime;
var float ConfigCloakTime;
var bool bInvisON,bStealth;

var()	vector					GrappleOffset;
var()	float					GrappleTraceDistance;

var xpawn NewAttachPawn,OldAttachPawn;
var bool bGrapple,bAttached;
//new
var()	float	InheritVelocityScale; // Amount of vehicles velocity
var()	float	MinProjectiles, MaxProjectiles;

var bool bEnhancedHud;
var float EnhancedHudRange;

var actor HitActor,HitActorB;
var vector TraceStartB, TraceEndB, HitLocationB, HitNormalB;
var RopeBeamEffect RopeEffect;
var int reaperState, oldState;
const STATE_CANNON = 0;
const STATE_MISSILE = 1;
const STATE_HELLFIRE = 2;
const STATE_CLOAK = 3;

replication
{
    reliable if( bNetDirty && (Role== ROLE_Authority) && bNetOwner )
		CloakTime;
    reliable if( Role==ROLE_Authority )
        NumChaff,bInvis, reaperState, bEnhancedHud, EnhancedHudRange, ConfigCloakTime;
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    LastCloakTime=CloakTime;
}
// do any general vehicle set-up when it gets spawned.
simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    if(Role == ROLE_Authority)
      {
       if (BladesStill==none)
          {
           BladesStill=spawn(Class'Deco_PredatorStillBlades',Self,,Location);
           if( !AttachToBone(BladesStill,'Blades1') )
             {
			   BladesStill.Destroy();
			   return;
		     }
           }
       }
}
function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	if ( FRand() < 0.7 )
	{
		VehicleMovingTime = Level.TimeSeconds + 1;
		Rise = 1;
	}
	return (Rise != 0);
}

function KDriverEnter(Pawn p)
{

    super.KDriverEnter( P );

   Driver.CreateInventory("CSAPVerIV.edo_ChuteInv");
   if(bGearsUp==False)
     GotoState('CannonMode');
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{

    if (blades!=none)
	    blades.Destroy();

    if(LeftRunningLight!=none)
       LeftRunningLight.Destroy();
    if(RightRunningLight!=none)
       RightRunningLight.Destroy();
    if(BottomRunningLight!=none)
       BottomRunningLight.Destroy();
    if (BladesStill!=none)
        BladesStill.Destroy();
    Super.Died(Killer, damageType, HitLocation);
}

simulated function Destroyed()
{
    local int i;


	if (Level.NetMode != NM_DedicatedServer)
	{
		for (i = 0; i < ChopperDust.Length; i++)
			ChopperDust[i].Destroy();

		ChopperDust.Length = 0;
	}
	if (blades!=none)
	    blades.Destroy();
    if(LeftRunningLight!=none)
       LeftRunningLight.Destroy();
    if(RightRunningLight!=none)
       RightRunningLight.Destroy();
    if(BottomRunningLight!=none)
       BottomRunningLight.Destroy();
     if (BladesStill!=none)
         BladesStill.Destroy();

     if(NewAttachPawn!=none)
           DetachPlayerPawn();
     if(RopeEffect!=none)
        RopeEffect.Destroy();

   Super.Destroyed();
}

simulated function DestroyAppearance()
{
	local int i;

	if (Level.NetMode != NM_DedicatedServer)
	{
		for (i = 0; i < ChopperDust.Length; i++)
			ChopperDust[i].Destroy();

		ChopperDust.Length = 0;
	}

	Super.DestroyAppearance();
}

simulated event DrivingStatusChanged()
{
	local vector RotX, RotY, RotZ;
	local int i;

	Super.DrivingStatusChanged();


    if (bDriving && Level.NetMode != NM_DedicatedServer && ChopperDust.Length == 0 && !bDropDetail)
	{
		ChopperDust.Length = ChopperDustOffset.Length;
		ChopperDustLastNormal.Length = ChopperDustOffset.Length;

		for(i=0; i<ChopperDustOffset.Length; i++)
    		if (ChopperDust[i] == None)
    		{
    			ChopperDust[i] = spawn( class'FX_PredatorHoverDust', self,, Location + (ChopperDustOffset[i] >> Rotation) );
    			ChopperDust[i].SetDustColor( Level.DustColor );
    			ChopperDustLastNormal[i] = vect(0,0,1);
    		}
	}
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
    	{
    		for(i=0; i<ChopperDust.Length; i++)
                ChopperDust[i].Destroy();

            ChopperDust.Length = 0;
        }
    }

}
simulated event TeamChanged()
{
    Super.TeamChanged();
	// Add Trail FX
	if ( Level.NetMode != NM_DedicatedServer )
	{
		SetRunningLightsFX();
	}

}
simulated function SetRunningLightsFX()
{
 if (LeftRunningLight==none && Health>0 && Team != 255 )
          {
           LeftRunningLight = Spawn(class'FX_RunningLight',self,,Location);
           if( !AttachToBone(LeftRunningLight,'LWLight') )
		     {
			  LeftRunningLight.Destroy();
			  return;
		     }

          RightRunningLight = Spawn(class'FX_RunningLight',self,,Location);
          if( !AttachToBone(RightRunningLight,'RWLight') )
		    {
			 RightRunningLight.Destroy();
			 return;
		    }
		  BottomRunningLight = Spawn(class'FX_RunningLight',self,,Location);
		  if( !AttachToBone(BottomRunningLight,'BLight') )
		    {
			 BottomRunningLight.Destroy();
			 return;
		    }
		    LeftRunningLight.SetRelativeLocation(LeftRunningLightOffset);
	        RightRunningLight.SetRelativeLocation(RightRunningLightOffset);
		    BottomRunningLight.SetRelativeLocation(BottomRunningLightOffset);
        }

       if (LeftRunningLight!=none)
          {
           if ( Team == 1 || (Controller!=none && controller.PlayerReplicationInfo.Team.TeamIndex==1) )	// Blue version
			   {
				LeftRunningLight.SetBlueColor();
                RightRunningLight.SetBlueColor();
                BottomRunningLight.SetBlueColor();
               }
          }
}


simulated function UpdateRoll(float dt)
{
    local rotator r;
     mRollInc = 65536.f*2.f;
    if (mRollInc <= 0.f)
        return;

    mCurrentRoll += dt*mRollInc;
    mCurrentRoll = mCurrentRoll % 65536.f;
    r.Yaw = int(mCurrentRoll);

    SetBoneRotation('Blades1', r, 0, 1.f);
}

simulated function Tick(float DeltaTime)
{
    local float EnginePitch,ThrustAmount,HitDist;
	local int i;
	local vector RelVel,TraceStart, TraceEnd, HitLocation, HitNormal;

	local bool bIsBehindView;
	local PlayerController PC;
     local vector PlayerV;

     if (blades==none)
         {
          blades=spawn(Class'CSAPVerIV.Deco_PredatorBlades',Self,,Location);
          if( !AttachToBone(blades,'Blades1') )
            {
			blades.Destroy();
			return;
		   }
         }
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


    }

   if(Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
		for(i=0; i<ChopperDust.Length; i++)
		{
			ChopperDust[i].bDustActive = false;

			TraceStart = Location + (ChopperDustOffset[i] >> Rotation);
			TraceEnd = TraceStart - ( ChopperDustTraceDistance * vect(0,0,1) );

			HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, True);

			if(HitActor == None)
			{
				ChopperDust[i].UpdateHoverDust(false, 0);
			}
			else
			{
				HitDist = VSize(HitLocation - TraceStart);

				ChopperDust[i].SetLocation( HitLocation + 10*HitNormal);

				ChopperDustLastNormal[i] = Normal( 3*ChopperDustLastNormal[i] + HitNormal );
				ChopperDust[i].SetRotation( Rotator(ChopperDustLastNormal[i]) );

				ChopperDust[i].UpdateHoverDust(true, HitDist/ChopperDustTraceDistance);

				// If dust is just turning on, set OldLocation to current Location to avoid spawn interpolation.
				if(!ChopperDust[i].bDustActive)
					ChopperDust[i].OldLocation = ChopperDust[i].Location;

				ChopperDust[i].bDustActive = true;
			}
		}
	}
      if(bGrapple==true)
        {
          TraceStartB = Location + (GrappleOffset >> Rotation);
		  TraceEndB = TraceStart - ( GrappleTraceDistance * vect(0,0,1) );

			HitActorB = Trace(HitLocationB, HitNormalB, TraceEndB, TraceStartB, True);
            if(RopeEffect!=none)
              {
                RopeEffect.SetLocation(TraceStartB);
                if(NewAttachPawn==none)
                  {
                   RopeEffect.bBendy=true;
                   RopeEffect.EndEffect=TraceEndB;
                  }
                else
                  {
                   RopeEffect.EndEffect=NewAttachPawn.location;
                   RopeEffect.bBendy=false;
                  }
              }
			if(bAttached==False)
            {
            if(HitActorB != none && HitActorB.IsA('XPawn')&& NewAttachPawn==none)
               {
                NewAttachPawn=XPawn(HitActorB);
                AttachPlayerPawn();
               }
            }
        }
        if(NewAttachPawn!=none)
          {
             PlayerV = TraceEndB +(Vect(0,0,25) >> Rotation);
             NewAttachPawn.SetLocation(PlayerV);
          }

       if( NewAttachPawn!=none && (NewAttachPawn.IsInState('Dying') || NewAttachPawn.bDeleteMe==true))
	       DetachPlayerPawn();
	   if( NewAttachPawn!=none && NewAttachPawn.controller.bDuck > 0)
           DetachPlayerPawn();

    //---Running Lights-----------------------------------

    if (bDriving==true)
       {
           UpdateRoll(DeltaTime);
           if (BladesStill!=none)
               BladesStill.Destroy();
       }

    Super.Tick(DeltaTime);
    if ( !IsVehicleEmpty() )
		Enable('tick');
}


simulated event  AttachPlayerPawn()
{
  NewAttachPawn.bCanFly=true;
  NewAttachPawn.SetPhysics(PHYS_flying);
  bAttached=true;
  if (PlayerController(Controller) != None)
	  PlayerController(Controller).ReceiveLocalizedMessage(class'MSG_PredatorMessages', 6);

}

simulated event  DetachPlayerPawn()
{
  if( NewAttachPawn!=none)
    {
     NewAttachPawn.SetPhysics(Phys_Falling);
     NewAttachPawn.setBase(none);
     NewAttachPawn.bCanFly=false;
     OldAttachPawn=NewAttachPawn;
    }
  NewAttachPawn=none;
  bAttached=false;
  if (PlayerController(Controller) != None)
	  PlayerController(Controller).ReceiveLocalizedMessage(class'MSG_PredatorMessages', 5);

}
event bool KDriverLeave( bool bForceLeave )
{
	if(NewAttachPawn!=none)
       DetachPlayerPawn();

    if(RopeEffect!=none)
       RopeEffect.Destroy();

    LastCloakTime=CloakTime;
    SetInvisibility(0.0);

    return super.KDriverLeave(bForceLeave);
 	//bDriving = true;
	//enable('Tick');

	//return b;
}
exec function SwitchToLastWeapon()
{

     if(bGrapple==false)
       {
        bGrapple=true;

            //P = spawn(class'ReaperGrappleProjectile', self,,Location);
            // AttachToBone(P,'Main');
          RopeEffect=spawn(class'RopeBeamEffect', self,,Location);
          if (PlayerController(Controller) != None)
	          PlayerController(Controller).ReceiveLocalizedMessage(class'MSG_PredatorMessages', 7);
        return;
        }
      else
        {
         bGrapple=false;
         if(NewAttachPawn!=none)
           DetachPlayerPawn();

          if(RopeEffect!=none)
             RopeEffect.Destroy();

        }
}
simulated event GearStatusChanged()
{
  	if (blades!=none)
	    blades.Destroy();
     if(bGearsUp==true)
       {
        PlaySound(Sound'IndoorAmbience.door2',SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
        PlayAnim('GearsOpen');
        bGearsUp=false;
       }
     if (BladesStill==none)
          {
           BladesStill=spawn(Class'Deco_PredatorStillBlades',Self,,Location);
           if( !AttachToBone(BladesStill,'Blades1') )
             {
			   BladesStill.Destroy();
			   return;
		     }
           }
}
simulated function ClientKDriverLeave(PlayerController PC)
{
    GearStatusChanged();
    Super.ClientKDriverLeave(PC);
}
function float ImpactDamageModifier()
{
    local float Multiplier;
    local vector X, Y, Z;

    GetAxes(Rotation, X, Y, Z);
    if (ImpactInfo.ImpactNorm Dot Z > 0)
        Multiplier = 1-(ImpactInfo.ImpactNorm dot Z);
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



static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.Predator_ST.PredatorDestroyed');
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
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'APVerIV_ST.Predator_ST.PredatorDestroyed');
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
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
	Super.UpdatePrecacheMaterials();
}

simulated function DrawHUD(Canvas Canvas)
{
   local PlayerController	PC;
   super.DrawHUD(Canvas);
	// Don't draw if player is dead...
	if ( Health < 1 || Controller == None || PlayerController(Controller) == None )
		return;

	PC = PlayerController(Controller);
    if(bEnhancedHud)
        DrawVehicleHUD( Canvas, PC );
}

simulated function DrawVehicleHUD( Canvas C, PlayerController PC )
{
    local vehicle	V;
    local XPawn	P;
	local vector	ScreenPos;
	local string	VehicleInfoString;
	local string	FriendInfoString;
    C.Style		= ERenderStyle.STY_Alpha;

		// Draw Weird cam
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.DrawColor.A = 64;
		C.SetPos(0,0);
		C.DrawColor	= class'HUD_Assault'.static.GetTeamColor( Team );

        // Draw Reticle around visible vehicles
		foreach DynamicActors(class'Vehicle', V )
		{
			if ((V==Self) || (V.Health < 1) || V.bDeleteMe || V.GetTeamNum() == Team || V.bDriving==false || !V.IndependentVehicle())
                 continue;
            if ((V.IsA('Reaper')) && (Reaper(V).bStealth==True))
                 continue;

			if ( !class'HUD_Assault'.static.IsTargetInFrontOfPlayer( C, V, ScreenPos, Location, Rotation ) )
				continue;

			if ( !FastTrace( V.Location, Location ) )
				continue;

            if(VSize(Location-V.Location) > EnhancedHudRange)
                continue;

            C.SetDrawColor(255, 0, 0, 192);

			C.Font = class'HudBase'.static.GetConsoleFont( C );
			VehicleInfoString = V.VehicleNameString $ ":" @ int(VSize(Location-V.Location)*0.01875.f) $ class'HUD_Assault'.default.MetersString;
			class'HUD_Assault'.static.Draw_2DCollisionBox( C, V, ScreenPos, VehicleInfoString, 1.5f, true );
		}

	   // Draw Reticle around visible friends
		foreach DynamicActors(class'XPawn', P )
		{
			if ((P==Self) || (P.Health < 1) || P.bDeleteMe || P.GetTeamNum() != Team || P.bCanTeleport==false)
                 continue;

			if ( !class'HUD_Assault'.static.IsTargetInFrontOfPlayer( C, P, ScreenPos, Location, Rotation ) )
				continue;

			if ( !FastTrace( P.Location, Location ) )
				continue;
            C.SetDrawColor(0, 255, 100, 192);

			C.Font = class'HudBase'.static.GetConsoleFont( C );
			FriendInfoString = "Friend" @ int(VSize(Location-P.Location)*0.01875.f) $ class'HUD_Assault'.default.MetersString;
			class'HUD_Assault'.static.Draw_2DCollisionBox( C, P, ScreenPos, FriendInfoString, 1.5f, true );
		}
}

exec function NextItem()
{
	ServerPlayHorn(0);
}

function Vehicle FindEntryVehicle(Pawn P)
{
	local Bot B, S;

	B = Bot(P.Controller);
	if ( (B == None) || !IsVehicleEmpty() || (WeaponPawns[0].Driver != None) )
		return Super.FindEntryVehicle(P);

	for ( S=B.Squad.SquadMembers; S!=None; S=S.NextSquadMember )
	{
		if ( (S != B) && (S.RouteGoal == self) && S.InLatentExecution(S.LATENT_MOVETOWARD)
			&& ((S.MoveTarget == self) || (Pawn(S.MoveTarget) == None)) )
			return WeaponPawns[0];
	}
	return Super.FindEntryVehicle(P);
}




//Notify vehicle that an enemy has locked on to it
event NotifyEnemyLockedOn()
{
    if(controller.IsA('Bot'))
      SwitchToLastWeapon();

	bEnemyLockedOn = true;
}

function ChooseFireAt(Actor A)
{
	local bot B;

	B = Bot(Controller);

	if ( (Vehicle(B.Enemy) != None)
	     && (B.Enemy.bCanFly || B.Enemy.IsA('ONSHoverCraft')) && (FRand() < 0.3 + 0.1 * B.Skill) )
		GotoState('WeaponMissilesmode');
    else
      {
       if ( FRand() < 0.65 )
           GotoState('WeaponRocketmode');
       else
           GotoState('WeaponPlasmaCannonMode');
       }

    if (!bHasAltFire)
		Fire(0);
	else if (ActiveWeapon < Weapons.length)
	{
		if (Weapons[ActiveWeapon].BestMode() == 0)
			Fire(0);
		else
			AltFire(0);
	}
}

simulated state CannonMode
{
  function VehicleFire(bool bWasAltFire)
   {
    	if (bWasAltFire)
    	{
            GotoState('Missilemode');
        }
    	else
        {
            LastCloakTime=CloakTime;
            SetInvisibility(0.0);
    		bWeaponIsFiring = True;
        }
   }
   Begin:
     reaperState=STATE_CANNON;
     if(bGearsUp==False)
       {
        PlaySound(Sound'IndoorAmbience.door2',SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
        PlayAnim('GearsClose');
        bGearsUp=true;
        sleep(3.0);
       }
       PlaySound(Sound'IndoorAmbience.door5',SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
       PlayAnim('CannonOpen');
       if (PlayerController(Controller) != None)
	   PlayerController(Controller).ReceiveLocalizedMessage(class'MSG_PredatorMessages', 1);
       SetActiveWeapon(0);

       Weapons[0].PlayAnim('CannonOpen');
}

simulated state Missilemode
{
    function VehicleFire(bool bWasAltFire)
    {
        if (bWasAltFire)
        {
            GotoState('Rocketmode');
        }
    	else
        {
            LastCloakTime=CloakTime;
            SetInvisibility(0.0);
    		bWeaponIsFiring = True;
        }
    }
Begin:
       reaperState=STATE_MISSILE;
       Weapons[0].PlayAnim('CannonClose');
       PlaySound(Sound'IndoorAmbience.door5',SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
       PlayAnim('CannonClose');
       sleep(2.0);
       PlaySound(Sound'IndoorAmbience.door4',SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
       PlayAnim('MissileOpen');
       if (PlayerController(Controller) != None)
	   PlayerController(Controller).ReceiveLocalizedMessage(class'MSG_PredatorMessages', 3);
       SetActiveWeapon(1);
}

simulated state Rocketmode
{
    function VehicleFire(bool bWasAltFire)
    {
        if (bWasAltFire)
        {
            CloakTime=LastCloakTime;
            bOldInvis=false;
            GotoState('ReaperStealthmode');
        }
    	else
        {
            LastCloakTime=CloakTime;
            SetInvisibility(0.0);
    		bWeaponIsFiring = True;
        }
    }
Begin:
       reaperState=STATE_HELLFIRE;
       PlaySound(Sound'IndoorAmbience.door4',SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
       PlayAnim('MissileClose');
       sleep(2.0);
       PlaySound(Sound'IndoorAmbience.door10',SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
       PlayAnim('RocketOpen');
       if (PlayerController(Controller) != None)
	   PlayerController(Controller).ReceiveLocalizedMessage(class'MSG_PredatorMessages', 4);
       SetActiveWeapon(2);
}

simulated state ReaperStealthmode
{
    function VehicleFire(bool bWasAltFire)
    {
        if (bWasAltFire)
        {
            GotoState('CannonMode');
        }
        else
        {
            //CloakTime=LastCloakTime;
            if(stealthTimer != None)
                SetInvisibility(CloakTime);
            bWeaponIsFiring = True;
        }
    }
Begin:
       reaperState=STATE_CLOAK;
       PlaySound(Sound'IndoorAmbience.door10',SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
       PlayAnim('RocketClose');
       sleep(2.0);
       if (PlayerController(Controller) != None)
	   PlayerController(Controller).ReceiveLocalizedMessage(class'MSG_PredatorMessages', 2);
       SetActiveWeapon(3);
       //if(LastCloakTime!=CloakTime)
       // StealthMode();
}

//=========================================
// new StealthStuff
simulated function SetInvisibility(float time)
{
    local int i,NumSkins;
    bInvis = (time > 0.0);

    //Visibility is for AI control
    //bInvisON is used by HUD code 
    if (Role == ROLE_Authority)
    {
        if (bInvis)
		{
			Visibility = 0;
			bInvisON=True;
        }
        else
        {
 		 Visibility = Default.Visibility;
         bInvisON=false;
        }
    }

    if(bOldInvis != bInvis)
    {
        //if(bInvis && !bOldInvis) // Going invisible
        if(bInvis)
        {
            bStealth=true;
            bShowChargingBar=true;
            // Save the 'real' non-invis skin
            NumSkins = Clamp(Skins.Length,2,4);

            for ( i=0; i<NumSkins; i++ )
            {
                RealSkins[i] = Skins[i];
                Skins[i] = InvisMaterial;
            }

            if(Weapons.length > 0)
                Weapon_ReaperCannon(Weapons[0]).SetInvisable();

            if (blades!=none)
                blades.bHidden=true;

            //--RunningLights----------------------------
            RightRunningLight.SetInvisable();
            LeftRunningLight.SetInvisable();
            BottomRunningLight.SetInvisable();
        }
        //else if(!bInvis && bOldInvis) // Going visible
        else
        {
            if(Weapons.length > 0)
                Weapon_ReaperCannon(Weapons[0]).SetVisable();

            if (blades!=none)
                blades.bHidden=false;

            //Make Running Lights Visable Again
            if ( RightRunningLight != none )
                RightRunningLight.SetVisable();

            if ( LeftRunningLight != none )
                LeftRunningLight.SetVisable();

            if ( BottomRunningLight != none )
                BottomRunningLight.SetVisable();

            NumSkins = Clamp(Skins.Length,2,4);

            for ( i=0; i<NumSkins; i++ )
                    Skins[i] = RealSkins[i];
            
            bStealth=false;
            bShowChargingBar=false;
            //bOldInvis = bInvis;
            bOldInvis = bInvis;
        }

        bOldInvis = bInvis;
    }
}

function StealthMode()
{
    if(stealthTimer == None)
    {
        CloakTime=100;
        stealthTimer = spawn(class'CSAPVerIV.Info_ReaperStealthTimer',self);
    }
}


simulated function float ChargeBar()
{
    return 1.0 - ((100-CloakTime)/100);
}

simulated event PostNetReceive()
{
    local int i,NumSkins;
    if(bInvis != bOldInvis)
    {
        if(bInvis)
        {
            // Save the 'real' non-invis skin
            NumSkins = Clamp(Skins.Length,2,4);

            for ( i=0; i<NumSkins; i++ )
            {
                RealSkins[i] = Skins[i];
                Skins[i] = InvisMaterial;
            }

            Weapon_ReaperCannon(Weapons[0]).SetInvisable();

            if (blades!=none)
                blades.bHidden=true;

            //--RunningLights----------------------------
            RightRunningLight.SetInvisable();
            LeftRunningLight.SetInvisable();
            BottomRunningLight.SetInvisable();
            bShowChargingBar=true;

        }
        else
        {
            if (blades!=none)
                blades.bHidden=false;

            //Make Running Lights Visable Again
            if ( RightRunningLight != none )
                RightRunningLight.SetVisable();

            if ( LeftRunningLight != none )
                LeftRunningLight.SetVisable();

            if ( BottomRunningLight != none )
                BottomRunningLight.SetVisable();

            NumSkins = Clamp(Skins.Length,2,4);

            for ( i=0; i<NumSkins; i++ )
                    Skins[i] = RealSkins[i];
            
            bShowChargingBar=false;
        }

        bOldInvis = bInvis;
    }

    if(reaperState != oldState)
    {
        switch(reaperState)
        {
            case STATE_CANNON:
                GotoState('CannonMode');
                break;
            case STATE_MISSILE:
                GotoState('Missilemode');
                break;
            case STATE_HELLFIRE:
                GotoState('Rocketmode');
                break;
            case STATE_CLOAK:
                GotoState('ReaperStealthmode');
                break;
        }

        oldState = reaperState;
    }
}

defaultproperties
{
    ConfigCloakTime=90
    bEnhancedHud=false
    EnhancedHudRange=10000
     bNetNotify=true
     MaxPitchSpeed=2000.000000
     ChopperDustOffset(0)=(X=25.000000,Z=10.000000)
     ChopperDustTraceDistance=600.000000
     LeftRunningLightOffset=(Y=-0.500000)
     RightRunningLightOffset=(Y=0.500000)
     BottomRunningLightOffset=(Z=-0.500000)
     NumChaff=3
     InvisMaterial=FinalBlend'APVerIV_Tex.AP_FX.WraithInvisFB'
     CloakTime=100.000000
     GrappleOffset=(Z=20.000000)
     GrappleTraceDistance=1200.000000
     UprightStiffness=500.000000
     UprightDamping=300.000000
     MaxThrustForce=180.000000
     LongDamping=0.050000
     MaxStrafeForce=120.000000
     LatDamping=0.050000
     MaxRiseForce=75.000000
     UpDamping=0.050000
     TurnTorqueFactor=650.000000
     TurnTorqueMax=250.000000
     TurnDamping=50.000000
     MaxYawRate=2.500000
     PitchTorqueFactor=200.000000
     PitchTorqueMax=35.000000
     PitchDamping=20.000000
     RollTorqueTurnFactor=550.000000
     RollTorqueStrafeFactor=90.000000
     RollTorqueMax=90.000000
     RollDamping=40.000000
     StopThreshold=100.000000
     MaxRandForce=3.000000
     RandForceInterval=0.750000
     DriverWeapons(0)=(WeaponClass=Class'CSAPVerIV.Weapon_ReaperCannon',WeaponBone="CannonAttach")
     DriverWeapons(1)=(WeaponClass=Class'CSAPVerIV.Weapon_ReaperMissileWeapon',WeaponBone="Main")
     DriverWeapons(2)=(WeaponClass=Class'CSAPVerIV.Weapon_ReaperHellFireRockets',WeaponBone="Main")
     DriverWeapons(3)=(WeaponClass=Class'CSAPVerIV.Weapon_ReaperStealthActivation',WeaponBone="Main")
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_PredatorPassenger',WeaponBone="PassAttach")
     bHasAltFire=False
     IdleSound=Sound'APVerIV_Snd.ReaperEngine'
     StartUpSound=Sound'CicadaSnds.Flight.CicadaStartUp'
     ShutDownSound=Sound'CicadaSnds.Flight.CicadaShutdown'
     StartUpForce="AttackCraftStartUp"
     ShutDownForce="AttackCraftShutDown"
     DestroyedVehicleMesh=StaticMesh'APVerIV_ST.Reaper_ST.ReaperDestroyed'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathAttackCraft'
     DestructionLinearMomentum=(Min=50000.000000,Max=150000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     DamagedEffectOffset=(X=-120.000000,Y=10.000000,Z=65.000000)
     ImpactDamageMult=0.001000
     HeadlightCoronaOffset(0)=(X=182.000000,Z=-5.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=60.000000
     VehicleMass=4.000000
     bTurnInPlace=True
     bShowDamageOverlay=True
     ExitPositions(0)=(Y=-324.000000,Z=100.000000)
     ExitPositions(1)=(Y=324.000000,Z=100.000000)
     EntryPosition=(X=-40.000000)
     EntryRadius=210.000000
     TPCamDistance=500.000000
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=200.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Reaper"
     VehicleNameString="Reaper 1.9"
     RanOverDamageType=Class'Onslaught.DamTypeAttackCraftRoadkill'
     CrushedDamageType=Class'Onslaught.DamTypeAttackCraftPancake'
     FlagBone="Main"
     FlagOffset=(Z=80.000000)
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn03'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn07'
     bCanBeBaseForPawns=True
     GroundSpeed=2000.000000
     HealthMax=300.000000
     Health=300
     Mesh=SkeletalMesh'CSAPVerIV_Anim.ReaperMesh'
     Skins(0)=Shader'APVerIV_Tex.ExcaliburSkins.GlassShader'
     Skins(1)=Texture'ONSBPTextures.fX.Missile'
     Skins(2)=Texture'APVerIV_Tex.PhantomSkins.PhantomSkinA'
     Skins(3)=Texture'APVerIV_Tex.PhantomSkins.PhantomSkinB'
     SoundVolume=240
     CollisionRadius=150.000000
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
     KParams=KarmaParamsRBFull'CSAPVerIV.Reaper.KParams0'

}
