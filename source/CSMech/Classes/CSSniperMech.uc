class CSSniperMech extends CSHoverMech
    placeable;

#exec obj load file="Animations\CSMech_Xan_Anim.ukx" package=CSMech
#exec AUDIO IMPORT FILE=Sounds\EngStop6.wav
#exec AUDIO IMPORT FILE=Sounds\EngStart6.wav
#exec AUDIO IMPORT FILE=Sounds\FootStep3.wav
#exec AUDIO IMPORT FILE=Sounds\missionimpossible.wav
#exec AUDIO IMPORT FILE=Sounds\nelson.wav
#exec AUDIO IMPORT FILE=Sounds\EngIdle7.wav
#exec AUDIO IMPORT FILE=Sounds\flying.wav

var(Gfx) float testX;
var(Gfx) float testY;

var(Gfx) float borderX;
var(Gfx) float borderY;
var(Gfx) float focusX;
var(Gfx) float focusY;
var(Gfx) float innerArrowsX;
var(Gfx) float innerArrowsY;

var(Gfx) Color ArrowColor;
var(Gfx) Color TargetColor;
var(Gfx) Color NoTargetColor;
var(Gfx) Color FocusColor;
var(Gfx) Color ChargeColor;

var(Gfx) vector RechargeOrigin;
var(Gfx) vector RechargeSize;
var bool zooming;
var float OldHoverRise;
var bool bHovering;
var float HoverCharge, HoverForceMag, LastHover;
var() float HoverCost, HoverGain, HoverChargeMax;

var()   array<vector>					TrailEffectPositions;
var()   array<rotator>					TrailEffectRotations;
var     class<CSSniperMechThruster>	TrailEffectClass;
var     array<CSSniperMechThruster>	TrailEffects;
var(Sound) sound ThrustSound;

replication
{
    reliable if(Role == ROLE_Authority)
        HoverCharge;
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    HoverCharge=HoverChargeMax;
}

function AltFire(optional float F)
{
	local PlayerController PC;

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = true;
	PC.ToggleZoom();
    zooming=!zooming;
    if(zooming)
    {
        PlaySound(Sound'WeaponSounds.LightningGun.LightningZoomIn', SLOT_Misc,,,,,false);
    }
    else
    {
        PlaySound(Sound'WeaponSounds.LightningGun.LightningZoomOut', SLOT_Misc,,,,,false);
    }
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if (!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

simulated function ClientKDriverLeave(PlayerController PC)
{
	Super.ClientKDriverLeave(PC);

	bWeaponIsAltFiring = false;
    zooming=false;
	PC.EndZoom();
}

simulated function bool KDriverLeave(bool bForce)
{
    local bool retval;

    retval = super.KDriverLeave(bForce);
    if(retval && Role == ROLE_Authority)
    {
        zooming=false;
    }
    return retval;
}

simulated function SetZoomBlendColor(Canvas c)
{
    local Byte    val;
    local Color   clr;
    local Color   fog;

    clr.R = 255;
    clr.G = 255;
    clr.B = 255;
    clr.A = 255;

    if( Instigator.Region.Zone.bDistanceFog )
    {
        fog = Instigator.Region.Zone.DistanceFogColor;
        val = 0;
        val = Max( val, fog.R);
        val = Max( val, fog.G);
        val = Max( val, fog.B);

        if( val > 128 )
        {
            val -= 128;
            clr.R -= val;
            clr.G -= val;
            clr.B -= val;
        }
    }
    c.DrawColor = clr;
}

//used to draw HUD when in FP view
simulated function DrawHUD(Canvas Canvas)
{
    if(zooming)
    {
        RenderZoom(Canvas);
    }
    else
    {
        super.DrawHUD(Canvas);
    }
}

function RenderZoom( Canvas Canvas )
{
	local float tileScaleX;
	local float tileScaleY;
	local float bX;
	local float bY;
	local float fX;
	local float fY;
	local float ChargeBar;

	local float tX;
	local float tY;

	local float barOrgX;
	local float barOrgY;
	local float barSizeX;
	local float barSizeY;

    if(Level.NetMode == NM_DedicatedServer)
        return;

    if ( Weapons[0].FireCountdown >= Level.TimeSeconds )
    {
        ChargeBar = 1.0;
    }
    else
    {
        ChargeBar = 1.0 - ((Weapons[0].FireCountdown) / Weapons[0].FireInterval);
        ChargeBar = FClamp(ChargeBar, 0.0,1.0);
    }

    tileScaleX = Canvas.SizeX / 640.0f;
    tileScaleY = Canvas.SizeY / 480.0f;

    bX = borderX * tileScaleX;
    bY = borderY * tileScaleY;
    fX = 2*focusX * tileScaleX;
    fY = 2*focusY * tileScaleX;

    tX = testX * tileScaleX;
    tY = testY * tileScaleX;

    barOrgX = RechargeOrigin.X * tileScaleX;
    barOrgY = RechargeOrigin.Y * tileScaleY;

    barSizeX = RechargeSize.X * tileScaleX;
    barSizeY = RechargeSize.Y * tileScaleY;

    SetZoomBlendColor(Canvas);

    Canvas.Style = 255;
    Canvas.SetPos(0,0);
    Canvas.DrawTile( Material'ZoomFB', Canvas.SizeX, Canvas.SizeY, 128, 128, 256, 256 ); // !! hardcoded size

    Canvas.DrawColor = FocusColor;
    Canvas.DrawColor.A = 255; // 255 was the original -asp. WTF??!?!?!
    Canvas.Style = ERenderStyle.STY_Alpha;

    Canvas.SetPos((Canvas.SizeX*0.5)-fX,(Canvas.SizeY*0.5)-fY);
    Canvas.DrawTile( Texture'SniperFocus', fX*2.0, fY*2.0, 0.0, 0.0, Texture'SniperFocus'.USize, Texture'SniperFocus'.VSize );

    fX = innerArrowsX * tileScaleX;
    fY = innerArrowsY * tileScaleY;

    Canvas.DrawColor = ArrowColor;
    Canvas.SetPos((Canvas.SizeX*0.5)-fX,(Canvas.SizeY*0.5)-fY);
    Canvas.DrawTile( Texture'SniperArrows', fX*2.0, fY*2.0, 0.0, 0.0, Texture'SniperArrows'.USize, Texture'SniperArrows'.VSize );

    // Draw the Charging meter  -AsP
    Canvas.DrawColor = ChargeColor;
    Canvas.DrawColor.A = 255;

    if(ChargeBar <1)
        Canvas.DrawColor.R = 255*ChargeBar;
    else
    {
        Canvas.DrawColor.R = 0;
        Canvas.DrawColor.B = 0;
    }

    if(ChargeBar == 1)
    {
        Canvas.DrawColor.G = 255;
    }
    else
    {
        Canvas.DrawColor.G = 0;
    }

    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.SetPos( barOrgX, barOrgY );
    Canvas.DrawTile(Texture'Engine.WhiteTexture',barSizeX,barSizeY*ChargeBar, 0.0, 0.0,Texture'Engine.WhiteTexture'.USize,Texture'Engine.WhiteTexture'.VSize*ChargeBar);
}

simulated function CheckHover(float DeltaTime)
{
    if(Role == ROLE_Authority)
    {
        HoverCharge += HoverGain * DeltaTime;
        if(bHovering)
            HoverCharge -= HoverCost * DeltaTime;
        HoverCharge = FClamp(HoverCharge, 0, HoverChargeMax);
    }

    if(OldHoverRise != Rise && didDoubleJump && dodgeDir < 0)
    {
        if(Rise > 0)
        {
            HoverCharge -= HoverCost * DeltaTime;
            HoverCharge = FClamp(HoverCharge, 0, HoverChargeMax);
            LastHover = Level.TimeSeconds;
            bHovering = true;
        }
        else
        {
            bHovering = false;
        }

        EnableThrusters(bHovering);
        OldHoverRise=Rise;
    }

    if(bHovering)
    {
        if(HoverCharge == 0)
        {
            EnableThrusters(false);
        }
        else
        {
            PlaySound( ThrustSound,, 2.5*TransientSoundVolume);
        }
    }
}

simulated function MechLanded()
{
    super.MechLanded();
    bHovering = false;
    EnableThrusters(bHovering);
}

simulated function EnableThrusters(bool bEnable)
{
    local int i;
    //local float ThrustAmount;
    //ThrustAmount = FClamp(OutputThrust, 0.0, 1.0);

    for(i=0; i<TrailEffects.Length; i++)
    {
        TrailEffects[i].SetThrustEnabled(bEnable && HoverCharge > 0);
        TrailEffects[i].SetThrust(1.0);
    }
}

simulated function KApplyForce(out vector Force, out vector Torque)
{
    local float DT;
	Super.KApplyForce(Force, Torque);

	if (bDriving && bHovering && HoverCharge > 0.0 && dodgeDir < 0)
	{
        DT = FClamp((Level.TimeSeconds - LastHover)*2.0, 0, 1);
		Force += vect(0,0,1) * HoverForceMag * DT;
	}
}

simulated function Tick(float DeltaTime)
{
    CheckHover(DeltaTime);
    super.Tick(DeltaTime);

}

simulated function float ChargeBar()
{
    return FMin(HoverCharge/HoverChargeMax,0.999);
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

    Super.Destroyed();
}

simulated event DrivingStatusChanged()
{
	local vector RotX, RotY, RotZ;
    local coords C;
    local rotator R;
	local int i;

	Super.DrivingStatusChanged();

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
        GetAxes(Rotation,RotX,RotY,RotZ);

        if (TrailEffects.Length == 0)
        {
            TrailEffects.Length = TrailEffectPositions.Length;
            C = GetBoneCoords(SpineBone2);
            R = GetBoneRotation(SpineBone2);

        	for(i=0;i<TrailEffects.Length;i++)
            if (TrailEffects[i] == None)
            {
                TrailEffects[i] = spawn(TrailEffectClass,self);
                TrailEffects[i].SetBase(self);
                AttachToBone(TrailEffects[i], SpineBone2);
                TrailEffects[i].SetRelativeLocation( TrailEffectPositions[i]);
                TrailEffects[i].SetRelativeRotation( TrailEffectRotations[i]);

                TrailEffects[i].SetThrustEnabled(false);
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


defaultproperties
{    
    VehicleNameString="Snipertron 1.8"
    VehiclePositionString="in a Snipertron"
    bExtraTwist=false

    Mesh=Mesh'CSMech.XanM02'
    RedSkin=Texture'UT2004PlayerSkins.Xan.XanM2_Body_0'
    RedSkinHead=Shader'UT2004PlayerSkins.Xan.XanM2_HeadShader'
    BlueSkin=Texture'UT2004PlayerSkins.Xan.XanM2_Body_1'
    BlueSkinHead=Shader'UT2004PlayerSkins.Xan.XanM2_HeadShader'

	Health=1400
	HealthMax=1400
	DriverWeapons(0)=(WeaponClass=class'CSSniperMechWeapon',WeaponBone=righthand)
    HornAnims(0)=Specific_1
    HornAnims(1)=gesture_point
    HornSounds(0)=sound'CSMech.missionimpossible'
    HornSounds(1)=sound'CSMech.nelson'
    IdleSound=sound'CSMech.EngIdle7'            
    StartUpSound=sound'CSMech.EngStart6'
	ShutDownSound=sound'CSMech.EngStop6'
    FootStepSound=sound'CSMech.FootStep3'

	borderX=60.0
	borderY=60.0
	focusX=135
	focusY=105
	testX=100
	testY=100
    innerArrowsX=42.0
    innerArrowsY=42.0
	ChargeColor=(R=255,G=255,B=255,A=255)
    FocusColor=(R=71,G=90,B=126,A=215)
    NoTargetColor=(R=200,G=200,B=200,A=255)
    TargetColor=(R=255,G=255,B=255,A=255)
    ArrowColor=(R=255,G=0,B=0,A=255)
    RechargeOrigin=(X=600,Y=330,Z=0)
	RechargeSize=(X=10,Y=-180,Z=0)

    bHovering=false
    HoverChargeMax=1.0
    HoverCost=0.50
    HoverGain=0.20
    HoverForceMag=3000.0
    HoverCheckDist=150.0
    //back row
    ThrusterOffsets(0)=(X=-140,Y=-150,Z=-290)
	ThrusterOffsets(1)=(X=-140,Y=-50,Z=-290)
	ThrusterOffsets(2)=(X=-140,Y=50,Z=-290)
	ThrusterOffsets(3)=(X=-140,Y=150,Z=-290)

	//front row
	ThrusterOffsets(4)=(X=90,Y=-150,Z=-290)
	ThrusterOffsets(5)=(X=90,Y=-50,Z=-290)
	ThrusterOffsets(6)=(X=90,Y=50,Z=-290)
	ThrusterOffsets(7)=(X=90,Y=150,Z=-290)

    bShowChargingBar=true

    TrailEffectPositions(0)=(X=-14,Y=55,Z=26)
    TrailEffectPositions(1)=(X=-14,Y=55,Z=-26)
    TrailEffectRotations(0)=(Pitch=28672,Yaw=-1024,Roll=0);
    TrailEffectRotations(1)=(Pitch=28672,Yaw=1024,Roll=0);

    TrailEffectClass=class'CSMech.CSSniperMechThruster'
    ThrustSound=Sound'CSMech.flying'

}
