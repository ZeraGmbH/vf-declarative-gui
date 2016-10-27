import QtQuick 2.0

Item {
  id: root

  property vector2d v1: Qt.vector2d(0,0)
  property string v1Label: ""
  property color v1Color: ZColorTheme.system1Color;
  property vector2d v2: Qt.vector2d(0,0)
  property string v2Label: ""
  property color v2Color: ZColorTheme.system2Color;
  property vector2d v3: Qt.vector2d(0,0)
  property string v3Label: ""
  property color v3Color: ZColorTheme.system3Color;

  // lines with color gradients will have this color in the middle
  property color tweakColor: "white"

  property real phi: 0

  property bool circle: true
  property real circleValue: maxValue
  property color circleColor: "lightGray"

  property bool grid: true

  property real maxValue: 0
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

    renderStrategy: Canvas.Cooperative
    renderTarget: Canvas.Image

    function radToDeg(rad)
    {
      return rad * (180/Math.PI)
    }
    function degToRad(deg)
    {
      return deg * (Math.PI/180)
    }

    function drawTriangle(ctx, fromx, fromy)
    {
      var tmpXv1, tmpYv1, tmpPhiv1;
      var tmpXv2, tmpYv2, tmpPhiv2;
      var tmpXv3, tmpYv3, tmpPhiv3;

      var grd1, grd2, grd3;

      //Scale vectors and convert to x/y
      //v1
      tmpPhiv1 = Math.atan2(root.v1.y, root.v1.x)-root.phi;
      tmpXv1 = fromx+root.pixelScale*root.v1.length()*Math.cos(tmpPhiv1);
      tmpYv1 = fromy+root.pixelScale*root.v1.length()*Math.sin(tmpPhiv1);

      //v2
      tmpPhiv2 = Math.atan2(root.v2.y, root.v2.x)-root.phi;
      tmpXv2 = fromx+root.pixelScale*root.v2.length()*Math.cos(tmpPhiv2);
      tmpYv2 = fromy+root.pixelScale*root.v2.length()*Math.sin(tmpPhiv2);

      //v3
      tmpPhiv3 = Math.atan2(root.v3.y, root.v3.x)-root.phi;
      tmpXv3 = fromx+root.pixelScale*root.v3.length()*Math.cos(tmpPhiv3);
      tmpYv3 = fromy+root.pixelScale*root.v3.length()*Math.sin(tmpPhiv3);

      //Gradients
      //v1->v2
      grd1=ctx.createLinearGradient(tmpXv1,tmpYv1,tmpXv2,tmpYv2);
      grd1.addColorStop(0,root.v1Color.toString());
      grd1.addColorStop(1,root.v2Color.toString());

      //v2->v3
      grd2=ctx.createLinearGradient(tmpXv2,tmpYv2,tmpXv3,tmpYv3);
      grd2.addColorStop(0,root.v2Color.toString());
      grd2.addColorStop(1,root.v3Color.toString());

      //v3->v1
      grd3=ctx.createLinearGradient(tmpXv3,tmpYv3,tmpXv1,tmpYv1);
      grd3.addColorStop(0,root.v3Color.toString());
      grd3.addColorStop(1,root.v1Color.toString());


      ctx.lineWidth = 1;


      //--Draw--//////////////////////// v1 -> v2
      ctx.beginPath();
      ctx.moveTo(tmpXv1, tmpYv1);
      ctx.lineTo(tmpXv2, tmpYv2);
      ctx.closePath();
      ctx.strokeStyle = grd1
      ctx.stroke();

      //--Draw--//////////////////////// v2 -> v3
      ctx.beginPath();
      ctx.moveTo(tmpXv2, tmpYv2);
      ctx.lineTo(tmpXv3, tmpYv3);
      ctx.closePath();
      ctx.strokeStyle = grd2;
      ctx.stroke();


      //--Draw--//////////////////////// v3 -> v1
      ctx.beginPath();
      ctx.moveTo(tmpXv3, tmpYv3);
      ctx.lineTo(tmpXv1, tmpYv1);
      ctx.closePath();
      ctx.strokeStyle = grd3;
      ctx.stroke();


      if(root.v1Label !=="")
      {
        var xOffset1=root.v1Label.length*7
        ctx.fillStyle = root.v1Color;
        ctx.font = "20px sans-serif";
        ctx.moveTo(fromx, fromy)

        ctx.fillText(root.v1Label, root.pixelScale*root.maxValue*Math.cos(tmpPhiv1)+fromx-xOffset1, 0.9*root.pixelScale*root.maxValue*Math.sin(tmpPhiv1)+fromy+5);
      }
      if(root.v1Label !=="")
      {
        var xOffset2=root.v2Label.length*7
        ctx.fillStyle = root.v2Color;
        ctx.font = "20px sans-serif";
        ctx.moveTo(fromx, fromy)
        ctx.fillText(root.v2Label, root.pixelScale*root.maxValue*Math.cos(tmpPhiv2)+fromx-xOffset2, 0.9*root.pixelScale*root.maxValue*Math.sin(tmpPhiv2)+fromy+5);
      }
      if(root.v1Label !=="")
      {
        var xOffset3=root.v3Label.length*7
        ctx.fillStyle = root.v3Color;
        ctx.font = "20px sans-serif";
        ctx.moveTo(fromx, fromy)
        //
        ctx.fillText(root.v3Label, root.pixelScale*root.maxValue*Math.cos(tmpPhiv3)+fromx-xOffset3, 0.9*root.pixelScale*root.maxValue*Math.sin(tmpPhiv3)+fromy+5);
      }
    }

    function canvas_triangle(fromx, fromy) {
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

      drawTriangle(context,fromx,fromy);
    }
    onPaint: {
      if(visible === true)
      {
        canvas_triangle(width/2,height/2);
      }
    }
  }
}
