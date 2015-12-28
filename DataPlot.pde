class DataPlot
{
	boolean isValid;
	int column;
	int plotMinYear, plotMaxYear;
	float mean, stdDev;
	float normal1, normal2;
	float plotMin, plotMax;
	float validRowStart;

	FloatTable plotData;
	Selection plotSelect;

	DataPlot (FloatTable inputData, Selection inputSelect, int inputColumn)
	{
		plotData = inputData;
		plotSelect = inputSelect;
		column = inputColumn;

		float sum = 0;
		int counter = 0;
		for (int i = 0; i < plotData.getRowCount(); i++)
		{
			if (plotData.isValid(i, column))
			{
				sum += plotData.getFloat(i, column);
				counter++;
			}
		}
		mean = sum / counter;

		sum = 0;
		for (int i = 0; i < plotData.getRowCount(); i++)
		{
			if (plotData.isValid(i, column))
			{
				sum += sq(plotData.getFloat(i, column) - mean);
			}
		}
		stdDev = sqrt(sum / counter);

		update();
	}

	void update()
	{
		isValid = plotData.isValidRange(plotSelect.getRowStart(), plotSelect.getRowEnd(), column);

		if (isValid)
		{
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
			}
			else if ((mean - stdDev * 2) > plotMax) {
				normal1 = plotMax;
			}
			else {
				normal1 = mean - stdDev * 2;
			}

			if ((mean + stdDev) < plotMin) {
				normal2 = plotMin;
			}
			else if ((mean + stdDev * 2) > plotMax) {
				normal2 = plotMax;
			}
			else {
				normal2 = mean + stdDev * 2;
			}
		}
	}

	boolean getValid()
	{
		return isValid;
	}

	float getDataMin()
	{
		return plotMin;
	}

	float getDataMax()
	{
		return plotMax;
	}

	int getDataMinYear()
	{
		return plotMinYear;
	}

	int getDataMaxYear()
	{
		return plotMaxYear;
	}

	float getLowNormal()
	{
		return normal1;
	}

	float getUpperNormal()
	{
		return normal2;
	}
}