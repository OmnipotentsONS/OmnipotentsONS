class ArbalestIncendiaryGuidedWarhead extends ArbalestGuidedWarhead;

function BlowUp(vector HitLocation)
{

//	local PlayerController PC;
    local vector start;
    local rotator rot;
    local int i;
    local ArbalestFire FireBLOB;
	
	if ( Role == ROLE_Authority )
	{
		bHidden = true;

	PlaySound(sound'WeaponSounds.BExplosion5',, 2.5*TransientSoundVolume);

    if ( EffectIsRelevant(Location, false) )
    {
	Spawn(class'FireVehiclesV2Omni.IncendiarySmokeRing',,, Location, Rotation);
	Spawn(class'FireVehiclesV2Omni.IncendiarySmokeRing',,, Location, Rotation);
	Spawn(class'FireVehiclesV2Omni.IncendiarySmokeRing',,, Location, Rotation);
	Spawn(class'FireVehiclesV2Omni.IncendiarySmokeRing',,, Location, Rotation);
	Spawn(class'FireVehiclesV2Omni.IncendiarySmokeRing',,, Location, Rotation);
	Spawn(class'FireVehiclesV2Omni.IncendiarySmokeRing',,, Location, Rotation);
	Spawn(class'FireVehiclesV2Omni.IncendiarySmokeRing',,, Location, Rotation);
	Spawn(class'FireVehiclesV2Omni.IncendiarySmokeRing',,, Location, Rotation);
    }
	start = Location;
	if ( Role == ROLE_Authority )
	{
		HurtRadius(damage, 220, MyDamageType, MomentumTransfer, HitLocation);	
		for (i=0; i<8; i++)
		{
			rot = Rotation;
			rot.yaw += FRand()*32000-16000;
			rot.pitch += FRand()*32000-16000;
			rot.roll += FRand()*32000-16000;
			FireBLOB = Spawn( class 'ArbalestFire',, '', Start, rot);
		}
	}
		GotoState('Dying');
	}
}

state Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function Fire( optional float F ) {}
	function BlowUp(vector HitLocation) {}
	function ServerBlowUp() {}
	function Timer() {}
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType) {}

    function BeginState()
    {
		bHidden = true;
		bStaticScreen = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		Spawn(class'FireVehiclesV2Omni.FireballBlowup',,, Location, Rotation);
		if ( SmokeTrail != None )
			SmokeTrail.Destroy();
		ShakeView();
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
	Instigator = self;
    PlaySound(sound'WeaponSounds.BaseImpactAndExplosions.BExplosion2');
    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.5);
    HurtRadius(Damage, DamageRadius*0.300, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.475, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    RelinquishController();
    HurtRadius(Damage, DamageRadius*0.650, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.825, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);
    Destroy();
}

defaultproperties
{
     Damage=50.000000
     DamageRadius=1300.000000
     MomentumTransfer=0.000000
     AirSpeed=1900.000000
}