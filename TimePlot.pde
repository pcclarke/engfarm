class TimePlot
{
  boolean[] usage;
  boolean[] greyed;
  boolean showDetail, selMode;
  
  color[] plotColour;
  color background;
  
  float x1, y1, x2, y2; 
  float plotX1, plotY1, plotX2, plotY2;
  float dataMin, dataMax; 
  float mouseTrackX, mouseTrackY;
  float selX1, selX2;
  
  int rowCount, mouseOver;
  int years[];
  int yearMin, yearMax;
  int yearInterval = 100;
  int tickInterval = 75;
  int selYear1, selYear2;
  
  FloatTable chartData;
  HoverBox detail;
  Selection timeSelect;
  
  TimePlot (float inputX1, float inputY1, float inputX2, float inputY2, FloatTable inputData, Selection inputSelect)
  {
    x1 = inputX1;
    x2 = inputX2;
    plotX1 = inputX1 + 75;
    plotY1 = inputY1;
    plotX2 = inputX2 - 25;
    plotY2 = inputY2;

    chartData = inputData;
    timeSelect = inputSelect;
    
    background = color(255);
    plotColour = new color[chartData.getColumnCount()];
    
    rowCount = chartData.getRowCount();
    years = chartData.getRowNames();
    yearMin = years[0];
    yearMax = years[years.length - 1];
    dataMax = chartData.getTableMax();
  }
  
  void drawChart()
  {
    showDetail = false;
    
    fill(0);
    textFont(futura20);
    textSize(12);
    textAlign(LEFT);
    text("1860-9", x1, (.4 * (plotY2 - plotY1)) + plotY1);
    text("Shillings", x1, (.65 * (plotY2 - plotY1)) + plotY1);
    
    fill(background);
    rectMode(CORNERS);
    noStroke();
    rect(plotX1, plotY1, plotX2, plotY2);
    
    // Draw selection area
    drawSelection(selMode);
       
    drawYearLabels();
    
    for(int i = 0; i < chartData.getColumnCount(); i++)
    {
      if(usage[i])
      {
        drawDataCurve(i);
      }
    }
    
    drawTicks(); 
    
    if(showDetail)
    {
      detail.drawHover();
    }
  }
  
  void drawSelection(boolean selectionMode)
  {
    if(selectionMode)
    {
      noStroke();
      fill(240);
      rect(selX1, plotY1, selX2, plotY2);
      
      float year1 = map(selX1, plotX1, plotX2, yearMin, yearMax);
      float year2 = map(selX2, plotX1, plotX2, yearMin, yearMax);

      stroke(0);
      strokeWeight(1);

      line(selX1, plotY1, selX1, plotY2);
      line(selX2, plotY1, selX2, plotY2);


      if (abs(selX2 - selX1) > 40) {
        textAlign(LEFT);
        textFont(futura20);
        textSize(10);
        fill(0);
        if (selX2 > selX1) {
          text(round(year1), selX1 + 3, plotY1 + 10);
          text(round(year2), selX2 - 23, plotY1 + 10); 
        }
        else {
          text(round(year1), selX1 - 23, plotY1 + 10);
          text(round(year2), selX2 + 3, plotY1 + 10); 
        }
      }
      
    }
  }
  
  void drawDataCurve(int col) 
  {    
    noFill();
    if (greyed[col])
    {
      stroke(180);
    }
    else
    {
      stroke(plotColour[col]);
    }
    strokeWeight(1);
    beginShape();
    for (int row = 0; row < rowCount; row++) 
    {
      if (chartData.isValid(row, col)) 
      {
        float value = chartData.getFloat(row, col);
        float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
        float y = map(value, dataMin, dataMax, plotY2, plotY1);        
        if (!chartData.isValid(row - 1, col))
        {
          curveVertex(x, y);
          curveVertex(x, y);
          endShape(); 
          
          noFill();
          if (greyed[col])
          {
            stroke(180);
          }
          else
          {
            stroke(plotColour[col]);
          }
          strokeWeight(1);
          
          beginShape();
          curveVertex(x, y);
        }
        curveVertex(x, y);
        // Double the curve points for the start and stop
        if ((row == 0) || (row == rowCount -1)) 
        {
          curveVertex(x, y);
        }
        //
        if (dist(mouseX, mouseY, x, y) < 5  && !showDetail) 
        { 
          showDetail = true;
          mouseTrackX = mouseX;
          mouseTrackY = mouseY;
          mouseOver = col;
          detail = new HoverBox(x, y, chartData.getColumnName(col) + " " + years[row] + ": " + value);
        }
      }
      // If previous data was valid, but this one isn't, start drawing in grey
      else if (!chartData.isValid(row, col) && chartData.isValid(row - 1, col))
      {
        float value = chartData.getFloat(row - 1, col);
        float x = map(years[row - 1], yearMin, yearMax, plotX1, plotX2);
        float y = map(value, dataMin, dataMax, plotY2, plotY1);  
        curveVertex(x, y);
        endShape(); 
             
        stroke(200);
        strokeWeight(1);  

        beginShape();
        curveVertex(x, y);
        curveVertex(x, y);        
      } 
    }
    endShape();
  }
 
  void drawTicks() 
  {
    fill(0);
    textFont(futura20);
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
  
  void drawYearLabels() 
  {
    fill(0);
    textFont(futura20);
    textSize(10);
    //textAlign(CENTER, TOP);
    textAlign(LEFT);
    
    // Use thin, grey lines to draw the grid.
    stroke(224);
    strokeWeight(1);
    
    for (int row = yearMin; row < yearMax; row++) 
    {
      if ((row % yearInterval) == 0)
      {
        float x = map(row, yearMin, yearMax, plotX1, plotX2);
        text(row, x, plotY2 + 15);
        line(x, plotY1, x, plotY2);
        /*float x = map(row, yearMin, yearMax, plotX1, plotX2);
        pushMatrix();
        translate(x - 20, plotY2 + 22);
        rotate(-PI/4);  
        text(row, 0, 0);
        popMatrix();
        line(x, plotY1, x, plotY2);*/
      }
    }
  }
  
  void setUsage(boolean[] inputUsage)
  {
    usage = inputUsage;
    greyed = new boolean[usage.length];
    
    float m = -Float.MAX_VALUE;
    for(int i = 0; i < chartData.getColumnCount(); i++)
    {
      if(usage[i])
      {
        if (m < chartData.getColumnMax(i))
        {
          m = chartData.getColumnMax(i);
        }
        plotColour[i] = assignColour(i);
      }
    }
    dataMax = m;
  }
  
  void mPressed()
  {
            
    if(checkMouse())
    {
      if (mouseButton == LEFT)
      {
        if (dist(mouseX, mouseY, mouseTrackX, mouseTrackY) < 2)
        {
          greyed[mouseOver] = greyed[mouseOver] ? false : true;
        }
        else
        {
          selX1 = mouseX;
          if (selX1 < plotX2)
            selX2 = mouseX + 1;
          else
            selX2 = mouseX - 1;
          selMode = true;
        }
      }
      else if (mouseButton == RIGHT)
      {
        selMode = false;
      }
    }
  }
  
  void mDragged()
  {
    if(checkMouse())
    {
      if (selMode)
      {
        selX2 = mouseX;
        if (mouseX <= plotX1)
        {
          selX2 = plotX1;
        }
        else if (mouseX >= plotX2)
        {
          selX2 = plotX2;
        }       
      }
    }
  }
  
  void mReleased()
  {
    if (mouseButton == LEFT)
    {
      if(selMode)
      {
        float setX1;
        float setX2;
        if (selX1 < selX2)
        {
          setX1 = map(selX1, plotX1, plotX2, yearMin, yearMax);
          setX2 = map(selX2, plotX1, plotX2, yearMin, yearMax);
        }
        else
        {
          setX1 = map(selX2, plotX1, plotX2, yearMin, yearMax);
          setX2 = map(selX1, plotX1, plotX2, yearMin, yearMax);
        }
        selectMinRow = int(setX1) - years[0];
        selectMaxRow = int(setX2) - years[0];
        timeSelect.setRowRange(int(setX1) - years[0], int(setX2) - years[0]);
      }
    }
    else if (mouseButton == RIGHT)
    {
      selectMinRow = yearMin;
      selectMaxRow = yearMax;
      timeSelect.setRowRange(0, chartData.getRowCount() - 1);
    }
  }
  
  boolean checkMouse()
  {
    if((mouseX >= plotX1 && mouseX <= plotX2) && (mouseY > plotY1 && mouseY < plotY2))
    {
      return true;
    }
    return false;
  }
  
  color assignColour(int index)
  {
    color setColor = color(0);
    
    switch (index)
    {
      case 0:
        setColor = color(0);
        break;
      case 1:
        setColor = color(255, 0, 0);
        break;
      case 2:
        setColor = color(0, 255, 0);
        break;
      case 3:
        setColor = color(0, 0, 255);
        break;
      default:
        setColor = color(random(100, 225), random(100, 225), random(100, 225));
        break;
    }        
    return setColor;
  }
}