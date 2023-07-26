
class CSHoverMech extends ONSHoverCraft
    placeable;

#exec OBJ LOAD FILE=..\Animations\ONSVehicles-A.ukx
#exec OBJ LOAD FILE=..\Sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=..\textures\EpicParticles.utx
#exec OBJ LOAD FILE=..\StaticMeshes\ONSWeapons-SM
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

#exec obj load file="Animations\CSMech_Anim.ukx" package=CSMech
#exec obj load file="Textures\CSMech_tex.utx" package=CSMech
#exec AUDIO IMPORT FILE=Sounds\FootStep.wav
#exec AUDIO IMPORT FILE=Sounds\EngStart.wav
#exec AUDIO IMPORT FILE=Sounds\EngStop.wav
#exec AUDIO IMPORT FILE=Sounds\EngIdle.wav
#exec AUDIO IMPORT FILE=Sounds\EngIdle2.wav
#exec AUDIO IMPORT FILE=Sounds\turretturn.wav
#exec AUDIO IMPORT FILE=Sounds\jump.wav
#exec AUDIO IMPORT FILE=Sounds\yourstocommand.wav

var()   float   MaxPitchSpeed;

var()   float   JumpDuration;
var()	float	JumpForceMag;
var     float   JumpCountdown;
var     float	JumpDelay, DoubleJumpDelay, LastJumpTime;

var()   sound                           JumpSound;
var()   sound                           FootStepSound;
var()   sound                           TeamChangedSound;

// Force Feedback
var()	string							JumpForce;

var		bool							DoMechJump;
var		bool							OldDoMechJump;
var     bool                            CanDoDoubleJump;
var     bool                            DidDoubleJump;

var     float                           animRate, tweenTime;
var     bool                            bOnGround;
var     bool                            bOldOnGround;
var     float                           GroundContact;
var     float                           StepCountdown;
var float MaxGroundSpeed, MaxAirSpeed;
var name FireRootBone;
var     rotator                         currentR;
var int currentDir;
var bool bExtraTwist;
var     float                           GravScaleAir, GravScaleAirThrottle;
var     float                           RadarHudRange;
var     bool                            bDebug;
var     float                           oldCollisionRise, oldJumpRise;
var     float                           stepPitchFactor;
var     Material                        RedSkinHead,BlueSkinHead;
var     array<name>                     HornAnims[2];
var()     Name                            HornAnim;
var       Name                          PrevAction;
var name HitAnims[4];

var float OldThrottle; // , OldSteering;  defined in Vehicle.uc
var float lastFirstTap, lastSecondTap, doubleTapThreshold;
var int dodgeDir, oldDodgeDir, firstDodgeDir, secondDodgeDir;
var float DodgeForceMag, DodgeCountdown, DodgeDuration, DodgeAirSpeedMulti;
var bool bDodgeEnabled;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		DoMechJump, dodgeDir;
	unreliable if (Role == ROLE_Authority)
        ClientPlayHorn;
}

simulated function PostBeginPlay()
{
    //fix for spawning halfway below geometry
    SetCollision(false,false,false);
    SetPhysics(PHYS_None);
    SetLocation(Location + vect(0,0,420));
    SetPhysics(PHYS_Karma);
    SetCollision(true,true,true);

    super.PostBeginPlay();
    BoneRefresh();
    AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
    PlayAnim('JumpF_Land', animRate,tweenTime,0);
    PlayAnim('Biggun_Burst', animRate,tweenTime,1);
    SetMesh();
}

simulated function PostNetBeginPlay()
{
	local vector RotX, RotY, RotZ;
	local KarmaParams kp;
	local KRepulsor rep;
	local int i;
    local MutantGlow ball;

    GetAxes(Rotation,RotX,RotY,RotZ);

	// Spawn and assign 'repulsors' to hold bike off the ground
	kp = KarmaParams(KParams);
    kp.Repulsors.Length = ThrusterOffsets.Length;

	for(i=0;i<ThrusterOffsets.Length;i++)
	{
    	rep = spawn(class'KRepulsor', self,, Location + ThrusterOffsets[i].X * RotX + ThrusterOffsets[i].Y * RotY + ThrusterOffsets[i].Z * RotZ);
    	rep.SetBase(self);
    	rep.bHidden = True;
    	rep.bRepulseWater = False;
    	kp.Repulsors[i] = rep;

        if(bDebug)
        {
            ball = spawn(class'MutantGlow', self,, Location + ThrusterOffsets[i].X * RotX + ThrusterOffsets[i].Y * RotY + ThrusterOffsets[i].Z * RotZ);
            ball.SetBase(self);
        }
    }

    Super(ONSVehicle).PostNetBeginPlay();
}

//used to draw HUD when in FP view
simulated function DrawHUD(Canvas Canvas)
{
    local PlayerController PC;
    local int cyaw;

    super.DrawHUD(Canvas);

    PC = PlayerController(Controller);

    if(bDebug)
    {
        cyaw = pc.Rotation.Yaw & 65535;
        if(cyaw > 32768)
            cyaw -= 65536;
        Canvas.SetPos(4,200);
        Canvas.DrawText("currentR! P="$currentR.Pitch$" Y="$currentR.Yaw$" R="$currentR.Roll);
        Canvas.SetPos(4,220);
        Canvas.DrawText("pcr! P="$PC.Rotation.Pitch$" Y="$PC.Rotation.Yaw$" R="$PC.Rotation.Roll$" cyaw="$cyaw);
        Canvas.SetPos(4,240);
        Canvas.DrawText("r! P="$Rotation.Pitch$" Y="$Rotation.Yaw$" R="$Rotation.Roll);
        Canvas.DrawText("currentDir="$currentDir);
    }

    if(PC != None && !PC.bBehindView)
    {
        Canvas.Style = 5;
        if ( !Level.IsSoftwareRendering() )
        {
            Canvas.DrawColor.R = 255;
            Canvas.DrawColor.G = 255;
            Canvas.DrawColor.B = 255;
            Canvas.DrawColor.A = 50;
            Canvas.DrawTile( Material'DomPLinesGP', Canvas.SizeX, Canvas.SizeY, 0, 0, 256, 256);
        }

        Canvas.Style = 1;
        Canvas.DrawColor.R = 255;
        Canvas.DrawColor.G = 255;
        Canvas.DrawColor.B = 255;
        Canvas.DrawColor.A = 255;

        Canvas.SetPos(0,0);
        Canvas.DrawTile( Material'TurretHud2', Canvas.SizeX, Canvas.SizeY, 0, 0, 1024, 768);
        Canvas.SetPos(0,0);

        DrawRadarHUD(Canvas, PC);
    }
}

simulated function DrawRadarHUD( Canvas C, PlayerController PC )
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

        if ( !class'HUD_Assault'.static.IsTargetInFrontOfPlayer( C, V, ScreenPos, Location, Rotation ) )
            continue;

        if ( !FastTrace( V.Location, Location ) )
            continue;
        
        if(VSize(Location-V.Location) > RadarHudRange)
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

function KDriverEnter(Pawn P)
{
    super.KDriverEnter(P);
	bHeadingInitialized = False;
    SetAnimAction('idle_start');
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	bHeadingInitialized = False;
	Super.ClientKDriverEnter(PC);
}

simulated function ClientKDriverLeave(PlayerController pc)
{
    if(!bDebug)
        SetAnimAction('JumpF_Land');

	Super.ClientKDriverLeave(PC);
}

// AI hint
function bool FastVehicle()
{
	return false;
}

function bool ImportantVehicle()
{
	return true;
}

simulated event DrivingStatusChanged()
{
    if(!bDriving && !bDebug)
        SetAnimAction('JumpF_Land');

    JumpCountDown = 0.0;
    DodgeCountdown = 0.0;
	Super.DrivingStatusChanged();
}

simulated event SetAnimAction(name NewAction)
{
    local bool isWalking, isCrouchWalking, wasWalking, wasCrouchWalking;

    PrevAction = AnimAction;
    AnimAction = NewAction;

    if(AnimAction == 'None' || AnimAction == ''|| bWaitForAnim)
        return;


    isWalking = IsWalkSeq(AnimAction);
    wasWalking = IsWalkSeq(prevAction);
    isCrouchWalking = IsCrouchWalkSeq(AnimAction);
    wasCrouchWalking = IsCrouchWalkSeq(prevAction);
    AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);

    if(AnimAction == 'idle_start')
    {
        AnimAction = 'Idle_Biggun';
        TweenAnim(AnimAction, 2.0);
    }
    else if(AnimAction == 'Biggun_Burst')
        PlayAnim(AnimAction, animRate,,1);
    else if(IsHornAnim(AnimAction))
        PlayAnim(AnimAction, animRate,,1);
    else if(IsTakeOffSeq(AnimAction))
    {
        AnimBlendParams(1, 0.0);
        PlayAnim(AnimAction, animRate, 0.1);
    }
    else if(IsJumpSeq(AnimAction))
    {
        AnimBlendParams(1, 0.0);
        PlayAnim(AnimAction, animRate, 0.1);
        
    }
    else if(IsDoubleJumpSeq(AnimAction))
    {
        AnimBlendParams(1, 0.0);
        PlayAnim(AnimAction, animRate, 0.1);
        
    }
    else if(IsHitSeq(AnimAction))
        PlayAnim(AnimAction, animRate,,0);
    else if(isCrouchWalking && !wasCrouchWalking)
        LoopAnim(AnimAction, animRate,0.3,0);
    else if(wasCrouchWalking && !isCrouchWalking)
        LoopAnim(AnimAction, animRate,0.3,0);
    else if(isCrouchWalking || isWalking)
        LoopAnim(AnimAction, animRate,,0);
    else if(AnimAction == 'Idle_Biggun')
    {
        LoopAnim(AnimAction, animRate,0.3,0);
    }
    else if(AnimAction == 'Crouch')
    {
        LoopAnim(AnimAction, animRate,0.3,0);
    }
    else
    {
        //unknown/unhandled
        PlayAnim(AnimAction, animRate,0.3,0);
    }

}

/*
function PlayTakeHit(vector HitLoc, int damage, class<DamageType> damageType)
{
    super.PlayTakeHit(HitLoc, damage, damageType);
    PlayDirectionalHit(HitLoc);
}
*/

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

    if(!bDriving || !bOnGround)
        return;

    //if(Health > 300)
    //    return;

    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;

    // random
    if ( VSize(Location - HitLoc) < 1.0 )
    {
        Dir = VRand();
    }
    // hit location based
    else
    {
        Dir = -Normal(Location - HitLoc);
    }

    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
    {
        SetAnimAction('HitF');
    }
    else if ( Dir Dot X < -0.7 )
    {
        SetAnimAction('HitB');
    }
    else if ( Dir Dot Y > 0 )
    {
        SetAnimAction('HitR');
    }
    else
    {
        SetAnimAction('HitL');
    }
    bWaitForAnim=true;
}

simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    CheckOnGround(DeltaTime);
    ForceUpright();
    UpdateTwist();
    ApplyAnims();
    CheckJump(DeltaTime);
    CheckDodging(DeltaTime);
    UpdateCollision();
    CheckDoStep(DeltaTime);
    UpdateEnginePitch(DeltaTime);
}


function DoStep()
{
    if(Role == ROLE_Authority)
    {
        PlaySound(FootStepSound,SLOT_Interact,512);
        if(Controller != None)
        {
            Controller.ShakeView(vect(100.0,0.0,0), vect(2000.0,0.0,0), 0.5, vect(0.0,0.0,0.0), vect(0.0,0.0,0.0), 0.0);
        }
    }
}

simulated function UpdateEnginePitch(float DeltaTime)
{
    local float EnginePitch;
    stepPitchFactor = FClamp(stepPitchFactor + DeltaTime, 0, 1.0);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		EnginePitch = 16.0 + (VSize(Velocity)/MaxPitchSpeed) * stepPitchFactor * 64.0 * 0.5;
		SoundPitch = FClamp(EnginePitch, 16, 128);
	}
}

simulated function CheckDoStep(float DeltaTime)
{
    local float frame, rate;
    local name seq;

    StepCountdown -= DeltaTime;

    if(StepCountdown <= 0 && bOnGround)
    {
		GetAnimParams( 0, seq, frame, rate );

        if(frame > 0.30 && frame < 0.35 && (IsWalkSeq(seq) || IsCrouchWalkSeq(seq)))
        {
            DoStep();
            StepCountdown = 0.5;
            stepPitchFactor = 0.5;
        }
        else if(frame > 0.80 && frame < 0.85 && (IsWalkSeq(seq) || IsCrouchWalkSeq(seq)))
        {
            DoStep();
            StepCountdown = 0.5;
            stepPitchFactor = 0.5;
        }
    }
}

simulated function bool IsWalkSeq(name seq)
{
    local int i;

    for(i = 0;i < 4; i++ )
    {
        if(WalkAnims[i] == seq)
            return true;
    }

    return false;
}

simulated function bool IsCrouchWalkSeq(name seq)
{
    local int i;

    for(i = 0;i < 4; i++ )
    {
        if(CrouchAnims[i] == seq)
            return true;
    }

    return false;
}

simulated function bool IsJumpSeq(name seq)
{
    local int i;

    for(i = 0;i < 4; i++ )
    {
        if(AirAnims[i] == seq)
            return true;
    }

    return false;
}

simulated function bool IsDoubleJumpSeq(name seq)
{
    local int i;

    for(i = 0;i < 4; i++ )
    {
        if(DoubleJumpAnims[i] == seq)
            return true;
    }

    return false;
}

simulated function bool IsDodgeSeq(name seq)
{
    local int i;

    for(i = 0;i < 4; i++ )
    {
        if(DoubleJumpAnims[i] == seq)
            return true;
    }

    return false;
}

simulated function bool IsTakeOffSeq(name seq)
{
    local int i;

    for(i = 0;i < 4; i++ )
    {
        if(TakeoffAnims[i] == seq)
            return true;
    }

    return false;
}

simulated function bool IsHitSeq(name seq)
{
    local int i;

    for(i = 0;i < 4; i++ )
    {
        if(HitAnims[i] == seq)
            return true;
    }

    return false;
}

simulated function bool IsHornAnim(name anim)
{
    local int i;

    for(i = 0;i < 2; i++ )
    {
        if(HornAnims[i] == anim)
            return true;
    }

    return false;
}

function bool OnGround()
{
    local int i;
	local KarmaParams KP;
	KP = KarmaParams(KParams);
	for(i=0; i<KP.Repulsors.Length; i++)
	{
		if( KP.Repulsors[i] != None && KP.Repulsors[i].bRepulsorInContact )
			return true;
	}

    return false;
}

simulated function ApplyAnims()
{
    local int dir;
    local float frame, rate;
    local name seq;

    dir = Get4WayDirection();
    GetAnimParams( 0, seq, frame, rate );

    if(!bDriving)
    {
        SetAnimAction('JumpF_Land');
    }
    else if(VSize(Velocity) < StopThreshold)
    {
        if(bOnGround)
        {
            if(Rise < 0)
                SetAnimAction('Crouch');
            else
                SetAnimAction('Idle_Biggun');
        }

    }
    else
    {
        if(bOnGround)
        {
            if(Rise < 0)
            {
                SetAnimAction(CrouchAnims[dir]);
            }
            else
            {
                SetAnimAction(WalkAnims[dir]);
            }
        }
    }
    if(bOldOnGround != bOnGround)
    {
        if(!bOnGround)
        {
            SetAnimAction(TakeoffAnims[dir]);
        }
        else
        {
            MechLanded();
        }

        bOldOnGround = bOnGround;
    }
}

simulated function CheckOnGround(float DeltaTime)
{
    local KarmaParams KP;
    KP = KarmaParams(KParams);
    if(OnGround())
    {
        GroundContact = 1.0;
	    KP.kMaxSpeed = MaxGroundSpeed;
    }
    else
    {
        KP.kMaxSpeed = MaxAirSpeed;
    }

    bOnGround = GroundContact > 0.0;
    GroundContact -= DeltaTime * 3.0;

}

simulated function MechLanded() 
{
    dodgeDir=-1;
    DidDoubleJump=false;
    DodgeCountdown=0;
    JumpCountdown=0;
}

simulated function CheckJump(float DeltaTime)
{
    local int dir;

    JumpCountdown -= DeltaTime;

    if(oldJumpRise != Rise)
    {
        // If we are on the ground, and press Rise, and we not currently in the middle of a jump, start a new one.
        if (Rise > 0 && bOnGround && Level.TimeSeconds - JumpDelay >= LastJumpTime)
        {        
            //PlaySound(JumpSound,,1.0);
            if (Role == ROLE_Authority)
            {
                DoMechJump = !DoMechJump;
            }

            if(Level.NetMode != NM_DedicatedServer)
            {
                ClientPlayForceFeedback(JumpForce);
            }

            if ( AIController(Controller) != None )
                Rise = 0;

            LastJumpTime = Level.TimeSeconds;
            didDoubleJump=false;
            dir = Get4WayDirection();
            SetAnimAction(TakeoffAnims[dir]);
        }
        else if (Rise > 0 && !bOnGround && !didDoubleJump && Level.TimeSeconds - LastJumpTime <= DoubleJumpDelay)
        {        
            if (Role == ROLE_Authority)
            {
                DoMechJump = !DoMechJump;
            }

            if(Level.NetMode != NM_DedicatedServer)
            {
                ClientPlayForceFeedback(JumpForce);
            }

            if ( AIController(Controller) != None )
                Rise = 0;


            LastJumpTime = Level.TimeSeconds;
            DidDoubleJump=true;
            dir = Get4WayDirection();
            SetAnimAction(DoubleJumpAnims[dir]);
        }

        oldJumpRise = Rise;
    }

	if(DoMechJump != OldDoMechJump)
	{
        JumpCountdown = JumpDuration;
        if(DidDoubleJump)
        {
            JumpCountdown+=JumpDuration;
        }

        OldDoMechJump = DoMechJump;
	}
}

simulated function CheckDodging(float DeltaTime)
{
    local KarmaParams KP;
    DodgeCountdown -= DeltaTime;

    if(Throttle != OldThrottle)
    {
        if(Throttle != 0)
        {
            lastSecondTap=lastFirstTap;
            lastFirstTap=Level.TimeSeconds;
            secondDodgeDir=firstDodgeDir;

            if(Throttle > 0 && OldThrottle <= 0)
                firstDodgeDir=0;
            else if (Throttle < 0 && OldThrottle >= 0)
                firstDodgeDir=1;

            if((lastFirstTap - lastSecondTap) < doubleTapThreshold && firstDodgeDir == secondDodgeDir && dodgeDir < 0 && bOnGround)
            {
                if(ROLE == ROLE_Authority && bDodgeEnabled)
                   dodgeDir=firstDodgeDir;
            }
        }

        OldThrottle=Throttle;
    }
    else if(Steering != OldSteering)
    {
        if(Steering != 0)
        {
            lastSecondTap=lastFirstTap;
            lastFirstTap=Level.TimeSeconds;
            secondDodgeDir=firstDodgeDir;

            if( Steering > 0 && OldSteering <= 0)
                firstDodgeDir=2;
            else if( Steering < 0 && OldSteering >= 0)
                firstDodgeDir=3;

            if((lastFirstTap - lastSecondTap) < doubleTapThreshold && firstDodgeDir == secondDodgeDir && dodgeDir < 0 && bOnGround)
            {
                if(ROLE == ROLE_Authority && bDodgeEnabled)
                    dodgeDir=firstDodgeDir;
            }
        }

        OldSteering=Steering;
    }

    if(oldDodgeDir != dodgeDir)
    {
        if(dodgeDir >= 0)
        {
            if(bOnGround && Level.TimeSeconds - JumpDelay >= LastJumpTime)
            {
                if(Level.NetMode != NM_DedicatedServer)
                {
                    ClientPlayForceFeedback(JumpForce);
                }

                LastJumpTime = Level.TimeSeconds;
                DodgeCountdown = DodgeDuration;
                SetAnimAction(DodgeAnims[dodgeDir]);
            }

        }

        oldDodgeDir=dodgeDir;
    }

    // when dodging remove some air control to mimick pawn dodging
    if(Driver != None && dodgeDir >= 0 && (Role == ROLE_Authority))
    {
        if(dodgeDir == 0)
            Throttle=1;
        else if(dodgeDir == 1)
            Throttle=-1;
        else if(dodgeDir == 3)
            Steering=-1;
        else if(dodgeDir == 2)
            Steering=1;

        KP = KarmaParams(KParams);
        KP.kMaxSpeed = MaxAirSpeed*DodgeAirSpeedMulti;
    }
}

simulated function KApplyForce(out vector Force, out vector Torque)
{
	local vector worldForward, worldBackward, worldRight, worldLeft;

	Super.KApplyForce(Force, Torque);

	worldForward = vect(1, 0, 0) >> Rotation;
	worldBackward = vect(-1, 0, 0) >> Rotation;
	worldRight = vect(0, 1, 0) >> Rotation;
	worldLeft = vect(0, -1, 0) >> Rotation;

	if (bDriving && JumpCountdown > 0.0)
	{
        Force += vect(0,0,1) * JumpForceMag;
        if(Throttle != 0 || Steering != 0)
        {
            //extra force to counter air control floating
            Force += vect(0,0,1) * JumpForceMag * 1.0;
        }

	}

    if (bDriving && DodgeCountdown > 0.0)
    {
        if(dodgeDir == 0)
            Force += (worldForward * DodgeForceMag);
        else if(dodgeDir == 1)
            Force += (worldBackward * DodgeForceMag);
        else if(dodgeDir == 3)
            Force += (worldRight * DodgeForceMag);
        else if(dodgeDir == 2)
            Force += (worldLeft * DodgeForceMag);

        Force += vect(0,0,1) * DodgeForceMag;
    }

    //counteract hover
    if(bDriving && !bOnGround)
    {
		Force += PhysicsVolume.Gravity * GravScaleAir;
        if(Throttle != 0 || Steering != 0)
        {
            //extra force to counter air control floating
            Force += PhysicsVolume.Gravity * GravScaleAirThrottle;
        }
    }
}

function PlayFiring(optional float rate, optional name channel)
{
    SetAnimAction('Biggun_Burst');
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);
    //todo
    //not sure these are necessary when content is embedded
}

simulated function UpdatePrecacheStaticMeshes()
{
	Super.UpdatePrecacheStaticMeshes();
    //todo
}

simulated function UpdatePrecacheMaterials()
{
	Super.UpdatePrecacheMaterials();
    //todo
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
    //lol
    if(Damage >= 100)
        PlayDirectionalHit(HitLocation);

    momentum *= 0.25;

    if(damageType == class'DamTypeSniperShot')
        Damage *= 3;

    if(damageType == class'DamTypeSniperHeadShot')
        Damage *= 6;

    if(damageType == class'DamTypeClassicSniper')
        Damage *= 3;

    if(damageType == class'DamTypeClassicHeadShot')
        Damage *= 6;


    super.TakeDamage(Damage, instigatedBy, hitLocation, momentum, damageType);
}

function UpdateTwist()
{
    local rotator r, r2, pcr;
    local int vp;
    local int YawCheck;

    r = Rotation;
    pcr = Controller.Rotation;
    vp = viewpitch;

    //YawCheck = 8192;
    YawCheck = 12000;
    
    pcr.Yaw = pcr.Yaw & 65535;
    
    if(pcr.Yaw > 32768)
        pcr.Yaw -= 65536;


    if(pcr.Yaw > YawCheck && r.Yaw < -YawCheck)
    {
        currentDir = 1; //debug
        pcr.Yaw -= 32768;
        r.Yaw += 32768;
    }
    else if(pcr.Yaw < -YawCheck && r.Yaw > YawCheck)
    {
        currentDir = -1; //debug
        pcr.Yaw += 32768;
        r.Yaw -= 32768;
    }
    else
    {
        currentDir = 0; //debug
    }

    if(pcr.Pitch > 32768)
        pcr.Pitch -= 65536;

    r.roll = (pcr.Pitch - vp)/4;
    r.Yaw = -(pcr.Yaw - r.Yaw)/3;
    r.pitch = 0;

    r2 = GetBoneRotation(RootBone);

    currentR = r; //debug
    SetBoneDirection(HeadBone, r, vect(0,0,0), 1.0, 0);
    if(bExtraTwist)
    {
        r.Yaw -= (Rotation.Yaw - r2.Yaw)/2;
    }
    SetBoneDirection(SpineBone1, r, vect(0,0,0), 1.0, 0);
    SetBoneDirection(SpineBone2, r, vect(0,0,0), 1.0, 0);
}

//make mech always vertical
function ForceUpright()
{
    local rotator r;
    r = Rotation;
    r.Pitch = 0;
    r.Roll = 0;
    SetRotation(r);
}

//update collision based on crouching (doesn't affect karma collision on the mesh)
function UpdateCollision()
{
    if(oldCollisionRise != Rise)
    {
        if(Rise < 0 && bOnGround)
        {
            SetCollisionSize(180,100);
        }
        else
        {
            SetCollisionSize(180,200);
        }

        oldCollisionRise = Rise;
    }
}

simulated event TeamChanged()
{
    Super.TeamChanged();
    if(Team == 0)
    {
        if(RedSkin != None)
            Skins[0]=RedSkin;

        if(RedSkinHead != None)
            Skins[1]=RedSkinHead;
    }
    else
    {
        if(BlueSkin != None)
            Skins[0]=BlueSkin;

        if(BlueSkinHead != None)
            Skins[1]=BlueSkinHead;
    };
}

function ServerPlayHorn(int HornIndex)
{
	if( (Level.TimeSeconds - LastHornTime > 3.0) && (HornIndex >= 0) && (HornIndex < HornSounds.Length) )
	{
		PlaySound( HornSounds[HornIndex],, 5.0*TransientSoundVolume,, 2000);
		LastHornTime = Level.TimeSeconds;

        ClientPlayHorn(HornIndex);
	}
}

simulated function ClientPlayHorn(int HornIndex)
{
    HornAnim = HornAnims[HornIndex];
    SetAnimAction(HornAnim);
}

event AnimEnd(int channel)
{
    local float frame, rate;
    local name seq;
    local int dir;
    GetAnimParams( channel, seq, frame, rate );
    if(IsHornAnim(seq))
    {
        SetAnimAction('Biggun_Burst');
    }
    else if(IsTakeOffSeq(seq))
    {
        dir = Get4WayDirection();
        SetAnimAction(AirAnims[dir]);
    }
    else if(IsDodgeSeq(seq))
    {
        dir = Get4WayDirection();
        SetAnimAction(AirAnims[dir]);
    }
    else if(IsHitSeq(seq))
    {
        bWaitForAnim=false;
    }
}

// only difference from default is to play horn louder
function PossessedBy(Controller C)
{
	local PlayerController PC;

	if ( bAutoTurret && (Controller != None) && ClassIsChildOf(Controller.Class, AutoTurretControllerClass) && !Controller.bDeleteMe )
	{
		Controller.Destroy();
		Controller = None;
	}

	super(Pawn).PossessedBy( C );

	// Stole another team's vehicle, so set Team to new owner's team
	if ( C.GetTeamNum() != Team )
	{
		//add stat tracking event/variable here?
		if ( Team != 255 && PlayerController(C) != None )
		{
			if( StolenAnnouncement != '' )
				PlayerController(C).PlayRewardAnnouncement(StolenAnnouncement, 1);

			if( StolenSound != None )
				//PlaySound( StolenSound,, 2.5*TransientSoundVolume,, 400);
				PlaySound( StolenSound,, 5.0*TransientSoundVolume,, 1200);
		}

		if ( C.GetTeamNum() != 255 )
			SetTeamNum( C.GetTeamNum() );
	}

	NetPriority = 3;
	NetUpdateFrequency = 100;
	ThrottleTime = Level.TimeSeconds;
	bSpawnProtected = false;

	PC = PlayerController(C);
	if ( PC != None )
		ClientKDriverEnter( PC );

	if ( ParentFactory != None && ( !bAutoTurret || !ClassIsChildOf(C.Class, AutoTurretControllerClass) ) )
		ParentFactory.VehiclePossessed( Self );		// Notify parent factory
}

simulated function Gib SpawnGiblet( class<Gib> GibClass, Vector Location, Rotator Rotation, float GibPerterbation, bool bFlaming, float scale )
{
    local Gib Giblet;
    local Vector Direction, Dummy;

    if( (GibClass == None) || class'GameInfo'.static.UseLowGore() )
        return None;

	Instigator = self;
    Giblet = Spawn( GibClass,,, Location, Rotation );
    if( Giblet == None )
        return None;
	Giblet.bFlaming = bFlaming;
	Giblet.SpawnTrail();

    GibPerterbation *= 32768.0;
    Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

    GetAxes( Rotation, Dummy, Dummy, Direction );

    Giblet.Velocity = Velocity + Normal(Direction) * (550 + 500 * FRand());
    Giblet.LifeSpan = Giblet.LifeSpan + 2 * FRand() - 1;
    Giblet.SetDrawScale(scale);

    return Giblet;
}

simulated event ClientVehicleExplosion(bool bFinal)
{
    local Coords bone;
    super.ClientVehicleExplosion(bFinal);
    bone = GetBoneCoords('Bip01 rthigh');
    SpawnGiblet(class'GibBotCalf', bone.Origin, Rotation, FRand(), FRand() < 0.5, 3.0);
    bone = GetBoneCoords('Bip01 Head');
    SpawnGiblet(class'GibBotHead', bone.Origin, Rotation, FRand(), FRand() < 0.5, 3.0);
    bone = GetBoneCoords('Bip01 Spine');
    SpawnGiblet(class'GibBotTorso', bone.Origin, Rotation, FRand(), FRand() < 0.5, 3.0);
    bone = GetBoneCoords('Bip01 rfarm');
    SpawnGiblet(class'GibBotForearm', bone.Origin, Rotation, FRand(), FRand() < 0.5, 3.0);
}

function Pawn CheckForHeadShot(vector loc, vector ray, float AdditionalScale)
{
     if(IsHeadShot(loc,ray,AdditionalScale))
     {
        return self;
     }

    return None;
}

//don't do any damage/sound/sparks as we scrape across the ground
event TakeImpactDamage(float AccelMag)
{
    /*
	local int Damage;

	Damage = int(AccelMag * ImpactDamageModifier());
	TakeDamage(Damage, Self, ImpactInfo.Pos, vect(0,0,0), class'DamTypeONSVehicle');
	//FIXME - Scale sound volume to damage amount
	if (ImpactDamageSounds.Length > 0)
		PlaySound(ImpactDamageSounds[Rand(ImpactDamageSounds.Length-1)],,TransientSoundVolume*2.5);

    if (Health < 0 && (Level.TimeSeconds - LastImpactExplosionTime) > TimeBetweenImpactExplosions)
    {
        VehicleExplosion(Normal(ImpactInfo.ImpactNorm), 0.5);
        LastImpactExplosionTime = Level.TimeSeconds;
    }

	if ( (Controller != None) && (KarmaBoostDest(Controller.MoveTarget) != None) && Controller.InLatentExecution(Controller.LATENT_MOVETOWARD) )
		Controller.MoveTimer = -1;
        */
}

simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    // no stupid roll
    if(Abs(PC.ShakeRot.Pitch) >= 16384)
    {
        PC.bEnableAmbientShake = false;
        PC.StopViewShaking();
        PC.ShakeOffset = vect(0,0,0);
        PC.ShakeRot = rot(0,0,0);
    }

    super.SpecialCalcBehindView(PC, ViewActor, CameraLocation, CameraRotation);
}

defaultproperties
{
    VehicleNameString="CSHoverMech"
    VehiclePositionString="in a CSHoverMech"
    Mesh=Mesh'CSMech.BotB'
	Health=2000
	HealthMax=2000

    animRate=0.6
    tweenTime=0.6
    bClientAnim=false

    CollisionRadius=180.0
    CollisionHeight=200.0
    DriverDamageMult=0.000000

    DrivePos=(X=-18.438,Y=0.0,Z=220.0)
	EntryPosition=(X=0,Y=0,Z=-340)
	EntryRadius=300.0

    FPCamPos=(X=140,Y=0,Z=220)
	TPCamLookat=(X=0,Y=0,Z=0)
	TPCamWorldOffset=(X=0,Y=0,Z=350)
	TPCamDistance=500
    bDrawDriverInTP=False
	bDrawMeshInFP=True
    SparkEffectClass=None

    Begin Object Class=KarmaParamsRBFull Name=KParams0
        KMaxSpeed=800
		KStartEnabled=True
		KFriction=0.5
		KLinearDamping=0
		KAngularDamping=0
		bKNonSphericalInertia=True
		KImpactThreshold=700
        bHighDetailOnly=False
        bClientOnly=False
		bKDoubleTickRate=True
		bKStayUpright=True
		bKAllowRotate=True
		KInertiaTensor(0)=3.0
		KInertiaTensor(1)=0.0
		KInertiaTensor(2)=0.0
		KInertiaTensor(3)=3.0
		KInertiaTensor(4)=0.0
		KInertiaTensor(5)=3.0
		KCOMOffset=(X=0.0,Y=0.0,Z=-10.0)
		bDestroyOnWorldPenetrate=True
		bDoSafetime=True
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'
    GroundSpeed=800
    MaxGroundSpeed=800
    MaxAirSpeed=1000

	DestroyedVehicleMesh=None
    DestructionEffectClass=class'CSMech.CSHoverMechVehicleDeath'
    bDisintegrateVehicle=false
    ExplosionDamage=100
    ExplosionRadius=660

    DestructionLinearMomentum=(Min=62000,Max=100000)
    DestructionAngularMomentum=(Min=25,Max=75)
    ImpactDamageMult=0.0
    ImpactDamageSounds=None

	RanOverDamageType=class'CSHoverMechDamTypeRoadkill'
	CrushedDamageType=class'CSHoverMechDamTypePancake'

	IdleSound=sound'CSMech.EngIdle2'
	StartUpSound=sound'CSMech.EngStart'
	ShutDownSound=sound'CSMech.EngStop'


	MaxPitchSpeed=800
	SoundVolume=255
	SoundRadius=512

	StartUpForce="MASStartUp"
	ShutDownForce="MASShutDown"

	bShowDamageOverlay=True

	bTurnInPlace=True
	bScriptedRise=True
	bHasAltFire=True
	bShowChargingBar=False
    RadarHudRange=20000

	MaxViewYaw=16000
	MaxViewPitch=16000

    ExitPositions(0)=(X=0,Y=300,Z=100)
    ExitPositions(1)=(X=0,Y=-300,Z=100)
	ExitPositions(2)=(X=350,Y=0,Z=100)
	ExitPositions(3)=(X=-350,Y=0,Z=100)
	ExitPositions(4)=(X=-350,Y=0,Z=-100)
	ExitPositions(5)=(X=350,Y=0,Z=-100)
	ExitPositions(6)=(X=0,Y=300,Z=-100)
	ExitPositions(7)=(X=0,Y=-300,Z=-100)

    //back row
	ThrusterOffsets(0)=(X=-140,Y=-150,Z=-310)
	ThrusterOffsets(1)=(X=-140,Y=-50,Z=-310)
	ThrusterOffsets(2)=(X=-140,Y=50,Z=-310)
	ThrusterOffsets(3)=(X=-140,Y=150,Z=-310)

	//front row
	ThrusterOffsets(4)=(X=90,Y=-150,Z=-310)
	ThrusterOffsets(5)=(X=90,Y=-50,Z=-310)
	ThrusterOffsets(6)=(X=90,Y=50,Z=-310)
	ThrusterOffsets(7)=(X=90,Y=150,Z=-310)

	HoverSoftness=0.0
	HoverPenScale=1.5
	HoverCheckDist=100

	UprightStiffness=2000
	UprightDamping=2000

	MaxThrustForce=1000
	LongDamping=10.0

	MaxStrafeForce=1000
    LatDamping=10.0

	TurnTorqueFactor=1000.0
	TurnTorqueMax=525.0
	TurnDamping=100.0
	MaxYawRate=100.0

	PitchTorqueFactor=200.0
	PitchTorqueMax=45.0
	PitchDamping=1000.0

	RollTorqueTurnFactor=450.0
	RollTorqueStrafeFactor=50.0
	RollTorqueMax=52.5
	RollDamping=1000.0
	StopThreshold=100

	VehicleMass=12.0

    JumpDuration=0.16
	JumpForceMag=2200.0
    GravScaleAir=0.7
    GravScaleAirThrottle=0.3
    JumpSound=sound'CSMech.jump'
    JumpForce="HoverBikeJump"
    JumpDelay=0.75
    DoubleJumpDelay=0.75

	DamagedEffectOffset=(X=50,Y=-25,Z=20)
	DamagedEffectScale=5.0

    bDriverHoldsFlag=false
	bCanCarryFlag=false
	FlagOffset=(Z=45.0)
	FlagBone='bip01 l hand'
	FlagRotation=(Yaw=32768)

	HornSounds(0)=sound'ONSVehicleSounds-S.Horn02'
	HornSounds(1)=sound'ONSVehicleSounds-S.La_Cucharacha_Horn'

	MeleeRange=-100.0
	ObjectiveGetOutDist=750.0
	bTraceWater=True
	MaxDesireability=0.6

    RootBone="Bip01"
    HeadBone="Bip01 Head"
    SpineBone1="Bip01 Spine1"
    SpineBone2="Bip01 Spine2"
    FireRootBone="Bip01 Spine"

    WalkAnims(0)=WalkF
    WalkAnims(1)=WalkB
    WalkAnims(2)=WalkL
    WalkAnims(3)=WalkR

    CrouchAnims(0)=CrouchF
    CrouchAnims(1)=CrouchB
    CrouchAnims(2)=CrouchL
    CrouchAnims(3)=CrouchR

    LandAnims(0)=JumpF_land
    LandAnims(1)=JumpB_land
    LandAnims(2)=JumpL_land
    LandAnims(3)=JumpR_land

    TakeoffAnims(0)=JumpF_Takeoff
    TakeoffAnims(1)=JumpB_Takeoff
    TakeoffAnims(2)=JumpL_Takeoff
    TakeoffAnims(3)=JumpR_Takeoff    

    AirAnims(0)=JumpF_Mid
    AirAnims(1)=JumpB_Mid
    AirAnims(2)=JumpL_Mid
    AirAnims(3)=JumpR_Mid

    HitAnims(0)=HitF
    HitAnims(1)=HitB
    HitAnims(2)=HitL
    HitAnims(3)=HitR

    DoubleJumpAnims(0)=DoubleJumpF
    DoubleJumpAnims(1)=DoubleJumpB
    DoubleJumpAnims(2)=DoubleJumpL
    DoubleJumpAnims(3)=DoubleJumpR

    DodgeAnims(0)=WallDodgeF
    DodgeAnims(1)=WallDodgeB
    DodgeAnims(2)=WallDodgeL
    DodgeAnims(3)=WallDodgeR

    bCanCrouch=true
    bCanStrafe=true
    bDoTorsoTwist=true
    bExtraTwist=true

    GroundContact=1.0
    bOnGround=true
    FootStepSound=Sound'CSMech.FootStep'
    TeamChangedSound=Sound'CSMech.yourstocommand'
    //StolenAnnouncement=Hijacked
	//StolenSound=sound'ONSVehicleSounds-S.CarAlarm01'
    StolenAnnouncement=None
    StolenSound=Sound'CSMech.yourstocommand'
    bDebug=false
    HornAnims(0)=gesture_cheer
    HornAnims(1)=pthrust

    HeadScale=4.5
    EyeHeight=200
    BaseEyeHeight=200

    doubleTapThreshold=0.25
    DodgeDuration=0.1
	DodgeForceMag=2000.0
    DodgeAirSpeedMulti=1.5
    dodgeDir=-1
    OldSteering=-1
    OldThrottle=-1
    bDodgeEnabled=false
}