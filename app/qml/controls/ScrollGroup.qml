import QtQuick 2.0
import QtQuick.Controls 2.4

Item {
    id: root
    property var groupItems : []
    property bool xactive: true
    property bool yactive: true
    property ScrollBar scrollbarX : null
    property ScrollBar scrollbarY : null
    property real positionX : 0
    property real positionY: 0
    property real scrollbarPosX: 0
    property real scrollbarPosY: 0
    property int lastXEle: -1
    property int lastYEle: -1

    function appendFlickable(item){
        groupItems.push(item)
        connect(groupItems.length-1)
    }

    function removeFlickable(item){
        for(var ele=0; ele<groupItems.length;ele++){
            if(groupItems[ele] === item){
                groupItems.splice(ele)
                break;
            }
        }
    }

    function connect(ele){
        if(xactive){
            var funcx = function(pos = ele) {
                return function(){
                    var value=groupItems[pos].visibleArea.xPosition/(1-groupItems[pos].visibleArea.widthRatio);
                    if(value !== positionY){
                        positionX=value
                        lastXEle=pos;
                    }
                }
            }
            groupItems[ele].onContentXChanged.connect(funcx())
        }

        if(yactive){
            var funcy = function(pos = ele) {
                return function(){
                    var value=groupItems[pos].visibleArea.yPosition/(1-groupItems[pos].visibleArea.heightRatio);
                    if(value !== positionY){
                        positionY=value
                        lastYEle=pos;
                    }
                }
            }
            groupItems[ele].onContentYChanged.connect(funcy())
        }
    }


    onPositionXChanged: {
        for(var ele=0; ele<groupItems.length;ele++){
            if(ele !== lastXEle){
                groupItems[ele].contentX=positionX * (groupItems[ele].width /groupItems[ele].visibleArea.widthRatio-groupItems[ele].width);
            }
        }
        if(lastXEle !== -1 && scrollbarX !== null){
               scrollbarX.position=positionX
        }
    }

    onPositionYChanged: {
        for(var ele=0; ele<groupItems.length;ele++){
            if(ele !== lastYEle){
                groupItems[ele].contentY=positionY * (groupItems[ele].height /groupItems[ele].visibleArea.heightRatio-groupItems[ele].height);
            }
        }
        if(lastYEle !== -1 && scrollbarY !== null){
               scrollbarY.position=positionY
        }
    }


    Component.onCompleted: {
        for(var ele=0; ele<groupItems.length;ele++){
            connect(ele)
        }
    }

    onScrollbarXChanged: {
           scrollbarY.onPositionChanged.connect(function(){
               var value=scrollbarX.position;
               if(value !== root.positionY){
                root.positionY=value;
                lastXEle=-1;
                }
           })
    }

    onScrollbarYChanged: {
           scrollbarY.onPositionChanged.connect(function(){
               var value=scrollbarY.position;
               if(value !== root.positionY){
                root.positionY=value;
                lastYEle=-1;
                }
           })
    }


}
