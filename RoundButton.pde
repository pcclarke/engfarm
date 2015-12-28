//**********************************
//ROUND BUTTON
//**********************************
class RoundButton {
  boolean selected;
  char shape;
  color fillOnColour, fillOffColour;
  float x, y, radius;
  int type;
  String name;

  RoundButton (float x, float y, float inputRadius) {
    this.x = x;
    this.y = y;
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
