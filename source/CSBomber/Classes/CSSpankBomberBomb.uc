
class CSSpankBomberBomb extends Projectile;

var int PawnMomentumTransfer;
var CSSpankBomberBombEffect ONSShockBallEffect;
//var() Sound PopSound;
var() Sound UltraPopSound;
//#exec AUDIO IMPORT FILE=Sounds\bigpop.wav
#exec AUDIO IMPORT FILE=Sounds\hugepop.wav

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
	{
        ONSShockBallEffect = Spawn(class'CSSpankBomberBombEffect', self);
        ONSShockBallEffect.SetBase(self);
	}

    if(Role == ROLE_Authority)
    {
        //Velocity = Speed * Vector(Rotation); 
        if(Instigator != None)
        {
            Velocity =Instigator.Velocity * 0.9;
            Velocity.Z += -30;
        }
        //RandSpin(900000);
    }
    SetTimer(0.4,false);
}

function Timer()
{
    SetCollisionSize(80,80);
}

simulated function Destroyed()
{
    if (ONSShockBallEffect != None)
    {
        ONSShockBallEffect.Destroy();
	}
	Super.Destroyed();

}

simulated function DestroyTrails()
{
    if (ONSShockBallEffect != None)
        ONSShockBallEffect.Destroy();
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
    Explode(Location + ExploWallOut * HitNormal, HitNormal);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( Other != Instigator )
		Explode(HitLocation,Normal(HitLocation-Other.Location));
}

simulated function Landed( vector HitNormal )
{
	HitWall(HitNormal, None);
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
    UltraExplosion();
}

function UltraExplosion()
{
	local actor HitActor;
	local vector HitLocation, HitNormal;

	HurtRadius(Damage*5, DamageRadius*2.5, MyDamageType, MomentumTransfer*2.5, Location );

    Spawn(class'CSSpankBomberBombExplosion');
	if ( (Level.NetMode != NM_DedicatedServer) && EffectIsRelevant(Location,false) )
	{
		HitActor = Trace(HitLocation, HitNormal,Location - Vect(0,0,120), Location,false);
		if ( HitActor != None )
			Spawn(class'ComboDecal',self,,HitLocation, rotator(vect(0,0,-1)));
	}
	PlaySound(UltraPopSound, SLOT_None,1.5,,1200);
    DestroyTrails();
    Destroy();
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float dist, damageScale;
	local vector dir;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') && Victims != Instigator)
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;

            Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				vect(0,0,0),
				DamageType
			);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, 0, HitLocation);                

            dir.Z = Abs(dir.Z);
            if(XPawn(Victims) != None)
            {
                XPawn(Victims).SetPhysics(PHYS_Falling);
                XPawn(Victims).AddVelocity(Normal(dir)*PawnMomentumTransfer);
            }
            else
            {
                Victims.KAddImpulse(Normal(dir)*MomentumTransfer, HitLocation);
            }
		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') && LastTouched != Instigator)
	{
		Victims = LastTouched;
		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;

        Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
			vect(0,0,0),
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, 0, HitLocation);

        dir.Z = Abs(dir.Z);

        if(XPawn(Victims) != None)
        {
            XPawn(Victims).SetPhysics(PHYS_Falling);
            XPawn(Victims).AddVelocity(Normal(dir)*PawnMomentumTransfer);
        }
        else
        {
            Victims.KAddImpulse(Normal(dir)*MomentumTransfer, HitLocation);
        }
	}

	bHurtEntry = false;
}

simulated function BlowUp(vector HitLocation)
{
	DelayedHurtRadius(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    if(Damage > 0)
    {
        UltraExplosion();
    }
}

defaultproperties
{
    bNetTemporary=false
    bOnlyDirtyReplication=true

    bProjTarget=true
    //bBounce=true
    bBounce=false
    Speed=3850.0
    MaxSpeed=3850.0
    Damage=95
    MomentumTransfer=2000000
    PawnMomentumTransfer=80000
    TossZ=0.0
	DamageRadius=400.0
    UltraPopSound=sound'CSBomber.hugepop'
   AmbientSound=sound'CSBomber.BombDrop'
   SoundVolume=255

     DesiredRotation=(Pitch=9000000,Yaw=9000000,Roll=9000000)
    //CollisionRadius=60.0
	//CollisionHeight=30.0
    CollisionRadius=0.0
	CollisionHeight=0.0
    bFixedRotationDir=true
    Skins(0)=None
    Texture=None
    MyDamageType=Class'CSSpankBomberDamTypeBomb'
    AmbientGlow=255
    FluidSurfaceShootStrengthMod=3.00000    
    DrawType=DT_None
    Lifespan=16.0
    Physics=PHYS_Falling
}