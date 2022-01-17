/******************************************************************************
IonTurretAttachment

Creation date: 2012-10-23 11:13
Last change: $Id$
Copyright © 2012, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class IonTurretAttachment extends Actor;


//=============================================================================
// Properties
//=============================================================================

var() array<Material> RedSkins;
var() array<Material> BlueSkins;
var() vector RightChargeBeamOffset;

var Emitter ChargeBeams[2];
var float BeamSize;
var bool bCharging;


function SetTeam(byte T)
{
	switch (T)
	{
		case 0:
			Skins = RedSkins;
			break;
		case 1:
			Skins = BlueSkins;
			break;
		default:
			//Skins = default.Skins;
			break;
	}
}


function PlayChargeUp()
{
	PlayAnim('Charge', 0.3);
	bCharging = True;
}

function PlayFire()
{
	PlayAnim('Fire', 0.5);
	bCharging = False;
}

function PlayExplode()
{
	Spawn(class'ONSVehicleIonExplosionEffect');
	bCharging = False;
}

function Destroyed()
{
	if (ChargeBeams[0] != None)
		ChargeBeams[0].Destroy();
	if (ChargeBeams[1] != None)
		ChargeBeams[1].Destroy();
}

function Tick(float DeltaTime)
{
	if (!bCharging)
	{
		BeamSize = 0;
		if (ChargeBeams[0] != None)
		{
			ChargeBeams[0].Kill();
			ChargeBeams[0] = None;
		}
		if (ChargeBeams[1] != None)
		{
			ChargeBeams[1].Kill();
			ChargeBeams[1] = None;
		}
	}
	else
	{
		BeamSize += DeltaTime;
		UpdateChargeBeam(0);
		UpdateChargeBeam(1);
	}
}

function UpdateChargeBeam(int n)
{
	local float Dist;

	if (ChargeBeams[n] == None)
	{
		//log("WA_Turret_IonCannon::UpdateChargeBeam Spawning ChargeBeam");
		ChargeBeams[n] = Spawn(class'UT2k4AssaultFull.FX_Turret_IonCannon_ChargeBeam');
		if (ChargeBeams[n] != None)
		{
			AttachToBone(ChargeBeams[n], 'BeamFront');

			ChargeBeams[n].SetRelativeLocation(n * RightChargeBeamOffset);
		}
	}

	if (ChargeBeams[n] != None)
	{
		// Correct Length
		Dist = VSize(GetBoneCoords('BeamFront').Origin - GetBoneCoords('BeamRear').Origin);
		BeamEmitter(ChargeBeams[n].Emitters[0]).BeamDistanceRange.Min   = Dist;
		BeamEmitter(ChargeBeams[n].Emitters[0]).BeamDistanceRange.Max   = Dist;
		SpriteEmitter(ChargeBeams[n].Emitters[2]).StartLocationOffset.X = Dist;

		// Size Scale
		BeamEmitter(ChargeBeams[n].Emitters[0]).StartSizeRange.X.Min = 15.0 * BeamSize * 0.5;
		BeamEmitter(ChargeBeams[n].Emitters[0]).StartSizeRange.X.Max = 50.0 * BeamSize * 0.5;

		SpriteEmitter(ChargeBeams[n].Emitters[1]).StartSizeRange.X.Min =  75.0 * BeamSize * 0.5;
		SpriteEmitter(ChargeBeams[n].Emitters[1]).StartSizeRange.X.Max = 100.0 * BeamSize * 0.5;

		SpriteEmitter(ChargeBeams[n].Emitters[2]).StartSizeRange.X.Min =  75.0 * BeamSize * 0.5;
		SpriteEmitter(ChargeBeams[n].Emitters[2]).StartSizeRange.X.Max = 100.0 * BeamSize * 0.5;
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     RedSkins(0)=Shader'WVHoverTankV2.Skins.IonTurretLit1Red'
     RedSkins(1)=Shader'WVHoverTankV2.Skins.IonTurretLit2Red'
     BlueSkins(0)=Shader'WVHoverTankV2.Skins.IonTurretLit1Blue'
     BlueSkins(1)=Shader'WVHoverTankV2.Skins.IonTurretLit2Blue'
     RightChargeBeamOffset=(Y=200.000000)
     DrawType=DT_Mesh
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'AS_VehiclesFull_M.IonCannon'
     DrawScale=0.200000
     DrawScale3D=(Y=2.000000)
}
