/*******************************************************************************
  Class B Library ${REL_VER} Release

  Company:
    Microchip Technology Inc.

  File Name:
    classb.c

  Summary:
    Class B Library main source file

  Description:
    This file provides general functions for the Class B library.

*******************************************************************************/

/*******************************************************************************
* Copyright (C) ${REL_YEAR} Microchip Technology Inc. and its subsidiaries.
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
*******************************************************************************/

/*----------------------------------------------------------------------------
 *     include files
 *----------------------------------------------------------------------------*/
#include "classb/classb.h"

/*----------------------------------------------------------------------------
 *     Constants
 *----------------------------------------------------------------------------*/
#define CLASSB_RESULT_ADDR                  (0x${CLASSB_SRAM_START_ADDRESS}U)
#define CLASSB_COMPL_RESULT_ADDR            (0x${CLASSB_SRAM_START_MSB + "08"}U)
#define CLASSB_ONGOING_TEST_VAR_ADDR        (0x${CLASSB_SRAM_START_MSB + "10"}U)
#define CLASSB_TEST_IN_PROG_VAR_ADDR        (0x${CLASSB_SRAM_START_MSB + "14"}U)
#define CLASSB_WDT_TEST_IN_PROG_VAR_ADDR    (0x${CLASSB_SRAM_START_MSB + "18"}U)
#define CLASSB_INTERRUPT_TEST_VAR_ADDR      (0x${CLASSB_SRAM_START_MSB + "1c"}U)
#define CLASSB_INTERRUPT_COUNT_VAR_ADDR     (0x${CLASSB_SRAM_START_MSB + "20"}U)
#define CLASSB_CLOCK_ERROR_PERCENT          (${CLASSB_CLOCK_TEST_PERCENT}U)
/* RTC is clocked from 32768 Hz Crystal for CPU clock test.
   One RTC cycle is 30517 nano sec */
#define CLASSB_CLOCK_TEST_RTC_RATIO_NS      (30517U)
#define CLASSB_CLOCK_TEST_RATIO_NS_MS       (1000000U)
#define CLASSB_CLOCK_DEFAULT_CLOCK_FREQ     (4000000U)
#define CLASSB_INVALID_TEST_ID              (0xFFU)

/*----------------------------------------------------------------------------
 *     Global Variables
 *----------------------------------------------------------------------------*/
volatile uint8_t * ongoing_sst_id;
volatile uint8_t * classb_test_in_progress;
volatile uint8_t * wdt_test_in_progress;
volatile uint8_t * interrupt_tests_status;
volatile uint32_t * interrupt_count;

/*----------------------------------------------------------------------------
 *     Functions
 *----------------------------------------------------------------------------*/
<#if CLASSB_SRAM_ECC_OPT??>
    <#if CLASSB_SRAM_ECC_OPT == true>
/*============================================================================
static void CLASSB_SRAM_Callback(uint32_t status, uintptr_t context)
------------------------------------------------------------------------------
Purpose: Called if a single fault error detected by SRAM ECC.
Input  : None.
Output : None
Notes  : The application decides the contents of this function.
         This function must not return.
============================================================================*/
static void CLASSB_SRAM_Callback(uint32_t status, uintptr_t context) {
#if (defined(__DEBUG) || defined(__DEBUG_D)) && defined(__XC32)
    __builtin_software_breakpoint();
#endif
    // Infinite loop
    while (1)
    {
        ;
    }
}

    </#if>
</#if>
<#if CLASSB_FLASH_ECC_OPT??>
    <#if CLASSB_FLASH_ECC_OPT == true>
/*============================================================================
static void CLASSB_FLASH_Callback(uint32_t status, uintptr_t context)
------------------------------------------------------------------------------
Purpose: Called if a single fault error detected by Flash ECC.
Input  : None
Output : None
Notes  : The application decides the contents of this function.
         This function must not return.
============================================================================*/
static void CLASSB_FLASH_Callback(uint32_t status, uintptr_t context) {
#if (defined(__DEBUG) || defined(__DEBUG_D)) && defined(__XC32)
    __builtin_software_breakpoint();
#endif
    // Infinite loop
    while (1)
    {
        ;
    }
}

    </#if>
</#if>
/*============================================================================
void CLASSB_SelfTest_FailSafe(CLASSB_TEST_ID cb_test_id)
------------------------------------------------------------------------------
Purpose: Called if a non-critical self-test is failed.
Input  : The ID of the failed test.
Output : None
Notes  : The application decides the contents of this function. This function
         should perform failsafe operation after checking the 'cb_test_id'.
         This function must not return.
============================================================================*/
void CLASSB_SelfTest_FailSafe(CLASSB_TEST_ID cb_test_id)
{
#if (defined(__DEBUG) || defined(__DEBUG_D)) && defined(__XC32)
    __builtin_software_breakpoint();
#endif
    // Infinite loop
    while (1)
    {
        ;
    }
}

/*============================================================================
static void CLASSB_GlobalsInit(void)
------------------------------------------------------------------------------
Purpose: Initialization of global variables for the classb library.
Input  : None
Output : None
Notes  : This function is called before C startup code
============================================================================*/
static void CLASSB_GlobalsInit(void)
{
    /* Initialize pointers needed to access variables in SRAM.
     * These variables point to address' in the reserved SRAM for the
     * Class B library.
     */
    ongoing_sst_id = (volatile uint8_t *)CLASSB_ONGOING_TEST_VAR_ADDR;
    classb_test_in_progress = (volatile uint8_t *)CLASSB_TEST_IN_PROG_VAR_ADDR;
    wdt_test_in_progress = (volatile uint8_t *)CLASSB_WDT_TEST_IN_PROG_VAR_ADDR;
    interrupt_tests_status = (volatile uint8_t *)CLASSB_INTERRUPT_TEST_VAR_ADDR;
    interrupt_count = (volatile uint32_t *)CLASSB_INTERRUPT_COUNT_VAR_ADDR;
    
    // Initialize variables
    *ongoing_sst_id = CLASSB_INVALID_TEST_ID;
    *classb_test_in_progress = CLASSB_TEST_NOT_STARTED;
    *wdt_test_in_progress = CLASSB_TEST_NOT_STARTED;
    *interrupt_tests_status = CLASSB_TEST_NOT_STARTED;
}

/*============================================================================
static void CLASSB_App_WDT_Recovery(void)
------------------------------------------------------------------------------
Purpose: Called if a WDT reset is caused by the application
Input  : None
Output : None
Notes  : The application decides the contents of this function.
============================================================================*/
static void CLASSB_App_WDT_Recovery(void)
{
#if (defined(__DEBUG) || defined(__DEBUG_D)) && defined(__XC32)
    __builtin_software_breakpoint();
#endif
    // Infinite loop
    while (1)
    {
        ;
    }
}

/*============================================================================
static void CLASSB_SST_WDT_Recovery(void)
------------------------------------------------------------------------------
Purpose: Called after WDT reset, to indicate that a Class B function is stuck.
Input  : None
Output : None
Notes  : The application decides the contents of this function.
============================================================================*/
static void CLASSB_SST_WDT_Recovery(void)
{
#if (defined(__DEBUG) || defined(__DEBUG_D)) && defined(__XC32)
    __builtin_software_breakpoint();
#endif
    // Infinite loop
    while (1)
    {
        ;
    }
}

/*============================================================================
static void CLASSB_TestWDT(void)
------------------------------------------------------------------------------
Purpose: Function to check WDT after a device reset.
Input  : None
Output : None
Notes  : None
============================================================================*/
static void CLASSB_TestWDT(void)
{
    /* This persistent flag is checked after reset */
    *wdt_test_in_progress = CLASSB_TEST_STARTED;

    /* If WDT ALWAYSON is set, wait till WDT resets the device */
    if ((WDT_REGS->WDT_CTRLA & WDT_CTRLA_ALWAYSON_Msk) == WDT_CTRLA_ALWAYSON_Msk)
    {
        // Infinite loop
        while (1)
        {
            ;
        }
    }
    else
    {
        // If WDT is not enabled, enable WDT and wait
        if ((WDT_REGS->WDT_CTRLA & WDT_CTRLA_ENABLE_Msk) == 0)
        {
            // Configure timeout
            WDT_REGS->WDT_CONFIG = WDT_CONFIG_PER_CYC256;
            WDT_REGS->WDT_CTRLA |= WDT_CTRLA_ENABLE_Msk;
            // Infinite loop
            while (1)
            {
                ;
            }
        }
        else
        {
            // Infinite loop
            while (1)
            {
                ;
            }
        }
    }
}

/*============================================================================
static CLASSB_INIT_STATUS CLASSB_Init(void)
------------------------------------------------------------------------------
Purpose: To check reset cause and decide the startup flow.
Input  : None
Output : None
Notes  : This function is executed on every device reset. This shall be
         called right after the reset, before any other initialization is
         performed.
============================================================================*/
static CLASSB_INIT_STATUS CLASSB_Init(void)
{
    /* Initialize pointers needed to access variables in SRAM.
     * These variables point to address' in the reserved SRAM for the
     * Class B library.
     */
    ongoing_sst_id = (volatile uint8_t *)CLASSB_ONGOING_TEST_VAR_ADDR;
    classb_test_in_progress = (volatile uint8_t *)CLASSB_TEST_IN_PROG_VAR_ADDR;
    wdt_test_in_progress = (volatile uint8_t *)CLASSB_WDT_TEST_IN_PROG_VAR_ADDR;
    interrupt_tests_status = (volatile uint8_t *)CLASSB_INTERRUPT_TEST_VAR_ADDR;
    interrupt_count = (volatile uint32_t *)CLASSB_INTERRUPT_COUNT_VAR_ADDR;

    CLASSB_INIT_STATUS ret_val = CLASSB_SST_NOT_DONE;

    if ((RSTC_REGS->RSTC_RCAUSE & RSTC_RCAUSE_WDT_Msk) == RSTC_RCAUSE_WDT_Msk)
    {
        if (*wdt_test_in_progress == CLASSB_TEST_STARTED)
        {
            *wdt_test_in_progress = CLASSB_TEST_NOT_STARTED;
        }
        else if (*classb_test_in_progress == CLASSB_TEST_STARTED)
        {
            CLASSB_SST_WDT_Recovery();
        }
        else
        {
            CLASSB_App_WDT_Recovery();
        }
    }
    else
    {
        /* If it is a software reset and the Class B library has issued it */
        if ((*classb_test_in_progress == CLASSB_TEST_STARTED) &&
            ((RSTC_REGS->RSTC_RCAUSE & RSTC_RCAUSE_SYST_Msk) == RSTC_RCAUSE_SYST_Msk))
        {
            *classb_test_in_progress = CLASSB_TEST_NOT_STARTED;
            ret_val = CLASSB_SST_DONE;
        }
        else
        {
            /* For all other reset causes,
             * perform SMBIST Test,
             * initialize Class B variables
             * clear the test results and test WDT
             */
            
            // Test the SRAM using SMBIST Module
            // SMBIST is no longer PAC secure to perform SMBIST Test
            PAC_REGS->PAC_WRCTRL = (uint32_t)(PAC_WRCTRL_KEY_CLR | PAC_WRCTRL_PERID (91));

            // Clear SMBIST Status Flags
            SMBIST_REGS->SMBIST_STATUS = (uint32_t) SMBIST_STATUS_Msk;
            // Launch the MBIST Test on SRAM
            SMBIST_REGS->SMBIST_CTRL = (uint32_t)(SMBIST_CTRL_SMBISTP1_Msk | SMBIST_CTRL_SMBISTP2_Msk);
            // Wait for Test to Finish
            while ((SMBIST_REGS->SMBIST_STATUS & SMBIST_STATUS_DONE_Msk) == 0)
            {
                // Wait till SMBIST Test is complete
                ;
            }
            
            // RAM Initialize
            register uint32_t *pRam;
            for (pRam = (uint32_t*)(0x${CLASSB_SRAM_START_ADDRESS}U) ; 
                pRam < ((uint32_t*)(0x${CLASSB_SRAM_START_ADDRESS}U + ${CLASSB_SRAM_SIZE}U)) ; pRam++)
            {
                *pRam = 0U;
            }

            if ((SMBIST_REGS->SMBIST_STATUS & SMBIST_STATUS_FAIL_Msk) == 0)
            {
                // RAM Test passed. Initialize all Class B variables
                CLASSB_GlobalsInit();
                CLASSB_ClearTestResults(CLASSB_TEST_TYPE_SST);
                CLASSB_ClearTestResults(CLASSB_TEST_TYPE_RST);
                // Perform WDT test
                CLASSB_TestWDT();
            }
            else
            {
                while (1)
                {
                    ;
                }
            }
        }
    }

    return ret_val;
}

/*============================================================================
static CLASSB_STARTUP_STATUS CLASSB_Startup_Tests(void)
------------------------------------------------------------------------------
Purpose: Call all startup self-tests.
Input  : None
Output : None
Notes  : This function calls all the configured self-tests during startup.
         The MPLAB Harmony Configurator (MHC) has options to configure
         the startup self-tests. If startup tests are not enabled via MHC,
         this function enables the WDT and returns CLASSB_STARTUP_TEST_NOT_EXECUTED.
============================================================================*/
static CLASSB_STARTUP_STATUS CLASSB_Startup_Tests(void)
{
    <#if (CLASSB_CPU_TEST_OPT?? && CLASSB_CPU_TEST_OPT == true) ||
        (CLASSB_CLOCK_TEST_OPT?? && CLASSB_CLOCK_TEST_OPT == true) ||
        (CLASSB_INTERRUPT_TEST_OPT?? && CLASSB_INTERRUPT_TEST_OPT == true)>
    <#lt>    CLASSB_STARTUP_STATUS cb_startup_status = CLASSB_STARTUP_TEST_NOT_EXECUTED;
    <#else>
    <#lt>    CLASSB_STARTUP_STATUS cb_startup_status = CLASSB_STARTUP_TEST_PASSED;
    </#if>
    <#if (CLASSB_CPU_TEST_OPT?? && CLASSB_CPU_TEST_OPT == true) ||
         (CLASSB_SRAM_ECC_OPT?? && CLASSB_SRAM_ECC_OPT == true) ||
         (CLASSB_FLASH_ECC_OPT?? && CLASSB_FLASH_ECC_OPT == true) ||
         (CLASSB_CLOCK_TEST_OPT?? && CLASSB_CLOCK_TEST_OPT == true) ||
         (CLASSB_INTERRUPT_TEST_OPT?? && CLASSB_INTERRUPT_TEST_OPT == true)>
        <#if (CLASSB_CPU_TEST_OPT?? && CLASSB_CPU_TEST_OPT == true) ||
            (CLASSB_CLOCK_TEST_OPT?? && CLASSB_CLOCK_TEST_OPT == true) ||
            (CLASSB_INTERRUPT_TEST_OPT?? && CLASSB_INTERRUPT_TEST_OPT == true)>
        <#lt>    CLASSB_STARTUP_STATUS cb_temp_startup_status = CLASSB_STARTUP_TEST_NOT_EXECUTED;
        <#lt>    CLASSB_TEST_STATUS cb_test_status = CLASSB_TEST_NOT_EXECUTED;
        </#if>
    
    //Enable watchdog if it is not enabled via Fuses
    if (((WDT_REGS->WDT_CTRLA & WDT_CTRLA_ENABLE_Msk) == 0) &&
        ((WDT_REGS->WDT_CTRLA & WDT_CTRLA_ALWAYSON_Msk) == 0))
    {
        WDT_REGS->WDT_CONFIG = WDT_CONFIG_PER_CYC2048;
        WDT_REGS->WDT_CTRLA |= WDT_CTRLA_ENABLE_Msk;
    }
    
    // Update the flag before running any self-test
    *classb_test_in_progress = CLASSB_TEST_STARTED;
    </#if>
    <#if CLASSB_CLOCK_TEST_OPT??>
        <#if CLASSB_CLOCK_TEST_OPT == true>
            <#if CLASSB_CLOCK_TEST_DURATION?has_content>
            <#lt>    uint16_t clock_test_rtc_cycles = ((${CLASSB_CLOCK_TEST_DURATION}U * CLASSB_CLOCK_TEST_RATIO_NS_MS) / CLASSB_CLOCK_TEST_RTC_RATIO_NS);
            </#if>
        </#if>
    </#if>

    <#if CLASSB_CPU_TEST_OPT?? && CLASSB_CPU_TEST_OPT == true>
        <#lt>    // Test processor core registers
        <#lt>    cb_test_status = CLASSB_CPU_RegistersTest(false);
        <#lt>    if ((cb_temp_startup_status != CLASSB_STARTUP_TEST_FAILED) && (cb_test_status == CLASSB_TEST_PASSED))
        <#lt>    {
        <#lt>        cb_temp_startup_status = CLASSB_STARTUP_TEST_PASSED;
        <#lt>    }
        <#lt>    else if (cb_test_status == CLASSB_TEST_FAILED)
        <#lt>    {
        <#lt>        cb_temp_startup_status = CLASSB_STARTUP_TEST_FAILED;
        <#lt>    }
        <#lt>    else
        <#lt>    {
        <#lt>        // No need to update cb_temp_startup_status
        <#lt>        ;
        <#lt>    }
        <#lt>
        <#lt>    // Program Counter test
        <#lt>    *ongoing_sst_id = CLASSB_TEST_PC;
        <#lt>    cb_test_status = CLASSB_CPU_PCTest(false);
        <#lt>    if ((cb_temp_startup_status != CLASSB_STARTUP_TEST_FAILED) && (cb_test_status == CLASSB_TEST_PASSED))
        <#lt>    {
        <#lt>        cb_temp_startup_status = CLASSB_STARTUP_TEST_PASSED;
        <#lt>    }
        <#lt>    else if (cb_test_status == CLASSB_TEST_FAILED)
        <#lt>    {
        <#lt>        cb_temp_startup_status = CLASSB_STARTUP_TEST_FAILED;
        <#lt>    }
        <#lt>    else
        <#lt>    {
        <#lt>        // No need to update cb_temp_startup_status
        <#lt>        ;
        <#lt>    }
    </#if>
    <#if CLASSB_SRAM_ECC_OPT??>
        <#if CLASSB_SRAM_ECC_OPT == true>
            
            <#lt>    // SRAM ECC Initialize
            <#lt>    CLASSB_SRAM_EccInit(CLASSB_SRAM_Callback, 0);
        </#if>
    </#if>
    <#if CLASSB_FLASH_ECC_OPT??>
        <#if CLASSB_FLASH_ECC_OPT == true>

            <#lt>    // FLASH ECC Initialize
            <#lt>    CLASSB_FLASH_EccInit(CLASSB_FLASH_Callback, 0);
        </#if>
    </#if>
    <#if CLASSB_CLOCK_TEST_OPT??>
        <#if CLASSB_CLOCK_TEST_OPT == true>
            
            <#lt>    // Clock Test
            <#lt>    *ongoing_sst_id = CLASSB_TEST_CLOCK;
            <#lt>    // Clear WDT before test
            <#lt>    WDT_REGS->WDT_CLEAR = WDT_CLEAR_CLEAR_KEY;
            <#if CLASSB_CLOCK_TEST_PERCENT?has_content && CLASSB_CLOCK_TEST_DURATION?has_content>
                <#lt>    cb_test_status = CLASSB_ClockTest(CLASSB_CLOCK_DEFAULT_CLOCK_FREQ, CLASSB_CLOCK_ERROR_PERCENT, clock_test_rtc_cycles, false);
            </#if>
            <#lt>    if ((cb_temp_startup_status != CLASSB_STARTUP_TEST_FAILED) && (cb_test_status == CLASSB_TEST_PASSED))
            <#lt>    {
            <#lt>        cb_temp_startup_status = CLASSB_STARTUP_TEST_PASSED;
            <#lt>    }
            <#lt>    else if (cb_test_status == CLASSB_TEST_FAILED)
            <#lt>    {
            <#lt>        cb_temp_startup_status = CLASSB_STARTUP_TEST_FAILED;
            <#lt>    }
            <#lt>    else
            <#lt>    {
            <#lt>        // No need to update cb_temp_startup_status
            <#lt>        ;
            <#lt>    }
        </#if>
    </#if>
    <#if CLASSB_INTERRUPT_TEST_OPT??>
        <#if CLASSB_INTERRUPT_TEST_OPT == true>

            <#lt>    // Interrupt Test
            <#lt>    *ongoing_sst_id = CLASSB_TEST_INTERRUPT;
            <#lt>    // Clear WDT before test
            <#lt>    WDT_REGS->WDT_CLEAR = WDT_CLEAR_CLEAR_KEY;
            <#lt>    cb_test_status = CLASSB_SST_InterruptTest();
            <#lt>    if ((cb_temp_startup_status != CLASSB_STARTUP_TEST_FAILED) && (cb_test_status == CLASSB_TEST_PASSED))
            <#lt>    {
            <#lt>        cb_temp_startup_status = CLASSB_STARTUP_TEST_PASSED;
            <#lt>    }
            <#lt>    else if (cb_test_status == CLASSB_TEST_FAILED)
            <#lt>    {
            <#lt>        cb_temp_startup_status = CLASSB_STARTUP_TEST_FAILED;
            <#lt>    }
            <#lt>    else
            <#lt>    {
            <#lt>        // No need to update cb_temp_startup_status
            <#lt>        ;
            <#lt>    }
        </#if>
    </#if>
    <#if (CLASSB_CPU_TEST_OPT?? && CLASSB_CPU_TEST_OPT == true) ||
         (CLASSB_CLOCK_TEST_OPT?? && CLASSB_CLOCK_TEST_OPT == true) ||
         (CLASSB_INTERRUPT_TEST_OPT?? && CLASSB_INTERRUPT_TEST_OPT == true)>
    
    <#lt>    if (cb_temp_startup_status == CLASSB_STARTUP_TEST_PASSED)
    <#lt>    {
    <#lt>        cb_startup_status = CLASSB_STARTUP_TEST_PASSED;
    <#lt>    }
    <#lt>    else
    <#lt>    {
    <#lt>        cb_startup_status = CLASSB_STARTUP_TEST_FAILED;
    <#lt>    }
    </#if>
    return cb_startup_status;
}

/*============================================================================
void _on_reset(void)
------------------------------------------------------------------------------
Purpose: Handle reset causes and perform start-up self-tests.
Input  : None
Output : None
Notes  : This function is called from Reset_Handler.
============================================================================*/
#if     (defined (__XC32))
void _on_reset(void)
#elif     (defined (__CC_ARM)) || (defined (__ARMCC_VERSION))
void __attribute__((used)) _on_reset(void)
#endif
{
    CLASSB_STARTUP_STATUS startup_tests_status = CLASSB_STARTUP_TEST_FAILED;

    CLASSB_INIT_STATUS init_status = CLASSB_Init();

    if (init_status == CLASSB_SST_NOT_DONE)
    {
        // Run all startup self-tests
        startup_tests_status = CLASSB_Startup_Tests();

        if (startup_tests_status == CLASSB_STARTUP_TEST_PASSED)
        {
            // Reset the device if all tests are passed.
            NVIC_SystemReset();
        }
        else if (startup_tests_status == CLASSB_STARTUP_TEST_FAILED)
        {
#if (defined(__DEBUG) || defined(__DEBUG_D)) && defined(__XC32)
            __builtin_software_breakpoint();
#endif
            // Infinite loop
            while (1)
            {
                ;
            }
        }
        else
        {
            // If startup tests are not enabled via MHC, do nothing.
            ;
        }
    }
    else if (init_status == CLASSB_SST_DONE)
    {
        // Clear flags
        *classb_test_in_progress = CLASSB_TEST_NOT_STARTED;
    }
    else
    {
        // The init_status is neither CLASSB_SST_NOT_DONE nor CLASSB_SST_DONE, do nothing.
        ;
    }
}
