// ============================================================================
// LinkFlyer                                                        ItsMeAgain
// Weapon, Mostly copied from LinkTank
// ============================================================================
class LinkFlyerWeapon extends ONSWeapon;

// ============================================================================
// Properties
// ============================================================================
var() array<Material> LinkSkin_Gold, LinkSkin_Green, LinkSkin_Red, LinkSkin_Blue;
var() int LinkBeamSkin;
var() sound LinkedFireSound;

// ============================================================================
// CPed from LinkFire
// ============================================================================
var(LinkBeam) class<LinkBeamEffect> BeamEffectClass;
var(LinkBeam) Sound MakeLinkSound;
var(LinkBeam) float LinkBreakDelay;
var(LinkBeam) float MomentumTransfer;
var(LinkBeam) class<DamageType> AltDamageType;
var(LinkBeam) int   AltDamage;
var(LinkBeam) String MakeLinkForce;
var(LinkBeam) float LinkFlexibility;
var(LinkBeam) byte  LinkVolume;
var(LinkBeam) Sound BeamSounds[4];
var(LinkBeam) float VehicleDamageMult;

// ============================================================================
// Internal vars
// ============================================================================
//var LinkBeamEffect Beam;

// CPed from LinkFire
var float UpTime;
var Pawn  LockedPawn;
var float LinkBreakTime;

var bool bInitAimError;
var bool bDoHit;
var bool bFeedbackDeath;
var bool bLinkFeedbackPlaying;
var bool bStartFire;

var byte    SentLinkVolume;
var rotator DesiredAimError, CurrentAimError;
var Sound   OldAmbientSound;

// CPed from WraithBellyGun Vampire
var() float SelfHealMultiplier;

// ============================================================================
// Replication
// ============================================================================
//replication
//{
//    reliable if (Role == ROLE_Authority)
//        Beam;
//}

// ============================================================================
// UpdateLinkColor
// ============================================================================
simulated function UpdateLinkColor(LinkAttachment.ELinkColor Color)
    {
    switch (Color)
        {
        case LC_Gold:    Skins[LinkBeamSkin]=LinkSkin_Gold[Team];        break;
        case LC_Green:    Skins[LinkBeamSkin]=LinkSkin_Green[Team];        break;
        case LC_Red:     Skins[LinkBeamSkin]=LinkSkin_Red[Team];        break;
        case LC_Blue:     Skins[LinkBeamSkin]=LinkSkin_Blue[Team];        break;
        }
    Skins[0]=Combiner'AS_Weapons_TX.LinkTurret.LinkTurret_Skin2_C';
    }

// ============================================================================
// Spawn projectile. Adjust link properties if needed.
// ============================================================================
function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
    {
    local Projectile SpawnedProjectile;
    local int NumLinks;

    if (ONSLinkFlyer(Owner)!=None)
        NumLinks=ONSLinkFlyer(Owner).GetLinks();
    else
        NumLinks=0;

    // Swap out fire sound
    if (NumLinks>0)
        FireSoundClass=LinkedFireSound;
    else
        FireSoundClass=default.FireSoundClass;

    SpawnedProjectile=Super.SpawnProjectile(ProjClass, bAltFire);
    if (PROJ_LinkTurret_Plasma(SpawnedProjectile)!=None)
        {
        PROJ_LinkTurret_Plasma(SpawnedProjectile).Links=NumLinks;
        PROJ_LinkTurret_Plasma(SpawnedProjectile).LinkAdjust();
        }

    return SpawnedProjectile;
    }

// ============================================================================
// Spawn/find link beam
// ============================================================================
function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
    {
    local LinkBeamEffect ThisBeam;
    local LinkBeamEffect FoundBeam;

    if (ONSLinkFlyer(Owner)!=None)
        FoundBeam=ONSLinkFlyer(Owner).Beam;

    if (FoundBeam==None||FoundBeam.bDeleteMe)
        {
        foreach DynamicActors(class'LinkBeamEffect', ThisBeam)
            if (ThisBeam.Instigator==Instigator)
                FoundBeam=ThisBeam;
        }

    if (FoundBeam==None)
        {
        FoundBeam=Spawn(BeamEffectClass, Owner, , WeaponFireLocation);
        if (ONSLinkFlyer(Owner)!=None)
            ONSLinkFlyer(Owner).Beam=FoundBeam;
        }

    //if (LinkFlyerBeamEffect(Beam) != None)
    //    LinkFlyerBeamEffect(Beam).WeaponOwner = self;

    bDoHit=true;
    UpTime=AltFireInterval+0.1;
    }

// ============================================================================
// Start fire
// ============================================================================
simulated function ClientStartFire(Controller C, bool bAltFire)
    {
    //log(self@"client start fire alt"@bAltFire,'KDebug');
    Super.ClientStartFire(C, bAltFire);

    // Write UpTime here in the client
    if (bAltFire && Role<ROLE_Authority)
        {
        UpTime=AltFireInterval+0.1;
        //log("UpTime is now"@UpTime,'KDebug');
        }
    }

// ============================================================================
// Cease fire, destroy link beam
// ============================================================================
function WeaponCeaseFire(Controller C, bool bWasAltFire)
    {
    local LinkBeamEffect Beam;

    if (ONSLinkFlyer(Owner)!=None)
        Beam=ONSLinkFlyer(Owner).Beam;

    //log(self@"ceasefire"@bWasAltFire,'KDebug');
    if (bWasAltFire && Beam!=None)
        {
        Beam.Destroy();
        Beam=None;
        if (ONSLinkFlyer(Owner)!=None)
            {
            ONSLinkFlyer(Owner).Beam=None;
            ONSLinkFlyer(Owner).bBeaming=false;
            }

        //AmbientSound = None;
        Owner.AmbientSound=OldAmbientSound;
        OldAmbientSound=None;
        //Owner.SoundVolume = ONSVehicle(Owner).Default.SoundVolume;
        SetLinkTo(None);

        // Can't link if there's no beam
        if (ONSLinkFlyer(Owner)!=None)
            {
            //log(Level.TimeSeconds@Self@"Set LinkFlyer bLinking to FALSE in WeaponCeaseFire",'KDebug');
            ONSLinkFlyer(Owner).bLinking=false;
            }
        }
    }

// ============================================================================
// ModeTick -- Maintain alt-firing link beam.
// Mostly c/p'd from LinkFire and modified accordingly to work with ONSWeapon
// ============================================================================
simulated event Tick(float dt)
    {
    local Vector StartTrace, EndTrace, V, X, Y, Z;
    local Vector HitLocation, HitNormal, EndEffect;
    local Actor Other;
    local Rotator Aim;
    local ONSLinkFlyer LinkFlyer;
    local bool bIsHealingObjective;
    local int AdjustedDamage, NumLinks;
    local DestroyableObjective HealObjective;
    local Vehicle LinkedVehicle;
    local LinkBeamEffect Beam;
    //local Vehicle OtherVehicle; // For limiting vampire

    // I don't think ONSWeapon has a tick by default but it's always a good idea to call super when in doubt
    Super.Tick(dt);

    if (ONSLinkFlyer(Owner)!=None)
        {
        LinkFlyer=ONSLinkFlyer(Owner);
        NumLinks=LinkFlyer.GetLinks();
        Beam=ONSLinkFlyer(Owner).Beam;
        }
    else
        {
        NumLinks=0;
        }

    // If not firing, restore value of bInitAimError
    if (Beam==None && Role==ROLE_Authority)
        {
        bInitAimError=true;
        return;
        }

    if (LinkFlyer!=None && LinkFlyer.GetLinks()<0)
        {
        LinkFlyer.ResetLinks();
        }

    if ((UpTime>0.0)||(Role<ROLE_Authority))
        {
        UpTime-=dt;

        // FireStart begins at WeaponFireLocation
        CalcWeaponFire();
        GetAxes(WeaponFireRotation, X, Y, Z);
        StartTrace=WeaponFireLocation;
        TraceRange=default.TraceRange+NumLinks*250;

        // Get client LockedPawn
        if (Role<ROLE_Authority)
            {
            if (Beam!=None)
                LockedPawn=Beam.LinkedPawn;
            }

        // If we're locked onto a pawn increase our trace distance
        if (LockedPawn!=None)
            TraceRange*=1.5;

        if (LockedPawn!=None)
            {
            EndTrace=LockedPawn.Location+LockedPawn.BaseEyeHeight*Vect(0, 0, 0.5); // Beam ends at approx gun height
            if (Role==ROLE_Authority)
                {
                V=Normal(EndTrace-StartTrace);
                if ((V dot X < LinkFlexibility)||LockedPawn.Health<=0||LockedPawn.bDeleteMe||(VSize(EndTrace-StartTrace) > 1.5 * TraceRange))
                    {
                    SetLinkTo(None);
                    }
                }
            }

        if (LockedPawn==None)
            {
            //Aim = GetPlayerAim(StartTrace, AimError);
            if (Role==ROLE_Authority)
                Aim=AdjustAim(true);
            else
                Aim=WeaponFireRotation;

            X=Vector(Aim);
            EndTrace=StartTrace+TraceRange * X;
            }

        Other=Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
        if (Other!=None && Other!=Instigator)
            EndEffect=HitLocation;
        else
            EndEffect=EndTrace;

        if (Beam!=None)
            Beam.EndEffect=EndEffect;

        if (Role<ROLE_Authority)
            {
            return;
            }

        if (Other!=None && Other!=Instigator)
            {
            // Target can be linked to
            if (IsLinkable(Other))
                {
                if (Other!=Lockedpawn)
                    SetLinkTo(Pawn(Other));

                if (Lockedpawn!=None)
                    LinkBreakTime=LinkBreakDelay;
                }
            else
                {
                // Stop linking
                if (Lockedpawn!=None)
                    {
                    if (LinkBreakTime<=0.0)
                        SetLinkTo(None);
                    else
                        LinkBreakTime-=dt;
                    }

                // Beam is updated every frame, but damage is only done based on the firing rate
                if (bDoHit)
                    {
                    if (Beam!=None)
                        Beam.bLockedOn=false;

                    Instigator.MakeNoise(1.0);

                    AdjustedDamage=AdjustLinkDamage(NumLinks, Other, AltDamage);

                    if (!Other.bWorldGeometry)
                        {
                        if (Level.Game.bTeamGame &&
                            Pawn(Other)!=None && Pawn(Other).PlayerReplicationInfo!=None &&
                            Pawn(Other).PlayerReplicationInfo.Team==Instigator.PlayerReplicationInfo.Team) // So even if friendly fire is on you can't hurt teammates
                            {
                            AdjustedDamage=0;
                            }

                        HealObjective=DestroyableObjective(Other);
                        if (HealObjective==None)
                            HealObjective=DestroyableObjective(Other.Owner);

                        if (HealObjective!=None && HealObjective.TeamLink(Instigator.GetTeamNum()))
                            {
                            SetLinkTo(None, true);
                            LinkFlyer.bLinking=true;
                            bIsHealingObjective=true;
                            HealObjective.HealDamage(AdjustedDamage, Instigator.Controller, DamageType);
                            }
                        else
                            {
                            if (LockedPawn!=None)
                                warn(self@"called takedamage with a linked pawn!!!");
                            else
                                {
                                // LinkFlyer only allows vampire on occupied vehicles or team unlocked ones
                                //OtherVehicle=Vehicle(Other);
                                //if (OtherVehicle!=None&&(OtherVehicle.Occupied()||!OtherVehicle.bTeamLocked))
                                if (LinkFlyer!=None&&LinkFlyer.Health<LinkFlyer.HealthMax&&(ONSPowerCore(HealObjective)==None||ONSPowerCore(HealObjective).PoweredBy(Team)&&!LockedPawn.IsInState('NeutralCore')))
                                    LinkFlyer.HealDamage(Round(AdjustedDamage * SelfHealMultiplier), Instigator.Controller, AltDamageType);
                                Other.TakeDamage(AdjustedDamage, Instigator, HitLocation, MomentumTransfer*X, AltDamageType);
                                }
                            }

                        if (Beam!=None)
                            Beam.bLockedOn=true;
                        }
                    }
                }
            }

        // Vehicle healing
        LinkedVehicle=Vehicle(LockedPawn);
        if (LinkedVehicle!=None && bDoHit)
            {
            AdjustedDamage=AltDamage * (1.5*NumLinks+1) * Instigator.DamageScaling;
            if (Instigator.HasUDamage())
                AdjustedDamage*=2;
            LinkedVehicle.HealDamage(AdjustedDamage, Instigator.Controller, DamageType);
            }

        if (LinkFlyer!=None && bDoHit)
            LinkFlyer.bLinking=(LockedPawn!=None)||bIsHealingObjective;

        // Handle color changes
        if (Beam!=None)
            {
            if ((LinkFlyer!=None&&LinkFlyer.bLinking)||((Other!=None)&&(Instigator.PlayerReplicationInfo.Team!=None)&&Other.TeamLink(Instigator.PlayerReplicationInfo.Team.TeamIndex)))
                Beam.LinkColor=Instigator.PlayerReplicationInfo.Team.TeamIndex+1;
            else
                Beam.LinkColor=0;

            Beam.Links=NumLinks;
            if (OldAmbientSound==None)
                {
                OldAmbientSound=Owner.AmbientSound;
                Owner.AmbientSound=BeamSounds[Min(Beam.Links, 3)];
                }

            //AmbientSound = BeamSounds[Min(Beam.Links,3)];
            if (LinkFlyer!=None)
                LinkFlyer.bBeaming=true;
            Soundvolume=FireSoundVolume;

            //Owner.SoundPitch = Owner.Default.SoundPitch;
            //Owner.SoundVolume = SentLinkVolume;
            Beam.LinkedPawn=LockedPawn;
            Beam.bHitSomething=(Other!=None);
            Beam.EndEffect=EndEffect;
            }
        }

    bDoHit=false;
    }

// ============================================================================
// AdjustLinkDamage
// Return adjusted damage based on number of links
// Takes a NumLinks argument instead of an actual LinkGun
// ============================================================================
simulated function float AdjustLinkDamage(int NumLinks, Actor Other, float Damage)
    {
    Damage=Damage * (1.5*NumLinks+1);

    if (Other.IsA('Vehicle'))
        Damage*=VehicleDamageMult;

    return Damage;
    }

// ============================================================================
// SetLinkTo
// Add our link to the other pawn
// ============================================================================
function SetLinkTo(Pawn Other, optional bool bHealing)
    {
    // Sanity check
    if (LockedPawn!=Other)
        {
        if (LockedPawn!=None && ONSLinkFlyer(Owner)!=None)
            {
            RemoveLink(1+ONSLinkFlyer(Owner).GetLinks(), Instigator);

            // Added flag so the vehihicle doesn't flash from green to teamcolor rapidly while linking a non-Wormbo node
            if (!bHealing)
                ONSLinkFlyer(Owner).bLinking=false;
            }

        LockedPawn=Other;

        if (LockedPawn!=None)
            {
            if (ONSLinkFlyer(Owner)!=None)
                {
                if (!AddLink(1+ONSLinkFlyer(Owner).GetLinks(), Instigator))
                    {
                    bFeedbackDeath=true;
                    }
                ONSLinkFlyer(Owner).bLinking=true;
                }
            LockedPawn.PlaySound(MakeLinkSound, SLOT_None);
            }
        }
    }

// ============================================================================
// AddLink
// Add our links to the target's LinkGun
// No need to notify other LinkFlyers -- they will pick up the link automatically in HealDamage
// (This will also work for other Link Vehicles utilizing the same code)
// c/p'd from LinkFire
// ============================================================================
function bool AddLink(int Size, Pawn Starter)
    {
    local Inventory Inv;

    if (LockedPawn!=None && !bFeedbackDeath)
        {
        if (LockedPawn==Starter)
            {
            return false;
            }
        else
            {
            Inv=LockedPawn.FindInventoryType(class'LinkGun');
            if (Inv!=None)
                {
                if (LinkFire(LinkGun(Inv).GetFireMode(1)).AddLink(Size, Starter))
                    LinkGun(Inv).Links+=Size;
                else
                    return false;
                }
            }
        }

    return true;
    }

// ============================================================================
// RemoveLink
// Remove our link from the target's LinkGun
// c/p'd from LinkFire
// ============================================================================
function RemoveLink(int Size, Pawn Starter)
    {
    local Inventory Inv;

    if (LockedPawn!=None && !bFeedbackDeath)
        {
        if (LockedPawn!=Starter)
            {
            Inv=LockedPawn.FindInventoryType(class'LinkGun');
            if (Inv!=None)
                {
                LinkFire(LinkGun(Inv).GetFireMode(1)).RemoveLink(Size, Starter);
                LinkGun(Inv).Links-=Size;
                }
            }
        }
    }

// ============================================================================
// IsLinkable
// More c/p action
// ============================================================================
function bool IsLinkable(Actor Other)
    {
    local Pawn P;
    local LinkGun LG;
    local LinkFire LF;
    local int sanity;
    //local ONSVehicle OwnerVehicle;

    if (Other.IsA('Pawn')&&Other.bProjTarget)
        {
        P=Pawn(Other);

        if (P.Weapon==None||!P.Weapon.IsA('LinkGun'))
            {
            if (Vehicle(P)!=None)
                return P.TeamLink(Instigator.GetTeamNum());
            return false;
            }

        LG=LinkGun(P.Weapon);
        LF=LinkFire(LG.GetFireMode(1));

        // Pro-actively prevent link cycles from happening
        while (LF!=None && LF.LockedPawn!=None && LF.LockedPawn!=P && sanity<32)
            {
            if (LF.LockedPawn==Pawn(Owner))
                return false;

            LG=LinkGun(LF.LockedPawn.Weapon);
            if (LG==None)
                break;

            LF=LinkFire(LG.GetFireMode(1));
            sanity++;
            }

        return (Level.Game.bTeamGame && P.GetTeamNum()==ONSVehicle(Owner).Team);
        }

    return false;
    }

// ============================================================================
// TraceFire
// Spawn the beam and all but don't actually do any damage here
// ============================================================================
function TraceFire(Vector Start, Rotator Dir)
    {
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local ONSWeaponPawn WeaponPawn;
    local Vehicle VehicleInstigator;
    local bool bDoReflect;
    local int ReflectNum;
    //local int Damage; no damage

    MaxRange();

    if (bDoOffsetTrace)
        {
        WeaponPawn=ONSWeaponPawn(Owner);
        if (WeaponPawn!=None && WeaponPawn.VehicleBase!=None)
            {
            if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start+vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
                Start=HitLocation;
            }
        else
            if (!Owner.TraceThisActor(HitLocation, HitNormal, Start, Start+vector(Dir) * (Owner.CollisionRadius * 1.5)))
                Start=HitLocation;
        }

    ReflectNum=0;
    while (true)
        {
        bDoReflect=false;
        X=Vector(Dir);
        End=Start+TraceRange * X;

        // Skip past vehicle driver
        VehicleInstigator=Vehicle(Instigator);
        if (ReflectNum==0&&VehicleInstigator!=None && VehicleInstigator.Driver!=None)
            {
            VehicleInstigator.Driver.bBlockZeroExtentTraces=false;
            Other=Trace(HitLocation, HitNormal, End, Start, true);
            VehicleInstigator.Driver.bBlockZeroExtentTraces=true;
            }
        else
            Other=Trace(HitLocation, HitNormal, End, Start, True);

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

        if (bDoReflect && ++ReflectNum<4)
            {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start=HitLocation;
            Dir=Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
            }
        else
            break;
        }

    NetUpdateTime=Level.TimeSeconds-1;
    }


// ============================================================================
// Precache
// ============================================================================
simulated function UpdatePrecacheMaterials()
    {
    Super.UpdatePrecacheMaterials();
    }

// ============================================================================
simulated function UpdatePrecacheStaticMeshes()
    {
    Super.UpdatePrecacheStaticMeshes();
    //Level.AddPrecacheStaticMesh(StaticMesh'MyStaticMesh');
    }

// ============================================================================
// ProjectileFireMode
// state
// ============================================================================
state ProjectileFireMode
    {
    function Fire(Controller C)
        {
        //if (Beam != None)
        //    CeaseFire(C);
        Super.Fire(C);
        }

    function AltFire(Controller C)
        {
        FlashMuzzleFlash();
        if (AmbientEffectEmitter!=None)
            AmbientEffectEmitter.SetEmitterStatus(true);
        TraceFire(WeaponFireLocation, WeaponFireRotation);
        }
    }

// ============================================================================
// defaultproperties
// ============================================================================

defaultproperties
{
     LinkSkin_Gold(0)=Shader'UT2004Weapons.Shaders.PowerPulseShaderYellow'
     LinkSkin_Gold(1)=Shader'UT2004Weapons.Shaders.PowerPulseShaderYellow'
     LinkSkin_Green(0)=Shader'UT2004Weapons.Shaders.PowerPulseShader'
     LinkSkin_Green(1)=Shader'UT2004Weapons.Shaders.PowerPulseShader'
     LinkSkin_Red(0)=Shader'UT2004Weapons.Shaders.PowerPulseShaderRed'
     LinkSkin_Blue(1)=Shader'UT2004Weapons.Shaders.PowerPulseShaderBlue'
     LinkBeamSkin=2
     LinkedFireSound=Sound'WeaponSounds.LinkGun.BLinkedFire'
     BeamEffectClass=Class'ONSLinkFlyer.LinkFlyerBeamEffect'
     MakeLinkSound=Sound'WeaponSounds.LinkGun.LinkActivated'
     LinkBreakDelay=0.500000
     MomentumTransfer=2000.000000
     AltDamageType=Class'ONSLinkFlyer.DamTypeLinkFlyerBeam'
     AltDamage=15
     MakeLinkForce="LinkActivated"
     LinkFlexibility=0.550000
     LinkVolume=240
     BeamSounds(0)=Sound'WeaponSounds.LinkGun.BLinkGunBeam1'
     BeamSounds(1)=Sound'WeaponSounds.LinkGun.BLinkGunBeam2'
     BeamSounds(2)=Sound'WeaponSounds.LinkGun.BLinkGunBeam3'
     BeamSounds(3)=Sound'WeaponSounds.LinkGun.BLinkGunBeam4'
     VehicleDamageMult=1.500000
     bInitAimError=True
     SelfHealMultiplier=0.600000
     YawBone="PlasmaGunBarrel"
     PitchBone="PlasmaGunBarrel"
     PitchUpLimit=18000
     PitchDownLimit=49153
     WeaponFireAttachmentBone="PlasmaGunBarrel"
     RotationsPerSecond=0.500000
     FireInterval=0.350000
     AltFireInterval=0.120000
     FireSoundClass=SoundGroup'WeaponSounds.PulseRifle.PulseRifleFire'
     FireSoundVolume=256.000000
     FireForce="Explosion05"
     DamageMin=0
     DamageMax=0
     TraceRange=5000.000000
     ProjectileClass=Class'ONSLinkFlyer.LinkFlyerProjectile'
     AIInfo(0)=(bLeadTarget=True,WarnTargetPct=0.990000,RefireRate=0.990000)
     AIInfo(1)=(bInstantHit=True,WarnTargetPct=0.990000,RefireRate=0.990000)
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
     DrawScale=0.300000
     SoundPitch=112
     SoundRadius=512.000000
     TransientSoundRadius=1024.000000
}
