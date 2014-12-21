import processing.serial.*;
import processing.net.*;

Server server;
Client client;
Serial arduino;
int portNumber = 9750;
boolean isSerialInitialized = false;
String ports[];
void setup() {
  background(0);
  size(500, 500);
  ports = Serial.list();
}


void draw() {  
  if (!isSerialInitialized) {
    background(0);
    for (int i=0; i<ports.length; i++) {
      text(i + " : "+ports[i], 20, 20+20*i);
    }
    text("choose serial port and type number", 20, 40+ ports.length*20);
    if (keyPressed) {
      int c = int(key)-48;
      if (c >= 0 && c < ports.length ) {
        try {
          arduino = new Serial(this, ports[c], 9600);
          server = new Server(this, portNumber);
          isSerialInitialized = true;
        } 
        catch (Exception e) {
          println(e);
          isSerialInitialized = false;
        }
      }
    }
  }  
  else {
    background(0, 124, 124);
    text("Arduino connected", 20, 30);
    
    client = server.available();
    if (client == null) return;
    // Send command
    if (client.available () > 0) {
      String buf = client.readString();
      if (buf != null){
        print("Req: ");
        println(buf);
        arduino.write(buf);
      }
    }
    // Receive response
    String buf = null;
    int start = millis();
    do{
      if(arduino.available() > 0) {
        buf = arduino.readStringUntil('\r');
      }
    }while( (buf == null || buf.equals("\r")) && millis() - start < 1000);
    
    print("Res: ");
    println(buf);
    if(client != null){
      client.write(buf);
      client.stop();
    }
  }
}

