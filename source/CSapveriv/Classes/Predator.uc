//-----------------------------------------------------------
// PredatorAttackHelicopter
// 2 Man Attack Helicopter
//-----------------------------------------------------------
class Predator extends ONSChopperCraft
    placeable;

#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx
#exec OBJ LOAD FILE=..\Sounds\APVerIV_Snd.uax
var()   float							MaxPitchSpeed;

var()   array<vector>					TrailEffectPositions;
var     class<ONSAttackCraftExhaust>	TrailEffectClass;
var     array<ONSAttackCraftExhaust>	TrailEffects;
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
var Sound		TargetAcquiredSound;

var texture		WeaponInfoTexture, SpeedInfoTexture;
var Deco_PredatorGears LandingGears;
var vector LandingGearOffset;
var float               mCurrentRoll;
var float               mRollInc;
var float               mRollUpdateTime;
var Proj_FighterChaff Decoy;
var() config int NumChaff;
var bool bEnhancedHud;
var float EnhancedHudRange;

replication
{
    reliable if( Role==ROLE_Authority )
        NumChaff, bEnhancedHud,EnhancedHudRange;
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
           if( !AttachToBone(BladesStill,'BladeAttachment') )
             {
			  log( "Couldn't attach BladesStill to BladeAttachment", 'Error' );
			   BladesStill.Destroy();
			   return;
		     }
           }
       if (LandingGears==none)
          {
           LandingGears=spawn(Class'Deco_PredatorGears',Self,,Location);
           if( !AttachToBone(LandingGears,'PredatorWeapons') )
             {
			  log( "Couldn't attach LandingGears to PredatorWeapons", 'Error' );
			   LandingGears.Destroy();
			   return;
		     }
		     LandingGears.SetRelativeLocation(LandingGearOffset);
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

}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local int i;

    if(Level.NetMode != NM_DedicatedServer)
	{
    	for(i=0;i<TrailEffects.Length;i++)
        	TrailEffects[i].Destroy();
        TrailEffects.Length = 0;

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
    if (LandingGears!=none)
        LandingGears.Destroy();
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
    }

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
     if (LandingGears!=none)
        LandingGears.Destroy();
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
           if( !AttachToBone(LeftRunningLight,'PredatorWeapons') )
		     {
			  log( "Couldn't attach LeftRunningLight to PredatorWeapons", 'Error' );
		      LeftRunningLight.Destroy();
			  return;
		     }

          RightRunningLight = Spawn(class'FX_RunningLight',self,,Location);
          if( !AttachToBone(RightRunningLight,'PredatorWeapons') )
		    {
			 log( "Couldn't attach RightRunningLight to PredatorWeapons", 'Error' );
			 RightRunningLight.Destroy();
			 return;
		    }
		  BottomRunningLight = Spawn(class'FX_RunningLight',self,,Location);
		  if( !AttachToBone(BottomRunningLight,'PredatorWeapons') )
		    {
			 log( "Couldn't attach BottomRunningLight to PredatorWeapons", 'Error' );
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

    SetBoneRotation('BladeAttachment', r, 0, 1.f);
}

simulated function Tick(float DeltaTime)
{
    local float EnginePitch,ThrustAmount,HitDist;
	local int i;
	local vector RelVel,TraceStart, TraceEnd, HitLocation, HitNormal;
	local actor HitActor;
	local bool bIsBehindView;
	local PlayerController PC;

     if (blades==none)
         {
          blades=spawn(Class'CSAPVerIV.Deco_PredatorBlades',Self,,Location);
          if( !AttachToBone(blades,'BladeAttachment') )
            {
			log( "Couldn't attach blades to BladeAttachment", 'Error' );
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

	//---Running Lights-----------------------------------

    if (bDriving==true)
       {
           UpdateRoll(DeltaTime);
           if (BladesStill!=none)
               BladesStill.Destroy();
           if (LandingGears!=none)
               LandingGears.Destroy();
         }

    if (bDriving==false && LandingGears==none)
         GearStatusChanged();

    Super.Tick(DeltaTime);
    if ( !IsVehicleEmpty() )
		Enable('tick');
}


simulated event GearStatusChanged()
{
  	if (LandingGears==none)
               {
           LandingGears=spawn(Class'Deco_PredatorGears',Self,,Location);
           if( !AttachToBone(LandingGears,'PredatorWeapons') )
             {
			  log( "Couldn't attach LandingGears to PredatorWeapons", 'Error' );
			   LandingGears.Destroy();
			   return;
		     }
		     LandingGears.SetRelativeLocation(LandingGearOffset);
           }
     if (blades!=none)
	    blades.Destroy();

     if (BladesStill==none)
          {
           BladesStill=spawn(Class'Deco_PredatorStillBlades',Self,,Location);
           if( !AttachToBone(BladesStill,'BladeAttachment') )
             {
			  log( "Couldn't attach BladesStill to BladeAttachment", 'Error' );
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

exec function SwitchToLastWeapon()
{
     if ( NumChaff > 0 )
     {
	   NumChaff --;
       Decoy=Spawn(Class'CSAPVerIV.Proj_FighterChaff',Self,,location + Vect(-228,0,0),Rotation);
     }
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

auto state WeaponPlasmaCannonMode
{
  function VehicleFire(bool bWasAltFire)
   {
    	if (bWasAltFire)
    	{
            GotoState('WeaponMissilesmode');
        }
    	else
    		bWeaponIsFiring = True;
   }
   Begin:
       if (PlayerController(Controller) != None)
	   PlayerController(Controller).ReceiveLocalizedMessage(class'MSG_PredatorMessages', 1);
       SetActiveWeapon(0);
}

state WeaponMissilesmode
{
    function VehicleFire(bool bWasAltFire)
            {
    	     if (bWasAltFire)
    	        {
                 GotoState('WeaponRocketmode');
                }
    	     else
    		     bWeaponIsFiring = True;
            }
Begin:
       if (PlayerController(Controller) != None)
	   PlayerController(Controller).ReceiveLocalizedMessage(class'MSG_PredatorMessages', 3);
       SetActiveWeapon(1);
}

state WeaponRocketmode
{
    function VehicleFire(bool bWasAltFire)
            {
    	     if (bWasAltFire)
    	        {
                 GotoState('WeaponPlasmaCannonMode');
                }
    	     else
    		     bWeaponIsFiring = True;
            }
Begin:
       if (PlayerController(Controller) != None)
	   PlayerController(Controller).ReceiveLocalizedMessage(class'MSG_PredatorMessages', 4);
       SetActiveWeapon(2);
}


defaultproperties
{
    bEnhancedHud=false
    EnhancedHudRange=10000
     MaxPitchSpeed=2000.000000
     TrailEffectPositions(0)=(X=-148.000000,Y=-20.000000,Z=36.000000)
     TrailEffectPositions(1)=(X=-148.000000,Y=20.000000,Z=36.000000)
     TrailEffectClass=Class'Onslaught.ONSAttackCraftExhaust'
     ChopperDustOffset(0)=(X=25.000000,Z=10.000000)
     ChopperDustTraceDistance=600.000000
     LeftRunningLightOffset=(X=-1.150000,Y=-5.100000,Z=0.600000)
     RightRunningLightOffset=(X=-1.150000,Y=5.100000,Z=0.600000)
     BottomRunningLightOffset=(Z=-0.500000)
     LandingGearOffset=(X=-2.000000,Z=1.100000)
     NumChaff=3
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
     DriverWeapons(0)=(WeaponClass=Class'CSAPVerIV.Weapon_PredatorWeapon',WeaponBone="PredatorWeapons")
     DriverWeapons(1)=(WeaponClass=Class'CSAPVerIV.Weapon_PredatorMissileWeapon',WeaponBone="PredatorWeapons")
     DriverWeapons(2)=(WeaponClass=Class'CSAPVerIV.Weapon_PredatorHellFireRockets',WeaponBone="PredatorWeapons")
     PassengerWeapons(0)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_PredatorPawn',WeaponBone="PredatorWeaponAttachment")
     PassengerWeapons(1)=(WeaponPawnClass=Class'CSAPVerIV.WeaponPawn_PredatorPassenger',WeaponBone="PredatorWeapons")
     bHasAltFire=False
     IdleSound=Sound'APVerIV_Snd.PredatorSnd'
     StartUpSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftStartUp'
     ShutDownSound=Sound'ONSVehicleSounds-S.AttackCraft.AttackCraftShutDown'
     StartUpForce="AttackCraftStartUp"
     ShutDownForce="AttackCraftShutDown"
     DestroyedVehicleMesh=StaticMesh'APVerIV_ST.Predator_ST.PredatorDestroyed'
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
     VehiclePositionString="in a Predator"
     VehicleNameString="Predator 1.8"
     RanOverDamageType=Class'Onslaught.DamTypeAttackCraftRoadkill'
     CrushedDamageType=Class'Onslaught.DamTypeAttackCraftPancake'
     FlagBone="PredatorGunTurret"
     FlagOffset=(Z=80.000000)
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn03'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn07'
     bCanBeBaseForPawns=True
     GroundSpeed=2000.000000
     HealthMax=350.000000
     Health=350
     Mesh=SkeletalMesh'APVerIV_Anim.PredatorMesh'
     SoundVolume=240
     CollisionRadius=150.000000
     CollisionHeight=70.000000
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
     KParams=KarmaParamsRBFull'CSAPVerIV.Predator.KParams0'

}
