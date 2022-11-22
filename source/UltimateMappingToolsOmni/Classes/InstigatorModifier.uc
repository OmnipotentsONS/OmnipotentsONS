//=============================================================================
// InstigatorModifier
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 15.08.2011 00:40:47 in Package: UltimateMappingTools$
//
// Changes the properties of the pawn that triggered the Event to the specified
// ones. Leave a value at 0 to keep the pawn's own value.
//=============================================================================
class InstigatorModifier extends EventGate;


      /* Public */

    var()  bool bAddValues ;
    // Considers the pawn's old health and shield when applying the new values, so he doesn't get full health when damaged already.
    // The maximum values are not affected by that.

    var()  int  Health ; // The health of the player to start with.
    var()  int  Shield ; // The shield of the player to start with.

    var()  bool bChangeMaxHealth ;
    // The player's health can be refilled up to the new health value. SuperHealthMax is twice the health-value.

    var()  bool bChangeMaxShield ;
    // The player's shield can be refilled up to the new shield value. ShieldStrengthMax is three times the shield-value.

    var() float GroundSpeed ;    // The maximum ground speed.
    var() float WaterSpeed ;     // The maximum swimming speed.
    var() float AirSpeed ;       // The maximum flying speed.
    var() float LadderSpeed ;    // Ladder climbing speed
    var() float AccelRate ;      // Max acceleration rate
    var() float JumpZ ;          // Vertical acceleration w/ jump
    var() float AirControl ;     // Amount of AirControl available to the pawn
    var() float MaxFallSpeed ;   // Max speed pawn can land without taking damage (also limits what paths AI can use)
    var() int   MaxMultiJump ;   // How often this pawn can multijump (negative values use default setting)

    var() float UnderWaterTime ; // How much time pawn can go without air (in seconds)
    var() bool  bRemovePowerUps ;// Remove any powerup from instigator.
    var() array<Inventory> AddInventory; // Add the items of this array to the instigator's inventory.

    var() bool bModifyVehicleDrivers ; // If True, this will also modify the driver of a vehicle.



// ============================================================================
// Trigger
//
// Calls the ModifyPlayer function if the instigator is a living player or vehicle driver.
// ============================================================================
event Trigger(Actor Other, Pawn EventInstigator)
{
    if ((xPawn(EventInstigator) != None && EventInstigator.Health > 0) ||
        (bModifyVehicleDrivers && Vehicle(EventInstigator) != None && Vehicle(EventInstigator).Driver != None &&
         Vehicle(EventInstigator).Driver.Health > 0))
        ModifyPlayer(xPawn(EventInstigator));
}


// ============================================================================
// ModifyPlayer
//
// Applies the changed values to the instigator. The instigator must be an xPawn.
// ============================================================================
function ModifyPlayer(xPawn Instigator)
{
    local int i;

    if (Instigator == None)
        return;

    if (Health > 0)
    {
        if (bChangeMaxHealth)
        {
            Instigator.SuperHealthMax = 2*Health - 1;
            Instigator.HealthMax = Health;
        }

        if (bAddValues) // Consider that the instigator's current health.
            Instigator.GiveHealth(Health, Instigator.HealthMax);
        else
            Instigator.Health = Health;

        if (Instigator.Health > Instigator.SuperHealthMax)
            Instigator.Health = Instigator.SuperHealthMax;
    }

    if (Shield > 0)
    {
        if (bChangeMaxShield)
            Instigator.ShieldStrengthMax = 3*Shield;

        if (bAddValues)
            Instigator.AddShieldStrength(Shield);
        else
            Instigator.ShieldStrength = Shield;

        if (Instigator.ShieldStrength > Instigator.ShieldStrengthMax)
            Instigator.ShieldStrength = Instigator.ShieldStrengthMax;
    }

    if (GroundSpeed > 0)
        Instigator.GroundSpeed = GroundSpeed;

    if (WaterSpeed > 0)
        Instigator.WaterSpeed = WaterSpeed;

    if (AirSpeed > 0)
        Instigator.AirSpeed = AirSpeed;

    if (LadderSpeed > 0)
        Instigator.LadderSpeed = LadderSpeed;

    if (AccelRate > 0)
        Instigator.AccelRate = AccelRate;

    if (JumpZ > 0)
        Instigator.JumpZ = JumpZ;

    if (AirControl > 0)
        Instigator.AirControl = AirControl;

    if (MaxFallSpeed > 0)
        Instigator.MaxFallSpeed = MaxFallSpeed;

    if (MaxMultiJump >= 0)
        Instigator.MaxMultiJump = MaxMultiJump;

    if (UnderWaterTime > 0)
        Instigator.UnderWaterTime = UnderWaterTime;

    if (bRemovePowerUps)
        Instigator.RemovePowerups();

    for (i = 0; i < AddInventory.Length; i++)
        Instigator.AddInventory(AddInventory[i]);
}

defaultproperties
{
     Texture=Texture'Engine.S_Pawn'
}
