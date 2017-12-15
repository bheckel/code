@echo off

:: This script tests to see if jobs have completed prior to copying (to avoid copying a failed or in-progress run)
:: rsh86800 15-May-09 (adapted from cny22437 version)
setlocal enabledelayedexpansion

::::::::::::::::::::::::: Valtrex Caplets ::::::::::::::::::::::::
set /A n=0
:start_valtrex_test
  if exist .\VALTREX_Caplets\INPUT_DATA_FILES\tmp\DPRunFlg.txt goto sleep_valtrex_time 
  goto copy_valtrex_files

:sleep_valtrex_time
  sleep 10
  set /A n+=1
  echo in va loop !n!
  if !n! == 3 goto endvalsleep
  goto start_valtrex_test

:copy_valtrex_files
  echo rd here va %%n
  :::rd /s /q .\DataPost\WebPages\ValtrexCapletsData\InputData
  :::rd /s /q .\DataPost\WebPages\ValtrexCapletsData\OutputCompiledData
  :::rd /s /q .\DataPost\WebPages\ValtrexCapletsData\Other

  :::mkdir .\DataPost\WebPages\ValtrexCapletsData\InputData
  :::mkdir .\DataPost\WebPages\ValtrexCapletsData\OutputCompiledData
  :::mkdir .\DataPost\WebPages\ValtrexCapletsData\Other

  :::xcopy /e /y /q .\valtrex_caplets\input_data_files     .\DataPost\WebPages\ValtrexCapletsData\InputData
  :::xcopy /e /y /q .\valtrex_caplets\output_compiled_data .\DataPost\WebPages\ValtrexCapletsData\OutputCompiledData
  :::xcopy /e /y /q .\valtrex_caplets\other                .\DataPost\WebPages\ValtrexCapletsData\Other

:endvalsleep
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::: Ventolin HFA ::::::::::::::::::::::::
set /A n=0
:start_ventolin_test
  echo falling into ve
  if exist .\Ventolin_HFA\INPUT_DATA_FILES\tmp\DPRunFlg.txt goto sleep_ventolin_time 
  goto copy_ventolin_files

:sleep_ventolin_time
  set /A n+=1
  echo in ve loop !n!
  if !n! == 3 goto endvensleep
  sleep 10
  goto start_ventolin_test

:copy_ventolin_files
  echo rd here ve !n!
  :::rd /s /q .\DataPost\WebPages\VentolinHFAData\InputData
  :::rd /s /q .\DataPost\WebPages\VentolinHFAData\OutputCompiledData
  :::rd /s /q .\DataPost\WebPages\VentolinHFAData\Other

  :::mkdir .\DataPost\WebPages\VentolinHFAData\InputData
  :::mkdir .\DataPost\WebPages\VentolinHFAData\OutputCompiledData
  :::mkdir .\DataPost\WebPages\VentolinHFAData\OutputCompiledData\Analytical_byTest
  :::mkdir .\DataPost\WebPages\VentolinHFAData\Other

  :::xcopy /e /y /q .\ventolin_hfa\input_data_files .\DataPost\WebPages\VentolinHFAData\InputData
  :::xcopy    /y /q .\ventolin_hfa\output_compiled_data .\DataPost\WebPages\VentolinHFAData\OutputCompiledData
  :::xcopy    /y /q .\ventolin_hfa\output_compiled_data\analytical_bytest .\DataPost\WebPages\VentolinHFAData\OutputCompiledData\Analytical_byTest
  :::xcopy /e /y /q .\ventolin_hfa\other .\DataPost\WebPages\VentolinHFAData\Other

:endvensleep
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
