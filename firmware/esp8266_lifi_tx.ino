/**
 * ESP8266 LiFi Data Receiver and Transmitter
 * -----------------------------------------
 * This firmware allows the ESP8266 to receive text data from the Flutter app
 * via an HTTP GET request and "transmit" it using an LED (LiFi) or Serial.
 * 
 * Communication Protocol:
 * The Flutter app sends: http://<ESP_IP>/?data=MESSAGE
 * 
 * Hardware Connections:
 * - LiFi LED: Connect to GPIO 2 (D4 on most NodeMCU/Wemos boards) with a resistor.
 * - Monitor Serial at 115200 baud for debugging.
 */

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

// --- Configuration ---
const char* ssid = "YOUR_WIFI_SSID";     // Change to your WiFi name
const char* password = "YOUR_WIFI_PASSWORD"; // Change to your WiFi password

// Pin for LiFi Transmission (LED)
const int LIFI_LED_PIN = 2; // GPIO 2 (D4 / Onboard LED)

// Transmission Settings
const int BIT_PERIOD_MS = 10; // Delay between bits (10ms = 100 bps)

// Web Server instance on port 80
ESP8266WebServer server(80);

/**
 * Transmits a string bit-by-bit using the LED (Simple OOK - On-Off Keying)
 */
void transmitLiFi(String data) {
  Serial.print(">>> Transmitting LiFi: ");
  Serial.println(data);

  // OOK (On-Off Keying) Transmission
  // Protocol: [START_BIT(HIGH)] [8 DATA BITS] [STOP_BIT(LOW)]
  
  for (int i = 0; i < data.length(); i++) {
    char c = data[i];

    // 1. Send Start Bit (HIGH) to signal character start
    digitalWrite(LIFI_LED_PIN, HIGH);
    delay(BIT_PERIOD_MS);

    // 2. Send 8 Bits (LSB first)
    for (int b = 0; b < 8; b++) {
      bool bitValue = (c >> b) & 0x01;
      digitalWrite(LIFI_LED_PIN, bitValue ? HIGH : LOW);
      delay(BIT_PERIOD_MS);
    }

    // 3. Send Stop Bit (LOW)
    digitalWrite(LIFI_LED_PIN, LOW);
    delay(BIT_PERIOD_MS);
    
    // Tiny gap between characters
    delay(BIT_PERIOD_MS * 2);
  }
  
  Serial.println(">>> Transmission Complete.");
}

/**
 * Endpoint: /
 * Handles both "Check Connection" (GET /) 
 * and "Send Data" (GET /?data=...)
 */
void handleRoot() {
  if (server.hasArg("data")) {
    String message = server.arg("data");
    
    // Log to Serial
    Serial.print("Received Data from App: ");
    Serial.println(message);

    // Respond to the App (Success)
    server.send(200, "text/plain", "SUCCESS: Transmitting \"" + message + "\"");

    // Perform LiFi Transmission
    transmitLiFi(message);
    
  } else {
    // Basic health check response
    server.send(200, "text/html", 
      "<html><body><h1>ESP8266 LiFi Node</h1><p>Status: Ready</p></body></html>");
    Serial.println("Connection health check received.");
  }
}

/**
 * Endpoint: /status
 * Returns system information as a simple text/json response
 */
void handleStatus() {
  String status = "{\"chip_id\": " + String(ESP.getChipId()) + 
                 ", \"uptime\": " + String(millis()/1000) + 
                 ", \"status\": \"online\"}";
  server.send(200, "application/json", status);
}

void setup() {
  // Initialize Serial for debugging
  Serial.begin(115200);
  delay(10);
  
  // Initialize LED Pin
  pinMode(LIFI_LED_PIN, OUTPUT);
  digitalWrite(LIFI_LED_PIN, LOW); // Start with LED OFF

  Serial.println("\n----------------------------------");
  Serial.println("ESP8266 LiFi Controller Starting...");
  Serial.println("----------------------------------");

  // Connect to WiFi
  Serial.print("Connecting to: ");
  Serial.println(ssid);
  
  WiFi.mode(WIFI_STA); 
  WiFi.begin(ssid, password);

  int counter = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    digitalWrite(LIFI_LED_PIN, (counter % 2 == 0) ? HIGH : LOW); // Blink while connecting
    counter++;
    if (counter > 40) { // Fail-safe: restart if connection takes too long
      Serial.println("\nWiFi Failed. Restarting...");
      ESP.restart();
    }
  }

  // Connection Success
  digitalWrite(LIFI_LED_PIN, LOW); // Keep LED off after connection
  Serial.println("\nWiFi Connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
  Serial.println("Use this IP address in your Flutter App.");

  // Configure Web Server routes
  server.on("/", HTTP_GET, handleRoot);
  server.on("/status", HTTP_GET, handleStatus);

  // Start Server
  server.begin();
  Serial.println("HTTP Server Started. Ready to transmit.");
}

void loop() {
  // Handle incoming HTTP requests
  server.handleClient();
}
