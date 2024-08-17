//=============================================================================
//
//=============================================================================
class OmniRedeemerIIProjectile extends Projectile;
//#exec LOAD OBJ FILE=forcompile\siegesnds.uax PACKAGE=WGSNUKE
#exec LOAD OBJ FILE=OmniNukesSounds.uax

var	NewRedeemerTrail SmokeTrail;
var float ExpStart;
var float armor;

// camera shakes //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view

var class<Emitter> ExplosionEffectClass;

var byte Team;

replication
{
    reliable if (Role == ROLE_Authority && bNetOwner)
        armor, ExpStart;
}

simulated function Destroyed()
{
	if ( SmokeTrail != None )
		SmokeTrail.Destroy();
	Super.Destroyed();
}

function BeginPlay()
{
	Super.BeginPlay();

	if (Instigator != None)
		Team = Instigator.GetTeamNum();
	SetTimer(0.5, true);
}

simulated function PostBeginPlay()
{
	local vector Dir;

	if ( bDeleteMe || IsInState('Dying') )
		return;

	Dir = vector(Rotation);
	Velocity = speed * Dir;

	if ( Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'NewRedeemerTrail',self,,Location - 40 * Dir, Rotation);
		SmokeTrail.SetBase(self);
	}

	Super.PostBeginPlay();
}

event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry )
		return true;

	return false;
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( Other != instigator )
		Explode(HitLocation,Vect(0,0,1));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp(HitLocation);
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

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType)
{
	local controller c;

   if ( (Damage > 0) && ((InstigatedBy == None) || (InstigatedBy.Controller == None) || (Instigator == None) || (Instigator.Controller == None) || !InstigatedBy.Controller.SameTeamAs(Instigator.Controller)) )

	{
		if ( DamageType.Default.bVehicleHit || (DamageType == class'Crushed') )
			BlowUp(Location);
		else if(damage>=rand(armor))
		{
	 		Spawn(class'OmniNukes.OmniNukeFlash',,, Location, Rotation);
            Spawn(class'OmniNukes.OmniNukeExplo',,, Location, Rotation);
            PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKExp',SLOT_None,TransientSoundVolume/1.5,false,TransientSoundRadius/2);

		    SetCollision(false,false,false);
//		    HurtRadius(100, 400, MyDamageType, MomentumTransfer, Location);
		    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);

/*
		    for ( c = Level.ControllerList; c!=None; c=c.nextController )
            {
                if(playercontroller(c)!=none && c.PlayerReplicationInfo.team!=instigator.PlayerReplicationInfo.Team)
                    playercontroller(c).ReceiveLocalizedMessage(class'OmniNukes.OmniNukeUnWarnMsg');
            }
*/

		    Destroy();
		}
	}


}

simulated event FellOutOfWorld(eKillZType KillType)
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
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

      if (!fasttrace(Victims.Location, hitlocation)) damagescale*=dmgPctThru;

      if (InstigatorController!=None) 	Victims.SetDelayedDamageInstigatorController( InstigatorController );

      if (pawn(victims)==none)  damagescale*=dmgPctHard;

      Victims.TakeDamage(damageScale * DamageAmount,Instigator,	Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,(damageScale * Momentum * dir),DamageType);
			
			if(pawn(victims)!=none && pawn(victims).controller!=none && playercontroller(pawn(victims).controller)!=none && flash!=vect(0,0,0))
         playercontroller(pawn(victims).controller).clientflash(1-damagescale, flash);

      if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			   Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);

		}
	}

	bHurtEntry = false;
}

function Timer()
{
	local Controller C;

	//Enemies who don't have anything else to shoot at will try to shoot redeemer down
	for (C = Level.ControllerList; C != None; C = C.NextController)
		if ( AIController(C) != None && C.Pawn != None && C.GetTeamNum() != Team && AIController(C).Skill >= 2.0
		     && !C.Pawn.IsFiring() && (C.Enemy == None || !C.LineOfSightTo(C.Enemy)) && C.Pawn.CanAttack(self) )
		{
			C.Focus = self;
			C.FireWeaponAt(self);
		}
}

state Dying
{
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							vector momentum, class<DamageType> damageType) {}

    function BeginState()
    {
				bHidden = true;
				LightType=LT_Steady;
		    SetPhysics(PHYS_None);
				SetCollision(false,false,false);
				Spawn(class'IonCore',,, Location, Rotation);
				ShakeView();
				InitialState = 'Dying';
				if ( SmokeTrail != None ) 	SmokeTrail.Kill();
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
    DmgRadius(vect(10000,11000,12000), 0, 0.9, Damage*0.01, DamageRadius, class'OmniNukes.DamTypeOmniNukeFlash', MomentumTransfer*0, Location);

    //Sleep(0.2);
    PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKBoom',SLOT_None,5*TransientSoundVolume);
    PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKRing',SLOT_None,1.0*TransientSoundVolume,false,TransientSoundRadius*1.5,0.3+frand()*0.7);
    PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKRing',SLOT_None,1.25*TransientSoundVolume,false,TransientSoundRadius*1.6,0.3+frand()*0.5);
    PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKRing',SLOT_None,1.5*TransientSoundVolume,false,TransientSoundRadius*1.7,0.3+frand()*0.3);
    PlaySound(sound'OmniNukesSounds.OmniNukes.TFNKDistantBoom',SLOT_None,3*TransientSoundVolume,false,TransientSoundRadius*4);

    //Deemer code
    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.3);
    HurtRadius(Damage, DamageRadius*0.300, MyDamageType, MomentumTransfer, Location);
    Sleep(0.15);
    HurtRadius(Damage, DamageRadius*0.475, MyDamageType, MomentumTransfer, Location);
    Sleep(0.15);
    HurtRadius(Damage, DamageRadius*0.650, MyDamageType, MomentumTransfer, Location);
    Sleep(0.15);
    HurtRadius(Damage, DamageRadius*0.825, MyDamageType, MomentumTransfer, Location);
    Sleep(0.15);
    HurtRadius(Damage, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);

    //Shockwave
    DmgRadius(vect(0,0,0), 1, 0.40, Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    DmgRadius(vect(0,0,0), 1, 0.38, Damage*0.975, DamageRadius*0.213, MyDamageType, MomentumTransfer*0.975, Location);
    Sleep(0.15);
    DmgRadius(vect(0,0,0), 1, 0.36, Damage*0.9, DamageRadius*0.300, MyDamageType, MomentumTransfer*0.9, Location);
    Sleep(0.15);
    DmgRadius(vect(0,0,0), 1, 0.34, Damage*0.85, DamageRadius*0.388, MyDamageType, MomentumTransfer*0.85, Location);
    Sleep(0.15);
    DmgRadius(vect(0,0,0), 1, 0.32, Damage*0.8, DamageRadius*0.475, MyDamageType, MomentumTransfer*0.8, Location);
    Sleep(0.15);
//    DmgRadius(vect(0,0,0), 1, 0.30, Damage*0.7, DamageRadius*0.563, MyDamageType, MomentumTransfer*0.7, Location);
//    Sleep(0.2);
//    DmgRadius(vect(0,0,0), 1, 0.28, Damage*0.6, DamageRadius*0.650, MyDamageType, MomentumTransfer*0.6, Location);
//    Sleep(0.2);
    DmgRadius(vect(0,0,0), 1, 0.26, Damage*0.45, DamageRadius*0.738, MyDamageType, MomentumTransfer*0.45, Location);
    Sleep(0.1);
//    DmgRadius(vect(0,0,0), 1, 0.24, Damage*0.3, DamageRadius*0.825, MyDamageType, MomentumTransfer*0.3, Location);
//    Sleep(0.2);
     DmgRadius(vect(0,0,0), 1, 0.22, Damage*0.1, DamageRadius*0.9, MyDamageType, MomentumTransfer*0.1, Location);
//    Sleep(0.2);
     DmgRadius(vect(0,0,0), 1, 0.20, Damage*0.05, DamageRadius*1.000, MyDamageType, MomentumTransfer*0.05, Location);

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
     Armor=75.000000
     ShakeRotMag=(Z=500.000000)
     ShakeRotRate=(Z=3500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=20.000000)
     ShakeOffsetRate=(Z=1000.000000)
     ShakeOffsetTime=12.000000
     ExplosionEffectClass=Class'XEffects.RedeemerExplosion'
     Team=255
     Speed=1700.000000
     MaxSpeed=1800.000000
     Damage=375.000000
     DamageRadius=5000.000000
     MomentumTransfer=500000.000000
     MyDamageType=Class'OmniNukes.DamTypeOmniNukeRedeemerII'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=28
     LightBrightness=255.000000
     LightRadius=6.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RedeemerMissile'
     bDynamicLight=True
     bNetTemporary=False
     AmbientSound=Sound'OmniNukesSounds.OmniNukes.tfWarheadAmb'
     LifeSpan=20.000000
     DrawScale=0.500000
     AmbientGlow=96
     bUnlit=False
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
