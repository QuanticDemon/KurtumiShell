pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton{
    id:battery

    readonly property real battery_percent : UPower.displayDevice.percentage * 100
    readonly property var state:
           UPower.displayDevice.state
   
       readonly property bool charging:
           state === UPowerDeviceState.Charging
}

