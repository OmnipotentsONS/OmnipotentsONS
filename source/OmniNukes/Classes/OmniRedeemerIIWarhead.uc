class OmniRedeemerIIWarhead extends Pawn;

#EXEC OBJ LOAD FILE=2K4Hud.utx
#EXEC OBJ LOAD FILE=OmniNukesSounds.uax
//#exec LOAD OBJ FILE=forcompile\siegesnds.uax PACKAGE=WGSNUKE

var float Damage, DamageRadius, MomentumTransfer;
var class<DamageType> MyDamageType;
var Pawn OldPawn;
var	RedeemerTrail SmokeTrail;
var float YawAccel, PitchAccel;
var float ExpStart;
var float armor;


// banking related
var Shader InnerScopeShader, OuterScopeShader, OuterEdgeShader;
var FinalBlend AltitudeFinalBlend;
var float YawToBankingRatio, BankingResetRate, BankingToScopeRotationRatio;
var int Banking, BankingVelocity, MaxBanking, BankingDamping;

var float VelocityToAltitudePanRate, MaxAltitudePanRate;

// camera shakes //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view

var bool	bStaticScreen;
var bool	bFireForce;

var TeamInfo MyTeam;

replication
{
    reliable if (Role == ROLE_Authority && bNetOwner)
        armor, ExpStart, bStaticScreen;

    reliable if ( Role < ROLE_Authority )
		ServerBlowUp;
}

function PlayerChangedTeam()
{
	Died( None, class'DamageType', Location );
	OldPawn.Died(None, class'DamageType', OldPawn.Location);
}

function TeamInfo GetTeam()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.Team;
	return MyTeam;
}

simulated function Destroyed()
{
	RelinquishController();
	if ( SmokeTrail != None )
		SmokeTrail.Destroy();
	Super.Destroyed();
}

simulated function bool IsPlayerPawn()
{
	return false;
}

event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry )
		return true;

	return false;
}

event EncroachedBy( actor Other )
{
	BlowUp(Location);
}

function RelinquishController()
{
	if ( Controller == None )
		return;
	Controller.Pawn = None;
	if ( !Controller.IsInState('GameEnded') )
	{
		if ( (OldPawn != None) && (OldPawn.Health > 0) )
			Controller.Possess(OldPawn);
		else
		{
			if ( OldPawn != None )
				Controller.Pawn = OldPawn;
			else
				Controller.Pawn = self;
			Controller.PawnDied(Controller.Pawn);
		}
	}
	RemoteRole = Default.RemoteRole;
	Instigator = OldPawn;
	Controller = None;
}

simulated function PostBeginPlay()
{
	local vector Dir;

	Dir = Vector(Rotation);
    Velocity = AirSpeed * Dir;
    Acceleration = Velocity;

	if ( Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'RedeemerTrail',self,,Location - 40 * Dir);
		SmokeTrail.SetBase(self);
	}
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if ( PlayerController(Controller) != None )
	{
		Controller.SetRotation(Rotation);
		PlayerController(Controller).SetViewTarget(self);
		Controller.GotoState(LandMovementState);
		PlayOwnedSound(Sound'WeaponSounds.redeemer_shoot',SLOT_Interact,1.0);
	}
}

simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
}

function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange)
{
    local vector X,Y,Z;
	local float PitchThreshold;
	local int Pitch;
    local rotator TempRotation;
    local TexRotator ScopeTexRotator;
    local VariableTexPanner AltitudeTexPanner;

	YawAccel = (1-2*DeltaTime)*YawAccel + DeltaTime*YawChange;
	PitchAccel = (1-2*DeltaTime)*PitchAccel + DeltaTime*PitchChange;
	SetRotation(rotator(Velocity));

	GetAxes(Rotation,X,Y,Z);
	PitchThreshold = 3000;
	Pitch = Rotation.Pitch & 65535;
	if ( (Pitch > 16384 - PitchThreshold) && (Pitch < 49152 + PitchThreshold) )
	{
		if ( Pitch > 49152 - PitchThreshold )
			PitchAccel = Max(PitchAccel,0);
		else if ( Pitch < 16384 + PitchThreshold )
			PitchAccel = Min(PitchAccel,0);
	}
	Acceleration = Velocity + 5*(YawAccel*Y + PitchAccel*Z);
	if ( Acceleration == vect(0,0,0) )
		Acceleration = Velocity;

	Acceleration = Normal(Acceleration) * AccelRate;

    BankingVelocity += DeltaTime * (YawToBankingRatio * YawChange - BankingResetRate * Banking - BankingDamping * BankingVelocity);
    Banking += DeltaTime * (BankingVelocity);
    Banking = Clamp(Banking, -MaxBanking, MaxBanking);
	TempRotation = Rotation;
	TempRotation.Roll = Banking;
	SetRotation(TempRotation);
    ScopeTexRotator = TexRotator(OuterScopeShader.Diffuse);
    if (ScopeTexRotator != None)
        ScopeTexRotator.Rotation.Yaw = Rotation.Roll;
    AltitudeTexPanner = VariableTexPanner(Shader(AltitudeFinalBlend.Material).Diffuse);
    if (AltitudeTexPanner != None)
        AltitudeTexPanner.PanRate = FClamp(Velocity.Z * VelocityToAltitudePanRate, -MaxAltitudePanRate, MaxAltitudePanRate);
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
}

simulated function Landed( vector HitNormal )
{
	BlowUp(Location);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	BlowUp(Location);
}

function UnPossessed()
{
	BlowUp(Location);
}

simulated singular function Touch(Actor Other)
{
	if ( Other.bBlockActors )
		BlowUp(Location);
}

simulated singular function Bump(Actor Other)
{
	if (Other.bBlockActors)
		BlowUp(Location);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,Vector momentum, class<DamageType> damageType)
{
	local controller c;

  if ( (Damage > 0) && ((InstigatedBy == None) || (InstigatedBy.Controller == None) || (Instigator == None) || (Instigator.Controller == None) || !InstigatedBy.Controller.SameTeamAs(Instigator.Controller)) )
	{
	    if ( DamageType.Default.bVehicleHit || (DamageType == class'Crushed') )
			    BlowUp(Location);
		  else if(Damage>=rand(armor))
		  {
			    if ( PlayerController(Controller) != None ) PlayerController(Controller).PlayRewardAnnouncement('Denied',1, true);
			    if ( PlayerController(InstigatedBy.Controller) != None )	PlayerController(InstigatedBy.Controller).PlayRewardAnnouncement('Denied',1, true);

          Spawn(class'OmniNukes.OmniNukeFlash',,, Location, Rotation);
          Spawn(class'OmniNukes.OmniNukeExplo',,, Location, Rotation);
          PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKExp',SLOT_None,TransientSoundVolume/1.5,false,TransientSoundRadius/2);

		      RelinquishController();
		      SetCollision(false,false,false);
		      HurtRadius(100, 400, MyDamageType, MomentumTransfer, Location);
		      Destroy();


		    for ( c = Level.ControllerList; c!=None; c=c.nextController )
            {
                if(playercontroller(c)!=none && c.PlayerReplicationInfo.team!=instigator.PlayerReplicationInfo.Team)
                    playercontroller(c).ReceiveLocalizedMessage(class'OmniNukes.OmniNukeUnWarnMsg');
            }
            
		}
	}
}

function Fire( optional float F )
{
	ServerBlowUp();
	if ( F == 1 )
	{
		OldPawn.Health = -1;
		OldPawn.KilledBy(OldPawn);
	}
}

function ServerBlowUp()
{
	BlowUp(Location);
}

function BlowUp(vector HitLocation)
{
    local rotator rot;
    local vector loc;
    local int i;
    local OmniNukeMShroomcloud cloud;

    if ( Role == ROLE_Authority )
	  {
	      bHidden=true;
        Spawn(class'OmniNukes.OmniNukeNukeFlash',,, Location, Rotation);
        loc=location+vect(0,0,1)*512;
        //Mushroom-Cloud
        for(i=0; i<8; i++)
        {
            cloud=none;
            loc=location+vect(0,0,1)*512;
            rot.yaw=(8187)*i;
            cloud=Spawn(class'OmniNukes.OmniNukeMShroomcloud',,,location+vector(rot)*420, Rot);
            cloud.Velocity=vect(0,0,1)*260;
        }
        Spawn(class'OmniNukes.OmniNukeExplosionA',,, Location, rotator(vect(0,0,0)));
        GotoState('Dying');
    }
}

function bool DoJump( bool bUpdating )
{
	return false;
}

singular event BaseChange()
{
}

simulated function DrawHUD(Canvas Canvas)
{
    local float Offset;
    local Plane SavedCM;

    SavedCM = Canvas.ColorModulate;
    Canvas.ColorModulate.X = 1;
    Canvas.ColorModulate.Y = 1;
    Canvas.ColorModulate.Z = 1;
    Canvas.ColorModulate.W = 1;
    Canvas.Style = 255;
	Canvas.SetPos(0,0);
	Canvas.DrawColor = class'Canvas'.static.MakeColor(255,255,255);
	if ( bStaticScreen )
		Canvas.DrawTile( Material'ScreenNoiseFB', Canvas.SizeX, Canvas.SizeY, 0.0, 0.0, 512, 512 );
	else if ( !Level.IsSoftwareRendering() )
	{
	    if (Canvas.ClipX >= Canvas.ClipY)
	    {
            Offset = Canvas.ClipX / Canvas.ClipY;
	        Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512 * (1 - Offset), 0, Offset * 512, 512 );
     	    Canvas.SetPos(0.5*Canvas.SizeX,0);
      	    Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 0, -512 * Offset, 512 );
         	Canvas.SetPos(0,0.5* Canvas.SizeY);
            Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512 * (1 - Offset), 512, Offset * 512, -512);
            Canvas.SetPos(0.5*Canvas.SizeX,0.5* Canvas.SizeY);
            Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512, -512 * Offset, -512 );
            Canvas.SetPos(0, 0);
	        Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512 * (1 - Offset), 0, Offset * 512, 512 );
     	    Canvas.SetPos(0.5* Canvas.SizeX,0);
      	    Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 0, -512 * Offset, 512 );
       	    Canvas.SetPos(0,0.5* Canvas.SizeY);
            Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512 * (1 - Offset), 512, Offset * 512, -512 );
            Canvas.SetPos(0.5* Canvas.SizeX,0.5* Canvas.SizeY);
            Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512, -512 * Offset, -512 );
            Canvas.SetPos(0.5 * (Canvas.SizeX - Canvas.SizeY), 0);
            Canvas.DrawTile( OuterScopeShader, Canvas.SizeX, Canvas.SizeY, 0, 0, 1024 * Offset, 1024 );
            Canvas.SetPos((512 * (Offset - 1) + 383) * (Canvas.SizeX / (1024 * Offset)), Canvas.SizeY *(451.0/(1024.0)));
            Canvas.DrawTile( AltitudeFinalBlend, Canvas.SizeX / (8 * Offset), Canvas.SizeY / 8, 0, 0, 128, 128);
            Canvas.SetPos((512 * (Offset - 1) + 383 + 2*(512-383) - 128) * (Canvas.SizeX / (1024 * Offset)), Canvas.SizeY *(451.0/1024.0));
            Canvas.DrawTile( AltitudeFinalBlend, Canvas.SizeX / (8 * Offset), Canvas.SizeY / 8, 128, 0, -128, 128);
        }
        else
        {
            Offset = Canvas.ClipY / Canvas.ClipX;
	        Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 0, 512 * (1 - Offset), 512, 512 * Offset);
     	    Canvas.SetPos(0.5*Canvas.SizeX,0);
      	    Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512 * (1 - Offset), -512, 512 * Offset);
         	Canvas.SetPos(0,0.5* Canvas.SizeY);
            Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 0, 512, 512, -512 * Offset);
            Canvas.SetPos(0.5*Canvas.SizeX,0.5* Canvas.SizeY);
            Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512, -512, -512 * Offset);
            Canvas.SetPos(0, 0);
	        Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 0, 512 * (1 - Offset), 512, 512 * Offset);
     	    Canvas.SetPos(0.5*Canvas.SizeX,0);
      	    Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512 * (1 - Offset), -512, 512 * Offset);
         	Canvas.SetPos(0,0.5* Canvas.SizeY);
            Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 0, 512, 512, -512 * Offset);
            Canvas.SetPos(0.5*Canvas.SizeX,0.5* Canvas.SizeY);
            Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512, -512, -512 * Offset);
            Canvas.SetPos(0, 0.5 * (Canvas.SizeY - Canvas.SizeX));
            Canvas.DrawTile( OuterScopeShader, Canvas.SizeX, Canvas.SizeY, 0, 0, 1024, 1024 * Offset );
            Canvas.SetPos(Canvas.SizeX * (383.0/1024.0), (512 * (Offset - 1) + 451) * (Canvas.SizeY / (1024 * Offset)));
            Canvas.DrawTile( AltitudeFinalBlend, Canvas.SizeX / 8, Canvas.SizeY / (8 * Offset), 0, 0, 128, 128);
            Canvas.SetPos(Canvas.SizeX * ((383 + 2*(512-383) - 128)) / 1024, (512 * (Offset - 1) + 451) * (Canvas.SizeY / (1024 * Offset)));
            Canvas.DrawTile( AltitudeFinalBlend, Canvas.SizeX / 8, Canvas.SizeY / (8 * Offset), 128, 0, -128, 128);
        }
   	}
   	Canvas.ColorModulate = SavedCM;
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc);

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	BlowUp(Location);
}

function bool CheatWalk()
{
	return false;
}

function bool CheatGhost()
{
	return false;
}

function bool CheatFly()
{
	return false;
}

function ShouldCrouch(bool Crouch) {}

event SetWalking(bool bNewIsWalking) {}

function Suicide()
{
	Blowup(Location);
	if ( (OldPawn != None) && (OldPawn.Health > 0) )
		OldPawn.KilledBy(OldPawn);
}

auto state Flying
{
	function Tick(float DeltaTime)
	{
		if ( !bFireForce && (PlayerController(Controller) != None) )
		{
			bFireForce = true;
			PlayerController(Controller).ClientPlayForceFeedback("FlakCannonAltFire");  // jdf
		}
		if ( (OldPawn == None) || (OldPawn.Health <= 0) )
			BlowUp(Location);
		else if ( Controller == None )
		{
			if ( OldPawn.Controller == None )
				OldPawn.KilledBy(OldPawn);
			BlowUp(Location);
		}
	}
}
//////////////////// DmgRadius added after ///////////////
simulated function DmgRadius(vector flash, float dmgPctHard, float dmgPctThru, float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if ( bHurtEntry )
		return;

    bHurtEntry = true;
	foreach CollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
		    dir = Victims.Location - HitLocation;
		    dist = FMax(1,VSize(dir));
		    dir = dir/dist;
		    damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
        if(!fasttrace(Victims.Location, hitlocation)) damagescale*=dmgPctThru;
        if ( oldpawn.Controller != None ) Victims.SetDelayedDamageInstigatorController( oldpawn.Controller );

        if(pawn(victims)!=none) damagescale=damagescale;
        else damagescale*=dmgPctHard;

        Victims.TakeDamage(damageScale * DamageAmount,Instigator,	Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(damageScale * Momentum * dir),DamageType);
		  	if(pawn(victims)!=none && pawn(victims).controller!=none && playercontroller(pawn(victims).controller)!=none && flash!=vect(0,0,0))
             playercontroller(pawn(victims).controller).clientflash(1-damagescale, flash);

        if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				    Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, oldpawn.Controller, DamageType, Momentum, HitLocation);

		}
	}

	bHurtEntry = false;
}

state Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function Fire( optional float F ) {}
	function BlowUp(vector HitLocation) {}
	function ServerBlowUp() {}
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType) {}

    function BeginState()
    {
		    bHidden = true;
		    LightType=LT_Steady;
        bStaticScreen = true;
		    SetPhysics(PHYS_None);
		    SetCollision(false,false,false);
		   //Spawn(class'IonCore',,, Location, Rotation);

        if ( SmokeTrail != None )	SmokeTrail.Kill();
		    ShakeView();

		    bDynamicLight=true;

        expstart=level.TimeSeconds;
        settimer(0.1, true);
    }

    simulated function timer()
    {
		local float h;
		local OmniNukeCloudWave wave;

        if(level.TimeSeconds<expstart+2) lightbrightness=(level.timeseconds-expstart)*255;
        else lightbrightness=fmax(0,255-(level.timeseconds-(expstart+2))*26);

        //Cloudwaves
        if(level.TimeSeconds>expstart+2 && level.TimeSeconds<expstart+4 && frand()<0.2)
        {
            h=400+2000*(((level.timeseconds-expstart)-2)/2);
            wave=Spawn(class'OmniNukes.OmniNukeCloudWave',,,Location+vect(0,0,1)*h);
            wave.emitters[0].SizeScale[1].relativesize= 20+(60+rand(40))*(level.timeseconds-(expstart+2))*(1-h/2400);
        }
    }

    function ShakeView()
    {
        local Controller C;
        local PlayerController PC;
        local float Dist, Scale;

        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
            PC = PlayerController(C);
            if ( PC != None && PC.ViewTarget != None )
            {
                Dist = VSize(Location - PC.ViewTarget.Location);
                if (Dist<DamageRadius*3)
                {
                    scale=1-(dist/(DamageRadius*3));

                    C.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
                }
            }
        }
    }

Begin:
	  Instigator = self;
    DmgRadius(vect(10000,11000,12000), 0, 0.9, Damage*0.01, DamageRadius, class'OmniNukes.DamTypeOmniNukeFlash', MomentumTransfer*0, Location);

    //Sleep(0.2);
    //RelinquishController();
    // pooty - this might be the no damage bug, why reliquish controller now wait till same spot as regular deemer 

    PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKBoom',SLOT_None,5*TransientSoundVolume);
    PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKRing',SLOT_None,1.0*TransientSoundVolume,false,TransientSoundRadius*1.5,0.3+frand()*0.7);
    PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKRing',SLOT_None,1.25*TransientSoundVolume,false,TransientSoundRadius*1.6,0.2+frand()*0.4);
    PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKRing',SLOT_None,1.5*TransientSoundVolume,false,TransientSoundRadius*1.7,0.1+frand()*0.1);
    PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKDistantBoom',SLOT_None,3*TransientSoundVolume,false,TransientSoundRadius*4);

    //Deemer Code
    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage, DamageRadius*0.300, MyDamageType, MomentumTransfer, Location);
    Sleep(0.15);
    HurtRadius(Damage, DamageRadius*0.475, MyDamageType, MomentumTransfer, Location);
    Sleep(0.15);
    RelinquishController();
    HurtRadius(Damage, DamageRadius*0.650, MyDamageType, MomentumTransfer, Location);
    Sleep(0.15);
    HurtRadius(Damage, DamageRadius*0.825, MyDamageType, MomentumTransfer, Location);
    Sleep(0.15);
    HurtRadius(Damage, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);

    //Shockwave+Heat
    DmgRadius(vect(0,0,0), 1, 0.20, Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.15);
    DmgRadius(vect(0,0,0), 1, 0.19, Damage*0.975, DamageRadius*0.213, MyDamageType, MomentumTransfer*0.975, Location);
    Sleep(0.15);
    DmgRadius(vect(0,0,0), 1, 0.18, Damage*0.9, DamageRadius*0.300, MyDamageType, MomentumTransfer*0.9, Location);
    Sleep(0.15);
    DmgRadius(vect(0,0,0), 1, 0.17, Damage*0.85, DamageRadius*0.388, MyDamageType, MomentumTransfer*0.85, Location);
    Sleep(0.15);
//    DmgRadius(vect(500,400,100), 0.2, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'WGS_wep_paky.DamTypeNKHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.16, Damage*0.8, DamageRadius*0.475, MyDamageType, MomentumTransfer*0.8, Location);
    Sleep(0.15);
//    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'WGS_wep_paky.DamTypeNKHeat', MomentumTransfer*-0.2, Location);
//    DmgRadius(vect(0,0,0), 1, 0.15, Damage*0.7, DamageRadius*0.563, MyDamageType, MomentumTransfer*0.7, Location);
//    Sleep(0.2);
//    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'WGS_wep_paky.DamTypeNKHeat', MomentumTransfer*-0.2, Location);
//    DmgRadius(vect(0,0,0), 1, 0.14, Damage*0.6, DamageRadius*0.650, MyDamageType, MomentumTransfer*0.6, Location);
//    Sleep(0.2);
//    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'WGS_wep_paky.DamTypeNKHeat', MomentumTransfer*-0.2, Location);
      DmgRadius(vect(0,0,0), 1, 0.13, Damage*0.45, DamageRadius*0.738, MyDamageType, MomentumTransfer*0.45, Location);
      Sleep(0.1);
//    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'WGS_wep_paky.DamTypeNKHeat', MomentumTransfer*-0.2, Location);
//    DmgRadius(vect(0,0,0), 1, 0.12, Damage*0.3, DamageRadius*0.825, MyDamageType, MomentumTransfer*0.3, Location);
//    Sleep(0.2);
//    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'WGS_wep_paky.DamTypeNKHeat', MomentumTransfer*-0.2, Location);
      DmgRadius(vect(0,0,0), 1, 0.11, Damage*0.1, DamageRadius*0.9, MyDamageType, MomentumTransfer*0.1, Location);
//    Sleep(0.2);
//    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'WGS_wep_paky.DamTypeNKHeat', MomentumTransfer*-0.2, Location);
      DmgRadius(vect(0,0,0), 1, 0.10, Damage*0.05, DamageRadius*1.000, MyDamageType, MomentumTransfer*0.05, Location);

    //Heat only
    while(level.TimeSeconds<expstart+10)
    {
        Sleep(0.1);  // was.2
        DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.10*DamageRadius, class'OmniNukes.DamTypeOmniNukeHeat', MomentumTransfer*-0.2, Location);
    }

    Sleep(5);
    Destroy();
}

defaultproperties
{
     Damage=375.000000
     DamageRadius=5000.000000
     MomentumTransfer=500000.000000
     MyDamageType=Class'OmniNukes.DamTypeOmniNukeRedeemerII'
     Armor=75.000000
     InnerScopeShader=Shader'2K4Hud.ZoomFX.RDM_InnerScopeShader'
     OuterScopeShader=Shader'2K4Hud.ZoomFX.RDM_OuterScopeShader'
     OuterEdgeShader=Shader'2K4Hud.ZoomFX.RDM_OuterEdgeShader'
     AltitudeFinalBlend=FinalBlend'2K4Hud.ZoomFX.RDM_AltitudeFinal'
     YawToBankingRatio=60.000000
     BankingResetRate=15.000000
     BankingToScopeRotationRatio=8.000000
     MaxBanking=20000
     BankingDamping=10
     VelocityToAltitudePanRate=0.001750
     MaxAltitudePanRate=10.000000
     ShakeRotMag=(Z=500.000000)
     ShakeRotRate=(Z=3500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=20.000000)
     ShakeOffsetRate=(Z=1000.000000)
     ShakeOffsetTime=12.000000
     bSimulateGravity=False
     bDirectHitWall=True
     bHideRegularHUD=True
     bSpecialHUD=True
     bNoTeamBeacon=True
     bCanUse=False
     AirSpeed=1800.000000
     AccelRate=2000.000000
     BaseEyeHeight=0.000000
     EyeHeight=0.000000
     LandMovementState="PlayerRocketing"
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=40
     LightSaturation=192
     LightBrightness=255.000000
     LightRadius=128.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RedeemerMissile'
     bDynamicLight=True
     bStasis=False
     bReplicateInstigator=True
     bNetInitialRotation=True
     Physics=PHYS_Flying
     NetPriority=3.000000
     AmbientSound=Sound'OmniNukesSounds.OmniNukes.tfWarheadAmb'
     DrawScale=0.500000
     AmbientGlow=96
     bGameRelevant=True
     SoundRadius=100.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=5000.000000
     CollisionRadius=24.000000
     CollisionHeight=12.000000
     bBlockActors=False
     ForceType=FT_DragAlong
     ForceRadius=100.000000
     ForceScale=5.000000
}
