//-----------------------------------------------------------
//	Skaarj Viper Speedboat
//	Colt Wohlers (aka CMan)
//	Beta 4.0 (July 2/2004)
//-----------------------------------------------------------
//   Modified Projectile By: Mr. Slate
//-----------------------------------------------------------

class ViperFrontProjectile extends ONSSkyMine;


var SkaarjViper FoundViper;

simulated function PostBeginPlay()
{
        local vector RelVel;
        local float ViperModYaw, GunModYaw;
        Super(Projectile).PostBeginPlay();
        if ( Level.NetMode != NM_DedicatedServer )
	{
		ProjectileEffect = spawn(ProjectileEffectClass, self,, Location, Rotation);
    		ProjectileEffect.SetBase(self);
	}

	if(Role == Role_Authority)
	{
         FoundViper = SkaarjViper(ONSWeaponPawn(Instigator).VehicleBase);
	 RelVel = FoundViper.Velocity << FoundViper.Rotation;
         if(FoundViper.Rotation.Yaw < 0.0 && ONSWeaponPawn(Instigator).Gun.WeaponFireRotation.Yaw < 0.0)
         {
         ViperModYaw = abs(FoundViper.Rotation.Yaw);
         GunModYaw = abs(ONSWeaponPawn(Instigator).Gun.WeaponFireRotation.Yaw);
         }
         else
         {
         ViperModYaw = FoundViper.Rotation.Yaw;
         GunModYaw = ONSWeaponPawn(Instigator).Gun.WeaponFireRotation.Yaw;
         }
         if(FoundViper != None && (ViperModYaw - GunModYaw) <= 16384/2.0f && (ViperModYaw - GunModYaw) >= -16384/2.0f)
             Speed = FClamp(Speed + RelVel.X, Speed, Speed + KarmaParams(FoundViper.KParams).KMaxSpeed);
	}
	else     //client side
	{
	 foreach VisibleCollidingActors(class'SkaarjViper',FoundViper, 500,Location)
                break;

         if(FoundViper!= None)
         {
           if(FoundViper.Rotation.Yaw < 0.0 && FoundViper.WeaponPawns[0].Gun.WeaponFireRotation.Yaw < 0.0)
           {
           ViperModYaw = abs(FoundViper.Rotation.Yaw);
           GunModYaw = abs(FoundViper.WeaponPawns[0].Gun.WeaponFireRotation.Yaw);
           }
           else
           {
           ViperModYaw = FoundViper.Rotation.Yaw;
           GunModYaw = FoundViper.WeaponPawns[0].Gun.WeaponFireRotation.Yaw;
           }

           if((ViperModYaw - GunModYaw) <= 16384/2.0f && (ViperModYaw - GunModYaw) >= -16384/2.0f)
           {
              RelVel = FoundViper.Velocity << FoundViper.Rotation;
              Speed = FClamp(Speed + RelVel.X, Speed, Speed + KarmaParams(FoundViper.KParams).KMaxSpeed);
           }
         }
	}

        Velocity = Speed * Vector(Rotation);
}

defaultproperties
{
}
