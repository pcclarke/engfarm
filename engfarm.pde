/* @pjs font="/EncodeSansCondensed-Regular.ttf, /LibreCaslonText-Bold.ttf"; */
    
int selectMinRow, selectMaxRow;
float bigFloat = 1000000; // poor substitute for not being able to use Float.MAX_VALUE

PFont bodyFont, headerFont, displayFont;

DataPlot[] plots;
TimePlot main;
FloatTable data;
Selection mainSelection;
SparkLine[] sparks;
SparkManager overSparks;
IndexChart second;

void setup()
{
  size(1024, 768);

  data = new FloatTable("farm2002.csv");

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
  }

  overSparks = new SparkManager(25, 215, 425, 750, sparks);
  overSparks.setupOrder(data);
  
//  bodyFont = createFont("Encode Sans Condensed", 20);
//  displayFont = createFont("Libre Caslon Text", 50);
  bodyFont = createFont("EncodeSansCondensed-Regular.ttf", 12);
  headerFont = createFont("LibreCaslonText-Bold.ttf", 16);
  displayFont = createFont("LibreCaslonText-Bold.ttf", 50.5);
  
  main = new TimePlot(25, 95, width, 145, data, mainSelection);
  main.setFont(bodyFont);
  main.setUsage(mainUsage);
  
  second = new IndexChart(400, 215, 1024, 768, data, mainSelection);
  second.setFont(bodyFont);
  
  assignColour();

  smooth();
}

void draw() {
  background(252, 249, 240);
  
  textAlign(LEFT, BOTTOM);
  textFont(displayFont);
  //fill(119, 118, 112);
  fill(100);
  textSize(50.5);
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

