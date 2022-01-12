class CSPallasMortarShell extends ONSMortarShell;

#exec AUDIO IMPORT FILE=Sounds\shellambient.wav

var() float DampenFactor, DampenFactorParallel;
var bool bCanHitOwner, bHitWater;
var class<Projectile> SmallShellClass;
var CSPallasShockBall ONSShockBallEffect;

simulated function PostBeginPlay()
{
	local PlayerController PC;
    local Rotator R;

    Super(Projectile).PostBeginPlay();
	R = Rotation;
	R.Roll = 32768;
    SetRotation(R);

    if ( Level.NetMode != NM_DedicatedServer)
    {
		PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5500 )
			Trail = Spawn(class'CSPallasSparkles', self,, Location, Rotation);
			Glow = Spawn(class'FlakGlow', self);
            ONSShockBallEffect = Spawn(class'CSPallasV2.CSPallasShockBall', self);
            if(Trail != None)
                Trail.Setbase(self);
            if(Glow != None)
                Glow.Setbase(self);

            if(ONSSHockBallEffect != None)
                ONSShockBallEffect.SetBase(self);

    }

    if ( Role == ROLE_Authority )
    {
        Velocity = Speed * Vector(Rotation);
        RandSpin(900000);
        bCanHitOwner = false;
        if (Instigator.HeadVolume.bWaterVolume)
        {
            bHitWater = true;
            Velocity = 0.6*Velocity;
        }
    }
}

simulated function Timer()
{
    local int i;
    local Projectile SmallShell;

	PlaySound(sound'ONSBPSounds.Artillery.ShellBrakingExplode');
    for (i=0; i<12; i++)
    {
        SmallShell = spawn(SmallShellClass, self, , Location, Rotation);
		if ( SmallShell != None )
			SmallShell.Velocity = Velocity + (VRand() * 400.0);
    }
    bExploded = true;
    Destroy();
}


event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    if (Damage > 0 && (EventInstigator == None || EventInstigator.Controller == None ||
                       Instigator == None || Instigator.Controller == None ||
                       !EventInstigator.Controller.SameTeamAs(Instigator.Controller)))
    {
        ExplodeInAir();
    }
}

simulated function SpawnEffects(vector HitLocation, vector HitNormal)
{
    PlaySound(sound'WeaponSounds.ShockRifle.ShockComboFire',,3.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(class'ShockComboVortex',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'CSPallasVortex',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'ShockCombo',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'CSPallasSphereDark',,, HitLocation, rotator(vect(0,0,1)));

        Spawn(class'CSPallasExplosionRing',,, HitLocation, rotator(vect(0,0,1)));

        Spawn(class'CSPallasExplosionRing',,, HitLocation + (VRand()*10.0), rotator(vect(0,0,1)));
        Spawn(class'CSPallasExplosionRing',,, HitLocation + (VRand()*10.0), rotator(vect(0,0,1)));
        Spawn(class'CSPallasExplosionRing',,, HitLocation + (VRand()*10.0), rotator(vect(0,0,1)));
        Spawn(class'CSPallasExplosionRing',,, HitLocation + (VRand()*10.0), rotator(vect(0,0,1)));
        Spawn(class'CSPallasExplosionRing',,, HitLocation + (VRand()*10.0), rotator(vect(0,0,1)));

        Spawn(class'ShockComboExpRing',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'ShockComboFlash',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'IonCannonDeathEffect',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'CSPallasFlashExplosion',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(class'ONSTankHitRockEffect',,, HitLocation, rotator(vect(0,0,1)));
        Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    BlowUp(HitLocation);
    Destroy();
}

simulated function Destroyed()
{
	if ( Trail != None )
		Trail.mRegen=False;
	if ( glow != None )
		Glow.Destroy();

    if(ONSShockBallEffect != None)
        ONSShockBallEffect.Destroy();

	Super.Destroyed();
}

function float MaxRange()
{
	return 100000;
}

defaultproperties
{
     DampenFactor=0.500000
     DampenFactorParallel=0.800000
     SmallShellClass=Class'CSPallasV2.CSPallasMortarShellFrag'
     ExplosionEffectClass=None
     AirExplosionEffectClass=None
     Speed=8850.000000
     MaxSpeed=8850.000000
     TossZ=0.000000
     Damage=1000.000000
     DamageRadius=1800.000000
     MomentumTransfer=600000.000000
     MyDamageType=Class'CSPallasV2.CSPallasDamTypeMortarShell'
     ImpactSound=ProceduralSound'WeaponSounds.PGrenFloor1.P1GrenFloor1'
     ExplosionDecal=Class'CSPallasV2.CSPallasImpactScorch'
     MaxEffectDistance=100000.000000
     StaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
     CullDistance=0.000000
     AmbientSound=Sound'CSPallasV2.shellambient'
     DrawScale=0.500000
     Skins(0)=Shader'WarEffectsTextures.Particles.N_energy01_S_JM'
     AmbientGlow=255
     bFullVolume=True
     SoundRadius=2000.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=1500.000000
     DrawType=DT_None
}
