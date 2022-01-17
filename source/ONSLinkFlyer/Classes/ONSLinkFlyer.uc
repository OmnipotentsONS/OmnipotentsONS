// ============================================================================
// LinkFlyer                                                        ItsMeAgain
// Main Class, Combo of Starbolt and LinkTank
//
// Do no damage after owner death

//log("Current Rotation="$WeaponFireRotation$" My Flag="$bMyFlag);
//
// ============================================================================
class ONSLinkFlyer extends ONSAttackCraft;

#exec OBJ LOAD FILE=..\textures\LinkFlyer_Tex.utx

// ============================================================================
// Internal Structs
// ============================================================================
struct LinkerStruct
    {
    var Controller LinkingController;
    var int NumLinks;
    var float LastLinkTime;
    };

// ============================================================================
// Consts
// ============================================================================
const LINK_DECAY_TIME=0.25;             // Time to remove a linker from the linker list
const AI_HEAL_SEARCH=4096.0;            // Radius for bots to search for damaged actors while driving

// ============================================================================
// Internal Properties
// ============================================================================
var() array<Material> LinkSkin_Gold, LinkSkin_Green, LinkSkin_Red, LinkSkin_Blue;

// ============================================================================
// Internal vars
// ============================================================================
var array<LinkerStruct> Linkers;        // For keeping track of links
var int Links;
var bool bLinking;                      // True if we're linking a vehicle/node/player
var bool bBeaming;                      // True if utilizing alt-fire
var LinkBeamEffect Beam;

//var bool bBotHealing;
//var LinkAttachment.ELinkColor OldLinkColor;

// ============================================================================
// Replication
// ============================================================================
replication
    {
    unreliable if (Role==ROLE_Authority && bNetDirty)
        Links, bLinking, Beam, bBeaming;
    }

    // ============================================================================
    // HealDamage
    // When someone links the Flyer, record it and add it to the Linkers
    // After a certain time period passes, remove that linker if they aren't linking anymore
    // ============================================================================
    function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
        {
        local int i;
        local bool bFound;

        if (Healer==None||Healer.bDeleteMe)
            return false;

        // If allied teammate, possibly add them to a link list
        if (TeamLink(Healer.GetTeamNum()))
            {
            for (i=0; i<Linkers.Length; i++)
                {
                if (Linkers[i].LinkingController!=None && Linkers[i].LinkingController==Healer)
                    {
                    bFound=true;
                    Linkers[i].LastLinkTime=Level.TimeSeconds;

                    // If other players are linking that pawn, record it
                    if ((Linkers[i].LinkingController.Pawn!=None)&&(Linkers[i].LinkingController.Pawn.Weapon!=None)&&(LinkGun(Linkers[i].LinkingController.Pawn.Weapon)!=None))
                        Linkers[i].NumLinks=LinkGun(Linkers[i].LinkingController.Pawn.Weapon).Links;
                    else
                        Linkers[i].NumLinks=0;
                    }
                }

            if (!bFound)
                {
                Linkers.Insert(0, 1);
                Linkers[0].LinkingController=Healer;
                Linkers[0].LastLinkTime=Level.TimeSeconds;

                // If other players are linking that pawn, record it
                if ((Linkers[i].LinkingController.Pawn!=None)&&(Linkers[i].LinkingController.Pawn.Weapon!=None)&&(LinkGun(Linkers[i].LinkingController.Pawn.Weapon)!=None))
                    Linkers[0].NumLinks=LinkGun(Linkers[0].LinkingController.Pawn.Weapon).Links;
                else
                    Linkers[0].NumLinks=0;
                }
            }

        return super.HealDamage(Amount, Healer, DamageType);
        }

    // ============================================================================
    // GetLinks
    // Returns number of linkers
    // ============================================================================
    function int GetLinks()
        {
        return Links;
        }

    // ============================================================================
    // ResetLinks
    // Reset our linkers, called if Links < 0 or during tick
    // ============================================================================
    function ResetLinks()
        {
        local int i;
        local int NewLinks;

        i=0;
        NewLinks=0;
        while (i < Linkers.Length)
            {
            // Remove linkers when their controllers are deleted Or remove if LINK_DECAY_TIME seconds pass since they last linked the flyer
            if (Linkers[i].LinkingController==None||Level.TimeSeconds-Linkers[i].LastLinkTime > LINK_DECAY_TIME)
                Linkers.Remove(i, 1);
            else
                {
                NewLinks+=1+Linkers[i].NumLinks;
                i++;
                }
            }

        if (Links!=NewLinks)
            Links=NewLinks;
        }

    // ============================================================================
    // Tick
    // Remove linkers from the linker list after they stop linking
    // ============================================================================
    simulated event Tick(float DT)
        {
        //local float EnginePitch;
        //local KRigidBodyState BodyState;
        //local KarmaParams KP;
        //local bool bOnGround;
        //local int i;

        //Super.Tick(DT);

        // cp from HoverTank -- all we care about is not wildly varying the ambientsound of the beam
        //KGetRigidBodyState(BodyState);

        //if (Level.NetMode!=NM_DedicatedServer)
        //    {
        //    if (!bBeaming)
        //        {
        //        EnginePitch=64.0+VSize(Velocity)/MaxPitchSpeed * 64.0;
        //        SoundPitch=FClamp(EnginePitch, 64, 128);
        //        }
        //    else
        //        SoundPitch=64.0;
        //    }

        Super(ONSAttackCraft).Tick(DT);

        //if (bBotHealing)
        //    AltFire();

        if (Role==ROLE_Authority)
            ResetLinks();
        }

    // ============================================================================
    function Fire(optional float F)
        {
        if (!bBeaming) // Don't allow primary fire if beaming
            Super.Fire(F);
        }

    // ============================================================================
    function AltFire(optional float F)
        {
        super(ONSVehicle).AltFire(F);
        }

    // ============================================================================
    function ClientVehicleCeaseFire(bool bWasAltFire)
        {
        super(ONSVehicle).ClientVehicleCeaseFire(bWasAltFire);
        }

    // ============================================================================
    //simulated function ClientKDriverLeave(PlayerController PC)
    //    {
    //    Super.ClientKDriverLeave(PC);

    //    bBeaming=false;
    //    //bWeaponIsAltFiring=false;
    //    PC.EndZoom();
    //    }

    // ============================================================================
    //function bool RecommendLongRangedAttack()
    //    {
    //    return true;
    //    }

    // ============================================================================
    // Precache
    // ============================================================================
    static function StaticPrecache(LevelInfo L)
        {
        Super.StaticPrecache(L);

        L.AddPrecacheMaterial(Material'LinkFlyer_Tex.LinkFlyer.LinkFlyerBodyRed');
        L.AddPrecacheMaterial(Material'LinkFlyer_Tex.LinkFlyer.LinkFlyerBodyBlue');

        L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerGreen');
        L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerRed');
        L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerBlue');
        L.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerYellow');
        }

    // ============================================================================
    simulated function UpdatePrecacheStaticMeshes()
        {
        Super.UpdatePrecacheStaticMeshes();
        }

    // ============================================================================
    simulated function UpdatePrecacheMaterials()
        {
        Level.AddPrecacheMaterial(Material'LinkFlyer_Tex.LinkFlyer.LinkFlyerBodyRed');
        Level.AddPrecacheMaterial(Material'LinkFlyer_Tex.LinkFlyer.LinkFlyerBodyBlue');

        Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerGreen');
        Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerRed');
        Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerBlue');
        Level.AddPrecacheMaterial(Material'UT2004Weapons.NewWeaps.LinkPowerYellow');

        Super.UpdatePrecacheMaterials();
        }

    // ============================================================================
    // defaultproperties
    // ============================================================================

defaultproperties
{
     MaxPitchSpeed=2200.000000
     MaxThrustForce=170.000000
     MaxStrafeForce=130.000000
     MaxRiseForce=150.000000
     MaxYawRate=2.300000
     DriverWeapons(0)=(WeaponClass=Class'ONSLinkFlyer.LinkFlyerWeapon')
     RedSkin=Combiner'LinkFlyer_Tex.LinkFlyer.LinkFlyerCombinerRed'
     BlueSkin=Combiner'LinkFlyer_Tex.LinkFlyer.LinkFlyerCombinerBlue'
     DisintegrationEffectClass=None
     DisintegrationHealth=0.000000
     VehiclePositionString="in a Chupacabra"
     VehicleNameString="Chupacabra 1.0"
     GroundSpeed=2200.000000
     HealthMax=450.000000
     Mesh=SkeletalMesh'LinkFlyer_Mesh.LinkFlyer.LinkFinal'
     CollisionRadius=130.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.250000)
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=0.000000
         KMaxSpeed=2100.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=800.000000
     End Object
     KParams=KarmaParamsRBFull'ONSLinkFlyer.ONSLinkFlyer.KParams0'

}
