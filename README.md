## vRAAS for MSFS

Enhance your flight simulation experience with **vRAAS**, a virtual Runway Awareness and Advisory System designed to replicate real-world RAAS functionality, delivering runway alerts and advisories directly within MSFS. Every feature operates exactly like its real counterpart and can be easily customized or disabled to suit your preferences.

[<img src="https://github.com/user-attachments/assets/0a74de5a-6c71-4480-9750-ad2e417fdb07">](https://contrail.shop/products/land3-simulations-vraas-msfs) <br/><br/>
[<img width="200" src="https://github.com/user-attachments/assets/4df0b494-7c98-4a4c-b677-b22b63523ad6">](http://discord.land3simulations.com/)
[<img width="230" src="https://github.com/user-attachments/assets/de8a0650-3394-44e9-b0f7-347a9ad6842e">](https://contrail.shop/products/land3-simulations-vraas-msfs)

### Key Features:

- **Full Compatibility**: Works seamlessly with all airports, including add-ons, and supports all aircraft types—no configuration required.
- **In-Sim Text Display**: Displays alerts on the PFD/ND (see limitations below).
- **Effortless Setup**: No manual setup needed—simply install and fly.
- **Auto-Updating**: Stay up-to-date with automatic software and configuration updates.
- **Automatic Aircraft-Specific Configurations**: _Automatically_ downloads aircraft-specific settings.
- **Multiple Voice Options**: Choose from multiple male or female voice callouts for a personalized experience.
- **Highly Customizable**: Tailor the system settings to your preferences with ease.
- **Convenient Automation**: Includes options for auto-start, auto-close, and minimize-to-tray functionality.
- **No Performance Impact**: Enjoy realistic alerts with no noticeable effect on FPS.
- **Flexible Audio**: Select any Windows sound output device for audio alerts.
- **Built-in Self-Test**: Ensure functionality with a reliable self-test feature.
- **In-Cockpit Controls**: RAAS INHIBIT or FLAP INHIBIT switches in your cockpit are linked to vRAAS.

### Known Limitations:

- **Experimental PFD/ND Text Display**: The text display on the PFD/ND is currently experimental and may be affected by future MSFS updates.
- **_TOO FAST_ Callout Limitations**: Due to MSFS constraints, the _TOO FAST_ warning is only supported on certain aircraft.

### Compatibility with MSFS 2024:

vRAAS has been tested with the MSFS 2024 Tech Alpha, and all features performed as expected. However, until the final version is available, we cannot guarantee full compatibility with MSFS 2024.

---

## Aircraft Compatibility List

Generally, **vRAAS audio calls work with all aircraft**, including 3rd-party addons. However, some features require additional configuration or fine-tuning. The following aircraft will work perfectly without any configuration on your part.

**vRAAS Audio**: Audio calls, generally available for all aircraft  
**vRAAS Display**: In-game RAAS text messages displayed on PFD or ND  

| Developer                 | Aircraft                   	| vRAAS Audio 	| vRAAS Display | NOTE 	|
|---------------------------|----------------------------|:----------:|:------------:|------|
| FlyByWire                   | A320neo                    |      ✅     	|       ✅      |1)      	|
| FlyByWire                   | A380X                      |      ✅     	|       ✅      |        	|
| Fenix                       | A319/A320/A321             |      ✅     	|       ✅      |1)      	|
| FlightSimStudio FSS         | E170/E175/E190(F)/E195(F)  |      ✅     	|       ✅      |      	|
| FlightSimStudio FSS         | B727                       |      ✅     	|       ❌      |1) No displays to show vRAAS text. |
| Horizon Simulations         | B787                       |      ✅     	|       ✅      |      	|
| IniBuilds A306F             | A306F                      |      ✅     	|       ✅      |1)      	|
| iFly			               | B737-MAX8                  |      ⚠️     	|       ⚠️      |1) RAAS included in aircraft. vRAAS disabled by default. Enabling vRAAS shows text on PFD.       	|
| Leonardo                    | MADDOX X                   |      ✅     	|       ✅      |      	|
| LatinVFR                    | A330-900neo                |      ✅     	|       ✅      |1)      	|
| Headwind Simulations        | A330neo					     |      ✅     	|       ✅      |      	|
| Microsoft / Default         | A310                       |      ✅     	|       ✅      |1)      	|
| Asobo / Default             | B747-8i                    |      ✅     	|       ✅      |1)      	|
| Asobo / Default             | B787-10                    |      ✅     	|       ✅      |1)      	|   
| Asobo / Default             | A320neo                    |      ✅     	|       ✅      |1)      	|
| Asobo / Default             | CJ4                        |      ✅     	|       ✅      |1)      	|
| Asobo / Default             | Citation Longitude         |      ✅     	|       ✅      |1)      	|
| Asobo / Default             | C208 Grand Caravan         |      ✅     	|       ✅      |1)      	|
| PMDG                        | B737 (ALL VARIANTS)        |      ✅     	|       ✅      |      	|
| PMDG                        | B777                       |      ✅     	|       ✅      |      	|
| ProSim                      | B738                       |      ✅     	|       ❌      |1) vRAAS cannot access ProSim display. |
| TFDi				          | MD-11                      |      ✅     	|       ✅      |1)      	|

1\) **_TOO FAST_** callout during approach is currently unavailable for this aircraft due to missing data from add-on.

Don’t see your favorite aircraft listed? Feel free to send a request on our Discord!

---

## Available Callouts

0. **Self-Test**  
   Checks if vRAAS is working properly and announces the unit used for distance calls:  
   **_“RUNWAY AWARENESS OKAY - METER / FEET”_**  
   **_“RUNWAY AWARENESS INOP”_**  
   **_“RUNWAY AWARENESS R-T-O”_**

### Ground Operations

1. **Approaching Runway (on Ground)**  
   Informs when approaching a runway during taxi operations:  
   **_“APPROACHING RUNWAY 25 LEFT”_**

2. **On Runway**  
   Confirms runway location when lining up on the runway:  
   **_“ON RUNWAY 25 LEFT”_**

3. **Takeoff Flaps Configuration**  
   Warns if lining up without a valid takeoff flaps setting:  
   **_“ON RUNWAY 25 LEFT. FLAPS! FLAPS!_**

4. **Extended Hold on Runway**  
   Alerts if holding on the runway for an extended time:  
   **_“ON RUNWAY 25 LEFT. ON RUNWAY 25 LEFT.”_**

5. **Insufficient Runway Length on Ground**  
   Warns of insufficient runway length for takeoff:  
   **_“ON RUNWAY 25 LEFT. 500 METERS/FEET REMAINING”_**

6. **Short Runway Takeoff Warning**  
   Alerts when the remaining runway length is shorter than nominal:  
   **_“SHORT RUNWAY! SHORT RUNWAY!”_**

7. **Distance Remaining (Rejected Takeoff)**  
   Announces runway distance remaining after rejected takeoff:  
   **_“1500 ... 1200 ... 900 ...”_** (meters or feet)

8. **Taxiway Takeoff (Advisory)**  
   Advises when the aircraft is accelerating on a taxiway instead of a runway:  
   **_“(CAUTION!) ON TAXIWAY! ON TAXIWAY!”_**

### Approach and Landing

10. **Approaching Runway (Landing)**  
    Informs when the aircraft is approaching a runway during landing:  
    **_“APPROACHING 25 LEFT”_**

11. **Approaching Short Runway**  
    Runway length is shorter than nominal landing distance:  
    **_“APPROACHING 25 LEFT, 1400M AVAILABLE”_**

12. **Short Runway Landing**  
    Alerts of final approach to a short runway:  
    **_“CAUTION SHORT RUNWAY, SHORT RUNWAY!”_**

13. **Taxiway Landing**  
    Warns if lined up with a taxiway instead of a runway:  
    **_“CAUTION TAXIWAY! CAUTION TAXIWAY!”_**

14. **Distance Remaining (Landing & Rollout)**  
    Announces remaining runway distance during landing and rollout:  
    **_“ONE THOUSAND, FIVE HUNDRED”_** (METERS/FEET REMAINING)

### In-Flight Approach Warnings

15. **Landing Flaps Not Set**  
    Warns if landing flaps are not set:  
    **_“FLAPS, FLAPS”_**

17. **Too High on Approach**  
    Alerts if too high on approach path:  
    **_“TOO HIGH, TOO HIGH”_**

18. **Too Fast on Approach**  
    Alerts if too fast for a safe approach speed:  
    **_“TOO FAST, TOO FAST”_**

---

### Why Choose vRAAS?

Compared to other RAAS add-ons on the market, **vRAAS** offers the following benefits:

- **RAAS display on PFD/ND for many aircraft**  
  _View RAAS alerts directly on your PFD/ND, enhancing in-flight awareness._

- **Automatic, aircraft-specific configurations**  
  _vRAAS automatically downloads and applies specific configurations for each aircraft—no setup required._

- **Full automation, no interaction required**  
  _Enjoy a fully automated experience from start to finish, allowing you to focus entirely on your flight._

- **Detects runway-specific approach angles, avoiding "TOO HIGH" alerts**  
  _Avoids false "TOO HIGH" alerts by recognizing steep approach angles at specific airports, such as London City._

- **Real-time altimeter calls based on flight area transition altitude**  
  _Receive accurate altimeter setting reminders tailored to the transition altitude of your flight area._

- **Distinct sound levels for advisory vs. caution alerts**  
  _Just like real counterpart, alerts are differentiated by volume, with cautions louder than advisories, for immediate recognition._

- **Integrated with in-cockpit switches for enhanced control**  
  _Directly control RAAS functionality via RAAS INHIBIT and FLAP INHIBIT switches in the cockpit._

- **Dynamic TOO FAST alerts based on target speed**  
  _TOO FAST alerts dynamically adjust based on your aircraft's approach speed, providing precise feedback._

---

## FAQ

### Activation / Serial
- **Is an active internet connection required?**  <br/>
  _An internet connection is needed to activate the product on the first launch._

### General
- **Do I have to launch vRAAS manually each time I want to fly?**  <br/>
  _The vRAAS process needs to be running for RAAS to function, but you can enable the auto-start option in the General Settings tab. Additionally, you can select options for_ _Minimize to tray_, _Start minimized_, _and_ _Auto-close_ _so you won’t need to interact with the vRAAS window at all._

- **Does vRAAS reduce FPS?**  <br/>
  _We haven't observed any noticeable impact on FPS._
  
- **Do I need Internet for vRAAS to work?**  <br/>
  _vRAAS automatically downloads aircraft-specific details at each launch. Although vRAAS generally functions well without an internet connection, some convenience features do require it._

- **Can I disable the self-test on startup?** <br/> 
  _Yes, go to_ _General Settings_ _and disable_ _Self-Test on startup_.

- **How can I change the unit of measurement to feet?**  <br/>
  _Go to **Main Window > RAAS Features > ALL AIRCRAFT > Units** and select your preferred unit._

### Display
- **How can I disable the RAAS Display for certain displays?**<br/>
  _Navigate to_ **Main Window > RAAS Features > CURRENT AIRCRAFT > Display Setup**. _Check or uncheck the desired display, and you can also adjust the text position and size here._

- **I don't see any text on my PFD/ND.**<br/>
  _If you have just installed vRAAS, restart your Simulator. <br/>
  _Ensure the community-folder plugin is installed (it should install automatically). Also, verify if your aircraft is on the supported list above. If not, go to_ **Main Window > RAAS Features > CURRENT AIRCRAFT > Display Setup** _to position the text yourself or reach out on our Discord for assistance._

- **The real aircraft only shows RAAS text when TERR is selected on the ND. Can you add this to vRAAS?** <br/> 
  _vRAAS supports this, but many aircraft don’t provide the required data to detect if TERR is selected. If you know of a way to detect it, please share on Discord!_

- **I get the self-test alert even when the aircraft is cold-and-dark.** <br/> 
  _Currently, vRAAS is always "powered on." Linking vRAAS to the aircraft power state is on our to-do list. In the meantime, you can disable the self-test on the_ _General Settings_ _page._


### Any further questions? Ideas? Join our Discord!
[<img width="200" src="https://github.com/user-attachments/assets/4df0b494-7c98-4a4c-b677-b22b63523ad6">](http://discord.land3simulations.com/)

---

## TO-DO List

- Link RAAS to aircraft power state
- Add (Virtual-)Airline specific profiles
- Expand voice options
- Increase support for more aircraft

---

###### Impressum (Imprint)

To comply with German law, please refer to our [Impressum](http://land3simulations.com/impressum.html) for legal details.


