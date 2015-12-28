//**********************************
//Button Class - This makes Buttons!
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

  Button (float inputX1, float inputY1, float inputX2, float inputY2, String inputName, int inputCategory) {
    x1 = min(inputX1, inputX2);
    y1 = min(inputY1, inputY2);
    x2 = max(inputX1, inputX2);
    y2 = max(inputY1, inputY2);
    name = inputName;
    category = inputCategory;

    fillOffColour = color(252, 249, 240);
    fillOnColour = color(240);
    textColour = color(0);
    borderColour = color(220);

    selected = false;
    showBorder = false;
    hasSub = false;

    align = 'c';
  }
  
  void setPos(float inputx1, float inputy1, float inputx2, float inputy2) {
    x1 = min(inputx1, inputx2);
    y1 = min(inputy1, inputy2);
    x2 = max(inputx1, inputx2);
    y2 = max(inputy1, inputy2);
  }

  void setAlign(char ali) {
    align = ali;
  }
  
  void setState (boolean inputSelected) {
    selected = inputSelected;
  }
  
  void setFillOffColour(color inputColour) {
    fillOffColour = inputColour;
  }

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
