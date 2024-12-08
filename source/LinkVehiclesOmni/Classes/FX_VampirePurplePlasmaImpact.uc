class FX_VampirePurplePlasmaImpact extends FX_PlasmaImpact notplaceable;


simulated function PostBeginPlay()
{
	  super.PostBeginPlay();
    SetPurpleColor();

   
}

simulated function SetPurpleColor()
{
       
    Emitters[0].ColorScale[0].Color = class'Canvas'.static.MakeColor( 136, 14, 79);
   	Emitters[0].ColorScale[1].Color = class'Canvas'.static.MakeColor( 136, 14, 79);

    Emitters[1].ColorScale[0].Color = class'Canvas'.static.MakeColor( 124, 10, 2);
    Emitters[1].ColorScale[1].Color = class'Canvas'.static.MakeColor( 0, 77, 64);

    Emitters[2].ColorScale[0].Color = class'Canvas'.static.MakeColor(74,20,140); //74,20,140
    Emitters[2].ColorScale[1].Color = class'Canvas'.static.MakeColor( 74,20,140);
}


defaultproperties
{

}