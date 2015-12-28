//************************************************
// SparkLine
// Draws the individual sparklines along the left
//************************************************
class SparkLine
{
  boolean showDetail, dragged, mDragging, isZoomed;
  color plotColour;
  color bg, normal;
  float x1, y1, x2, y2;
  float plotX1, plotY1, plotX2, plotY2;
  float h, w;
  int column, rowCount, mouseOver;
  int years[];
  int dataMinYear, dataMaxYear;
  float dataMin, dataMax; 
  float mouseTrackX, mouseTrackY;
  float q1, median, q3;
  int yearInterval = 50;
  int tickInterval = 25;
  
  Button title;
  DataPlot sparkPlot;
  FloatTable sparkData;
  HoverBox detail;
  RoundButton toIndexChart, lock;
  Selection sparkSelect;
  
  SparkLine (float inputX1, float inputY1, float inputX2, float inputY2, FloatTable inputData, Selection inputSelect, DataPlot inputPlot, int inputColumn) {
    x1 = inputX1;
    y1 = inputY1;
    x2 = inputX2;
    y2 = inputY2;
    plotX1 = x1 + 90;
    plotY1 = inputY1;
    plotX2 = inputX1 + (.57 * (x2 - x1));
    plotY2 = inputY2;

    sparkData = inputData;
    sparkPlot = inputPlot;
    sparkSelect = inputSelect;
    column = inputColumn;
    
    bg = color(240);
    normal = color(230);
    
    rowCount = sparkData.getRowCount();
    years = sparkData.getRowNames();
    
    dataMin = sparkPlot.getDataMin();
    dataMax = sparkPlot.getDataMax();

    dataMinYear = sparkPlot.getDataMinYear();
    dataMaxYear = sparkPlot.getDataMaxYear();

    q1 = sparkData.getQ1(column);
    median = sparkData.getMedian(column);
    q3 = sparkData.getQ3(column);
    
    String titleName = sparkData.getColumnName(column);
    String[] matcher = match(titleName, "Index");
    if(matcher != null) {
      titleName = titleName.toUpperCase();
    } 

    title = new Button(x1, y1, x1 + 90, y2, titleName, column);
    title.setAlign('r');
    if (matcher == null) {
      title.setSub(sparkData.getIndex(column).toUpperCase());  
    }
    
    // Create round button for passing data to Index Chart
    toIndexChart = new RoundButton(x2, (y2 - y1) * .5 + y1, 10);
    lock = new RoundButton(x2, (y2 - y1) * .5 + y1, 10);
    lock.setShape('l');
  }
  
  void drawSparkLine()
  {
    showDetail = false;
    
    textFont(body20);
    textSize(10);

    if(mDragging && checkMouse())
    {
      noStroke();
      fill(bg);
      rect(x1, y1, x2, y2);
    }
    
    textAlign(LEFT);
    fill(0);
    text(sparkData.getUnit(column), x1 + (.8 * (x2 - x1)), (.55 * (plotY2 - plotY1)) + plotY1);
    
    if (sparkPlot.getValid())
    {
      textAlign(RIGHT);
      fill(0, 153, 255);
      //if(!Float.isNaN(dataMin))
      if (!(dataMin < 0))
      {
        text(nf(dataMin, 0, 2), x1 + (.65 * (x2 - x1)), (.55 * (plotY2 - plotY1)) + plotY1);
      }
      fill(255, 0, 0);
      //if(!Float.isNaN(dataMax))
      if (!(dataMin < 0))
      {
        text(nf(dataMax, 0, 2), x1 + (.75 * (x2 - x1)), (.55 * (plotY2 - plotY1)) + plotY1);
      }

      // 95% Normal Band
      /*float topNormal = map(sparkPlot.getLowNormal(), dataMin, dataMax, plotY2, plotY1);
      float bottomNormal = map(sparkPlot.getUpperNormal(), dataMin, dataMax, plotY2, plotY1);
      
      fill(normal);
      rectMode(CORNERS);
      noStroke();
      rect(plotX1, topNormal, plotX2, bottomNormal);*/

      // IQR Bands
      float q1Plot = map(q1, dataMin, dataMax, plotY2, plotY1);
      if (q1Plot < plotY2) {
        fill(245);
        rectMode(CORNERS);
        noStroke();
        if (q1Plot < plotY1) {
          rect(plotX1, plotY2, plotX2, plotY1);
        }
        else {
          rect(plotX1, plotY2, plotX2, q1Plot);
        }
      }
      
      float q3Plot = map(q3, dataMin, dataMax, plotY2, plotY1);
      if (q3Plot > plotY1) {
        fill(200);
        rectMode(CORNERS);
        noStroke();
        if (q3Plot > plotY2) {
          rect(plotX1, plotY1, plotX2, plotY2);
        }
        else {
          rect(plotX1, plotY1, plotX2, q3Plot);
        }
      }

      rectMode(CORNERS);
      noStroke();
      if ((q1Plot < plotY2) && (q1Plot > plotY1) && (q3Plot > plotY1) && (q3Plot < plotY2))
      {
        fill(225);
        rect(plotX1, q1Plot, plotX2, q3Plot);
      }
      else if ((q1Plot < plotY2) && (q1Plot > plotY1) && !((q3Plot > plotY1) && (q3Plot < plotY2))) {
        fill(225);
        rect(plotX1, q1Plot, plotX2, plotY1);        
      }
      else if (!((q1Plot < plotY2) && (q1Plot > plotY1)) && (q3Plot > plotY1) && (q3Plot < plotY2)) {
        fill(225);
        rect(plotX1, plotY2, plotX2, q3Plot);             
      }
      else if ((q1Plot >= plotY2) && (q3Plot <= plotY1)) {
        fill(225);
        rect(plotX1, plotY2, plotX2, plotY1);     
      }

      float medLine = map(median, dataMin, dataMax, plotY2, plotY1);
      if (medLine > plotY1 && medLine < plotY2) {
        stroke(255);
        strokeWeight(1);
        line(plotX1, medLine, plotX2, medLine);
      }

      //println("column: " + column + " plotY2: " + plotY2 + " median: " + median);

      drawDataLine(column);

      drawDataMax();
      drawDataMin();

      toIndexChart.setPos(x2 - 15, (y2 - y1) * .5 + y1);
      toIndexChart.draw(); 
    
      if (isZoomed) {
        lock.setPos(x2, (y2 - y1) * .5 + y1);
        lock.draw();
      }

    }

    title.draw();
    if (dragged) {
      title.setPos(mouseX, mouseY, mouseX + 80, mouseY + (y2 - y1));
      title.setState(true);
    }
    else {
      title.setPos(x1, y1, x1 + 90, y2);  
    }

    if(showDetail)
    {
      detail.drawHover();
    }
  }
  
  void drawDataLine(int col) 
  {    
    noFill();
    stroke(0);
    strokeWeight(.5);
    beginShape();
    for (int row = sparkSelect.getRowStart(); row <= sparkSelect.getRowEnd(); row++) 
    {
      if (sparkData.isValid(row, col)) 
      {
        float value = sparkData.getFloat(row, col);
        float x = map(years[row], sparkSelect.getYearStart(), sparkSelect.getYearEnd(), plotX1, plotX2);
        float y = map(value, dataMin, dataMax, plotY2, plotY1);       
        if (!sparkData.isValid(row - 1, col))
        {
          vertex(x, y);
          vertex(x, y);
          endShape(); 
          
          noFill();
          stroke(0);
          strokeWeight(.5);
          
          beginShape();
          vertex(x, y);
        }
        vertex(x, y);
        // Double the curve points for the start and stop
        if ((row == sparkSelect.getRowStart()) || (row == sparkSelect.getRowEnd())) 
        {
          vertex(x, y);
        }
        //
        if (dist(mouseX, mouseY, x, y) < 5  && !showDetail) 
        { 
          showDetail = true;
          mouseTrackX = mouseX;
          mouseTrackY = mouseY;
          mouseOver = col;
          detail = new HoverBox(x, y, sparkData.getColumnName(col) + " " + years[row] + ": " + value, body20);
        }
      }
      // If previous data was valid, but this one isn't, start drawing in grey
      else if (!sparkData.isValid(row, col) && sparkData.isValid(row - 1, col) && years[row - 1] >= sparkSelect.getYearStart())
      {
        float value = sparkData.getFloat(row - 1, col);
        float x = map(years[row - 1], sparkSelect.getYearStart(), sparkSelect.getYearEnd(), plotX1, plotX2);
        float y = map(value, dataMin, dataMax, plotY2, plotY1);  
        vertex(x, y);
        endShape(); 
             
        stroke(255);
        strokeWeight(.5);  

        beginShape();
        vertex(x, y);
        vertex(x, y);        
      }
    }
    endShape();
  }
  
  void drawDataMax()
  {
    float x = map(dataMaxYear, sparkSelect.getYearStart(), sparkSelect.getYearEnd(), plotX1, plotX2);
    float y = map(dataMax, dataMin, dataMax, plotY2, plotY1);  
    
    stroke(255, 0, 0);
    strokeWeight(3);
    point(x, y);
  }
  
  void drawDataMin()
  {
    float x = map(dataMinYear, sparkSelect.getYearStart(), sparkSelect.getYearEnd(), plotX1, plotX2);
    float y = map(dataMin, dataMin, dataMax, plotY2, plotY1);  
    
    stroke(0, 153, 255);
    strokeWeight(3);
    point(x, y);
  }
 
  void drawTicks() {
    fill(0);
    textFont(body20);
    textSize(10);
    textAlign(RIGHT, CENTER);
    
    // Varying alignments
    stroke(128);
    strokeWeight(1);
    
    for (float v = dataMin; v <= dataMax; v += tickInterval) {
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
      if (v % tickInterval == 0) { // If a major tick mark
        if (v == dataMin) {
          textAlign(RIGHT); // ALign by the bottom
        } else if (v == dataMax) {
          textAlign(RIGHT, TOP); // Align by the top
        } else {
          textAlign(RIGHT, CENTER); // Center vertically
        }
        text(floor(v), plotX1 - 10, y);
        line(plotX1 - 4, y, plotX1, y); // Draw major tick
      } else {
        line(plotX1 - 2, y, plotX1, y); // Draw minor tick
      }
    }
  }
  
  boolean checkMouse()
  {
    checkTitle();
    if((mouseX >= x1 && mouseX <= x2) && (mouseY > y1 && mouseY < y2))
    {
      return true;
    }
    return false;
  }

  boolean checkTitle() {
    return title.checkMouse();
  }
  
  boolean checkToIndex() {
    return toIndexChart.checkMouse();
  }

  void setZoom(boolean inputZoom) {
    isZoomed = inputZoom;
  }

  boolean checkLock() {
    if (lock.checkMouse() && isZoomed)
      return true;
    return false;
  }

  void drag() {
    if (mouseButton == LEFT) {
      dragged = true;
    }
    else if (mouseButton == RIGHT) {
      dragged = false;  
      title.setState(false);
    }
  }

  void dragging(boolean setOtherDrag) {
    mDragging = setOtherDrag;
  }

  boolean isDragged() {
    return dragged;
  }

  boolean dragEnd()
  {
    if (dragged) {
      dragged = false;
      title.setState(false);
      return true;
    }
    return false;
  }
  
  void update() {
    dataMin = sparkPlot.getDataMin();
    dataMax = sparkPlot.getDataMax();

    dataMinYear = sparkPlot.getDataMinYear();
    dataMaxYear = sparkPlot.getDataMaxYear();
  }

  void setY(float inputY1, float inputY2) {
    y1 = inputY1;
    y2 = inputY2;

    plotY1 = inputY1;
    plotY2 = inputY2;
  }

  void setColour(color inputColour) {
    plotColour = inputColour;
    toIndexChart.setFillOffColour(plotColour);
  }
}
