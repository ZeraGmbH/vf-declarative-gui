import QtQml 2.14
import QtQuick 2.14

Item {
    ///////////////////////////////////////////////////////////////////////////
    // public interface

    /* taskArray has to be set as a array of
      {
        'type': 'block'/'rpc',
        'callFunction': <pointer to the function starting a task>,
        'notifyCallback: <pointer to after-task notification/evaluation function>,
        'rpcTarget': <target entity for (rpc type only / othewise ignored)>
      }

      Details on function callbacks:
        callFunction:
          * no parameter
          * return value:
            * block: functions are expected to return true (ok) / false (error)
            * rpc functions must return RPC ID
        notifyCallback:
          * if not set use wise default
          * parameter:
            * block: bool return of callFunction
            * rpc: rpc-result: t_resultData
          * return value bool: true continue next task / false stop with error
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
        }
    }
    signal done(bool error)
    readonly property alias running: _private.running


    ///////////////////////////////////////////////////////////////////////////
    // private internals
    Timer { // blocking: avoid call-stack explosion on many blocking tasks
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
            function onSigRPCFinished(t_identifier, t_resultData) {
                if(t_identifier === _private.rpcId) {
                    let continueNext
                    // no notifier callback set: use default matching most times
                    if(taskArray[_private.currentTaskNo].notifyCallback === undefined) {
                        // default
                        continueNext =  t_resultData["RemoteProcedureData::resultCode"] === 0 &&
                                t_resultData["RemoteProcedureData::Return"] === true
                    }
                    else {
                        continueNext = taskArray[_private.currentTaskNo].notifyCallback(t_resultData)
                    }
                    if(continueNext) {
                        timerNextHelper.start()
                    }
                    else {
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
            let ok = taskArray[_private.currentTaskNo].callFunction()
            let continueNext
            if(taskArray[_private.currentTaskNo].notifyCallback === undefined) {
                continueNext = ok // stop on error
            }
            else {
                continueNext = taskArray[_private.currentTaskNo].notifyCallback(ok)
            }
            if(continueNext) {
                timerNextHelper.start()
            }
            else {
                stop(!ok)
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
