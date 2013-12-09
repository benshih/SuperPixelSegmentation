/* Xinlei Chen
 * CV Fall 2013 - Provided Code for Simple Linear Iterative Clustering (SLIC)
 * Credit: Andrea Vedaldi, from VLFeat Library
 */

#include <mex.h>
#include <math.h>
#include <string.h>

typedef long long unsigned my_size;
typedef long long my_index;

#define INFINITY_F (0x7F800000UL)
#define atimage(x,y,k) image[(x)+(y)*width+(k)*width*height]
#define atEdgeMap(x,y) edgeMap[(x)+(y)*width]
#define max(x,y) (((x)>(y))?(x):(y))
#define min(x,y) (((x)<(y))?(x):(y))

void slic_segment (int unsigned * segmentation,
                 float const * image,
                 my_size width,
                 my_size height,
                 my_size numChannels,
                 my_size regionSize,
                 float regularization,
                 my_size minRegionSize)
{
  my_index i, x, y, u, v, k, region;
  my_size iter;
  my_size const numRegionsX = (my_size) ceil((double) width / regionSize);
  my_size const numRegionsY = (my_size) ceil((double) height / regionSize);
  my_size const numRegions = numRegionsX * numRegionsY;
  my_size const numPixels = width * height;
  float * centers;
  float * edgeMap;
  float previousEnergy = INFINITY_F;
  float startingEnergy;
  int unsigned * masses;
  my_size const maxNumIterations = 100;

  edgeMap = (float *) mxCalloc(numPixels, sizeof(float));
  masses = (int unsigned *) mxMalloc(sizeof(int unsigned) * numPixels);
  centers = (float *) mxMalloc(sizeof(float) * (2 + numChannels) * numRegions);

  /* compute edge map (gradient strength) */
  for (k = 0; k < (signed)numChannels; ++k) {
    for (y = 1; y < (signed)height-1; ++y) {
      for (x = 1; x < (signed)width-1; ++x) {
        float a = atimage(x-1,y,k);
        float b = atimage(x+1,y,k);
        float c = atimage(x,y+1,k);
        float d = atimage(x,y-1,k);
        atEdgeMap(x,y) += (a - b)  * (a - b) + (c - d) * (c - d);
      }
    }
  }

  /* initialize K-means centers */
  i = 0;
  for (v = 0; v < (signed)numRegionsY; ++v) {
    for (u = 0; u < (signed)numRegionsX; ++u) {
      my_index xp;
      my_index yp;
      my_index centerx;
      my_index centery;
      float minEdgeValue = INFINITY_F;

      x = (my_index) floor(regionSize * (u + 0.5)+0.5F);
      y = (my_index) floor(regionSize * (v + 0.5)+0.5F);

      x = max(min(x, (signed)width-1),0);
      y = max(min(y, (signed)height-1),0);

      /* search in a 3x3 neighbourhood the smallest edge response */
      for (yp = max(0, y-1); yp <= min((signed)height-1, y+1); ++ yp) {
        for (xp = max(0, x-1); xp <= min((signed)width-1, x+1); ++ xp) {
          float thisEdgeValue = atEdgeMap(xp,yp);
          if (thisEdgeValue < minEdgeValue) {
            minEdgeValue = thisEdgeValue;
            centerx = xp;
            centery = yp;
          }
        }
      }

      /* initialize the new center at this location */
      centers[i++] = (float) centerx;
      centers[i++] = (float) centery;
      for (k  = 0; k < (signed)numChannels; ++k) {
        centers[i++] = atimage(centerx,centery,k);
      }
    }
  }

  /* run k-means iterations */
  for (iter = 0; iter < maxNumIterations; ++iter) {
    float factor = regularization / (regionSize * regionSize);
    float energy = 0;

    /* assign pixels to centers */
    for (y = 0; y < (signed)height; ++y) {
      for (x = 0; x < (signed)width; ++x) {
        my_index u = (my_index) floor((double)x / regionSize - 0.5);
        my_index v = (my_index) floor((double)y / regionSize - 0.5);
        my_index up, vp;
        float minDistance = INFINITY_F;

        for (vp = max(0, v); vp <= min((signed)numRegionsY-1, v+1); ++vp) {
          for (up = max(0, u); up <= min((signed)numRegionsX-1, u+1); ++up) {
            my_index region = up  + vp * numRegionsX;
            float centerx = centers[(2 + numChannels) * region + 0] ;
            float centery = centers[(2 + numChannels) * region + 1];
            float spatial = (x - centerx) * (x - centerx) + (y - centery) * (y - centery);
            float appearance = 0;
            float distance;
            for (k = 0; k < (signed)numChannels; ++k) {
              float centerz = centers[(2 + numChannels) * region + k + 2] ;
              float z = atimage(x,y,k);
              appearance += (z - centerz) * (z - centerz);
            }
            distance = appearance + factor * spatial;
            if (minDistance > distance) {
              minDistance = distance;
              segmentation[x + y * width] = (int unsigned)region;
            }
          }
        }
        energy += minDistance;
      }
    }

    /* check energy termination conditions */
    if (iter == 0) {
      startingEnergy = energy;
    } else {
      if ((previousEnergy - energy) < 1e-5 * (startingEnergy - energy)) {
        break;
      }
    }
    previousEnergy = energy;

    /* recompute centers */
    memset(masses, 0, sizeof(int unsigned) * width * height);
    memset(centers, 0, sizeof(float) * (2 + numChannels) * numRegions);

    for (y = 0; y < (signed)height; ++y) {
      for (x = 0; x < (signed)width; ++x) {
        my_index pixel = x + y * width;
        my_index region = segmentation[pixel];
        masses[region] ++;
        centers[region * (2 + numChannels) + 0] += x;
        centers[region * (2 + numChannels) + 1] += y;
        for (k = 0; k < (signed)numChannels; ++k) {
          centers[region * (2 + numChannels) + k + 2] += atimage(x,y,k);
        }
      }
    }

    for (region = 0; region < (signed)numRegions; ++region) {
      float mass = (float) max(masses[region], 1e-8);
      for (i = (2 + numChannels) * region;
           i < (signed)(2 + numChannels) * (region + 1);
           ++i) {
        centers[i] /= mass;
      }
    }
  }

  mxFree(masses);
  mxFree(centers);

  /* elimiate small regions */
  {
    int unsigned * cleaned = (int unsigned *) mxCalloc(numPixels, sizeof(int unsigned));
    my_size * segment = (my_size *) mxMalloc(sizeof(my_size) * numPixels);
    my_size segmentSize;
    int unsigned label;
    int unsigned cleanedLabel;
    my_size numExpanded;
    my_index const dx [] = {+1, -1,  0,  0};
    my_index const dy [] = { 0,  0, +1, -1};
    my_index direction;
    my_index pixel;

    for (pixel = 0; pixel < (signed)numPixels; ++pixel) {
      if (cleaned[pixel]) continue;
      label = segmentation[pixel];
      numExpanded = 0;
      segmentSize = 0;
      segment[segmentSize++] = pixel;

      /*
       find cleanedLabel as the label of an already cleaned
       region neihbour of this pixel
       */
      cleanedLabel = label + 1;
      cleaned[pixel] = label + 1;
      x = pixel % width;
      y = pixel / width;
      for (direction = 0; direction < 4; ++direction) {
        my_index xp = x + dx[direction];
        my_index yp = y + dy[direction];
        my_index neighbor = xp + yp * width;
        if (0 <= xp && xp < (signed)width &&
            0 <= yp && yp < (signed)height &&
            cleaned[neighbor]) {
          cleanedLabel = cleaned[neighbor];
        }
      }

      /* expand the segment */
      while (numExpanded < segmentSize) {
        my_index open = segment[numExpanded++];
        x = open % width;
        y = open / width;
        for (direction = 0; direction < 4; ++direction) {
          my_index xp = x + dx[direction];
          my_index yp = y + dy[direction];
          my_index neighbor = xp + yp * width;
          if (0 <= xp && xp < (signed)width &&
              0 <= yp && yp < (signed)height &&
              cleaned[neighbor] == 0 &&
              segmentation[neighbor] == label) {
            cleaned[neighbor] = label + 1;
            segment[segmentSize++] = neighbor;
          }
        }
      }

      /* change label to cleanedLabel if the semgent is too small */
      if (segmentSize < minRegionSize) {
        while (segmentSize > 0) {
          cleaned[segment[--segmentSize]] = cleanedLabel;
        }
      }
    }
    /* restore base 0 indexing of the regions */
    for (pixel = 0; pixel < (signed)numPixels; ++pixel) cleaned[pixel] --;

    memcpy(segmentation, cleaned, numPixels * sizeof(int unsigned));
    
    mxFree(cleaned);
    mxFree(segment);
  }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) { 
    
    float const * image;
    my_size width;
    my_size height;
    my_size numChannels;
    my_size regionSize;
    float regularizer;
    int unsigned * segmentation;
    int minRegionSize = -1;
  
    if (nrhs != 3)
        mexErrMsgTxt("SLIC: Wrong number of inputs"); 
    if (nlhs != 1)
        mexErrMsgTxt("SLIC: Wrong number of outputs");
    
    if (!mxIsNumeric(prhs[0]) || mxIsComplex(prhs[0])) {
        mexErrMsgTxt("SLIC: IMAGE is not a real matrix.");
    }
    if (mxGetClassID(prhs[0]) != mxSINGLE_CLASS) {
        mexErrMsgTxt("SLIC: IMAGE is not of class SINGLE.");
    }
    image = (const float *) mxGetData(prhs[0]);
    width = mxGetDimensions(prhs[0])[1];
    height = mxGetDimensions(prhs[0])[0];
    if (mxGetNumberOfDimensions(prhs[0]) == 2) {
        numChannels = 1;
    } else {
        numChannels = mxGetDimensions(prhs[0])[2];
    }
    
    regionSize = (my_size) mxGetScalar(prhs[1]);
    if (regionSize < 1) {
        mexErrMsgTxt("REGIONSIZE is smaller than one.");
    }
    
    regularizer = (float) mxGetScalar(prhs[2]);
    if (regularizer < 0) {
        mexErrMsgTxt("REGULARIZER is smaller than zero.");
    }
    
    if (minRegionSize < 0) {
        minRegionSize = (regionSize * regionSize) / (6*6);
    }
    
    plhs[0] = mxCreateNumericMatrix((mwSize)height, (mwSize)width, mxUINT32_CLASS, mxREAL);
    segmentation = (int unsigned *) mxGetData(plhs[0]);
    
    slic_segment(segmentation,
                  image, height, width, numChannels, /* the image is transposed */
                  regionSize, regularizer, minRegionSize);

}
