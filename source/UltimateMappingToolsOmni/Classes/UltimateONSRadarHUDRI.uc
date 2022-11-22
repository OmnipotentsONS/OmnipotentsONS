//-----------------------------------------------------------------------------
// UltimateONSRadarHUDRI
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 24.08.2011 16:28:06 in Package: UltimateMappingTools$
//
// Creates the HUDOverlay for the Ultimate ONS radar map. For the vehicle stuff
// and so on.
//-----------------------------------------------------------------------------
class UltimateONSRadarHUDRI extends ReplicationInfo;

var    bool   bRadarMutatorEnabled ; // Disable radar functionality in that case.
var    bool   bCreatedOverlay;


replication
{
    reliable if (Role == ROLE_Authority)
        bRadarMutatorEnabled;
}



// ============================================================================
// PostBeginPlay
// ============================================================================
event PostBeginPlay()
{
    // Hack #1: If some Mutator knows about us and wants to turn this off before PostBeginPlay, let him do so.
    // Not recommended, since it would mean to include this package for compiling. Thus see hack #2.
    bRadarMutatorEnabled = bRadarMutatorEnabled || HasRadarMutator();
    NetUpdateTime = Level.TimeSeconds - 1;

    if (Level.NetMode == NM_DedicatedServer)
        Disable('Tick');
}


// ============================================================================
// Tick
//
// Performs the Tick until it could add the Overlay to the local player.
// ============================================================================
simulated event Tick(float DeltaTime)
{
    local PlayerController  PC;
    local UltimateRadarVehicleHUDOverlay Overlay;
    PC = Level.GetLocalPlayerController();

    if (!bScriptInitialized) // Assure that the Mutator-check has been performed already in PostBeginPlay.
        return;

    if (PC != none)
    {
        if (!bCreatedOverlay && !bRadarMutatorEnabled)
        {
            Overlay = Spawn(class'UltimateRadarVehicleHUDOverlay');
            if (Overlay != None)
            {
                PC.myHUD.AddHudOverlay(Overlay);

                bCreatedOverlay = True;
            }
        }
        Disable('Tick');
    }
}


// ============================================================================
// HasRadarMutator
//
// Returns True if a Mutator that affects the Radar is loaded.
// ============================================================================
function bool HasRadarMutator()
{
    local Mutator M;

    if (Level.Game == None)
       return True; // Failsafe.


    for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
    {
        if ((InStr(M.FriendlyName, "Radar") != -1) || (InStr(M.GroupName, "Radar") != -1))
            return True;
    }

    return False;
}


// ============================================================================
// Hack #2:
// If some Mutator knows about us but doesn't want to deal with our
// variables and functions in particular because he doesn't want to compile us
// with him, he can use this method.
//
// By calling this very basic function that exists in the Actor class, he can use
// a plain A.IsA('UltimateONSFactory') and then A.HealDamage() to disable the
// radar vehicle stuff.
//
// I simply assume that no code out there would ever attempt to heal damage on
// a VehicleFactory for whatever reason.
// But to be absolutely sure, the Amount must be less than 0. ;)
// ============================================================================
function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
    if (Amount < 0)
    {
        return True;
        bRadarMutatorEnabled = True;
    }
    return False;
}

defaultproperties
{
     NetUpdateFrequency=1.000000
}
