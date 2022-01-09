class MutLinkNukeRadar extends Mutator;

//Since HUD is not an Actor it won't replicate the same 
//so we replicate through the mutator instead

//support up to 10 nukes on screen
var() vector p0,p1,p2,p3,p4,p5,p6,p7,p8,p9;

replication
{
    unreliable if(Role == ROLE_Authority)
        p0,p1,p2,p3,p4,p5,p6,p7,p8,p9;
}

simulated function PostBeginPlay()
{
    local ONSOnslaughtGame Game;

    Game = ONSOnslaughtGame(Level.Game);
    if(Game != None)
    {
        Game.HUDType="CSLinkNuke.CSLinkNukeHUD";
    }

    super.PostBeginPlay();
}


simulated function Tick(float DT)
{
    local Pawn gunHolder;
    super.Tick(DT);

    if(Role == ROLE_Authority)
    {
        p0 = vect(0,0,0);
        p1 = vect(0,0,0);
        p2 = vect(0,0,0);
        p3 = vect(0,0,0);
        p4 = vect(0,0,0);
        p5 = vect(0,0,0);
        p6 = vect(0,0,0);
        p7 = vect(0,0,0);
        p8 = vect(0,0,0);
        p9 = vect(0,0,0);
        
        foreach DynamicActors(class'Pawn', gunHolder)
        {
            if(HasLinkNuke(gunHolder))
            {
                if(p0 == vect(0,0,0))
                    p0 = gunHolder.Location;
                else if(p1 == vect(0,0,0))
                    p1 = gunHolder.Location;
                else if(p2 == vect(0,0,0))
                    p2 = gunHolder.Location;
                else if(p3 == vect(0,0,0))
                    p3 = gunHolder.Location;
                else if(p4 == vect(0,0,0))
                    p4 = gunHolder.Location;
                else if(p5 == vect(0,0,0))
                    p5 = gunHolder.Location;
                else if(p6 == vect(0,0,0))
                    p6 = gunHolder.Location;
                else if(p7 == vect(0,0,0))
                    p7 = gunHolder.Location;
                else if(p8 == vect(0,0,0))
                    p8 = gunHolder.Location;
                else if(p9 == vect(0,0,0))
                    p9 = gunHolder.Location;
                else break;
            }
        }
    }
}

simulated function bool HasLinkNuke(Pawn gunHolder)
{
    local inventory Inv;
    for(Inv=gunHolder.Inventory;Inv!=None;INv=Inv.Inventory)
    {
        if(CSLinkNuke(Inv) != None && CSLinkNuke(Inv).HasAmmo())
            return true;
    }

    return false;
}

defaultproperties
{
    bAddToServerPackages=True

    GroupName=""
    FriendlyName="Link Nuke Radar"
    Description="Put link nukes on the minimap"

    bAlwaysRelevant=true
    bNoDelete=false
    bStatic=false
    RemoteRole=ROLE_SimulatedProxy
    NetPriority=3.0
}