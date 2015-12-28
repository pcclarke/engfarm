class IndexChart
{
  boolean[] usage;
  boolean[] greyed;
  boolean showDetail, selMode;
  color[] plotColour;
  color background;
  float x1, y1, x2, y2; 
  float plotX1, plotY1, plotX2, plotY2;
  float selX1, selX2;
  float indexVal, indexMin, indexMax;
  int rowCount, mouseOver;
  int years[];
  float dataMin, dataMax; 
  float mouseTrackX, mouseTrackY;
  int yearInterval = 25;
  int tickInterval = 1;
  int selYear1, selYear2;
  
  FloatTable chartData;
  HoverBox detail;
  Selection indexSelect;
  
  IndexChart (float inputX1, float inputY1, float inputX2, float inputY2, FloatTable inputData, Selection inputSelect)
  {
    x1 = inputX1;
    y1 = inputY1;
    x2 = inputX2;
    y2 = inputY2;
    plotX1 = inputX1 + 75;
    plotY1 = inputY1 + 15;
    plotX2 = inputX2 - 25;
    plotY2 = inputY2 - 65;

    chartData = inputData;
    indexSelect = inputSelect;
    
    background = color(255);
    plotColour = new color[chartData.getColumnCount()];
    
    usage = new boolean[chartData.getColumnCount()];
    
    rowCount = chartData.getRowCount();
    years = chartData.getRowNames();
    dataMax = chartData.getTableMax();
    
    /*for (int i = 0; i < chartData.getColumnCount(); i++)
    {
      plotColour[i] = assignColour(i);
    }*/
  }
  
  void drawChart()
  {
    showDetail = false;

    drawBackground();
    
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
  
  void drawBackground()
  {
    fill(background);
    rectMode(CORNERS);
    noStroke();
    rect(x1 + 75, y1, x2 - 25, y2 - 50);
  }
  
  void drawSelection(boolean selectionMode)
  {
    if(selectionMode)
    {
      noStroke();
      fill(242, 255, 255);
      rect(selX1, plotY1, selX2, plotY2);
      
      stroke(150, 150, 255);
      strokeWeight(1);
      line(selX1, y1, selX1, y2 - 50);
      line(selX2, y1, selX2, y2 - 50);
    }
  }
  
  void drawDataCurve(int col) 
  {    
    noFill();
    stroke(greyed[col] ? color(180) : plotColour[col]);
    strokeWeight(1);
    beginShape();
    
    float indexVal = chartData.getNextValidFloat(indexSelect.getRowStart(), col);
    
    for (int row = indexSelect.getRowStart(); row <= indexSelect.getRowEnd(); row++) 
    {
      if (chartData.isValid(row, col)) 
      {
        
        float value = chartData.getFloat(row, col) / indexVal;        
        float x = map(years[row], indexSelect.getYearStart(), indexSelect.getYearEnd(), plotX1, plotX2);
        float y = map(value, indexMin, indexMax, plotY2, plotY1);     
        
        // Double the curve points for the end of a gap
        if (!chartData.isValid(row - 1, col) && (row != indexSelect.getRowStart()))
        {
          beginShape();
          
        }
        curveVertex(x, y);
        // Double the curve points for the start and stop of plot
        if ((row == indexSelect.getRowStart()) || (row == indexSelect.getRowEnd())) 
        {
          curveVertex(x, y);
        }
        // Double the curve points for start of a gap
        if (!chartData.isValid(row + 1, col) && (row != indexSelect.getRowEnd()))
        {
          curveVertex(x, y);
          endShape();
        }
        
        if (dist(mouseX, mouseY, x, y) < 5  && !showDetail) 
        { 
          showDetail = true;
          mouseTrackX = mouseX;
          mouseTrackY = mouseY;
          mouseOver = col;
          detail = new HoverBox(x, y, chartData.getColumnName(col) + ": " + chartData.getFloat(row, col));
        }
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
    
    for (float v = 1; v <= indexMax; v += tickInterval) 
    {
      float y = map(v, indexMin, indexMax, plotY2, plotY1);
      if (v % tickInterval == 0) 
      { // If a major tick mark
        if (v == indexMin) 
        {
          textAlign(RIGHT); // ALign by the bottom
        } 
        else if (v == indexMax) 
        {
          textAlign(RIGHT, TOP); // Align by the top
        } 
        else 
        {
          textAlign(RIGHT, CENTER); // Center vertically
        }
        text(nf((v - 1) * 100, 0, 0) + "%", plotX1 - 10, y);
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
    textAlign(CENTER, TOP);
    
    // Use thin, grey lines to draw the grid.
    stroke(224);
    strokeWeight(1);
    
    for (int row = indexSelect.getYearStart(); row <= indexSelect.getYearEnd(); row++) 
    {
      if ((row % yearInterval) == 0)
      {
        float x = map(row, indexSelect.getYearStart(), indexSelect.getYearEnd(), plotX1, plotX2);
        pushMatrix();
        translate(x - 20, y2 - 30);
        rotate(-PI/4);  
        text(row, 0, 0);
        popMatrix();
        line(x, y1, x, y2 - 50);
      }
    }
  }
  
  void setUsage(int index)
  {
    if(usage[index])
    {
      usage[index] = false;
    }
    else
    {
      usage[index] = true;
    }
    
    greyed = new boolean[usage.length];
    
    update();
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
  
  boolean checkMouse()
  {
    if((mouseX >= plotX1 && mouseX <= plotX2) && (mouseY > plotY1 && mouseY < plotY2))
    {
      return true;
    }
    return false;
  }

  void setColour(color[] inputColour) {
    plotColour = inputColour;
  }
  
  void update()
  { 
    int minRow;
    int maxRow;
    
    dataMin = Float.MAX_VALUE;
    dataMax = -Float.MAX_VALUE;
    indexMin = Float.MAX_VALUE;
    indexMax = -Float.MAX_VALUE;
    
    for (int i = 0; i < chartData.getColumnCount(); i++)
    {
      if(chartData.isValidRange(indexSelect.getRowStart(), indexSelect.getRowEnd(), i))
      {
        if(usage[i])
        {
          minRow = chartData.getColumnMinRange(i, indexSelect.getRowStart(), indexSelect.getRowEnd());
          maxRow = chartData.getColumnMaxRange(i, indexSelect.getRowStart(), indexSelect.getRowEnd());

          if (dataMin > chartData.getFloat(minRow, i))
          {
            dataMin = chartData.getFloat(minRow, i);
          }
          if (dataMax < chartData.getFloat(maxRow, i))
          {
            dataMax = chartData.getFloat(maxRow, i);
          }   
         
          
      
          if (indexMin > chartData.getNextValidFloat(minRow, i) / chartData.getNextValidFloat(indexSelect.getRowStart(), i))
          {
            indexMin = chartData.getNextValidFloat(minRow, i) / chartData.getNextValidFloat(indexSelect.getRowStart(), i);
          }
          if (indexMax < chartData.getNextValidFloat(maxRow, i) / chartData.getNextValidFloat(indexSelect.getRowStart(), i))
          {
            indexMax = chartData.getNextValidFloat(maxRow, i) / chartData.getNextValidFloat(indexSelect.getRowStart(), i);
          }
        }
      }
    }   
  }
}