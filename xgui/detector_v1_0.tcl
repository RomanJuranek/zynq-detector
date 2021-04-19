# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set General [ipgui::add_page $IPINST -name "General"]
  ipgui::add_param $IPINST -name "USE_AXIL" -parent ${General} -widget comboBox
  ipgui::add_param $IPINST -name "SCALE_MODE" -parent ${General} -widget comboBox
  ipgui::add_param $IPINST -name "DETECT_STEP_Y" -parent ${General}
  ipgui::add_param $IPINST -name "DETECT_STEP_X" -parent ${General}
  ipgui::add_param $IPINST -name "FEATURE_LIMIT" -parent ${General}
  ipgui::add_param $IPINST -name "MAX_HEIGTH" -parent ${General}
  ipgui::add_param $IPINST -name "MAX_WIDTH" -parent ${General}

  #Adding Page
  set Dafaults_Value [ipgui::add_page $IPINST -name "Dafaults Value"]
  ipgui::add_param $IPINST -name "DEF_THRESHOLD" -parent ${Dafaults_Value}
  ipgui::add_param $IPINST -name "DEF_INSTANCE" -parent ${Dafaults_Value}


}

proc update_PARAM_VALUE.DEBUG { PARAM_VALUE.DEBUG } {
	# Procedure called to update DEBUG when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEBUG { PARAM_VALUE.DEBUG } {
	# Procedure called to validate DEBUG
	return true
}

proc update_PARAM_VALUE.DEF_FEATURE_CNT { PARAM_VALUE.DEF_FEATURE_CNT } {
	# Procedure called to update DEF_FEATURE_CNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEF_FEATURE_CNT { PARAM_VALUE.DEF_FEATURE_CNT } {
	# Procedure called to validate DEF_FEATURE_CNT
	return true
}

proc update_PARAM_VALUE.DEF_IMAGE_HEIGHT { PARAM_VALUE.DEF_IMAGE_HEIGHT } {
	# Procedure called to update DEF_IMAGE_HEIGHT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEF_IMAGE_HEIGHT { PARAM_VALUE.DEF_IMAGE_HEIGHT } {
	# Procedure called to validate DEF_IMAGE_HEIGHT
	return true
}

proc update_PARAM_VALUE.DEF_IMAGE_WIDTH { PARAM_VALUE.DEF_IMAGE_WIDTH } {
	# Procedure called to update DEF_IMAGE_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEF_IMAGE_WIDTH { PARAM_VALUE.DEF_IMAGE_WIDTH } {
	# Procedure called to validate DEF_IMAGE_WIDTH
	return true
}

proc update_PARAM_VALUE.DEF_INSTANCE { PARAM_VALUE.DEF_INSTANCE } {
	# Procedure called to update DEF_INSTANCE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEF_INSTANCE { PARAM_VALUE.DEF_INSTANCE } {
	# Procedure called to validate DEF_INSTANCE
	return true
}

proc update_PARAM_VALUE.DEF_SUM_NULL { PARAM_VALUE.DEF_SUM_NULL } {
	# Procedure called to update DEF_SUM_NULL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEF_SUM_NULL { PARAM_VALUE.DEF_SUM_NULL } {
	# Procedure called to validate DEF_SUM_NULL
	return true
}

proc update_PARAM_VALUE.DEF_THRESHOLD { PARAM_VALUE.DEF_THRESHOLD } {
	# Procedure called to update DEF_THRESHOLD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEF_THRESHOLD { PARAM_VALUE.DEF_THRESHOLD } {
	# Procedure called to validate DEF_THRESHOLD
	return true
}

proc update_PARAM_VALUE.DEF_WINDOW_HEIGHT { PARAM_VALUE.DEF_WINDOW_HEIGHT } {
	# Procedure called to update DEF_WINDOW_HEIGHT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEF_WINDOW_HEIGHT { PARAM_VALUE.DEF_WINDOW_HEIGHT } {
	# Procedure called to validate DEF_WINDOW_HEIGHT
	return true
}

proc update_PARAM_VALUE.DETECT_STEP_X { PARAM_VALUE.DETECT_STEP_X } {
	# Procedure called to update DETECT_STEP_X when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DETECT_STEP_X { PARAM_VALUE.DETECT_STEP_X } {
	# Procedure called to validate DETECT_STEP_X
	return true
}

proc update_PARAM_VALUE.DETECT_STEP_Y { PARAM_VALUE.DETECT_STEP_Y } {
	# Procedure called to update DETECT_STEP_Y when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DETECT_STEP_Y { PARAM_VALUE.DETECT_STEP_Y } {
	# Procedure called to validate DETECT_STEP_Y
	return true
}

proc update_PARAM_VALUE.FEATURE_LIMIT { PARAM_VALUE.FEATURE_LIMIT } {
	# Procedure called to update FEATURE_LIMIT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FEATURE_LIMIT { PARAM_VALUE.FEATURE_LIMIT } {
	# Procedure called to validate FEATURE_LIMIT
	return true
}

proc update_PARAM_VALUE.MAX_HEIGTH { PARAM_VALUE.MAX_HEIGTH } {
	# Procedure called to update MAX_HEIGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_HEIGTH { PARAM_VALUE.MAX_HEIGTH } {
	# Procedure called to validate MAX_HEIGTH
	return true
}

proc update_PARAM_VALUE.MAX_WIDTH { PARAM_VALUE.MAX_WIDTH } {
	# Procedure called to update MAX_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_WIDTH { PARAM_VALUE.MAX_WIDTH } {
	# Procedure called to validate MAX_WIDTH
	return true
}

proc update_PARAM_VALUE.SCALE_MODE { PARAM_VALUE.SCALE_MODE } {
	# Procedure called to update SCALE_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SCALE_MODE { PARAM_VALUE.SCALE_MODE } {
	# Procedure called to validate SCALE_MODE
	return true
}

proc update_PARAM_VALUE.S_AXI_ADDR_WIDTH { PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to update S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_AXI_ADDR_WIDTH { PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to validate S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.S_AXI_DATA_WIDTH { PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to update S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.S_AXI_DATA_WIDTH { PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to validate S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.USE_AXIL { PARAM_VALUE.USE_AXIL } {
	# Procedure called to update USE_AXIL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.USE_AXIL { PARAM_VALUE.USE_AXIL } {
	# Procedure called to validate USE_AXIL
	return true
}


proc update_MODELPARAM_VALUE.S_AXI_DATA_WIDTH { MODELPARAM_VALUE.S_AXI_DATA_WIDTH PARAM_VALUE.S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.S_AXI_ADDR_WIDTH PARAM_VALUE.S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.MAX_WIDTH { MODELPARAM_VALUE.MAX_WIDTH PARAM_VALUE.MAX_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_WIDTH}] ${MODELPARAM_VALUE.MAX_WIDTH}
}

proc update_MODELPARAM_VALUE.MAX_HEIGTH { MODELPARAM_VALUE.MAX_HEIGTH PARAM_VALUE.MAX_HEIGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_HEIGTH}] ${MODELPARAM_VALUE.MAX_HEIGTH}
}

proc update_MODELPARAM_VALUE.FEATURE_LIMIT { MODELPARAM_VALUE.FEATURE_LIMIT PARAM_VALUE.FEATURE_LIMIT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FEATURE_LIMIT}] ${MODELPARAM_VALUE.FEATURE_LIMIT}
}

proc update_MODELPARAM_VALUE.DEBUG { MODELPARAM_VALUE.DEBUG PARAM_VALUE.DEBUG } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEBUG}] ${MODELPARAM_VALUE.DEBUG}
}

proc update_MODELPARAM_VALUE.SCALE_MODE { MODELPARAM_VALUE.SCALE_MODE PARAM_VALUE.SCALE_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SCALE_MODE}] ${MODELPARAM_VALUE.SCALE_MODE}
}

proc update_MODELPARAM_VALUE.DETECT_STEP_X { MODELPARAM_VALUE.DETECT_STEP_X PARAM_VALUE.DETECT_STEP_X } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DETECT_STEP_X}] ${MODELPARAM_VALUE.DETECT_STEP_X}
}

proc update_MODELPARAM_VALUE.DETECT_STEP_Y { MODELPARAM_VALUE.DETECT_STEP_Y PARAM_VALUE.DETECT_STEP_Y } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DETECT_STEP_Y}] ${MODELPARAM_VALUE.DETECT_STEP_Y}
}

proc update_MODELPARAM_VALUE.USE_AXIL { MODELPARAM_VALUE.USE_AXIL PARAM_VALUE.USE_AXIL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.USE_AXIL}] ${MODELPARAM_VALUE.USE_AXIL}
}

proc update_MODELPARAM_VALUE.DEF_IMAGE_WIDTH { MODELPARAM_VALUE.DEF_IMAGE_WIDTH PARAM_VALUE.DEF_IMAGE_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEF_IMAGE_WIDTH}] ${MODELPARAM_VALUE.DEF_IMAGE_WIDTH}
}

proc update_MODELPARAM_VALUE.DEF_IMAGE_HEIGHT { MODELPARAM_VALUE.DEF_IMAGE_HEIGHT PARAM_VALUE.DEF_IMAGE_HEIGHT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEF_IMAGE_HEIGHT}] ${MODELPARAM_VALUE.DEF_IMAGE_HEIGHT}
}

proc update_MODELPARAM_VALUE.DEF_WINDOW_HEIGHT { MODELPARAM_VALUE.DEF_WINDOW_HEIGHT PARAM_VALUE.DEF_WINDOW_HEIGHT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEF_WINDOW_HEIGHT}] ${MODELPARAM_VALUE.DEF_WINDOW_HEIGHT}
}

proc update_MODELPARAM_VALUE.DEF_FEATURE_CNT { MODELPARAM_VALUE.DEF_FEATURE_CNT PARAM_VALUE.DEF_FEATURE_CNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEF_FEATURE_CNT}] ${MODELPARAM_VALUE.DEF_FEATURE_CNT}
}

proc update_MODELPARAM_VALUE.DEF_THRESHOLD { MODELPARAM_VALUE.DEF_THRESHOLD PARAM_VALUE.DEF_THRESHOLD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEF_THRESHOLD}] ${MODELPARAM_VALUE.DEF_THRESHOLD}
}

proc update_MODELPARAM_VALUE.DEF_INSTANCE { MODELPARAM_VALUE.DEF_INSTANCE PARAM_VALUE.DEF_INSTANCE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEF_INSTANCE}] ${MODELPARAM_VALUE.DEF_INSTANCE}
}

proc update_MODELPARAM_VALUE.DEF_SUM_NULL { MODELPARAM_VALUE.DEF_SUM_NULL PARAM_VALUE.DEF_SUM_NULL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEF_SUM_NULL}] ${MODELPARAM_VALUE.DEF_SUM_NULL}
}

