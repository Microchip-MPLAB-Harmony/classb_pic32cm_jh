/*******************************************************************************
  Class B Library v0.1.0 Release

  Company:
    Microchip Technology Inc.

  File Name:
    classb_common.h

  Summary:
    Class B Library

  Description:
    Common type definitions for class b functions

*******************************************************************************/

/*******************************************************************************
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
*******************************************************************************/

#ifndef CLASSB_COMMON_H
#define CLASSB_COMMON_H

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END

/*----------------------------------------------------------------------------
 *     Include files
 *----------------------------------------------------------------------------*/
#include "device.h"
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

/*----------------------------------------------------------------------------
 *     Constants
 *----------------------------------------------------------------------------*/
#if (defined (__XC32))
	#define OPTIMIZE_O0 __attribute__((optimize("-O0")))
#else
	#define OPTIMIZE_O0
#endif

/*----------------------------------------------------------------------------
 *     Globals
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------
 *     Data types
 *----------------------------------------------------------------------------*/
 
// *****************************************************************************
/* Class B library self-test state

  Summary:
    Identifies Class B library test state

  Description:
    This data type is used to update flags which indicates whether a test
    has started or not.

  Remarks:
    None.
*/
typedef enum classb_test_state
{
    CLASSB_TEST_NOT_STARTED = 0U,
    CLASSB_TEST_STARTED = 1U
} CLASSB_TEST_STATE;

// *****************************************************************************
/* Class B library self-test identifier

  Summary:
    Identifies Class B library tests

  Description:
    This enumeration can be used to read the self-test status and update it.
    Test ID corresponds to the bit position at which the 2-bit test result
    is stored.

  Remarks:
    None.
*/
typedef enum classb_test_id
{
    CLASSB_TEST_CPU         = 0U,
    CLASSB_TEST_PC          = 2U,
    CLASSB_TEST_RESERVE1    = 4U,
    CLASSB_TEST_RESERVE2    = 6U,
    CLASSB_TEST_CLOCK       = 8U,
    CLASSB_TEST_INTERRUPT   = 10U,
    CLASSB_TEST_IO          = 12U
} CLASSB_TEST_ID;

// *****************************************************************************
/* Class B library self-test result

  Summary:
    Identifies result from Class B library test

  Description:
    This is return type for self-tests.

  Remarks:
    None.
*/
typedef enum classb_test_status
{
    CLASSB_TEST_NOT_EXECUTED  = 0U,
    CLASSB_TEST_PASSED        = 1U,
    CLASSB_TEST_FAILED        = 2U,
    CLASSB_TEST_INPROGRESS    = 3U
} CLASSB_TEST_STATUS;

// *****************************************************************************
/* Class B library initialization status

  Summary:
    Identifies Class B initialization status

  Description:
    This is return type for the function which initializes the Class B
    library during startup. This indicates whether the SSTs are executed or not.

  Remarks:
    None.
*/
typedef enum classb_init_status
{
    CLASSB_SST_DONE = 1U,
    CLASSB_SST_NOT_DONE = 2U
} CLASSB_INIT_STATUS;

// *****************************************************************************
/* Class B library startup self-tests status

  Summary:
    Identifies startup test status

  Description:
    This is return type for the function which calls all self-tests
    during startup.

  Remarks:
    None.
*/
typedef enum classb_startup_status
{
    CLASSB_STARTUP_TEST_NOT_EXECUTED  = 0U,
    CLASSB_STARTUP_TEST_PASSED = 1U,
    CLASSB_STARTUP_TEST_FAILED = 2U
} CLASSB_STARTUP_STATUS;

// *****************************************************************************
/* Class B library self-test type

  Summary:
    Identifies type of the Class B library test

  Description:
    There are two categories of test. They are startup tests (SSTs) and
    run-time tests (RSTs). Test results for SSTs and RSTs are stored at
    separately in the SRAM.

  Remarks:
    None.
*/
typedef enum classb_test_type
{
    CLASSB_TEST_TYPE_SST  = 0U,
    CLASSB_TEST_TYPE_RST  = 1U
} CLASSB_TEST_TYPE;

// *****************************************************************************
/* Structure for Class B library self-test result

  Summary:
    Structure for Class B library self-test result

  Description:
    For bit-field representation of Class B library test results.

  Remarks:
    None.
*/
typedef struct classb_sst_result_bf
{
    CLASSB_TEST_STATUS CPU_STATUS:2;
    CLASSB_TEST_STATUS PC_STATUS:2;
    CLASSB_TEST_STATUS RESERVE1_STATUS:2;
    CLASSB_TEST_STATUS RESERVE2_STATUS:2;
    CLASSB_TEST_STATUS CLOCK_STATUS:2;
    CLASSB_TEST_STATUS INTERRUPT_STATUS:2;
} *CLASSB_SST_RESULT_BF;

// *****************************************************************************
/* Structure for Class B library self-test result

  Summary:
    Structure for Class B library self-test result

  Description:
    For bit-field representation of Class B library test results.

  Remarks:
    None.
*/
typedef struct classb_rst_result_bf
{
    CLASSB_TEST_STATUS CPU_STATUS:2;
    CLASSB_TEST_STATUS PC_STATUS:2;
    CLASSB_TEST_STATUS RESERVE1_STATUS:2;
    CLASSB_TEST_STATUS RESERVE2_STATUS:2;
    CLASSB_TEST_STATUS CLOCK_STATUS:2;
    CLASSB_TEST_STATUS RESERVE3_STATUS:2;
    CLASSB_TEST_STATUS IO_STATUS:2;
} *CLASSB_RST_RESULT_BF;


/*----------------------------------------------------------------------------
 *     Functions
 *----------------------------------------------------------------------------*/
/* Function called when a non-critical self-test fails */
void CLASSB_SelfTest_FailSafe(CLASSB_TEST_ID test_id);

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif
// DOM-IGNORE-END
#endif // CLASSB_COMMON_H
