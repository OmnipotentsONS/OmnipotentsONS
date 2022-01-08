class APAutoBomber extends ONSAutoBomber;


var bool bNuke,bAlreadyNukeDrop;
var FX_RunningLight LeftWingLight,RightWingLight,BottomLight;
var Proj_NukeMissile Nuke;
var Proj_BombShell Bomb;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
    PlayAnim('BBayDoorOpen');
	if (Role == ROLE_Authority && Instigator != None)
	   SetRunningLightsFX();


    if (Instigator != none && Instigator.Controller.Adrenaline==100.0)
       {
        bNuke=true;
        Instigator.Controller.Adrenaline=0.0;
       }
}

function Timer()
{
	local Controller C;

	if (FRand() < 0.5)
	{
		//high skill enemies who don't have anything else to shoot at will try to shoot bomber down
		for (C = Level.ControllerList; C != None; C = C.NextController)
			if ( AIController(C) != None && C.Pawn != None && C.GetTeamNum() != Team && AIController(C).Skill >= 5.0
			     && !C.Pawn.IsFiring() && (C.Enemy == None || !C.LineOfSightTo(C.Enemy)) && C.Pawn.CanAttack(self) )
			{
				C.Focus = self;
				C.FireWeaponAt(self);
			}
	}

    if(bNuke==true && bAlreadyNukeDrop==false)
      {
        BombRange=1000.000000;
       if (VSize(Location - BombTargetCenter) < BombRange)
	      {

            bAlreadyNukeDrop=true;
          //drop a Nuke
		   Nuke=spawn(Class'CSAPVerIV.Proj_NukeMissile',,, Location - ((CollisionHeight + BombClass.default.CollisionHeight) * vect(0,0,2)), rotator(vect(0,0,-1)));
		   Velocity = Normal(Velocity) * MinSpeed;
		   Acceleration = vect(0,0,0);
	      }
     }
    if(bNuke==false && bAlreadyNukeDrop==false)
     {
	    BombRange=2500.000000;
      if (VSize(Location - BombTargetCenter) < BombRange)
	     {
		  //drop a bomb
		  Bomb=spawn(Class'CSAPVerIV.Proj_BombShell',,, Location - ((CollisionHeight + BombClass.default.CollisionHeight) * vect(0,0,2)), rotator(vect(0,0,-1)));
		  Bomb.StartTimer(2.0);
          Velocity = Normal(Velocity) * MinSpeed;
		  Acceleration = vect(0,0,0);
	    }
     }
}

simulated function Tick(float deltaTime)
{
	local float TargetDist;

	//start out really fast, slow down when near target
	TargetDist = VSize(Location - BombTargetCenter);
	if (TargetDist > BombRange)
		Velocity = vector(Rotation) * ((TargetDist - BombRange) / 100000 * Speed + MinSpeed);

}

simulated function Destroyed()
{
	if (LeftWingLight!=none)
        LeftWingLight.Destroy();
    if (RightWingLight!=none)
        RightWingLight.Destroy();
    if (BottomLight!=none)
        BottomLight.Destroy();
    if (DyingEffect != None)
		DyingEffect.Kill();
}

simulated function SetRunningLightsFX()
{
 if (LeftWingLight==none)
          {
           LeftWingLight=spawn(Class'FX_RunningLight',Self,,Location);
           AttachToBone(LeftWingLight, 'LWLight');

		   RightWingLight=spawn(Class'FX_RunningLight',Self,,Location);
           AttachToBone(RightWingLight,'RWLight');

           BottomLight=spawn(Class'FX_RunningLight',Self,,Location);
           AttachToBone(BottomLight,'BLight');
          }
       if (LeftWingLight!=none)
          {
           if ( Team == 1 )	// Blue version
			   {
				LeftWingLight.SetBlueColor();
                RightWingLight.SetBlueColor();
                BottomLight.SetBlueColor();
               }
            else
               if ( Team == 0)	// Red version
			   {
                LeftWingLight.SetRedColor();
                RightWingLight.SetRedColor();
                BottomLight.SetRedColor();
               }
          }
}

defaultproperties
{
     bReplicateAnimations=True
     Mesh=SkeletalMesh'APVerIV_Anim.PhantomMesh'
}
