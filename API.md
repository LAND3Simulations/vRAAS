vRAAS provides LVARs for all possible display texts. These can be used by other developers to display RAAS Text whereever they want.  

Most LVARs contain simple bool (1/0, on/off) , indicating if something should be shown or not.

| LVAR                	| Value   	| Comment                                                                                                            	|
|---------------------	|---------	|--------------------------------------------------------------------------------------------------------------------	|
| RAAS_TEXT_GREEN     	| 0/1     	| SHOW RAAS TEXT IN COLOR GREEN                                                                                      	|
| RAAS_TEXT_YELLOW    	| 0/1     	| SHOW RAAS TEXT IN COLOR YELLOW                                                                                     	|
|                     	|         	| The two above should be used a "master" LVAR. Only one of those can be 1 at a time (XOR). Only show the text when one is 1 	|
| RAAS_RWY_NUMBER     	| 0, 1-36 	| Runway number to be appended to RAAS_ON and RAAS_APP                                                               	|
| RAAS_RWY_DESIGNATOR 	| 0,1,2,3 	| Runway designator (0 = none, 1=L, 2=C, 3=R) to be appended to RAAS_RWY_NUMBER                                      	|
| RAAS_AUTO_POPUP     	| 0/1     	| (Optional) 1 when a caution-message should auto-enable the terrain display                                          	|
|                     	|         	|                                                                                                                    	|
| RAAS_APP_RWYS            	|0 / 1      |                                                                                                                    	|
| RAAS_APP                 	|0 / 1      |                                                                                                                    	|
| RAAS_ON                  	|0 / 1      |                                                                                                                    	|
| RAAS_ON_RWYS             	|0 / 1      |                                                                                                                    	|
| RAAS_SHORT_RUNWAY        	|0 / 1      |                                                                                                                    	|
| RAAS_ON_TAXIWAY          	|0 / 1      |                                                                                                                    	|
| RAAS_TAXIWAY             	|0 / 1      |                                                                                                                    	|
| RAAS_FLAPS               	|0 / 1      |                                                                                                                    	|
| RAAS_TOO_HIGH            	|0 / 1      |                                                                                                                    	|
| RAAS_TOO_FAST            	|0 / 1      |                                                                                                                    	|
| RAAS_UNSTABLE            	|0 / 1      |                                                                                                                    	|
| RAAS_ALTM_SETTING        	|0 / 1      |                                                                                                                    	|
| RAAS_LONG_LANDING        	|0 / 1      |                                                                                                                    	|
| RAAS_DEEP_LANDING        	|0 / 1      |                                                                                                                    	|
| RAAS_RAAS_OK_FT          	|0 / 1      |                                                                                                                    	|
| RAAS_RAAS_OK_M           	|0 / 1      |                                                                                                                    	|
| RAAS_RAAS_INOP           	|0 / 1      |                                                                                                                    	|
| RAAS_RAAS_N_AVBL         	|0 / 1      |                                                                                                                    	|
| RAAS_RAAS_RTO            	|0 / 1      |                                                                                                                    	|
| RAAS_RAAS_INHIBIT        	|0 / 1      |                                                                                                                    	|
