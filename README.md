## vRAAS for MSFS

Enhance your flight simulation experience with **vRAAS**, a virtual Runway Awareness and Advisory System designed to replicate the functionality of real-world systems, delivering runway alerts and advisories directly within MSFS. Every feature operates **exactly** like its real counterpart and can be easily customized or disabled to suit your preferences.

### Key Features:

- **Full Compatibility**: Works seamlessly with all airports, including add-ons, and supports all aircraft types—no configuration required.
- **In-Sim Text Display**: Displays alerts on the PFD/ND (see limitations below).
- **Effortless Setup**: No manual setup needed—simply install and fly.
- **Auto-Updating**: Stay up-to-date with automatic software and configuration updates.
- **Aircraft-Specific Configurations**: Automatically downloads aircraft-specific settings.
- **Multiple Voice Options**: Choose from male or female voice callouts for a personalized experience.
- **Highly Customizable**: Tailor the system settings to your preferences with ease.
- **Convenient Automation**: Includes options for auto-start, auto-close, and minimize-to-tray functionality.
- **No Performance Impact**: Enjoy realistic alerts with no noticeable effect on FPS.
- **Flexible Audio**: Select any Windows sound output device for audio alerts.
- **Built-in Self-Test**: Ensure functionality with a reliable self-test feature.

### Known Limitations:

- **Experimental PFD/ND Text Display**: The text display on the PFD/ND is currently experimental and may be affected by future MSFS updates.
- **_TOO FAST_ Callout Limitations**: Due to MSFS constraints, the _TOO FAST_ warning is only supported on certain aircraft.

### Compatibility with MSFS 2024:

vRAAS has been tested with the MSFS 2024 Tech Alpha, and all features performed as expected. However, until the final version is available, we cannot guarantee full compatibility with MSFS 2024.


## Aircraft compatiblity list

Generally, vRAAS audio calls work with all aircraft, including 3rd party addons.
However, some features require additional configuration or fine-tuning.
The following aircraft will work perfectly without any configuration from your side.

**vRAAS Audio**: Audio calls, generally available for all aircraft
**vRAAS Display**: In-Game RAAS text messages displayed on PFD or ND 

| Developer                 | Aircraft                   	| vRAAS Audio 	| vRAAS Display | NOTE 	|
|---------------------------|----------------------------|:----------:|:------------:|------|
| FlyByWire                   | A320neo                    |      ✅     	|       ✅      |1)      	|
| Fenix                       | A319/A320/A321             |      ✅     	|       ✅      |1)      	|
| FlightSimStudio FSS         | E170/E175/E190(F)/E195(F)  |      ✅     	|       ✅      |      	|
| FlightSimStudio FSS         | B727                       |      ✅     	|       ❌      |1)  No displays to show vRAAS Text. |
| Horizon Simulations         | B787                       |      ✅     	|       ✅      |      	|
| IniBuilds A306F             | A306F                      |      ✅     	|       ✅      |1)      	|
| iFly			               | B737-MAX8                  |      ⚠️     	|       ⚠️      |1)  RAAS included in aircraft. vRAAS disabled by default.       	|
| Leonardo                    | MADDOX X                   |      ✅     	|       ✅      |      	|
| LatinVFR                    | A330-900neo                |      ✅     	|       ✅      |1)      	|
| Headwind Simulations        | A330neo					     |      ✅     	|       ✅      |      	|
| Microsoft / Default         | A310                       |      ✅     	|       ✅      |1)      	|
| Asobo / Default             | B747-8i                    |      ✅     	|       ✅      |1)      	|
| Asobo / Default             | B787-9                     |      ✅     	|       ✅      |1)          |   
| Asobo / Default             | A320neo                    |      ✅     	|       ✅      |1)      	|
| Asobo / Default             | CJ4                        |      ✅     	|       ✅      |1)      	|
| Asobo / Default             | Citation Longitude         |      ✅     	|       ✅      |1)      	|
| Asobo / Default             | C208 Grand Caravan         |      ✅     	|       ✅      |1)      	|
| PMDG                        | B737 (ALL VARIANTS)        |      ✅     	|       ✅      |      	|
| PMDG                        | B777                       |      ✅     	|       ✅      |      	|
| ProSim                      | B738                       |      ✅     	|       ❌      |1)  vRAAS cannot access ProSim Display. |

1\) **_TOO FAST_** callout during approach is currently not available for this aircraft due to missing data from add-on.

Your favourite aircraft is not listed? Feel free to send a request on our Discord!

## Available Callouts

0. **Self Test**  
   Checks if vRAAS is working properly and announces unit used for distance calls  
   **_“RUNWAY AWARESS OKAY - METER / FEET”_**

### Ground Operations

1. **Approaching Runway (on Ground)**  
   Informs when approaching a runway during taxi operations.  
   **_“APPROACHING RUNWAY 25 LEFT”_**

2. **On Runway**  
   Confirms runway location when the aircraft is lining up on the runway.  
   **_“ON RUNWAY 25 LEFT”_**

3. **Takeoff Flaps Configuration**  
   Advises if lining up on a runway without a valid flaps setting for takeoff.  
   **_“ON RUNWAY 25 LEFT. FLAPS! FLAPS!_**

4. **Extended Hold on Runway**  
   Cautions the crew if the aircraft holds on the runway for an extended time.  
   **_“ON RUNWAY 25 LEFT. ON RUNWAY 25 LEFT._**

5. **Insufficient Runway Length on Ground**  
   Warns of insufficient runway length for takeoff.   
   **_“ON RUNWAY 25 LEFT. 500 METERS/FEET REMAINING”_**

6. **Short Runway Takeoff Warning**  
   Alerts when the remaining runway length is shorter that the nominal runway length.  
   **_“SHORT RUNWAY! SHORT RUNWAY!”_**

7. **Distance Remaining (Rejected Takeoff)**  
   Announces runway distance remaining after a rejected takeoff.  
   **_“1500 ... 1200 ... 900 ...”_** (meters or feet)

8. **Taxiway Takeoff (Advisory)**  
   Advises when the aircraft is not on a runway and accelerating for takeoff.  
   **_“ (CAUTION!) ON TAXIWAY! ON TAXIWAY!”_**
### Approach and Landing

10. **Approaching Runway (Landing)**  
    Informs when the aircraft is approaching a runway during landing.  
    **_“APPROACHING 25 LEFT”_**

11. **Approaching Short Runway**  
    Runway length is less than nominal landing runway length.  
    **_“APPROACHING 25 LEFT, 1400M AVAILABLE”_**

12. **Short Runway Landing**  
    Aircraft is on final approach to a short runway.  
    **_“CAUTION SHORT RUNWAY, SHORT RUNWAY!”_**

13. **Taxiway Landing**  
    Warns if the aircraft is not lined up with a runway on landing.  
    **_“CAUTION TAXIWAY! CAUTION TAXIWAY!”_**

14. **Distance Remaining (Landing & Rollout)**  
    Announces the remaining runway distance during landing and rollout.  
    **_“ONE THOUSAND, FIVE HUNDRED”_** (METERS/FEET REMAINING)

### In-Flight Approach Warnings

15. **Landing Flaps Not Set**
    Warns if landing flaps have not been set.  
    **_“FLAPS, FLAPS”_**

17. **Too High on Approach**  
    Alerts the crew if the aircraft is too high on the approach path.  
    **_“TOO HIGH, TOO HIGH”_**

18. **Too Fast on Approach**  
    Warns if the aircraft is approaching too fast for a safe landing.   
    **_“TOO FAST, TOO FAST”_**

19. **Unstable Approach**  
    Alerts of an unstable approach due to improper speed, flaps setting or approach angle.  
    **_“UNSTABLE, UNSTABLE”_**

20. **Long (or Deep) Landing**  
    Warns if the aircraft has touched down far from the runway threshold, reducing available stopping distance.  
    **_“LONG LANDING, LONG LANDING”_** or **_“DEEP LANDING, DEEP LANDING”

### Altimeter and Setting Alerts

21. **Altimeter Setting (Climb + Descend)**  
    Warns if the altimeter is not set properly.  
    **_“ALTIMETER SETTING”_**

## FAQ
### Activation / Serial 
#### Is an active internet connection required? 
Internet connection is required to activate the product on first launch.

### General
#### Do I have to launch it manually each time I want to fly? 
The vRAAS process needs to be running for RAAS to work, but there is an auto-start option available in the general settings tab.  
You can also select the _Minimize to tray_ , _Start minimized_ and _auto-close_ options. That way, you'll not need to interact with the vRAAS window at all.

#### Does vRAAS reduce the fps?
We could not measure any reduction in fps.  
There have been no reports of any performance issues.

#### How can I change the unit to feet?
Main Window -> RAAS Features -> ALL AIRCRAFT -> Units
