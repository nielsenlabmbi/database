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
  - select
  - source and description name: ephysDatabase
  - select TCP/IP Server
  - provide username and password
  - select 'ferretphysiology' as database




## fields in ephysDatabase
schema: ferretphysiology
documentation in Excel file: fieldDescriptions 
