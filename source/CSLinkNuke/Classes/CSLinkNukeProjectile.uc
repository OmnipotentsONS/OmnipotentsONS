//class CSLinkNukeProjectile extends RocketProj;
class CSLinkNukeProjectile extends Projectile;

#exec AUDIO IMPORT FILE=Sounds\YEAAAHHHnukeMedQuality.wav

var	xEmitter SmokeTrail;
var Effects Corona;

var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset vie

var() float SuckAmount;
var() float SuckScale;
var() int CoreDamage;


var() bool bHealNodes;
var() bool bHealPlayers;
var() bool bHealVehicles;
var() int NodeDamage;

var actor HurtNode;

simulated function Destroyed()
{
	if ( SmokeTrail != None )
		SmokeTrail.mRegen = False;
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
    local vector Dir;
	if ( Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'RocketTrailSmoke',self);
		Corona = Spawn(class'RocketCorona',self);
	}


	bHealNodes = class'MutUseLinkNuke'.default.bHealNodes;
	bHealPlayers = class'MutUseLinkNuke'.default.bHealPlayers;
	bHealVehicles = class'MutUseLinkNuke'.default.bHealVehicles;
    CoreDamage = class'MutUseLinkNuke'.default.CoreDamage;
    NodeDamage = class'MutUseLinkNuke'.default.NodeDamage;

    Dir = vector(Rotation);
	Velocity = speed * Dir;
	if (PhysicsVolume.bWaterVolume)
	{
		Velocity=0.6*Velocity;
	}

	Super.PostBeginPlay();
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( Other != instigator && Other != Self)
		Explode(HitLocation,Vect(0,0,1));
}


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType)
{
    local int teamNum;
    teamNum = 0;

	if ( (Damage > 0) && ((InstigatedBy == None) || (InstigatedBy.Controller == None) || (Instigator == None) || (Instigator.Controller == None) || !InstigatedBy.Controller.SameTeamAs(Instigator.Controller)) )
	{
		//if ( (InstigatedBy == None) || DamageType.Default.bVehicleHit || (DamageType == class'Crushed') )
		if (InstigatedBy == None)
			BlowUp(Location);
		else
		{
            if ( Instigator != None && PlayerController(Instigator.Controller) != None )
            {
				PlayerController(Instigator.Controller).PlayRewardAnnouncement('Denied',1, true);
                teamNum = Instigator.Controller.GetTeamNum();

            }
			if ( instigatedBy != None && PlayerController(InstigatedBy.Controller) != None )
            {
				PlayerController(InstigatedBy.Controller).PlayRewardAnnouncement('Denied',1, true);
                teamNum = instigatedBy.Controller.GetTeamNum();
            }
            SpawnDeniedEffects(hitlocation, Normal(velocity));
            GotoState('Dying');
		}
	}
}

simulated function Landed( vector HitNormal )
{
    Explode(Location, HitNormal);
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
    Super.HitWall(HitNormal, Wall);
    Explode(Location, HitNormal);
}

simulated event FellOutOfWorld(eKillZType KillType)
{
	BlowUp(Location);
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
    MakeNoise(1.0);
}


simulated function Explode(vector HitLocation, vector HitNormal)
{
    SpawnEffects(HitLocation, Normal(Velocity));
	BlowUp(HitLocation);
    GotoState('Dying');
}

simulated function SpawnEffects(vector HitLocation, vector HitNormal)
{
    PlaySound(sound'CSLinkNuke.YEAAAHHHnukeMedQuality',,2.5*TransientSoundVolume);
    if(EffectIsRelevant(HitLocation, false))
    {
        if(Instigator != None && Instigator.GetTeamNum() == 1)
        {
            Spawn(class'CSLinkNuke.CSLinkNukeSphereBlue',,, HitLocation, rotator(vect(0,0,1)));
        }
        else
        {
            Spawn(class'CSLinkNuke.CSLinkNukeSphere',,, HitLocation, rotator(vect(0,0,1)));
        }
    }
}

simulated function SpawnDeniedEffects(vector HitLocation, vector HitNormal)
{
    if(EffectIsRelevant(HitLocation, false))
    {
        Spawn(class'RocketExplosion',,, HitLocation, rotator(vect(0,0,1)));
    }
}

function bool IsSameTeam(Actor Victim)
{
    local bool sameTeam;
    sameTeam = false;
    if(Instigator != None)
    {
        if(Pawn(Victim) != None && Pawn(Victim).GetTeamNum() == Instigator.GetTeamNum())
        {
            sameTeam = true;
        }
        else if(ONSVehicle(Victim) != None && ONSVehicle(Victim).GetTeamNum() == Instigator.GetTeamNum())
        {
            sameTeam = true;
        }
        else if(ONSManualGunPawn(Victim) != None && ONSManualGunPawn(Victim).GetTeamNum() == Instigator.GetTeamNum())
        {
            sameTeam = true;
        }
    }

    return sameTeam;
}

function HealRadius(float Radius, vector HitLocation)
{
    local actor Victim;
    local bool sameTeam;
    local actor healedNode;
    local bool bFlipNodes;

    sameTeam = false;
    healedNode = None;
    bFlipNodes = CSLinkNuke(Owner).bFlipNodes;

    foreach VisibleCollidingActors( class 'Actor', Victim, DamageRadius, HitLocation )
	{
        sameTeam = IsSameTeam(victim);

        if( (Victim != None) && (Victim != self) && (Victim.Role == ROLE_Authority))
        {
            if(bHealNodes && healedNode == None && (Victim.IsA('ONSPowerNode')) && ((bFlipNodes) || (!bFlipNodes && HurtNode == None)))
            {
                spawn(class'CSLinkNuke.CSLinkNukeNodeHealer', Victim);
                HealedNode = Victim;
            }
            else if(bHealNodes && healedNode == None && (Victim.IsA('ONSPowerNodeEnergySphere')) && ((bFlipNodes) || (!bFlipNodes && HurtNode == None)))
            {
                spawn(class'CSLinkNuke.CSLinkNukeNodeHealer', ONSPowerNodeEnergySphere(Victim).PowerNode);
                healedNode = Victim;
            }
            else if(bHealVehicles && sameTeam && (Victim.IsA('Vehicle')))
            {
                spawn(class'CSLinkNuke.CSLinkNukeVehicleHealer', Victim);

            }
            else if(bHealVehicles && sameTeam && (Victim.IsA('ONSManualGunPawn')))
            {
                spawn(class'CSLinkNuke.CSLinkNukeTurretHealer', Victim);

            }
            else if(bHealPlayers && sameTeam && (Victim.IsA('Pawn')))
            {
                spawn(class'CSLinkNuke.CSLinkNukePlayerHealer', Victim);
            }
        }
    }
}

/*
function ApplyMomentum(vector HitLocation, float Radius, float Momentum)
{
    local actor Victims;
    local float damageScale, dist;
	local vector momentumDir;
    local float appliedMomentum;

    foreach VisibleCollidingActors( class 'Actor', Victims, Radius, HitLocation )
	{
        appliedMomentum = momentum;
        if(Vehicle(Victims) != None)
            appliedMomentum = momentum*10.0;

        momentumDir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(momentumDir));
			momentumDir = momentumDir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/Radius);
			Victims.TakeDamage
			(
				0,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * momentumDir,
				(damageScale * Momentum * momentumDir),
				class'DamageType'
			);
    }
}
*/

simulated function TeamHurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
    local float appliedMomentum;
    local float appliedDamage;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
    appliedMomentum = momentum;
    appliedDamage = DamageAmount;

	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
        if(Pawn(Victims) != None && Instigator != None)
        {
            if(Pawn(Victims).GetTeamNum() == Instigator.GetTeamNum())
            {
                appliedDamage = 0;
                appliedMomentum = 0;
            }
            else if(Vehicle(Victims) != none)
            {
                appliedMomentum = momentum *10.0;
                appliedDamage = DamageAmount *10.0;
            }
        }
        if(ONSPowerCore(Victims) != None && Instigator != None)
        {
            if(ONSPowerCore(Victims).DefenderTeamIndex != Instigator.GetTeamNum())
            {
                appliedDamage = CoreDamage;
            }
        }
        if(ONSPowerNode(Victims) != None && Instigator != None)
        {
            //if(ONSPowerNode(Victims).DefenderTeamIndex != Instigator.GetTeamNum() && ONSPowerNode(Victims).Health > 0)
            if(ONSPowerNode(Victims).DefenderTeamIndex != Instigator.GetTeamNum() && ONSPowerNode(Victims).CoreStage != 4)
            {
                appliedDamage = NodeDamage;
                HurtNode = Victims;
            }
        }

		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
            //damageScale = damageScale *2.0;
            damageScale = 1.0;
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;
			Victims.TakeDamage
			(
				damageScale * appliedDamage,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * appliedMomentum * dir),
				DamageType
			);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(appliedDamage, DamageRadius, InstigatorController, DamageType, appliedMomentum, HitLocation);

		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;

        if(Pawn(Victims) != None && Instigator != None)
        {
            if(Pawn(Victims).GetTeamNum() == Instigator.GetTeamNum())
            {
                appliedDamage = 0;
                appliedMomentum = 0;
            }
        }
        if(ONSPowerCore(Victims) != None && Instigator != None)
        {
            if(ONSPowerCore(Victims).DefenderTeamIndex != Instigator.GetTeamNum())
            {
                appliedDamage = CoreDamage;
            }
        }
        if(ONSPowerNode(Victims) != None && Instigator != None)
        {
            //if(ONSPowerNode(Victims).DefenderTeamIndex != Instigator.GetTeamNum() && ONSPowerNode(Victims).Health > 0)
            if(ONSPowerNode(Victims).DefenderTeamIndex != Instigator.GetTeamNum() && ONSPowerNode(Victims).CoreStage != 4)
            {
                appliedDamage = NodeDamage;
                HurtNode = Victims;
            }
        }

		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;
		//damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
        damageScale = 1.0;
		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(InstigatorController);
		Victims.TakeDamage
		(
			damageScale * appliedDamage,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
			(damageScale * appliedMomentum * dir),
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(appliedDamage, DamageRadius, InstigatorController, DamageType, appliedMomentum, HitLocation);
	}

	bHurtEntry = false;
}


simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
    TeamHurtRadius(DamageAmount, DamageRadius, DamageType, Momentum, HitLocation);
    HealRadius(DamageRadius, HitLocation);
}

state Dying
{
    function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
                        Vector momentum, class<DamageType> damageType) {}
	function Timer() {}

    function HitWall(vector HitNormal, actor Wall)
    {
    }

    function BeginState()
    {
		bHidden = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
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
    Sleep(0.8);
    //ApplyMomentum(Location, DamageRadius*SuckScale*1.0, SuckAmount);
    //Sleep(0.05);
    //ApplyMomentum(Location, DamageRadius*SuckScale*0.9, SuckAmount);
    //Sleep(0.05);
    //ApplyMomentum(Location, DamageRadius*SuckScale*0.8, SuckAmount);
    //Sleep(0.05);
    //ApplyMomentum(Location, DamageRadius*SuckScale*0.7, SuckAmount);
    //Sleep(0.05);
    //ApplyMomentum(Location, DamageRadius*SuckScale*0.6, SuckAmount);
    //Sleep(0.05);
    //ApplyMomentum(Location, DamageRadius*SuckScale*0.5, SuckAmount);
    //Sleep(0.05);
    //ApplyMomentum(Location, DamageRadius*SuckScale*0.4, SuckAmount);
    //Sleep(0.05);
    //ApplyMomentum(Location, DamageRadius*SuckScale*0.3, SuckAmount);
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
     SuckAmount=-40000.000000
     SuckScale=1.800000
     Speed=1000.000000
     MaxSpeed=1000.000000
     Damage=300.000000
     CoreDamage=6000
     NodeDamage=5000
     DamageRadius=1750.000000
     //MomentumTransfer=200000.000000
     MomentumTransfer=1000000.000000
     MyDamageType=Class'CSLinkNuke.CSLinkNukeDamTypeLinkNuke'
     ExplosionDecal=Class'XEffects.ShockImpactScorch'
     MaxEffectDistance=14000.000000
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=28
     LightBrightness=255.000000
     LightRadius=6.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'CSLinkNuke.RedeemerMissile'
     CullDistance=8000.000000
     bDynamicLight=True
     bNetTemporary=False
     AmbientSound=Sound'WeaponSounds.Misc.redeemer_flight'
     LifeSpan=20.000000
     DrawScale=0.500000
     AmbientGlow=96
     bUnlit=False
     FluidSurfaceShootStrengthMod=10.000000
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
