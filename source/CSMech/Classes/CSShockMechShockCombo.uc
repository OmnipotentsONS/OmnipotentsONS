
class CSShockMechShockCombo extends ShockCombo;

simulated event PostBeginPlay()
{
    Super(Actor).PostBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        Spawn(class'CSShockMechShockComboExpRing');
        Flare = Spawn(class'CSShockMechShockComboFlare');
        Spawn(class'CSShockMechShockComboCore');
        Spawn(class'CSShockMechShockComboSphereDark');
        Spawn(class'CSShockMechShockComboVortex');
        Spawn(class'CSShockMechShockComboWiggles');
        Spawn(class'CSShockMechShockComboFlash');
    }
}

defaultproperties
{
}