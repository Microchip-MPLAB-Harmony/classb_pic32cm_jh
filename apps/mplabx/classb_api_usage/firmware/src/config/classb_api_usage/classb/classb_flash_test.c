/*******************************************************************************
  Class B Library v1.0.2 Release

  Company:
    Microchip Technology Inc.

  File Name:
    classb_flash_test.c

  Summary:
    Class B Library flash program memory self-test source file

  Description:
    This file provides flash program memory self-test.

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

/*----------------------------------------------------------------------------
 *     include files
 *----------------------------------------------------------------------------*/
#include "classb/classb_flash_test.h"

/*----------------------------------------------------------------------------
 *     Constants
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------
 *     Global Variables
 *----------------------------------------------------------------------------*/

volatile static CLASSB_FLASH_ECC_CALLBACK_OBJ CLASSB_FLASH_ECC_CallbackObject;

/*----------------------------------------------------------------------------
 *     Functions
 *----------------------------------------------------------------------------*/
extern void _CLASSB_UpdateTestResult(CLASSB_TEST_TYPE test_type,
    CLASSB_TEST_ID test_id, CLASSB_TEST_STATUS value);

/*============================================================================
void __attribute__((used)) CLASSB_FLASH_ECC_InterruptHandler ( void )
------------------------------------------------------------------------------
Purpose: Interrupt Handler for FLASH ECC.
Input  : None
Output : None.
Notes  : None
============================================================================*/
void __attribute__((used)) CLASSB_FLASH_ECC_InterruptHandler(void) {

    NVMCTRL_REGS->NVMCTRL_INTENCLR = NVMCTRL_INTENCLR_READY_Msk;

    uint32_t status;
    status = NVMCTRL_REGS->NVMCTRL_INTFLAG & NVMCTRL_INTFLAG_Msk;

    /* Clear interrupt */
    NVMCTRL_REGS->NVMCTRL_INTFLAG = status;
    while ((NVMCTRL_REGS->NVMCTRL_INTFLAG & status) != NVMCTRL_INTFLAG_READY_Msk)
    {
        /* Wait for the interrupt status to clear */
        ;
    }
    
    if (CLASSB_FLASH_ECC_CallbackObject.callback != NULL) {
        uintptr_t context = CLASSB_FLASH_ECC_CallbackObject.context;
        CLASSB_FLASH_ECC_CallbackObject.callback(status, context);
    }
}

/*============================================================================
CLASSB_TEST_STATUS CLASSB_FLASH_EccInit(CLASSB_FLASH_ECC_CALLBACK callback, uintptr_t context)
------------------------------------------------------------------------------
Purpose: Initialize ECC to perform fault detection on FLASH.
Input  : Callback function to be called once single fault is detected
         and the context
Output : None.
Notes  : None
============================================================================*/
void CLASSB_FLASH_EccInit(CLASSB_FLASH_ECC_CALLBACK callback, uintptr_t context) {
    /* Register callback function */
    CLASSB_FLASH_ECC_CallbackObject.callback = callback;
    CLASSB_FLASH_ECC_CallbackObject.context = context;
    
    // Enable NVIC IRQn for MCRAMC
    NVIC_EnableIRQ(NVMCTRL_IRQn);
    
    // Enable Single and Double Fault interrupt
    NVMCTRL_REGS->NVMCTRL_INTENSET = NVMCTRL_INTENSET_SERR_Msk | NVMCTRL_INTENSET_DERR_Msk;
    
    if (context == true)
    {
        _CLASSB_UpdateTestResult(CLASSB_TEST_TYPE_RST, CLASSB_TEST_FLASH,
            CLASSB_TEST_INPROGRESS);
    }
    else
    {
        _CLASSB_UpdateTestResult(CLASSB_TEST_TYPE_SST, CLASSB_TEST_FLASH,
            CLASSB_TEST_INPROGRESS);
    }
    
    
}
