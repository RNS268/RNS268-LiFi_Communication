# 💡 LiFi Communication System

A full-stack **Light Fidelity (Li-Fi)** communication project using an ESP8266 microcontroller as the optical transmitter and a React-based web dashboard for real-time monitoring and control.

---

## 📖 Overview

Li-Fi (Light Fidelity) is a wireless communication technology that transmits data using visible light instead of radio waves. This project demonstrates a working Li-Fi system where:

- An **ESP8266** modulates an LED at high frequency to encode and transmit data optically
- A **React dashboard** connects over WebSocket for real-time control and live telemetry
- PWM frequency and duty cycle can be tuned on the fly from the browser UI

---

## ✨ Features

- 🔆 **Optical Data Transmission** — LED-based Li-Fi transmitter driven by the ESP8266
- 🎛️ **PWM Control** — Adjustable frequency and duty cycle from the dashboard
- 📡 **WebSocket Integration** — Low-latency, real-time bidirectional communication
- 📋 **Live Logging** — Real-time event and data log feed in the dashboard
- 🌑 **Dark/Cyan UI** — Sleek dark-themed React dashboard with a cyan accent palette
- 📶 **Wi-Fi Hosted** — ESP8266 hosts a local access point or connects to your network

---

## 🧰 Hardware Requirements

| Component                         | Description                                |
|-----------------------------------|--------------------------------------------|
| ESP8266 (NodeMCU / Wemos D1 Mini) | Main microcontroller + Wi-Fi               |
| High-speed LED                    | Optical transmitter element                |
| Photodiode / LDR                  | Optical receiver (if implementing RX side) |
| Resistors, jumper wires           | Supporting components                      |
| USB cable                         | For flashing and power                     |

---

## 🖥️ Software Stack

### Firmware (ESP8266)
- **Arduino framework** (via Arduino IDE or PlatformIO)
- `ESP8266WiFi` — Wi-Fi connectivity
- `WebSocketsServer` — Real-time WebSocket server
- `analogWrite` / PWM — LED modulation

### Dashboard (React)
- **React** — Component-based UI
- **WebSocket API** — Browser-native real-time comms
- Dark/cyan theme with live controls and log panel

---

## 🚀 Getting Started

### 1. Flash the ESP8266 Firmware

1. Open the firmware folder in Arduino IDE or PlatformIO.
2. Update your Wi-Fi credentials in the config section:
   ```cpp
   const char* ssid     = "YOUR_SSID";
   const char* password = "YOUR_PASSWORD";
   ```
3. Select the correct board (`NodeMCU 1.0` or `LOLIN(Wemos) D1 R2`) and port.
4. Upload the sketch.
5. Open Serial Monitor at **115200 baud** to get the device IP address.

### 2. Run the React Dashboard

```bash
# Navigate to the dashboard directory
cd dashboard

# Install dependencies
npm install

# Start the dev server
npm start
```

3. Open your browser and go to `http://localhost:3000`.
4. Enter the ESP8266's IP address in the dashboard and connect.

---

## 🎛️ Dashboard Controls

| Control | Description |
|---|---|
| **Connect / Disconnect** | Toggle WebSocket connection to the ESP8266 |
| **PWM Frequency** | Set the LED modulation frequency (Hz) |
| **Duty Cycle** | Adjust the on/off ratio of the PWM signal (%) |
| **Send** | Push updated parameters to the device |
| **Live Log** | Real-time feed of events, errors, and received data |

---

## 📡 WebSocket Protocol

Messages are exchanged as JSON between the dashboard and ESP8266.

**Dashboard → ESP8266 (control command):**
```json
{
  "type": "config",
  "frequency": 1000,
  "duty": 50
}
```

**ESP8266 → Dashboard (status / log):**
```json
{
  "type": "log",
  "message": "PWM updated: 1000Hz, 50% duty",
  "timestamp": 3821
}
```

---

## 📁 Project Structure

```
RNS268-LiFi_Communication/
├── firmware/
│   └── lifi_transmitter/
│       └── lifi_transmitter.ino   # ESP8266 Arduino sketch
├── dashboard/
│   ├── public/
│   ├── src/
│   │   ├── App.jsx                # Root component
│   │   ├── components/
│   │   │   ├── ControlPanel.jsx   # PWM sliders and controls
│   │   │   └── LogPanel.jsx       # Live log feed
│   │   └── index.css              # Dark/cyan theme
│   └── package.json
└── README.md
```

---

## 🔧 Configuration

| Parameter           | Default  | Description                                  | 
|--------------------|-----------|----------------------------------------------|
| WebSocket Port     | `81`      | Port the ESP8266 WebSocket server listens on |
| Default Frequency  | `1000 Hz` | Initial LED PWM frequency                    |
| Default Duty Cycle | `50%`     | Initial on/off ratio                         |
| Baud Rate          | `115200`  | Serial monitor baud rate                     |

---

## 📸 Screenshots

> _Dashboard screenshot — dark theme with cyan controls and live log panel_

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

---

## 👤 Author

**Shashank** — [@RNS268](https://github.com/RNS268)

> Built as part of an exploration into visible light communication (VLC) and embedded IoT systems.
