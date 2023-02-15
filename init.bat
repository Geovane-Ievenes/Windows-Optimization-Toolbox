echo off

:begin
cls
echo.
echo  ******************************************************************
echo  *         Windows Toolbox. Por favor selecione uma opção         *
echo  ******************************************************************
echo.
echo ------------- Hardware -------------
echo  1) Informações sobre a computador
echo  2) habilitar memória cache 
echo.
echo  -- Otimização de recursos do Windows --
echo  3) Otimizar
echo  4) Voltar ao normal 
echo.
echo --------- Recursos especiais ----------
echo  5) Habilitar recursos especiais
echo  6) Desabilitar recursos especiais
echo.
echo -- Executar scripts em modo "Stand Alone" --
echo  5) Habilitar recursos especiais
echo  6) Desabilitar recursos especiais

SET /p script=" Insert a value: "
SET CURRENTDIR=%~dp0%

IF %script% ==1 (
    SET FILENAME=Components.ps1 
) ELSE IF %script% ==2(
    SET FILENAME=CacheMemory.ps1 
) ELSE IF %script% ==3(
    SET FILENAME=Optimization.ps1 
) ELSE IF %script% ==4(
    SET FILENAME=Optimization.ps1 
) ELSE IF %script% ==5(
    SET FILENAME=Special.ps1 
) ELSE IF %script% ==6(
    SET FILENAME=Special.ps1 
) ELSE (
    cls
    echo Por favor, insira uma opção válida...
    pause
    goto begin
)

:execute
cls
set SCRIPT_PATH="%CURRENTDIR%\scripts\%filename%"

REM Execute selected Powershell script 
PowerShell.exe -ExecutionPolicy Bypass -File %SCRIPT_PATH% 

:executeagain
set /p again="Execute script again ? [s/n]"
IF %again%==s (
    goto execute
) ELSE IF %again%==n (
    goto wanttogoback
) ELSE (
    cls
    echo Please select a valid option...
    pause
    goto executeagain
)

:wanttogoback
set /p goback="Go back to script selection ? [s/n]"
IF %goback%==s (
    goto begin
) ELSE IF %goback%==n (
    exit
) ELSE (
    cls
    echo Please select a valid option...
    pause
    goto wanttogoback
)