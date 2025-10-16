@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: ========================================
::    Конфигурационные переменные
:: ========================================
set "BUILD_DIR=.build"
set "VENV_DIR=.venv"
set "EXE_NAME=main.exe"
set "ICON_FILE_PATH=../assets/prj_icon.ico"

:menu
cls
echo ========================================
echo    Скрипт сборки Python проекта
echo ========================================
echo.
echo Выберите действие:
echo   1 - Собрать исполняемый файл
echo   2 - Запустить исполняемый файл
echo   3 - Очистка проекта
echo   4 - Выход
echo.
set /p choice="Введите номер действия (1-4): "

if "%choice%"=="1" goto build
if "%choice%"=="2" goto run
if "%choice%"=="3" goto clean
if "%choice%"=="4" goto exit
echo Неверный выбор! Пожалуйста, введите 1, 2, 3 или 4
goto menu

:build
call :build_executable
goto menu

:run
:: Проверяем существование собранного файла
if exist "%BUILD_DIR%\%EXE_NAME%" (
    echo Запуск исполняемого файла...
    %BUILD_DIR%\%EXE_NAME%
) else (
    echo Исполняемый файл не найден. Собираю проект...
    call :build_executable
    if exist "%BUILD_DIR%\%EXE_NAME%" (
        echo Запуск исполняемого файла...
        %BUILD_DIR%\%EXE_NAME%
    ) else (
        echo Ошибка: Не удалось собрать или найти исполняемый файл
        pause
    )
)
goto menu

:clean
echo.
echo ========================================
echo    Очистка проекта
echo ========================================

echo Удаление директории сборки...
if exist "%BUILD_DIR%" (
    rmdir /s /q %BUILD_DIR%
    echo Директория %BUILD_DIR% удалена
)

echo Удаление кэша Python...
for /d /r . %%i in (__pycache__) do (
    if exist "%%i" (
        rmdir /s /q "%%i"
    )
)

echo Удаление временных файлов...
if exist "*.spec" del /q *.spec 2>nul
if exist "dist" rmdir /s /q dist 2>nul
if exist "build" rmdir /s /q build 2>nul

echo Удаление кэша Nuitka...
if exist ".nuitka" rmdir /s /q .nuitka 2>nul

echo Очистка завершена!
pause
goto menu

:exit
echo Выход...
pause
exit /b 0

:check_python
python --version >nul 2>&1
if errorlevel 1 (
    echo Ошибка: Python не установлен или не добавлен в PATH
    echo Убедитесь, что Python установлен и доступен из командной строки
    pause
    exit /b 1
)
goto :eof

:check_dependencies
echo Проверка и установка необходимых зависимостей...

:: Проверка Nuitka
pip show nuitka >nul 2>&1
if errorlevel 1 (
    echo Установка Nuitka...
    pip install nuitka
    if !errorlevel! neq 0 (
        echo Ошибка установки Nuitka
        pause
        exit /b 1
    )
    echo Nuitka успешно установлен
) else (
    echo Nuitka уже установлен
)
goto :eof

:build_executable
:: Функция сборки исполняемого файла
echo.
echo ========================================
echo    Начало процесса сборки
echo ========================================

:: Проверка Python
call :check_python

:: Проверка наличия основного файла
if not exist "main.py" (
    echo Ошибка: Файл main.py не найден!
    pause
    exit /b 1
)

:: Проверка наличия виртуального окружения
if not exist "%VENV_DIR%" (
    echo Виртуальное окружение не найдено. Создаю...
    python -m venv %VENV_DIR%
    if !errorlevel! neq 0 (
        echo Ошибка создания виртуального окружения
        pause
        exit /b 1
    )
    echo Виртуальное окружение успешно создано
) else (
    echo Виртуальное окружение найдено
)

:: Активация виртуального окружения
echo Активация виртуального окружения...
call %VENV_DIR%\Scripts\activate.bat
if !errorlevel! neq 0 (
    echo Ошибка активации виртуального окружения
    pause
    exit /b 1
)

:: Обновление pip для избежания проблем с зависимостями
echo Обновление pip...
python -m pip install --upgrade pip

:: Проверка и установка зависимостей
call :check_dependencies

:: Установка зависимостей из requirements.txt
if exist "requirements.txt" (
    echo Установка зависимостей из requirements.txt...
    pip install -r requirements.txt
    if !errorlevel! neq 0 (
        echo Ошибка установки зависимостей
        pause
        exit /b 1
    )
    echo Зависимости успешно установлены
) else (
    echo Файл requirements.txt не найден, пропускаю установку зависимостей
)

:: Работа с директорией сборки
if not exist "%BUILD_DIR%" (
    echo Создание директории %BUILD_DIR%...
    mkdir %BUILD_DIR%
) else (
    echo Очистка директории %BUILD_DIR%...
    rmdir /s /q %BUILD_DIR%
    mkdir %BUILD_DIR%
)

:: Сохраняем текущую директорию
set "ORIGINAL_DIR=%CD%"

:: Переходим в директорию сборки
cd %BUILD_DIR%

:: Сборка с помощью Nuitka
echo Запуск сборки с помощью Nuitka...

:: Базовые параметры Nuitka
set "NUITKA_CMD=nuitka --standalone --onefile --windows-console-mode=disable --include-package=wx --follow-imports --include-package-data=wx --noinclude-unittest-mode=nofollow"

:: Добавляем включение assets
set "NUITKA_CMD=!NUITKA_CMD! --include-data-files=../assets/*=assets/"

:: Добавляем иконку если существует
if exist "%ICON_FILE_PATH%" (
    set "NUITKA_CMD=!NUITKA_CMD! --windows-icon-from-ico=%ICON_FILE_PATH%"
)

:: Выполняем команду
echo Выполняется: !NUITKA_CMD! ../main.py
call !NUITKA_CMD! ../main.py

if !errorlevel! neq 0 (
    echo Сборка завершилась с ошибкой!
    cd /d "%ORIGINAL_DIR%"
    pause
    exit /b 1
)

echo Сборка успешно завершена!

:: Копирование assets директории
echo Копирование директории assets...
if exist "..\assets" (
    xcopy "..\assets" "assets\" /E /I /Y
    echo Ресурсы успешно скопированы
) else (
    echo Директория assets не найдена
)

:: Очистка BUILD_DIR от лишних файлов и папок (кроме EXE и assets)
echo Очистка временных файлов сборки...
for /d %%i in (*) do (
    if /i not "%%i"=="assets" (
        rmdir /s /q "%%i" 2>nul
    )
)

for %%i in (*) do (
    if /i not "%%i"=="%EXE_NAME%" (
        if /i not "%%i"=="assets" (
            del /q "%%i" 2>nul
        )
    )
)

:: Возврат в исходную директорию
cd /d "%ORIGINAL_DIR%"

:: Деактивация виртуального окружения
echo Деактивация виртуального окружения...
call deactivate

echo ========================================
echo    Процесс сборки завершен!
echo ========================================

:: Показ информации о собранном файле
if exist "%BUILD_DIR%\%EXE_NAME%" (
    echo Собранный файл: %BUILD_DIR%\%EXE_NAME%
    for %%F in ("%BUILD_DIR%\%EXE_NAME%") do (
        echo Размер файла: %%~zF байт
    )
) else (
    echo ВНИМАНИЕ: Исполняемый файл не найден в папке %BUILD_DIR%!
)

pause
exit /b 0