import processing.serial.*;
import controlP5.*;
import java.util.*;

ControlP5 cp5;
Chart myChart;

Serial mySerial;
PrintWriter output;

LinkedList<Integer> signal = new LinkedList<Integer>();

int i=10;
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
   size(800,600);
   frameRate(30);
   cp5 = new ControlP5(this);
   smooth();
   
    myChart = cp5.addChart("PULSEWAVE SIGNAL AND DTW DISTNACE")
               .setPosition(300, 10)
               .setSize(490, 200)
               .setRange(0, 255)
               .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
               ;

  myChart.getColor().setBackground(color(255, 100));


  myChart.addDataSet("signal");
  myChart.setColors("signal", color(255,0,255),color(255,0,0));
  myChart.setData("signal", new float[500]);

  myChart.setStrokeWeight(2);

  myChart.addDataSet("earth");
  myChart.setColors("earth", color(255), color(0, 255, 0));
  myChart.updateData("earth", new float[500]);
}
void draw() {
    background(200);
    fill(30);
    if (mySerial.available() > 0 ) {
         String value = mySerial.readString();
         if ( value != null ) {
           int foo = tryParse(value);
           signal.add(foo);
           while(signal.size()>10){
             signal.remove();
           }
            println(signal);
           // unshift: add data from left to right (first in)
            myChart.push("signal", (foo));
            float[] n2 = {1.5f, 3.9f, 4.1f, 3.3f};
            float[] n1 = {1.5f, 3.9f, 4.1f, 5.3f};
            DTW dtw = new DTW(n1, n2);
            
            int d=(int) dtw.getDistance();
            // push: add data from right to left (last in)
            myChart.push("earth", d*100);
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