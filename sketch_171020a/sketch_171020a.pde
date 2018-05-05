import processing.serial.*;
import controlP5.*;
import java.util.*;
float pattern[]={52,17,54,24,62,31,68,34,69,35,66,31,63,28,60,24,60,30,67,32,64,27,63,33,71,41,82,40,70,31,60,23,58,28,68,37,74,45,93,73,121,95,136,104,140,105,138,97,122,72,97,49,78,35,64,27,64,33,76,48,82,47,77,36,65,27,61,25,62,28,68,36,72,35,70,33,66,31,66,30,65,25,59,19,51,13,50,13};
ControlP5 cp5;
Chart myChart, meanChart;
Slider frequency;
Button savebtn,clearbtn,modebtn;
PFont font,font2;

Serial mySerial;
PrintWriter output;

LinkedList<Integer> signal = new LinkedList<Integer>();
LinkedList<Integer> boof = new LinkedList<Integer>();

//constolls
int startPoint=0,endPoint=0;
int switcher=140;
int i=30;
int counter=30;
boolean tr=true;

public static Integer tryParse(String text) {
  try {
    return Integer.parseInt(trim(text));
  } catch (NumberFormatException e) {
    return 0;
  }
}
void setup() {
  
   mySerial = new Serial( this, Serial.list()[1], 9600 );
   output = createWriter( "data.txt" );
   mySerial.setDTR(false);
   mySerial.setDTR(true);
   size(800,500);
   frameRate(30);
   cp5 = new ControlP5(this);
   smooth();
   font=createFont("calibri light bold",20);
    savebtn=cp5.addButton("Save")
  .setPosition(10, 10)
  .setSize(280, 50)
  .setFont(font);
  
   clearbtn=cp5.addButton("Clear")
  .setPosition(10, 70)
  .setSize(280, 50)
  .setFont(font);
  
  clearbtn=cp5.addButton("Mode")
  .setPosition(10, 130)
  .setSize(280, 50)
  .setFont(font);
  
  frequency=cp5.addSlider("")
    .setPosition(10, 190)
    .setSize(280, 100)
    .setRange(1,5)
    .setValueLabel("")
    .setFont(font);
    
    textSize(20);
    text("Frequency", 10, 300);
    myChart = cp5.addChart("PULSEWAVE SIGNAL AND DTW DISTNACE")
               .setPosition(300, 10)
               .setSize(490, 200)
               .setRange(0, 255)
               .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
               .setFont(font);

  myChart.getColor().setBackground(color(255, 100));


  myChart.addDataSet("signal");
  myChart.setColors("signal", color(255,0,255),color(255,0,0));
  myChart.setData("signal", new float[500]);

  myChart.setStrokeWeight(2);

  myChart.addDataSet("earth");
  myChart.setColors("earth", color(255), color(0, 255, 0));
  myChart.updateData("earth", new float[500]);
  
  
  meanChart = cp5.addChart("R analysis")
               .setPosition(300, 240)
               .setSize(490, 200)
               .setRange(0, 200)
               .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
               .setFont(font);

  meanChart.getColor().setBackground(color(255, 100));

  meanChart.setStrokeWeight(3);

  meanChart.addDataSet("R");
  meanChart.setColors("R", color(255,0,0), color(0, 255, 0));
  meanChart.updateData("R", pattern);
  
  
}
void draw() {
    background(200);
    //fill(30);
    textSize(20);
    text("Frequency", 50, 320);
    if (mySerial.available() > 0 ) {
         String value = mySerial.readString();
         if ( value != null ) {
           int foo = tryParse(value);
           int len=signal.size();
           if(len>10){
             foo=Math.round(foo*0.3+signal.get(len-1)*0.1+signal.get(len-2)*0.1
             +signal.get(len-3)*0.1+signal.get(len-4)*0.1+signal.get(len-5)*0.1
             +signal.get(len-6)*0.1+signal.get(len-7)*0.1);
           }
           signal.add(foo);
           while(signal.size()>500){
             signal.remove();
           }

           // unshift: add data from left to right (first in)
            myChart.push("signal", (foo));
            

            
            int d=0;
            if(foo<40 && tr){
              tr=false;
              boof.clear();
            }
            if(!tr){
              if(boof.size()<switcher){
                boof.add(foo);
              }
              if((foo<40 && boof.size()>counter) || boof.size()>switcher){
                Integer[] array = boof.toArray(new Integer[boof.size()]);
                
                float[] floatArray = new float[array.length];
                for (int i = 0 ; i < array.length; i++)
                {
                      floatArray[i] = (float) array[i];
                }
                DTW dtw = new DTW(pattern, floatArray);
                int tmp1=(int) dtw.getDistance();
                
                if(tmp1<500){
                  d=int(200*(1-(tmp1/500.0))+50);
                }
                
                println(d);
                tr=true;
                meanChart.updateData("R", floatArray);
              }
            }
            // push: add data from right to left (last in)
            myChart.push("earth", d);
           //rect(100, 100, foo, 200);
              output.println( value );
         }
    }
}

void keyPressed() {
    output.flush();  // Writes the remaining data to the file
    output.close();  // Finishes the file
    exit();  // Stops the program
}