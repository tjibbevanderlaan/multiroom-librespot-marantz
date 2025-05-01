# Multiroom Librespot Marantz
This project combines Librespot, Snapserver, and ESPHome control over a Marantz amplifier.
- **Snapserver**: Runs a Docker-based Librespot + Snapserver stack. On specific playback events (like start/stop), it sends HTTP requests to an ESPHome device (NodeMCU) that then controls a Marantz amplifier via RC5 signals.
- **Snapclient**: A separate configuration for the Snapclient that receives audio from Snapserver and outputs sound to your desired audio device (e.g., a USB DAC).
- **Marantz Remote (ESPHome)**: An ESPHome YAML configuration that, when flashed to a NodeMCU, can transmit RC5 signals to your Marantz amplifier.

## Hardware Setup

Below is an overview of the hardware used and how they connect:
1.	Marantz Amplifier – The classic stereo amplifier that accepts RC5 over a RCA input (remote control in).
2.	NodeMCU (ESP8266 or ESP32) – Flashed with ESPHome firmware using the marantz_remote.yaml file.
3.	RC5 Circuit – A small circuit that includes a diode that transmits RC5 signals from the NodeMCU to the Marantz amplifier via the remote control input port. Diode prevents that current is flowing the other way around. 
4.	Linux Machine – Runs Docker for the Librespot + Snapserver “Server” container. Also runs Snapclient to receive audio from Snapserver. The audio output goes to a USB DAC or onboard sound, which feeds into the Marantz amplifier.

### Physical Connections
1.	Linux Machine ↔ (USB) ↔ USB DAC → (RCA cable) → Marantz Amp
2.	NodeMCU → (GPIO pin with diode) → (RCA cable) → Marantz Amp

## Usage Instructions
### Build and Run the Server
1.	Clone this repository.
2.	Enter the `server/` directory:
```bash
cd server
docker-compose up -d
```
3.	Verify that Librespot and Snapserver containers are running.

### Configure and Start Snapclient
1.	Install snapclient on the same (or another) machine.
2.	Copy or adapt `snapclient` from the `snapclient/` directory to `/etc/default/snapclient`.
3.	Start snapclient:
```bash
snapclient
```
4.	Verify it connects to the Snapserver.

### Flash the ESPHome Configuration to the NodeMCU
1.	Install ESPHome locally or use the ESPHome add-on in Home Assistant.
2.	Copy `esphome/marantz_remote.yaml` to your ESPHome project.
3.	Update wifi: credentials, and ensure the remote_transmitter GPIO pin matches your actual wiring.
4.	Flash to the NodeMCU.

### Test Playback and Amplifier Control
- Start streaming from Spotify to "Marantz" (the one created by your Docker container).
- As soon as playback starts or stops, the server script will send an HTTP request to your NodeMCU, prompting the amplifier to turn on/off or mute on paused playback.


## Contributing
- Issues: If you find a bug or have an idea for an improvement, open an issue.
- Pull Requests: PRs are welcome if you’d like to contribute updates or new features.

## License
GNU GENERAL PUBLIC LICENSE
