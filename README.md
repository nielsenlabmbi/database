# ephys database

## involved databases
MySql: 172.30.4.71 port 3306, username nielsenlab
Access: ferretDatabase on Z, no username

## initial set up of database access in matlab
- install database explorer toolbox
- Access database:
  - select 'new ODBC data source' under connect
  - select 'add'
  - select 'MS Access Driver'
  - source and description name: ferretDatabase
  - select ferretDatabase.accdb on Z
- MySqldatabase: 
  - select 'new ODBC data source' under connect
  - select 'add'
  - select MySQL ODBC Ansi 8.0 driver
  - source and description name: ephysDatabase
  - select TCP/IP Server
  - provide username and password
  - select 'ferretphysiology' as database
If the MySQL driver is not available, install it from here:
https://dev.mysql.com/doc/connector-odbc/en/connector-odbc-installation-binary-windows.html
It is sufficient to choose 'custom' and only install the ODBC connector (choose the newest one, X64 works).


## fields in ephys database
schema: ferretphysiology
documentation in Excel file: fieldDescriptions

## example searches
- find experiment with multiple recording sites:
  SELECT tblexperiment.experimentID,tblexperiment.unitNr,tblexperiment.experimentNr
  FROM (ferretphysiology.tblexperiment
  INNER JOIN ferretphysiology.tblrecording 
  ON tblrecording.experimentKey=tblexperiment.experimentKey)
  WHERE tblrecording.recSite IN ('V1','PSS')
  GROUP BY tblrecording.experimentKey
  HAVING COUNT(*)=2

- find experiment with particular looper variable
  as the first looper parameter:
  WHERE looperName1 LIKE '%ori%'
  in any looper parameter:
  WHERE 'ori' in (looperName1,looperName2,looperName3,looperName4,looperName5)         

- find experiment with looper variable setting
  WHERE concat_ws('|',looperVal1,looperVal2,looperVal3) LIKE '%0:30%'

- find animals based on recording site, age and experiment
  SELECT tblexperiment.experimentId,tblexperiment.unitNr,tblexperiment.experimentNr
  FROM ((ferretphysiology.tblexperiment
  INNER JOIN ferretphysiology.tblanimal
  ON tblexperiment.experimentId = tblanimal.experimentId)
  INNER JOIN ferretphysiology.tblrecording
  ON tblexperiment.experimentKey = tblrecording.experimentKey)
  WHERE tblanimal.age >= 37
  AND tblrecording.recSite = 'V1'
  AND 'ori' IN (looperName1,looperName2)
  AND (looperVal1 LIKE '%0:22.5%' OR looperVal2 LIKE '%0:22.5%')
  AND  spikeSorted=1