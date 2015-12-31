//****************************************************************
// FloatTable
// Lifted from "Visualizing Data" by Ben Fry
// Because there's no Table class in Processing.js, sigh...
//****************************************************************

class FloatTable {
  int rowCount;
  int columnCount;
  float[][] data;
  int[] rowNames;
  String[] columnNames;
  String[] columnUnits;
  String[] columnIndices;
  
  FloatTable(String filename) {
    String[] rows = loadStrings(filename);
    
    String[] columns = split(rows[0], ',');
    columnNames = subset(columns, 1); // upper-left corner ignored
    scrubQuotes(columnNames);
    columnCount = columnNames.length;
    
    String[] units = split(rows[1], ',');
    columnUnits = subset(units, 1); // upper-left corner ignored
    
    String[] indices = split(rows[2], ',');
    columnIndices = subset(indices, 1); // upper-left corner ignored

    rowNames = new int[rows.length-3];
    data = new float[rows.length-3][];

    // start reading at row 1, because the first row was only the column headers
    for (int i = 3; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }

      // split the row on the commas
      String[] pieces = split(rows[i], ',');
      scrubQuotes(pieces);
      
      // copy row title
      rowNames[rowCount] = int(pieces[0]);
      // copy data into the table starting at pieces[1]
      data[rowCount] = parseFloat(subset(pieces, 1));

      // increment the number of valid rows found so far
      rowCount++;      
    }
    // resize the 'data' array as necessary
    data = (float[][]) subset(data, 0, rowCount);
  }
  
  
  void scrubQuotes(String[] array) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].length() > 2) {
        // remove quotes at start and end, if present
        if (array[i].startsWith("\"") && array[i].endsWith("\"")) {
          array[i] = array[i].substring(1, array[i].length() - 1);
        }
      }
      // make double quotes into single quotes
      array[i] = array[i].replaceAll("\"\"", "\"");
    }
  }
  
  int getRowCount() {
    return rowCount;
  }
  
  int getRowName(int rowIndex) {
    return rowNames[rowIndex];
  }
  
  int[] getRowNames() {
    return rowNames;
  }
  
  // Find a row by its name, returns -1 if no row found. 
  // This will return the index of the first row with this name.
  // A more efficient version of this function would put row names
  // into a Hashtable (or HashMap) that would map to an integer for the row.
  int getRowIndex(int year) {
    for (int i = 0; i < rowCount; i++) {
      if (rowNames[i] == year) {
        return i;
      }
    }
    //println("No row named '" + name + "' was found");
    return -1;
  }
  
  
  // technically, this only returns the number of columns 
  // in the very first row (which will be most accurate)
  int getColumnCount() {
    return columnCount;
  }
  
  
  String getColumnName(int colIndex) {
    return columnNames[colIndex];
  }
  
  
  String[] getColumnNames() {
    return columnNames;
  }
  
  String getUnit(int colIndex) 
  {
    return columnUnits[colIndex];
  }
  
  String getIndex (int colIndex)
  {
    return columnIndices[colIndex];
  }


  float getFloat(int rowIndex, int col) {
    // Remove the 'training wheels' section for greater efficiency
    // It's included here to provide more useful error messages
    
    // begin training wheels
    if ((rowIndex < 0) || (rowIndex >= data.length)) {
      throw new RuntimeException("There is no row " + rowIndex);
    }
    if ((col < 0) || (col >= data[rowIndex].length)) {
      throw new RuntimeException("Row " + rowIndex + " does not have a column " + col);
    }
    // end training wheels
    
    return data[rowIndex][col];
  }
  
  float getNextValidFloat(int rowIndex, int col)
  {
    for (int i = rowIndex; i < rowCount; i++)
    {
      if (isValid(i, col))
      {
        return data[i][col];
      }
    }
    return 0;
  }
  
  
  boolean isValid(int row, int col) 
  {
    if (row < 0) return false;
    if (row >= rowCount) return false;
    //if (col >= columnCount) return false;
    if (col >= data[row].length) return false;
    if (col < 0) return false;
    return !(data[row][col] < 0);
  }

  boolean isValidRange(int rowMin, int rowMax, int col)
  {
    if (rowMin < 0)
      return false;
    if (rowMin > rowMax)
      return false;
    if (rowMin >= rowCount)
      return false;
    if (rowMax < 0)
      return false;
    if (rowMax < rowMin)
      return false;
    if (rowMax >= rowCount)
      return false;

    for (int i = rowMin; i < rowMax; i++)
    {
      if (col < data[i].length)
      //if (!Float.isNaN(data[i][col]))
        return true;
    }
    return false;
  }

  float getQ1(int col)
  {
    float[] fullCol = new float[rowCount];
    float med = 0;
    int goodCount = 0;
    for (int i = 0; i < rowCount; i++) {
      if (isValid(i, col)) {
        if (data[i][col] > 0) {
          fullCol[goodCount] = data[i][col];
          goodCount++;
        }
      }
    }

    fullCol = subset(fullCol, 0, goodCount);

    Quicksort findMed = new Quicksort();
    findMed.sort(fullCol);
    med = findMed.getQ1();
    return med;
  }

  float getMedian(int col)
  {
    float[] fullCol = new float[rowCount];
    float med = 0;
    int goodCount = 0;
    for (int i = 0; i < rowCount; i++) {
      if (isValid(i, col)) {
        if (data[i][col] > 0) {
          fullCol[goodCount] = data[i][col];
          goodCount++;
        }
      }
    }

    fullCol = subset(fullCol, 0, goodCount);

    Quicksort findMed = new Quicksort();
    findMed.sort(fullCol);
    med = findMed.getPivot();
    return med;
  }

  float getQ3(int col) {
    float[] fullCol = new float[rowCount];
    float med = 0;
    int goodCount = 0;
    for (int i = 0; i < rowCount; i++) {
      if (isValid(i, col)) {
        fullCol[goodCount] = data[i][col];
        goodCount++;
      }
    }

    fullCol = subset(fullCol, 0, goodCount);
   
    Quicksort findMed = new Quicksort();
    findMed.sort(fullCol);
    med = findMed.getQ3();
    return med;
  }
  
  float getColumnMin(int col) {
    float m = bigFloat;
    for (int i = 0; i < rowCount; i++) {
      if (isValid(i, col)) {
        if (data[i][col] < m) {
          m = data[i][col];
        }
      }
    }
    return m;
  }
  
  float getColumnMax(int col) {
    float m = -bigFloat;
    for (int i = 0; i < rowCount; i++) {
      if (isValid(i, col)) {
        if (data[i][col] > m) {
          m = data[i][col];
        }
      }
    }
    return m;
  }
  
  int getColumnMinRange(int col, int min, int max) {
    float m = bigFloat;
    int minRow = 0;
    for (int i = min; i <= max; i++) {
      if (isValid(i, col)) {
        if (data[i][col] < m) {
          m = data[i][col];
          minRow = i;
        }
      }
    }
    return minRow;
  }
  
  int getColumnMaxRange(int col, int min, int max) {
    float m = -bigFloat;
    int maxRow = 1;
    for (int i = min; i <= max; i++) 
    {
      if (isValid(i, col)) {
        if (data[i][col] > m) {
          m = data[i][col];
          maxRow = i;
        }
      }
    }
    return maxRow;
  }

  
  float getRowMin(int row) {
    float m = bigFloat;
    for (int i = 0; i < columnCount; i++) {
      if (isValid(row, i)) {
        if (data[row][i] < m) {
          m = data[row][i];
        }
      }
    }
    return m;
  } 

  
  float getRowMax(int row) {
    float m = -bigFloat;
    for (int i = 1; i < columnCount; i++) {
      //if (!Float.isNaN(data[row][i])) {
        if (data[row][i] > m) {
          m = data[row][i];
        }
      //}
    }
    return m;
  }
  
  
  float getTableMin() {
    float m = bigFloat;
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < columnCount; j++) {
        if (isValid(i, j)) {
          if (data[i][j] < m) {
            m = data[i][j];
          }
        }
      }
    }
    return m;
  }
  
  float getTableMinRange(int min, int max) {
    float m = bigFloat;
    for (int i = min; i < max; i++) {
      for (int j = 0; j < columnCount; j++) {
        if (isValid(i, j)) {
          if (data[i][j] < m) {
            m = data[i][j];
          }
        }
      }
    }
    return m;
  }

  
  float getTableMax() {
    float m = -bigFloat;
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < columnCount; j++) {
        if (isValid(i, j)) {
          if (data[i][j] > m) {
            m = data[i][j];
          }
        }
      }
    }
    return m;
  }
  
  float getTableMaxRange(int min, int max) {
    float m = -bigFloat;
    for (int i = min; i < max; i++) {
      for (int j = 0; j < columnCount; j++) {
        if (isValid(i, j)) {
          if (data[i][j] > m) {
            m = data[i][j];
          }
        }
      }
    }
    return m;
  }
}
