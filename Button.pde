//**********************************
//Button Class - This makes Buttons!
//**********************************
class Button
{
  float Xposa;
  float Yposa;
  float Xposb;
  float Yposb;
  String name, sub;
  int category;
  char align;
  color fillOnColour;
  color fillOffColour;
  color textColour;
  color borderColour;
  boolean state;
  boolean showBorder, hasSub;

  Button (float inputXposa, float inputYposa, float inputXposb, float inputYposb, String inputName, int inputCategory)
  {
    Xposa = min(inputXposa, inputXposb);
    Yposa = min(inputYposa, inputYposb);
    Xposb = max(inputXposa, inputXposb);
    Yposb = max(inputYposa, inputYposb);
    name = inputName;
    category = inputCategory;

    fillOffColour = color(252, 249, 240);
    fillOnColour = color(240);
    textColour = color(0);
    borderColour = color(220);

    state = false;
    showBorder = false;
    hasSub = false;

    align = 'c';
  }
  
  void setPos(float inputXposa, float inputYposa, float inputXposb, float inputYposb)
  {
    Xposa = min(inputXposa, inputXposb);
    Yposa = min(inputYposa, inputYposb);
    Xposb = max(inputXposa, inputXposb);
    Yposb = max(inputYposa, inputYposb);
  }

  void setAlign(char ali)
  {
    align = ali;
  }
  
  void setState (boolean inputState)
  {
    state = inputState;
  }
  
  void setFillOffColour(color inputColour)
  {
    fillOffColour = inputColour;
  }

  boolean checkMouse()
  {
    if ((mouseX < Xposb) && (mouseX > Xposa) && (mouseY < Yposb) && (mouseY > Yposa))
    {
      showBorder = true;
      return true;     
    }
    else
    {
      showBorder = false;
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

  void setSub(String inputText) {
    sub = inputText;
    hasSub = true;
  }

  int getCategory()
  {
    return category;
  }
  
  void setBorder(boolean inputBorder)
  {
      showBorder = inputBorder;
  }

  void draw()
  {
    noStroke();
    if (state == false)
    {
      fill(fillOffColour);
    }
    else if (state == true)
    {
      fill(fillOnColour);
    }
    
    if (showBorder) {
      strokeWeight(1);
      stroke(borderColour);
    } else {
      noStroke();
    } 
      
    rectMode(CORNERS);
    rect(Xposa, Yposa, Xposb, Yposb);

    fill(textColour);
    textSize(10);

    if (Yposb - Yposa < 25) {
      switch(align)
      {
        case 'l':
          textAlign(LEFT);
          text(name, Xposa + 5, Yposa + 4 + (0.5 * (Yposb - Yposa)));
          break;
        case 'c':
          textAlign(CENTER);
          text(name, Xposa + (0.5 * (Xposb - Xposa)), Yposa + 4 + (0.5 * (Yposb - Yposa)));
          break;
        case 'r':
          textAlign(RIGHT);
          text(name, Xposb - 5, Yposa + 4 + (0.5 * (Yposb - Yposa)));
          break;
      }
    }
    else {
      textSize(12);
      switch(align)
      {
        case 'l':
          textAlign(LEFT);
          text(name, Xposa + 5, Yposa + 4 + (0.35 * (Yposb - Yposa)));
          if (hasSub) {
            fill(128);
            text(sub, Xposa + 5, Yposa + 4 + (0.65 * (Yposb - Yposa)));  
          }
          break;
        case 'c':
          textAlign(CENTER);
          text(name, Xposa + (0.5 * (Xposb - Xposa)), Yposa + 4 + (0.35 * (Yposb - Yposa)));
          if (hasSub) {
            fill(128);
            text(sub, Xposa + (0.5 * (Xposb - Xposa)), Yposa + 4 + (0.65 * (Yposb - Yposa)));
          }
          break;
        case 'r':
          textAlign(RIGHT);
          text(name, Xposb - 5, Yposa + 4 + (0.35 * (Yposb - Yposa)));
          if (hasSub) {
            fill(128);
            text(sub, Xposb - 5, Yposa + 4 + (0.65 * (Yposb - Yposa)));
          }
          break;
      }
    }

    
  }
}