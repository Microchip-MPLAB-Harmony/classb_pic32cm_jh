/*******************************************************************************
  Class B Library ${REL_VER} Release

  Company:
    Microchip Technology Inc.

  File Name:
    classb_io_pin_test.h

  Summary:
    Header file for I/O pin self-tests

  Description:
    This file provides function prototypes, macros and datatypes for the
    I/O pin test.

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

#ifndef CLASSB_IO_PIN_TEST_H
#define CLASSB_IO_PIN_TEST_H

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
// *****************************************************************************
/* PORT index definitions

  Summary:
    PORT index definitions for Class B library I/O pin test

  Description:
    This can be used in the I/O pin test.

  Remarks:
    None.
*/
typedef enum classb_port_index
{
    PORTA = 0U,
    PORTB = 1U,
    PORTC = 2U,
} CLASSB_PORT_INDEX;

// *****************************************************************************
/* PIN definitions

  Summary:
    PIN definitions for Class B library I/O pin test

  Description:
    This can be used in the I/O pin test.

  Remarks:
    None.
*/
typedef enum classb_port_pin
{
    PIN0 = 0U,
    PIN1 = 1U,
    PIN2 = 2U,
    PIN3 = 3U,
    PIN4 = 4U,
    PIN5 = 5U,
    PIN6 = 6U,
    PIN7 = 7U,
    PIN8 = 8U,
    PIN9 = 9U,
    PIN10 = 10U,
    PIN11 = 11U,
    PIN12 = 12U,
    PIN13 = 13U,
    PIN14 = 14U,
    PIN15 = 15U,
    PIN16 = 16U,
    PIN17 = 17U,
    PIN18 = 18U,
    PIN19 = 19U,
    PIN20 = 20U,
    PIN21 = 21U,
    PIN22 = 22U,
    PIN23 = 23U,
    PIN24 = 24U,
    PIN25 = 25U,
    PIN26 = 26U,
    PIN27 = 27U,
    PIN28 = 28U,
    PIN29 = 29U,
    PIN30 = 30U,
    PIN31 = 31U
} CLASSB_PORT_PIN;

// *****************************************************************************
/* PORT pin state

  Summary:
    PORT pin state

  Description:
    This can be used in the I/O pin test.

  Remarks:
    None.
*/
typedef enum classb_port_pin_state
{
    PORT_PIN_LOW  = 0U,
    PORT_PIN_HIGH = 1U,
    PORT_PIN_INVALID = 2U
} CLASSB_PORT_PIN_STATE;

/*----------------------------------------------------------------------------
 *     Functions
 *----------------------------------------------------------------------------*/

CLASSB_TEST_STATUS CLASSB_RST_IOTest(CLASSB_PORT_INDEX port, CLASSB_PORT_PIN pin,
    CLASSB_PORT_PIN_STATE state);
void CLASSB_IO_InputSamplingEnable(CLASSB_PORT_INDEX port, CLASSB_PORT_PIN pin);

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif
// DOM-IGNORE-END
#endif // CLASSB_IO_PIN_TEST_H
