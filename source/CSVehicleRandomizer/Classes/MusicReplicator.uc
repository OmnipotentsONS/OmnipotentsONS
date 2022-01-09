//=============================================================================
// MusicReplicator.
//=============================================================================
class MusicReplicator extends Actor
	placeable
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

// Exists solely to change the music on the client side.
// used by ONSVehicleRandomizer

var string CurrentSong;
var string OldSong;
var int MusicThread;

replication
{
	reliable if (Role == ROLE_Authority)
		CurrentSong;
}

// Changes music to Song.
// Saves the song filename in a variable and sets a timer to change to that music
// (for some reason, changing the music right here doesn't work at the start of the level)
function ServerChangeMusic(string Song)
{
	// This gets called once at the beginning of the map by ONSVehicleRandomizer.
	// At this time, null out the level's Song so that no music will play.
	// Otherwise, the level music will overlap with our music.
	Level.Song = "";

	CurrentSong = Song;
	// If on a listen or standalone server, set the timer to change the song.
	// NM_Client will change their song in PostNetReceive.
	if (Level.NetMode == NM_ListenServer || Level.NetMode == NM_Standalone)
		SetTimer(1.0, false);
}

// PostNetReceive -- change songs for NM_Client connections
simulated event PostNetReceive()
{
	if (CurrentSong != "" && CurrentSong != OldSong && Level.NetMode == NM_Client)
	{
		SwitchMusic();
		OldSong = CurrentSong;
	}
}

// Stop old music (if any) and play the new song.
simulated function SwitchMusic()
{
	if (MusicThread != 0)
		StopMusic(MusicThread, 1.0);

	MusicThread = PlayMusic(CurrentSong, 1.0);

	// If the music didn't initialize, try again later
	if (MusicThread == 0 && Level.NetMode == NM_Client)
		SetTimer(1.0, false);
}

simulated event Timer()
{
	SwitchMusic();
}

defaultproperties
{
     bHidden=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     Texture=Texture'Engine.S_Ambient'
     bNetNotify=True
     bSelected=True
}
