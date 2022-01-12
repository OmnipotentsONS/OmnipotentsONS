class CSPallasTurretCannon extends ONSWeapon;

var vector OldDir;
var rotator OldRot;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx
#exec OBJ LOAD FILE=..\Textures\BenTex01.utx
//#exec TEXTURE IMPORT FORMAT=DXT5 FILE=Textures\CSPallasArtilleryTurretRed.dds
//#exec TEXTURE IMPORT FORMAT=DXT5 FILE=Textures\CSPallasArtilleryTurretBlue.dds
#exec OBJ LOAD FILE=Textures\CSPallasTex.utx PACKAGE=CSPallasV2

#exec AUDIO IMPORT FILE=Sounds\shell.wav

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'CSPallasV2.CSPallasArtilleryTurretRed');
    L.AddPrecacheMaterial(Material'CSPallasV2.CSPallasArtilleryTurretBlue');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'CSPallasV2.CSPallasArtilleryTurretRed');
    Level.AddPrecacheMaterial(Material'CSPallasV2.CSPallasArtilleryTurretBlue');

    Super.UpdatePrecacheMaterials();
}

function byte BestMode()
{
	return 0;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	OldDir = Vector(CurrentAim);
	//SetBoneScale(0,0.8, 'TurretAttach');
}

function Tick(float Delta)
{
	local int i;
	local xPawn P;
	local vector NewDir, PawnDir;
    local coords WeaponBoneCoords;

    Super.Tick(Delta);

	if ( (Role == ROLE_Authority) && (Base != None) )
	{
	    WeaponBoneCoords = GetBoneCoords(YawBone);
		NewDir = WeaponBoneCoords.XAxis;
		if ( (Vehicle(Base).Controller != None) && (NewDir.Z < 0.9) )
		{
			for ( i=0; i<Base.Attached.Length; i++ )
			{
				P = XPawn(Base.Attached[i]);
				if ( (P != None) && (P.Physics != PHYS_None) && (P != Vehicle(Base).Driver) )
				{
					PawnDir = P.Location - WeaponBoneCoords.Origin;
					PawnDir.Z = 0;
					PawnDir = Normal(PawnDir);
					if ( ((PawnDir.X <= NewDir.X) && (PawnDir.X > OldDir.X))
						|| ((PawnDir.X >= NewDir.X) && (PawnDir.X < OldDir.X)) )
					{
						if ( ((PawnDir.Y <= NewDir.Y) && (PawnDir.Y > OldDir.Y))
							|| ((PawnDir.Y >= NewDir.Y) && (PawnDir.X < OldDir.Y)) )
						{
							P.SetPhysics(PHYS_Falling);
							P.Velocity = WeaponBoneCoords.YAxis;
							if ( ((NewDir - OldDir) Dot WeaponBoneCoords.YAxis) < 0 )
								P.Velocity *= -1;
							P.Velocity = 500 * (P.Velocity + 0.3*NewDir);
							P.Velocity.Z = 200;
						}
					}
				}
			}
		}
		OldDir = NewDir;
	}
}
defaultproperties
{
     YawBone="8WheelerTop"
     PitchBone="TurretAttach"
     PitchUpLimit=32767
     PitchDownLimit=59500
     WeaponFireAttachmentBone="Firepoint"
     RotationsPerSecond=0.180000
     bDoOffsetTrace=True
     Spread=0.015000
     RedSkin=Shader'CSPallasV2.ArtilleryTurretRedShader'
     BlueSkin=Shader'CSPallasV2.ArtilleryTurretBlueShader'

     FireInterval=2.500000
     EffectEmitterClass=Class'OnslaughtBP.ONSShockTankMuzzleFlash'
     FireSoundClass=Sound'CSPallasV2.shell'
     FireSoundVolume=512.000000
     AltFireSoundClass=Sound'CSPallasV2.shell'
     FireForce="Explosion05"
     DamageType=Class'CSPallasV2.CSPallasDamTypeMortarShell'
     ProjectileClass=Class'CSPallasV2.CSPallasMortarShellSmall'
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.800000)
     Mesh=SkeletalMesh'ONSBPAnimations.ShockTankCannonMesh'
     DrawScale=0.400000
}
