class AP_AutoTurret extends Actor
    abstract;

var(Cannon) byte    Team;
var(Cannon) bool    bTeamCannon;
var(Cannon) float   FireInterval;
var(Cannon) float   Range;
var(Cannon) float   TargettingLatency;
var(Cannon) class<Projectile> ProjectileClass;
var(Cannon)travel int      Health;         // Health: 100 = normal maximum
var(Cannon)float	   MomentumTransfer; // Momentum magnitude imparted by impacting projectile.
var(Cannon)class<DamageType>	   MyDamageType;
var(Cannon)float    Damage;
var(Cannon)vector FireOffset;
var Actor           Target,A,NewEnemy;
var float           FireCountDown;
var float           TargettingCountDown;
// Damage attributes.

var	  float	   DamageRadius;
var Emitter ExplosionEffect;
var class<Emitter> ExplosionEffectClass;
var Controller C;
var rotator TurretRot;
var rotator AimDir;
var vector MuzSpawnOffset;
var vector firetest;
var float Closest,NewClosest;
var float TargetDist, ProjSpeed;
var vector FireSpot,TargetVel;
var vector HitLocation, HitNormal;
var actor HitActor;
var emitter Muzflash;

//---BeamWeapons
var class<DamageType> DamageType;
var int DamageMin, DamageMax;
var float TraceRange;
var float Momentum;
var() bool  bReflective;
var() float DamageAtten; // attenuate instant-hit/projectile damage by this multiplier
var rotator AimBoneRotation;

// static base
var		class<AP_TurretBase>	TurretBaseClass;
var		AP_TurretBase			TurretBase;
var vector BaseOffset;
var		rotator					OriginalRotation;
//----------------------------------------------
//Bone Names
var name            YawBone;
var name            PitchBone;
var name            FirePointBone;
//----------------------------------------------
var sound FireSound;
var name  FireAnim;
var vector WeaponFireLocation;
var Vehicle V;

replication
{
  reliable if( bNetInitial && Role==ROLE_Authority )
        ProjectileClass;

  reliable if( bNetDirty && Role==ROLE_Authority )
         Health;
  reliable if( Role==ROLE_Authority )
         AimDir,Team,Target,TraceRange,Range;

}
Simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
}

simulated event PostNetBeginPlay()
{
	// static (non rotating) base
	if ( TurretBaseClass != None )
		TurretBase = Spawn(TurretBaseClass, Self,, Location + BaseOffset, OriginalRotation);
	super.PostNetBeginPlay();
}

function bool IsNewTargetRelevant( Actor Target )
{
if ( (Target != None) && (Target.IsA('Vehicle') && Vehicle(Target).Controller != None) && (Vehicle(Target).GetTeamNum()!=Team) && (Vehicle(Target).Health > 0) && VSize(Target.Location-Location) < Range )
		  return true;

	return false;
}
simulated event SetTeam(byte NewTeam)
{
  Team=NewTeam;
}

simulated function int GetTeamNum()
{
  return Team;
}

function Fire();

event SeeEnemy( Actor SeenEnemy );

auto state FindEnemy
{
     event SeeEnemy( Actor SeenEnemy )
	      {
		   if ( IsNewTargetRelevant( SeenEnemy ) )
		      {
			   NewEnemy = SeenEnemy;
			   GotoState('Engaged');
		      }
	      }
     function SelectTarget()
        {
         //don't start till game has begun
         if(Level.Game.GameReplicationInfo.bMatchHasBegun==false)
            return;
         // select nearest controlled Vehicle
         foreach CollidingActors(class'Vehicle', V,Range )
		     {
			  if(V != None)
                {
                 HitActor = Trace(HitLocation, HitNormal,V.Location);
                 if (HitActor == V)
                    {
                     Target=V;
                     SeeEnemy(Target);
                    }
                 else
                  continue;
                }
             }

              // aim at the Enemy
              if (Target != none)
                 {
                  if (ProjSpeed != ProjectileClass.default.speed)
                      ProjSpeed=ProjectileClass.default.speed;

                  FireSpot = Target.Location;
                  TargetVel=Target.Velocity;
                  TargetDist = Closest;
                  FireSpot += FMin(0.2, 0.7 + 0.6 * FRand()) * TargetVel * TargetDist/projSpeed;
	              FireSpot.Z = FMin(Target.Location.Z, FireSpot.Z);
                }
      }

     function BeginState()
	  {
	    NewEnemy = None;
	  }

Begin:
	SelectTarget();
	Sleep(0.10);
	Goto('Begin');
}

state Engaged
{
	function BeginState()
	{
		 // aim at the Enemy
          if (NewEnemy != none)
             {
              if (ProjSpeed != ProjectileClass.default.speed)
                  ProjSpeed=ProjectileClass.default.speed;

                  FireSpot = NewEnemy.Location;
                  TargetVel=NewEnemy.Velocity;
                  TargetDist = Closest;
                  //FireSpot += FMin(0.2, 0.7 + 0.6 * FRand()) * TargetVel * TargetDist/projSpeed;
	              //FireSpot.Z = FMin(NewEnemy.Location.Z, FireSpot.Z);
              }
        if (FireCountDown < 0 && NewEnemy != none)
           {
             FireCountDown = 0;
             Fire();
           }
	}

Begin:
	Sleep(0.10);
	if ( NewEnemy==none)
		GotoState('FindEnemy');
		BeginState();
	Goto('Begin');
}

function Tick(float DeltaTime)
{
  local Bot B;

     for ( C=Level.ControllerList; C!=None; C=C.NextController )
	     {
		   B = Bot(C);
		   if ( (B != None) && B.GetTeamNum() != Team && (B.Pawn != None))
			  {
			    // give B a chance to shoot at me
			    B.GoalString = "Destroy Turret";
			    B.Target = self;
			    B.Focus = self;
				B.FireWeaponAt(self);
                B.SwitchToBestWeapon();
			    if ( B.Pawn.CanAttack(self) )
			       {
				    B.DoRangedAttackOn(self);
				    if ( FRand() < 0.5 )
						break;
			        }
			   }
		  }
           Closest = Range;
           // select current target, with latency
           TargettingCountDown += DeltaTime;
            if (TargettingCountDown >= TargettingLatency)
                    {
                     TargettingCountDown -= TargettingLatency;
                     AimDir = Rotator(FireSpot - Location);
                     if (Rotation!= AimDir)
                         SetRotation(AimDir);
                    }
             // fire at the current target, if any
		     FireCountDown -= DeltaTime;
}



function float MaxRange()
{
	return TraceRange;
}

//==============================================================================
// Damage Systems
//==============================================================================
//-----------------------------------
// Damage Taken From Enemy Fire

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation,
						vector momentum, class<DamageType> damageType)
{
     Instigator = InstigatedBy;
	 Spawn(Class'XEffects.xHeavyWallHitEffect',,, hitLocation, Rotator(-momentum));
	  spawn(class'FlakExplosion',,,HitLocation, Rotator(-momentum));
     PlaySound(Sound'XEffects.Impact2Snd', SLOT_None,,,,, false);
    // Avoid damage healing the Fighter
    Instigator = InstigatedBy;
	if(Damage < 0)
		return;
if(damageType == class'DamTypeSuperShockBeam')
		Health -= 100; // Instagib doesn't work on vehicles
	else
		Health -= 1 * Damage; // Weapons do less damage
         // DamageCheck();
	// Cannon is busted so need to destroy it...
	if(Health <= 0)
	{
		BlowUp(location);
		Destroy(); // Destroy the vehicle itself (see Destroyed below)
	}
}

//-----------------------------------
// Server Blows up APFighter
function ServerBlowUp()
{
	BlowUp(Location);
}
//-----------------------------------
// Blowup Effects
function BlowUp(vector HitLocation)
{
	if ( Role == ROLE_Authority )
	{
		bHidden = true;
        GotoState('Dying');
	}
}

simulated event Destroyed()
{
	if ( TurretBase != None )
		 TurretBase.Destroy();
	super.Destroyed();
}
//--------------------------------------
//Dying state Calls Damage and destroys Cannon
state Dying
{
	function BlowUp(vector HitLocation) {}
	function ServerBlowUp() {}
	function Timer() {}
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							vector momentum, class<DamageType> damageType) {}


    function BeginState()
    {
    local vector start;

		bHidden = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, Location );
        ExplosionEffect= Spawn(ExplosionEffectClass, Self,, Location, Rotation);
        start = Location + 10 * Normal(Velocity);

        spawn(class'RocketSmokeRing',,,Location + Normal(Velocity)*16 );
   }

Begin:
    PlaySound(sound'WeaponSounds.redeemer_explosionsound');
    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.5);
    HurtRadius(Damage, DamageRadius*0.300, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.475, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);

    HurtRadius(Damage, DamageRadius*0.650, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.825, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);
    Destroy();
    Super.destroyed();
}

function DoFireEffect()
{
    local Vector StartTrace;
    StartTrace = WeaponFireLocation + FireOffset;
    DoTrace(StartTrace, AimDir);
}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local int Damage;
    local bool bDoReflect;
    local int ReflectNum;

    ReflectNum = 0;
    while (true)
    {
        bDoReflect = false;
        X = Vector(Dir);

        End = Start + TraceRange * X;

        Other = Trace(HitLocation, HitNormal, End, Start, true);

        if ( Other != None)
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = true;
                HitNormal = Vect(0,0,0);
            }
            else if (!Other.bWorldGeometry)
            {
				Damage = DamageMin;
				if ( (DamageMin != DamageMax) && (FRand() > 0.5) )
					Damage += Rand(1 + DamageMax - DamageMin);
                Damage = Damage * DamageAtten;
                Other.TakeDamage(Damage, none, HitLocation, Momentum*X, DamageType);
                HitNormal = Vect(0,0,0);
            }
           }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
        }

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);
        if (bDoReflect && ++ReflectNum < 4)
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start = HitLocation;
            Dir = Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum);

defaultproperties
{
     Range=16000.000000
     TargettingLatency=0.010000
     MyDamageType=Class'CSAPVerIV.DamType_FighterMissile'
     Damage=60.000000
     firetest=(Z=32.000000)
     bCanBeDamaged=True
     bClientAnim=True
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
}
