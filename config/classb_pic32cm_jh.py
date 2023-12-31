# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2023 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*****************************************************************************"""
################################################################################
#### Call-backs ####
################################################################################
# Update Symbol Visibility
def setClassB_SymbolVisibility(MySymbol, event):
    MySymbol.setVisible(event["value"])

# Set or clear Core Symbol Value
def updateCore_SymbolValue(symbolId, value, isSet):
    if isSet == True:
        Database.setSymbolValue("core", symbolId, value)
    else:
        Database.clearSymbolValue("core", symbolId)

# Update SRAM, Flash ECC Interrupt State
def setClassB_UpdateInterrupt(SelectedSymbol, event):
    interruptName = ""
    selectedSymbolId = SelectedSymbol.getID()
    if selectedSymbolId == "CLASSB_SYS_SRAM_INT_SYM":
        interruptName = "MCRAMC"
    elif selectedSymbolId == "CLASSB_SYS_FLASH_INT_SYM":
        interruptName = "NVMCTRL"

    if interruptName != "":
        updateCore_SymbolValue(interruptName + "_INTERRUPT_ENABLE", event["value"], event["value"])
        updateCore_SymbolValue(interruptName + "_INTERRUPT_HANDLER", SelectedSymbol.getValue(), event["value"])

################################################################################
#### Component ####
################################################################################
def instantiateComponent(classBComponent):

    global configName
    global classBSourceResultMgmt
    global classBSourceCpuTestAsm
        
    configName = Variables.get("__CONFIGURATION_NAME")

    classBMenu = classBComponent.createMenuSymbol("CLASSB_MENU", None)
    classBMenu.setLabel("Class B Startup Test Configuration")

    execfile(Module.getPath() +"/config/interface.py")
    
    # Device params
    classBFlashNode = ATDF.getNode("/avr-tools-device-file/devices/device/address-spaces/address-space/memory-segment@[name=\"FLASH\"]")
    if classBFlashNode != None:
        # Flash size
        classB_FLASH_SIZE = classBComponent.createIntegerSymbol("CLASSB_FLASH_SIZE", None)
        classB_FLASH_SIZE.setVisible(False)
        classB_FLASH_SIZE.setDefaultValue(int(classBFlashNode.getAttribute("size"), 16))
        
    classBSRAMNode = ATDF.getNode("/avr-tools-device-file/devices/device/address-spaces/address-space/memory-segment@[name=\"DRAM\"]")
    if classBSRAMNode != None:
        # SRAM size
        classB_SRAM_SIZE = classBComponent.createIntegerSymbol("CLASSB_SRAM_SIZE", None)
        classB_SRAM_SIZE.setVisible(False)
        classB_SRAM_SIZE.setDefaultValue(int(classBSRAMNode.getAttribute("size"), 16))
        # SRAM address
        classB_SRAM_ADDR = classBComponent.createHexSymbol("CLASSB_SRAM_START_ADDRESS", None)
        classB_SRAM_ADDR.setVisible(False)
        classB_SRAM_ADDR.setDefaultValue(int(classBSRAMNode.getAttribute("start"), 16))
        # SRAM address MSB 24 bits
        classB_SRAM_START_MSB = classBComponent.createHexSymbol("CLASSB_SRAM_START_MSB", None)
        classB_SRAM_START_MSB.setVisible(False)
        classB_SRAM_START_MSB.setDefaultValue(int(classBSRAMNode.getAttribute("start"), 16) >> 8)
        # SRAM reserve size is 64 bytes
        classB_SRAM_RESERVE_SIZE = classBComponent.createIntegerSymbol("CLASSB_SRAM_RESERVE_SIZE", None)
        classB_SRAM_RESERVE_SIZE.setVisible(False)
        classB_SRAM_RESERVE_SIZE.setDefaultValue(int("64", 10))
    
    # Insert CPU test
    classB_UseCPUTest = classBComponent.createBooleanSymbol("CLASSB_CPU_TEST_OPT", classBMenu)
    classB_UseCPUTest.setLabel("Test CPU?")
    classB_UseCPUTest.setVisible(True)
    classB_UseCPUTest.setDefaultValue(False)
    classB_UseCPUTest.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")
    
    # Insert SRAM ECC
    classB_EnableSRAMEcc = classBComponent.createBooleanSymbol("CLASSB_SRAM_ECC_OPT", classBMenu)
    classB_EnableSRAMEcc.setLabel("Enable SRAM ECC?")
    classB_EnableSRAMEcc.setVisible(True)
    classB_EnableSRAMEcc.setDefaultValue(False)
    classB_EnableSRAMEcc.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")
    
    # Insert FLASH ECC
    classB_EnableFlashEcc = classBComponent.createBooleanSymbol("CLASSB_FLASH_ECC_OPT", classBMenu)
    classB_EnableFlashEcc.setLabel("Enable Flash ECC?")
    classB_EnableFlashEcc.setVisible(True)
    classB_EnableFlashEcc.setDefaultValue(False)
    classB_EnableFlashEcc.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")

    # Insert Clock test
    classB_UseClockTest = classBComponent.createBooleanSymbol("CLASSB_CLOCK_TEST_OPT", classBMenu)
    classB_UseClockTest.setLabel("Test CPU Clock?")
    classB_UseClockTest.setVisible(True)
    classB_UseClockTest.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")
    
    # Acceptable CPU clock frequency error at startup
    classb_ClockTestPercentage = classBComponent.createKeyValueSetSymbol("CLASSB_CLOCK_TEST_PERCENT", classB_UseClockTest)
    classb_ClockTestPercentage.setLabel("Permitted CPU clock error at startup")
    classb_ClockTestPercentage.addKey("CLASSB_CLOCK_5PERCENT", "5", "+-5 %")
    classb_ClockTestPercentage.addKey("CLASSB_CLOCK_10PERCENT", "10", "+-10 %")
    classb_ClockTestPercentage.addKey("CLASSB_CLOCK_15PERCENT", "15", "+-15 %")
    classb_ClockTestPercentage.setOutputMode("Value")
    classb_ClockTestPercentage.setDisplayMode("Description")
    classb_ClockTestPercentage.setDescription("Selects the permitted CPU clock error at startup")
    classb_ClockTestPercentage.setDefaultValue(0)
    classb_ClockTestPercentage.setVisible(False)
    classb_ClockTestPercentage.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")
    classb_ClockTestPercentage.setDependencies(setClassB_SymbolVisibility, ["CLASSB_CLOCK_TEST_OPT"])
    
    # Clock test duration
    classb_ClockTestDuration = classBComponent.createIntegerSymbol("CLASSB_CLOCK_TEST_DURATION", classB_UseClockTest)
    classb_ClockTestDuration.setLabel("Clock Test Duration (ms)")
    classb_ClockTestDuration.setDefaultValue(5)
    classb_ClockTestDuration.setVisible(False)
    classb_ClockTestDuration.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")
    classb_ClockTestDuration.setMin(5)
    classb_ClockTestDuration.setMax(20)
    classb_ClockTestDuration.setDependencies(setClassB_SymbolVisibility, ["CLASSB_CLOCK_TEST_OPT"])
    
    # Insert Interrupt test
    classB_UseInterTest = classBComponent.createBooleanSymbol("CLASSB_INTERRUPT_TEST_OPT", classBMenu)
    classB_UseInterTest.setLabel("Test Interrupts?")
    classB_UseInterTest.setVisible(True)
    classB_UseInterTest.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")
    classB_UseInterTest.setDefaultValue(False)
    classB_UseInterTest.setDescription("This self-test check interrupts operation with the help of NVIC, RTC and TC0")

    classBReadOnlyParams = classBComponent.createMenuSymbol("CLASSB_ADDR_MENU", None)
    classBReadOnlyParams.setLabel("Build parameters (read-only) used by the library")
    
    # Read-only symbol for start of non-reserved SRAM
    classb_AppRam_start = classBComponent.createHexSymbol("CLASSB_SRAM_APP_START", classBReadOnlyParams)
    classb_AppRam_start.setLabel("Start address of non-reserved SRAM")
    classb_AppRam_start.setDefaultValue(classB_SRAM_ADDR.getValue() + classB_SRAM_RESERVE_SIZE.getValue())
    classb_AppRam_start.setReadOnly(True)
    classb_AppRam_start.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")
    classb_AppRam_start.setMin(classB_SRAM_ADDR.getValue() + classB_SRAM_RESERVE_SIZE.getValue())
    classb_AppRam_start.setMax(classB_SRAM_ADDR.getValue() + classB_SRAM_RESERVE_SIZE.getValue())
    classb_AppRam_start.setDescription("Initial " + str(classB_SRAM_RESERVE_SIZE.getValue()) +" bytes of SRAM is used by the Class B library")
    
    # Update value of Global symbols for SRAM
    sram_len_str = str((hex(classb_AppRam_start.getValue())))
    Database.setSymbolValue("core", "IRAM1_START", sram_len_str.strip("L"))
    Database.setSymbolValue("core", "IRAM1_SIZE", str((hex(classB_SRAM_SIZE.getValue() - classB_SRAM_RESERVE_SIZE.getValue()))))
      
    # Read-only symbol for max SysTick count
    classb_SysTickMaxCount = classBComponent.createHexSymbol("CLASSB_SYSTICK_MAXCOUNT", classBReadOnlyParams)
    classb_SysTickMaxCount.setLabel("Maximum SysTick count")
    classb_SysTickMaxCount.setDefaultValue(0xFFFFFF)
    classb_SysTickMaxCount.setReadOnly(True)
    classb_SysTickMaxCount.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")
    classb_SysTickMaxCount.setMin(0xFFFFFF)
    classb_SysTickMaxCount.setMax(0xFFFFFF)
    classb_SysTickMaxCount.setDescription("The SysTick is a 24-bit counter with max count value " + str(hex(classb_SysTickMaxCount.getValue())))
    
    # Read-only symbol for max CPU clock frequency
    classb_CPU_MaxClock = classBComponent.createIntegerSymbol("CLASSB_CPU_MAX_CLOCK", classBReadOnlyParams)
    classb_CPU_MaxClock.setLabel("Maximum CPU clock frequency")
    classb_CPU_MaxClock.setDefaultValue(48000000)
    classb_CPU_MaxClock.setReadOnly(True)
    classb_CPU_MaxClock.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")
    classb_CPU_MaxClock.setMin(48000000)
    classb_CPU_MaxClock.setMax(48000000)
    classb_CPU_MaxClock.setDescription("The self-test for CPU clock frequency assumes that the maximum CPU clock frequency is " + str(classb_CPU_MaxClock.getValue()) + "Hz")
    
    # Read-only symbol for expected RTC clock frequency
    classb_RTC_Clock = classBComponent.createIntegerSymbol("CLASSB_RTC_EXPECTED_CLOCK", classBReadOnlyParams)
    classb_RTC_Clock.setLabel("Expected RTC clock frequency")
    classb_RTC_Clock.setDefaultValue(32768)
    classb_RTC_Clock.setReadOnly(True)
    classb_RTC_Clock.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")
    classb_RTC_Clock.setMin(32768)
    classb_RTC_Clock.setMax(32768)
    classb_RTC_Clock.setDescription("The self-test for CPU clock frequency expects the RTC clock frequency to be " + str(classb_RTC_Clock.getValue()) + "Hz")
    
    # Read-only symbol for maximum configurable accuracy for CPU clock self-test
    classb_MaxAccuracy = classBComponent.createIntegerSymbol("CLASSB_CPU_CLOCK_TEST_ACCUR", classBReadOnlyParams)
    classb_MaxAccuracy.setLabel("Maximum accuracy for CPU clock test")
    classb_MaxAccuracy.setDefaultValue(5)
    classb_MaxAccuracy.setReadOnly(True)
    classb_MaxAccuracy.setHelp("Harmony_ClassB_Library_for_PIC32CM_JH00_JH01")
    classb_MaxAccuracy.setMin(5)
    classb_MaxAccuracy.setMax(5)
    classb_MaxAccuracy.setDescription("Error percentage selected for CPU clock frequency test must be " + str(classb_MaxAccuracy.getValue()) + "% or higher")

############################################################################
#### Code Generation ####
############################################################################

    # Symbol for result management source file
    classBSourceResultMgmt = classBComponent.createFileSymbol("CLASSB_SOURCE_RESULT_MGMT", None)
    classBSourceResultMgmt.setSourcePath("/templates/pic32cm_jh/classb_result_management_xc32.S.ftl")
    classBSourceResultMgmt.setOutputName("classb_result_management.S")
    classBSourceResultMgmt.setDestPath("/classb")
    classBSourceResultMgmt.setProjectPath("config/" + configName + "/classb")
    classBSourceResultMgmt.setType("SOURCE")
    classBSourceResultMgmt.setMarkup(True)
    
    # Header File for result handling
    classBHeaderResultMgmt = classBComponent.createFileSymbol("CLASSB_HEADER_RESULT_MGMT", None)
    classBHeaderResultMgmt.setSourcePath("/templates/pic32cm_jh/classb_result_management.h.ftl")
    classBHeaderResultMgmt.setOutputName("classb_result_management.h")
    classBHeaderResultMgmt.setDestPath("/classb")
    classBHeaderResultMgmt.setProjectPath("config/" + configName +"/classb")
    classBHeaderResultMgmt.setType("HEADER")
    classBHeaderResultMgmt.setMarkup(True)
    
    # Source File for CPU test
    classBSourceCpuTestAsm = classBComponent.createFileSymbol("CLASSB_SOURCE_CPUTEST_S", None)
    classBSourceCpuTestAsm.setSourcePath("/templates/pic32cm_jh/classb_cpu_reg_test_xc32.S.ftl")
    classBSourceCpuTestAsm.setOutputName("classb_cpu_reg_test.S")
    classBSourceCpuTestAsm.setDestPath("/classb")
    classBSourceCpuTestAsm.setProjectPath("config/" + configName + "/classb")
    classBSourceCpuTestAsm.setType("SOURCE")
    classBSourceCpuTestAsm.setMarkup(True)
        
    # Header File for CPU test
    classBHeaderCpuTestAsm = classBComponent.createFileSymbol("CLASSB_HEADER_CPU_TEST", None)
    classBHeaderCpuTestAsm.setSourcePath("/templates/pic32cm_jh/classb_cpu_reg_test.h.ftl")
    classBHeaderCpuTestAsm.setOutputName("classb_cpu_reg_test.h")
    classBHeaderCpuTestAsm.setDestPath("/classb")
    classBHeaderCpuTestAsm.setProjectPath("config/" + configName +"/classb")
    classBHeaderCpuTestAsm.setType("HEADER")
    classBHeaderCpuTestAsm.setMarkup(True)
    
    # Main Header File
    classBHeaderFile = classBComponent.createFileSymbol("CLASSB_HEADER", None)
    classBHeaderFile.setSourcePath("/templates/pic32cm_jh/classb.h.ftl")
    classBHeaderFile.setOutputName("classb.h")
    classBHeaderFile.setDestPath("/classb")
    classBHeaderFile.setProjectPath("config/" + configName + "/classb")
    classBHeaderFile.setType("HEADER")
    classBHeaderFile.setMarkup(True)
    
    # Main Source File
    classBSourceFile = classBComponent.createFileSymbol("CLASSB_SOURCE", None)
    classBSourceFile.setSourcePath("/templates/pic32cm_jh/classb.c.ftl")
    classBSourceFile.setOutputName("classb.c")
    classBSourceFile.setDestPath("/classb")
    classBSourceFile.setProjectPath("config/" + configName + "/classb")
    classBSourceFile.setType("SOURCE")
    classBSourceFile.setMarkup(True)
    
    # Header File common for all tests
    classBCommHeaderFile = classBComponent.createFileSymbol("CLASSB_COMMON_HEADER", None)
    classBCommHeaderFile.setSourcePath("/templates/pic32cm_jh/classb_common.h.ftl")
    classBCommHeaderFile.setOutputName("classb_common.h")
    classBCommHeaderFile.setDestPath("/classb")
    classBCommHeaderFile.setProjectPath("config/" + configName +"/classb")
    classBCommHeaderFile.setType("HEADER")
    classBCommHeaderFile.setMarkup(True)
      
    # Source File for CPU PC test
    classBSourceCpuPCTest = classBComponent.createFileSymbol("CLASSB_SOURCE_CPUPC_TEST", None)
    classBSourceCpuPCTest.setSourcePath("/templates/pic32cm_jh/classb_cpu_pc_test.c.ftl")
    classBSourceCpuPCTest.setOutputName("classb_cpu_pc_test.c")
    classBSourceCpuPCTest.setDestPath("/classb")
    classBSourceCpuPCTest.setProjectPath("config/" + configName + "/classb")
    classBSourceCpuPCTest.setType("SOURCE")
    classBSourceCpuPCTest.setMarkup(True)
    
    # Source File for SRAM test
    classBSourceSRAMTest = classBComponent.createFileSymbol("CLASSB_SOURCE_SRAM_TEST", None)
    classBSourceSRAMTest.setSourcePath("/templates/pic32cm_jh/classb_sram_test.c.ftl")
    classBSourceSRAMTest.setOutputName("classb_sram_test.c")
    classBSourceSRAMTest.setDestPath("/classb")
    classBSourceSRAMTest.setProjectPath("config/" + configName + "/classb")
    classBSourceSRAMTest.setType("SOURCE")
    classBSourceSRAMTest.setMarkup(True)
    
    # Header File for SRAM test
    classBHeaderSRAMTest = classBComponent.createFileSymbol("CLASSB_HEADER_SRAM_TEST", None)
    classBHeaderSRAMTest.setSourcePath("/templates/pic32cm_jh/classb_sram_test.h.ftl")
    classBHeaderSRAMTest.setOutputName("classb_sram_test.h")
    classBHeaderSRAMTest.setDestPath("/classb")
    classBHeaderSRAMTest.setProjectPath("config/" + configName +"/classb")
    classBHeaderSRAMTest.setType("HEADER")
    classBHeaderSRAMTest.setMarkup(True)
    
    # Source File for Flash test
    classBSourceFLASHTest = classBComponent.createFileSymbol("CLASSB_SOURCE_FLASH_TEST", None)
    classBSourceFLASHTest.setSourcePath("/templates/pic32cm_jh/classb_flash_test.c.ftl")
    classBSourceFLASHTest.setOutputName("classb_flash_test.c")
    classBSourceFLASHTest.setDestPath("/classb")
    classBSourceFLASHTest.setProjectPath("config/" + configName + "/classb")
    classBSourceFLASHTest.setType("SOURCE")
    classBSourceFLASHTest.setMarkup(True)
    
    # Header File for Flash test
    classBHeaderFLASHTest = classBComponent.createFileSymbol("CLASSB_HEADER_FLASH_TEST", None)
    classBHeaderFLASHTest.setSourcePath("/templates/pic32cm_jh/classb_flash_test.h.ftl")
    classBHeaderFLASHTest.setOutputName("classb_flash_test.h")
    classBHeaderFLASHTest.setDestPath("/classb")
    classBHeaderFLASHTest.setProjectPath("config/" + configName +"/classb")
    classBHeaderFLASHTest.setType("HEADER")
    classBHeaderFLASHTest.setMarkup(True)
    
    # Source File for Clock test
    classBSourceClockTest = classBComponent.createFileSymbol("CLASSB_SOURCE_CLOCK_TEST", None)
    classBSourceClockTest.setSourcePath("/templates/pic32cm_jh/classb_clock_test.c.ftl")
    classBSourceClockTest.setOutputName("classb_clock_test.c")
    classBSourceClockTest.setDestPath("/classb")
    classBSourceClockTest.setProjectPath("config/" + configName + "/classb")
    classBSourceClockTest.setType("SOURCE")
    classBSourceClockTest.setMarkup(True)
    
    # Header File for Clock test
    classBHeaderClockTest = classBComponent.createFileSymbol("CLASSB_HEADER_CLOCK_TEST", None)
    classBHeaderClockTest.setSourcePath("/templates/pic32cm_jh/classb_clock_test.h.ftl")
    classBHeaderClockTest.setOutputName("classb_clock_test.h")
    classBHeaderClockTest.setDestPath("/classb")
    classBHeaderClockTest.setProjectPath("config/" + configName +"/classb")
    classBHeaderClockTest.setType("HEADER")
    classBHeaderClockTest.setMarkup(True)
    
    # Source File for Interrupt test
    classBSourceInterruptTest = classBComponent.createFileSymbol("CLASSB_SOURCE_INTERRUPT_TEST", None)
    classBSourceInterruptTest.setSourcePath("/templates/pic32cm_jh/classb_interrupt_test.c.ftl")
    classBSourceInterruptTest.setOutputName("classb_interrupt_test.c")
    classBSourceInterruptTest.setDestPath("/classb")
    classBSourceInterruptTest.setProjectPath("config/" + configName + "/classb")
    classBSourceInterruptTest.setType("SOURCE")
    classBSourceInterruptTest.setMarkup(True)
    
    # Header File for Interrupt test
    classBHeaderInterruptTest = classBComponent.createFileSymbol("CLASSB_HEADER_INTERRUPT_TEST", None)
    classBHeaderInterruptTest.setSourcePath("/templates/pic32cm_jh/classb_interrupt_test.h.ftl")
    classBHeaderInterruptTest.setOutputName("classb_interrupt_test.h")
    classBHeaderInterruptTest.setDestPath("/classb")
    classBHeaderInterruptTest.setProjectPath("config/" + configName +"/classb")
    classBHeaderInterruptTest.setType("HEADER")
    classBHeaderInterruptTest.setMarkup(True)
    
    # Source File for IO pin test
    classBSourceIOpinTest = classBComponent.createFileSymbol("CLASSB_SOURCE_IOPIN_TEST", None)
    classBSourceIOpinTest.setSourcePath("/templates/pic32cm_jh/classb_io_pin_test.c.ftl")
    classBSourceIOpinTest.setOutputName("classb_io_pin_test.c")
    classBSourceIOpinTest.setDestPath("/classb")
    classBSourceIOpinTest.setProjectPath("config/" + configName + "/classb")
    classBSourceIOpinTest.setType("SOURCE")
    classBSourceIOpinTest.setMarkup(True)
    
    # Header File for IO pin test
    classBHeaderIOpinTest = classBComponent.createFileSymbol("CLASSB_HEADER_IOPIN_TEST", None)
    classBHeaderIOpinTest.setSourcePath("/templates/pic32cm_jh/classb_io_pin_test.h.ftl")
    classBHeaderIOpinTest.setOutputName("classb_io_pin_test.h")
    classBHeaderIOpinTest.setDestPath("/classb")
    classBHeaderIOpinTest.setProjectPath("config/" + configName +"/classb")
    classBHeaderIOpinTest.setType("HEADER")
    classBHeaderIOpinTest.setMarkup(True)
    
    # System Definition
    classBSystemDefFile = classBComponent.createFileSymbol("CLASSB_SYS_DEF", None)
    classBSystemDefFile.setType("STRING")
    classBSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    classBSystemDefFile.setSourcePath("/templates/system/definitions.h.ftl")
    classBSystemDefFile.setMarkup(True)

    # System Startup Modification to comment RAM_Initialize()
    classBSystemStartupFile = classBComponent.createFileSymbol("CLASSB_SYS_STARTUP", None)
    classBSystemStartupFile.setSourcePath("/templates/startup_xc32.c.ftl")
    classBSystemStartupFile.setOutputName("startup_xc32.c")
    classBSystemStartupFile.setDestPath("/")
    classBSystemStartupFile.setProjectPath("config/" + configName + "/")
    classBSystemStartupFile.setType("SOURCE")
    classBSystemStartupFile.setMarkup(True)

    # System SRAM ECC Interrupt Modification to interrupt files
    classBSystemSRAMInterruptSymbol = classBComponent.createStringSymbol("CLASSB_SYS_SRAM_INT_SYM", None)
    classBSystemSRAMInterruptSymbol.setVisible(False)
    classBSystemSRAMInterruptSymbol.setValue("CLASSB_SRAM_ECC_InterruptHandler")
    classBSystemSRAMInterruptSymbol.setDependencies(setClassB_UpdateInterrupt, ["CLASSB_SRAM_ECC_OPT"])

    # System Flash ECC Interrupt Modification to interrupt files
    classBSystemFlashInterruptSymbol = classBComponent.createStringSymbol("CLASSB_SYS_FLASH_INT_SYM", None)
    classBSystemFlashInterruptSymbol.setVisible(False)
    classBSystemFlashInterruptSymbol.setValue("CLASSB_FLASH_ECC_InterruptHandler")
    classBSystemFlashInterruptSymbol.setDependencies(setClassB_UpdateInterrupt, ["CLASSB_FLASH_ECC_OPT"])
    
    # Linker option to reserve classB reserve size of SRAM
    classB_xc32ld_reserve_sram = classBComponent.createSettingSymbol("CLASSB_XC32LD_RESERVE_SRAM", None)
    classB_xc32ld_reserve_sram.setCategory("C32-LD")
    classB_xc32ld_reserve_sram.setKey("appendMe")
    classB_xc32ld_reserve_sram.setValue("-DRAM_ORIGIN=" + hex(int(classBSRAMNode.getAttribute("start"), 16) + classB_SRAM_RESERVE_SIZE.getValue()) + ",-DRAM_LENGTH=" + hex(int(classBSRAMNode.getAttribute("size"), 16) - classB_SRAM_RESERVE_SIZE.getValue()))
