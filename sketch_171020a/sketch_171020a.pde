import processing.serial.*;
import controlP5.*;

ControlP5 cp5;
Chart myChart;

Serial mySerial;
PrintWriter output;

IntList signal;

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
   
    myChart = cp5.addChart("hello")
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
  myChart.updateData("earth", 1, 2, 10, 3);
}
void draw() {
    background(200);
    
    fill(30);
    if (mySerial.available() > 0 ) {
         String value = mySerial.readString();
         if ( value != null ) {
           int foo = tryParse(value);
           print(value);
           // unshift: add data from left to right (first in)
            myChart.unshift("signal", (foo));
            
            // push: add data from right to left (last in)
            myChart.push("earth", (sin(frameCount*0.1))*127+127);
           rect(100, 100, foo, 200);
              output.println( value );
         }
    }
}

void keyPressed() {
    output.flush();  // Writes the remaining data to the file
    output.close();  // Finishes the file
    exit();  // Stops the program
}