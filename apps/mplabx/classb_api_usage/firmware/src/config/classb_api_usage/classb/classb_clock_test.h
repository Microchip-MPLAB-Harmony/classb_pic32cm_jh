/*******************************************************************************
  Class B Library v1.0.2 Release

  Company:
    Microchip Technology Inc.

  File Name:
    classb_clock_test.h

  Summary:
    Header file for Clock self-tests

  Description:
    This file provides function prototypes, macros and datatypes for the
    Clock test.

*******************************************************************************/

/*******************************************************************************
* Copyright (C) 2021 Microchip Technology Inc. and its subsidiaries.
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

#ifndef CLASSB_CLOCK_TEST_H
#define CLASSB_CLOCK_TEST_H

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END

/*----------------------------------------------------------------------------
 *     Include files
 *----------------------------------------------------------------------------*/
#include "classb/classb_common.h"

/*----------------------------------------------------------------------------
 *     Constants
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------
 *     Data types
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------
 *     Functions
 *----------------------------------------------------------------------------*/

CLASSB_TEST_STATUS CLASSB_ClockTest(uint32_t cpu_clock_freq,
    uint8_t error_limit,
    uint16_t clock_test_rtc_cycles,
    bool running_context);

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif
// DOM-IGNORE-END
#endif // CLASSB_CLOCK_TEST_H
