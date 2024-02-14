class PROJ_ReaperMissle extends PROJ_PredatorMissle;
#exec OBJ LOAD FILE=..\StaticMeshes\APVerIV_ST.usx


simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(sound'WeaponSounds.BExplosion3',, 2.5*TransientSoundVolume);

	if ( TrailEmitter != None )
	{
		TrailEmitter.Kill();
		TrailEmitter = None;
	}

    if ( EffectIsRelevant(Location, false) )
    {
    	Spawn(class'FX_SpaceFighter_Explosion',,, HitLocation + HitNormal*16, rotator(HitNormal));
        bDynamicLight=true;
        Spawn(class'CSAPVerIV.FX_NukeFlashFirst',,, Location, Rotation);
        Spawn(class'CSAPVerIV.FX_NukeFlash',,, Location, Rotation);
        Spawn(class'CSAPVerIV.FX_MissileHitGlow',,, Location, Rotation);

        PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation, rotator(HitNormal));

		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp(HitLocation+HitNormal*2.f);
	Destroy();
}

defaultproperties
{
     //Damage=165.000000
     //DamageRadius=550
     Damage=150.000000
     DamageRadius=500
     Speed=2300.000000
     MaxSpeed=4250.000000
     StaticMesh=StaticMesh'APVerIV_ST.AP_Weapons_ST.RLMissile'
     DrawScale=0.400000
}
