/*
  
  Temperature Seeded Audio 1.0 
    Initial Prototype Sketch
  
  created: 1-5-2013
  by Brian Tice who borrowed heavily from the 
  SD card and WebServer sketches written by Tom Igoe.
 
 This example code is in the public domain.
    
 */

#include <SD.h>
#include <SPI.h>
#include <Ethernet.h>

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = { 
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
IPAddress ip(172,16,42,4);

// Initialize the Ethernet server library
// with the IP address and port you want to use 
// (port 80 is default for HTTP):
EthernetServer server(80);

// On the Ethernet Shield, CS is pin 4. Note that even if it's not
// used as the CS pin, the hardware CS pin (10 on most Arduino boards,
// 53 on the Mega) must be left as an output or the SD library
// functions will not work.
const int chipSelect = 4;

void setup()
{
 // Open serial communications and wait for port to open:
  Serial.begin(9600);
   while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }

 
  Serial.print("Initializing SD card...");
  // make sure that the default chip select pin is set to
  // output, even if you don't use it:
  pinMode(53, OUTPUT);
  
  // see if the card is present and can be initialized:
  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    // don't do anything more:
    return;
  }
  Serial.println("card initialized.");

  // start the Ethernet connection and the server:
  Ethernet.begin(mac, ip);
  server.begin();
  Serial.print("server is at ");
  Serial.println(Ethernet.localIP());

}
int entryCount =   0;
void loop()
{
  
  // listen for incoming clients
  EthernetClient client = server.available();
 
  //boolean done =     false;
  
  int analogPin =    0;
  int sensor =       0;
  long timestamp =    0;
   // make a string for assembling the data to log:
  String dataString = "";
  // open the file. note that only one file can be open at a time,
  // so you have to close this one before opening another.
  
  
  //while(!done)
  //{
    if(entryCount > 500)   // Only run for 500 temperature readings for the time being
    {
      //done = true;
      return;
    }
    dataString = "";
    sensor = analogRead(analogPin);
    dataString += "Temperature: ";
    dataString += String(sensor);
    dataString += " Timestamp: ";
    timestamp = millis();
    timestamp = timestamp/1000;
    dataString += String(timestamp);
   
    delay(1000);
    entryCount++; 
    File dataFile = SD.open("datalog.txt", FILE_WRITE);
     // if the file is available, write to it:
    if (dataFile) 
    {
        
        dataFile.println(dataString);
        dataFile.close();
        // print to the serial port too:
        Serial.println(dataString);
      
        if (client) 
        {
          Serial.println("new client");
          // an http request ends with a blank line
          boolean currentLineIsBlank = true;
          
          
          while (client.connected()) 
          {
            if (client.available()) 
            {
              char c = client.read();
              Serial.write(c);
              // if you've gotten to the end of the line (received a newline
              // character) and the line is blank, the http request has ended,
              // so you can send a reply
              if (c == '\n' && currentLineIsBlank) 
              {
                // send a standard http response header
                client.println("HTTP/1.1 200 OK");
                client.println("Content-Type: text/html");
                client.println("Connnection: close");
                client.println();
                client.println("<!DOCTYPE HTML>");
                client.println("<html>");
                // add a meta refresh tag, so the browser pulls again every 5 seconds:
                client.println("<meta http-equiv=\"refresh\" content=\"5\">");
                // output the value of each analog input pin
                client.println(dataString);
                client.println("<br />"); 
                client.println("</html>");
                break;      
              }
       
              if (c == '\n') 
              {
                // you're starting a new line
                currentLineIsBlank = true;
              } 
              else if (c != '\r')
              {
                // you've gotten a character on the current line
                currentLineIsBlank = false;
              }
          }
        }
        // give the web browser time to receive the data
        delay(1);
        // close the connection:
        client.stop();
        Serial.println("client disonnected");
      
      }
                  
    }
    // if the file isn't open, pop up an error:
    else 
    {
      Serial.println("error opening datalog.txt");
    } 
  
   
}

