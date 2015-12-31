//****************************************************************************************************************************************
// Quicksort
// Lifted from here: http://www.vogella.com/tutorials/JavaAlgorithmsQuicksort/article.html
// Because if I wasn't writing for Processing.js I'd just use Arrays.sort()
//****************************************************************************************************************************************

public class Quicksort  {
  private float[] numbers;
  private int number;
  private float pivot;

  Quicksort() { }
  
  public void sort(float[] values) {
    // Check for empty or null array
    if (values == null || values.length==0){
      return;
    }
    numbers = values;
    number = values.length;
    quicksort(0, number - 1);
  }

  private void quicksort(int low, int high) {
    int i = low, j = high;
    // Get the pivot element from the middle of the list
    pivot = numbers[low + (high-low)/2];

    // Divide into two lists
    while (i <= j) {
      // If the current value from the left list is smaller then the pivot
      // element then get the next element from the left list
      while (numbers[i] < pivot) {
        i++;
      }
      // If the current value from the right list is larger then the pivot
      // element then get the next element from the right list
      while (numbers[j] > pivot) {
        j--;
      }

      // If we have found a values in the left list which is larger then
      // the pivot element and if we have found a value in the right list
      // which is smaller then the pivot element then we exchange the
      // values.
      // As we are done we can increase i and j
      if (i <= j) {
        exchange(i, j);
        i++;
        j--;
      }
    }
    // Recursion
    if (low < j)
      quicksort(low, j);
    if (i < high)
      quicksort(i, high);
  }

  private void exchange(int i, int j) {
    float temp = numbers[i];
    numbers[i] = numbers[j];
    numbers[j] = temp;
  }

  float getPivot() {
    float median = numbers[floor((numbers.length) / 2)];
    return median;
  }

  float getQ1() {
    float q1 = numbers[floor((numbers.length) / 4)];
    return q1;
  }

  float getQ3() {
    float median = numbers[floor(3 * (numbers.length) / 4)];
    return median;
  }
} 
