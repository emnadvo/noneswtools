#!'C:\app\Python37\python.exe'
#-*- coding: UTF-8 -*-


# --- integral values ---
BUTTON_WIDTH = 8
BUTTON_HEIGHT = BUTTON_WIDTH+5
DRIVE_ID = 0
COMBO_HEIGHT = 50
COLUMNSPAN = 4
GRID_PAD = 5
PATH_ID = 1

# --- literal values ---
BTN_LABEL = 'Actions'
CCUSERID = '0054383'
CLEARCASE_VIEW = 'view'
CMB_LABEL = 'ClearCase view'
GEOMETRY_RESOLUTION = '580x150'
TITLE = 'ZF CR Service tool'
VERSION = '1.0.0'
SHOW_WARNING_TITLE = 'Warning'
SHOW_ERROR_TITLE = 'Error'
SHOW_INFO_TITLE = 'Information'
MISSING_CHOICE_VIEW = 'You don\'t have choiced a view for next operation.'
SOFTWARE_DIRNAME = 'software'
DEBUG_DIRNAME = 'debug'

DIRECTORY_L1 = 1
DIRECTORY_L2 = 2
DIRECTORY_L3 = 3

DIRECTORY_PATH_L0 = [ 'frdcc_haq4_pag_ms', 'frdcc_tond', 'frdcc_tond2_dai_mma_ms' ]
DIRECTORY_PATH_L1 = [ 'software' ]
DIRECTORY_PATH_L2 = [ 'tools', 'build' ]
DIRECTORY_PATH_L3 = [ 'debug', 'trace32' ]
# ----------------------------------------------------------------
# Background for button Debug
DEBUGGER_PATHS = [ '', 'trace32_2G', 'smp' ]
DEBUGGER_CMD = [ 'start_trace32.bat', 'helper_start_t32.bat', '!start_win64.bat' ]
# ----------------------------------------------------------------
# Background for button RBS (Canoe)
RBS_PATHS = [ '', 'CANoe' ]
RBS_CMD = [ 'Start_CANoe.bat' ]
# ----------------------------------------------------------------
# Background for button build
BUILD_PATHS = [ '' ]
BUILD_CMD = [ 'build.bat' ]
# ----------------------------------------------------------------
# Background for button Analysis (Canape)
ANALYSIS_PATHS = [ '', 'CANape' ]
ANALYSIS_CMD = [ 'Start_CANape.bat' ]