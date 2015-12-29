//********************************************************************
// HoverBox
// Draws a pop-up box at a given position
//********************************************************************

class HoverBox {
  float x, y, w, h;
  PFont font;
  String hoverText;
  
  HoverBox (float inputX, float inputY, String inputText, PFont font) {
    x = inputX;
    y = inputY;
    hoverText = inputText;
    
    w = 6 * hoverText.length();
    h = 15;
    
    this.font = font;
  }
  
  void drawHover() {
    fill(255, 255, 255, 200);
    stroke(128);
    strokeWeight(1);
    rectMode(CENTER);
    if (x + w * .5 > width) {
      rect(x - .5 * w, y -12, w, h);
    } else if (x - w * .5 < 0) {
      rect(x + .5 * w, y -12, w, h);
    } else {
      rect(x, y - 12, w, h);
    }
    
    fill(0);
    textFont(font);
    textSize(12);
    textAlign(CENTER);
    if (x + w  * .5  > width) {
      text(hoverText, x - .5 * w, y - 8);
    } else if (x - w * .5 < 0) {
       text(hoverText, x + .5 * w, y - 8); 
    } else {
      text(hoverText, x, y - 8);
    }
    
    stroke(0);
    strokeWeight(10);
    point(x, y);
  }
}
