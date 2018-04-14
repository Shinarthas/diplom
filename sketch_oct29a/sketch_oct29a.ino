#include <QList.h>
//#include "QList.cpp" 

#include <TimerOne.h>
float koefDTW=1;
volatile QList <byte> mySignal;

int d11=11;
// This example uses the timer interrupt to blink an LED
// and also demonstrates how to share a variable between
// the interrupt and the main program.


void setup(void)
{
  pinMode(d11, OUTPUT);
  pinMode(8, OUTPUT);
  pinMode(7, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  //Timer1.initialize(100000);// в микросекундах
  Timer1.initialize(50000);// в микросекундах
  Timer1.attachInterrupt(blinkLED); // blinkLED to run every 0.10 seconds
  Serial.begin(9600);
}


// The interrupt will blink the LED, and keep
// track of how many times it has blinked.
int ledState = LOW;

void blinkLED(void)
{
  if (ledState == LOW) {
    ledState = HIGH;
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
 
  //тут будет DTW
  int disctance=DTWrun(signalCopy);
  if (disctance>0 && disctance<500){koefDTW+=0.1;}
  if (disctance<0 && disctance>-500){koefDTW-=0.1;}
  if(koefDTW<0.1){koefDTW=0.1;}
  if(koefDTW>2){koefDTW=1.9;}
  //Serial.print(" distance ");
  //Serial.print(disctance);
  //Serial.println();
  signalCopy.clear();
  //delete &signalCopy;
}

void addItemSignal(){
  int curSig=analogRead(A0);
  if(curSig>255){
    curSig=255;
  }
  float Rdist=analogRead(A1)/1023.0;
  Serial.println(curSig);
  if(curSig>50){analogWrite(d11, curSig*Rdist*koefDTW);}
  if(curSig>0 && curSig<50){digitalWrite(8, ledState);}
  if(curSig>50 && curSig<150){analogWrite(7, curSig*Rdist*3*koefDTW);}
  //Serial.println(mySignal.size());
  while (mySignal.size()>=70){
   mySignal.pop_back();
  }
  //Serial.println(mySignal.size());
  
  mySignal.push_front((byte)curSig);
}

int DTWrun( QList <byte> &v) {
  int cost=0;
  byte pattern[]={52,17,54,24,62,31,68,34,69,35,66,31,63,28,60,24,60,30,67,32,64,27,63,33,71,41,82,40,70,31,60,23,58,28,68,37,74,45,93,73,121,95,136,104,140,105,138,97,122,72,97,49,78,35,64,27,64,33,76,48,82,47,77,36,65,27,61,25,62,28,68,36,72,35,70,33,66,31,66,30,65,25,59,19,51,13,50,13
  };
  if(v.size()<10){Serial.println(v.size()); return 9999;}
  //Serial.println("here");
  
  int len=sizeof(pattern);
  int mGamma [2][v.size()+1];
  for( int i = 1; i <= v.size(); i++ ) {
    mGamma[0][i] = 0;
    mGamma[1][i] = 0;
  }
  mGamma[0][0] = 0;
  mGamma[1][0] = 0;

  for (int j=1; j<len; j++){
    for(int i=1; i<=v.size();i++){
      cost = abs( v.get(i-1) - pattern[j-1] ) * abs(v.get(i-1)- pattern[j-1] );
      mGamma[1][i] = cost + min( mGamma[0][i-1], min(mGamma[0][i], mGamma[0][i-1]) );
    }
    for( int i = 0; i <= v.size(); i++  ) {
      mGamma[0][i] = mGamma[1][i];
      //Serial.println("wtf2");
    }
  }
  //Serial.println(mGamma[1][v.size()]);
  return mGamma[1][v.size()];
}


