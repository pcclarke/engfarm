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
