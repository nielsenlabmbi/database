classdef enterExperimentDB_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        EnterexperimentPanel          matlab.ui.container.Panel
        EartagEditFieldLabel          matlab.ui.control.Label
        Eartag                        matlab.ui.control.EditField
        ExperimentIDEditFieldLabel    matlab.ui.control.Label
        ExperimentID                  matlab.ui.control.EditField
        Terminal                      matlab.ui.control.CheckBox
        ExperimentDurDropDownLabel    matlab.ui.control.Label
        ExperimentDur                 matlab.ui.control.DropDown
        InactivationPanel             matlab.ui.container.Panel
        Inactivation                  matlab.ui.control.CheckBox
        MethodDropDownLabel           matlab.ui.control.Label
        InactivationMethod            matlab.ui.control.DropDown
        AreaEditFieldLabel            matlab.ui.control.Label
        InactivationArea              matlab.ui.control.EditField
        StimulationPanel              matlab.ui.container.Panel
        Stimulation                   matlab.ui.control.CheckBox
        MethodDropDownLabel_2         matlab.ui.control.Label
        StimulationMethod             matlab.ui.control.DropDown
        AreaEditFieldLabel_2          matlab.ui.control.Label
        StimulationArea               matlab.ui.control.EditField
        TrainingPanel                 matlab.ui.container.Panel
        Training                      matlab.ui.control.CheckBox
        StimulusLabel                 matlab.ui.control.Label
        TrainingStim                  matlab.ui.control.DropDown
        MovingLabel                   matlab.ui.control.Label
        TrainingStimMoving            matlab.ui.control.DropDown
        Warning                       matlab.ui.control.CheckBox
        ExperimentDateLabel           matlab.ui.control.Label
        ExperimentDate                matlab.ui.control.DatePicker
        AreasPanel                    matlab.ui.container.Panel
        V1CheckBox                    matlab.ui.control.CheckBox
        PSSCheckBox                   matlab.ui.control.CheckBox
        S1CheckBox                    matlab.ui.control.CheckBox
        LGNCheckBox                   matlab.ui.control.CheckBox
        otherCheckBox                 matlab.ui.control.CheckBox
        OtherArea                     matlab.ui.control.EditField
        Access                        matlab.ui.control.Button
        Docs                          matlab.ui.control.Button
        Expsql                        matlab.ui.control.Button
        SettingsPanel                 matlab.ui.container.Panel
        AccessTest                    matlab.ui.control.Button
        Lamp                          matlab.ui.control.Lamp
        mySqlTest                     matlab.ui.control.Button
        Lamp_2                        matlab.ui.control.Lamp
        AnalyzerPathEditFieldLabel    matlab.ui.control.Label
        AnalyzerPath                  matlab.ui.control.EditField
        BrowseAnalyzer                matlab.ui.control.Button
        configDB                      matlab.ui.control.Button
        SpikedatapathEditFieldLabel   matlab.ui.control.Label
        SpikePath                     matlab.ui.control.EditField
        BrowseSpike                   matlab.ui.control.Button
        EnterspikesAllfilesforanimalPanel  matlab.ui.container.Panel
        ExperimentIDEditFieldLabel_2  matlab.ui.control.Label
        ExperimentIDSpikeAll          matlab.ui.control.EditField
        SpikeAllSql                   matlab.ui.control.Button
        Enterspikes1fileonlyPanel     matlab.ui.container.Panel
        ExperimentIDEditFieldLabel_3  matlab.ui.control.Label
        ExperimentIDSpike1            matlab.ui.control.EditField
        Spike1Sql                     matlab.ui.control.Button
        UnitLabel                     matlab.ui.control.Label
        UnitSpike1                    matlab.ui.control.EditField
        ExperimentLabel               matlab.ui.control.Label
        ExpSpike1                     matlab.ui.control.EditField
        SelectSpike1                  matlab.ui.control.Button
        SelectdatafileLabel           matlab.ui.control.Label
        orenterinfoLabel              matlab.ui.control.Label
        PaperDataPanel                matlab.ui.container.Panel
        HelpPaper                     matlab.ui.control.Button
        ReadData                      matlab.ui.control.Button
        FigureEditFieldLabel          matlab.ui.control.Label
        FigureNr                      matlab.ui.control.NumericEditField
        PaperLabel                    matlab.ui.control.Label
        PaperName                     matlab.ui.control.EditField
        addPaper                      matlab.ui.control.Button
        DatafilecolumnDropDownLabel   matlab.ui.control.Label
        DatafileColumn                matlab.ui.control.DropDown
        ProbecolumnDropDownLabel      matlab.ui.control.Label
        ProbeColumn                   matlab.ui.control.DropDown
        UnitcolumnDropDownLabel       matlab.ui.control.Label
        UnitColumn                    matlab.ui.control.DropDown
        DataTable                     matlab.ui.control.Label
        FulljournalnameandyearLabel   matlab.ui.control.Label
        AreacolumnDropDownLabel       matlab.ui.control.Label
        AreaColumn                    matlab.ui.control.DropDown
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: AccessTest
        function AccessTestPushed(app, event)
            conn=database('ferretDatabase','','');
            if isempty(conn.Message)
                app.Lamp.Color='green';
            else
                app.Lamp.Color='red';
            end
            close(conn);
        end

        % Button pushed function: mySqlTest
        function mySqlTestPushed(app, event)
            conn=database('clusterdb','kristina','Oregon101');
            if isempty(conn.Message)
                app.Lamp_2.Color='green';
            else
                app.Lamp_2.Color='red';
            end
            close(conn);
        end

        % Button pushed function: configDB
        function configDBButtonPushed(app, event)
            configureODBCDataSource
        end

        % Button pushed function: BrowseAnalyzer
        function BrowseAnalyzerPushed(app, event)
            anapath=uigetdir;
            if anapath(1)~=0
                app.AnalyzerPath.Value=anapath;
            end
        end

        % Button pushed function: BrowseSpike
        function BrowseSpikePushed(app, event)
            spikepath=uigetdir;
            if spikepath(1)~=0
                app.SpikePath.Value=spikepath;
            end
        end

        % Button pushed function: Access
        function AccessPushed(app, event)
            %update access database (baseinfo and experiment table)
            
      
            
            %get info from fields
            animalId=app.Eartag.Value;
            expId=app.ExperimentID.Value;
            expDate=app.ExperimentDate.Value;
            expDate=datestr(datenum(expDate),31); %correct format for database
            terminalExp=app.Terminal.Value;
            expDur=app.ExperimentDur.Value;
            
            
            %open database
            conn=database('ferretDatabase','','');
            if ~isempty(conn.Message)
                uialert(app.UIFigure,'Cannot open Access Database!','Error')
                return;
            end
            
            %enter new info into experiment table
            %first check whether this has happened already:
            sqlquery=['SELECT Eartag FROM tblExperimentInfo WHERE Eartag=''', animalId, ''''];
            data=select(conn,sqlquery);
            
            if ~isempty(data)
                uialert(app.UIFigure,'Animal already entered, did not proceed','Error');
                return;
            end
            eTnames={'Eartag','[Experiment ID]','[Experiment date]','Experiment','Room','Duration'};
            eTval={animalId,expId,expDate,'Physiology','352A',expDur};
            
            etab=cell2table(eTval);
            etab.Properties.VariableNames=eTnames;
            sqlwrite(conn,'tblExperimentInfo',etab);
            
            %also update base info - enter disposed date (if terminal); only update if
            %experiment was also entered in the database to avoid unnecessary updates
            if terminalExp
                %need to correctly transform date
                update(conn,'tblBaseInfo',{'Disposed','Reason','Cage'},{expDate,'Terminal exp.',''},['WHERE Eartag=''', animalId, '''']);
            end
            
            uiconfirm(app.UIFigure,'Animal database updated.','Confirm done');
                      
            close(conn);
            
            
        end

        % Button pushed function: Docs
        function DocsPushed(app, event)
            
            uiconfirm(app.UIFigure,{'1. Scan animal info, vitals and experiment documents';...
                '2. Copy animal info to Z:\database\animal information';...
                '3. Add link to animal info in access database (Update animal -> animal record)';...
                '4. Copy vitals to Z:\ephys new\vitals';...
                '5. Add link to vitals in access database (Enter experiment -> experiment vitals)';...
                '6. Copy experiment documents to Z:\ephysnew\note scans';...
                '7. Enter experiment documents in ferret physiology notebox in onenote'},'Update docs');
            
        end

        % Button pushed function: Expsql
        function ExpsqlPushed(app, event)
            
            wb=uiprogressdlg(app.UIFigure,'Title','Updating mySql database...','Message','Entering animal info');
            
            
            %get info from fields
            %for tblanimal
            animalId=app.Eartag.Value;
            expId=app.ExperimentID.Value;
            eDate=app.ExperimentDate.Value;
            if ~isempty(eDate)
                eDate=datestr(datenum(eDate),31); %correct format for database
            end
            inactSel=app.Inactivation.Value;
            stimSel=app.Stimulation.Value;
            trainSel=app.Training.Value;
                    
                       
            
            % get additional stuff from the access database
            conn=database('ferretDatabase','','');
            if ~isempty(conn.Message)
                uialert(app.UIFigure,'Cannot open Access Database!','Error')
                return;
            end
            
            %basic info: DOB, sex, eye opening
            sqlquery=['SELECT Sex, DOB, [Eyes open] ' ...
                'FROM tblBaseInfo WHERE Eartag=''', animalId, ''''];
            baseData=select(conn,sqlquery);
           
            if isempty(baseData)
                uialert(app.UIFigure,'Could not find animal information!','Error in access db');
                close(wb);
                return;
            end
           
            %rearing information
            sqlquery=['SELECT DR, [DR start], [DR stop], LE, [LE start], [LE stop], RE, [RE start], [RE stop] ' ...
                'FROM tblRearingInfo WHERE Eartag=''', animalId, ''''];
            rearingData=select(conn,sqlquery);
            
            if isempty(rearingData)
                uialert(app.UIFigure,'Could not find rearing information for animal!','Error in access db');
                close(wb);
                return;
            end
            
            baseData=[baseData rearingData];
            
            close(conn);
            
                     
            %open mysql database
            conn1=database('clusterdb','kristina','Oregon101');
            if ~isempty(conn1.Message)
                uialert(app.UIFigure,'Cannot open Access Database!','Error')
                close(wb);
                return;
            end
            
            %first check whether animal was already entered - do not
            %proceed if this is the case
            sqlquery=['SELECT animalkey FROM tblanimal WHERE experimentid=''', expId, ''''];
            testData=select(conn1,sqlquery);
            if ~isempty(testData)
                uialert(app.UIFigure,'Experiment already entered!','Error');
                close(wb);
                return;
            end
                       
            %add rest of animal information (this comes from this gui)
            eartag={animalId};
            experimentid={expId};
            expdate={eDate};
            baseData=addvars(baseData,eartag,experimentid,expdate,'Before','Sex');
             
            %transform true/false vars to number so that sqlwrite works
            baseData.DR=int32(baseData.DR);
            baseData.LE=int32(baseData.LE);
            baseData.RE=int32(baseData.RE);
            
            %add age (to make searches easier)
            age=between(datetime(baseData.DOB),datetime(eDate),'days');
            age={caldays(age)};
            baseData=addvars(baseData,age);
             
            %add stim/inactivation/training flag
            if inactSel==1
                eMethod=app.InactivationMethod.Value;
                eArea=app.InactivationArea.Value;
                inactflag={int32(inactSel)};
                inactmethod={eMethod};
                inactarea={eArea};
                baseData=addvars(baseData,inactflag,inactmethod,inactarea);
            end
            
            if stimSel==1
                eMethod=app.StimulationMethod.Value;
                eArea=app.StimulationArea.Value;
                stimflag={int32(stimSel)};
                stimmethod={eMethod};
                stimarea={eArea};
                baseData=addvars(baseData,stimflag,stimmethod,stimarea);
            end
            
            if trainSel==1
                eStim=app.TrainingStim.Value;
                eMove=app.TrainingStimMoving.Value;
                trainflag={int32(trainSel)};
                trainstim={eStim};
                trainmove={eMove};
                baseData=addvars(baseData,trainflag,trainstim,trainmove);
            end
            
            %add warning flag
            warningflag={int32(app.Warning.Value)};
            baseData=addvars(baseData,warningflag);
            
            %add area flags
            v1flag={int32(app.V1CheckBox.Value)};
            pssflag={int32(app.PSSCheckBox.Value)};
            lgnflag={int32(app.LGNCheckBox.Value)};
            s1flag={int32(app.S1CheckBox.Value)};
            otherflag={int32(app.otherCheckBox.Value)};
            baseData=addvars(baseData,v1flag,pssflag,lgnflag,s1flag,otherflag);
            if app.otherCheckBox.Value==1
                eArea=app.OtherArea.Value;
                otherarea={eArea};
                baseData=addvars(baseData,otherarea);
            end
            
            %write animal-specific information
            sqlwrite(conn1,'tblanimal',baseData);
            
            wb.Value=.1;
            wb.Message='Entering experiment info';           
            
            %enter each experiment into tblexperiment
            %this needs to loop through all analyzer files for the animal
            fpath=fullfile(app.AnalyzerPath.Value, expId,[expId '*.analyzer']);
            expfiles=dir(fpath);
            nfiles=length(expfiles);
            
            for f=1:nfiles 
                wb.Value=.1+.9/nfiles*f;
                
                %open Analyzer file
                load(fullfile(expfiles(f).folder,expfiles(f).name),'-mat');
                if ~exist('Analyzer','var')
                    uialert(app.UIFigure,{'Cannot load Analyzer file!';fullfile(fpath,expfiles(f).name)},'Error')
                    close(wb);
                    return;
                end
                
                %disp(Analyzer);
                
                %first enter experiment info into tblexperiment
                %get data
                if isfield(Analyzer,'date')
                    analyzerDate=datestr(datenum(Analyzer.date),31); %correct format for database
                else
                    analyzerDate=eDate;
                end
                
                %get module
                if isfield(Analyzer,'modID')
                    module=Analyzer.modID;
                else
                    module=Analyzer.P.type;
                end
                
                %build table
                expData=table(experimentid,{Analyzer.M.unit},{Analyzer.M.expt},...
                    {analyzerDate},{module},{Analyzer.L.reps},{Analyzer.L.rand});
                
                expData.Properties.VariableNames={'experimentid','unit','experiment',...
                    'anadate','module','reps','trialrand'};
                
                nLoop=length(Analyzer.L.param);
                for i=1:nLoop
                    if length(Analyzer.L.param{i})==3
                        expData=addvars(expData,Analyzer.L.param{i}(1),Analyzer.L.param{i}(2),Analyzer.L.param{i}(3),...
                            'NewVariableNames',{['lname' num2str(i)],['lval' num2str(i)],['lblock' num2str(i)]});
                    else %old format doesn't have blocks
                        expData=addvars(expData,Analyzer.L.param{i}(1),Analyzer.L.param{i}(2),...
                            'NewVariableNames',{['lname' num2str(i)],['lval' num2str(i)]});
                    end
                end
                %write
                sqlwrite(conn1,'tblexperiment',expData);
                clear expData;
                
                
                %now add parameters into tblparams (params simply get
                %listed as name/value pairs plus experiment key)
                
                %get primary key of experiment
                selectquery=['SELECT expkey FROM tblexperiment ' ...
                    'WHERE experimentid="' expId ...
                    '" AND unit="' Analyzer.M.unit ...
                    '" AND experiment="' Analyzer.M.expt '"'];
                data=select(conn1,selectquery);
                
                %now parameters
                ptable{1,1}='expkey';
                ptable{1,2}='pname';
                ptable{1,3}='pval';
                
                pcount=2;
                for p=1:length(Analyzer.P.param)
                    %check whether it should be entered
                    if Analyzer.P.param{p}{4}==1
                        ptable{pcount,1}=int32(data.expkey);
                        ptable{pcount,2}=Analyzer.P.param{p}{1};
                        ptable{pcount,3}=num2str(Analyzer.P.param{p}{3});
                        pcount=pcount+1;
                    end
                end
                
                pout=cell2table(ptable(2:end,:));
                pout.Properties.VariableNames=ptable(1,:);
                %disp(pout)
      
                %write to table 
                sqlwrite(conn1,'tblparams',pout);
                
                clear ptable Analyzer;
                
                
            end
            
            
            close(conn1);
            close(wb);
            uiconfirm(app.UIFigure,'Experiment database updated.','Confirm done','icon','success');
     
        end

        % Button pushed function: SpikeAllSql
        function SpikeAllSqlPushed(app, event)
            wb=uiprogressdlg(app.UIFigure,'Title','Updating mySql database...','Message','Entering spike info');
            
            %get aninamal name and file path
            expId=app.ExperimentIDSpikeAll.Value;
            spikePath=app.SpikePath.Value;
            
            %find files
            fpath=fullfile(spikePath,expId,[expId '*_id.mat']);
            %disp(fpath)
            spikefiles=dir(fpath);
            nfiles=length(spikefiles);
            
            if nfiles==0
                uialert(app.UIFigure,'No spike id files found!','Error')
                close(wb);
                return;
            end
            
            %open mysql database
            conn1=database('clusterdb','kristina','Oregon101');
            if ~isempty(conn1.Message)
                uialert(app.UIFigure,'Cannot open Access Database!','Error')
                close(wb);
                return;
            end
            
            %loop through files
            for i=1:nfiles
                wb.Value=1/nfiles*i;
                
                %parse file name to get unit and experiment
                fparts=strsplit(spikefiles(i).name,'_');
                unitId=fparts{2}(2:4); %need to drop the leading u
                experiment=fparts{3};
                
                
                %get primary key of experiment
                selectquery=['SELECT expkey FROM tblexperiment ' ...
                    'WHERE experimentid="' expId ...
                    '" AND unit="' unitId ...
                    '" AND experiment="' experiment '"'];
                dataS=select(conn1,selectquery);
                
                if isempty(dataS)
                    uialert(app.UIFigure,'Could not find experiment information!','Error');
                    close(wb);
                    return;
                end
                
                %test whether the spike data has already been entered (only
                %need to do this once)
                if i==1
                    selectquery=['SELECT spikekey FROM tblspikes ' ...
                        'WHERE expkey="' num2str(dataS.expkey) '"'];                 
                    dataS2=select(conn1,selectquery);
                    if ~isempty(dataS2)
                        uialert(app.UIFigure,'Spike data already entered!','Error');
                        close(wb);
                        return;
                    end
                end
                
                %generate data entry
                ptable{1,1}='expkey';
                ptable{2,1}=int32(dataS.expkey);
                
                %load spike data file
                load(fullfile(spikefiles(i).folder,spikefiles(i).name));
                ptable{1,2}='loca';
                ptable{2,2}=id.probes(1).area;
                ptable{1,3}='probea';
                ptable{2,3}=id.probes(1).type;
                
                count=4;
                
                if length(id.probes)==2
                    ptable{1,4}='locb';
                    ptable{2,4}=id.probes(2).area;
                    ptable{1,5}='probeb';
                    ptable{2,5}=id.probes(2).type;
                    count=6;
                end
                
                ptable{1,count}='recsystem';
                if id.isBR==1
                    ptable{2,count}='blackrock';
                else
                    ptable{2,count}='intan';
                end
                
                %disp(ptable)
                
                ptable{1,count+1}='nrsingleunit';
                ptable{2,count+1}=int32(id.NSingleUnit);
                ptable{1,count+2}='nrmultiunit';
                ptable{2,count+2}=int32(id.NMultiUnit);
                
                %write
                pout=cell2table(ptable(2:end,:));
                pout.Properties.VariableNames=ptable(1,:);
                sqlwrite(conn1,'tblspikes',pout);
                
                clear ptable;
            end
            
            close(conn1);
            close(wb);
            uiconfirm(app.UIFigure,'Experiment database updated.','Confirm done','icon','success');
        end

        % Button pushed function: SelectSpike1
        function SelectSpike1Pushed(app, event)
                [spikefile, spikepath]=uigetfile;
                if spikefile(1)~=0
                    fparts=strsplit(spikefile,'_');
                    expId=fparts{1};
                    unitId=fparts{2}(2:4); %need to drop the leading u
                    experiment=fparts{3};
                    
                    app.ExperimentIDSpike1.Value=expId;
                    app.UnitSpike1.Value=unitId;
                    app.ExpSpike1.Value=experiment;
                    app.SpikePath.Value=spikepath;
                end
        end

        % Button pushed function: Spike1Sql
        function Spike1SqlPushed(app, event)
            %get aninamal name and file path
            expId=app.ExperimentIDSpike1.Value;
            spikepath=app.SpikePath.Value;
            unitId=app.UnitSpike1.Value;
            experiment=app.ExpSpike1.Value;
           
            spikefile=[expId '_u' unitId '_' experiment '_id.mat'];
        
            
            %open mysql database
            conn1=database('clusterdb','kristina','Oregon101');
            if ~isempty(conn1.Message)
                uialert(app.UIFigure,'Cannot open Access Database!','Error')
                return;
            end
                       
            %get primary key of experiment
            selectquery=['SELECT expkey FROM tblexperiment ' ...
                'WHERE experimentid="' expId ...
                '" AND unit="' unitId ...
                '" AND experiment="' experiment '"'];
            dataS=select(conn1,selectquery);
            
            if isempty(dataS)
                uialert(app.UIFigure,'Could not find experiment information!','Error');
                return;
            end
            
            %test whether the spike data has already been entered
            selectquery=['SELECT spikekey FROM tblspikes ' ...
                'WHERE expkey="' num2str(dataS.expkey) '"'];
            
            dataS2=select(conn1,selectquery);
            if ~isempty(dataS2)
                uialert(app.UIFigure,'Spike data already entered!','Error');
                return;
            end
            
            ptable{1,1}='expkey';
            ptable{2,1}=int32(dataS.expkey);
            
            %load spike data file
            load(fullfile(spikepath,spikefile));
            
            if ~exist('id','var')
                uialert(app.UIFigure,'Could not load spike file!','Error');
                return;
            end
            
            ptable{1,2}='loca';
            ptable{2,2}=id.probes(1).area;
            ptable{1,3}='probea';
            ptable{2,3}=id.probes(1).type;
            
            count=4;
            
            if length(id.probes)==2
                ptable{1,4}='locb';
                ptable{2,4}=id.probes(2).area;
                ptable{1,5}='probeb';
                ptable{2,5}=id.probes(2).type;
                count=6;
            end
            
            ptable{1,count}='recsystem';
            if id.isBR==1
                ptable{2,count}='blackrock';
            else
                ptable{2,count}='intan';
            end
           
            ptable{1,count+1}='nrsingleunit';
            ptable{2,count+1}=int32(id.NSingleUnit);
            ptable{1,count+2}='nrmultiunit';
            ptable{2,count+2}=int32(id.NMultiUnit);
            
            %write
            pout=cell2table(ptable(2:end,:));
            pout.Properties.VariableNames=ptable(1,:);
            sqlwrite(conn1,'tblspikes',pout);
            
            clear ptable;
            
            close(conn1);
            uiconfirm(app.UIFigure,'Experiment database updated.','Confirm done','icon','success');
        end

        % Button pushed function: ReadData
        function ReadDataPushed(app, event)
            [datafile,datapath]=uigetfile('*.xlsx');
            if datafile(1)~=0
                %read columns in spreadsheet to populate drop downs
                opts=detectImportOptions(fullfile(datapath,datafile));
                
                if ~isempty(opts)
                    %set label with filename
                    app.DataTable.Text=fullfile(datapath,datafile);
                
                    %set and enable drop downs - the first 2 don't have
                    %none as option since they need to be selected
                    columnNames=opts.VariableNames;
                    columnNames{end+1}='none';
                    app.DatafileColumn.Items=opts.VariableNames;
                    app.DatafileColumn.Enable=1;
                    app.AreaColumn.Items=opts.VariableNames;
                    app.AreaColumn.Enable=1;
                    app.UnitColumn.Items=columnNames;
                    app.UnitColumn.Enable=1;
                    app.ProbeColumn.Items=columnNames;
                    app.ProbeColumn.Enable=1;
                    
                    %enable rest
                    app.FigureNr.Enable=1;
                    app.PaperName.Enable=1;
                    app.addPaper.Enable=1;
                else                  
                    uialert(app.UIFigure,'Could not load data file!','Error');
                    return;
                end
                
                
            end     
        end

        % Button pushed function: addPaper
        function addPaperPushed(app, event)
            %determine which columns to read
            datafileC=app.DatafileColumn.Value;
            areaC=app.AreaColumn.Value;
            unitC=app.UnitColumn.Value;
            probeC=app.ProbeColumn.Value;
            
            sVar={datafileC,areaC};
            if ~strcmp(unitC,'none')
                sVar{end+1}=unitC;
            end
            if ~strcmp(probeC,'none')
                sVar{end+1}=probeC;
            end
            
            %set spreadsheet info
            opts=detectImportOptions(app.DataTable.Text);
            opts.SelectedVariableNames=sVar;
            
            %now read data from spreadsheet
            dataTable=readtable(app.DataTable.Text,opts);
            
            %open database 
            conn1=database('clusterdb','kristina','Oregon101');
            if ~isempty(conn1.Message)
                uialert(app.UIFigure,'Cannot open Access Database!','Error')
                return;
            end
            
            %loop through all entries to build output table
            for i=1:height(dataTable)
                    filename=dataTable{i,1};
                    fparts=strsplit(filename{1},'_');
                    
                    %figure out experiment key
                    selectquery=['SELECT expkey FROM tblexperiment ' ...
                    'WHERE experimentid="' fparts{1} ...
                    '" AND unit="' fparts{2}(2:4) ...
                    '" AND experiment="' fparts{3} '"'];
                                  
                    dataS=select(conn1,selectquery);
                    expkey(i)=dataS.expkey;
                    
                    %find spike key
                    area=dataTable{i,2};
                    area=area{1};
                    
                    selectquery=['SELECT spikekey FROM tblspikes ' ...
                    'WHERE expkey="' num2str(expkey(i)) ...
                    '" AND loca="' area ...
                    '" OR locb="' area '"'];
                    dataS=select(conn1,selectquery);
                    spikekey(i)=dataS.spikekey;
                
                    %add paper and figure number
                    paper{i}=app.PaperName.Value;
                    fignum(i)=app.FigureNr.Value;
                    
                   
            end
            
            ptable=table(expkey',spikekey',paper',fignum','VariableNames',{'expkey';'spikekey';'paper';'figure'});
            ptable=addvars(ptable,dataTable{:,2},'NewVariableNames','area');
            count=3;
            if ~strcmp(unitC,'none')
                ptable=addvars(ptable,dataTable{:,count},'NewVariableNames','unitid');
                count=4;
            end
            if ~strcmp(probeC,'none')
                ptable=addvars(ptable,dataTable{:,count},'NewVariableNames','probeid');
            end 
            sqlwrite(conn1,'tblpaperdata',ptable);
            
            clear ptable;
            close(conn1);
            uiconfirm(app.UIFigure,'Experiment database updated.','Confirm done','icon','success');
        end

        % Button pushed function: HelpPaper
        function HelpPaperPushed(app, event)
            uiconfirm(app.UIFigure,{'Generate an excel spreadsheet with the data used for every figure.';...
                'At the minimum, the spreadsheet should have 2 columns:';...
                'One column needs to contain the name of the experiment file used.';...
                'The other column needs to contain the recording area.';...
                'Two additional columns can be used to indicate unit number and probe number.';...
                'Name and order of columns can be arbitrary.'},'Update docs');
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 848 888];
            app.UIFigure.Name = 'MATLAB App';

            % Create EnterexperimentPanel
            app.EnterexperimentPanel = uipanel(app.UIFigure);
            app.EnterexperimentPanel.Title = 'Enter experiment';
            app.EnterexperimentPanel.Position = [32 309 543 388];

            % Create EartagEditFieldLabel
            app.EartagEditFieldLabel = uilabel(app.EnterexperimentPanel);
            app.EartagEditFieldLabel.Position = [15 332 44 22];
            app.EartagEditFieldLabel.Text = 'Ear tag';

            % Create Eartag
            app.Eartag = uieditfield(app.EnterexperimentPanel, 'text');
            app.Eartag.Tag = 'eartag';
            app.Eartag.Position = [122 332 100 22];

            % Create ExperimentIDEditFieldLabel
            app.ExperimentIDEditFieldLabel = uilabel(app.EnterexperimentPanel);
            app.ExperimentIDEditFieldLabel.Position = [15 301 82 22];
            app.ExperimentIDEditFieldLabel.Text = 'Experiment ID';

            % Create ExperimentID
            app.ExperimentID = uieditfield(app.EnterexperimentPanel, 'text');
            app.ExperimentID.Tag = 'expid';
            app.ExperimentID.Position = [122 301 100 22];

            % Create Terminal
            app.Terminal = uicheckbox(app.EnterexperimentPanel);
            app.Terminal.Tag = 'terminalExp';
            app.Terminal.Text = 'Terminal?';
            app.Terminal.Position = [263 270 74 22];
            app.Terminal.Value = true;

            % Create ExperimentDurDropDownLabel
            app.ExperimentDurDropDownLabel = uilabel(app.EnterexperimentPanel);
            app.ExperimentDurDropDownLabel.Position = [15 239 92 22];
            app.ExperimentDurDropDownLabel.Text = 'Experiment Dur.';

            % Create ExperimentDur
            app.ExperimentDur = uidropdown(app.EnterexperimentPanel);
            app.ExperimentDur.Items = {'<12 hr', 'same day', 'next day', '2 days'};
            app.ExperimentDur.Tag = 'expDur';
            app.ExperimentDur.Position = [122 239 100 22];
            app.ExperimentDur.Value = 'same day';

            % Create InactivationPanel
            app.InactivationPanel = uipanel(app.EnterexperimentPanel);
            app.InactivationPanel.Position = [371 263 161 98];

            % Create Inactivation
            app.Inactivation = uicheckbox(app.InactivationPanel);
            app.Inactivation.Text = 'Inactivation';
            app.Inactivation.Position = [6 68 83 22];

            % Create MethodDropDownLabel
            app.MethodDropDownLabel = uilabel(app.InactivationPanel);
            app.MethodDropDownLabel.Position = [6 39 65 22];
            app.MethodDropDownLabel.Text = 'Method';

            % Create InactivationMethod
            app.InactivationMethod = uidropdown(app.InactivationPanel);
            app.InactivationMethod.Items = {'Muscimol', 'ACSF', 'Opto'};
            app.InactivationMethod.Position = [57 39 98 22];
            app.InactivationMethod.Value = 'Muscimol';

            % Create AreaEditFieldLabel
            app.AreaEditFieldLabel = uilabel(app.InactivationPanel);
            app.AreaEditFieldLabel.Position = [6 9 55 22];
            app.AreaEditFieldLabel.Text = 'Area';

            % Create InactivationArea
            app.InactivationArea = uieditfield(app.InactivationPanel, 'text');
            app.InactivationArea.Position = [60 9 90 22];

            % Create StimulationPanel
            app.StimulationPanel = uipanel(app.EnterexperimentPanel);
            app.StimulationPanel.Position = [371 157 161 98];

            % Create Stimulation
            app.Stimulation = uicheckbox(app.StimulationPanel);
            app.Stimulation.Text = 'Stimulation';
            app.Stimulation.Position = [6 68 82 22];

            % Create MethodDropDownLabel_2
            app.MethodDropDownLabel_2 = uilabel(app.StimulationPanel);
            app.MethodDropDownLabel_2.Position = [6 39 65 22];
            app.MethodDropDownLabel_2.Text = 'Method';

            % Create StimulationMethod
            app.StimulationMethod = uidropdown(app.StimulationPanel);
            app.StimulationMethod.Items = {'Opto', 'Microstim', ''};
            app.StimulationMethod.Position = [57 39 98 22];
            app.StimulationMethod.Value = 'Opto';

            % Create AreaEditFieldLabel_2
            app.AreaEditFieldLabel_2 = uilabel(app.StimulationPanel);
            app.AreaEditFieldLabel_2.Position = [6 9 55 22];
            app.AreaEditFieldLabel_2.Text = 'Area';

            % Create StimulationArea
            app.StimulationArea = uieditfield(app.StimulationPanel, 'text');
            app.StimulationArea.Position = [60 9 90 22];

            % Create TrainingPanel
            app.TrainingPanel = uipanel(app.EnterexperimentPanel);
            app.TrainingPanel.Position = [371 52 161 98];

            % Create Training
            app.Training = uicheckbox(app.TrainingPanel);
            app.Training.Text = 'Training';
            app.Training.Position = [6 68 65 22];

            % Create StimulusLabel
            app.StimulusLabel = uilabel(app.TrainingPanel);
            app.StimulusLabel.Position = [6 39 65 22];
            app.StimulusLabel.Text = 'Stimulus';

            % Create TrainingStim
            app.TrainingStim = uidropdown(app.TrainingPanel);
            app.TrainingStim.Items = {'Grating', 'Plaid', 'Blank', 'Other'};
            app.TrainingStim.Position = [70 39 85 22];
            app.TrainingStim.Value = 'Grating';

            % Create MovingLabel
            app.MovingLabel = uilabel(app.TrainingPanel);
            app.MovingLabel.Position = [6 9 65 22];
            app.MovingLabel.Text = 'Moving?';

            % Create TrainingStimMoving
            app.TrainingStimMoving = uidropdown(app.TrainingPanel);
            app.TrainingStimMoving.Items = {'Drifting', 'Static'};
            app.TrainingStimMoving.Position = [70 9 85 22];
            app.TrainingStimMoving.Value = 'Drifting';

            % Create Warning
            app.Warning = uicheckbox(app.EnterexperimentPanel);
            app.Warning.Text = 'Warning - General problems w/ experiment';
            app.Warning.Position = [15 99 252 22];

            % Create ExperimentDateLabel
            app.ExperimentDateLabel = uilabel(app.EnterexperimentPanel);
            app.ExperimentDateLabel.Position = [15 270 95 22];
            app.ExperimentDateLabel.Text = 'Experiment Date';

            % Create ExperimentDate
            app.ExperimentDate = uidatepicker(app.EnterexperimentPanel);
            app.ExperimentDate.Position = [122 270 100 22];

            % Create AreasPanel
            app.AreasPanel = uipanel(app.EnterexperimentPanel);
            app.AreasPanel.Title = 'Area(s)';
            app.AreasPanel.Position = [15 140 302 86];

            % Create V1CheckBox
            app.V1CheckBox = uicheckbox(app.AreasPanel);
            app.V1CheckBox.Text = 'V1';
            app.V1CheckBox.Position = [8 39 37 22];

            % Create PSSCheckBox
            app.PSSCheckBox = uicheckbox(app.AreasPanel);
            app.PSSCheckBox.Text = 'PSS';
            app.PSSCheckBox.Position = [8 9 46 22];

            % Create S1CheckBox
            app.S1CheckBox = uicheckbox(app.AreasPanel);
            app.S1CheckBox.Text = 'S1';
            app.S1CheckBox.Position = [68 39 37 22];

            % Create LGNCheckBox
            app.LGNCheckBox = uicheckbox(app.AreasPanel);
            app.LGNCheckBox.Text = 'LGN';
            app.LGNCheckBox.Position = [68 9 47 22];

            % Create otherCheckBox
            app.otherCheckBox = uicheckbox(app.AreasPanel);
            app.otherCheckBox.Text = 'other:';
            app.otherCheckBox.Position = [131 39 53 22];

            % Create OtherArea
            app.OtherArea = uieditfield(app.AreasPanel, 'text');
            app.OtherArea.Position = [185 39 100 22];

            % Create Access
            app.Access = uibutton(app.EnterexperimentPanel, 'push');
            app.Access.ButtonPushedFcn = createCallbackFcn(app, @AccessPushed, true);
            app.Access.Tag = 'bAccess';
            app.Access.Position = [15 12 137 22];
            app.Access.Text = {'Update animal DB'; ''};

            % Create Docs
            app.Docs = uibutton(app.EnterexperimentPanel, 'push');
            app.Docs.ButtonPushedFcn = createCallbackFcn(app, @DocsPushed, true);
            app.Docs.Tag = 'bDocs';
            app.Docs.Position = [171 12 137 22];
            app.Docs.Text = 'Update documents';

            % Create Expsql
            app.Expsql = uibutton(app.EnterexperimentPanel, 'push');
            app.Expsql.ButtonPushedFcn = createCallbackFcn(app, @ExpsqlPushed, true);
            app.Expsql.Tag = 'bExpsql';
            app.Expsql.Position = [327 12 137 22];
            app.Expsql.Text = 'Update experiment DB';

            % Create SettingsPanel
            app.SettingsPanel = uipanel(app.UIFigure);
            app.SettingsPanel.Title = 'Settings';
            app.SettingsPanel.Position = [32 709 791 156];

            % Create AccessTest
            app.AccessTest = uibutton(app.SettingsPanel, 'push');
            app.AccessTest.ButtonPushedFcn = createCallbackFcn(app, @AccessTestPushed, true);
            app.AccessTest.Tag = 'bAccessTest';
            app.AccessTest.Position = [23 100 100 22];
            app.AccessTest.Text = 'Test Access DB';

            % Create Lamp
            app.Lamp = uilamp(app.SettingsPanel);
            app.Lamp.Tag = 'lAccessTest';
            app.Lamp.Position = [154 101 20 20];
            app.Lamp.Color = [1 1 0.0667];

            % Create mySqlTest
            app.mySqlTest = uibutton(app.SettingsPanel, 'push');
            app.mySqlTest.ButtonPushedFcn = createCallbackFcn(app, @mySqlTestPushed, true);
            app.mySqlTest.Tag = 'bmySqlTest';
            app.mySqlTest.Position = [23 64 100 22];
            app.mySqlTest.Text = 'Test mySql DB';

            % Create Lamp_2
            app.Lamp_2 = uilamp(app.SettingsPanel);
            app.Lamp_2.Tag = 'lmySqlTest';
            app.Lamp_2.Position = [154 65 20 20];
            app.Lamp_2.Color = [1 1 0.0667];

            % Create AnalyzerPathEditFieldLabel
            app.AnalyzerPathEditFieldLabel = uilabel(app.SettingsPanel);
            app.AnalyzerPathEditFieldLabel.Position = [212 100 88 22];
            app.AnalyzerPathEditFieldLabel.Text = 'Analyzer Path';

            % Create AnalyzerPath
            app.AnalyzerPath = uieditfield(app.SettingsPanel, 'text');
            app.AnalyzerPath.Tag = 'anapath';
            app.AnalyzerPath.Position = [316 100 205 22];
            app.AnalyzerPath.Value = 'Z:\EphysNew\analyzer';

            % Create BrowseAnalyzer
            app.BrowseAnalyzer = uibutton(app.SettingsPanel, 'push');
            app.BrowseAnalyzer.ButtonPushedFcn = createCallbackFcn(app, @BrowseAnalyzerPushed, true);
            app.BrowseAnalyzer.Tag = 'bAnapath';
            app.BrowseAnalyzer.Position = [527.5 100 39 22];
            app.BrowseAnalyzer.Text = 'Find';

            % Create configDB
            app.configDB = uibutton(app.SettingsPanel, 'push');
            app.configDB.ButtonPushedFcn = createCallbackFcn(app, @configDBButtonPushed, true);
            app.configDB.Position = [23 29 100 22];
            app.configDB.Text = 'Configure DB';

            % Create SpikedatapathEditFieldLabel
            app.SpikedatapathEditFieldLabel = uilabel(app.SettingsPanel);
            app.SpikedatapathEditFieldLabel.Position = [212 64 89 22];
            app.SpikedatapathEditFieldLabel.Text = 'Spike data path';

            % Create SpikePath
            app.SpikePath = uieditfield(app.SettingsPanel, 'text');
            app.SpikePath.Position = [316 64 205 22];
            app.SpikePath.Value = 'Z:\EphysNew\processedSpikes';

            % Create BrowseSpike
            app.BrowseSpike = uibutton(app.SettingsPanel, 'push');
            app.BrowseSpike.ButtonPushedFcn = createCallbackFcn(app, @BrowseSpikePushed, true);
            app.BrowseSpike.Tag = 'bAnapath';
            app.BrowseSpike.Position = [527.5 64 39 22];
            app.BrowseSpike.Text = 'Find';

            % Create EnterspikesAllfilesforanimalPanel
            app.EnterspikesAllfilesforanimalPanel = uipanel(app.UIFigure);
            app.EnterspikesAllfilesforanimalPanel.Title = 'Enter spikes - All files for animal';
            app.EnterspikesAllfilesforanimalPanel.Position = [592 572 232 125];

            % Create ExperimentIDEditFieldLabel_2
            app.ExperimentIDEditFieldLabel_2 = uilabel(app.EnterspikesAllfilesforanimalPanel);
            app.ExperimentIDEditFieldLabel_2.Position = [13 69 82 22];
            app.ExperimentIDEditFieldLabel_2.Text = 'Experiment ID';

            % Create ExperimentIDSpikeAll
            app.ExperimentIDSpikeAll = uieditfield(app.EnterspikesAllfilesforanimalPanel, 'text');
            app.ExperimentIDSpikeAll.Tag = 'expid';
            app.ExperimentIDSpikeAll.Position = [120 69 100 22];

            % Create SpikeAllSql
            app.SpikeAllSql = uibutton(app.EnterspikesAllfilesforanimalPanel, 'push');
            app.SpikeAllSql.ButtonPushedFcn = createCallbackFcn(app, @SpikeAllSqlPushed, true);
            app.SpikeAllSql.Position = [41 18 137 22];
            app.SpikeAllSql.Text = 'Update experiment DB';

            % Create Enterspikes1fileonlyPanel
            app.Enterspikes1fileonlyPanel = uipanel(app.UIFigure);
            app.Enterspikes1fileonlyPanel.Title = 'Enter spikes - 1 file only';
            app.Enterspikes1fileonlyPanel.Position = [591 309 232 255];

            % Create ExperimentIDEditFieldLabel_3
            app.ExperimentIDEditFieldLabel_3 = uilabel(app.Enterspikes1fileonlyPanel);
            app.ExperimentIDEditFieldLabel_3.Position = [13 129 82 22];
            app.ExperimentIDEditFieldLabel_3.Text = 'Experiment ID';

            % Create ExperimentIDSpike1
            app.ExperimentIDSpike1 = uieditfield(app.Enterspikes1fileonlyPanel, 'text');
            app.ExperimentIDSpike1.Tag = 'expid';
            app.ExperimentIDSpike1.Position = [120 129 100 22];

            % Create Spike1Sql
            app.Spike1Sql = uibutton(app.Enterspikes1fileonlyPanel, 'push');
            app.Spike1Sql.ButtonPushedFcn = createCallbackFcn(app, @Spike1SqlPushed, true);
            app.Spike1Sql.Position = [39 12 137 22];
            app.Spike1Sql.Text = 'Update experiment DB';

            % Create UnitLabel
            app.UnitLabel = uilabel(app.Enterspikes1fileonlyPanel);
            app.UnitLabel.Position = [13 99 27 22];
            app.UnitLabel.Text = 'Unit';

            % Create UnitSpike1
            app.UnitSpike1 = uieditfield(app.Enterspikes1fileonlyPanel, 'text');
            app.UnitSpike1.Tag = 'expid';
            app.UnitSpike1.Position = [120 99 100 22];

            % Create ExperimentLabel
            app.ExperimentLabel = uilabel(app.Enterspikes1fileonlyPanel);
            app.ExperimentLabel.Position = [13 70 66 22];
            app.ExperimentLabel.Text = 'Experiment';

            % Create ExpSpike1
            app.ExpSpike1 = uieditfield(app.Enterspikes1fileonlyPanel, 'text');
            app.ExpSpike1.Tag = 'expid';
            app.ExpSpike1.Position = [120 70 100 22];

            % Create SelectSpike1
            app.SelectSpike1 = uibutton(app.Enterspikes1fileonlyPanel, 'push');
            app.SelectSpike1.ButtonPushedFcn = createCallbackFcn(app, @SelectSpike1Pushed, true);
            app.SelectSpike1.Position = [119 198 100 22];
            app.SelectSpike1.Text = 'Select';

            % Create SelectdatafileLabel
            app.SelectdatafileLabel = uilabel(app.Enterspikes1fileonlyPanel);
            app.SelectdatafileLabel.Position = [13 198 84 22];
            app.SelectdatafileLabel.Text = 'Select data file';

            % Create orenterinfoLabel
            app.orenterinfoLabel = uilabel(app.Enterspikes1fileonlyPanel);
            app.orenterinfoLabel.Position = [13 159 70 22];
            app.orenterinfoLabel.Text = 'or enter info';

            % Create PaperDataPanel
            app.PaperDataPanel = uipanel(app.UIFigure);
            app.PaperDataPanel.Title = 'Enter paper data';
            app.PaperDataPanel.Position = [32 21 791 276];

            % Create HelpPaper
            app.HelpPaper = uibutton(app.PaperDataPanel, 'push');
            app.HelpPaper.ButtonPushedFcn = createCallbackFcn(app, @HelpPaperPushed, true);
            app.HelpPaper.Position = [202 16 99 22];
            app.HelpPaper.Text = 'Instructions';

            % Create ReadData
            app.ReadData = uibutton(app.PaperDataPanel, 'push');
            app.ReadData.ButtonPushedFcn = createCallbackFcn(app, @ReadDataPushed, true);
            app.ReadData.Position = [15 217 85 22];
            app.ReadData.Text = 'Read table';

            % Create FigureEditFieldLabel
            app.FigureEditFieldLabel = uilabel(app.PaperDataPanel);
            app.FigureEditFieldLabel.Position = [15 132 40 22];
            app.FigureEditFieldLabel.Text = 'Figure';

            % Create FigureNr
            app.FigureNr = uieditfield(app.PaperDataPanel, 'numeric');
            app.FigureNr.Enable = 'off';
            app.FigureNr.Position = [118 132 100 22];

            % Create PaperLabel
            app.PaperLabel = uilabel(app.PaperDataPanel);
            app.PaperLabel.Position = [15 168 38 22];
            app.PaperLabel.Text = {'Paper'; ''};

            % Create PaperName
            app.PaperName = uieditfield(app.PaperDataPanel, 'text');
            app.PaperName.Enable = 'off';
            app.PaperName.Position = [117 168 256 22];

            % Create addPaper
            app.addPaper = uibutton(app.PaperDataPanel, 'push');
            app.addPaper.ButtonPushedFcn = createCallbackFcn(app, @addPaperPushed, true);
            app.addPaper.Enable = 'off';
            app.addPaper.Position = [11 16 137 22];
            app.addPaper.Text = 'Update experiment DB';

            % Create DatafilecolumnDropDownLabel
            app.DatafilecolumnDropDownLabel = uilabel(app.PaperDataPanel);
            app.DatafilecolumnDropDownLabel.Position = [14 96 88 22];
            app.DatafilecolumnDropDownLabel.Text = {'Datafile column'; ''};

            % Create DatafileColumn
            app.DatafileColumn = uidropdown(app.PaperDataPanel);
            app.DatafileColumn.Items = {};
            app.DatafileColumn.Enable = 'off';
            app.DatafileColumn.Position = [117 96 161 22];
            app.DatafileColumn.Value = {};

            % Create ProbecolumnDropDownLabel
            app.ProbecolumnDropDownLabel = uilabel(app.PaperDataPanel);
            app.ProbecolumnDropDownLabel.Position = [336 96 80 22];
            app.ProbecolumnDropDownLabel.Text = 'Probe column';

            % Create ProbeColumn
            app.ProbeColumn = uidropdown(app.PaperDataPanel);
            app.ProbeColumn.Items = {};
            app.ProbeColumn.Enable = 'off';
            app.ProbeColumn.Position = [438 96 161 22];
            app.ProbeColumn.Value = {};

            % Create UnitcolumnDropDownLabel
            app.UnitcolumnDropDownLabel = uilabel(app.PaperDataPanel);
            app.UnitcolumnDropDownLabel.Position = [336 59 69 22];
            app.UnitcolumnDropDownLabel.Text = 'Unit column';

            % Create UnitColumn
            app.UnitColumn = uidropdown(app.PaperDataPanel);
            app.UnitColumn.Items = {};
            app.UnitColumn.Enable = 'off';
            app.UnitColumn.Position = [440 59 160 22];
            app.UnitColumn.Value = {};

            % Create DataTable
            app.DataTable = uilabel(app.PaperDataPanel);
            app.DataTable.BackgroundColor = [1 1 1];
            app.DataTable.Position = [118 217 325 22];
            app.DataTable.Text = '';

            % Create FulljournalnameandyearLabel
            app.FulljournalnameandyearLabel = uilabel(app.PaperDataPanel);
            app.FulljournalnameandyearLabel.Position = [383 168 148 22];
            app.FulljournalnameandyearLabel.Text = 'Full journal name and year';

            % Create AreacolumnDropDownLabel
            app.AreacolumnDropDownLabel = uilabel(app.PaperDataPanel);
            app.AreacolumnDropDownLabel.Position = [15 59 73 22];
            app.AreacolumnDropDownLabel.Text = 'Area column';

            % Create AreaColumn
            app.AreaColumn = uidropdown(app.PaperDataPanel);
            app.AreaColumn.Items = {};
            app.AreaColumn.Enable = 'off';
            app.AreaColumn.Position = [119 59 159 22];
            app.AreaColumn.Value = {};

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = enterExperimentDB_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end