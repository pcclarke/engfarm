class HoverBox
{
  float xPos, yPos, w, h;
  String text;
  
  HoverBox (float x, float y, String inputText)
  {
    xPos = x;
    yPos = y;
    text = inputText;
    
    w = 6 * text.length();
    h = 15;
  }
  
  void drawHover()
  {
    fill(255, 255, 255, 200);
    stroke(128);
    strokeWeight(1);
    rectMode(CENTER);
    if (xPos + w * .5 > width)
    {
      rect(xPos - .5 * w, yPos -12, w, h);
    }
    else if (xPos - w * .5 < 0)
    {
      rect(xPos + .5 * w, yPos -12, w, h);
    }
    else
    {
      rect(xPos, yPos - 12, w, h);
    }
    
    fill(0);
    textFont(futura20);
    textSize(12);
    textAlign(CENTER);
    if (xPos + w  * .5  > width)
    {
      text(text, xPos - .5 * w, yPos - 8);
    }
    else if (xPos - w * .5 < 0)
    {
       text(text, xPos + .5 * w, yPos - 8); 
    }
    else
    {
      text(text, xPos, yPos - 8);
    }
    
    stroke(0);
    strokeWeight(10);
    point(xPos, yPos);
  }
}