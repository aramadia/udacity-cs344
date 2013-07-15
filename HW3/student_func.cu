/* Udacity Homework 3
   HDR Tone-mapping

  Background HDR
  ==============

  A High Definition Range (HDR) image contains a wider variation of intensity
  and color than is allowed by the RGB format with 1 byte per channel that we
  have used in the previous assignment.  

  To store this extra information we use single precision floating point for
  each channel.  This allows for an extremely wide range of intensity values.

  In the image for this assignment, the inside of church with light coming in
  through stained glass windows, the raw input floating point values for the
  channels range from 0 to 275.  But the mean is .41 and 98% of the values are
  less than 3!  This means that certain areas (the windows) are extremely bright
  compared to everywhere else.  If we linearly map this [0-275] range into the
  [0-255] range that we have been using then most values will be mapped to zero!
  The only thing we will be able to see are the very brightest areas - the
  windows - everything else will appear pitch black.

  The problem is that although we have cameras capable of recording the wide
  range of intensity that exists in the real world our monitors are not capable
  of displaying them.  Our eyes are also quite capable of observing a much wider
  range of intensities than our image formats / monitors are capable of
  displaying.

  Tone-mapping is a process that transforms the intensities in the image so that
  the brightest values aren't nearly so far away from the mean.  That way when
  we transform the values into [0-255] we can actually see the entire image.
  There are many ways to perform this process and it is as much an art as a
  science - there is no single "right" answer.  In this homework we will
  implement one possible technique.

  Background Chrominance-Luminance
  ================================

  The RGB space that we have been using to represent images can be thought of as
  one possible set of axes spanning a three dimensional space of color.  We
  sometimes choose other axes to represent this space because they make certain
  operations more convenient.

  Another possible way of representing a color image is to separate the color
  information (chromaticity) from the brightness information.  There are
  multiple different methods for doing this - a common one during the analog
  television days was known as Chrominance-Luminance or YUV.

  We choose to represent the image in this way so that we can remap only the
  intensity channel and then recombine the new intensity values with the color
  information to form the final image.

  Old TV signals used to be transmitted in this way so that black & white
  televisions could display the luminance channel while color televisions would
  display all three of the channels.
  

  Tone-mapping
  ============

  In this assignment we are going to transform the luminance channel (actually
  the log of the luminance, but this is unimportant for the parts of the
  algorithm that you will be implementing) by compressing its range to [0, 1].
  To do this we need the cumulative distribution of the luminance values.

  Example
  -------

  input : [2 4 3 3 1 7 4 5 7 0 9 4 3 2]
  min / max / range: 0 / 9 / 9

[0 1 2 2 3 3]

  histo with 3 bins: [4 7 3]

  cdf : [4 11 14]


  Your task is to calculate this cumulative distribution by following these
  steps.

*/

#include "utils.h"
using namespace std;

float *d_minWorking;

// Reduce to get the min value
__global__
void minReduce(float* const d_values, 
              const size_t numCells)
{
  //
  int x = threadIdx.x;

  int s = 1;
  
  for (int numLeft = numCells; numLeft > 1; s*=2)
  {
    if (x % s == 0 && x + s < numCells)
    {
      d_values[x] = min(d_values[x], d_values[x + s]);
    }
    if (numLeft % 2 == 0) 
    {
      numLeft /= 2;
    }
    else
    {
      numLeft = (numLeft + 1)/2;
    }

    // wait for all threads to finish adding
    __syncthreads();
  }

  // result should be in d_values[0];
}

void your_histogram_and_prefixsum(const float* const d_logLuminance,
                                  unsigned int* const d_cdf,
                                  float &min_logLum,
                                  float &max_logLum,
                                  const size_t numRows,
                                  const size_t numCols,
                                  const size_t numBins)
{
  //TODO
  /*Here are the steps you need to implement
    1) find the minimum and maximum value in the input logLuminance channel
       store in min_logLum and max_logLum
    2) subtract them to find the range
    3) generate a histogram of all the values in the logLuminance channel using
       the formula: bin = (lum[i] - lumMin) / lumRange * numBins
    4) Perform an exclusive scan (prefix sum) on the histogram to get
       the cumulative distribution of luminance values (this should go in the
       incoming d_cdf pointer which already has been allocated for you)       */



  int i = 0;

  cout << "HELP ME\n";

  // calculate the pixel coordinate for this thread
  float value = d_logLuminance[0];

  // allocate second float array of numRows * numCols

  // do a min reduction op
  int curCells = numRows * numCols;

  checkCudaErrors(cudaMalloc(&d_minWorking, sizeof(float) * curCells));


  // create array
  float testArray[] = {4,3,26,21,25,3,6,15,10,3,5,6,7};
  int numCells = sizeof(testArray)/sizeof(float);
  cout << "TestArray cells: " << numCells << endl;

  // copy array


  checkCudaErrors(cudaMemcpy(d_minWorking, testArray, 
    sizeof(testArray), cudaMemcpyHostToDevice));

  // gridSize, blockSize
  minReduce<<<1, numCells>>>(d_minWorking, numCells);


  checkCudaErrors(cudaMemcpy(testArray, d_minWorking, 
    sizeof(testArray), cudaMemcpyDeviceToHost));

  cout << "Output should be 2\n";
  cout << "Output is " << testArray[0] << endl;

}

