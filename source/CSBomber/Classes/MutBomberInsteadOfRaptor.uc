class MutBomberInsteadOfRaptor extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None && SVehicleFactory(Other).VehicleClass != None)
     {
         if(SVehicleFactory(Other).VehicleClass.name == 'Wasp')
         {
            SVehicleFactory(Other).VehicleClass = class'CSPlasmaFighter';
         }
         if(SVehicleFactory(Other).VehicleClass.name == 'ONSDualAttackCraft')
         {
            SVehicleFactory(Other).VehicleClass = class'CSSpankBomber';
         }
         if(SVehicleFactory(Other).VehicleClass.name == 'Falcon')
         {
            SVehicleFactory(Other).VehicleClass = class'CSBomber';
         }
         if(SVehicleFactory(Other).VehicleClass.name == 'ONSAttackCraft')
         {
            SVehicleFactory(Other).VehicleClass = class'CSBomber';
         }
         if(SVehicleFactory(Other).VehicleClass.name == 'PheonixAttackCraft')
         {
            SVehicleFactory(Other).VehicleClass = class'CSBioBomber';
         }
         if(SVehicleFactory(Other).VehicleClass.name == 'Aurora')
         {
            SVehicleFactory(Other).VehicleClass = class'CSSpankBomber';
         }
         if(SVehicleFactory(Other).VehicleClass.name == 'ONSHoverBike')
         {
            SVehicleFactory(Other).VehicleClass = class'CSBioBomber';
         }

     }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="CSBomber test"
     Description="Test out bombers on air mars, replaces raptor, falcon, wasp with bomber variants"
}
