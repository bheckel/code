2010-04-12

Version 9 is apparently the same:
C:\Program Files\Quest Software\Toad for Oracle\User Files\*.*


---


2007-11-08

Easier than below info is to just cp C:\Program Files\Quest Software\Toad for
Oracle\User Files\ to new box's User Files\ to get *all* preferences,
connections and saved sqls


---


Transferring Configuration files
If you are installing Toad on a new computer, you may want to move your
settings, personal SQL, SQL History and Named SQL Statements to the new
machine. This will save you the trouble of recreating all of these settings. 

To do this, copy the following files from your old machine to the new machine.
Be sure the file structure remains the same. These are just the basic
settings. If you want to transfer ALL personalized settings, additional
information on configuration files that are customizable can be found in the
Properties Files topic.

Location
 Contents
 
<Toad folder>\TOAD.INI
 Toad Settings
 
<Toad folder>\ToadParams.ini
 Toad Parameters (if you have not set any of the Toad parameters, this file will not exist.
 
<Toad folder>\perssqls.dat
 Personal SQLs
 
<Toad folder>\sqls.dat
 SQL History
 
<Toad folder>\temps\namedsql.dat
 Named SQL Statements
 
<Toad folder>\toolbars.ini
 Toolbar configurations
 


---------
2006-11-16
c:\prog files\quest...\toad for oracle\user files\toad.ini


[Window states]
TfrmSQLEditor_autoopen=1
TfrmSessProcs_autoopen=0
TIMonitor_autoopen=0
TInstanceManagerForm_autoopen=0
TOSMonitorForm_autoopen=0
TOracleScriptForm_autoopen=0
TProjectManagerForm_autoopen=0
NewStyleAutoOpen=1
TInstanceManagerForm_OneInstance=1
TSQLLoader_OneInstance=1
TfrmProcEdit_OneInstance=1
TUNIXKernelParmsForm_OneInstance=1
TWindowsRegistryParmsForm_OneInstance=1
TSchedulerForm_OneInstance=1
TOutputFrm_OneInstance=1
TfrmJavaManager_OneInstance=1
TProjectManagerForm_OneInstance=1
TDBrowserForm_OneInstance=1
TServiceMgrForm_OneInstance=1
TTaskSchedulerForm_OneInstance=1
TThreadedQueryViewerForm_OneInstance=1
TFormRefCursorResults_OneInstance=1
TAppsMonitorForm_OneInstance=1
TReportsForm_OneInstance=1
TfrmAnalyze_savesize=1
TfrmAnalyze_saveposition=0
TfrmAnalyze_OneInstance=0
TfrmAnalyze_OnePerToad=0
TZipArchiveForm_savesize=0
TZipArchiveForm_saveposition=0
TZipArchiveForm_OneInstance=0
TZipArchiveForm_OnePerToad=0
TfrmChainedRows_savesize=0
TfrmChainedRows_saveposition=0
TfrmChainedRows_OneInstance=0
TfrmChainedRows_OnePerToad=0
TFormCRM_savesize=0
TFormCRM_saveposition=0
TFormCRM_OneInstance=0
TFormCRM_OnePerToad=0
TDataCompareForm_savesize=0
TDataCompareForm_saveposition=0
TDataCompareForm_OneInstance=0
TDataCompareForm_OnePerToad=0
TDiffHolderForm_savesize=0
TDiffHolderForm_saveposition=0
TDiffHolderForm_OneInstance=0
TDiffHolderForm_OnePerToad=0
TClusterForm_savesize=0
TClusterForm_saveposition=0
TClusterForm_OneInstance=0
TClusterForm_OnePerToad=0
TIndexForm_savesize=0
TIndexForm_saveposition=0
TIndexForm_OneInstance=0
TIndexForm_OnePerToad=0
TfrmMakeSeq_savesize=0
TfrmMakeSeq_saveposition=0
TfrmMakeSeq_OneInstance=0
TfrmMakeSeq_OnePerToad=0
TSnapshotForm_savesize=0
TSnapshotForm_saveposition=0
TSnapshotForm_OneInstance=0
TSnapshotForm_OnePerToad=0
TSnapshotLogForm_savesize=0
TSnapshotLogForm_saveposition=0
TSnapshotLogForm_OneInstance=0
TSnapshotLogForm_OnePerToad=0
TTableForm_savesize=0
TTableForm_saveposition=0
TTableForm_OneInstance=0
TTableForm_OnePerToad=0
TTablespaceForm_savesize=0
TTablespaceForm_saveposition=0
TTablespaceForm_OneInstance=0
TTablespaceForm_OnePerToad=0
TTriggerForm_savesize=0
TTriggerForm_saveposition=0
TTriggerForm_OneInstance=0
TTriggerForm_OnePerToad=0
TViewForm_savesize=0
TViewForm_saveposition=0
TViewForm_OneInstance=0
TViewForm_OnePerToad=0
TDataPumpWizardForm_savesize=0
TDataPumpWizardForm_saveposition=0
TDataPumpWizardForm_OneInstance=0
TDataPumpWizardForm_OnePerToad=0
TDataPumpImpWizardForm_savesize=0
TDataPumpImpWizardForm_saveposition=0
TDataPumpImpWizardForm_OneInstance=0
TDataPumpImpWizardForm_OnePerToad=0
TDataPumpManagerForm_savesize=0
TDataPumpManagerForm_saveposition=0
TDataPumpManagerForm_OneInstance=0
TDataPumpManagerForm_OnePerToad=0
TfrmDepend_savesize=0
TfrmDepend_saveposition=0
TfrmDepend_OneInstance=0
TfrmDepend_OnePerToad=0
TAppsBrowserForm_savesize=0
TAppsBrowserForm_saveposition=0
TAppsBrowserForm_OneInstance=0
TAppsBrowserForm_OnePerToad=0
TAppsLookupFinderForm_savesize=0
TAppsLookupFinderForm_saveposition=0
TAppsLookupFinderForm_OneInstance=0
TAppsLookupFinderForm_OnePerToad=0
TAppsMonitorForm_savesize=0
TAppsMonitorForm_saveposition=0
TAppsMonitorForm_OnePerToad=0
TReportsForm_savesize=0
TReportsForm_saveposition=0
TReportsForm_OnePerToad=0
TfrmEditor_savesize=0
TfrmEditor_saveposition=0
TfrmEditor_OneInstance=0
TfrmEditor_OnePerToad=0
TFormERD_savesize=0
TFormERD_saveposition=0
TFormERD_OneInstance=0
TFormERD_OnePerToad=0
TfrmExPlan_savesize=0
TfrmExPlan_saveposition=0
TfrmExPlan_OneInstance=0
TfrmExPlan_OnePerToad=0
TExportBrowserForm_savesize=0
TExportBrowserForm_saveposition=0
TExportBrowserForm_OneInstance=0
TExportBrowserForm_OnePerToad=0
TfrmMultiTblScript_savesize=0
TfrmMultiTblScript_saveposition=0
TfrmMultiTblScript_OneInstance=0
TfrmMultiTblScript_OnePerToad=0
TfrmExtents_savesize=0
TfrmExtents_saveposition=0
TfrmExtents_OneInstance=0
TfrmExtents_OnePerToad=0
TTOADFTP_savesize=0
TTOADFTP_saveposition=0
TTOADFTP_OneInstance=0
TTOADFTP_OnePerToad=0
TfrmSchemaDoc_savesize=1
TfrmSchemaDoc_saveposition=0
TfrmSchemaDoc_OneInstance=0
TfrmSchemaDoc_OnePerToad=0
TEstimateIndSizeForm_savesize=0
TEstimateIndSizeForm_saveposition=0
TEstimateIndSizeForm_OneInstance=0
TEstimateIndSizeForm_OnePerToad=0
TMasterDetailForm_savesize=0
TMasterDetailForm_saveposition=0
TMasterDetailForm_OneInstance=0
TMasterDetailForm_OnePerToad=0
TMultiObjectPrivForm_savesize=0
TMultiObjectPrivForm_saveposition=0
TMultiObjectPrivForm_OneInstance=0
TMultiObjectPrivForm_OnePerToad=0
TNetworkForm_savesize=0
TNetworkForm_saveposition=0
TNetworkForm_OneInstance=0
TNetworkForm_OnePerToad=0
TfrmComp1Obj_savesize=0
TfrmComp1Obj_saveposition=0
TfrmComp1Obj_OneInstance=0
TfrmComp1Obj_OnePerToad=0
TfrmObjectSearch_savesize=1
TfrmObjectSearch_saveposition=0
TfrmObjectSearch_OneInstance=0
TfrmObjectSearch_OnePerToad=0
TfrmOraInit_savesize=0
TfrmOraInit_saveposition=0
TfrmOraInit_OneInstance=0
TfrmOraInit_OnePerToad=0
TfrmProcEdit_savesize=1
TfrmProcEdit_saveposition=0
TfrmProcEdit_OnePerToad=0
TtdProfileAnalysisForm_savesize=1
TtdProfileAnalysisForm_saveposition=0
TtdProfileAnalysisForm_OneInstance=0
TtdProfileAnalysisForm_OnePerToad=0
TThreadedQueryViewerForm_savesize=0
TThreadedQueryViewerForm_saveposition=0
TThreadedQueryViewerForm_OnePerToad=0
TfrmIndRbld_savesize=1
TfrmIndRbld_saveposition=0
TfrmIndRbld_OneInstance=0
TfrmIndRbld_OnePerToad=0
TfrmRebuildTable_savesize=0
TfrmRebuildTable_saveposition=0
TfrmRebuildTable_OneInstance=0
TfrmRebuildTable_OnePerToad=0
TfrmObjects_savesize=1
TfrmObjects_saveposition=0
TfrmObjects_OneInstance=0
TfrmObjects_OnePerToad=0
TScriptManagerForm_savesize=0
TScriptManagerForm_saveposition=0
TScriptManagerForm_OneInstance=0
TScriptManagerForm_OnePerToad=0
TfrmServerStats_savesize=0
TfrmServerStats_saveposition=0
TfrmServerStats_OneInstance=0
TfrmServerStats_OnePerToad=0
TSessionBrowserForm_savesize=0
TSessionBrowserForm_saveposition=0
TSessionBrowserForm_OneInstance=0
TSessionBrowserForm_OnePerToad=0
TfrmSessionInfo_savesize=0
TfrmSessionInfo_saveposition=0
TfrmSessionInfo_OneInstance=0
TfrmSessionInfo_OnePerToad=0
TfrmTrace_savesize=0
TfrmTrace_saveposition=0
TfrmTrace_OneInstance=0
TfrmTrace_OnePerToad=0
TfrmSQLEditor_savesize=0
TfrmSQLEditor_saveposition=0
TfrmSQLEditor_OneInstance=0
TfrmSQLEditor_OnePerToad=0
TFDataModeler_savesize=0
TFDataModeler_saveposition=0
TFDataModeler_OneInstance=0
TFDataModeler_OnePerToad=0
TSQLLoader_savesize=0
TSQLLoader_saveposition=0
TSQLLoader_OnePerToad=0
TFormSupportBundle_savesize=0
TFormSupportBundle_saveposition=0
TFormSupportBundle_OneInstance=0
TFormSupportBundle_OnePerToad=0
TfrmTabDupes_savesize=0
TfrmTabDupes_saveposition=0
TfrmTabDupes_OneInstance=0
TfrmTabDupes_OnePerToad=0
TEstimateTabSizeForm_savesize=0
TEstimateTabSizeForm_saveposition=0
TEstimateTabSizeForm_OneInstance=0
TEstimateTabSizeForm_OnePerToad=0
TfrmTableSpaces_savesize=0
TfrmTableSpaces_saveposition=0
TfrmTableSpaces_OneInstance=0
TfrmTableSpaces_OnePerToad=0
TTaskSchedulerForm_savesize=0
TTaskSchedulerForm_saveposition=0
TTaskSchedulerForm_OnePerToad=0
TFormWrap_savesize=0
TFormWrap_saveposition=0
TFormWrap_OneInstance=0
TFormWrap_OnePerToad=0
ShowFirst=Schema browser
TfrmObjects_WIDTH=1104
TfrmObjects_HEIGHT=524

[SETTINGS]
CustomToolbarFileUpgradeOccurred=1
ToolbarConfigurationCount=2
CurrentToolbarFile=
VisualStyle=1
LoginWindowGUIStyle=2
LoginWindowViewMode=0
LoginWindowMultiTabs=0
SCRIPT_MEM_WARN=50
SE_NAV_GROUP=1
SE_NAV_SORT=0
FTP ASCII Extensions=txt
USER_VARS=
PERSIST_SE_TAB=0
BYTES_PER_LINE=20
HEX_FONT_SIZE=8
HEX_FONT_COLOR=0
HEX_FONT_NAME=normal
OFFSET_FONT_SIZE=8
OFFSET_FONT_COLOR=8388608
OFFSET_FONT_NAME=normal
TEXT_FONT_SIZE=8
TEXT_FONT_COLOR=128
TEXT_FONT_NAME=normal
SE_NAV_FONT_SIZE=8
SE_NAV_FONT_COLOR=0
SE_NAV_FONT_NAME=normal
DBMS_FONT_SIZE=8
DBMS_FONT_COLOR=0
DBMS_FONT_NAME=normal
FlashOutput=1
FlashToad=1
BrowserItemIcons=1
BrowserIcons=1
BrowserHints=1
SB_ShowPackageBody=0
BrowserCopyMode=1
GridFetchMemoryWarn=12
RefreshBrowserAfterCreate=0
RefreshBrowserAfterAlter=0
AutoSaveDesktop=1
OECapSource=1
OELoadTables=0
OELoadCols=0
OELoadDep=0
OECollectionName=NEWCOLLECTION
OEObjName=NEWOBJECT
OEAttrName=NEWATTRIB
OEAttrType=VARCHAR2
OEMethodName=NEWMETHOD
OEMethodType=Procedure
OEFunctionType=INTEGER
OERestrictions=
FindUseCase=0
FindWholeWord=0
FindRegEx=0
FindWholeWordFile=0
FindRegExFile=0
FindFirstFile=1
MANYTOADS=0
SAVE_SQLS=1
AUTOCOMMIT=0
READ_ONLY=0
FONT_SIZE=11
FONT_BOLD=1
FONT_NAME=Courier New
SFONT_NAME=
RptFontName=Courier New
RptFontSize=9
RptFontBold=0
RptCharSet=1
OBJSPLITTER=417
PLAN_TABLE=TOAD_PLAN_TABLE
CODE_FORMAT=5
SQL_PATH=C:\cygwin\home\bheckel\code\misccode\
PLSQL_PATH=C:\Program Files\Quest Software\Toad for Oracle\
CBar_FONT_SIZE=8
CBar_FONT_STYLE=normal
CBar_FONT_NAME=Tahoma
CBar_FONT_COLOR=000000
WBar_FONT_SIZE=8
WBar_FONT_STYLE=normal
WBar_FONT_NAME=Tahoma
WBar_FONT_COLOR=000000
SortedRecordView=0
XML10103ReadOnly=1
SB_FONT_BOLD=0
SB_FONT_NAME=MS Sans Serif
SB_FONT_CHAR=1
SB_FONT_SIZE=8
SB_FONT_COLOR=000000
ByteCharIn9i=1
Script_FONT_BOLD=0
Script_FONT_NAME=Courier
Script_FONT_CHAR=1
Script_FONT_SIZE=10
EXECUTELOGINSCRIPTS=0
MAXROWS=0
ASKCOMMIT=1
ALWAYSCOMMIT=0
ALWAYSROLLBACK=0
MRUCOUNT=10
AUTO_LOAD=C:\cygwin\home\bheckel\code\misccode\links_toadload.sql
AutoExecFile=
NUM_SQLS=100
MAKE_BACKUPS=1
HideClobs=0
SBHistSave=0
SBHistLimit=25
REFRESHTABLES=0
DefWindow=0
IncOwnerInProcs=0
WinUserName=RSH86800
SERELOADFILES=0
ViewAsTable=1
OMITSYSDEPEND=1
MEMOONCLICK=1
AutoSizeColumns=1
SmallColumns=0
HighLiteProcs=1
THREADQUERIES=1
SqlPlus=
FONT_CHAR=1
GRIDCHARS=1
CLONECURSOR=0
AutoFilter=0
CheckDBAPrivs=0
ShowTblSize=0
ShowIdxSize=1
UseLinePrint=0
HighlightTables=1
AutoLoadTables=0
AutoShowLogin=1
AutoloadViews=0
AllowF7=1
DateFormat=dd-MMM-yy
TimeFormat=h:nn:ss
DataRowNum=
LimitGridFetch=0
NoRequiredCols=1
ShowSchema=1
UseToadSession=0
CheckVariables=1
MDIMAXED=1
AppMAXED=1
ObjOwnersOnly=0
ObjOwnersOnlyNoSyns=0
ObjOwnersOnlyNoSynsOrTempTables=0
WasRun=1
ProcFilters=1
CreateOnly=0
SortSortCols=1
SortFilterCols=1
RptOrient=0
DescPopupsSOT=1
Sortpopups=1
DDLOptimizer=
SelObjAuto=1
OCIArrayBuffer=500
IncSysViews=1
SHOWSPLASH=1
TwoDigitWindow=30
ToadOracleHome=
KillRefresRate=20
KillDoRefresh=1
KillExcSys=0
KillExcSysAcc=1
ShowRowid=0
KillExcSysBlocks=0
KillExcSysLocks=0
KillAutoDetails=1
KillSortCol=3
KillSortHow=DESC
KillAccessSortCol=3
KillAccessSortHow=DESC
ShowUsersWithPivs=1
DescTimer=1000
UserDefSpace=
UsertempSpace=
ConfirmExportOverwrites=1
ConfirmImportOverwrites=1
ConfirmLoaderOverwrites=1
KeepSameSchema=0
ConfirmShutDown=0
PromptToCloseWins=0
SBMRUOL=0
AutoTrim=0
TablePkeys=1
AllowRTF=1
ShowStatusBar=1
SHOWSQLNETWARNING=1
SHOWLOGINSETTINGSCHANGEDWARNING=1
CheckDeps=1
DCIFromNet=0
SqlTempsFromNet=0
SqlStatementCursor=0
StripCodeClipboard=0
TempsPath=
SaveBeforeRun=0
ValidSql=1
UserName=
SizeListViews=1
SaveSqlEditor=1
AutoAlias=0
ArgsIncName=1
ArgsIncType=1
ArgsIncInOut=1
ConfirmDeletes=1
NotifyOnCompletion=0
SaveGridLayouts=0
AllowPkgVars=1
SEBlueDots=1
SEFORMATFILES=0
DebugTrans=0
EnableDebugTrace=0
BreakOnException=1
UnderbarStartsWord=0
DoLowCaseObjNames=1
AllowColumnDropDown=1
SaveBrowserFilters=1
DebugCompDeps=Prompt
ShowNullArgsNag=1
ShowDebugEndNag=1
ExportNoDataNag=1
DefToDebugOn=1
WrapDataOutput=1
ShowTunerWarning=1
BpBack=9
BpFore=15
ExecBack=4
ExecFore=15
DisBack=7
DisFore=0
MonitorWidth=793
MonitorHeight=494
PMarginLeft=0
PMarginRight=0
PMarginTop=0
PMarginBottom=0
PPaperSizeY=0
PPaperSizeX=0
PPaperSizeUnits=INCH
DebugTimeout=180
nlsDateFormat=DD-MON-YY
FloatPrecision=0
IntPrecision=0
LastRevKb=
EnableOutput=1
PromptToCheckIn=0
ExternalEditor=C:\Program Files\Vim\vim70\gvim.exe
LastDbProject=
SBDetailTimer=900
SortNavList=0
NavLowerCase=1
SortSBNavList=0
CompileFromDb=1
SplitPackFromDb=1
OldPrintGrid=0
WrapComments=1
ModAfterCompFromDb=1
StepPkgSpec=0
StepSysProcs=0
ShowDebugToolbars=1
SaveProcParams=1
ShowSpecOnPackDesc=0
FindWordAtCursor=1
ClearGrid=1
LanguageNumber=1
MinsForAutoSave=3
lastOptPanel=36
AutoSBRHS=1
SBLHSToolBars=1
AUTO_DBMS=0
RESET_SE_SCRIPT_SETTINGS=1
SECommitRollbackAllTabs=0
MultiLineTabs=0
ChainedTable=CHAINED_ROWS
SQLLoaderPath=
ImportPath=
ExportPath=
TNSPingPath=C:\ORACLE\ORA817\bin\TNSPING.EXE
PingPath=C:\WINDOWS\system32\PING.EXE
SqldSavepath=
TKProfPath=
WrapPath=
ExpDataPumpPath=
ImpDataPumpPath=
ExpOutputPath=
DECIMALCHAR='.'
THOUSANDCHAR=','
RightMargin=80
ProcExt=prc
FncExt=fnc
SpecExt=pks
BodyExt=pkb
TrigExt=trg
ViewExt=vw
JavaExt=jvs
DbmsSize=20000
ShowTblStats=1
NoParQueries=0
FKLookup=1
IncDisabledFKs=1
ShowObjCreate=1
CacheDataTypeList=0
TABBED_SCHEMABROWSER=1
TreeViewBrowser=0
SepTblConstraints=0
BriefTypeFormat=1
ShowSqlTime=0
makeCodeVar=SQL
SCCProvider=
SCCAuxPath=
SCCProjName=
SCCLocalProjPath=
SCCCheckOutComment=0
SCCCheckInComment=0
SCCAddFileComment=0
UNIXSAVE=0
GRID_INDICATORS=1
EDIT_TOOLBARS=1
PLAY_WAVE=1
MDI3D=1
SetDataGridFocus=0
ShowTopLevelGrants=0
ConvertCrLf=0
SavePasswords=1
SavePasswordsReconnect=1
UseToadPlanTbls=0
ShowRecNums=0
ExtentFormat=1
CheckDelCons=1
AutoReplace Activation Keys=;,:=[]\n\t\s
Code template HotKey=Ctrl+Space
Auto-detect Oracle utilities=0
Instance Manager DB version refresh=0
MasterDetailConfirmClose=1
Open last use tnsnames files=1
Backup tnsnames files before saves=0
Allow docking of RO toolbars=1
Lock main toolbar=0
Rotate main toolbar when vertical=1
Scroll pinned windows=1
Pinned windows scroll rate=300
WinBtnShowConnect=0
WinBtnShowTitle=1
MultiLineTabsSE=0
HIGHLIGHTEXECLINE=0
QSQL path=C:\Program Files\Quest Software\Toad for Oracle\QSR.exe
CompilePkgAsPair=0
EnableParamHints=1
CtrlClickToBody=1
strFileSplitting=1
strFileSplittingSave=2
strFileSplitTags=1
strFileSplitSaveSeperate=0
ScientificNotation=1
SingleStepSpoolSQL=0
LastSessionBrowserFilter=<none>
tnsnames editor width=780
tnsnames editor height=491
tnsnames editor ls panel width=380
tnsnames editor panel height=136
Last left side tnsnames file=
Last right side tnsnames file=
tnsnames editor view style=tree
ShowTableComments=0
ShowColumnComments=0
SBRHSPrevWidth=0
ColCommentsHeight=0
SBTablesTopLevelRefsOnly=1
cbIdxSize=0
SBFavsBand=388
SBFavsCol0=140
SBFavsCol1=143
SBFavsCol2=200

[VCS_PROVIDERS]
0=Microsoft Visual Sourcesafe
1=Merant Version Manager (PVCS) version 5.2/5.3/6.0
2=SCC
3=Merant Version Manager (PVCS) version 6.6 and later
4=CVS (Concurrent Versions System)

[VCS_DLLS]
0=vss.dll
1=pvcs.dll
2=scc.dll
3=vss.dll
4=cvs.dll

[TEAM_CODING]
VCP List Version=1
Disable Provider Login=0
Automatic Check In=0
Automatic Check Out=0
Prompt for Check Out Comment=0
Prompt for Check In Comment=0
Prompt for Check in All=0
Simultaneously Check In/Out Spec and Body=0
Schema Replacement for Stored Code=0
Schema Replacement for Triggers=0
Schema Replacement for Views=0
Enable Actions in Schema Browser & Project Manager=0
Force New Revision on Check-In=0
Local Working Directory=

[LOGIN]
TOP=283
LEFT=240
WIDTH=799
HEIGHT=428
FavoritesOnly=0

[Script Debugger]
DockLayout=<default>

[XMLEditor]
SyncMode=1
MoveMode=0
SyncSize=1
SyncUnits=1

[MONITOR_ALERTS]
Enable Alerts=1

[GRIDSETTINGS]
HFONTCOLOR=0
HFONTSIZE=9
HFONTNAME=Arial Narrow
HFONTBOLD=0
HFONTITALICS=0
HFONTCHAR=0
FFONTCOLOR=0
FONTSIZE=9
FONTNAME=Andale Mono
FONTBOLD=0
FONTITALICS=0
FONTCHAR=0
PFONTCOLOR=0
PFONTSIZE=8
PFONTNAME=MS Sans Serif
PFONTBOLD=0
PFONTITALICS=0
PFONTCHAR=1
PLINES=1
PROWWIDTH=1
PHIDEFRECT=1
PHIDESEL=0
PSHOWGRID=1
PSHOWRUMS=0
PASKSORTS=1
PAUTOSIZE=1
PTABTHRU=0
PCOLSIZE=1
PCOLMOVE=1
PTABS=1
PROWSELECT=0
PMUTLSEL=0
PXONEXIT=1
PIMMEDEDITOR=0
PFULLSIZING=1
PSHOWALL=0
SHOWNULLS=0
NULLSYELLOW=0
SIZEHDRS=0
GRID_GRAY_NUMS=0
ExcelFilters=0

[PAGENAMES]
Constraints=Constraints
DB Links=DB Links
Directories=Directories
Indexes=Indexes
Java=Java
Jobs=Jobs
Libraries=Libraries
Policies=Policies
Procs=Procs
Rollback Segments=Rollback Segments
Sequences=Sequences
Snapshots=Snapshots
Synonyms=Synonyms
Tables=Tables
Tablespaces=Tablespaces
Triggers=Triggers
Users=Users
Views=Views
Profiles=Profiles
Roles=Roles
Types=Types
Queue Tables=Queue Tables
Queues=Queues
Favorites=Favorites
Snapshot Logs=Snapshot Logs
Dimensions=Dimensions
Policy Groups=Policy Groups
Resource Groups=Resource Groups
Resource Plans=Resource Plans
Sys Privs=Sys Privs
Clusters=Clusters
Refresh Groups=Refresh Groups
Recycle Bin=Recycle Bin
Sched. Programs=Sched. Programs
Sched. Schedules=Sched. Schedules
Sched. Jobs=Sched. Jobs
Sched. Job Classes=Sched. Job Classes
Sched. Windows=Sched. Windows
Sched. Window Groups=Sched. Window Groups

[PAGEORDERS]
Constraints=6
DB Links=9
Directories=15
Indexes=5
Java=8
Jobs=11
Libraries=21
Policies=18
Procs=3
Rollback Segments=19
Sequences=7
Snapshots=22
Synonyms=2
Tables=0
Tablespaces=20
Triggers=4
Users=10
Views=1
Profiles=17
Roles=23
Types=12
Queue Tables=13
Queues=14
Favorites=24
Snapshot Logs=25
Dimensions=26
Policy Groups=16
Resource Groups=27
Resource Plans=28
Sys Privs=29
Clusters=30
Refresh Groups=31
Recycle Bin=32
Sched. Programs=33
Sched. Schedules=34
Sched. Jobs=35
Sched. Job Classes=36
Sched. Windows=37
Sched. Window Groups=38

[PAGESHOW]
Constraints=1
DB Links=1
Directories=0
Indexes=1
Java=1
Jobs=1
Libraries=0
Policies=0
Procs=1
Rollback Segments=0
Sequences=1
Snapshots=1
Synonyms=1
Tables=1
Tablespaces=0
Triggers=1
Users=1
Views=1
Profiles=0
Roles=1
Types=1
Queue Tables=1
Queues=1
Favorites=1
Snapshot Logs=1
Dimensions=0
Policy Groups=0
Resource Groups=0
Resource Plans=0
Sys Privs=1
Clusters=1
Refresh Groups=0
Recycle Bin=1
Sched. Programs=0
Sched. Schedules=0
Sched. Jobs=0
Sched. Job Classes=0
Sched. Windows=0
Sched. Window Groups=0

[OBJECT_EXTENSIONS]
FUNCTION=fnc
JAVA SOURCE=jvs
PACKAGE BODY=pkb
PACKAGE=pks
PROCEDURE=prc
TRIGGER=trg
TYPE BODY=tpb
TYPE=tps
VIEW=vw

[TBLSELFORM]
TOP=10
LEFT=500
WIDTH=250
HEIGHT=265

[COLSELFORM]
TOP=10
LEFT=500
WIDTH=250
HEIGHT=265

[DiskAccess]
CodeSnippetsFilesConverted=1

[SD_toolbarMain]
DockedDockingStyle=2
DockedLeft=0
DockedTop=0
OneOnRow=0
Row=0
FloatLeft=276
FloatTop=216
FloatClientWidth=23
FloatClientHeight=22
DockingStyle=2
Visible=1

[SD_toolbarEdit]
DockedDockingStyle=2
DockedLeft=205
DockedTop=26
OneOnRow=0
Row=1
FloatLeft=276
FloatTop=216
FloatClientWidth=69
FloatClientHeight=22
DockingStyle=2
Visible=1

[SD_toolbarDesktop]
DockedDockingStyle=2
DockedLeft=619
DockedTop=26
OneOnRow=0
Row=1
FloatLeft=404
FloatTop=341
FloatClientWidth=23
FloatClientHeight=22
DockingStyle=2
Visible=1

[SD_toolbarFormatting]
DockedDockingStyle=2
DockedLeft=274
DockedTop=0
OneOnRow=0
Row=0
FloatLeft=404
FloatTop=341
FloatClientWidth=23
FloatClientHeight=22
DockingStyle=2
Visible=1

[SD_toolbarSource Control]
DockedDockingStyle=2
DockedLeft=330
DockedTop=0
OneOnRow=0
Row=0
FloatLeft=404
FloatTop=341
FloatClientWidth=23
FloatClientHeight=22
DockingStyle=2
Visible=1

[SD_toolbarSQL Recall]
DockedDockingStyle=2
DockedLeft=610
DockedTop=0
OneOnRow=0
Row=0
FloatLeft=276
FloatTop=216
FloatClientWidth=23
FloatClientHeight=22
DockingStyle=2
Visible=1

[SD_toolbarCurrent Schema]
DockedDockingStyle=2
DockedLeft=418
DockedTop=0
OneOnRow=0
Row=0
FloatLeft=276
FloatTop=216
FloatClientWidth=23
FloatClientHeight=22
DockingStyle=2
Visible=1

[SD_toolbarScript Debugging]
DockedDockingStyle=2
DockedLeft=0
DockedTop=26
OneOnRow=0
Row=1
FloatLeft=276
FloatTop=216
FloatClientWidth=23
FloatClientHeight=22
DockingStyle=2
Visible=1

[Main Menu]
DockedDockingStyle=2
DockedLeft=0
DockedTop=0
OneOnRow=1
Row=0
FloatLeft=0
FloatTop=0
FloatClientWidth=0
FloatClientHeight=0
DockingStyle=2
Visible=1

[Standard]
DockedDockingStyle=2
DockedLeft=0
DockedTop=23
OneOnRow=1
Row=1
FloatLeft=193
FloatTop=311
FloatClientWidth=230
FloatClientHeight=22
DockingStyle=2
Visible=1

[Team Coding]
DockedDockingStyle=2
DockedLeft=0
DockedTop=49
OneOnRow=1
Row=2
FloatLeft=340
FloatTop=264
FloatClientWidth=23
FloatClientHeight=22
DockingStyle=2
Visible=0

[barWindows]
DockedDockingStyle=4
DockedLeft=0
DockedTop=0
OneOnRow=1
Row=0
FloatLeft=404
FloatTop=341
FloatClientWidth=86
FloatClientHeight=26
DockingStyle=4
Visible=1

[barDesktops]
DockedDockingStyle=2
DockedLeft=594
DockedTop=23
OneOnRow=0
Row=1
FloatLeft=404
FloatTop=341
FloatClientWidth=23
FloatClientHeight=22
DockingStyle=2
Visible=0

[barConnections]
DockedDockingStyle=2
DockedLeft=0
DockedTop=49
OneOnRow=1
Row=2
FloatLeft=404
FloatTop=341
FloatClientWidth=23
FloatClientHeight=22
DockingStyle=2
Visible=0

[MAINFORM]
DockLayout=<default>

[TablespaceMapWindows]
SaveLegend=1
SaveSegments=1
SaveFilters=1

[JdwpSettings]
JdwpUse=0
JdwpAllowStepIntoJava=0
JdwpHost=ZEBWL06A16349
JdwpPort=-1

[Network Utilities]
Telnet Font Chrset=1
Telnet Font Name=MS Sans Serif
Telnet Font Size=8
Telnet Font Bold=0

[DATATYPES]
BFILE=TRUE
BINARY_DOUBLE=TRUE
BINARY_FLOAT=TRUE
BLOB=TRUE
CHAR=TRUE
CLOB=TRUE
DATE=TRUE
FLOAT=TRUE
LONG=TRUE
LONG RAW=TRUE
MLSLABEL=TRUE
NCHAR=TRUE
NCLOB=TRUE
NUMBER=TRUE
NVARCHAR2=TRUE
RAW=TRUE
ROWID=TRUE
URITYPE=TRUE
UROWID=TRUE
VARCHAR2=TRUE
XMLTYPE=TRUE
CHAR VARYING=TRUE
CHARACTER=TRUE
CHARACTER VARYING=TRUE
DECIMAL=TRUE
DOUBLE PRECISION=TRUE
INT=TRUE
INTEGER=TRUE
NATIONAL CHAR=TRUE
NATIONAL CHAR VARYING=TRUE
NATIONAL CHARACTER=TRUE
NATIONAL CHARACTER VARYING=TRUE
NCHAR VARYING=TRUE
NUMERIC=TRUE
REAL=TRUE
SMALLINT=TRUE
VARCHAR=TRUE
ORA8USERTYPES=FALSE
ORA9TIMESTAMPTYPES=FALSE

[SAVEAS]
eDir=
chkToFile=0
chkToClip=1
txtFileName=
cbLaunch=0
cbUnix=0
txtOther=|
seOther=124
cbDelimRow=0
seCommitInt=0
cbSelOnly=0
chkDblQuote=0
chkIncHeaders=1
cbLowerHeaders=0
chkIncNulls=0
cbSchema=0
cbZip=0
cbSQL=1
cbNoWrap=0
cbCellBorders=0
cbCloneCursor=0
cbStringFields=0
eSchema=
eTable=
chkDelim=0
optHTML=0
optINS=0
optSQLLdr=0
optXLS=0
optXLSInstance=0
optXMLPlain=0
optXML=0
optFixed=1
optMerge=0
seDiscardMax=0
rbInsert=0
rbTruncate=0
rbAppend=0
rbReplace=0
eFieldSep=;
eStringEnc="
cbCellFont=0
cbGeneral=0
eDateFormat=Mm/Dd/Yyyy Hh:mm:ss
cbAutoColWidth=0
cbHideZeroTime=0
seDec=2
cbDec=0
WIDTH=425
HEIGHT=558
Show Column List Comments=0
gridIndexesColumn7=None
gridIndexesColumn1=None
gridIndexesColumn2=None
gridIndexesColumn3=None
gridIndexesColumn4=None
gridIndexesColumn5=None
gridIndexesColumn6=None
GridPartsColumn1=None
GridPartsColumn2=None
GridPartsColumn3=None
GridPartsColumn4=None
GridPartsColumn11=None
GridPartsColumn5=None
GridPartsColumn6=None
GridPartsColumn7=None
GridPartsColumn8=None
GridPartsColumn9=None
GridPartsColumn10=None
dxDBGridColumn1=None
dxDBGridColumn2=None
dxDBGridColumn3=None
dxDBGridColumn4=None
gridSubpartsColumn10=None
dxDBGridColumn5=None
dxDBGridColumn6=None
dxDBGridColumn7=None
dxDBGridColumn8=None
dxDBGridColumn9=None
gridTriggersColumn1=None
gridTriggersColumn2=None
gridTriggersColumn3=None
gridTriggersColumn4=None
gridTriggersColumn5=None
gridTriggersColumn6=None
gridTriggersColumn7=None
gridTriggersColumn8=None

[Code Snippets]
ColsHeight=148

[TInstantMessageForm]
LEFT=22
TOP=29
WIDTH=425
HEIGHT=186

[ObjView]
Show Column List Comments=0
ScrFormat=0
ColCommentsHeight=0
ShowTableComments=0
ShowColumnComments=0

[Object Palette]
ShowColumns=1
ColsHeight=148
Col0Width=136
Col1Width=108
Col2Width=40
Col3Width=100

[SBLHS]
vt30_0_visible=1
vt30_0_pos=0
vt30_0_width=383
vt30_1_visible=0
vt30_1_pos=1
vt30_1_width=50
vt30_2_visible=0
vt30_2_pos=2
vt30_2_width=50
vt30_3_visible=0
vt30_3_pos=3
vt30_3_width=50

[TablespaceMap]
Free space=16777215
Used space=32768
Highlight=65535
Fragmentation level 1=255
FragStopVal1=30
CustomFragCount=1
SegHint=1

[ToolbarConfiguration1]
Desc=User default (current settings)
Filename=TOOLBARS.INI

[ToolbarConfiguration2]
Desc=TOAD default (all items)
Filename=

[Optimizer Hints]
DBA_DEPENDENCIES|7=/*+ ALL_ROWS */
DBA_DEPENDENCIES|8=/*+ ALL_ROWS */
DBA_DEPENDENCIES|8i=/*+ ALL_ROWS */
DBA_DEPENDENCIES|9i=/*+ ALL_ROWS */
DBA_DEPENDENCIES|9iR2=/*+ ALL_ROWS */
DBA_LOB_PARTITIONS|8i=<none>
DBA_LOB_PARTITIONS|9i=/*+ ALL_ROWS */
DBA_LOB_PARTITIONS|9iR2=/*+ ALL_ROWS */
DBA_LOB_SUBPARTITIONS|8i=<none>
DBA_LOB_SUBPARTITIONS|9i=/*+ ALL_ROWS */
DBA_LOB_SUBPARTITIONS|9iR2=/*+ ALL_ROWS */
DBA_NESTED_TABLES|8i=<none>
DBA_NESTED_TABLES|9i=/*+ ALL_ROWS */
DBA_NESTED_TABLES|9iR2=<none>
DBA_TYPES|8=/*+ ALL_ROWS */
DBA_TYPES|8i=/*+ ALL_ROWS */
DBA_TYPES|9i=<none>
DBA_TYPES|9iR2=<none>
V$LOCK|7=/*+ RULE */
V$LOCK|8=/*+ RULE */
V$LOCK|8i=/*+ RULE */
V$LOCK|9i=/*+ RULE */
V$LOCK|9iR2=/*+ RULE */

[PLSQLTEMPLATES]
PROCEDURE:Default=C:\Program Files\Quest Software\Toad for Oracle\User Files\NEWPROC.SQL
FUNCTION:Default=C:\Program Files\Quest Software\Toad for Oracle\User Files\NEWFUNC.SQL
TRIGGER:Default=C:\Program Files\Quest Software\Toad for Oracle\User Files\NEWTRIG.SQL
PACKAGE:Default=C:\Program Files\Quest Software\Toad for Oracle\User Files\NewPackage.SQL
PACKAGE BODY:Default=C:\Program Files\Quest Software\Toad for Oracle\User Files\NewPackageBody.SQL
TYPE:Default=C:\Program Files\Quest Software\Toad for Oracle\User Files\NewType.SQL
TYPE BODY:Default=C:\Program Files\Quest Software\Toad for Oracle\User Files\NewType.SQL
PACKAGE FUNCTION:Default=C:\Program Files\Quest Software\Toad for Oracle\User Files\NewPkgFunc.SQL
PACKAGE PROCEDURE:Default=C:\Program Files\Quest Software\Toad for Oracle\User Files\NewPkgProc.SQL
TYPE FUNCTION:Default=C:\Program Files\Quest Software\Toad for Oracle\User Files\NewTypeFunc.SQL
TYPE PROCEDURE:Default=C:\Program Files\Quest Software\Toad for Oracle\User Files\NewTypeProc.SQL

[ScriptDebuggerMRU_Files]
0=C:\cygwin\home\bheckel\code\misccode\links_toadload.sql
1=1=1=1=1=1=1=C:\Documents and Settings\rsh86800\Desktop\toad8.sql
2=2=2=2=2=2=2=C:\cygwin\home\bheckel\code\misccode\links_toadload.sql
3=3=3=3=3=3=3=C:\Documents and Settings\rsh86800\Desktop\toad6.sql
4=4=4=4=4=4=4=C:\Documents and Settings\rsh86800\Desktop\toad5.sql
5=5=5=5=5=5=5=C:\Documents and Settings\rsh86800\Desktop\toad4.sql
6=6=6=6=6=6=6=C:\Documents and Settings\rsh86800\Desktop\toad3.sql
7=7=7=7=7=7=7=C:\Documents and Settings\rsh86800\Desktop\toad2.sql
8=8=8=8=8=8=8=C:\Documents and Settings\rsh86800\Desktop\toad1.sql

[FILTERS]
SQL=*.sql
Text Files=*.txt
All Files=*.*

[LANGUAGES]
PLSQL=*.sql;*.prc;*.fnc;*.pks;*.pkb;*.trg;*.vw;*.tps;*.tpb
JAVA=*.java;*.jvs
HTML=*.html;*.htm;*.asp;*.xml;*.xsl;*.xsd
INI=*.ini
TEXT=*.txt

[PARSERS]
PLSQL=c:\program files\quest software\toad for oracle\user files\plsqlscr.txt
JAVA=c:\program files\quest software\toad for oracle\user files\javascr.txt
HTML=c:\program files\quest software\toad for oracle\user files\htmlscr.txt
INI=c:\program files\quest software\toad for oracle\user files\iniscr.txt
TEXT=c:\program files\quest software\toad for oracle\user files\textscr.txt
