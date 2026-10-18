pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

QtObject {
    id: wifi

    readonly property NetworkDevice _wifiDev: {
        let list = Networking.devices.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].type === 1 || list[i].name.startsWith("wl"))
                return list[i];
        }
        return null;
    }

    readonly property bool connexion: _wifiDev ? _wifiDev.connected : false

    
    readonly property var _activeNet: {
        if (!_wifiDev) return null;
        let nets = _wifiDev.networks.values;
        for (let i = 0; i < nets.length; i++) {
            if (nets[i].connected)
                return nets[i];
        }
        return null;
    }

    readonly property string ssid: _activeNet ? _activeNet.name : ""

   
    readonly property real signal: _activeNet ? _activeNet.signalStrength : 0

   
    readonly property int signal_percent: Math.round(signal * 100)
}