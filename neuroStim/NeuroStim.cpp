/*
  NeuroStim.cpp - Library for Controlling the NeuroStim.
  Created by Jacob M. Wheelock, April 19, 2022.
*/


#include "Arduino.h"
#include "NeuroStim.h"
#include <SPI.h>

// Constructor for NeuroStim Object
NeuroStim::NeuroStim()
{
  U2SS = 7; currentRead = A6; forward = 6; reverse = 5; FiveVolt = 2; // Set Pins
  divMult = 5.0 / 1024.0; resistance = 1000.0;                        // Set Float Constants
  divRead = 0.0; current = 0.0; refCurrent = 0.0; Z = 0.0;            // Initialize Floats
  divNow = 254; reader = 0; maxWiper = 254;                           // Initialize Ints
  oldTime = 0; currentTime = 0;                                       // Initialize Time
  positive = false; negative = false;                                 // Initialize Bools

  for (int i = 0; i < 91; i++) {                                      // Populate Sine LUT
    sine_table[i] = sin(3.14159 *  (float) i / 180.0);
  }

  pinMode(SS, OUTPUT);                                                // Unit 1 SS Pin: Output Mode
  pinMode(U2SS, OUTPUT);                                              // Unit 2 SS Pin: Output Mode
  pinMode(SCK, OUTPUT);                                               // Clock Pin:  Output Mode
  pinMode(MOSI, OUTPUT);                                              // SPI Data Pin: Output Mode
  pinMode(forward, OUTPUT);                                           // H-Bridge Forward Path Pin: Output Mode
  pinMode(reverse, OUTPUT);                                           // H-Bridge Reverse Path Pin: Output Mode
  digitalWrite(FiveVolt, HIGH);                                       // 5-Volt Supply Pin On
  reset();                                                            // Set H-Bridge Path to OFF
}

// Set uVal from 0 to maxWiper to scale the resistance value of the digiPots. Each division corresponds to roughly 781.25 Ohms.
void NeuroStim::digitalPotWrite(int uVal)
{
  uVal = (uVal - maxWiper) * -1;                                      // Using the A terminal gives you complementary resistance so use complement of value desired
  int U1 = (uVal > 127) ? (uVal - 127) : 0;                           // Set division value of unit 1
  int U2 = (uVal > 127) ? 127 : uVal;                                 // Set division value of unit 2
  SPI.beginTransaction(SPISettings(4000000, MSBFIRST, SPI_MODE3));    // Begin SPI Transaction
  digitalWrite(U2SS, LOW);                                            // Raise !SS for Unit 2
  SPI.transfer(U2);                                                   // Send Wiper Data to Unit 2
  digitalWrite(U2SS, HIGH);                                           // Lower !SS for Unit 2
  digitalWrite(SS, LOW);                                              // Raise !SS for Unit 1
  SPI.transfer(U1);                                                   // Send Wiper Data to Unit 1
  digitalWrite(SS, HIGH);                                             // Lower !SS for Unit 1
  SPI.endTransaction();                                               // End SPI Transaction: Wipers Have Been Set to Desired Position

}

// Read Serial Int and Push it to Wiper Value -- Debugging Function
void NeuroStim::serialToWiper()
{
  reader = Serial.parseInt();                                         // Read Int From Serial Line
  int ex = Serial.read();                                             // Throw Away Garbage
  digitalPotWrite(reader);                                            // Set DigiPot
  printCurrent();                                                     // Read and Print Current
}

// Create Square Wave Using 2 Current References (mA) and a Frequency Value (Hz)
void NeuroStim::square(float val1, float val2, float freq)
{
  bool R1 = LOW; bool R2 = LOW;                                       // Initialize H-Bridge Parameters
  bool F1 = HIGH; bool F2 = HIGH;
  int wiperL; int wiperH;                                             // Initialize Wiper Values

  float delayTime = (1000000.0 / freq) / 2.0;                         // Calculate Delta-Timing Spacing
  float delayTimeFull = delayTime * 2.0;
  long tNaught1 = micros();                                           // Initialize Timing Values
  long tNaught2 = tNaught1 + delayTime;
  long currentTime = micros();
  String ender = "";

  // Convert mA Values to Wiper Values Based on Head Impedance
  float Z = zCheck();

  wiperL = (int) ((255.0 / 200000.0) * ((27.0 / (abs(val1) * 0.001)) - 1000.0 - Z));
  wiperH = (int) ((255.0 / 200000.0) * ((27.0 / (abs(val2) * 0.001)) - 1000.0 - Z));

  // Set Polarities for H-Bridge
  if (val1 < 0) {
    R1 = HIGH; F1 = LOW;
  }
  if (val2 < 0) {
    R2 = HIGH; F2 = LOW;
  }
  if (val1 == 0) {
    F1 = LOW;
  }
  if (val2 == 0) {
    F2 = LOW;
  }

  // Main Loop
  while (true) {
    currentTime = micros();

    if (currentTime >= tNaught1 + delayTime) {                          // If Time for Val1
      digitalWrite(reverse, R1);                                        // Set H-Bridge
      digitalWrite(forward, F1);
      positive = F1; negative = R1;
      digitalPotWrite(wiperL);                                          // Write to DigiPots
      printCurrent();                                                   // Set and Print Current
      tNaught1 = tNaught1 + delayTimeFull;                              // Update Delta Timing

      if (Serial.available()) {                                         // End Mode if "end" is Passed to Serial Line
        ender = Serial.readString();
        if (ender.equals("end\n")) break;
      }

    }
    if (currentTime >= tNaught2 + delayTime) {                          // If Time for Val2
      digitalWrite(reverse, R2);                                        // Set H-Bridge
      digitalWrite(forward, F2);
      positive = F2; negative = R2;
      digitalPotWrite(wiperH);                                          // Write to DigiPots
      printCurrent();                                                   // Set and Print Current
      tNaught2 = tNaught2 + delayTimeFull;                              // Update Delta Timing

      if (Serial.available()) {                                         // End Mode if "end" is Passed to Serial Line
        ender = Serial.readStringUntil('\n');
        if (ender.equals("end")) break;

      }
    }

  }
}

// Create Periodic Rectangular Pulses Given Amplitude Array (mA), an Array to Store Wiper Values, a Time Array (ms) and the Size of the Arrays
void NeuroStim::pulse(float ampArray[], int timeArray[], int arrSize)
{
  long currentTime = millis();                                          // Initialize Time Value
  Z = zCheck();                                                         // Find Head Impedance

  // Main Loop
  while (true) {
    for (int i = 0; i < arrSize; i++) {
      int writer = (int) min(254, ((255.0 / 200000.0) * ((27.0 / (abs(ampArray[i]) * 0.001)) - 1000.0 - Z)));
      if (ampArray[i] < 0) writer = -writer;
      if (ampArray[i] == 0) writer = 0;
      writer = setHB(ampArray[i], writer);                              // Set H-Bridge Parameters
      digitalPotWrite(writer);                                          // Write to DigiPots

      currentTime = millis();                                           // Delta Timing
      long newTime = currentTime + timeArray[i];
      while (millis() < newTime) {
        printCurrent();
      }
    }

    if (Serial.available()) {                                           // Exit Mode if "end" is Passed Through Serial Line
      String ender = Serial.readStringUntil('\n');
      if (ender.equals("end")) break;
    }
  }
}

// Create Random Rectangular Pulses Given an Array of Possible Amplitudes (mA), an Array to Store Wiper Values and the Size of the Arrays
void NeuroStim::randPulse(float ampArray[], int arrSize)
{
  long currentTime = millis();                                          // Initialize Timing
  long sample = millis();
  int ampTemp; int timeTemp;                                            // Initialize Temporary Vars
  int i = 0; int j = 0;                                                 // Initialize Counters

  Z = zCheck();                                                         // Find Head Impedance

  // Main Loop
  while (true) {
    if (i % 2 == 0) {                                                   // Half the Time, Amplitude is 0, Timing is Random
      ampTemp = 0;
      timeTemp = 1000 + random(501);
      i++;
      j = arrSize;
    }
    else {
      j = random(0, arrSize - 1);
      ampTemp = (int) min(254, ((255.0 / 200000.0) * ((27.0 / (abs(ampArray[j]) * 0.001)) - 1000.0 - Z)));  // Half the Time, Amplitude is Random, Timing is Either 25 or 100 ms
      if (ampArray[j] < 0) ampTemp = -ampTemp;

      timeTemp = random(0, 2);
      if (timeTemp == 0) {
        timeTemp = 25;
      }
      else {
        timeTemp = 100;
      }
      i++;
    }

    int writer = setHB(ampArray[j], ampTemp);                            // Set H-Bridge Parameters
    digitalPotWrite(writer);                                             // Write to DigiPots

    currentTime = millis();                                              // Delta Timing
    long newTime = currentTime + timeTemp;

    while (millis() < newTime) {

      if (sample != millis()) {                                          // Print Current Every 1 ms
        printCurrent();
        sample = millis();
      }
    }

    if (Serial.available()) {
      String ender = Serial.readStringUntil('\n');
      if (ender.equals("end")) break;                                 // Exit Mode if "end" is Passed Through Serial Line
    }
  }
}

// Set Global Current Var and Print Current to Serial Line
void NeuroStim::printCurrent()
{
  divRead = analogRead(currentRead);                                    // Read Current Through On-Board ADC
  current = ((divRead * divMult) / resistance) * 1000;                  // Convert Digital Value to Analog
  if (negative == false) Serial.print(current);                         // Print Based on H-Bridge Polarity
  if (negative == true) {
    Serial.print("-");
    Serial.print(current);
  }
  Serial.println(" mA");
}


// Create Arbitrary Waveform Given an Amplitude Time Series (mA), an Array to Store Wiper Values, the Size of the Arrays and the Time Step Size
void NeuroStim::readTimeSeries(float ampArray[], int arrSize, int stepSize)
{
  long currentTime = millis();                                          // Initialize Timing Values
  long newTime;
  int writer;                                                           // Initialize H-Bridge Parameter

  Z = zCheck();                                                         // Find Head Impedance

  // Main Loop
  while (true) {

    for (int i = 0; i < arrSize; i++) {
      currentTime = millis();                                           // Set Delta Timing
      newTime = currentTime + stepSize;

      writer = (int) min(((255.0 / 200000.0) * ((27.0 / (abs(ampArray[i]) * 0.001)) - 1000.0 - Z)), 254);
      if (ampArray[i] < 0) writer = -writer;
      if (abs(ampArray[i]) == 0) writer = 0;

      writer = setHB(ampArray[i], writer);                              // Set H-Bridge

      digitalPotWrite(writer);                                          // Write to DigiPots

      while (millis() < newTime) {                                      // Delta Timing
        printCurrent();
      }
    }

    if (Serial.available()) {                                           // Exit Mode if "end" is Passed Through Serial Line
      String ender = Serial.readStringUntil('\n');
      if (ender.equals("end")) break;
    }
  }
}

// Create Sum of Sines Waveform Based on Weights for Each Frequency (3-18 Hz in Steps of 3 Hz)
void NeuroStim::sumOfSines(float weights[], int stepSize)
{
  long currentTime = micros();                                          // Initialize Timing
  float currentSec;
  long newTime;
  int writer; float amp; int weightVal; int weightInd;                  // Initialize Temporary Weights

  Z = zCheck();                                                         // Find Head Impendance

  // Main Loop
  while (true) {

    currentTime = millis();                                             // Set Delta Timing
    currentSec = (float) currentTime * 0.001;
    newTime = currentTime + stepSize;

    // Find Current Amplitude Based on Sine Approximations
    amp = weights[0] * approxSine(3.0, currentSec) + weights[1] * approxSine(6.0, currentSec)
          + weights[2] * approxSine(9.0, currentSec) + weights[3] * approxSine(12.0, currentSec)
          + weights[4] * approxSine(15.0, currentSec) + weights[5] * approxSine(18.0, currentSec);

    writer = (int) min(((255.0 / 200000.0) * ((27.0 / (abs(amp) * 0.001)) - 1000.0 - Z)), 254);
    if (amp < 0) writer = -writer;
    if (amp == 0) writer = 0;

    writer = setHB(amp, writer);                                        // Set H-Bridge


    digitalPotWrite(writer);                                            // Write to DigiPots
    while (millis() < newTime) {                                        // Delta Timing
      printCurrent();

    }

    if (Serial.available()) {
      String ender = Serial.readStringUntil('\n');
      if (ender.equals("end")) break;                                   // End Mode if "end" is Passed Through Serial Line
      else {                                                            // Otherwise Assume a New Weight is Being Passed
        weightVal = ender.toInt();
        weightInd = weightVal >> 8;
        weightVal = weightVal & 0x00FF;

        weights[weightInd] = (float) weightVal / 128.0;

      }
    }

  }
}

void NeuroStim::sumOfSines2(int stepSize)
{
  unsigned long currentTime = micros();                                          // Initialize Timing
  float currentSec;
  unsigned long newTime;
  int writer; float amp;
  unsigned long newWeight,  timing;                                             // Initialize Temporary Weights
  unsigned long delay1; unsigned long delay2;
  float t1, t2, weight0, freq0, weight1, freq1;

  Z = zCheck();                                                                 // Find Head Impedance

  while (!Serial.available());

  // Main Loop
  while (true) {

    digitalWrite(reverse, LOW);
    digitalWrite(forward, LOW);

    while (!Serial.available()) {};

    newWeight = Serial.readStringUntil('\n').toInt();
    timing = Serial.readStringUntil('\n').toInt();
    if (newWeight == -1) break;                                             // End Mode if -1 is Passed Through Serial Line
    else {                                                                  // Otherwise Assume a New Weight is Being Passed
      weight0 = 2.0 * float(newWeight & 0x000000FF) / 255.0;
      freq0 = 30.0 * float((newWeight >> 8) & 0x000000FF) / 255.0;
      weight1 = 2.0 * float((newWeight >> 16) & 0x000000FF) / 255.0;
      freq1 = 30.0 * float(newWeight >> 24) / 255.0;
      t1 = 10000.0 * float(timing & 0x0000FFFF) / 65535.0;
      t2 = 10000.0 * float(timing >> 16) / 65535.0;
    }


    delay1 = millis() + t1;                                                 // Set Delta Timing for t1
    while (millis() < delay1) {
      printCurrent();
    }

    delay2 = millis() + t2;                                                 // Set Delta Timing for t2

    while (millis() < delay2) {
      currentTime = millis();
      currentSec = (float) currentTime * 0.001;
      float mult = 2 * PI * currentSec;
      newTime = currentTime + stepSize;

      // Find Current Amplitude Based on Sum of Sines
      amp = weight0 * sin(mult * freq0) + weight1 * sin(mult * freq1);

      writer = (int) min(((255.0 / 200000.0) * ((27.0 / (abs(amp) * 0.001)) - 1000.0 - Z)), 254);
      if (amp < 0) writer = -writer;
      if (amp == 0) writer = 0;

      writer = setHB(amp, writer);                                        // Set H-Bridge

      digitalPotWrite(writer);                                            // Write to DigiPots
      while (millis() < newTime) {                                        // Delta Timing
        printCurrent();

      }

    }
    Serial.println("d");

  }
}



void NeuroStim::referenceCurrent()
{
  currentTime = millis();
  oldTime = currentTime;
  while (true) {

    currentTime = millis();
    printCurrent();                                                   // Read current Every Loop
    if (current > 2.3) {                                              // If a short occurs, pump resistance and require a restart
      reset();
      while (true) {
        Serial.println("Short Detected - Please Resolve and Restart");
      }
    }


    if (Serial.available()) {                                         // Set Reference Current if Available
      refCurrent = Serial.readStringUntil('\n').toFloat();
      Serial.println(refCurrent);
      int ex = Serial.read();

      if (refCurrent > 0 && positive == false) {
        digitalWrite(reverse, LOW);
        digitalWrite(forward, HIGH);
        positive = true; negative = false;
      }
      if (refCurrent < 0) {
        if (negative == false) {
          digitalWrite(forward, LOW);
          digitalWrite(reverse, HIGH);
          positive = false; negative = true;
        }
        refCurrent = -refCurrent;
      }
      if (refCurrent == 0) {
        digitalPotWrite(maxWiper);
        divNow = maxWiper;
        digitalWrite(forward, LOW);
        digitalWrite(reverse, LOW);
        positive = false; negative = false;

      }
      if (refCurrent == 1000) {
        break;
      }
    }

    if (currentTime >= oldTime + 1) {                                                           // Delta Timing Every 1 ms
      if (refCurrent > (current + 0.10) && divNow > 0 && current <= 2 && refCurrent <= 2) {     // If Reference > Current, Decrease Resistance (Do not exceed 2mA)
        divNow -= 1;
        digitalPotWrite(divNow);
      }
      else if (refCurrent < (current - 0.10) && divNow < maxWiper || current > 2.05) {               // If Reference < Current, Increase Resistance
        divNow += 1;
        digitalPotWrite(divNow);
      }
      oldTime = currentTime;
    }

  }
}

void NeuroStim::reset()
{
  digitalWrite(forward, LOW);
  digitalWrite(reverse, LOW);
  positive = false;
  negative = false;
  digitalPotWrite(maxWiper); divNow = maxWiper;
}

float NeuroStim::approxSine(float freq, float t) {
  // Find Angle and Normalize to [0,90] Degrees
  double angle = 360.0 * freq * t;
  angle = fmod(angle, 360.0);
  if (angle < 0.0) angle += 360;
  int ind = floor(angle);

  if (ind >= 0 && ind <= 90) return sine_table[ind];
  else if (ind > 90 && ind <= 180) return sine_table[90 - (ind - 90)];
  else if (ind > 180 && ind <= 270) return -sine_table[ind - 180];
  else return -sine_table[90 - (ind - 270)];
}

float NeuroStim::zCheck() {
  digitalWrite(forward, HIGH); digitalWrite(reverse, LOW);
  digitalPotWrite(20);
  delay(1000);
  printCurrent();
  digitalWrite(forward, LOW); digitalWrite(reverse, LOW);
  return (27.0 / (current * 0.001)) - 1000.0 - ((200000.0 / 255.0) * 20.0);
}


int NeuroStim::setHB(float ampVal, int wiperVal) {
  if (ampVal < 0) {
    digitalWrite(forward, LOW);
    digitalWrite(reverse, HIGH);
    negative = true; positive = false;
    return -wiperVal;
  }
  else if (ampVal == 0) {
    digitalWrite(reverse, LOW);
    digitalWrite(forward, LOW);
    return 254;
  }
  else {
    digitalWrite(reverse, LOW);
    digitalWrite(forward, HIGH);
    positive = true; negative = false;
    return wiperVal;
  }
}
