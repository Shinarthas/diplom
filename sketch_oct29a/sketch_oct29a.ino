#include <QList.h>
#include "QList.cpp" 

#include <TimerOne.h>

volatile QList <byte> mySignal;

// This example uses the timer interrupt to blink an LED
// and also demonstrates how to share a variable between
// the interrupt and the main program.


void setup(void)
{
  pinMode(LED_BUILTIN, OUTPUT);
  //Timer1.initialize(100000);// в микросекундах
  Timer1.initialize(10000);// в микросекундах
  Timer1.attachInterrupt(blinkLED); // blinkLED to run every 0.10 seconds
  Serial.begin(9600);
}


// The interrupt will blink the LED, and keep
// track of how many times it has blinked.
int ledState = LOW;
volatile unsigned long blinkCount = 0; // use volatile for shared variables

void blinkLED(void)
{
  if (ledState == LOW) {
    ledState = HIGH;
    blinkCount = blinkCount + 1;  // increase when LED turns on
  } else {
    ledState = LOW;
  }
  digitalWrite(LED_BUILTIN, ledState);
  addItemSignal();
}


// The main program will print the blink count
// to the Arduino Serial Monitor
void loop(void)
{
  QList <byte> signalCopy;  // holds a copy of the mySignal

  // to read a variable which the interrupt code writes, we
  // must temporarily disable interrupts, to be sure it will
  // not change while we are reading.  To minimize the time
  // with interrupts off, just quickly make a copy, and then
  // use the copy while allowing the interrupt to keep working.

  //int m1=millis();
  noInterrupts();
  // тут прочитать стек
  int signalSize=mySignal.size();
  for (int i=0;i<signalSize;i++){
    signalCopy.push_back(mySignal.get(i));
  }
  interrupts();
   //int m2=millis();
  //Serial.println(m2-m1);
  
 /*
  for (int i=0;i<signalSize;i++){
    //Serial.print(signalCopy.get(signalSize-i-1));
    Serial.print(signalCopy.get(i));
    Serial.print(" ");
  }
  */
  Serial.println();
  
  //тут будет DTW
  //Serial.print("num - ");
  //Serial.print(signalCopy.size());
  //int disctance=DTWrun(signalCopy,signalCopy);
  //Serial.print(" distance ");
  //Serial.print(disctance);
  //Serial.println();
}
void addItemSignal(){
  int curSig=analogRead(A0);
  if(curSig>255){
    curSig=255;
  }
  //Serial.println(mySignal.size());
  if (mySignal.size()>150){
    mySignal.pop_back();
  }
  Serial.println(curSig);
  mySignal.push_front((byte)curSig);
}

int DTWrun( QList <byte> &v, QList <byte>  &w ) {
  int cost;
  byte pattern[]={52,17,54,24,62,31,68,34,69,35,66,31,63,28,60,24,60,30,67,32,64,27,63,33,71,41,82,40,70,31,60,23,58,28,68,37,74,45,93,73,121,95,136,104,140,105,138,97,122,72,97,49,78,35,64,27,64,33,76,48,82,47,77,36,65,27,61,25,62,28,68,36,72,35,70,33,66,31,66,30,65,25,59,19,51,13,50,13
};
  int len=sizeof(pattern);
  int mGamma [v.size()+1][len+1];
  for( int i = 1; i <= len; i++ ) {
    mGamma[0][i] = 0;
  }
  for( int i = 1; i <= v.size(); i++ ) {
    mGamma[i][0] = 0;
  }
  mGamma[0][0] = 0;
  
  for( int i = 1; i <= v.size(); i++ ) {
    for( int j = 1; j <= len; j++ ) {
      cost = abs( v.get(i-1) - pattern[j-1] ) * abs(v.get(i-1)- pattern[j-1] );
      mGamma[i][j] = cost + min( mGamma[i-1][j], min(mGamma[i][j-1], mGamma[i-1][j-1]) );
    }
  }
  
  
  return mGamma[v.size()][len];
}


