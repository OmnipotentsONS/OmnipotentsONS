//=============================================================================
// UltimateDestroyableEnvironment
//
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 13.10.2011 00:10:19 in Package: UltimateMappingTools$
//
// Allows to set up an actor that gets more and more destroyed when it takes
// damage. That is done by having multiple versions of the StaticMesh that are
// differently high damaged.
//=============================================================================
class UltimateDestroyableEnvironment extends Decoration;


// ============================================================================
// Variables
// ============================================================================

struct _DecoKActor
{
    var() StaticMesh KActorStaticMesh; // This StaticMesh will be used by the KarmaThing that is spawned.
    var() float KActorMaxNetUpdateInterval; // How often is the KActor maximally updated per second for online games. Should be about 0.5

    var() editinline KarmaParams KActorParameters; // Set the parameters for the new Karma object.

    var() vector SpawnOffset; // Where does the KActor spawn in relation to the location of the StaticMesh?
    var() rotator RotationOffset; // Which rotation does the KActor have in relation to the StaticMesh?
    var() float KActorLifeSpan; // How many seconds does the KActor exist before it gets destroyed?
                                // 0 means infinite, but it's recommended to avoid that.
};

struct _LevelOfDestruction
{
    var() StaticMesh DestroyedStaticMesh; // The new StaticMesh that is used at this LOD.
    var() int HealthLimit; // This LOD becomes active if the actors health drops below this.

    var() vector StaticMeshScale; // Scale the StaticMesh by this value. Values close to 0 are ignored.
    var() vector StaticMeshOffset; // New location of the StaticMesh in relation to the original location.
    var() rotator StaticMeshRotation; // New rotation of the StaticMesh in relation to the original rotation.

    var() array<_DecoKActor> KarmaDeco; // KActors to spawn at the destruction.

    var() name TriggerEvent; // Trigger this Event once this LOD has been reached.

    var() bool bFinalDestruction; // Set this to True if you consider this the last stadium of the mesh in which it should disappear completely.
                                  // It still has the possibility to respawn in the next round.

    var   bool bReached; // True if this LOD has been executed already.
};


var() array<_LevelOfDestruction> LevelOfDestruction;
var() int TotalHealth; // The initial health of this actor.

var() array< class<DamageType> > DamageTypes; // Which DamageTypes can affect this actor?
var() bool bBlackList; // If true, the DamageTypes in the array can NOT damage this actor.
var() int WrongDamageEventTreshold; // Trigger an event every time this much damage has been caused by a "wrong" DamageType.
var(Events) name WrongDamageTypeEvent; // Triggered when an invalid DamageType damaged this actor.


var() bool bReset; // Reset this actor after the round ended or keep destruction the whole match?
var() bool bResetEventOnlyWhenFinalDestruction; // If True, only fire off the ResetEvent if an LOD with bFinalDestruction has been reached in this round.
var(Events) name ResetEvent; // Triggered if bReset is True, so that you can potentially do some updates on other things as well when resetting this actor.


/* Internal variables */
var StaticMesh OriginalStaticMesh; // Remember for reset.
var vector OriginalLocation; // Remember for calculating offset from default in each LOD.
var rotator OriginalRotation; // Remember for calculating rotation offset from default in each LOD.
var vector OriginalScale; // Just remember this too.
var ERenderStyle OriginalStyle; // Don't ask.
var bool bFinalDestructionReached; // Used by bResetEventOnlyWhenFinalDestruction.

var int i_temp, j_temp; // Remember the current array for use in GainedChild.
var int AccumulatedWrongDamage; // This much of the wrong damage has been accumulated already.
var int CurrentLOD, OldLOD;


replication
{
    reliable if (Role == ROLE_Authority)
        CurrentLOD;
}



// ============================================================================
// PostBeginPlay
//
// Use the Health variable and keep TotalHealth as backup.
// ============================================================================

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    Health = TotalHealth;

    OriginalStaticMesh = StaticMesh;
    OriginalLocation = Location;
    OriginalRotation = Rotation;
    OriginalScale = DrawScale3D;
    OriginalStyle = Style;
}



// ============================================================================
// TakeDamage
//
// Process damage on this actor and change it's appearance if a DamageLimit is
// reached.
// ============================================================================

event TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
                    Vector momentum, class<DamageType> damageType)
{
    local DynamicSpawnableKarmaThing SpawnedKActor;
    local int i, j;

    Instigator = InstigatedBy;
    if (Health < 0)
        return;

    if (!CheckDamageType(damageType))
    {
        AccumulatedWrongDamage += NDamage;
        if (AccumulatedWrongDamage >= WrongDamageEventTreshold)
        {
            AccumulatedWrongDamage -= WrongDamageEventTreshold;
            TriggerEvent(WrongDamageTypeEvent, self, instigatedBy);
        }
        return;
    }

    if (Instigator != None)
        MakeNoise(1.0); // Notify AI about the Instigator.


    Health -= NDamage;


    for (i = 0; i < LevelOfDestruction.Length; i++)
    {
        if (LevelOfDestruction[i].HealthLimit >= Health && !LevelOfDestruction[i].bReached)
        {
            LevelOfDestruction[i].bReached = True;
            CurrentLOD = i;
            NetUpdateTime = Level.TimeSeconds - 1;
            TriggerEvent(LevelOfDestruction[i].TriggerEvent, self, Instigator);


            // Server side assignments
            if (LevelOfDestruction[i].bFinalDestruction) // Mesh completely disappears, disable collision and rendering.
            {
                SetCollision(false, false, false);
                KSetBlockKarma(false);
                SetDrawType(DT_None);
                bFinalDestructionReached = True;
            }
            else
            {
                KSetBlockKarma(false);

                if (LevelOfDestruction[i].DestroyedStaticMesh != None)
                    SetStaticMesh(LevelOfDestruction[i].DestroyedStaticMesh);

                if (VSize(LevelOfDestruction[i].StaticMeshScale) ~= 0)
                {
                    LevelOfDestruction[i].StaticMeshScale.X = 1.0;
                    LevelOfDestruction[i].StaticMeshScale.Y = 1.0;
                    LevelOfDestruction[i].StaticMeshScale.Z = 1.0;
                }

                SetDrawScale3D(LevelOfDestruction[i].StaticMeshScale);

                SetLocation(OriginalLocation + LevelOfDestruction[i].StaticMeshOffset);
                SetRotation(OriginalRotation + LevelOfDestruction[i].StaticMeshRotation);


                KSetBlockKarma(true); // Update Karma collision
            }

            // Spawn KActors
            for (j = 0; j < LevelOfDestruction[i].KarmaDeco.Length; j++)
            {
                if (LevelOfDestruction[i].KarmaDeco[j].KActorStaticMesh != None)
                {
                    i_temp = i;
                    j_temp = j;
                    SpawnedKActor = Spawn(class'DynamicSpawnableKarmaThing', self,,
                                         Location + LevelOfDestruction[i].KarmaDeco[j].SpawnOffset,
                                         Rotation + LevelOfDestruction[i].KarmaDeco[j].RotationOffset);
                    if (SpawnedKActor != None)
                    {
                        AssignKarmaThingProperties(SpawnedKActor, LevelOfDestruction[i].KarmaDeco[j].KActorLifeSpan,
                                                   LevelOfDestruction[i].KarmaDeco[j].KActorStaticMesh,
                                                   LevelOfDestruction[i].KarmaDeco[j].KActorMaxNetUpdateInterval);
                    }
                }
            }
        }
    }
}



// ============================================================================
// AssignKarmaThingProperties
//
// Small hack to get the KarmaThing set up on the client as well.
// ============================================================================

simulated function AssignKarmaThingProperties(DynamicSpawnableKarmaThing KarmaThing,
                                              float NewLifeSpan,
                                              StaticMesh NewStaticMesh,
                                              float NewMaxNetUpdateInterval)
{
    KarmaThing.LifeSpan = NewLifeSpan;
    KarmaThing.SetStaticMesh(NewStaticMesh);
    KarmaThing.MaxNetUpdateInterval = Max(NewMaxNetUpdateInterval, 0.25);
}



// ============================================================================
// GainedChild
//
// This is the only place where we can assign our custom KParam as KParam of
// the spawned KActor before the Karma physics are initilizing.
// ============================================================================

simulated event GainedChild(Actor Other)
{
    if (DynamicSpawnableKarmaThing(Other) != None)
    {
        DynamicSpawnableKarmaThing(Other).KParams = LevelOfDestruction[i_temp].KarmaDeco[j_temp].KActorParameters;
    }
}



// ============================================================================
// PostNetReceive
//
// This updates the visuals and collision on the client to the current LOD
// when the variable changes on the server or when the player just joined.
// ============================================================================

simulated event PostNetReceive()
{
    if (CurrentLOD != OldLOD)
    {
        if (CurrentLOD == -1)
        {
            KSetBlockKarma(False);
            SetDrawType(DT_StaticMesh);
            SetStaticMesh(OriginalStaticMesh);
            SetDrawScale3D(OriginalScale);
            SetLocation(OriginalLocation);
            SetRotation(OriginalRotation);
            SetCollision(True,True,True);
            KSetBlockKarma(True);
        }
        else
        {
            if (LevelOfDestruction[CurrentLOD].bFinalDestruction) // Mesh completely disappears, disable collision and rendering.
            {
                Log("@FinalDestruction");
                SetCollision(false, false, false);
                KSetBlockKarma(false);
                SetDrawType(DT_None);
            }
            else
            {
                KSetBlockKarma(false);

                if (LevelOfDestruction[CurrentLOD].DestroyedStaticMesh != None)
                    SetStaticMesh(LevelOfDestruction[CurrentLOD].DestroyedStaticMesh);

                if (VSize(LevelOfDestruction[CurrentLOD].StaticMeshScale) ~= 0)
                {
                    LevelOfDestruction[CurrentLOD].StaticMeshScale.X = 1.0;
                    LevelOfDestruction[CurrentLOD].StaticMeshScale.Y = 1.0;
                    LevelOfDestruction[CurrentLOD].StaticMeshScale.Z = 1.0;
                }

                SetDrawScale3D(LevelOfDestruction[CurrentLOD].StaticMeshScale);

                SetLocation(OriginalLocation + LevelOfDestruction[CurrentLOD].StaticMeshOffset);
                SetRotation(OriginalRotation + LevelOfDestruction[CurrentLOD].StaticMeshRotation);


                KSetBlockKarma(true); // Update Karma collision
            }
        }
        OldLOD = CurrentLOD;
    }
}



// ============================================================================
// CheckDamageType
//
// Returns True if the DamageType is considered valid for this actor.
// ============================================================================

function bool CheckDamageType(class<DamageType> DT)
{
    local int a;

    if (DT == class'Crushed')
        return True;

    for (a = 0; a < DamageTypes.Length; a++)
    {
        if (DamageTypes[a] == DT)
            return !bBlackList;
    }
    return bBlackList;
}



// ============================================================================
// Trigger
//
// Triggering will cause the actor to lose all health that is the difference to
// the next lower LOD, i.e. cause it to active the next LOD.
// ============================================================================

event Trigger( actor Other, pawn EventInstigator )
{
    local int a, BestHealth;

    if (LevelOfDestruction.Length > 0)
    {
        for (a = 0; a < LevelOfDestruction.Length; a++)
        {
            if (!LevelOfDestruction[a].bReached && LevelOfDestruction[a].HealthLimit < Health && LevelOfDestruction[a].HealthLimit > BestHealth)
                BestHealth = LevelOfDestruction[a].HealthLimit;
        }


        Instigator = EventInstigator;
        TakeDamage( Health - BestHealth, Instigator, Location, Vect(0,0,1)*900, class'Crushed');
    }
}



// ============================================================================
// UpdatePrecacheStaticMeshes
//
// Load StaticMeshes into memory for faster access.
// ============================================================================

simulated function UpdatePrecacheStaticMeshes()
{
    local int a;

    super.UpdatePrecacheStaticMeshes();

    for (a = 0; a < LevelOfDestruction.Length; a++)
    {
        if (LevelOfDestruction[a].DestroyedStaticMesh != None)
            Level.AddPrecacheStaticMesh(LevelOfDestruction[a].DestroyedStaticMesh);
    }
}



// ============================================================================
// Reset
//
// Restore initial values if this actor should be reset.
// ============================================================================

function Reset()
{
    if (bReset)
    {
        CurrentLOD = -1; // Causes to update the client to the original state.

        KSetBlockKarma(False);
        SetDrawType(DT_StaticMesh);
        SetStaticMesh(OriginalStaticMesh);
        SetDrawScale3D(OriginalScale);
        SetLocation(OriginalLocation);
        SetRotation(OriginalRotation);
        SetCollision(True,True,True);
        KSetBlockKarma(True);

        Health = TotalHealth;
        AccumulatedWrongDamage = 0;

        if (!bResetEventOnlyWhenFinalDestruction || bFinalDestructionReached)
            TriggerEvent(ResetEvent, self, None);

        bFinalDestructionReached = False;
        NetUpdateTime = Level.TimeSeconds - 1;
    }
}



// ============================================================================
// Default Properties
// ============================================================================

defaultproperties
{
     TotalHealth=2000
     bBlacklist=True
     WrongDamageEventTreshold=300
     CurrentLOD=-1
     OldLOD=-1
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Albatross_architecture.Misc.Alb_crate1'
     bStatic=False
     bNoDelete=True
     bWorldGeometry=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     bCollideActors=True
     bBlockActors=True
     bBlockKarma=True
     bNetNotify=True
     bEdShouldSnap=True
}
