class SparkManager
{
	boolean bifocal, locked;
	float x1, y1, x2, y2;
	float heightStd, heightSmall, heightBig;
	int zoomCenter;
	int sparkOrder[];

	SparkLine[] managedSparks;

	SparkManager(float inputX1, float inputY1, float inputX2, float inputY2, SparkLine[] inputSparks)
	{
	    x1 = inputX1;
    	y1 = inputY1;
    	x2 = inputX2;
    	y2 = inputY2;
    	managedSparks = inputSparks;

    	bifocal = false;

    	sparkOrder = new int[managedSparks.length];

    	heightStd = (y2 - y1) / managedSparks.length;
    	heightBig = heightStd * 2.5;	
	}

	void drawSparks()
	{
		int dragger = 0;
		for(int i = 0; i < data.getColumnCount(); i++)
		{
			if(!managedSparks[sparkOrder[i]].isDragged()) {
				managedSparks[sparkOrder[i]].drawSparkLine();	
			}
			else {
				dragger = i;
			}
		}
		managedSparks[sparkOrder[dragger]].drawSparkLine();
	}

	void setupOrder(FloatTable manData)
	{
		String[] farmIndexes = {manData.getIndex(0)};
		String uniques = manData.getIndex(0);

		for (int i = 1; i < manData.getColumnCount(); i++)
		{
			String[] m = match(uniques, manData.getIndex(i));
			if (m == null)
			{
				uniques = uniques + " " + manData.getIndex(i);
				farmIndexes = append(farmIndexes, manData.getIndex(i));
			}
		}
		
		int colCount = 0;
		for (int i = 0; i < farmIndexes.length; i++)
		{
			for (int j = 0; j < manData.getColumnCount(); j++)
			{
				if (farmIndexes[i].equals(manData.getIndex(j)))
				{
					sparkOrder[colCount] = j;
					colCount++;
				}
			}
		}
		update();
	}

	boolean checkMouse()
  	{
	    if((mouseX >= x1 && mouseX <= x2) && (mouseY > y1 && mouseY < y2))
	    {
	      return true;
	    }
	    return false;
  	}

	void mMoved()
	{
		if(!locked)
		{
		int focusCount = 0;
		if((mouseX >= x1 && mouseX <= x2) && (mouseY > y1 && mouseY < y2))
		{
			bifocal = true;
			for (int i = 0; i < managedSparks.length; i++)
			{
				if(managedSparks[sparkOrder[i]].checkMouse())
				{
					if (i == 1)
					{
						focusCount++;
					}
					else if (i == 2)
					{
						focusCount += 2;
					}
					else if (i > 2) {
						focusCount += 3;
					}
					if (zoomCenter != i) {
						managedSparks[sparkOrder[zoomCenter]].setZoom(false);
						zoomCenter = i;
						managedSparks[sparkOrder[i]].setZoom(true);
					}
					focusCount++;
					if (i == managedSparks.length - 2)
					{
						focusCount++;
					}
					else if (i == managedSparks.length - 3)
					{
						focusCount += 2;
					}
					else if (i < managedSparks.length - 3)
					{
						focusCount += 3;
					}
					heightSmall = (y2 - y1 - (focusCount * heightBig)) / (managedSparks.length - focusCount);
				}
			}
		}
		else
		{
			managedSparks[sparkOrder[zoomCenter]].setZoom(false);
			bifocal = false;
		}
		update();
		}
	}

	void swap(int swap1, int swap2)
	{
		int swap1Pos = 0;
		int swap2Pos = 0;
		for (int i = 0; i < managedSparks.length; i++)
		{
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

	void lock()
	{
		if(locked) {
			locked = false;
		}
		else {
			locked = true;
		}
	}

	void update()
	{
		if (!locked)
		{
			float yNext = y1;
			for (int i = 0; i < managedSparks.length; i++)
			{
				if (bifocal)
				{
					if((i == zoomCenter) || (i + 1 == zoomCenter) || (i - 1 == zoomCenter)
						|| (i + 2 == zoomCenter) || (i - 2 == zoomCenter)
						|| (i + 3 == zoomCenter) || (i - 3 == zoomCenter)) {
						managedSparks[sparkOrder[i]].setY(yNext, yNext + floor(heightBig * .75));		
						yNext = yNext + heightBig;
					}
					else {
						managedSparks[sparkOrder[i]].setY(yNext, yNext + floor(heightSmall * .75));			
						yNext = yNext + heightSmall;
					}
				}
				else {
					managedSparks[sparkOrder[i]].setY(y1 + (heightStd * i), y1 + floor(heightStd * .75) + (heightStd * i));	
				}
				
			}
		}
	}



}