/*******************************************************************************
  Class B Library ${REL_VER} Release

  Company:
    Microchip Technology Inc.

  File Name:
    classb_sram_test.h

  Summary:
    Header file for SRAM self-tests

  Description:
    This file provides function prototypes, macros and data types for the SRAM
    tests.

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

#ifndef CLASSB_SRAM_TEST_H
#define CLASSB_SRAM_TEST_H

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
#define CLASSB_SRAM_APP_AREA_START          (0x${CLASSB_SRAM_APP_START}U) // Do not modify

/*----------------------------------------------------------------------------
 *     Data types
 *----------------------------------------------------------------------------*/
typedef void (*CLASSB_SRAM_ECC_CALLBACK)(uint32_t status, uintptr_t context);

typedef struct
{
    CLASSB_SRAM_ECC_CALLBACK callback;
    uintptr_t context;
}CLASSB_SRAM_ECC_CALLBACK_OBJ;
/*----------------------------------------------------------------------------
 *     Functions
 *----------------------------------------------------------------------------*/
void CLASSB_SRAM_EccInit(CLASSB_SRAM_ECC_CALLBACK callback, uintptr_t context);

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif
// DOM-IGNORE-END
#endif // CLASSB_SRAM_TEST_H
