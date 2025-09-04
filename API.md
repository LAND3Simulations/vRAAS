vRAAS provides LVARs to MSFS for all possible display texts. These can be used by other developers to display RAAS text anywhere.
If you are an aircraft developer, you can use this to natively integrate RAAS into your Terrain Display.

### LVARs

Most LVARs contain simple bool (1/0, on/off), indicating if something should be shown or not.

| LVAR                 | Value    | Comment                                                                                                             |
|----------------------|----------|----------------------------------------------------------------------------------------------------------------------|
| VRAAS_TEXT_GREEN      | 0/1      | SHOW RAAS TEXT IN COLOR GREEN                                                                                       |
| VRAAS_TEXT_YELLOW     | 0/1      | SHOW RAAS TEXT IN COLOR YELLOW                                                                                      |
|                      |          | The two above should be used as a "master" LVAR. Only one of these can be 1 at a time (XOR). Only show the text when one is 1. |
|                      |          |                                                                                                                     |
| VRAAS_RWY_NUMBER      | 0, 1-36  | Runway number to be appended to VRAAS_ON and VRAAS_APP                                                                |
| VRAAS_RWY_DESIGNATOR  | 0,1,2,3  | Runway designator (0 = none, 1=L, 2=C, 3=R) to be appended to VRAAS_RWY_NUMBER                                       |
| VRAAS_APPEND_NUMBER   | 0,1-99   | Remaining/available runway length on short runway. Only displayed when > 0                                          |
| VRAAS_AUTO_POPUP      | 0/1      | (Optional) 1 when a caution message should auto-enable the terrain display                                          |
|                      |          |                                                                                                                     |
|                      |          | The following LVARs indicate which message to display. The displayed text is the same as the LVAR name (replace _ with space). |
| VRAAS_APP_RWYS        | 0 / 1    | "APP RWYS"                                                                                                         |
| VRAAS_APP             | 0 / 1    | "APP" + RWY_NUMBER + RWY_DESIGNATOR + VRAAS_APPEND_NUMBER. See example below (e.g. APP 01C)                         |
| VRAAS_ON              | 0 / 1    | "ON" + RWY_NUMBER + RWY_DESIGNATOR + VRAAS_APPEND_NUMBER (e.g. ON 25R)                                              |
| VRAAS_ON_RWYS         | 0 / 1    | "ON RWYS"                                                                                                          |
| VRAAS_SHORT_RUNWAY    | 0 / 1    | "SHORT RUNWAY"                                                                                                     |
| VRAAS_ON_TAXIWAY      | 0 / 1    | "ON TAXIWAY"                                                                                                       |
| VRAAS_TAXIWAY         | 0 / 1    | "TAXIWAY"                                                                                                          |
| VRAAS_FLAPS           | 0 / 1    | "FLAPS"                                                                                                             |
| VRAAS_TOO_HIGH        | 0 / 1    | "TOO HIGH"                                                                                                          |
| VRAAS_TOO_FAST        | 0 / 1    | "TOO FAST"                                                                                                          |
| VRAAS_UNSTABLE        | 0 / 1    | "UNSTABLE"                                                                                                          |
| VRAAS_ALTM_SETTING    | 0 / 1    | "ALTM SETTING"                                                                                                      |
| VRAAS_LONG_LANDING    | 0 / 1    | "LONG LANDING"                                                                                                      |
| VRAAS_DEEP_LANDING    | 0 / 1    | "DEEP LANDING"                                                                                                      |
| VRAAS_RAAS_OK_FT      | 0 / 1    | "RAAS-OK-FT"                                                                                                        |
| VRAAS_RAAS_OK_M       | 0 / 1    | "RAAS-OK-M"                                                                                                         |
| VRAAS_RAAS_INOP       | 0 / 1    | "RAAS-INOP"                                                                                                         |
| VRAAS_RAAS_N_AVBL     | 0 / 1    | "RAAS-N-AVBL"                                                                                                       |
| VRAAS_RAAS_RTO        | 0 / 1    | "RAAS-RTO"                                                                                                          |
| VRAAS_RAAS_INHIBIT    | 0 / 1    | "RAAS-INH"                                                                                                          |

### Specials

The "APP ..." and "ON ..." messages are slightly more complicated than the other ones.<br />
First, append the runway number (01-36). Make sure to add a leading 0 if needed.<br />
Then append the RWY_DESIGNATOR (L/C/R) with no space between the number and designator.<br />
In case of a short runway, the VRAAS_APPEND_NUMBER will be above 0.<br />
In this case, add one space and then the number.<br />

The result could look like this:<br />
**APP 25R 9** (900 m/ft runway available)<br />
**ON 07 18** (1800 m/ft runway remaining)<br />
**ON 36** <br />

### Aligning

Most of the messages are displayed centered on the Terrain display.<br />
However, the _APP RWYS, APP XX, ON RWYS, and ON XX_ will be centered around the first empty space.
It should look like this:

![grafik](https://github.com/user-attachments/assets/baf3b861-ed15-48a7-8627-17574df9f2f6)

### Font / Colors
I'm using the following colors, but feel free to adjust them to exactly match those used in your terrain display.<br />
Green: #00CC00<br />
Yellow: #FFBF00<br />

The font I'm using is called VCR_OSD_MONO, and you can easily find it online.<br />
In case you are using a different font, make sure to use a monospaced one. Otherwise, it may look strange.

As a reference, this is the RAAS Self-Test on a real A320neo:
![IMG_5916](https://github.com/user-attachments/assets/9cd6a68c-d545-4f3f-8983-eddde62d743e)

