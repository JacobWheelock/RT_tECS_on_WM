/*
  NeuroStim.h - Library for Controlling the NeuroStim Device.
  Created by Jacob M. Wheelock, April 19, 2022.
*/
#ifndef NeuroStim_h
#define NeuroStim_h

#include "Arduino.h"

class NeuroStim
{
  public:
    // Constructor
    NeuroStim();

    // Stimulator Methods
    void digitalPotWrite(int uVal);                                                           // Method for Communicating with AD7376's
    void serialToWiper();                                                                     // Debugging Method to Send Wiper Values Directly to AD7376's
    void square(float val1, float val2, float freq);                                          // Method to Produce Square Waves
    void pulse(float ampArray[], int timeArray[], int arrSize);                               // Method to Produce Non-Random Rectangular Pulses
    void randPulse(float ampArray[], int arrSize);                                            // Method to Produce Random Rectangular Pulses
    void printCurrent();                                                                      // Method to Set Global Current Var and Print to Serial Line
    void readTimeSeries(float ampArray[], int arrSize, int stepSize);                         // Method to Produce Time Series Waveform
    void sumOfSines(float weights[], int stepSize);                                           // Method to Produce Sum of Sines Waveforms - 6 Fixed Frequencies
    void sumOfSines2(int stepSize);                                                           // Method to Produce Sum of Sines Waveforms - Two Unfixed Frequencies
    void referenceCurrent();                                                                  // Method to Pass Current by Reference
    float zCheck();                                                                           // Method to Check Current Head Impedance
    int setHB(float ampVal, int wiperVal);                                                    // Method to Set H-Bridge Polarities Based on Desired Amplitude (mA)
    void reset();                                                                             // Method to Turn off H-Bridge and Reset Global Vars

    // Global Variables
    int U2SS, currentRead, forward, reverse, FiveVolt, divNow, reader, maxWiper;
    float divMult, resistance, divRead, current, refCurrent, Z;
    unsigned long oldTime, currentTime;
    bool positive, negative;
    String refString;

    // Approximation of Sine is Preferable to Sin() for Speed so a LUT is Used
    float sine_table[91];
    float approxSine(float freq, float t);                                                    // Method to Find Sine Approximation for an Angle [0,90]

};

#endif
