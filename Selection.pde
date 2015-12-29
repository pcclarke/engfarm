//********************************************************
// Selection
// Contains information about a selected set of data
//********************************************************

class Selection {
  int rowStart, rowEnd;
  int yearStart, yearEnd;
  float dataMin, dataMax;

  FloatTable selData;

  Selection(FloatTable inputData) {
    selData = inputData;

    rowStart = 0;
    rowEnd = selData.getRowCount() - 1;

    yearStart = selData.getRowName(rowStart);
    yearEnd = selData.getRowName(rowEnd);

    dataMin = selData.getTableMin();
    dataMax = selData.getTableMax();
  }

  int getRowStart() {
    return rowStart;
  }

  int getRowEnd() {
    return rowEnd;
  }

  void setRowRange(int start, int end) {
    rowStart = start;
    rowEnd = end;

    yearStart = selData.getRowName(rowStart);
    yearEnd = selData.getRowName(rowEnd);

    dataMin = selData.getTableMinRange(rowStart, rowEnd);
    dataMax = selData.getTableMaxRange(rowStart, rowEnd);
  }

  int getYearStart() {
    return yearStart;
  }

  int getYearEnd() {
    return yearEnd;
  }
}	
