#include <SPI.h>
#include "NeuroStim.h"

NeuroStim stim = NeuroStim();
String mode = "";
int timeArr[125];
float ampArr[125];
float weights[6];


void setup() {
  Serial.begin(115200);
  SPI.begin();
  SPI.setBitOrder(MSBFIRST);    //  MSB to be sent first
  SPI.setDataMode(SPI_MODE3);   //  Set for clock rising edge
  SPI.setClockDivider(21);      // Set for 4MHz Clock Speed (Clocking Speed for DigiPot)

}

void loop() {
  stim.reset();                                   // Reset After Every Function Use
  Serial.println("Enter Operation Mode:");
  while (Serial.available() == 0) {}
  mode = Serial.readStringUntil('\n');

  // Reference Current Operation
  if (mode.equals("reference")) {
    stim.referenceCurrent();
  }

  // Square Pulse Operation
  else if (mode.equals("square")) {

    Serial.println("Enter Low Current (mA)");
    while (Serial.available() == 0) {}
    float low = Serial.readStringUntil('\n').toFloat();
    int ex = Serial.read();
    Serial.println("Enter High Current (mA)");
    while (Serial.available() == 0) {}
    float high = Serial.readStringUntil('\n').toFloat();
    ex = Serial.read();
    Serial.println("Enter Frequency (Hz)");
    while (Serial.available() == 0) {}
    float freq = Serial.readStringUntil('\n').toFloat();
    ex = Serial.read();

    stim.square(low, high, freq);

  }

  // Rectangular Pulse Operation
  else if (mode.equals("pulse")) {
    Serial.println("Enter Number of Pulses:");
    while (Serial.available() == 0) {}
    int sizeArr = Serial.readStringUntil('\n').toInt();
    int ex = Serial.read();

    for (int i = 0; i < sizeArr; i++) {
      Serial.print("Enter Pulse Amplitude ");
      Serial.println(i + 1);
      while (Serial.available() == 0) {}
      ampArr[i] = Serial.readStringUntil('\n').toFloat();
      int ex = Serial.read();

      Serial.print("Enter Pulse Time ");
      Serial.print(i + 1);
      Serial.println(" (ms)");
      while (Serial.available() == 0) {}
      timeArr[i] = Serial.readStringUntil('\n').toInt();
      ex = Serial.read();
    }

    stim.pulse(ampArr, timeArr, sizeArr);
  }

  // Random Rectangular Pulse Operation
  else if (mode.equals("randPulse")) {
    Serial.println("Enter Number of Pulses:");
    while (Serial.available() == 0) {}
    int sizeArr = Serial.readStringUntil('\n').toInt();
    sizeArr++;
    int ex = Serial.read();
    for (int i = 0; i < sizeArr; i++) {
      Serial.print("Enter Pulse Amplitude ");
      Serial.println(i + 1);
      while (Serial.available() == 0) {}
      ampArr[i] = Serial.readStringUntil('\n').toFloat();
      int ex = Serial.read();
    }

    stim.randPulse(ampArr, sizeArr);
  }

  // Time Series Operation
  else if (mode.equals("series")) {
    float amp = 0.0; int ex = 0;
    Serial.println("Enter Series Length:");
    while (!Serial.available()) {}
    int seriesSize = Serial.readStringUntil('\n').toInt();
    ex = Serial.read();
    for (int i = 0; i < seriesSize; i++) {
      while (Serial.available() == 0) {}
      amp = Serial.readStringUntil('\n').toFloat();
      ex = Serial.read();
      ampArr[i] = amp;
    }

    int stepSize = 1;
    stim.readTimeSeries(ampArr, seriesSize, stepSize);
  }

  // Sum of Sines Operation (Work in Progress)
  else if (mode.equals("sumOfSines")) {
    weights[0] = 1; weights[1] = 0; weights[2] = 0; weights[3] = 0; weights[4] = 0; weights[5] = 1;
    stim.sumOfSines(weights, 1);
  }

  else if (mode.equals("sumOfSines2")) {
    stim.sumOfSines2(1);
  }

  mode = "";

}
