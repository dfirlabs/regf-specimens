@echo off

rem Script to generate Windows NT Registry (REGF) test files

rem Split the output of ver e.g. "Microsoft Windows [Version 10.0.10586]"
rem and keep the last part "10.0.10586]".
for /f "tokens=1,2,3,4" %%a in ('ver') do (
	set version=%%d
)

rem Replace dots by spaces "10 0 10586]".
set version=%version:.= %

rem Split the last part of the ver output "10 0 10586]" and keep the first
rem 2 values formatted with a dot as separator "10.0".
for /f "tokens=1,2,*" %%a in ("%version%") do (
	set version=%%a.%%b
)

set specimenspath=specimens\%version%

if exist "%specimenspath%" (
	echo Specimens directory: %specimenspath% already exists.

	exit /b 1
)

mkdir "%specimenspath%"

set keypath=HKCU\TestKey

rem Scenario 1: Create a REGF file with different value types.

reg add %keypath% /f /ve /t REG_SZ /d DefaultValue
reg add %keypath% /f /v NoneValue /t REG_NONE
reg add %keypath% /f /v StringValue /t REG_SZ /d MyString
reg add %keypath% /f /v ExpandableStringValue /t REG_EXPAND_SZ /d %%MyExpandableString%%
reg add %keypath% /f /v MultiStringValue /t REG_MULTI_SZ /d My\0Multi\0String
reg add %keypath% /f /v BigEndianDwordValue /t REG_DWORD_BIG_ENDIAN /d 12345678
reg add %keypath% /f /v LittleEndianDwordValue /t REG_DWORD_LITTLE_ENDIAN /d 12345678
reg add %keypath% /f /v DwordValue /t REG_DWORD /d 12345678
reg add %keypath% /f /v QwordValue /t REG_QWORD /d 12345678
reg add %keypath% /f /v BinaryValue /t REG_BINARY /d 0123456789abcdef

rem For some reason a large string value can be exported but not imported with reg.exe.
reg import largevalue.reg

rem Use regln to create a REG_LINK
rem Create REG_FULL_RESOURCE_DESCRIPTOR

rem This requires administrator privileges and will create a REGF version 1.3 file.
rem To generate a REGF version 1.5 file change keypath to HKLM\SOFTWARE\TestKey in
rem this script and in largevalue.reg
reg save %keypath% %specimenspath%\value_types.hiv

reg delete %keypath% /f

rem Scenario 2: Create a REGF file with a large number of values.

for /l %%a in (1, 1, 100) do (
	reg add %keypath% /f /v %%a /t REG_DWORD_LITTLE_ENDIAN /d %%a > nul
)

reg save %keypath% %specimenspath%\100_values.hiv

reg delete %keypath% /f

for /l %%a in (1, 1, 10000) do (
	reg add %keypath% /f /v %%a /t REG_DWORD_LITTLE_ENDIAN /d %%a > nul
)

reg save %keypath% %specimenspath%\10000_values.hiv

reg delete %keypath% /f

rem Scenario 3: Create a REGF file with a large number of sub keys.

for /l %%a in (1, 1, 100) do (
	reg add %keypath%\%%a /f /v Value /t REG_SZ /d String > nul
)

reg save %keypath% %specimenspath%\100_sub_keys.hiv

reg delete %keypath% /f

for /l %%a in (1, 1, 10000) do (
	reg add %keypath%\%%a /f /v Value /t REG_SZ /d String > nul
)

reg save %keypath% %specimenspath%\10000_sub_keys.hiv

reg delete %keypath% /f

exit /b 0
