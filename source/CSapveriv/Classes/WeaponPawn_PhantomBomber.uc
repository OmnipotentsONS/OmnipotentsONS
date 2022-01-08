//-----------------------------------------------------------
//
//-----------------------------------------------------------
class WeaponPawn_PhantomBomber extends APWeaponPawn;
#exec OBJ LOAD FILE=..\Sounds\IndoorAmbience.uax
var     float   NukeFireCountdown;
var     float	NukeDropDelay, LastNukeDropTime;
var bool bStartTime;

var()       sound   DeploySound;

simulated function PostNetBeginPlay()
{
  	super.PostNetBeginPlay();
  	NukeDropDelay=0.5;
}

simulated function float ChargeBar()
{
   if(bStartTime)
   {
    // Clamp to 0.999 so charge bar doesn't blink when maxed
	if (Level.TimeSeconds - NukeDropDelay < LastNukeDropTime)
        return (FMin((Level.TimeSeconds - LastNukeDropTime) / NukeDropDelay, 0.999));
    else
		return 0.999;
	}
}
simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    NukeFireCountdown -= DeltaTime;

}

function Fire(optional float F)
{
	Super.Fire(F);
}
function AltFire(optional float F)
{
	Super.AltFire(F);
	if(bStartTime==false)
      {
       //NukeDropDelay=80;
       bStartTime=true;
      }
    CheckNukeDrop();
    if(Phantom(VehicleBaseB)!=None)
    GotoState('FireSequence');
}
state FireSequence
{

Begin:
    //if (Instigator.Controller != None)

     PlaySound(DeploySound,SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
     Phantom(VehicleBaseB).PlayAnim('BBayDoorOpen');
     Sleep(2.4);
     PlaySound(DeploySound,SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
     Phantom(VehicleBaseB).PlayAnim('BBayDoorClose');
     GotoState('');

}
function dooropen()
{
  PlaySound(DeploySound,SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
  Phantom(VehicleBaseB).PlayAnim('BBayDoorOpen');
}
function doorClose()
{
  PlaySound(DeploySound,SLOT_Interact,6*TransientSoundVolume,,TransientSoundRadius,,false);
  Phantom(VehicleBaseB).PlayAnim('BBayDoorClose');
}
//use this for countdown for indicating when next Nuke can be
// dropped use  NukeDropDelay set to same time as weapon alt fire.
simulated function CheckNukeDrop()
{
	if (NukeFireCountdown <= 0.0 && Level.TimeSeconds - NukeDropDelay >= LastNukeDropTime)
    	LastNukeDropTime = Level.TimeSeconds;
}

// - CenterDraw - Draws an images centered around a point.  Optionally, it can stretch the image.
simulated function CenterDraw(Canvas Canvas, Material Mat, float x, float y, float UScale, float VScale, optional bool bStretched)
{
	local float u,v,w,h;

	u = Mat.MaterialUSize(); w = u * UScale;
	v = Mat.MaterialVSize(); h = v * VScale;
	Canvas.SetPos(x - (w/2), y - (h/2) );
	if (!bStretched)
		Canvas.DrawTile(Mat,w,h,0,0,u,v);
	else
		Canvas.DrawTileStretched(Mat,w,h);
}


simulated function DrawHUD(Canvas Canvas)
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

//  Remove Me : for testing
//	ProjectilePostRender2D(None,Canvas,140,140);

}

defaultproperties
{
     DeploySound=Sound'IndoorAmbience.door4'
     GunClass=Class'CSAPVerIV.Weapon_PhantomBombDropper'
     CameraBone="PlasmaGunBarrel"
     bDrawDriverInTP=False
     DrivePos=(Z=-130.000000)
     ExitPositions(0)=(Y=-200.000000,Z=100.000000)
     ExitPositions(1)=(Y=200.000000,Z=100.000000)
     EntryPosition=(X=40.000000,Y=50.000000,Z=-100.000000)
     EntryRadius=130.000000
     FPCamPos=(Z=-20.000000)
     FPCamViewOffset=(X=-386.000000,Z=-300.000000)
     TPCamLookat=(Z=-86.000000)
     TPCamDistRange=(Min=0.000000,Max=0.000000)
     DriverDamageMult=0.000000
     VehiclePositionString="in a Phantom Bomber Turret"
     VehicleNameString="Phantom Bombadier"
}
