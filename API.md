vRAAS provides LVARs to MSFS for all possible display texts. These can be used by other developers to display RAAS text anywhere.
If you are an aircraft developer, you can use this to natively integrate RAAS into your Terrain Display.

### LVARs

Most LVARs contain simple bool (1/0, on/off), indicating if something should be shown or not.

| LVAR                 | Value    | Comment                                                                                                             |
|----------------------|----------|----------------------------------------------------------------------------------------------------------------------|
| RAAS_TEXT_GREEN      | 0/1      | SHOW RAAS TEXT IN COLOR GREEN                                                                                       |
| RAAS_TEXT_YELLOW     | 0/1      | SHOW RAAS TEXT IN COLOR YELLOW                                                                                      |
|                      |          | The two above should be used as a "master" LVAR. Only one of these can be 1 at a time (XOR). Only show the text when one is 1. |
|                      |          |                                                                                                                     |
| RAAS_RWY_NUMBER      | 0, 1-36  | Runway number to be appended to RAAS_ON and RAAS_APP                                                                |
| RAAS_RWY_DESIGNATOR  | 0,1,2,3  | Runway designator (0 = none, 1=L, 2=C, 3=R) to be appended to RAAS_RWY_NUMBER                                       |
| RAAS_APPEND_NUMBER   | 0,1-99   | Remaining/available runway length on short runway. Only displayed when > 0                                          |
| RAAS_AUTO_POPUP      | 0/1      | (Optional) 1 when a caution message should auto-enable the terrain display                                          |
|                      |          |                                                                                                                     |
|                      |          | The following LVARs indicate which message to display. The displayed text is the same as the LVAR name (replace _ with space). |
| RAAS_APP_RWYS        | 0 / 1    | "APP RWYS"                                                                                                         |
| RAAS_APP             | 0 / 1    | "APP" + RWY_NUMBER + RWY_DESIGNATOR + RAAS_APPEND_NUMBER. See example below                                        |
| RAAS_ON              | 0 / 1    | "ON" + RWY_NUMBER + RWY_DESIGNATOR + RAAS_APPEND_NUMBER                                                             |
| RAAS_ON_RWYS         | 0 / 1    |                                                                                                                     |
| RAAS_SHORT_RUNWAY    | 0 / 1    |                                                                                                                     |
| RAAS_ON_TAXIWAY      | 0 / 1    |                                                                                                                     |
| RAAS_TAXIWAY         | 0 / 1    |                                                                                                                     |
| RAAS_FLAPS           | 0 / 1    |                                                                                                                     |
| RAAS_TOO_HIGH        | 0 / 1    | "TOO HIGH"                                                                                                          |
| RAAS_TOO_FAST        | 0 / 1    | "TOO FAST"                                                                                                          |
| RAAS_UNSTABLE        | 0 / 1    |                                                                                                                     |
| RAAS_ALTM_SETTING    | 0 / 1    |                                                                                                                     |
| RAAS_LONG_LANDING    | 0 / 1    |                                                                                                                     |
| RAAS_DEEP_LANDING    | 0 / 1    |                                                                                                                     |
| RAAS_RAAS_OK_FT      | 0 / 1    |                                                                                                                     |
| RAAS_RAAS_OK_M       | 0 / 1    |                                                                                                                     |
| RAAS_RAAS_INOP       | 0 / 1    | "RAAS-INOP"                                                                                                         |
| RAAS_RAAS_N_AVBL     | 0 / 1    | "RAAS-N-AVBL"                                                                                                       |
| RAAS_RAAS_RTO        | 0 / 1    | "RAAS-RTO"                                                                                                          |
| RAAS_RAAS_INHIBIT    | 0 / 1    | "RAAS-INH"                                                                                                          |

### Specials

The "APP ..." and "ON ..." messages are slightly more complicated than the other ones.<br />
First, append the runway number (01-36). Make sure to add a leading 0 if needed.<br />
Then append the RWY_DESIGNATOR (L/C/R) with no space between the number and designator.<br />
In case of a short runway, the RAAS_APPEND_NUMBER will be above 0.<br />
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
