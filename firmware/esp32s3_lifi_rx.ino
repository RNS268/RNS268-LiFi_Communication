/**
 * ESP32-S3 Mini 1 LiFi Data Receiver
 * ----------------------------------
 * Receives data via light pulses on a Solar Panel connected to ADC.
 * Displays the received signal as text on an I2C LCD.
 * 
 * Hardware Connections:
 * - Solar Panel: One terminal to GND, the other terminal to GPIO 1.
 * - LCD Display (I2C): 
 *   - SDA -> GPIO 8
 *   - SCL -> GPIO 9
 *   - VCC -> 5V (or 3.3V)
 *   - GND -> GND
 */

#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// --- Pins ---
const int SOLAR_PIN = 1; // ADC Pin for Solar Panel Input (Analog)
const int SCL_PIN = 9;   // ESP32-S3 Mini I2C SCL
const int SDA_PIN = 8;   // ESP32-S3 Mini I2C SDA

// --- Timing (MUST MATCH TRANSMITTER) ---
const int BIT_PERIOD_MS = 10; // Delay between bits

// --- LCD Configuration ---
// Set the LCD address to 0x27 for a 16 chars and 2 line display
LiquidCrystal_I2C lcd(0x27, 16, 2);

// --- State Variables ---
int initialThreshold = 500; // Calculated during calibration
String currentMessage = ""; // Buffer for received text

/**
 * Calibration routine to set the light threshold 
 * based on ambient light in the room.
 */
void calibrate() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Calibrating...");
  Serial.print("Calibrating ambient light...");

  long sum = 0;
  for (int i = 0; i < 200; i++) {
    sum += analogRead(SOLAR_PIN);
    delay(5);
  }
  
  int ambient = sum / 200;
  // Threshold is set slightly above ambient to avoid noise
  // On ESP32-S3, analogRead goes up to 4095
  initialThreshold = ambient + (4095 - ambient) / 8; // Auto-adaptive bias
  
  Serial.println(" Done!");
  Serial.print("Ambient: "); Serial.println(ambient);
  Serial.print("Threshold set to: "); Serial.println(initialThreshold);
  
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Ready to Recv");
}

void setup() {
  Serial.begin(115200);
  
  // Initialize I2C Pins for ESP32-S3
  Wire.begin(SDA_PIN, SCL_PIN);
  
  // Initialize LCD
  lcd.init();
  lcd.backlight();
  
  // Start-up Screen
  lcd.setCursor(0, 0);
  lcd.print("LiFi RX System");
  lcd.setCursor(0, 1);
  lcd.print("v1.0 Starting...");
  delay(1000);

  calibrate();
}

void loop() {
  int sensorValue = analogRead(SOLAR_PIN);

  // Check for START_BIT (Light intensity goes HIGH above threshold)
  if (sensorValue > initialThreshold) {
    
    // 1. Sync to the middle of the Start Bit
    delay(BIT_PERIOD_MS / 2);
    
    // Verify it's still high (not just a flicker)
    if (analogRead(SOLAR_PIN) > initialThreshold) {
      
      char decodedChar = 0;
      
      // 2. Sample 8 Data Bits (LSB first)
      for (int b = 0; b < 8; b++) {
        // Wait for next bit period
        delay(BIT_PERIOD_MS);
        
        // Read bit at the center of the period
        if (analogRead(SOLAR_PIN) > initialThreshold) {
          decodedChar |= (1 << b);
        }
      }

      // 3. Process the character
      if (decodedChar > 0) {
        Serial.print(decodedChar);
        
        // Handle message display
        if (decodedChar == '\r' || decodedChar == '\n') {
          // Clear line on line break
          currentMessage = "";
          lcd.setCursor(0, 1);
          lcd.print("                "); // Clear line 2
        } else {
          currentMessage += decodedChar;
          
          // Display the last 16 characters on the second line
          lcd.setCursor(0, 1);
          if (currentMessage.length() > 16) {
            lcd.print(currentMessage.substring(currentMessage.length() - 16));
          } else {
            lcd.print(currentMessage);
          }
        }
      }

      // 4. Wait for Stop Bit (Cool-down)
      delay(BIT_PERIOD_MS); 
    }
  }
}
