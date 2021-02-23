import QtQml 2.14
import QtQuick 2.14

Item {
    /*  taskArray:
        Array of
        {
                'type': 'block'/'rpc',
                'callFunction': <pointer to call function>,
                'notifyCallback: <pointer to notification callback)
                'rpcTarget': Target entity For rpc type only
        }
        Notes:
        * callFunction: Blocking functions are expected to return true (success)/ false(error)
        * notifyCallback: If not set use wise default
        * notifyCallback: parameter: result: bool for blocking / rpc-result
        * notifyCallback: return: true continue / false stop
    */
    property var taskArray: []
    function startRun() {
        if(!_private.running) {
            _private.currentTaskNo = 0
            _private.running = true
            startTask()
        }
        else {
            console.error("Tasklist already running")
            //stop(true)
        }
    }
    signal done(bool error)
    readonly property alias running: _private.running


    ///////////////////////////////////////////////////////////////////////////
    // internals
    Timer { // blocking: avoid stack overflow on many blocking tasks
            // rpc: decouple RPC response from next task
        id: timerNextHelper
        interval: 0
        repeat: false
        running: false
        onTriggered: {
            startNextTask()
        }
    }
    Component {
        id: rpcConnection
        Connections {
            onSigRPCFinished: {
                if(t_identifier === _private.rpcId) {
                    let cont
                    // no notifier callback set: use default matching most times
                    if(taskArray[_private.currentTaskNo].notifyCallback === undefined) {
                        // default
                        cont =  t_resultData["RemoteProcedureData::resultCode"] === 0 &&
                                t_resultData["RemoteProcedureData::Return"] === true
                    }
                    else {
                        cont = taskArray[_private.currentTaskNo].notifyCallback(t_resultData)
                    }
                    if(cont) {
                        timerNextHelper.start()
                    }
                    else {
                        _private.running = false
                        stop(true)
                    }
                    _private.rpcId = undefined
                    _private.currentConnection.destroy()
                    _private.currentConnection = undefined
                }
            }
        }
    }
    Item {
        id: _private
        property var rpcId
        property var running: false
        property int currentTaskNo: 0
        property var currentConnection
    }

    function startNextTask() {
        ++_private.currentTaskNo
        if(_private.currentTaskNo < taskArray.length) {
            startTask()
        }
        else {
            stop(false)
        }
    }

    function startTask() {
        switch(taskArray[_private.currentTaskNo].type) {
        case 'block':
            let ret = taskArray[_private.currentTaskNo].callFunction()
            let cont
            if(taskArray[_private.currentTaskNo].notifyCallback === undefined) {
                cont = ret // stop on error
            }
            else {
                cont = taskArray[_private.currentTaskNo].notifyCallback(ret)
            }
            if(cont) {
                timerNextHelper.start()
            }
            else {
                _private.running = false
                stop(ret)
            }
            break;
        case 'rpc':
            if(_private.rpcId === undefined) {
                _private.currentConnection = rpcConnection.createObject(null, {target: taskArray[_private.currentTaskNo].rpcTarget})
                _private.rpcId = taskArray[_private.currentTaskNo].callFunction()
            }
            else {
                console.error("TaskList: Pending RPC for", _private.currentTaskNo)
                stop(true)
            }
            break;
        default:
            console.error("TaskList: Invalid task type for", _private.currentTaskNo)
            stop(true)
            break;
        }
    }

    function stop(error) {
        _private.running = false
        done(error)
    }

}
