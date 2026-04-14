## vRAAS for MSFS

Enhance your flight simulation experience with **vRAAS**, a virtual Runway Awareness and Advisory System designed to replicate real-world RAAS functionality, delivering runway alerts and advisories directly within MSFS. Every feature operates exactly like its real counterpart and can be easily customized or disabled to suit your preferences.

[<img src="https://github.com/user-attachments/assets/0a74de5a-6c71-4480-9750-ad2e417fdb07">](https://contrail.shop/products/land3-simulations-vraas-msfs) <br/><br/>
[<img width="200" src="https://github.com/user-attachments/assets/4df0b494-7c98-4a4c-b677-b22b63523ad6">](http://discord.land3simulations.com/)
[<img width="230" src="https://github.com/user-attachments/assets/de8a0650-3394-44e9-b0f7-347a9ad6842e">](https://contrail.shop/products/land3-simulations-vraas-msfs)

### What's new in v1.3

[<img src="https://github.com/user-attachments/assets/8804730d-d462-4fe5-a848-cfb14eaf61d6" alt="vRAAS v1.3 — MAX BRAKING! MAX REVERSE! — Runway Overrun Prevention (official trailer by aviationlads)">](https://youtu.be/1bn4M8EoCo8)

**Runway Overrun Prevention (ROP)** — predictive stopping-distance alerts during landing. If current braking and reverse thrust won't stop the aircraft on the remaining runway, ROP triggers a **_"MAX BRAKING! MAX REVERSE!"_** callout. See the **ROP** column in the [Aircraft Compatibility List](#aircraft-compatibility-list) for supported aircraft, or watch the [official trailer](https://youtu.be/1bn4M8EoCo8).

### Key Features:

- **Full Compatibility**: Works seamlessly with all airports, including add-ons, and supports all aircraft types—no configuration required.
- **In-Sim Text Display**: Displays alerts on the PFD/ND (see limitations below).
- **Runway Overrun Prevention (ROP)**: Predictive stopping-distance alerts during landing, prompting maximum braking and reverse thrust when needed. _New in v1.3._
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

### Simulator Compatibility:

**vRAAS is fully compatible with MSFS 2020 + MSFS 2024.**

---

## Aircraft Compatibility List

Generally, **vRAAS audio calls work with all aircraft**, including 3rd-party addons. However, some features require additional configuration or fine-tuning. The following aircraft will work perfectly without any configuration on your part.

**vRAAS Audio**: Audio calls — available for *all* aircraft.  
**vRAAS Display**: In-game RAAS text messages displayed on PFD or ND.  
**ROP**: Runway Overrun Protection — predictive stopping-distance alerts during landing.

| Developer              | Aircraft                 | MSFS 2020 | MSFS 2024 | Display | ROP | NOTE |
|------------------------|--------------------------|:---------:|:---------:|:-------:|:---:|------|
| Aerosoft               | A330                     |     ✅    |     ✅    |    ✅   |     |      |
| Aerosoft               | A340-600 PRO             |     ✅    |     ✅    |    ✅   |  ✅ | 1)   |
| Aerosoft               | CRJ (ALL VARIANTS)       |     ✅    |           |    ✅   |     |      |
| Asobo / Default        | A320neo                  |     ✅    |           |    ✅   |     | 1)   |
| Asobo / Default        | B737 MAX                 |           |     ✅    |    ✅   |     | 1)   |
| Asobo / Default        | B747-8i                  |     ✅    |     ✅    |    ✅   |     | 1)   |
| Asobo / Default        | B787-10                  |     ✅    |           |    ✅   |     | 1)   |
| Asobo / Default        | C208 Grand Caravan       |     ✅    |           |    ✅   |     | 1)   |
| Asobo / Default        | CJ4                      |     ✅    |           |    ✅   |     | 1)   |
| Asobo / Default        | Citation Longitude       |     ✅    |           |    ✅   |     | 1)   |
| Fenix                  | A319/A320/A321           |     ✅    |     ✅    |    ✅   |  ✅ | 1)   |
| Flight FX              | HJET                     |     ✅    |           |    ✅   |     | 1)   |
| FlightSimStudio FSS    | B727                     |     ✅    |     ✅    |         |     | No displays to show vRAAS text. |
| FlightSimStudio FSS    | E-Jets (v 1.x and above) |     ✅    |     ✅    |    ✅   |     |      |
| FlyByWire              | A320neo                  |     ✅    |     ✅    |    ✅   |  ✅ | 1)   |
| FlyByWire              | A380X                    |     ✅    |     ✅    |    ✅   |     |      |
| FsLabs                 | A321ceo                  |     ✅    |     ✅    |    ✅   |  ✅ | 1)   |
| FsLabs                 | A321neo                  |     ✅    |     ✅    |    ✅   |  ✅ | 1)   |
| Headwind Simulations   | A330neo                  |     ✅    |     ✅    |    ✅   |  ✅ |      |
| Horizon Simulations    | B787                     |     ✅    |           |    ✅   |     |      |
| iFly                   | B737-MAX8                |     ⚠️    |     ⚠️    |    ⚠️   |  ✅ | 1) RAAS included in aircraft. vRAAS enabled by default — disable the built-in RAAS in the iFly EFB to avoid double callouts. |
| IniBuilds              | A306F                    |     ✅    |           |    ✅   |     | 1)   |
| IniBuilds              | A340                     |           |     ✅    |    ✅   |  ✅ | 1)   |
| IniBuilds              | A350                     |     ✅    |     ✅    |    ✅   |  ✅ | 1)   |
| JeeHell FMGS           | A320                     |     ✅    |           |    ⚠️   |     | Use [3rd party vRAAS Overlay](https://flightsim.to/file/85252/pero-vraas-overlay) for display output |
| Just Flight            | RJ 75/80/100             |     ✅    |     ✅    |    ✅   |     |      |
| Kuro                   | B787                     |     ✅    |           |    ✅   |     | 1)   |
| LatinVFR               | A330-900neo              |     ✅    |           |    ✅   |     | 1)   |
| Leonardo               | MADDOX X                 |     ✅    |           |    ✅   |     |      |
| LivToAir               | CJ3+                     |     ✅    |     ✅    |    ✅   |     | 1)   |
| Microsoft / iniBuilds  | A310                     |     ✅    |     ✅    |    ✅   |     | 1)   |
| Microsoft / iniBuilds  | A320neo                  |           |     ✅    |    ✅   |  ✅ |      |
| Microsoft / iniBuilds  | A321                     |           |     ✅    |    ✅   |  ✅ |      |
| Microsoft / iniBuilds  | A330                     |           |     ✅    |    ✅   |  ✅ |      |
| Microsoft / iniBuilds  | Beluga XL                |           |     ✅    |    ✅   |     |      |
| PMDG                   | B737 (ALL VARIANTS)      |     ✅    |     ✅    |    ✅   |  ✅ |      |
| PMDG                   | B777                     |     ✅    |     ✅    |    ✅   |  ✅ |      |
| ProSim                 | B737                     |     ✅    |           |    ⚠️   |     | Use [3rd party vRAAS Overlay](https://flightsim.to/file/85252/pero-vraas-overlay) for display output |
| Salty                  | B747-8i                  |     ✅    |           |    ✅   |     |      |
| TFDi                   | MD-11                    |     ✅    |     ✅    |    ✅   |  ✅ |      |

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

### Runway Overrun Prevention (ROP)

vRAAS ROP mirrors real-world behavior — for Airbus aircraft the callouts match the Airbus ROPS specification ([see Airbus Safety First — Further preventing runway overrun](https://safetyfirst.airbus.com/further-preventing-runway-overrun/)), including the "Step 2" and "Step 2+" rollout alerts below.

#### On Approach (below ~400 ft AGL)

19. **If-Wet Runway Too Short** _(Airbus)_  
    Advisory that the runway would be too short if wet:  
    **_"IF WET: RUNWAY TOO SHORT"_**

20. **Runway Too Short — Caution** _(Airbus)_  
    Dry landing distance exceeds runway length available (amber):  
    **_"RUNWAY TOO SHORT"_**

21. **Runway Too Short — Warning** _(Airbus, below ~200 ft)_  
    Landing distance still exceeds runway available (red):  
    **_"RUNWAY TOO SHORT"_**

22. **Overrun — Go Around** _(Boeing)_  
    Landing distance exceeds runway available — commands a go-around:  
    **_"OVERRUN! GO AROUND!"_**

#### On Rollout (above ~30 kt)

23. **Max Braking** _(Airbus, Step 2)_  
    Overrun risk detected without braking applied:  
    **_"BRAKE! MAX BRAKING! MAX BRAKING!"_**

24. **Set Max Reverse** _(Airbus, Step 2+)_  
    Braking applied but reverse thrust not yet set:  
    **_"SET MAX REVERSE!"_**

25. **Keep Max Reverse** _(Airbus, 30–80 kt)_  
    Below 80 kt with overrun risk still present, reinforcing reverse usage:  
    **_"KEEP MAX REVERSE!"_**

26. **Speedbrake** _(Boeing)_  
    Overrun risk with speedbrakes not deployed:  
    **_"SPEEDBRAKE! SPEEDBRAKE!"_**

27. **Max Brakes, Max Reverse** _(Boeing)_  
    Overrun risk with speedbrakes deployed but braking or reverse insufficient:  
    **_"MAX BRAKES! MAX REVERSE!"_**

### Autobrake Monitoring (new in v1.3)

28. **Autobrake Off**  
    Warns if the autobrake disengages during rollout above ~33 kt — useful to catch accidental disarming before reaching taxi speed:  
    **_"AUTOBRAKE OFF"_**

---

### Why Choose vRAAS?

Compared to other RAAS add-ons on the market, **vRAAS** offers the following benefits:

- **RAAS display on PFD/ND for many aircraft**  
  _View RAAS alerts directly on your PFD/ND, enhancing in-flight awareness._

- **Runway Overrun Prevention (ROP) on supported aircraft**  
  _Predictive stopping-distance alerts during landing, shown directly on the PFD alongside audio callouts._

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
  _vRAAS ties the self-test to the aircraft power state, but some aircraft don't expose the required variables — in those cases the timing may be slightly off. You can also disable the self-test on the **General Settings** page._


### Any further questions? Ideas? Join our Discord!
[<img width="200" src="https://github.com/user-attachments/assets/4df0b494-7c98-4a4c-b677-b22b63523ad6">](http://discord.land3simulations.com/)

---

###### Impressum (Imprint)

To comply with German law, please refer to our [Impressum](http://land3simulations.com/impressum.html) for legal details.


