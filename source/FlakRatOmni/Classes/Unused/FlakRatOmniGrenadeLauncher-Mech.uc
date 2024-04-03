class CSBombMechWeapon extends ONSWeapon;

var float MinAim;
var class<xEmitter>     MuzFlashClass;
var xEmitter            MuzFlash;


////////////
var array<CSBombMechProjectile> Grenades;
var int CurrentGrenades; //should be sync'ed with Grenades.length
var int MaxGrenades;
var color FadedColor;


replication
{
	reliable if (bNetOwner && bNetDirty && ROLE == ROLE_Authority)
		CurrentGrenades;
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
}

simulated function GetViewAxes( out vector xaxis, out vector yaxis, out vector zaxis )
{
    if ( Instigator.Controller == None )
        GetAxes( Instigator.Rotation, xaxis, yaxis, zaxis );
    else
        GetAxes( Instigator.Controller.Rotation, xaxis, yaxis, zaxis );
}

state ProjectileFireMode
{
    function Fire(Controller C)
    {
        local CSBombMechProjectile P;
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

        P = CSBombMechProjectile(SpawnProjectile(ProjectileClass, false));
        if(P != None)
        {
            P.SetOwner(Self);
            Grenades[Grenades.length] = P;
            CurrentGrenades++;
        }

    }

    function AltFire(Controller C)
    {
        local int x;
        if(Vehicle(Owner) != None)
        {
            Vehicle(Owner).PlayFiring();
        }

        for (x = 0; x < Grenades.Length; x++)
            if (Grenades[x] != None)
                Grenades[x].Explode(Grenades[x].Location, vect(0,0,1));

        Grenades.length = 0;
        CurrentGrenades = 0;
    }
}

//////////////

simulated function NewDrawWeaponInfo(Canvas Canvas, float YPos)
{
	local int i, Half;
	local float ScaleFactor;

	ScaleFactor = 99 * Canvas.ClipX/3200;
	Half = (MaxGrenades + 1) / 2;
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = class'HUD'.Default.WhiteColor;
	for (i = 0; i < Half; i++)
	{
		if (i >= CurrentGrenades)
			Canvas.DrawColor = FadedColor;
		Canvas.SetPos(Canvas.ClipX - (i+1) * ScaleFactor * 1.25, YPos);
		Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 324, 325, 54, 54);
	}
	for (i = Half; i < MaxGrenades; i++)
	{
		if (i >= CurrentGrenades)
			Canvas.DrawColor = FadedColor;
		Canvas.SetPos(Canvas.ClipX - (i-Half+1) * ScaleFactor * 1.25, YPos - ScaleFactor);
		Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 324, 325, 54, 54);
	}
}

simulated function Destroyed()
{
	local int x;

	if (Role == ROLE_Authority)
	{
		for (x = 0; x < Grenades.Length; x++)
			if (Grenades[x] != None)
				Grenades[x].Explode(Grenades[x].Location, vect(0,0,1));
		Grenades.Length = 0;
	}

	Super.Destroyed();
}

function byte BestMode()
{
	local int x;

	if (CurrentGrenades >= MaxGrenades)
		return 1;

	for (x = 0; x < Grenades.length; x++)
		if (Grenades[x] != None && Pawn(Grenades[x].Base) != None)
			return 1;

	return 0;
}

event bool AttemptFire(Controller C, bool bAltFire)
{
    if(!bAltFire && CurrentGrenades >= MaxGrenades)
        return false;
    
    return super.AttemptFire(C, bAltFire);
}

defaultproperties
{
    Mesh=Mesh'ONSWeapons-A.GrenadeLauncher_3rd'


    YawBone='Bone_weapon'
    PitchBone='Bone_weapon'
    DrawScale=1.18
    YawStartConstraint=0
    YawEndConstraint=65535
    PitchUpLimit=18000
    PitchDownLimit=49153

    ProjectileClass=class'CSBombMechProjectile'
    FireSoundClass=Sound'WeaponSounds.BioRifle.BioRifleFire'

    FireSoundVolume=255
    FireSoundRadius=1500
    FireSoundPitch=0.8
    FireInterval=0.65

    AltFireSoundRadius=1500
    AltFireInterval=1.0

    RotateSound=sound'CSMech.turretturn'
    RotateSoundThreshold=50.0

    WeaponFireAttachmentBone=Bone_Flash
    WeaponFireOffset=0.0
    bAimable=True
    bInstantRotation=true
    bDoOffsetTrace=true
    DualFireOffset=0
    AIInfo(0)=(bLeadTarget=true,RefireRate=0.95)
    AIInfo(1)=(bLeadTarget=true,AimError=400,RefireRate=0.50)
    MinAim=0.900
    TraceRange=20000

    MaxGrenades=8
    FadedColor=(R=128,G=128,B=128,A=128)

}