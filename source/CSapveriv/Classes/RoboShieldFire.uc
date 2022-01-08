class RoboShieldFire extends WeaponFire;


function DoFireEffect()
{
    local controller C;
    C=instigator.Controller;
    RoboRifle(Weapon).AttemptFire(C,true);
}

function PlayFiring()
{

}

function StopFiring()
{
   RoboRifle(Weapon).DeactivateShield();
}

defaultproperties
{
     bPawnRapidFireAnim=True
     bWaitForRelease=True
     FireAnim=
     FireLoopAnim=
     FireEndAnim="Idle"
     FireSound=SoundGroup'WeaponSounds.Translocator.TranslocatorModuleRegeneration'
     FireForce="TranslocatorModuleRegeneration"
     FireRate=1.000000
     AmmoClass=Class'XWeapons.ShieldAmmo'
     BotRefireRate=1.000000
}
