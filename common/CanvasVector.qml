import QtQuick 2.0

Item {
  id: root

  property real fromRadius: 0
  property real fromPhi: 0
  property real radius: 0
  property real phi: 0
  property bool circle: false
  property real circleValue: maxValue
  property color circleColor: "lightGray"
  property color color: "white"
  property bool grid: false
  property string labelText: ""
  property real labelPhiOffset: 0
  property real labelLengthFactor: 1.0
  property real maxValue
  //this is like anchors.fill: parent
  property real pixelScale: Math.min(height,width)/maxValue/2

  onPhiChanged: canvas.markDirty(Qt.rect(0,0,width,height))

  function replot() {
    canvas.markDirty(Qt.rect(0,0,width,height));
  }

  Canvas {
    id: canvas
    anchors.fill: parent
    antialiasing: true
    smooth: true

    onWidthChanged: markDirty(Qt.rect(0,0,width,height));

    function radToDeg(rad)
    {
      return rad * (180/Math.PI)
    }
    function degToRad(deg)
    {
      return deg * (Math.PI/180)
    }
    function arrowHeadLines(ctx,toPoint,arrowPoint1,arrowPoint2){
      ctx.beginPath();
      ctx.moveTo(arrowPoint1.x,arrowPoint1.y);
      ctx.lineTo(toPoint.x,toPoint.y);
      ctx.lineTo(arrowPoint2.x,arrowPoint2.y);
      ctx.stroke();
    }
    function strokeArrowHead(ctx,toPoint,arrowPoint1,arrowPoint2){
      ctx.beginPath();
      ctx.moveTo(toPoint.x,toPoint.y);
      ctx.lineTo(arrowPoint1.x,arrowPoint1.y);
      ctx.lineTo(arrowPoint2.x,arrowPoint2.y);
      ctx.lineTo(toPoint.x,toPoint.y);
      ctx.fillStyle = root.color.toString();
      ctx.fill();
      ctx.stroke();
    }
    function drawArrow(ctx,fromPoint,toPoint,stroked){
      var dx = toPoint.x - fromPoint.x;
      var dy = toPoint.y - fromPoint.y;

      // normalize
      var length = Math.sqrt(dx * dx + dy * dy);
      var unitDx = dx / length;
      var unitDy = dy / length;
      // increase this to get a larger arrow head
      var arrowHeadSize = 6;

      var arrowPoint1 = Qt.point(
            (toPoint.x - unitDx * arrowHeadSize - unitDy * arrowHeadSize),
            (toPoint.y - unitDy * arrowHeadSize + unitDx * arrowHeadSize));
      var arrowPoint2 = Qt.point(
            (toPoint.x - unitDx * arrowHeadSize + unitDy * arrowHeadSize),
            (toPoint.y - unitDy * arrowHeadSize - unitDx * arrowHeadSize));

      //ctx.fillStyle = "rgba(100, 0, 200, 0.5)";
      // Drawing Arrow Line.
      ctx.beginPath();
      ctx.moveTo(fromPoint.x,fromPoint.y);
      ctx.lineTo(toPoint.x,toPoint.y);
      ctx.closePath();
      ctx.lineWidth = 1;
      ctx.stroke();
      if(stroked)
        strokeArrowHead(ctx,toPoint,arrowPoint1,arrowPoint2);
      else
        arrowHeadLines(ctx,toPoint,arrowPoint1,arrowPoint2);
    }

    function drawLabel(ctx, toPoint)
    {
      var xOffset=10;
      if(root.labelPhiOffset===0)
      {
        xOffset=root.labelText.length*7
      }
      ctx.fillStyle = root.color.toString();
      ctx.font = "20px sans-serif";
      ctx.fillText(root.labelText, toPoint.x-xOffset, toPoint.y+5);
      ctx.stroke();

    }

    function canvas_arrow(fromx, fromy, rad, phi) {
      var context = canvas.getContext("2d");
      var factor;

      factor=root.pixelScale


      context.clearRect(0, 0, canvas.width, canvas.height);

      if(root.grid)
      {
        context.strokeStyle = "rgba(128, 128, 128, 0.5)"
        context.beginPath();
        context.moveTo(fromx-root.maxValue*factor,fromy);
        context.lineTo(fromx+root.maxValue*factor,fromy);
        context.closePath();
        context.stroke();
        context.beginPath();
        context.moveTo(fromx,fromy-root.maxValue*factor);
        context.lineTo(fromx,fromy+root.maxValue*factor);
        context.closePath();
        context.stroke();
      }

      if(root.circle)
      {
        context.strokeStyle = root.circleColor
        context.beginPath();
        context.arc(fromx, fromy, factor*root.circleValue, 0, Math.PI*2, true);
        context.closePath();
        context.stroke();
      }

      context.strokeStyle = root.color.toString();

      if(Math.abs(fromPhi)>0 && fromRadius>0)
      {
        fromx += factor*fromRadius*Math.cos(fromPhi)
        fromy += factor*fromRadius*Math.sin(fromPhi)
      }

      drawArrow(context,Qt.point(fromx,fromy),Qt.point(fromx+factor*rad*Math.cos(phi),fromy+factor*rad*Math.sin(phi)),true);

      if(root.labelText !=="")
      {
        drawLabel(context,Qt.point(fromx+root.labelLengthFactor*factor*maxValue*Math.cos(phi+root.labelPhiOffset),
                                   fromy+root.labelLengthFactor*factor*maxValue*Math.sin(phi+root.labelPhiOffset)*0.9))
      }
    }
    onPaint: canvas_arrow(width/2,height/2,root.radius,root.phi);
  }
}
