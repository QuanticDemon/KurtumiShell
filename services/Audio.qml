pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Services.Pipewire

Singleton {
    id: audio
    
    readonly property var sink: Pipewire.defaultAudioSink

    PwObjectTracker{
      objects: [audio.sink]
    }
    readonly property real volume: sink?.audio?.volume ?? 0 

    readonly property bool muted: sink?.audio?.muted ?? false
      
    function changeVol(nmax){
      if(!sink?.audio)
        return
      sink.audio.volume = Math.max(
        0, Math.min(1, sink.audio.volume + nmax)
      )
      
    

    }

    function muteAudio(){
      if(!sink?.audio)
         return 

      sink.audio.muted = !sink.audio.muted
    }
}
