//**********************************
//ROUND BUTTON
//**********************************
class RoundButton
{
  boolean state;
  char shape;
  color fillOnColour, fillOffColour;
  float xPos, yPos, radius;
  int type;
  String name;

  RoundButton (float inputXPos, float inputYPos, float inputRadius)
  {
    xPos = inputXPos;
    yPos = inputYPos;
    radius = inputRadius;
    fillOnColour = color(150, 150, 255);
    fillOffColour = color(0);
    shape = 'a';
    state = false;
  }
  
  void draw()
  {
    // Draw circle
    noStroke();
    if (state) {
      fill(fillOnColour);
    }
    else {
      fill(fillOffColour);
    }
    ellipseMode(CENTER);
    ellipse(xPos, yPos, radius, radius);

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
    if (state) {
      line(xPos + .25 * radius, yPos - .25 * radius, xPos - .25 * radius, yPos);
      line(xPos - .25 * radius, yPos, xPos + .25 * radius, yPos + .25 * radius);
    }
    else {
    line(xPos - .25 * radius, yPos - .25 * radius, xPos + .25 * radius, yPos);
    line(xPos + .25 * radius, yPos, xPos - .25 * radius, yPos + .25 * radius);
    }
  }

  void drawLock()
  {
    stroke(255);
    strokeWeight(1);  
    arc(xPos, yPos - .15 * radius, .25 * radius, .4 * radius, PI, 2 * PI);
    noStroke();
    fill(255);
    rectMode(CORNER);
    rect(xPos - .25 * radius, yPos - .15 * radius, .5 * radius, .5 * radius);
  }

  
  void setPos(float inputXPos, float inputYPos)
  {
    xPos = inputXPos;
    yPos = inputYPos;
  }
  
  void setState (boolean inputState)
  {
    state = inputState;
  }
  
  void flipState()
  {
    state = state ? false : true;
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
    if (sqrt((sq(mouseX - xPos) + sq(mouseY - yPos))) < radius)
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
    return state;
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