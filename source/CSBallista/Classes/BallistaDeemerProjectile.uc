class BallistaDeemerProjectile extends RedeemerProjectile;

var Emitter SmokeTrailEffect;
var Effects Corona;
var vector Dir;
var bool bHitWater;

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer)
	{
        SmokeTrailEffect = Spawn(class'ONSTankFireTrailEffect',self);
		Corona = Spawn(class'RocketCorona',self);
	}

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	if (PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity=0.6*Velocity;
	}
    if ( Level.bDropDetail )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	Super.PostBeginPlay();
}

simulated function Destroyed()
{
  //if (Role == ROLE_Authority && HomingTarget != None)
	//  	if(HomingTarget.IsA('Vehicle')) Vehicle(HomingTarget).NotifyEnemyLostLock();
	if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}

//Below copied from RedeemerFire
state Dying
{
    function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
                            Vector momentum, class<DamageType> damageType) {}
    function Timer() {}

    function BeginState()
    {
        bHidden = true;
        SetPhysics(PHYS_None);
        SetCollision(false,false,false);
        Spawn(class'IonCore',,, Location, Rotation);
        ShakeView();
        InitialState = 'Dying';
        if ( SmokeTrail != None )
            SmokeTrail.Destroy();
        SetTimer(0, false);
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
	// this is somewhat different than redeemer - pooty 5/24
	// first HR is more damaging
	// second happens faster
	// there's four stages vs. 6
    PlaySound(sound'WeaponSounds.redeemer_explosionsound');
    HurtRadius(Damage*1.35, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    //HurtRadius(Damage, DamageRadius*0.300, MyDamageType, MomentumTransfer, Location);
    //Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.5, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.750, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    //HurtRadius(Damage, DamageRadius*0.825, MyDamageType, MomentumTransfer, Location);
    //Sleep(0.2);
    HurtRadius(Damage, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);
    Destroy();
}




defaultproperties
{
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     ExplosionEffectClass=Class'CSBallista.BallistaExplosion'
     Team=255
     Speed=25000.000000
     MaxSpeed=27540.000000
     Damage=225.00000
     DamageRadius=2000.000000
     MomentumTransfer=80000.00000//50000.000000
     MyDamageType=Class'CSBallista.BallistaShell'
     ExplosionDecal=Class'Onslaught.ONSRocketScorch'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=28
     LightBrightness=255.000000
     LightRadius=6.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RocketProj'
     bDynamicLight=True
     bNetTemporary=False
     AmbientSound=Sound'VMVehicleSounds-S.HoverTank.IncomingShell'
     LifeSpan=1.300000
     AmbientGlow=96
     bUnlit=False
     FluidSurfaceShootStrengthMod=10.000000
     bFullVolume=True
     SoundVolume=255
     SoundRadius=1000.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=1000.000000
     bProjTarget=True
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
