//=============================================================================
// Tacticle Nuclear Missile.
//=============================================================================
class Proj_NukeMissile extends Projectile;


// camera shakes //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view

var FX_NukeEngine MissileTrail;
var float ExplodeTimer, ExpStart;
var bool bCanHitOwner, bHitWater;
var() float DampenFactor, DampenFactorParallel;
var class<xEmitter> HitEffectClass;
var Emitter Trail;
var float LastSparkTime,health;
var float seekerThrust;
var int myteamNuke;

replication
{
     reliable if (Role==ROLE_Authority)
        myteamNuke, health, ExplodeTimer, ExpStart;

}

simulated function Destroyed()
{

	if ( MissileTrail != None )
		MissileTrail.Destroy();
	Super.Destroyed();
}

function BeginPlay()
{
	Super.BeginPlay();

	if (Instigator != None)
		MyTeamNuke = Instigator.GetTeamNum();
	SetTimer(0.5, true);
}

simulated function PostBeginPlay()
{
		local vector Dir;

	Dir = vector(Rotation);
	Velocity = speed * Dir;
    Acceleration = Velocity;

	if ( Level.NetMode != NM_DedicatedServer)
	{
		MissileTrail = Spawn(class'FX_NukeEngine',self,,Location - 100 * Dir, Rotation);
		MissileTrail.SetBase(self);
	}
	 if ( Instigator != None )
		Instigator.Controller = Instigator.Controller;

    settimer(0.1, true);
    Super.PostBeginPlay();
}

event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry )
		return true;

	return false;
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
	if ( Physics == PHYS_None )
    {
        explodetimer=level.timeseconds+=0.5;
    }
}

simulated function Timer()
{
    local Controller C;
    if(level.timeseconds>=explodetimer)
    {
        GotoState('NuclearExplosion');
        ExplodeTimer=99999;
         if (Trail != None )
			Trail.Destroy();
    }
    else if(explodetimer!=99999)
    {

    }
    	//Enemies who don't have anything else to shoot at will try to shoot redeemer down
	for (C = Level.ControllerList; C != None; C = C.NextController)
		if ( AIController(C) != None && C.Pawn != None && C.GetTeamNum() != MyTeamNuke && AIController(C).Skill >= 2.0
		     && !C.Pawn.IsFiring() && (C.Enemy == None || !C.LineOfSightTo(C.Enemy)) && C.Pawn.CanAttack(self) )
		{
			C.Focus = self;
			C.FireWeaponAt(self);
		}
}

simulated function HitWall( vector HitNormal, actor Wall )
{

    if (explodetimer==99999)
    {
        ExplodeTimer=level.timeseconds+0.5;

    }
        SetPhysics(PHYS_None);
       if ( MissileTrail != None )
		MissileTrail.Destroy();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    if ( Role == ROLE_Authority )
		MakeNoise(1.0);
    Spawn(class'CSAPVerIV.FX_NukeFlashFirst',,, Location, Rotation);
    Spawn(class'CSAPVerIV.FX_NukeExplosion',,, Location, Rotation);
    DmgRadius(vect(100,100,100), 1, 0.20, 100, 400, MyDamageType, MomentumTransfer*0.05, Location);
    PlaySound(sound'APVerIV_Snd.NKExp',SLOT_None,5*TransientSoundVolume/1.5,false,TransientSoundRadius/2);
    Destroy();
}

simulated function BlowUp(vector HitLocation)
{
  if (explodetimer==99999)
    {
        ExplodeTimer=level.timeseconds+1;
    }
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
}

simulated function Landed( vector HitNormal )
{
	BlowUp(Location);
}


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType)
{
	if ( (Damage > 0) && ((InstigatedBy == None) || (InstigatedBy.Controller == None) || (Instigator == None) || (Instigator.Controller == None) || !InstigatedBy.Controller.SameTeamAs(Instigator.Controller)) )
	{
		if ( (InstigatedBy == None) || DamageType.Default.bVehicleHit || (DamageType == class'Crushed') )
			BlowUp(Location);
		else
		{
	 		Spawn(class'SmallRedeemerExplosion');
		    SetCollision(false,false,false);
		    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
		    Destroy();
		}
	}
}

simulated event FellOutOfWorld(eKillZType KillType)
{
	BlowUp(Location);
}




final function DmgRadius(vector flash, float dmgPctHard, float dmgPctThru, float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry || Role != ROLE_Authority)
		return;

	if(instigator==none)
	{
	    if(pawn(owner)!=none)
            instigator=pawn(owner);
	    else if(instigator.controller!=none && instigator.controller.pawn!=none)
	        instigator=instigator.controller.pawn;
	    else if(controller(owner)!=none && controller(owner).pawn!=none)
	        instigator=controller(owner).pawn;
	}

    bHurtEntry = true;
	foreach CollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( victims!=none && (Victims != self) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

            if(!fasttrace(Victims.Location, hitlocation)) damagescale*=dmgPctThru;

            if(pawn(victims)!=none) damagescale=damagescale;
            else damagescale*=dmgPctHard;

            if(damage>0)
            {
                Victims.TakeDamage
			    (
				    damageScale * DamageAmount,
				    Instigator,
				    Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				    (damageScale * Momentum * dir),
				    DamageType
			    );

			    if(pawn(victims)!=none && pawn(victims).controller!=none && playercontroller(pawn(victims).controller)!=none && flash!=vect(0,0,0))
                    playercontroller(pawn(victims).controller).clientflash(0.1, flash*damagescale);
		    }
		}
	}
	bHurtEntry = false;
}

state NuclearExplosion
{
    function Fire( optional float F ) {}
	function BlowUp(vector HitLocation) {}
	function ServerBlowUp() {}


	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							vector momentum, class<DamageType> damageType) {}

    function BeginState()
    {
        local rotator rot;
        local vector loc;
		local int i;
		local FX_Shroomcloud cloud;
        bHidden = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
        bDynamicLight=true;
        Spawn(class'CSAPVerIV.FX_NukeFlash',,, Location, Rotation);
        loc=location+vect(0,0,1)*512;
        //Mushroom-Cloud
        for(i=0; i<8; i++)
        {
            cloud=none;
            loc=location+vect(0,0,1)*512;
            rot.yaw=(8187)*i;
            cloud=Spawn(class'CSAPVerIV.FX_Shroomcloud',,,location+vector(rot)*420, Rot);
            cloud.Velocity=vect(0,0,1)*260;
        }
        Spawn(class'CSAPVerIV.FX_NukeExplosionA',,, Location, rotator(vect(0,0,0)));
        ShakeView();
		InitialState = 'NuclearExplosion';
		if (Trail != None )
			Trail.Destroy();
		expstart=level.TimeSeconds;
        settimer(0.1, true);
    }

    simulated function timer()
    {
		local float h;
		local FX_NukeCloudWave wave;
        if(level.TimeSeconds<expstart+2) lightbrightness=(level.timeseconds-expstart)*255;
        else lightbrightness=fmax(0,255-(level.timeseconds-(expstart+2))*26);
        //Cloudwaves
        if(level.TimeSeconds>expstart+2 && level.TimeSeconds<expstart+4 && frand()<0.2)
        {
            h=2400*(((level.timeseconds-expstart)-2)/2);
            wave=Spawn(class'CSAPVerIV.FX_NukeCloudWave',,,Location+vect(0,0,1)*h);
            wave.emitters[0].SizeScale[1].relativesize= 6+(50+rand(20))*(level.timeseconds-(expstart+2))*(1-h/2400);
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
                if ( Dist < DamageRadius * 2.0)
                {
                    if (Dist < DamageRadius)
                        Scale = 1.0;
                    else
                        Scale = (DamageRadius*2.0 - Dist) / (DamageRadius);
                    C.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
                }
            }
        }
    }

Begin:
    //NeutronFlash
    DmgRadius(vect(10000,11000,12000), 0, 0.9, Damage*0.01, DamageRadius, class'CSAPVerIV.DamType_NukeFlash', MomentumTransfer*0, Location);
    //RelinquishController();
    Sleep(0.2);
    PlaySound(sound'APVerIV_Snd.NKBoom',SLOT_None,5*TransientSoundVolume);
    PlaySound(sound'APVerIV_Snd.NKRing',SLOT_None,1.0*TransientSoundVolume,false,TransientSoundRadius*1.5,0.3+frand()*0.7);
    PlaySound(sound'APVerIV_Snd.NKRing',SLOT_None,1.25*TransientSoundVolume,false,TransientSoundRadius*1.6,0.3+frand()*0.5);
    PlaySound(sound'APVerIV_Snd.NKRing',SLOT_None,1.5*TransientSoundVolume,false,TransientSoundRadius*1.7,0.3+frand()*0.3);
    PlaySound(sound'APVerIV_Snd.NKDistantBoom',SLOT_None,3*TransientSoundVolume,false,TransientSoundRadius*4);
    //Shockwave+Heat
    DmgRadius(vect(500,400,100), 0.2, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.20, Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    DmgRadius(vect(500,400,100), 0.2, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.19, Damage*0.975, DamageRadius*0.213, MyDamageType, MomentumTransfer*0.975, Location);
    Sleep(0.2);
    DmgRadius(vect(500,400,100), 0.2, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.18, Damage*0.9, DamageRadius*0.300, MyDamageType, MomentumTransfer*0.9, Location);
    Sleep(0.2);
    DmgRadius(vect(500,400,100), 0.2, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.17, Damage*0.85, DamageRadius*0.388, MyDamageType, MomentumTransfer*0.85, Location);
    Sleep(0.2);
    DmgRadius(vect(500,400,100), 0.2, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.16, Damage*0.8, DamageRadius*0.475, MyDamageType, MomentumTransfer*0.8, Location);
    Sleep(0.2);
    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.15, Damage*0.7, DamageRadius*0.563, MyDamageType, MomentumTransfer*0.7, Location);
    Sleep(0.2);
    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.14, Damage*0.6, DamageRadius*0.650, MyDamageType, MomentumTransfer*0.6, Location);
    Sleep(0.2);
    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.13, Damage*0.45, DamageRadius*0.738, MyDamageType, MomentumTransfer*0.45, Location);
    Sleep(0.2);
    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.12, Damage*0.3, DamageRadius*0.825, MyDamageType, MomentumTransfer*0.3, Location);
    Sleep(0.2);
    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.11, Damage*0.1, DamageRadius*0.913, MyDamageType, MomentumTransfer*0.1, Location);
    Sleep(0.2);
    DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/10)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    DmgRadius(vect(0,0,0), 1, 0.10, Damage*0.05, DamageRadius*1.000, MyDamageType, MomentumTransfer*0.05, Location);
    //Heat only
    while(level.TimeSeconds<expstart+13)
    {
        Sleep(0.2);
        DmgRadius(vect(500,400,100), 0.25, 0.50, (Damage/2)*(1-((level.TimeSeconds-expstart)/13)), 0.35*DamageRadius, class'CSAPVerIV.DamType_NukeHeat', MomentumTransfer*-0.2, Location);
    }

    Sleep(5);
    Destroy();
}

defaultproperties
{
     ShakeRotMag=(Z=300.000000)
     ShakeRotRate=(Z=3500.000000)
     ShakeRotTime=12.000000
     ShakeOffsetMag=(Z=15.000000)
     ShakeOffsetRate=(Z=300.000000)
     ShakeOffsetTime=20.000000
     ExplodeTimer=99999.000000
     DampenFactor=0.150000
     DampenFactorParallel=0.300000
     Health=20.000000
     Speed=3000.000000
     MaxSpeed=3000.000000
     Damage=1800.000000
     DamageRadius=5000.000000
     MomentumTransfer=500000.000000
     MyDamageType=Class'CSAPVerIV.DamType_NukeShock'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=40
     LightSaturation=192
     LightRadius=128.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RedeemerMissile'
     bNetTemporary=False
     AmbientSound=Sound'WeaponSounds.Misc.redeemer_flight'
     LifeSpan=20.000000
     DrawScale=0.600000
     DrawScale3D=(X=1.200000,Y=0.500000,Z=0.500000)
     AmbientGlow=96
     SoundVolume=255
     SoundRadius=100.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=5000.000000
     CollisionRadius=24.000000
     CollisionHeight=12.000000
     bProjTarget=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_DragAlong
     ForceRadius=100.000000
     ForceScale=5.000000
}
