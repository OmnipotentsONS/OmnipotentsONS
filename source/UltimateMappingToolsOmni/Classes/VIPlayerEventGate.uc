//=============================================================================
// VIPlayerEventGate
// $ckr1: Copyright 2011  by D. 'Crusha K. Rool' I.$
// $ckr2: <Mapping.Crocodile@googlemail.com>$
// $ckr3: Release date: 14.08.2011 00:26:25 in Package: UltimateMappingTools$
//
// This receives an incoming (Un)TriggerEvent and performs several checks about
// the Instigator of this Event. It will (un)trigger the next Event, depending on
// what the result of the check is.
//=============================================================================
class VIPlayerEventGate extends EventGate;



/* Public */

var(Events) name NoMatchEvent ; // The optional event that is (un)triggered if the Instigator is not in the WhiteList.
var(Events) name BlacklistEvent ; // The optional event that is (un)triggered if the Instigator is in the BlackList.


struct _PlayerProperties // each of these criterias needs to be fullfilled in order to be considered a match.
{
    var() String PlayerName ; // This string must be contained in the Instigator's name. Leaving this blank disables the criteria.
    var() bool bCheckExactName ; // Instigator's name must be EXACTLY the one entered in the PlayerName-field. (Unless the field is blank)
    var() enum ECheckResult  // Instigator needs to be logged in as Admin / a bot / in a vehicle.
    {
        ECR_Any,    // Ignore this criteria.
        ECR_True,   // Result must be true to be considered a match.
        ECR_False   // Result must be false to be considered a match.
    } MustBeAdmin, MustBeBot;
    var() bool bVehicleCheck ; // True to check whether the Instigator is in the RequiredVehicle, False to ignore this criteria.
    var() class<Vehicle> RequiredVehicle ; // The Instigator must be in this vehicle. None = must go by foot ;  Vehicle = can be any vehicle.
    var() string PlayerID ; // Instigator needs to have this exact sequence of characters somewhere in his ID. The longer the sequence, the less the chance of a false-positive.
    var() int MinimumRequiredScore ; // Instigator needs to have at least this much points. Enter a very low value to let everyone pass this check. ;)
    var() int TeamIndex ; // Instigator needs to be in this specific team. 0= red, 1= blue, 255= disable check
};
var() private array<_PlayerProperties> Whitelist ; // The Instigators with these criterias trigger the default Event.
var() private array<_PlayerProperties> Blacklist ; // The Instigators with these criterias trigger the BlacklistEvent.
// They are not considered for the WhiteList anymore if the BlackListCheck is positive.

var() bool bKillWarezPlayers ; // Kill the Instigator immediately, if he's using a demo CD-key. Otherwise nothing happens, no Event will be triggered at all.


/* Intern */

var const string WAREZ_ID ;  // The ID of pirated/demo CD-keys is not valid.

//=============================================================================


function Trigger(Actor Other, Pawn EventInstigator)
{
    if (PlayerController(EventInstigator.Controller) != None && PlayerController(EventInstigator.Controller).GetPlayerIDHash() == WAREZ_ID)
    {
        if (bKillWarezPlayers)
            EventInstigator.TakeDamage(10000, EventInstigator, EventInstigator.Location, vect(0,0,0), class'Gibbed');

        return; // No triggering for Warez.
    }

    if (PerformCheck(EventInstigator, True))
    {
        TriggerEvent(BlacklistEvent, self, EventInstigator); // Instigator is in Blacklist.
        return;
    }

    if (PerformCheck(EventInstigator, false))
    {
        TriggerEvent(event, self, EventInstigator); // Instigator is in Whitelist.
        return;
    }

    TriggerEvent(NoMatchEvent, self, EventInstigator); // Instigator isn't in any list.
}

function UnTrigger(Actor Other, Pawn EventInstigator)
{
    if (PlayerController(EventInstigator.Controller) != None && PlayerController(EventInstigator.Controller).GetPlayerIDHash() == WAREZ_ID)
    {
        if (bKillWarezPlayers)
            EventInstigator.TakeDamage(10000, EventInstigator, EventInstigator.Location, vect(0,0,0), class'Gibbed');

        return; // No triggering for Warez.
    }

    if (PerformCheck(EventInstigator, True))
    {
        UnTriggerEvent(BlacklistEvent, self, EventInstigator); // Instigator is in Blacklist.
        return;
    }

    if (PerformCheck(EventInstigator, false))
    {
        UnTriggerEvent(event, self, EventInstigator); // Instigator is in Whitelist.
        return;
    }

    UnTriggerEvent(NoMatchEvent, self, EventInstigator); // Instigator isn't in any list.
}

// Returns True, if Instigator is a match in the corresponding list.
function bool PerformCheck(Pawn Instigator, bool bBlacklist)
{
    local int i;
    local string InstigatorName, InstigatorHashID;
    local PlayerReplicationInfo PRI;

    PRI = Instigator.PlayerReplicationInfo;
    InstigatorName = PRI.PlayerName;

    if (PlayerController(Instigator.Controller) != None)
        InstigatorHashID = PlayerController(Instigator.Controller).GetPlayerIDHash();

    if (bBlacklist)
    {
        for (i = 0; i < Blacklist.length; i++)
        {
            if (Blacklist[i].PlayerName != "")
            {
                if (Blacklist[i].bCheckExactName)
                {
                    if (Blacklist[i].PlayerName != InstigatorName)
                        continue; // continue with the next entry, this one is already disqualified.
                }
                else
                {
                    if (InStr(Blacklist[i].PlayerName, InstigatorName) == -1)
                        continue;
                }
            }

            if ((Blacklist[i].MustBeAdmin == ECR_True && !PRI.bAdmin) || (Blacklist[i].MustBeAdmin == ECR_False && PRI.bAdmin))
                continue;

            if ((Blacklist[i].MustBeBot == ECR_True && !PRI.bBot) || (Blacklist[i].MustBeAdmin == ECR_False && PRI.bBot))
                continue;

            if (Blacklist[i].bVehicleCheck)
            {
                if ((Blacklist[i].RequiredVehicle == None && PRI.CurrentVehicle != None) || (Blacklist[i].RequiredVehicle != PRI.CurrentVehicle))
                    continue;
            }

            if (Blacklist[i].PlayerID != "")
            {
                if (InStr(Blacklist[i].PlayerID, InstigatorHashID) == -1)
                    continue;
            }

            if (PRI.Score < Blacklist[i].MinimumRequiredScore)
                continue;

            if (Blacklist[i].TeamIndex != 255)
            {
                if (!PRI.bNoTeam)
                {
                    if (PRI.Team.TeamIndex != Blacklist[i].TeamIndex)
                        continue;
                }
                else
                    continue;
            }

            // Passed all tests!
            return True;
        }

        // All entries in the list checked, but no match.
        return False;
    }
    else
    {
        for (i = 0; i < Whitelist.length; i++)
        {
            if (Whitelist[i].PlayerName != "")
            {
                if (Whitelist[i].bCheckExactName)
                {
                    if (Whitelist[i].PlayerName != InstigatorName)
                        continue; // continue with the next entry, this one is already disqualified.
                }
                else
                {
                    if (InStr(Whitelist[i].PlayerName, InstigatorName) == -1)
                        continue;
                }
            }

            if ((Whitelist[i].MustBeAdmin == ECR_True && !PRI.bAdmin) || (Whitelist[i].MustBeAdmin == ECR_False && PRI.bAdmin))
                continue;

            if ((Whitelist[i].MustBeBot == ECR_True && !PRI.bBot) || (Whitelist[i].MustBeAdmin == ECR_False && PRI.bBot))
                continue;

            if (Whitelist[i].bVehicleCheck)
            {
                if ((Whitelist[i].RequiredVehicle == None && PRI.CurrentVehicle != None) || (Whitelist[i].RequiredVehicle != PRI.CurrentVehicle))
                    continue;
            }

            if (Whitelist[i].PlayerID != "")
                if (InStr(Whitelist[i].PlayerID, InstigatorHashID) == -1)
                    continue;

            if (PRI.Score < Whitelist[i].MinimumRequiredScore)
                continue;

            if (Whitelist[i].TeamIndex != 255)
            {
                if (!PRI.bNoTeam)
                {
                    if (PRI.Team.TeamIndex != Whitelist[i].TeamIndex)
                        continue;
                }
                else
                    continue;
            }

            // Passed all tests!
            return True;
        }

        // All entries in the list checked, but no match.
        return False;
    }
}


//=============================================================================

defaultproperties
{
     WAREZ_ID="238c7dd4ec4a065e2314c1c8b4d41ca6"
}
