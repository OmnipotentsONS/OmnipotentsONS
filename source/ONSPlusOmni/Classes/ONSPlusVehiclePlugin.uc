// This class and it's subclasses are NEVER meant to be created, they are meant to be used entirely through static functions
Class ONSPlusVehiclePlugin extends Object
	abstract;

// This function is used to determine if this plugin wants to replace a certain class of vehicle
static function bool CanReplaceClass(class<Vehicle> VehicleClass)
{
	return False;
}

// Example way of how to code the above function in a subclass
/*
static function bool CanReplaceClass(class<Vehicle> VehicleClass)
{
	if (string(VehicleClass) ~= "StupidCars.PimpMobile1000")
		return True;

	return False;
}
*/


// This function is used to replace vehicle classes for factories
static function bool ReplaceVehicleClass(out class<Vehicle> CurrentClass);

// Example way of how to code the above function in a subclass
/*
static function bool ReplaceVehicleClass(out class<Vehicle> CurrentClass)
{
	local class<Vehicle> NewClass;

	if (string(CurrentClass) ~= "StupidCars.PimpMobile1000")
	{
		NewClass = Class<Vehicle>(DynamicLoadObject("MoreStupidCars.PimpMobile2000", Class'Class'));

		if (NewClass != None)
		{
			CurrentClass = NewClass;
			return True;
		}
	}

	return False;
}
*/


// This function attempts to setup the delegates for the controller, Avril and Missiles so that functions can be called without package-reference

// If you write code that calls this function then this is how to use it: The function has two uses:
// 1: To setup delegates in the Controller for the vehicle he/she IS OCCUPYING 
// 2: To setup delegates in Avril's or Missiles to give lock on/lost lock notifications to vehicles THEY ARE AIMING AT

// Thus, you need to be carefull to only supply a controller/Avril/Missile variable when needed and to make sure CurrentVehicle is the right vehicle

static function bool SetupVehicleDelegates(ONSPlusxPlayer Controller, ONSPlusAvril Avril, Projectile Missle, vehicle CurrentVehicle)
{
	return False;
}

// Example way of how to code the above function in a subclass
/*
static function bool SetupVehicleDelegates(ONSPlusxPlayer Controller, ONSPlusAvril Avril, ONSPlusAttackCraftMissle Missle, vehicle CurrentVehicle)
{
	if (CurrentVehicle.IsA('PimpMobile2000'))
	{
		if (Controller != none)
		{
			Controller.CurDelegateOwner = CurrentVehicle;

			// Assign the delegates
			Controller.DelTogglePreferredExit = PimpMobile2000(CurrentVehicle).TogglePreferredExit;
			Controller.DelSelectDirectionalExit = PimpMobile2000(CurrentVehicle).SelectDirectionalExit;
			//Controller.DelNotifyPlusEnemyLostLock = PimpMobile2000(CurrentVehicle).NotifyPlusEnemyLostLock; // N.B. I 'think' this become obsolete
			//Controller.DelNotifyPlusEnemyLockedOn = PimpMobile2000(CurrentVehicle).NotifyPlusEnemyLockedOn;

			return True;
		}

		if (Avril != none)
		{
			// Assign the delegates
			Avril.DelNotifyPlusEnemyLostLock = PimpMobile2000(CurrentVehicle).NotifyPlusEnemyLostLock;
			Avril.DelNotifyPlusEnemyLockedOn = PimpMobile2000(CurrentVehicle).NotifyPlusEnemyLockedOn;

			return True;
		}

		if (Missile != none)
		{
			// Assign the delegates
			Missile.DelNotifyPlusEnemyLostLock = PimpMobile2000(CurrentVehicle).NotifyPlusEnemyLostLock;
			Missile.DelNotifyPlusEnemyLockedOn = PimpMobile2000(CurrentVehicle).NotifyPlusEnemyLockedOn;

			return True;
		}
	}

	return False;
}
*/


// Placeholder function
static function string MinONSPlusVersion();

// YOU MUST INCLUDE THIS IN SUBCLASSES, THIS IS USED FOR IMPORTANT COMPATABILITY CHECKS
// When putting this in your plugin you (typically) don't need to change its value, however I highly recommend you test what versions of ONSPlus your vehicle is compatable with first
/*
static function string MinONSPlusVersion()
{
	return "v101";
}
*/


// Another placeholder function
static function string CompiledONSPlusVersion();

// YOU MUST INCLUDE THIS IN SUBCLASSES, THIS IS USED FOR IMPORTANT COMPATABILITY CHECKS
// When your putting this in your plugin, make sure it returns the version of ONSPlus which your compiling this with. (Look at the ONSPlusVersion const in ONSPlusMutator.uc to see)
/*
static function string CompiledONSPlusVersion()
{
	return "V101";
}
*/