int selectMinRow, selectMaxRow;
float bigFloat = 1000000; // poor substitute for not being able to use Float.MAX_VALUE

PFont smallFont, bodyFont, headerFont, displayFont;

DataPlot[] plots;
TimePlot main;
FloatTable data;
Selection mainSelection;
SparkLine[] sparks;
SparkManager overSparks;
IndexChart second;

void setup() {
  size(1024, 768);

  data = new FloatTable("farm2002.csv");
  
  smallFont = createFont("Encode Sans Condensed", 10);
  bodyFont = createFont("Encode Sans Condensed", 12);
  headerFont = createFont("Libre Caslon Text", 16);
  displayFont = createFont("Libre Caslon Text", 50);
//  smallFont = createFont("EncodeSansCondensed-Regular.ttf", 10);
//  bodyFont = createFont("EncodeSansCondensed-Regular.ttf", 12);
//  headerFont = createFont("LibreCaslonText-Bold.ttf", 16);
//  displayFont = createFont("LibreCaslonText-Bold.ttf", 50.5);

  mainSelection = new Selection(data);

  selectMinRow = 0;
  selectMaxRow = data.getRowCount() - 1;
  
  boolean[] mainUsage = new boolean[data.getColumnCount()];
  String[] grabNames = data.getColumnNames();
  
  plots = new DataPlot[data.getColumnCount()];
  sparks = new SparkLine[data.getColumnCount()];
  
  for(int i = 0; i < data.getColumnCount(); i++) {
    if(match(grabNames[i], "Index") != null) {
      mainUsage[i] = true;
    }
    plots[i] = new DataPlot(data, mainSelection, i);
    sparks[i] = new SparkLine(25, 250 + i * 20, 425, 265 + i * 20, data, mainSelection, plots[i], i);
    sparks[i].setFont(smallFont);
    sparks[i].setHoverFont(bodyFont);
  }

  overSparks = new SparkManager(25, 215, 425, 750, sparks);
  overSparks.setupOrder(data);
  
  main = new TimePlot(25, 95, width, 145, data, mainSelection);
  main.setFont(bodyFont);
  main.setUsage(mainUsage);
  
  second = new IndexChart(400, 215, 1024, 768, data, mainSelection);
  second.setFont(smallFont);
  
  assignColour();

  smooth();
}

void draw() {
  background(252, 249, 240);
  
  textAlign(LEFT, BOTTOM);
  textFont(displayFont);
  //fill(119, 118, 112);
  fill(100);
  textSize(50);
  text("English Agricultural Prices 1500\u20131914", 25, 60);

  fill(50);
  textFont(bodyFont);
  textSize(10);
  text("low", 267, 205);
  text("high", 307, 205);

  textFont(headerFont);
  fill(100);
  textSize(16);
  text("Price Indices", 25, 90);
  text("All Goods", 25, 205);
  text("Indexed Prices", 473, 205);

  main.drawChart();

  overSparks.drawSparks();
  
  second.drawChart();
}

void mousePressed() {
  main.mPressed();
  
  if (overSparks.checkMouse()) {
    for(int i = 0; i < data.getColumnCount(); i++) {
      if(sparks[i].checkToIndex()) {
        second.setUsage(i);
      } else if (sparks[i].checkTitle()) {
        sparks[i].drag();
      } else if (sparks[i].checkLock()) {
        overSparks.lock();
      } else if (mouseButton == RIGHT) {
        overSparks.setupOrder(data);
      }
    }
  }
}

void mouseMoved() {
  overSparks.mMoved();
}

void mouseDragged() {
  main.mDragged();
  if(overSparks.checkMouse()) {
    for(int i = 0; i < data.getColumnCount(); i++) {
      sparks[i].dragging(true);
    }
  } 
}

void mouseReleased() {
  if (main.checkMouse()) {
    main.mReleased();

    if(abs(selectMaxRow - selectMinRow) >= 1) {
      for(int i = 0; i < data.getColumnCount(); i++) {
        plots[i].update();
        sparks[i].update();
      }
      second.update();
      overSparks.update();
    }
  }
  
  if (overSparks.checkMouse()) {
    int swap1 = -1;
    int swap2 = -1;
    for(int i = 0; i < data.getColumnCount(); i++) {
      if (sparks[i].dragEnd()) {
        swap1 = i;
      }
      if (sparks[i].checkMouse()) {
        swap2 = i;
      }
      sparks[i].dragging(false);
    }
    if ((swap1 != -1) && (swap2 != -1) && (swap1 != swap2)) {
      overSparks.swap(swap1, swap2);
    }
  }
}

void assignColour() {
  color[] setColor = new color[data.getColumnCount()];

  for (int i = 0; i < data.getColumnCount(); i++) {
    if (i < 4) {
      switch (i) 
      {
        case 0:
          setColor[i] = color(0);
          break;
        case 1:
          setColor[i] = color(255, 0, 0);
          break;
        case 2:
          setColor[i] = color(0, 255, 0);
          break;
        case 3:
          setColor[i] = color(0, 0, 255);
          break;
        default:
          setColor[i] = color(random(100, 225), random(100, 225), random(100, 225));
          break;
      }        
    } else {
      if(data.getIndex(i).equals("arable")) {
        setColor[i] = color(random(150, 255), random(50, 150), random(50, 150));
      }
      if(data.getIndex(i).equals("pasture")) {
        setColor[i] = color(random(50, 150), random(150, 255), random(50, 150));
      }
      if(data.getIndex(i).equals("wood")) {
        setColor[i] = color(random(50, 150), random(50, 150), random(150, 255));
      }
    }
    sparks[i].setColour(setColor[i]);      
  }
  second.setColour(setColor);
}

//**********************************
// Button Class
// Draws a square button
//**********************************

class Button {
  float x1, y1, x2, y2;
  String name, sub;
  int category;
  char align;
  color fillOnColour, fillOffColour;
  color textColour;
  color borderColour;
  boolean selected;
  boolean showBorder, hasSub;
  
  PFont font;

  Button (float inputX1, float inputY1, float inputX2, float inputY2, String inputName, int inputCategory) {
    x1 = min(inputX1, inputX2);
    y1 = min(inputY1, inputY2);
    x2 = max(inputX1, inputX2);
    y2 = max(inputY1, inputY2);
    name = inputName;
    category = inputCategory;
    
    this.font = createFont("Arial", 10);

    fillOffColour = color(252, 249, 240);
    fillOnColour = color(240);
    textColour = color(0);
    borderColour = color(220);

    selected = false;
    showBorder = false;
    hasSub = false;

    align = 'c';
  }
  
  // Set the position of the button's 4 corners
  void setPos(float inputx1, float inputy1, float inputx2, float inputy2) {
    x1 = min(inputx1, inputx2);
    y1 = min(inputy1, inputy2);
    x2 = max(inputx1, inputx2);
    y2 = max(inputy1, inputy2);
  }
  
  void setFont(PFont font) {
    this.font = font;
  }

  // Set the alignment of text to the left 'l', center 'c', or right 'r'
  void setAlign(char ali) {
    align = ali;
  }
  
  // Set whether the button displays as selected or not
  void setState (boolean inputSelected) {
    selected = inputSelected;
  }
  
  // Set the deselected fill colour of the button
  void setFillOffColour(color inputColour) {
    fillOffColour = inputColour;
  }

  // Check whether the mouse cursor is in the area of the button
  boolean checkMouse() {
    if ((mouseX < x2) && (mouseX > x1) && (mouseY < y2) && (mouseY > y1)) {
      showBorder = true;
      return true;     
    } else {
      showBorder = false;
      return false;
    }
  }
  
  
  boolean getState() {
    return selected;
  }

  String getName() {
    return name;
  }

  void setSub(String inputText) {
    sub = inputText;
    hasSub = true;
  }

  int getCategory() {
    return category;
  }
  
  void setBorder(boolean inputBorder) {
      showBorder = inputBorder;
  }

  void draw() {
    noStroke();
    
    if (selected) {
      fill(fillOnColour);
    } else {
      fill(fillOffColour);
    }
    
    if (showBorder) {
      strokeWeight(1);
      stroke(borderColour);
    } else {
      noStroke();
    } 
      
    rectMode(CORNERS);
    rect(x1, y1, x2, y2);

    fill(textColour);
    textSize(10);

    if (y2 - y1 < 25) {
      switch(align)
      {
        case 'l':
          textAlign(LEFT);
          text(name, x1 + 5, y1 + 4 + (0.5 * (y2 - y1)));
          break;
        case 'c':
          textAlign(CENTER);
          text(name, x1 + (0.5 * (x2 - x1)), y1 + 4 + (0.5 * (y2 - y1)));
          break;
        case 'r':
          textAlign(RIGHT);
          text(name, x2 - 5, y1 + 4 + (0.5 * (y2 - y1)));
          break;
      }
    } else {
      textSize(12);
      switch(align)
      {
        case 'l':
          textAlign(LEFT);
          text(name, x1 + 5, y1 + 4 + (0.35 * (y2 - y1)));
          if (hasSub) {
            fill(128);
            text(sub, x1 + 5, y1 + 4 + (0.65 * (y2 - y1)));  
          }
          break;
        case 'c':
          textAlign(CENTER);
          text(name, x1 + (0.5 * (x2 - x1)), y1 + 4 + (0.35 * (y2 - y1)));
          if (hasSub) {
            fill(128);
            text(sub, x1 + (0.5 * (x2 - x1)), y1 + 4 + (0.65 * (y2 - y1)));
          }
          break;
        case 'r':
          textAlign(RIGHT);
          text(name, x2 - 5, y1 + 4 + (0.35 * (y2 - y1)));
          if (hasSub) {
            fill(128);
            text(sub, x2 - 5, y1 + 4 + (0.65 * (y2 - y1)));
          }
          break;
      }
    }
    
  }
}
//********************************************
// DataPlot
// Calculates information used for bandlines
//********************************************

class DataPlot {
  boolean isValid;
  int column;
  int plotMinYear, plotMaxYear;
  float mean, stdDev;
  float normal1, normal2;
  float plotMin, plotMax;
  float validRowStart;

  FloatTable plotData;
  Selection plotSelect;

  DataPlot (FloatTable inputData, Selection inputSelect, int inputColumn) {
    plotData = inputData;
    plotSelect = inputSelect;
    column = inputColumn;

    float sum = 0;
    int counter = 0;
    for (int i = 0; i < plotData.getRowCount(); i++) {
      if (plotData.isValid(i, column)) {
        sum += plotData.getFloat(i, column);
	counter++;
      }
    }
    mean = sum / counter;

    sum = 0;
    for (int i = 0; i < plotData.getRowCount(); i++) {
      if (plotData.isValid(i, column)) {
        sum += sq(plotData.getFloat(i, column) - mean);
      }
    }
    stdDev = sqrt(sum / counter);

    update();
  }

  void update() {
    isValid = plotData.isValidRange(plotSelect.getRowStart(), plotSelect.getRowEnd(), column);

    if (isValid) {
      validRowStart = plotData.getNextValidFloat(plotSelect.getRowStart(), column);

      int minRow;
      int maxRow;

      minRow = plotData.getColumnMinRange(column, plotSelect.getRowStart(), plotSelect.getRowEnd());
      maxRow = plotData.getColumnMaxRange(column, plotSelect.getRowStart(), plotSelect.getRowEnd());

      plotMin = plotData.getFloat(minRow, column);
      plotMax = plotData.getFloat(maxRow, column);

      plotMinYear = plotData.getRowName(minRow);
      plotMaxYear = plotData.getRowName(maxRow);

      if ((mean - stdDev * 2) < plotMin) {
	normal1 = plotMin;
      } else if ((mean - stdDev * 2) > plotMax) {
	normal1 = plotMax;
      } else {
        normal1 = mean - stdDev * 2;
      }

      if ((mean + stdDev) < plotMin) {
	normal2 = plotMin;
      } else if ((mean + stdDev * 2) > plotMax) {
	normal2 = plotMax;
      } else {
	normal2 = mean + stdDev * 2;
      }
    }
  }

  boolean getValid() {
    return isValid;
  }

  float getDataMin() {
    return plotMin;
  }

  float getDataMax() {
    return plotMax;
  }

  int getDataMinYear() {
    return plotMinYear;
  }

  int getDataMaxYear() {
    return plotMaxYear;
  }

  float getLowNormal() {
    return normal1;
  }

  float getUpperNormal() {
    return normal2;
  }
}

//****************************************************************
// FloatTable
// Lifted from "Visualizing Data" by Ben Fry
// Because there's no Table class in Processing.js, sigh...
//****************************************************************

class FloatTable {
  int rowCount;
  int columnCount;
  float[][] data;
  int[] rowNames;
  String[] columnNames;
  String[] columnUnits;
  String[] columnIndices;
  
  FloatTable(String filename) {
    String[] rows = loadStrings(filename);
    
    String[] columns = split(rows[0], ',');
    columnNames = subset(columns, 1); // upper-left corner ignored
    scrubQuotes(columnNames);
    columnCount = columnNames.length;
    
    String[] units = split(rows[1], ',');
    columnUnits = subset(units, 1); // upper-left corner ignored
    
    String[] indices = split(rows[2], ',');
    columnIndices = subset(indices, 1); // upper-left corner ignored

    rowNames = new int[rows.length-3];
    data = new float[rows.length-3][];

    // start reading at row 1, because the first row was only the column headers
    for (int i = 3; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }

      // split the row on the commas
      String[] pieces = split(rows[i], ',');
      scrubQuotes(pieces);
      
      // copy row title
      rowNames[rowCount] = int(pieces[0]);
      // copy data into the table starting at pieces[1]
      data[rowCount] = parseFloat(subset(pieces, 1));

      // increment the number of valid rows found so far
      rowCount++;      
    }
    // resize the 'data' array as necessary
    data = (float[][]) subset(data, 0, rowCount);
  }
  
  
  void scrubQuotes(String[] array) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].length() > 2) {
        // remove quotes at start and end, if present
        if (array[i].startsWith("\"") && array[i].endsWith("\"")) {
          array[i] = array[i].substring(1, array[i].length() - 1);
        }
      }
      // make double quotes into single quotes
      array[i] = array[i].replaceAll("\"\"", "\"");
    }
  }
  
  int getRowCount() {
    return rowCount;
  }
  
  int getRowName(int rowIndex) {
    return rowNames[rowIndex];
  }
  
  int[] getRowNames() {
    return rowNames;
  }
  
  // Find a row by its name, returns -1 if no row found. 
  // This will return the index of the first row with this name.
  // A more efficient version of this function would put row names
  // into a Hashtable (or HashMap) that would map to an integer for the row.
  int getRowIndex(int year) {
    for (int i = 0; i < rowCount; i++) {
      if (rowNames[i] == year) {
        return i;
      }
    }
    //println("No row named '" + name + "' was found");
    return -1;
  }
  
  
  // technically, this only returns the number of columns 
  // in the very first row (which will be most accurate)
  int getColumnCount() {
    return columnCount;
  }
  
  
  String getColumnName(int colIndex) {
    return columnNames[colIndex];
  }
  
  
  String[] getColumnNames() {
    return columnNames;
  }
  
  String getUnit(int colIndex) 
  {
    return columnUnits[colIndex];
  }
  
  String getIndex (int colIndex)
  {
    return columnIndices[colIndex];
  }


  float getFloat(int rowIndex, int col) {
    // Remove the 'training wheels' section for greater efficiency
    // It's included here to provide more useful error messages
    
    // begin training wheels
    if ((rowIndex < 0) || (rowIndex >= data.length)) {
      throw new RuntimeException("There is no row " + rowIndex);
    }
    if ((col < 0) || (col >= data[rowIndex].length)) {
      throw new RuntimeException("Row " + rowIndex + " does not have a column " + col);
    }
    // end training wheels
    
    return data[rowIndex][col];
  }
  
  float getNextValidFloat(int rowIndex, int col)
  {
    for (int i = rowIndex; i < rowCount; i++)
    {
      if (isValid(i, col))
      {
        return data[i][col];
      }
    }
    return 0;
  }
  
  
  boolean isValid(int row, int col) 
  {
    if (row < 0) return false;
    if (row >= rowCount) return false;
    //if (col >= columnCount) return false;
    if (col >= data[row].length) return false;
    if (col < 0) return false;
    return !(data[row][col] < 0);
  }

  boolean isValidRange(int rowMin, int rowMax, int col)
  {
    if (rowMin < 0)
      return false;
    if (rowMin > rowMax)
      return false;
    if (rowMin >= rowCount)
      return false;
    if (rowMax < 0)
      return false;
    if (rowMax < rowMin)
      return false;
    if (rowMax >= rowCount)
      return false;

    for (int i = rowMin; i < rowMax; i++)
    {
      if (col < data[i].length)
      //if (!Float.isNaN(data[i][col]))
        return true;
    }
    return false;
  }

  float getQ1(int col)
  {
    float[] fullCol = new float[rowCount];
    float med = 0;
    int goodCount = 0;
    for (int i = 0; i < rowCount; i++) {
      if (isValid(i, col)) {
        if (data[i][col] > 0) {
          fullCol[goodCount] = data[i][col];
          goodCount++;
        }
      }
    }

    fullCol = subset(fullCol, 0, goodCount);

    Quicksort findMed = new Quicksort();
    findMed.sort(fullCol);
    med = findMed.getQ1();
    return med;
  }

  float getMedian(int col)
  {
    float[] fullCol = new float[rowCount];
    float med = 0;
    int goodCount = 0;
    for (int i = 0; i < rowCount; i++) {
      if (isValid(i, col)) {
        if (data[i][col] > 0) {
          fullCol[goodCount] = data[i][col];
          goodCount++;
        }
      }
    }

    fullCol = subset(fullCol, 0, goodCount);

    Quicksort findMed = new Quicksort();
    findMed.sort(fullCol);
    med = findMed.getPivot();
    return med;
  }

  float getQ3(int col) {
    float[] fullCol = new float[rowCount];
    float med = 0;
    int goodCount = 0;
    for (int i = 0; i < rowCount; i++) {
      if (isValid(i, col)) {
        fullCol[goodCount] = data[i][col];
        goodCount++;
      }
    }

    fullCol = subset(fullCol, 0, goodCount);
   
    Quicksort findMed = new Quicksort();
    findMed.sort(fullCol);
    med = findMed.getQ3();
    return med;
  }
  
  float getColumnMin(int col) {
    float m = bigFloat;
    for (int i = 0; i < rowCount; i++) {
      if (isValid(i, col)) {
        if (data[i][col] < m) {
          m = data[i][col];
        }
      }
    }
    return m;
  }
  
  float getColumnMax(int col) {
    float m = -bigFloat;
    for (int i = 0; i < rowCount; i++) {
      if (isValid(i, col)) {
        if (data[i][col] > m) {
          m = data[i][col];
        }
      }
    }
    return m;
  }
  
  int getColumnMinRange(int col, int min, int max) {
    float m = bigFloat;
    int minRow = 0;
    for (int i = min; i <= max; i++) {
      if (isValid(i, col)) {
        if (data[i][col] < m) {
          m = data[i][col];
          minRow = i;
        }
      }
    }
    return minRow;
  }
  
  int getColumnMaxRange(int col, int min, int max) {
    float m = -bigFloat;
    int maxRow = 1;
    for (int i = min; i <= max; i++) 
    {
      if (isValid(i, col)) {
        if (data[i][col] > m) {
          m = data[i][col];
          maxRow = i;
        }
      }
    }
    return maxRow;
  }

  
  float getRowMin(int row) {
    float m = bigFloat;
    for (int i = 0; i < columnCount; i++) {
      if (isValid(row, i)) {
        if (data[row][i] < m) {
          m = data[row][i];
        }
      }
    }
    return m;
  } 

  
  float getRowMax(int row) {
    float m = -bigFloat;
    for (int i = 1; i < columnCount; i++) {
      //if (!Float.isNaN(data[row][i])) {
        if (data[row][i] > m) {
          m = data[row][i];
        }
      //}
    }
    return m;
  }
  
  
  float getTableMin() {
    float m = bigFloat;
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < columnCount; j++) {
        if (isValid(i, j)) {
          if (data[i][j] < m) {
            m = data[i][j];
          }
        }
      }
    }
    return m;
  }
  
  float getTableMinRange(int min, int max) {
    float m = bigFloat;
    for (int i = min; i < max; i++) {
      for (int j = 0; j < columnCount; j++) {
        if (isValid(i, j)) {
          if (data[i][j] < m) {
            m = data[i][j];
          }
        }
      }
    }
    return m;
  }

  
  float getTableMax() {
    float m = -bigFloat;
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < columnCount; j++) {
        if (isValid(i, j)) {
          if (data[i][j] > m) {
            m = data[i][j];
          }
        }
      }
    }
    return m;
  }
  
  float getTableMaxRange(int min, int max) {
    float m = -bigFloat;
    for (int i = min; i < max; i++) {
      for (int j = 0; j < columnCount; j++) {
        if (isValid(i, j)) {
          if (data[i][j] > m) {
            m = data[i][j];
          }
        }
      }
    }
    return m;
  }
}
//********************************************************************
// HoverBox
// Draws a pop-up box at a given position
//********************************************************************

class HoverBox {
  float x, y, w, h;
  String hoverText;
  
  PFont font;
  
  HoverBox (float inputX, float inputY, String inputText) {
    x = inputX;
    y = inputY;
    hoverText = inputText;
    this.font = createFont("Arial", 12);
    
    w = 6 * hoverText.length();
    h = 15;
  }
  
  void drawHover() {
    if (x + w * .5 > width) {
      drawHoverBox(x - 0.5 * w, y - 12);
      drawHoverText(x - 0.5 * w, y - 8);
    } else if (x - w * .5 < 0) {
      drawHoverBox(x + 0.5 * 5, y - 12);
      drawHoverText(x + 0.5 * w, y - 8);
    } else {
      drawHoverBox(x, y - 12);
      drawHoverText(x, y - 8);
    }
    
    stroke(0);
    strokeWeight(10);
    point(x, y);
  }
  
  void drawHoverBox(float xPos, float yPos) {
    fill(255, 255, 255, 200);
    stroke(128);
    strokeWeight(1);
    rectMode(CENTER);
    rect(xPos, yPos, w, h);
  }
  
  void drawHoverText(float xPos, float yPos) {
    fill(0);
    textFont(font);
    textSize(12);
    textAlign(CENTER);
    text(hoverText, xPos, yPos);
  }
  
  void setFont(PFont font) {
    this.font = font;
  }
}
//********************************************************************
// IndexChart
// Draws a line chart that can be updated with different selections
//********************************************************************

class IndexChart {
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
  
  PFont font;
  
  FloatTable chartData;
  HoverBox detail;
  Selection indexSelect;
  
  IndexChart (float inputX1, float inputY1, float inputX2, float inputY2, FloatTable inputData, Selection inputSelect) {
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
    this.font = createFont("Arial", 20);
    
    usage = new boolean[chartData.getColumnCount()];
    
    rowCount = chartData.getRowCount();
    years = chartData.getRowNames();
    dataMax = chartData.getTableMax();
    
    /*for (int i = 0; i < chartData.getColumnCount(); i++)
    {
      plotColour[i] = assignColour(i);
    }*/
  }
  
  void drawChart() {
    showDetail = false;

    drawBackground();
    
    // Draw selection area
    drawSelection(selMode);
       
    drawYearLabels();
    
    for(int i = 0; i < chartData.getColumnCount(); i++) {
      if(usage[i]) {
        drawDataCurve(i);
      }
    }
    
    drawTicks(); 
    
    if(showDetail) {
      detail.drawHover();
    }
  }
  
  void drawBackground() {
    fill(background);
    rectMode(CORNERS);
    noStroke();
    rect(x1 + 75, y1, x2 - 25, y2 - 50);
  }
  
  void drawSelection(boolean selectionMode) {
    if(selectionMode) {
      noStroke();
      fill(242, 255, 255);
      rect(selX1, plotY1, selX2, plotY2);
      
      stroke(150, 150, 255);
      strokeWeight(1);
      line(selX1, y1, selX1, y2 - 50);
      line(selX2, y1, selX2, y2 - 50);
    }
  }
  
  void drawDataCurve(int col) {    
    noFill();
    stroke(greyed[col] ? color(180) : plotColour[col]);
    strokeWeight(1);
    beginShape();
    
    float indexVal = chartData.getNextValidFloat(indexSelect.getRowStart(), col);
    
    for (int row = indexSelect.getRowStart(); row <= indexSelect.getRowEnd(); row++) {
      if (chartData.isValid(row, col)) {
        float value = chartData.getFloat(row, col) / indexVal;        
        float x = map(years[row], indexSelect.getYearStart(), indexSelect.getYearEnd(), plotX1, plotX2);
        float y = map(value, indexMin, indexMax, plotY2, plotY1);     
        
        // Double the curve points for the end of a gap
        if (!chartData.isValid(row - 1, col) && (row != indexSelect.getRowStart())) {
          beginShape();
        }
        curveVertex(x, y);
        
        // Double the curve points for the start and stop of plot
        if ((row == indexSelect.getRowStart()) || (row == indexSelect.getRowEnd())) {
          curveVertex(x, y);
        }
        
        // Double the curve points for start of a gap
        if (!chartData.isValid(row + 1, col) && (row != indexSelect.getRowEnd())) {
          curveVertex(x, y);
          endShape();
        }
        
        if (dist(mouseX, mouseY, x, y) < 5  && !showDetail) {
          showDetail = true;
          mouseTrackX = mouseX;
          mouseTrackY = mouseY;
          mouseOver = col;
          detail = new HoverBox(x, y, chartData.getColumnName(col) + ": " + chartData.getFloat(row, col));
          detail.setFont(font);
        }
      }
    }
    endShape();
  }
 
  void drawTicks() {
    fill(0);
    textFont(font);
    textSize(10);
    textAlign(RIGHT, CENTER);
    
    // Varying alignments
    stroke(128);
    strokeWeight(1);  
    
    for (float v = 1; v <= indexMax; v += tickInterval) {
      float y = map(v, indexMin, indexMax, plotY2, plotY1);
      if (v % tickInterval == 0) { // If a major tick mark
        if (v == indexMin) {
          textAlign(RIGHT); // Align by the bottom
        } else if (v == indexMax) {
          textAlign(RIGHT, TOP); // Align by the top
        } else {
          textAlign(RIGHT, CENTER); // Center vertically
        }
        text(nf((v - 1) * 100, 0, 0) + "%", plotX1 - 10, y);
        line(plotX1 - 4, y, plotX1, y); // Draw major tick
      } else {
        line(plotX1 - 2, y, plotX1, y); // Draw minor tick
      }
    }
  }
  
  void drawYearLabels() {
    fill(0);
    textFont(font);
    textSize(10);
    textAlign(CENTER, TOP);
    
    // Use thin, grey lines to draw the grid.
    stroke(224);
    strokeWeight(1);
    
    for (int row = indexSelect.getYearStart(); row <= indexSelect.getYearEnd(); row++) {
      if ((row % yearInterval) == 0) {
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
  
  void setFont(PFont font) {
    this.font = font;
  }
  
  void setUsage(int index) {
    if(usage[index]) {
      usage[index] = false;
    } else {
      usage[index] = true;
    }
    
    greyed = new boolean[usage.length];
    
    update();
  }
  
  boolean checkMouse() {
    if((mouseX >= plotX1 && mouseX <= plotX2) && (mouseY > plotY1 && mouseY < plotY2)) {
      return true;
    }
    return false;
  }

  void setColour(color[] inputColour) {
    plotColour = inputColour;
  }
  
  void update() { 
    int minRow;
    int maxRow;
    
    /*dataMin = Float.MAX_VALUE;
    dataMax = -Float.MAX_VALUE;
    indexMin = Float.MAX_VALUE;
    indexMax = -Float.MAX_VALUE;*/
    dataMin = 200;
    dataMax = -200;
    indexMin = 200;
    indexMax = -200;
    
    for (int i = 0; i < chartData.getColumnCount(); i++) {
      if(chartData.isValidRange(indexSelect.getRowStart(), indexSelect.getRowEnd(), i)) {
        if(usage[i]) {
          minRow = chartData.getColumnMinRange(i, indexSelect.getRowStart(), indexSelect.getRowEnd());
          maxRow = chartData.getColumnMaxRange(i, indexSelect.getRowStart(), indexSelect.getRowEnd());

          if (dataMin > chartData.getFloat(minRow, i)) {
            dataMin = chartData.getFloat(minRow, i);
          }
          if (dataMax < chartData.getFloat(maxRow, i)) {
            dataMax = chartData.getFloat(maxRow, i);
          }
      
          if (indexMin > chartData.getNextValidFloat(minRow, i) / chartData.getNextValidFloat(indexSelect.getRowStart(), i)) {
            indexMin = chartData.getNextValidFloat(minRow, i) / chartData.getNextValidFloat(indexSelect.getRowStart(), i);
          }
          if (indexMax < chartData.getNextValidFloat(maxRow, i) / chartData.getNextValidFloat(indexSelect.getRowStart(), i)) {
            indexMax = chartData.getNextValidFloat(maxRow, i) / chartData.getNextValidFloat(indexSelect.getRowStart(), i);
          }
        }
      }
    }   
  }
}
//****************************************************************************************************************************************
// Quicksort
// Lifted from here: http://www.vogella.com/tutorials/JavaAlgorithmsQuicksort/article.html
// Because if I wasn't writing for Processing.js I'd just use Arrays.sort()
//****************************************************************************************************************************************

public class Quicksort  {
  private float[] numbers;
  private int number;
  private float pivot;

  Quicksort() { }
  
  public void sort(float[] values) {
    // Check for empty or null array
    if (values == null || values.length==0){
      return;
    }
    numbers = values;
    number = values.length;
    quicksort(0, number - 1);
  }

  private void quicksort(int low, int high) {
    int i = low, j = high;
    // Get the pivot element from the middle of the list
    pivot = numbers[low + (high-low)/2];

    // Divide into two lists
    while (i <= j) {
      // If the current value from the left list is smaller then the pivot
      // element then get the next element from the left list
      while (numbers[i] < pivot) {
        i++;
      }
      // If the current value from the right list is larger then the pivot
      // element then get the next element from the right list
      while (numbers[j] > pivot) {
        j--;
      }

      // If we have found a values in the left list which is larger then
      // the pivot element and if we have found a value in the right list
      // which is smaller then the pivot element then we exchange the
      // values.
      // As we are done we can increase i and j
      if (i <= j) {
        exchange(i, j);
        i++;
        j--;
      }
    }
    // Recursion
    if (low < j)
      quicksort(low, j);
    if (i < high)
      quicksort(i, high);
  }

  private void exchange(int i, int j) {
    float temp = numbers[i];
    numbers[i] = numbers[j];
    numbers[j] = temp;
  }

  float getPivot() {
    float median = numbers[floor((numbers.length) / 2)];
    return median;
  }

  float getQ1() {
    float q1 = numbers[floor((numbers.length) / 4)];
    return q1;
  }

  float getQ3() {
    float median = numbers[floor(3 * (numbers.length) / 4)];
    return median;
  }
} 
//*********************************************
// RoundButton
// Draws a round button that can be toggled
//*********************************************

class RoundButton {
  boolean selected;
  char shape;
  color fillOnColour, fillOffColour;
  float x, y, radius;
  int type;
  String name;

  RoundButton (float inputX, float inputY, float inputRadius) {
    x = inputX;
    y = inputY;
    radius = inputRadius;
    fillOnColour = color(150, 150, 255);
    fillOffColour = color(0);
    shape = 'a';
    selected = false;
  }
  
  void draw() {
    // Draw circle
    noStroke();
    if (selected) {
      fill(fillOnColour);
    } else {
      fill(fillOffColour);
    }
    ellipseMode(CENTER);
    ellipse(x, y, radius, radius);

    if (shape == 'a') {
      drawArrow();  
    }
    else if (shape == 'l') {
      drawLock();
    }
  }

  void drawArrow() {
    stroke(255);
    strokeWeight(2);  
    if (selected) {
      line(x + .25 * radius, y - .25 * radius, x - .25 * radius, y);
      line(x - .25 * radius, y, x + .25 * radius, y + .25 * radius);
    } else {
      line(x - .25 * radius, y - .25 * radius, x + .25 * radius, y);
      line(x + .25 * radius, y, x - .25 * radius, y + .25 * radius);
    }
  }

  void drawLock() {
    stroke(255);
    strokeWeight(1);  
    arc(x, y - .15 * radius, .25 * radius, .4 * radius, PI, 2 * PI);
    noStroke();
    fill(255);
    rectMode(CORNER);
    rect(x - .25 * radius, y - .15 * radius, .5 * radius, .5 * radius);
  }

  
  void setPos(float inputXPos, float inputYPos) {
    x = inputXPos;
    y = inputYPos;
  }
  
  void setState (boolean inputSelected) {
    selected = inputSelected;
  }
  
  void flipState() {
    selected = selected ? false : true;
  }

  void setShape(char inputShape) {
    shape = inputShape;
  }
  
  void setFillOffColour(color inputColour)
  {
    fillOffColour = inputColour;
  }

  boolean checkMouse()
  {
    if (sqrt((sq(mouseX - x) + sq(mouseY - y))) < radius)
    {
      flipState();
      return true;
    }
    else
    {
      return false;
    }
  }
  
  boolean getState()
  {
    return selected;
  }

  String getName()
  {
    return name;
  }

  int getType()
  {
    return type;
  }
}
//********************************************************
// Selection
// Contains information about a selected set of data
//********************************************************

class Selection {
  int rowStart, rowEnd;
  int yearStart, yearEnd;
  float dataMin, dataMax;

  FloatTable selData;

  Selection(FloatTable inputData) {
    selData = inputData;

    rowStart = 0;
    rowEnd = selData.getRowCount() - 1;

    yearStart = selData.getRowName(rowStart);
    yearEnd = selData.getRowName(rowEnd);

    dataMin = selData.getTableMin();
    dataMax = selData.getTableMax();
  }

  int getRowStart() {
    return rowStart;
  }

  int getRowEnd() {
    return rowEnd;
  }

  void setRowRange(int start, int end) {
    rowStart = start;
    rowEnd = end;

    yearStart = selData.getRowName(rowStart);
    yearEnd = selData.getRowName(rowEnd);

    dataMin = selData.getTableMinRange(rowStart, rowEnd);
    dataMax = selData.getTableMaxRange(rowStart, rowEnd);
  }

  int getYearStart() {
    return yearStart;
  }

  int getYearEnd() {
    return yearEnd;
  }
}	
//************************************************
// SparkLine
// Draws the individual sparklines along the left
//************************************************

class SparkLine {
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
  
  PFont font, hoverFont;
  
  Button title;
  DataPlot sparkPlot;
  FloatTable sparkData;
  HoverBox detail;
  RoundButton toIndexChart, lock;
  Selection sparkSelect;
  
  SparkLine (float x1, float y1, float x2, float y2, FloatTable inputData, Selection inputSelect, DataPlot inputPlot, int column) {
    this.x1 = min(x1, x2);
    this.y1 = min(y1, y2);
    this.x2 = max(x1, x2);
    this.y2 = max(y1, y2);
    plotX1 = this.x1 + 90;
    plotY1 = this.y1;
    plotX2 = this.x1 + (.57 * (this.x2 - this.x1));
    plotY2 = this.y2;

    sparkData = inputData;
    sparkPlot = inputPlot;
    sparkSelect = inputSelect;
    this.column = column;
    
    this.font = createFont("Arial", 10);
    this.hoverFont = createFont("Arial", 12);
    
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
  
  void drawSparkLine() {
    showDetail = false;
    
    textFont(font);
    textSize(10);

    if(mDragging && checkMouse()) {
      noStroke();
      fill(bg);
      rect(x1, y1, x2, y2);
    }
    
    textAlign(LEFT);
    fill(0);
    text(sparkData.getUnit(column), x1 + (.8 * (x2 - x1)), (.55 * (plotY2 - plotY1)) + plotY1);
    
    if (sparkPlot.getValid()) {
      textAlign(RIGHT);
      fill(0, 153, 255);
      if (!(dataMin < 0)) {
        text(nf(dataMin, 0, 2), x1 + (.65 * (x2 - x1)), (.55 * (plotY2 - plotY1)) + plotY1);
      }
      fill(255, 0, 0);
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
      // Q1 - bottom
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
      
      // Q4 - top
      float q3Plot = map(q3, dataMin, dataMax, plotY2, plotY1);
      //println("name: " + sparkData.getColumnName(column) + " q3: " + q3 + " dataMin: " + dataMin + " dataMax: " + dataMax);
      //println("name: " + sparkData.getColumnName(column) + " q3Plot: " + q3Plot + " plotY1: " + plotY1 + " plotY2: " + plotY2);
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
      if ((q1Plot < plotY2) && (q1Plot > plotY1) && (q3Plot > plotY1) && (q3Plot < plotY2)) {
        fill(225);
        rect(plotX1, q1Plot, plotX2, q3Plot);
      } else if ((q1Plot < plotY2) && (q1Plot > plotY1) && !((q3Plot > plotY1) && (q3Plot < plotY2))) {
        fill(225);
        rect(plotX1, q1Plot, plotX2, plotY1);        
      } else if (!((q1Plot < plotY2) && (q1Plot > plotY1)) && (q3Plot > plotY1) && (q3Plot < plotY2)) {
        fill(225);
        rect(plotX1, plotY2, plotX2, q3Plot);             
      } else if ((q1Plot >= plotY2) && (q3Plot <= plotY1)) {
        fill(225);
        rect(plotX1, plotY2, plotX2, plotY1);     
      }

      float medLine = map(median, dataMin, dataMax, plotY2, plotY1);
      // println("name: " + sparkData.getColumnName(column) + " medLine: " + medLine + " q1Plot: " + q1Plot + " q3Plot: " + q3Plot);
      if (medLine > plotY1 && medLine < plotY2) {
        stroke(255);
        strokeWeight(1);
        line(plotX1, medLine, plotX2, medLine);
      }

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
    } else {
      title.setPos(x1, y1, x1 + 90, y2);  
    }

    if(showDetail) {
      detail.drawHover();
    }
  }
  
  void drawDataLine(int col) {    
    noFill();
    stroke(0);
    strokeWeight(.5);
    beginShape();
    for (int row = sparkSelect.getRowStart(); row <= sparkSelect.getRowEnd(); row++) {
      if (sparkData.isValid(row, col)) {
        float value = sparkData.getFloat(row, col);
        float x = map(years[row], sparkSelect.getYearStart(), sparkSelect.getYearEnd(), plotX1, plotX2);
        float y = map(value, dataMin, dataMax, plotY2, plotY1);       
        if (!sparkData.isValid(row - 1, col)) {
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
        if ((row == sparkSelect.getRowStart()) || (row == sparkSelect.getRowEnd())) {
          vertex(x, y);
        }
        //
        if (dist(mouseX, mouseY, x, y) < 5  && !showDetail) { 
          showDetail = true;
          mouseTrackX = mouseX;
          mouseTrackY = mouseY;
          mouseOver = col;
          detail = new HoverBox(x, y, sparkData.getColumnName(col) + " " + years[row] + ": " + value);
          detail.setFont(hoverFont);
        }
      }
      // If previous data was valid, but this one isn't, start drawing in grey
      else if (!sparkData.isValid(row, col) && sparkData.isValid(row - 1, col) && years[row - 1] >= sparkSelect.getYearStart()) {
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
  
  void drawDataMax() {
    float x = map(dataMaxYear, sparkSelect.getYearStart(), sparkSelect.getYearEnd(), plotX1, plotX2);
    float y = map(dataMax, dataMin, dataMax, plotY2, plotY1);  
    
    stroke(255, 0, 0);
    strokeWeight(3);
    point(x, y);
  }
  
  void drawDataMin() {
    float x = map(dataMinYear, sparkSelect.getYearStart(), sparkSelect.getYearEnd(), plotX1, plotX2);
    float y = map(dataMin, dataMin, dataMax, plotY2, plotY1);  
    
    stroke(0, 153, 255);
    strokeWeight(3);
    point(x, y);
  }
 
  void drawTicks() {
    fill(0);
    textFont(font);
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
  
  boolean checkMouse() {
    checkTitle();
    if((mouseX >= x1 && mouseX <= x2) && (mouseY > y1 && mouseY < y2)) {
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

  boolean dragEnd() {
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
  
  void setFont(PFont font) {
    this.font = font;
  }
  
  void setHoverFont(PFont font) {
    this.hoverFont = font;
  }
}
//********************************************************************
// SparkManager
// Handles size & position of sparklines when interacted with
//********************************************************************

class SparkManager {
  boolean bifocal, locked;
  float x1, y1, x2, y2;
  float heightStd, heightSmall, heightBig;
  int zoomCenter;
  int sparkOrder[];

  SparkLine[] managedSparks;

  SparkManager(float inputX1, float inputY1, float inputX2, float inputY2, SparkLine[] inputSparks) {
    x1 = inputX1;
    y1 = inputY1;
    x2 = inputX2;
    y2 = inputY2;
    managedSparks = inputSparks;

    bifocal = false;

    sparkOrder = new int[managedSparks.length];

    heightStd = (y2 - y1) / managedSparks.length; // height of sparklines when mouseout
    heightBig = heightStd * 2.5; // height of sparklines when mouseover
  }

  void drawSparks() {
    int dragger = 0;
    for(int i = 0; i < data.getColumnCount(); i++) {
      if(!managedSparks[sparkOrder[i]].isDragged()) {
	managedSparks[sparkOrder[i]].drawSparkLine();	
      } else {
	dragger = i;
      }
    }
    managedSparks[sparkOrder[dragger]].drawSparkLine();
  }

  void setupOrder(FloatTable manData) {
    String[] farmIndexes = { manData.getIndex(0) };
    String uniques = manData.getIndex(0);
    
    for (int i = 1; i < manData.getColumnCount(); i++) {
      String[] m = match(uniques, manData.getIndex(i));
      if (m == null) {
        uniques = uniques + " " + manData.getIndex(i);
	farmIndexes = append(farmIndexes, manData.getIndex(i));
      }
    }
	
    int colCount = 0;
    for (int i = 0; i < farmIndexes.length; i++) {
      for (int j = 0; j < manData.getColumnCount(); j++) {
	if (farmIndexes[i].equals(manData.getIndex(j))) {
          sparkOrder[colCount] = j;
	  colCount++;
	}
      }
    }
    update();
  }

  // Checks to see if mouse is in area of sparkline list
  boolean checkMouse() {
    if((mouseX >= x1 && mouseX <= x2) && (mouseY > y1 && mouseY < y2)) {
      return true;
    }
    return false;
  }

  // Handle mouseovers in sparkline list
  void mMoved() {
    if (!locked) {
      int focusCount = 0;
      if(checkMouse()) {
        bifocal = true;
	for (int i = 0; i < managedSparks.length; i++) {
          if(managedSparks[sparkOrder[i]].checkMouse()) {
            if (i > 2) {
              focusCount += 3;
            } else {
              focusCount += i;
            }
	  
            if (zoomCenter != i) {
              managedSparks[sparkOrder[zoomCenter]].setZoom(false);
	      zoomCenter = i;
	      managedSparks[sparkOrder[i]].setZoom(true);
	    }
	    focusCount++;
	  
            if (managedSparks.length - i > 3) {
              focusCount += 3;
            } else {
              focusCount += managedSparks.length - i - 1;
            }
            heightSmall = (y2 - y1 - (focusCount * heightBig)) / (managedSparks.length - focusCount);
          }
        }
      } else {
        managedSparks[sparkOrder[zoomCenter]].setZoom(false);
        bifocal = false;
      }
      update();
    }
  }

  // Swaps the position of two sparklines in the list
  void swap(int swap1, int swap2) {
    int swap1Pos = 0;
    int swap2Pos = 0;
    for (int i = 0; i < managedSparks.length; i++) {
      if (swap1 == sparkOrder[i]) {
	swap1Pos = i;
      }
      if (swap2 == sparkOrder[i]) {
	swap2Pos = i;
      }
    }
    sparkOrder[swap1Pos] = swap2;
    sparkOrder[swap2Pos] = swap1;
    update();
  }

  // Locks the position and size of a sparkline
  void lock() {
    locked = (locked) ? false : true;
  }

  // Update position and sizes of sparklines in list
  void update() {
    if (!locked) {
      float yNext = y1;
      for (int i = 0; i < managedSparks.length; i++) {
        if (bifocal) {
          if (zoomCenter >= i - 3 && zoomCenter <= i + 3) { 
	    managedSparks[sparkOrder[i]].setY(yNext, yNext + floor(heightBig * .75));		
            yNext = yNext + heightBig;
	  } else {
	    managedSparks[sparkOrder[i]].setY(yNext, yNext + floor(heightSmall * .75));			
	    yNext = yNext + heightSmall;
	  }
	} else {
          managedSparks[sparkOrder[i]].setY(y1 + (heightStd * i), y1 + floor(heightStd * .75) + (heightStd * i));	
	}
      }
    }
  }

}
//********************************************************************
// TimePlot
// Draws a line chart with a selection area
//********************************************************************

class TimePlot {
  boolean[] usage;
  boolean[] greyed;
  boolean showDetail, selMode;
  
  color[] plotColour;
  color background;
  
  float x1, y1, x2, y2; 
  float plotX1, plotY1, plotX2, plotY2;
  float[] padding;
  float dataMin, dataMax; 
  float mouseTrackX, mouseTrackY;
  float selX1, selX2;
  
  int rowCount, mouseOver;
  int years[];
  int yearMin, yearMax;
  int yearInterval = 100;
  int tickInterval = 75;
  int selYear1, selYear2;
  
  PFont font;
  
  FloatTable chartData;
  HoverBox detail;
  Selection timeSelect;
  
  TimePlot (float inputX1, float inputY1, float inputX2, float inputY2, FloatTable inputData, Selection inputSelect) {
    x1 = inputX1;
    y1 = inputY1;
    x2 = inputX2;
    y2 = inputY2;
    plotX1 = inputX1 + 75;
    plotY1 = inputY1;
    plotX2 = inputX2 - 25;
    plotY2 = inputY2;

    chartData = inputData;
    timeSelect = inputSelect;
    
    background = color(255);
    plotColour = new color[chartData.getColumnCount()];
    this.font = createFont("Arial", 12);
    
    rowCount = chartData.getRowCount();
    years = chartData.getRowNames();
    yearMin = years[0];
    yearMax = years[years.length - 1];
    dataMax = chartData.getTableMax();
  }
  
  // 
  void drawChart() {
    showDetail = false;
    
    fill(0);
    textFont(font);
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
    
    for(int i = 0; i < chartData.getColumnCount(); i++) {
      if(usage[i]) {
        drawDataCurve(i);
      }
    }
    
    drawTicks(); 
    
    if(showDetail) {
      detail.drawHover();
    }
  }
  
  void drawSelection(boolean selectionMode) {
    if(selectionMode) {
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
        textFont(font);
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
  
  void drawDataCurve(int col)  {    
    noFill();
    if (greyed[col]) {
      stroke(180);
    } else {
      stroke(plotColour[col]);
    }
    strokeWeight(1);
    beginShape();
    for (int row = 0; row < rowCount; row++) {
      if (chartData.isValid(row, col)) {
        float value = chartData.getFloat(row, col);
        float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
        float y = map(value, dataMin, dataMax, plotY2, plotY1);        
        if (!chartData.isValid(row - 1, col)) {
          curveVertex(x, y);
          curveVertex(x, y);
          endShape(); 
          
          noFill();
          if (greyed[col]) {
            stroke(180);
          } else {
            stroke(plotColour[col]);
          }
          strokeWeight(1);
          
          beginShape();
          curveVertex(x, y);
        }
        curveVertex(x, y);
        // Double the curve points for the start and stop
        if ((row == 0) || (row == rowCount -1)) {
          curveVertex(x, y);
        }
        //
        if (dist(mouseX, mouseY, x, y) < 5  && !showDetail) { 
          showDetail = true;
          mouseTrackX = mouseX;
          mouseTrackY = mouseY;
          mouseOver = col;
          detail = new HoverBox(x, y, chartData.getColumnName(col) + " " + years[row] + ": " + value);
          detail.setFont(font);
        }
      }
      // If previous data was valid, but this one isn't, start drawing in grey
      else if (!chartData.isValid(row, col) && chartData.isValid(row - 1, col)) {
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
 
  void drawTicks() {
    fill(0);
    textFont(font);
    textSize(10);
    textAlign(RIGHT, CENTER);
    
    // Varying alignments
    stroke(128);
    strokeWeight(1);
    
    for (float v = dataMin; v <= dataMax; v += tickInterval) {
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
      if (v % tickInterval == 0) { // If a major tick mark
        if (v == dataMin) {
          textAlign(RIGHT); // Align by the bottom
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
  
  // Draw the year labels below the chart, & vertical lines in the chart
  void drawYearLabels() {
    fill(0);
    textFont(font);
    textSize(10);
    textAlign(LEFT);
    
    // Use thin, grey lines to draw the grid.
    stroke(224);
    strokeWeight(1);
    
    for (int row = yearMin; row < yearMax; row++) {
      if ((row % yearInterval) == 0) {
        float x = map(row, yearMin, yearMax, plotX1, plotX2);
        text(row, x, plotY2 + 15);
        line(x, plotY1, x, plotY2);
      }
    }
  }
  
  // Sets the font used in the chart
  void setFont(PFont font) {
    this.font = font;
  }
  
  
  void setUsage(boolean[] inputUsage) {
    usage = inputUsage;
    greyed = new boolean[usage.length];
    
    //float m = -Float.MAX_VALUE;
    float m = -200;
    for(int i = 0; i < chartData.getColumnCount(); i++) {
      if(usage[i]) {
        if (m < chartData.getColumnMax(i)) {
          m = chartData.getColumnMax(i);
        }
        plotColour[i] = assignColour(i);
      }
    }
    dataMax = m;
  }
  
  void mPressed() {
    if(checkMouse()) {
      if (mouseButton == LEFT) {
        if (dist(mouseX, mouseY, mouseTrackX, mouseTrackY) < 2) {
          greyed[mouseOver] = greyed[mouseOver] ? false : true;
        } else {
          selX1 = mouseX;
          selX2 = (selX1 < plotX2) ? mouseX + 1 : mouseX - 1;
          selMode = true;
        }
      } else if (mouseButton == RIGHT) {
        selMode = false;
      }
    }
  }
  
  void mDragged() {
    if(checkMouse()) {
      if (selMode) {
        selX2 = mouseX;
        if (mouseX <= plotX1) {
          selX2 = plotX1;
        } else if (mouseX >= plotX2) {
          selX2 = plotX2;
        }
      }
    }
  }
  
  void mReleased() {
    if (mouseButton == LEFT) {
      if(selMode) {
        float setX1;
        float setX2;
        if (selX1 < selX2) {
          setX1 = map(selX1, plotX1, plotX2, yearMin, yearMax);
          setX2 = map(selX2, plotX1, plotX2, yearMin, yearMax);
        } else {
          setX1 = map(selX2, plotX1, plotX2, yearMin, yearMax);
          setX2 = map(selX1, plotX1, plotX2, yearMin, yearMax);
        }
        selectMinRow = int(setX1) - years[0];
        selectMaxRow = int(setX2) - years[0];
        timeSelect.setRowRange(int(setX1) - years[0], int(setX2) - years[0]);
      }
    } else if (mouseButton == RIGHT) {
      selectMinRow = yearMin;
      selectMaxRow = yearMax;
      timeSelect.setRowRange(0, chartData.getRowCount() - 1);
    }
  }
  
  boolean checkMouse() {
    if((mouseX >= plotX1 && mouseX <= plotX2) && (mouseY > plotY1 && mouseY < plotY2)) {
      return true;
    }
    return false;
  }
  
  color assignColour(int index) {
    color setColor = color(0);
    
    switch (index) {
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


