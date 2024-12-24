//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CSTrickboard extends ONSHoverCraft
    placeable;                                          
                                                                                             
#exec OBJ LOAD FILE=..\Animations\ONSVehicles-A.ukx
#exec OBJ LOAD FILE=..\Sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=..\textures\EpicParticles.utx
#exec OBJ LOAD FILE=..\StaticMeshes\ONSWeapons-SM.usx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx
#exec OBJ LOAD FILE=AS_Vehicles_TX.utx

#exec OBJ LOAD FILE=Animations\CSTrickboard-A.ukx PACKAGE=CSTrickboard
#exec OBJ LOAD FILE=Sounds\CSTrickboardSounds-S.uax PACKAGE=CSTrickboard
#exec OBJ LOAD FILE=StaticMeshes\CSTrickboard-SM.usx PACKAGE=CSTrickboard
#exec OBJ LOAD FILE=Textures\CSTrickboardMaterials.utx PACKAGE=CSTrickboard

#exec AUDIO IMPORT FILE="Sounds\kickflip1.wav" PACKAGE=CSTrickboard
#exec AUDIO IMPORT FILE="Sounds\kickflip2.wav" PACKAGE=CSTrickboard
#exec AUDIO IMPORT FILE="Sounds\spin1.wav" PACKAGE=CSTrickboard
#exec AUDIO IMPORT FILE="Sounds\spin2.wav" PACKAGE=CSTrickboard
#exec AUDIO IMPORT FILE="Sounds\Descend.wav" PACKAGE=CSTrickboard

var() float MaxPitchSpeed;

var() float JumpDuration;
var() float JumpDuration0;                     // This value never changes
var() float	JumpForceMag;
var float JumpCountdown;
var float JumpDelay, LastJumpTime;

var() float DuckDuration;
var() float DuckForceMag;
var float DuckCountdown;

var() array<vector>	BikeDustOffset;
var() float	BikeDustTraceDistance;

var() sound JumpSound;
var() sound DuckSound;

// Force Feedback
var() string JumpForce;

var() float grappleDistToStop;
var() float grappleFscale;
var() float grappleMaxForceFactor;

var	array<CSTrickboardDust>	BikeDust;
var	array<vector> BikeDustLastNormal;

var	bool DoBikeJump;
var	bool OldDoBikeJump;

var	bool DoBikeDuck;
var	bool OldDoBikeDuck;
var bool bHoldingDuck;

// Variables below by gel
var color dustColor;
var float spinAttack;

var bool DoSpinAttack, OldDoSpinAttack;

var() array<vector>	BikeDustOffsetTemp;
var int jumpMult;       // Multiplier for the jump (int b/c i don't know how to compare floats accurately)
var bool bDuckReleased;
var bool bPlayDuckSound;

// Bone Animation
var float legRotR;
var float armRotR;
var bool blegDone;
var float legRotRTemp;
var bool barmDone;
var float armRotRTemp;
var float bodyLocR;
var float bodyLocRTemp;
var float bodyVel;

var float superJumpCount;

// double tap for boost
var float lastAForward;
var float lastForwardPress, SecondForwardPress;
//Boost functionality
var bool bBoost;
var float BoostForce;
var float BoostTime;
var Sound BoostSound, BoostReadySound;
var float BoostRechargeTime;
var float BoostRechargeCounter;
var float BoostFOV;
var float BoostDoubleTapThreshold;
var bool  bAfterburnersOn;

var int Links;
var bool bLinking;							// True if we're linking a vehicle/node/player
var bool bBotHealing;
var bool bBeaming;							// True if utilizing alt-fire

var CSTrickboardBeamEffect Beam;
var HudCTeamDeathMatch OurHud;

var Pawn ServerLastDriver, ClientLastDriver;
var CSTrickboardCollision PawnCollision;

enum ETimerFunc
{
    ETimer_None,
    ETimer_Boosting,
    ETimer_PostAttach
};

var ETimerFunc TimerFunc;
var float TimeStep, TotalTime;
var int TickCount;

var float KickflipDamage;
var float KickflipMomentum;
var float KickflipRadius;

var Sound kickflipSounds[2];
var Sound spinSounds[2];

var int DisabledTickCount;

////////////////////////////////////////////////////

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		DoBikeJump;

    unreliable if (Role == ROLE_Authority && bNetDirty)
        Links, bLinking, Beam, bBeaming;    

    reliable if (Role==ROLE_Authority)
        bBoost,  BoostRechargeCounter;

    reliable if (Role<ROLE_Authority)
        ServerBoost;            

    reliable if (Role==ROLE_Authority)
        DoSpinAttack;

    reliable if (Role==ROLE_Authority)
        ServerLastDriver;
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    BoostRechargeCounter=BoostRechargeTime;
}

Function RawInput(float DeltaTime,
                            float aBaseX, float aBaseY, float aBaseZ, float aMouseX, float aMouseY,
                            float aForward, float aTurn, float aStrafe, float aUp, float aLookUp)
{
    if (aForward > 0 && lastAForward <= 0)
    {
        if(aForward > 0)
        {
            SecondForwardPress=lastForwardPress;
            lastForwardPress=Level.TimeSeconds;
        }

        if(aForward > 0 && (lastForwardPress - SecondForwardPress) < BoostDoubleTapThreshold)
        {
            //double forward press
            if(BoostRechargeCounter>=BoostRechargeTime)
            {
                Boost();
            }
        }
    }
    lastAForward=aForward;
    super.RawInput(DeltaTime, aBaseX, aBaseY, aBaseZ, aMouseX, aMouseY, aForward, aTurn, aStrafe, aUp, aLookUp);
}


function Boost()
{
	if (bBoost)
	{
	  PlaySound(BoostReadySound, SLOT_Misc, 128,,,160);
	}

	if (!bBoost)
	{
        BoostRechargeCounter=0;
        PlaySound(BoostSound, SLOT_Misc, 128,,,1.0); 
		ServerBoost();
	}
}

simulated function ServerBoost()
{
    BoostRechargeCounter=0;
    bBoost=true;
}

simulated function EnableAfterburners(bool bEnable)
{
    bAfterburnersOn = bEnable;
}

simulated event Timer()
{
    // there's only one timer func so switch based on need
    switch(TimerFunc)
    {
        case ETimer_Boosting:
            // when boost time exceeds time limit, turn it off
            bBoost = false;
            EnableAfterburners(bBoost);
            break;

        case ETimer_PostAttach:
            if(Driver != None)
            {
                // When bDrawDriverInTP is true, cull get set to 5000
                // but for hoverboard we don't want the driver to disappear beyond 5000
                Driver.CullDistance = 0;

                // after calling attach driver, StartDriving calls 
                // LoopAnim() with the 'Driving' animation, so in this timer func
                // we set to boarding animation instead
                // it's not a real animation so need to call it here
                SetDriverPositionBoarding(Driver);
            }
            break;
    }
}

simulated function BoostTick(float DT)
{
    //If bAfterburnersOn and boost state don't agree
    if (bBoost != bAfterburnersOn)
    {
        // it means we need to change the state of the vehicle (bAfterburnersOn)
        // to match the desired state (bBoost)
        EnableAfterburners(bBoost); // show/hide afterburner smoke

        // if we just enabled afterburners, set the timer
        // to turn them off after set time has expired
        if (bBoost)
        {
            TimerFunc = ETimer_Boosting;
            SetTimer(BoostTime, false);
        }
    }

    if (Role == ROLE_Authority)
    {
        // Afterburners recharge after the change in time exceeds the specified charge duration
        if(BoostRechargeCounter<BoostRechargeTime)
        {
            BoostRechargeCounter+=DT;
        }

        if (BoostRechargeCounter > BoostRechargeTime)
        {
            BoostRechargeCounter = BoostRechargeTime;
            if( PlayerController(Controller) != None)
            {
                PlayerController(Controller).ClientPlaySound(BoostReadySound,,,SLOT_Misc);
            }
        }
    }
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

function VehicleFire(bool bWasAltFire)
{
        if (!bWasAltFire)
        {
            // Primary Fire
            bWeaponIsFiring=true;
        }
        else 
        {
            // Alt-Fire
            if (Role == ROLE_Authority)
                DoSpinAttack = true;
        }
}

simulated function Destroyed()
{
	local int i;

	if (Level.NetMode != NM_DedicatedServer)
	{
		for (i = 0; i < BikeDust.Length; i++)
			BikeDust[i].Destroy();

		BikeDust.Length = 0;
	}

	Super.Destroyed();
}

simulated function DestroyAppearance()
{
	local int i;

	if (Level.NetMode != NM_DedicatedServer)
	{
		for (i = 0; i < BikeDust.Length; i++)
			BikeDust[i].Destroy();

		BikeDust.Length = 0;
	}

	Super.DestroyAppearance();
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	Rise = 1;
    ServerPlayHorn(1);
    Driver.PlayAnim('JumpL_Mid',,1.0);

	return true;
}

function ChooseFireAt(Actor A)
{
	if (Pawn(A) != None && Vehicle(A) == None && VSize(A.Location - Location) < 1500 && Controller.LineOfSightTo(A))
	{
		if (!bWeaponIsAltFiring)
			AltFire(0);
	}
	else if (bWeaponIsAltFiring)
		VehicleCeaseFire(true);

    //TODO bot stuff for grapple
	//Fire(0);
}

simulated event DrivingStatusChanged()
{
	local int i;

    // override default behavior here
    // normally tick was disabled if not driving but we need tick
    // to continue some to fix twisted body
    if(bDriving)
        Enable('Tick');

    if (bDriving && Level.NetMode != NM_DedicatedServer && BikeDust.Length == 0 && !bDropDetail)
	{
		BikeDust.Length = BikeDustOffset.Length;
		BikeDustLastNormal.Length = BikeDustOffset.Length;

		for(i=0; i<BikeDustOffset.Length; i++)
    		if (BikeDust[i] == None)
    		{
    			BikeDust[i] = spawn( class'CSTrickboardDust', self,, Location + (BikeDustOffset[i] >> Rotation) );
                        dustColor.R = 230;
                        dustColor.G = 200;
                        dustColor.B = 230;

    			BikeDust[i].SetDustColor( dustColor );
    			BikeDustLastNormal[i] = vect(0,0,1);
    		}
	}
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
    	{
    		for(i=0; i<BikeDust.Length; i++)
                BikeDust[i].Destroy();

            BikeDust.Length = 0;
        }
        JumpCountDown = 0.0;
    }
}

simulated function SetDriverPositionBoarding(Pawn P)
{
    if(P == None)
        return;

    P.SetBoneRotation('Bip01 Neck', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 Neck1', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy07', rot(0, 0, 0), 1.0);

    P.SetBoneRotation('Bip01 L Clavicle', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy03', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Finger1', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Finger11', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Finger12', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy04', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bone_L_shoulder', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy08', rot(0, 0, 0), 1.0);

    P.SetBoneRotation('Bip01 R Clavicle', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy01', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Finger1', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Finger11', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Finger12', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy02', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bone_R_shoulder', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy09', rot(0, 0, 0), 1.0);

    P.SetBoneRotation('Dummy06', rot(0, 0, 0), 1);
    P.SetBoneRotation('Dummy05', rot(0, 0, 0), 1);

    // Pelvis --------------------------------------------------
    P.SetBoneRotation('Bip01', rot(-1000, 13000, 0), 1.0);
    P.SetBoneRotation('Bip01 Pelvis', rot(0, 2000, 0), 1.0);

    // Head ----------------------------------------------------
    P.SetBoneRotation('Bip01 Head', rot(-3000, 0, -8000), 1.0);

    // Spine ---------------------------------------------------
    P.SetBoneRotation('Bip01 Spine', rot(0, 6000, -1000), 1.0);
    P.SetBoneRotation('Bip01 Spine1', rot(0, 0, -1000), 1.0);
    P.SetBoneRotation('Bip01 Spine2', rot(0, 0, -1000), 1.0);

    // Arms ----------------------------------------------------
    P.SetBoneRotation('Bip01 L UpperArm', rot(-6000, 9000, 0), 1.0);
    P.SetBoneRotation('Bip01 R UpperArm', rot(6000, 9000, 0), 1.0);
    P.SetBoneRotation('Bip01 L Forearm', rot(-3000, -4000, 0), 1.0);
    P.SetBoneRotation('Bip01 R Forearm', rot(3000, -4000, 0), 1.0);
    P.SetBoneRotation('Bip01 L Hand', rot(0, -3500, 0), 1.0);
    P.SetBoneRotation('Bip01 R Hand', rot(0, -3500, 0), 1.0);

    // Fingers -------------------------------------------------
    P.SetBoneRotation('Bip01 L Finger0', rot(0, -10000, 0), 1.0);
    P.SetBoneRotation('Bip01 L Finger01', rot(0, -10000, 0), 1.0);
    P.SetBoneRotation('Bip01 L Finger02', rot(0, -10000, 0), 1.0);

    P.SetBoneRotation('Bip01 R Finger0', rot(0, -10000, 0), 1.0);
    P.SetBoneRotation('Bip01 R Finger01', rot(0, -10000, 0), 1.0);
    P.SetBoneRotation('Bip01 R Finger02', rot(0, -10000, 0), 1.0);

    // Legs ----------------------------------------------------
    P.SetBoneRotation('Bip01 L Thigh', rot(8500, -5200, -3000), 1.0);
    P.SetBoneRotation('Bip01 R Thigh', rot(-8500, -5200, -3000), 1.0);
    P.SetBoneRotation('Bip01 L Calf', rot(0, -10000, -8000), 1.0);
    P.SetBoneRotation('Bip01 R Calf', rot(0, -10000, 8000), 1.0);
    P.SetBoneRotation('Bip01 L Foot', rot(-6000, 15000, 0), 1.0);
    P.SetBoneRotation('Bip01 R Foot', rot(5000, 15000, 0), 1.0);
    P.SetBoneRotation('Bip01 L Toe0', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Toe0', rot(0, 0, 0), 1.0);
}

simulated function SetDriverPositionOriginal(Pawn P) 
{
    // After the player leaves the vehicle, resets its additional bone rotations or else he'll be all twisted
    // Simply resets everything
	if (P == None)
		return;

    P.SetBoneRotation('Bip01 Neck', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 Neck1', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy07', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Clavicle', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy03', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Finger1', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Finger11', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Finger12', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy04', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bone_L_shoulder', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy08', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Clavicle', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy01', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Finger1', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Finger11', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Finger12', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy02', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bone_R_shoulder', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy09', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy06', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Dummy05', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 Pelvis', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 Head', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 Spine', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 Spine1', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 Spine2', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L UpperArm', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R UpperArm', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Forearm', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Forearm', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Hand', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Hand', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Finger0', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Finger01', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Finger02', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Finger0', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Finger01', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Finger02', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Thigh', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Thigh', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Calf', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Calf', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Foot', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Foot', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 L Toe0', rot(0, 0, 0), 1.0);
    P.SetBoneRotation('Bip01 R Toe0', rot(0, 0, 0), 1.0);
}

function KDriverEnter (Pawn P) 
{
    P.ReceiveLocalizedMessage(class'CSTrickboard.CSTrickboardEnterMessage', 0);
    Super.KDriverEnter(P); 
    SetDriverPositionBoarding(P); 
    ServerLastDriver = None;
    spinAttack = 0;
    BoostRechargeCounter = 0;
    DoSpinAttack = true; // do a kickflip on enter
    OldDoSpinAttack = false;
    BikeDustOffsetTemp[0] = BikeDustOffset[0];
    BikeDustOffsetTemp[1] = BikeDustOffset[1];
}

simulated function ClientKDriverEnter(PlayerController pc)
{
    super.ClientKDriverEnter(pc);
    if(pc != None && pc.Pawn != None)
        SetDriverPositionBoarding(pc.Pawn); 
}

function bool KDriverLeave (bool bForceLeave) 
{
    local Pawn tempDriver;
    tempDriver = Driver; // use variable to hold Driver because Driver is destroyed after KDriverLeave

    self.SetBoneRotation('root', rot(0, 0, 0), 1.0);
    spinAttack = 0;
    DoSpinAttack = false;
    OldDoSpinAttack = false;    
    BikeDustOffset[0] = BikeDustOffsetTemp[0];
    BikeDustOffset[1] = BikeDustOffsetTemp[1];

    // can't exit if there is something colliding with
    if(PawnCollision != None)
        PawnCollision.SetCollision(false,false);

    if (Super.KDriverLeave(bForceLeave)) 
    {
        ServerLastDriver = tempDriver;
        SetDriverPositionOriginal(tempDriver); // resets the position to the original position only if he could leave
        return true;
    } 
    else 
    {
        // exit failed, restore collision
        if(PawnCollision != None)
            PawnCollision.SetCollision(true,true);

        return false;
    }
}

// called for playercontrollers
simulated function ClientKDriverLeave(PlayerController pc)
{
    Super.ClientKDriverLeave(pc);

    self.SetBoneRotation('root', rot(0, 0, 0), 1.0);
    // the pc.pawn was swapped with the vehicle pawn (pc controls vehicle still)
    // player pawn doesn't get restored until unpossessed called later
    if(pc != none && Vehicle(pc.Pawn) != None)
        SetDriverPositionOriginal(Vehicle(pc.Pawn).Driver); // resets the position to the original position only if he could leave
}

// called for other controllers (bot etc)
simulated function ClientClearController()
{
    super.ClientClearController();
    self.SetBoneRotation('root', rot(0, 0, 0), 1.0);
    if(Controller != none && Controller.Pawn != None)
        SetDriverPositionOriginal(Controller.Pawn);
}

simulated function PlayCustomAnim (string animName, int currFrame)
{
    local rotator spinRot, bodyRot, legRot, armRot;
    local vector bodyLoc;
    local float    gravity;

    if(Driver == None)
        return;

    gravity = -timestep;

    // Super Jump (from crouch)
    if (animName == "Jump2" && currFrame > 0) 
    {
        spinRot.Pitch = bodyLocRTemp * currFrame;
        spinRot.Roll = 0;
        spinRot.Yaw = 0;
        self.SetBoneRotation('root', spinRot, 1.0);

        bodyVel += gravity;
        bodyLocRTemp += bodyVel;
        bodyLoc.X = 0;
        bodyLoc.Y = 0;
        bodyLoc.Z = BodyLocRTemp * timestep;
        Driver.SetBoneLocation('Bip01', bodyLoc, 1.0);

        bodyRot.Pitch = 0;
        bodyRot.Yaw = 13000 + bodyLocRTemp * currFrame;
        bodyRot.Roll = bodyLocRTemp * currFrame;

        // Move arms/legs
        if (!blegDone) 
        {
            legRotRTemp += 10 * timestep;
            if (legRotRTemp > legRotR) 
            {
                legRotRTemp = legRotR;
                blegDone = true;
            }
        }
        else 
        {
            legRotRTemp += -5 * timestep;
        }

        if (!barmDone) 
        {
            armRotRTemp += 5 * timestep;
            if (armRotRTemp > armRotR) 
            {
                armRotRTemp = armRotR;
                barmDone = true;
            }
        }
        else 
        {
            armRotRTemp += -3 * timestep;
        }

        //Legs
        legRot.Yaw = -5200 + legRotRTemp * (currFrame/2);
        legRot.Roll = -3000;
        legRot.Pitch = 8500 + legRotRTemp * (currFrame/3);
        Driver.SetBoneRotation('Bip01 L Thigh', legRot, 1.0);

        legRot.Yaw = -5200 + legRotRTemp * currFrame;
        legRot.Pitch = -8500;
        Driver.SetBoneRotation('Bip01 R Thigh', legRot, 1.0);

        legRot.Yaw = -10000 + legRotRTemp * currFrame/2;
        legRot.Roll = -8000;
        legRot.Pitch = 0;

        legRot.Yaw = -10000 + legRotRTemp * currFrame/4;
        legRot.Roll = 8000;
        Driver.SetBoneRotation('Bip01 R Calf', legRot, 1.0);

        //Arms
        armRot.Yaw = -4000 + armRotRTemp * currFrame;
        armRot.Roll = 0;
        armRot.Pitch = -3000 + armRotRTemp * currFrame;
        Driver.SetBoneRotation('Bip01 L Forearm', armRot, 1.0);
        armRot.Pitch = 3000 + armRotRTemp * currFrame;
        Driver.SetBoneRotation('Bip01 R Forearm', armRot, 1.0);
        Driver.SetBoneRotation('Bip01 L UpperArm', armRot, 1.0);
        Driver.SetBoneRotation('Bip01 R UpperArm', armRot, 1.0);
    }
}

simulated function Tick(float DeltaTime)
{
    local float tempYaw, tempRoll; // for custom anim
    local rotator rott; // for custom anim

    local float EnginePitch, HitDist;
	local int i;
	local vector TraceStart, TraceEnd, HitLocation, HitNormal;
	local actor HitActor;
	local Emitter JumpEffect;

   local rotator spinRot, bodyRot, legRot, armRot;
   local vector bodyLoc;
   local float    gravity;

   // DT can vary, get the average DT over 10000 ticks
   TotalTime += DeltaTime;
   timestep = TotalTime / TickCount;
   TickCount += 1;
   if(TickCount > 10000)
   {
        TickCount = 1;
        TotalTime = timestep;
   }

   // convert to 60fps assumption made in animation values below
   timestep = timestep / 0.01666;

   gravity = -timestep;

    Super.Tick(DeltaTime);

    // *** Custom animations ***
    if ( Level.NetMode != NM_DedicatedServer && !bDropDetail && bAdjustDriversHead && bDrawDriverinTP && (Driver != None) && (Driver.HeadBone != '')) 
    {
        tempYaw = (DriverViewYaw - Driver.Rotation.Yaw) & 65535;
        tempRoll = Driver.Rotation.Roll * -1;
        if (tempYaw > 32767) tempYaw = (65535 - tempYaw)*-1;

        rott.Pitch = -3000;
        rott.Roll = (tempYaw/6)-8000; // -8000;
        rott.Yaw = 0;
        Driver.SetBoneRotation('Bip01 Head', rott, 1.0);
        rott.Pitch = 0;
        rott.Roll = (tempYaw/6)-1000;
        rott.Yaw = (tempRoll/2) + 6000;
        Driver.SetBoneRotation('Bip01 Spine', rott, 1.0);
        rott.Pitch = 0;
        rott.Roll = (tempYaw/6)-1000;
        rott.Yaw = tempRoll/2;
        Driver.SetBoneRotation('Bip01 Spine1', rott, 1.0);
        rott.Pitch = 0;
        rott.Roll = (tempYaw/6)-1000;
        rott.Yaw = tempRoll/2;
        Driver.SetBoneRotation('Bip01 Spine2', rott, 1.0);

        rott.Pitch = 0;
        rott.Roll = tempYaw/6;
        rott.Yaw = (tempYaw/6)*-1;
        Driver.SetBoneRotation('Bip01 L Clavicle', rott, 1.0);
        rott.Pitch = 0;
        rott.Roll = tempYaw/6;
        rott.Yaw = tempYaw/6;
        Driver.SetBoneRotation('Bip01 R Clavicle', rott, 1.0);

        rott.Pitch = -6000;
        rott.Roll = 0;
        rott.Yaw = 9000-tempRoll;
        Driver.SetBoneRotation('Bip01 L UpperArm', rott, 1.0);
        rott.Pitch = 6000;
        rott.Roll = 0;
        rott.Yaw = 9000-tempRoll;
        Driver.SetBoneRotation('Bip01 R UpperArm', rott, 1.0);

    }

    EnginePitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 64.0;
    SoundPitch = FClamp(EnginePitch, 64, 128);

    JumpCountdown -= DeltaTime;
    CheckJumpDuck();

	if(DoBikeJump != OldDoBikeJump)
	{
		JumpCountdown = JumpDuration;
        OldDoBikeJump = DoBikeJump;
        if (Controller != Level.GetLocalPlayerController())
        {
            JumpEffect = Spawn(class'CSTrickboardJumpEffect');
            JumpEffect.SetBase(Self);
            ClientPlayForceFeedback(JumpForce);
        }
        JumpDuration = JumpDuration0;       // Set back to regular value
	}
	if (superJumpCount > 0) 
    {
	    superJumpCount += -8 * timestep;
	    PlayCustomAnim("Jump2", superJumpCount);
	    if (superJumpCount <= 0) 
        {
            SetDriverPositionBoarding(Driver);
            bodyLoc.X = 0;
            bodyLoc.Y = 0;
            bodyLoc.Z = 0;
            if(Driver != None)
                Driver.SetBoneLocation('Bip01', bodyLoc, 1.0);
            self.SetBoneRotation('root', rot(0, 0, 0), 1.0);
     	}
	}

	if(Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
		for(i=0; i<BikeDust.Length; i++)
		{
			BikeDust[i].bDustActive = false;

			TraceStart = Location + (BikeDustOffset[i] >> Rotation);
			TraceEnd = TraceStart - ( BikeDustTraceDistance * vect(0,0,1) );

			HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, True);

			if(HitActor == None)
			{
				BikeDust[i].UpdateHoverDust(false, 0, false);
			}
			else
			{
				HitDist = VSize(HitLocation - TraceStart);

				BikeDust[i].SetLocation( HitLocation + 10*HitNormal);

				BikeDustLastNormal[i] = Normal( 3*BikeDustLastNormal[i] + HitNormal );
				BikeDust[i].SetRotation( Rotator(BikeDustLastNormal[i]) );
                if (spinAttack > 0) 
                {
                    BikeDust[i].UpdateHoverDust(true, HitDist/BikeDustTraceDistance, true);
                }
                else 
                {
                    BikeDust[i].UpdateHoverDust(true, HitDist/BikeDustTraceDistance, false);
                }

				// If dust is just turning on, set OldLocation to current Location to avoid spawn interpolation.
				if(!BikeDust[i].bDustActive)
					BikeDust[i].OldLocation = BikeDust[i].Location;

				BikeDust[i].bDustActive = true;
			}
		}

	}


    if(DoSpinAttack != OldDoSpinAttack)
    {
        OldDoSpinAttack = DoSpinAttack;
        if(DoSpinAttack) 
        {
            if(spinAttack <= 0)
            {
                spinAttack = 180;
                // Anim
                bodyLocR = 40;
                bodyLocRTemp = 0;
                bodyVel = 12;
                legRotR = -30;
                armRotR = -20;
                blegDone = false;
                barmDone = false;
                legRotRTemp = 0;
                armRotRTemp = 0;
                SpinHurtRadius();
            }
        }
    }

    // Spin Attack
    if (spinAttack > 0) 
    {
        spinAttack -= 8 * timestep;

        spinRot.Pitch = 0;
        spinRot.Roll = spinAttack * -175;           // Kickflip
        spinRot.Yaw = spinAttack * -700;
        self.SetBoneRotation('root', spinRot, 1.0);

        BikeDustOffset[0].X = 0.000000;
        BikeDustOffset[0].Z = 10.000000;
        BikeDustOffset[1].X = 0.000000;
        BikeDustOffset[1].Z = 30.000000;

        bodyVel += gravity;
        bodyLocRTemp += bodyVel;

        bodyLoc.X = 0;
        bodyLoc.Y = 0;
        bodyLoc.Z = BodyLocRTemp * timestep;
        if(Driver != None)
            Driver.SetBoneLocation('Bip01', bodyLoc, 1.0);

        bodyRot.Pitch = 0;
        bodyRot.Yaw = 13000 + bodyLocRTemp * spinAttack;
        bodyRot.Roll = bodyLocRTemp * spinAttack;

        // Move arms/legs
        if (!blegDone) 
        {
            legRotRTemp += 10 * timestep;
            if (legRotRTemp > legRotR) 
            {
                legRotRTemp = legRotR;
                blegDone = true;
            }
        }
        else 
        {
            legRotRTemp += -5 * timestep;
        }

        if (!barmDone) 
        {
            armRotRTemp += 5 * timestep;
            if (armRotRTemp > armRotR) 
            {
                armRotRTemp = armRotR;
                barmDone = true;
            }
        }
        else 
        {
            armRotRTemp += -3 * timestep;
        }


        if(Driver != None)
        {
            //Legs
            legRot.Yaw = -5200 - legRotRTemp * spinAttack;
            legRot.Roll = -3000;
            legRot.Pitch = 8500;
            Driver.SetBoneRotation('Bip01 L Thigh', legRot, 1.0);

            legRot.Yaw = -5200 + legRotRTemp * spinAttack;
            legRot.Pitch = -8500;
            Driver.SetBoneRotation('Bip01 R Thigh', legRot, 1.0);

            legRot.Yaw = -10000 + legRotRTemp * spinAttack;
            legRot.Roll = -8000;
            legRot.Pitch = 0;

            legRot.Roll = 8000;
            Driver.SetBoneRotation('Bip01 R Calf', legRot, 1.0);

            //Arms
            armRot.Yaw = -4000 + armRotRTemp * spinAttack;
            armRot.Roll = 0;
            armRot.Pitch = -3000;
            Driver.SetBoneRotation('Bip01 L Forearm', armRot, 1.0);
            armRot.Pitch = 3000;
            Driver.SetBoneRotation('Bip01 R Forearm', armRot, 1.0);
        }

        if (spinAttack <= 0) 
        {
            self.SetBoneRotation('root', rot(0, 0, 0), 1.0);
            spinAttack = 0;
            DoSpinAttack = false;
            OldDoSpinAttack = false;
            bodyVel = 0;
            bodyLoc.X = 0;
            bodyLoc.Y = 0;
            bodyLoc.Z = 0;
            if(Driver != None)
            {
                Driver.SetBoneRotation('Bip01 L Thigh', rot(8500, -5200, -3000), 0.0);
                Driver.SetBoneRotation('Bip01 R Thigh', rot(-8500, -5200, -3000), 0.0);
                Driver.SetBoneRotation('Bip01 L Calf', rot(0, -10000, -8000), 0.0);
                Driver.SetBoneRotation('Bip01 R Calf', rot(0, -10000, 8000), 1.0);
                Driver.SetBoneRotation('Bip01 L Forearm', rot(-3000, -4000, 0), 1.0);
                Driver.SetBoneRotation('Bip01 R Forearm', rot(3000, -4000, 0), 1.0);
                Driver.SetBoneLocation('Bip01', bodyLoc, 1.0);
                Driver.SetBoneRotation('Bip01', rot(-1000, 13000, 0), 1.0);
            }
            if(BikeDustOffsetTemp.Length > 1)
            {
                BikeDustOffset[0] = BikeDustOffsetTemp[0];
                BikeDustOffset[1] = BikeDustOffsetTemp[1];
            }
        }
    }

    // do tick logic related to boosting
    BoostTick(DeltaTime);

    // on clients, if driver exited, reset the driver bones
    // this is needed here because rep functions only get called
    // on net owners.  This is for everybody not the net owner
    if(Role < ROLE_Authority && ServerLastDriver != ClientLastDriver)
    {
        if(ServerLastDriver != None)
        {
            SetDriverPositionOriginal(ServerLastDriver);
        }

        ClientLastDriver = ServerLastDriver;
    }

    // pawncollision can get moved sometimes
    // force it to always be centered on board
    if(PawnCollision != None)
        PawnCollision.SetRelativeLocation(vect(0,0,44));

    // normally tick gets disabled if bDriving changes to false
    // in DrivingStatusChanged() function.  
    // So instead we leave tick going, count up to 60 ticks, then 
    // finally disable tick.  This allows the tick logic to work 
    // which untwists the client pawns
    if(bDriving)
        DisabledTickCount=0;
    else
    {
        DisabledTickCount++;
        if(DisabledTickCount > 60)
            Disable('Tick');
    }
}

function VehicleCeaseFire(bool bWasAltFire)
{
    Super.VehicleCeaseFire(bWasAltFire);

    if (bWasAltFire)
        bHoldingDuck = False;
}

simulated function float ChargeBar()
{
    // Clamp to 0.999 so charge bar doesn't blink when maxed
	if (Level.TimeSeconds - JumpDelay < LastJumpTime)
        return (FMin((Level.TimeSeconds - LastJumpTime) / JumpDelay, 0.999));
    else
		return 0.999;
}

simulated function CheckJumpDuck()
{
	local KarmaParams KP;
	local Emitter JumpEffect, DuckEffect;
	local bool bOnGround;
	local int i;
	local rotator legRot;
    local vector bodyLoc;

	KP = KarmaParams(KParams);

	// Can only start a jump when in contact with the ground.
	bOnGround = false;
	for(i=0; i<KP.Repulsors.Length; i++)
	{
		if( KP.Repulsors[i] != None && KP.Repulsors[i].bRepulsorInContact )
			bOnGround = true;
	}

	// If we are on the ground, and press Rise, and we not currently in the middle of a jump, start a new one.
    if (JumpCountdown <= 0.0 && Rise > 0 && bOnGround && !bHoldingDuck && Level.TimeSeconds - JumpDelay >= LastJumpTime)
    {
        PlaySound(JumpSound,,1.0);

        if (Role == ROLE_Authority)
    	   DoBikeJump = !DoBikeJump;

        if(Level.NetMode != NM_DedicatedServer)
        {
            JumpEffect = Spawn(class'CSTrickboardJumpEffect');
            JumpEffect.SetBase(Self);
            ClientPlayForceFeedback(JumpForce);
        }

    	if ( AIController(Controller) != None )
    		Rise = 0;

    	LastJumpTime = Level.TimeSeconds;
    }
    else if (Rise < 0 && bOnGround) 
    {
        // gel: this makes the Board jump higher the longer you hold crouch
        if (!bHoldingDuck) 
        {
            bHoldingDuck = true;
        }
        bDuckReleased = false;
        bPlayDuckSound = false;
        //jumpMult += 15;
        jumpMult += 45 * timestep;
        if (jumpMult > 2000) 
        {
           jumpMult = 2000;
        }
        legRot.Pitch = 8500;
        legRot.Yaw = -5200 + (jumpMult-1000)*9;
        legRot.Roll = -3000;
        Driver.SetBoneRotation('Bip01 L Thigh', legRot, 0.0);
        legRot.Yaw = -5200 + (jumpMult-1000)*6;
        legRot.Pitch = -8500 + (jumpMult-1000)*6;
        Driver.SetBoneRotation('Bip01 R Thigh', legRot, 0.0);
        legRot.Pitch = 0;
        legRot.Yaw = -10000 - (jumpMult-1000)*10;
        legRot.Roll = -8000;
        Driver.SetBoneRotation('Bip01 L Calf', legRot, 0.0);
        legRot.Roll = 8000;
        Driver.SetBoneRotation('Bip01 R Calf', legRot, 1.0);
        legRot.Pitch = -6000;
        legRot.Yaw = 15000 + (jumpMult-1000)*10;
        legRot.Roll = 0;
        Driver.SetBoneRotation('Bip01 L Foot', rot(-6000, 15000, 0), 1.0);
        legRot.Pitch = 5000;
        Driver.SetBoneRotation('Bip01 R Foot', rot(5000, 15000, 0), 1.0);

        bodyLoc.X = 0;
        bodyLoc.Y = 0;
        bodyLoc.Z = -(jumpMult-1000) / 24;
        Driver.SetBoneLocation('Bip01', bodyLoc, 1.0);

    }

    else if (DuckCountdown <= 0.0 && (Rise < 0 || (bWeaponIsAltFiring && spinAttack <= 0)))
    {
        if (!bHoldingDuck)
        {
            bHoldingDuck = True;
            bPlayDuckSound = true;
            DuckEffect = Spawn(class'CSTrickboardAttackEffect');
            DuckEffect.SetBase(Self);

            if ( AIController(Controller) != None )
    			Rise = 0;

    		JumpCountdown = 0.0; // Stops any jumping that was going on.
    	}
    }
    else
    {
        bHoldingDuck = False;
    }

    // Super jump (from holding crouch)
    if (!bDuckReleased && !bHoldingDuck) 
    {
        bDuckReleased = true;
        bPlayDuckSound = false;
        JumpDuration = JumpDuration * (jumpMult/1000);
        jumpMult = 1000;
        PlaySound(JumpSound,,1.0);

        if (Role == ROLE_Authority)
            DoBikeJump = !DoBikeJump;

        if(Level.NetMode != NM_DedicatedServer)
        {
            JumpEffect = Spawn(class'CSTrickboardJumpEffect');
            JumpEffect.SetBase(Self);
            ClientPlayForceFeedback(JumpForce);
        }

        if ( AIController(Controller) != None )
            Rise = 0;

        LastJumpTime = Level.TimeSeconds;

        // Play Custom Jump Anim
        superJumpCount = 180;
        bodyLocR = 40;
        bodyLocRTemp = 0;
        bodyVel = 12;
        legRotR = -30;
        armRotR = -20;
        blegDone = false;
        barmDone = false;
        legRotRTemp = 0;
        armRotRTemp = 0;

        SetDriverPositionBoarding(Driver);
    }
    else if (bPlayDuckSound) 
    {
        if(Rise < 0 && !bOnGround && Velocity.Z > 0)
            PlaySound(DuckSound,,1.0);
        else
            PlaySound(spinSounds[rand(2)],,1.0);

        bPlayDuckSound = false;
    }
}

simulated function KApplyForce(out vector Force, out vector Torque)
{
	Super.KApplyForce(Force, Torque);

    KApplyBoostForce(Force,Torque);
    KApplyGrappleForce(Force,Torque);

	if (bDriving && JumpCountdown > 0.0)
	{
		Force += vect(0,0,1) * JumpForceMag;
	}

	if (bDriving && bHoldingDuck)
	{
		Force += vect(0,0,-1) * DuckForceMag;
	}
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverWing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorTailWing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverChair');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	L.AddPrecacheStaticMesh(StaticMesh'ONSWeapons-SM.PC_MantaJumpBlast');

	L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'WeaponSkins.Skins.RocketTex0');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.JumpDuck');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.AirBlast');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.GrenExpl');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverWing');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverChair');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RAPTORexploded.RaptorTailWing');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSWeapons-SM.PC_MantaJumpBlast');
	Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'WeaponSkins.Skins.RocketTex0');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.JumpDuck');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.RVGroup.RVbladesSHAD');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.NewHoverCraftNOcolor');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.AirBlast');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.GrenExpl');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

	Super.UpdatePrecacheMaterials();
}

function int GetLinks()
{
	return Links;
}

function ResetLinks()
{
    Links = 0;
}

// Don't allow primary fire if beaming
function Fire(optional float F)
{
	if (!bBeaming)
		Super.Fire(F);
}

// ============================================================================
// C/P'd Ion Tank stuff
// ============================================================================
function AltFire(optional float F)
{
	super(ONSVehicle).AltFire( F );
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	super(ONSVehicle).ClientVehicleCeaseFire( bWasAltFire );
}

///////////////////////////////////////////////////////////////////////////////////////////

simulated event KApplyGrappleForce(out vector Force, out vector Torque)
{
    local vector PawnDir;
    local vector dist;
    local vector TargetPos, TargetDir;
    local CSTrickboardWeapon boardweapon;
    local Pawn LockedPawn;

    if(Weapons.length > 0 && Weapons[0] != None)
        boardweapon = CSTrickboardWeapon(Weapons[0]);

	if (boardweapon != none && boardweapon.LockedPawn != none)
	{
        LockedPawn = boardweapon.LockedPawn;
        PawnDir = Normal(LockedPawn.Velocity - Velocity);
        TargetPos = LockedPawn.Location - PawnDir * grappleDistToStop;

        dist = Location - TargetPos;
        TargetDir = Normal(Location - TargetPos);

        if(VSize(LockedPawn.Location - Location) > grappleDistToStop)
            Force += TargetDir * FClamp(VSize(dist)*VSize(dist), 0, grappleMaxForceFactor) * grappleFscale;
	}
}

simulated event KApplyBoostForce(out vector Force, out vector Torque)
{
    if (bBoost)
	{
        Force += vector(Rotation) + vect(0,0,0.20);
		Force += Normal(Force) * BoostForce * (BoostRechargeTime - BoostRechargeCounter)/BoostRechargeTime;
	}
}

simulated function AttachDriver(Pawn P)
{
    super.AttachDriver(P);

    //give player pawn collision
    if(Role == ROLE_Authority)
    {
        PawnCollision = spawn(class'CSTrickboardCollision', self);
        PawnCollision.SetBase(self);
        PawnCollision.SetCollision(true,true);
        PawnCollision.SetRelativeLocation(vect(0,0,44));
        TimerFunc = ETimer_PostAttach;
        SetTimer(0.5, false);
    }
}

simulated function DetachDriver(Pawn P)
{
    super.DetachDriver(P);
    if(Role == ROLE_Authority)
    {
        PawnCollision.SetBase(None);
        PawnCollision.Destroy();
    }

    if(P != None && Vehicle(P) != None)
        SetDriverPositionOriginal(Vehicle(P).Driver);
}

event TakeImpactDamage(float AccelMag)
{
    //do nothing
}

simulated function SpinHurtRadius()
{
    HurtRadius(KickflipDamage, KickflipRadius, class'DamTypeCSTrickboardKickflip', KickflipMomentum, Location); 
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
    local bool bHurtSomething;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
    bHurtSomething = false;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims != Driver) && (Victims != PawnCollision) &&(Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
            bHurtSomething = true;
			if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
		}
	}
	bHurtEntry = false;

    if(bHurtSomething)
    {
        PlaySound(kickflipSounds[rand(2)],,2.5*TransientSoundVolume); 
        MakeNoise(1.0);
    }
}

function int LimitPitch(int pitch)
{
    return super(Pawn).LimitPitch(pitch);
}

defaultproperties
{
    bCanFly=true
    MaxPitchSpeed=2000.000000
    JumpDuration=0.100000
    JumpDuration0=0.100000
    JumpForceMag=224.000000
    JumpDelay=1.000000
    DuckForceMag=70.000000
    BikeDustOffset(0)=(X=50.000000,Z=10.000000)
    BikeDustOffset(1)=(X=-50.000000,Z=10.000000)
    BikeDustTraceDistance=300.000000
    JumpSound=Sound'CSTrickboard.Jump'
    DuckSound=Sound'CSTrickboard.Descend'
    JumpForce="HoverBikeJump"
    jumpMult=1000
    bDuckReleased=True
    ThrusterOffsets(0)=(X=95.000000,Z=10.000000)
    ThrusterOffsets(1)=(X=-200.000000,Z=10.000000)
    ThrusterOffsets(2)=(Z=10.000000)
    HoverSoftness=0.180000
    HoverPenScale=1.000000
    HoverCheckDist=140.000000
    UprightStiffness=40.000000
    UprightDamping=100.000000
    MaxThrustForce=60.000000
    LongDamping=0.020000
    MaxStrafeForce=40.000000
    LatDamping=0.100000
    TurnTorqueFactor=1000.000000
    TurnTorqueMax=250.000000
    TurnDamping=30.000000
    MaxYawRate=3.500000
    PitchTorqueFactor=250.000000
    PitchTorqueMax=15.000000
    PitchDamping=30.000000
    RollTorqueTurnFactor=550.000000
    RollTorqueStrafeFactor=400.000000
    RollTorqueMax=25.000000
    RollDamping=10.000000
    StopThreshold=200.000000
    bHasAltFire=False
    RedSkin=Shader'UT2004Weapons.Shaders.LinkGunRedShader'
    BlueSkin=Shader'UT2004Weapons.Shaders.LinkGunBlueShader'
    IdleSound=Sound'CSTrickboard.Idle'
    StartUpSound=Sound'CSTrickboard.StartUp'
    ShutDownSound=Sound'CSTrickboard.Shutdown'
    StartUpForce="HoverBikeStartUp"
    ShutDownForce="HoverBikeShutDown"
    DestroyedVehicleMesh=StaticMesh'CSTrickboard.Destroyed'
    DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
    DisintegrationEffectClass=Class'Onslaught.ONSVehDeathHoverBike'
    DestructionLinearMomentum=(Min=62000.000000,Max=100000.000000)
    DestructionAngularMomentum=(Min=25.000000,Max=75.000000)
    DamagedEffectScale=0.600000
    DamagedEffectOffset=(X=50.000000,Y=-25.000000,Z=10.000000)
    ImpactDamageMult=0.000080
    HeadlightCoronaOffset(0)=(X=-50.000000,Z=-13.000000)
    HeadlightCoronaOffset(1)=(X=50.000000,Z=-13.000000)
    HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
    HeadlightCoronaMaxSize=50.000000
    bDrawDriverInTP=True
    bTurnInPlace=True
    bShowDamageOverlay=True
    bDrawMeshInFP=True
    bScriptedRise=True
    bShowChargingBar=True
    DrivePos=(X=-18.000000,Y=-10.000000,Z=99.000000)
    ExitPositions(0)=(Z=60.000000)
    ExitPositions(1)=(Z=60.000000)
    ExitPositions(2)=(Z=60.000000)
    ExitPositions(3)=(Z=60.000000)
    ExitPositions(4)=(Z=60.000000)
    ExitPositions(5)=(Z=60.000000)
    ExitPositions(6)=(Z=60.000000)
    ExitPositions(7)=(Z=60.000000)
    EntryRadius=150.000000
    FPCamPos=(Z=50.000000)
    TPCamDistance=500.000000
    TPCamLookat=(X=0.000000,Z=0.000000)
    TPCamWorldOffset=(Z=120.000000)
    VehiclePositionString="on a trickboard"
    VehicleNameString="Trickboard"
    RanOverDamageType=Class'CSTrickboard.DamTypeCSTrickboardHeadshot'
    CrushedDamageType=Class'CSTrickboard.DamTypeCSTrickboardPancake'
    ObjectiveGetOutDist=10.000000
    FlagBone="HoverCraft"
    FlagOffset=(Z=45.000000)
    FlagRotation=(Yaw=32768)
    HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn02'
    HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.La_Cucharacha_Horn'
    bCanStrafe=True
    MeleeRange=-200.000000
    //GroundSpeed=3000.000000
    GroundSpeed=2000.000000
    HealthMax=150.000000
    Health=150
    Mesh=SkeletalMesh'CSTrickboard.Board'
    DrawScale=1.200000
    SoundRadius=300.000000
    Begin Object Class=KarmaParamsRBFull Name=KParams0
        KInertiaTensor(0)=1.300000
        KInertiaTensor(3)=3.000000
        KInertiaTensor(5)=3.500000
        KLinearDamping=0.150000
        KAngularDamping=0.000000
        KStartEnabled=True
        bHighDetailOnly=False
        bClientOnly=False
        bKDoubleTickRate=True
        bKStayUpright=True
        bKAllowRotate=True
        bDestroyOnWorldPenetrate=True
        bDoSafetime=True
        KFriction=0.300000
        KImpactThreshold=1700.000000
    End Object
    KParams=KarmaParamsRBFull'CSTrickboard.CSTrickboard.KParams0'

    bSelected=True

    DriverWeapons(0)=(WeaponClass=class'CSTrickboard.CSTrickboardWeapon')

    grappleDistToStop=1400
    grappleMaxForceFactor=100000
    grappleFscale=-0.001

    //BoostForce=3000.000000
    //BoostTime=1.0
    BoostForce=2800.000000
    BoostTime=0.75
    BoostSound=Sound'CSTrickboard.Jump'
    BoostReadySound=Sound'WeaponSounds.TAGRifle.TAGTargetAquired'
    //BoostRechargeTime=2.500000
    BoostRechargeTime=1.7500000
    BoostDoubleTapThreshold=0.25

    TickCount=1
    KickflipDamage=300
    KickflipMomentum=10000
    KickflipRadius=200

    kickflipSounds(0)=Sound'kickflip1'
    kickflipSounds(1)=Sound'kickflip2'
    spinSounds(0)=Sound'spin1'
    spinSounds(1)=Sound'spin2'

    bAlwaysRelevant=true
}
