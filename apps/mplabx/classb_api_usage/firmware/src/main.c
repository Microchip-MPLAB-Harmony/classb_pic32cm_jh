/*******************************************************************************
  Main Source File

  Company:
    Microchip Technology Inc.

  File Name:
    main.c

  Summary:
    This file contains the "main" function for a project.

  Description:
    This file contains the "main" function for a project.  The
    "main" function calls the "SYS_Initialize" function to initialize the state
    machines of all modules in the system
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

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stddef.h>                     // Defines NULL
#include <stdbool.h>                    // Defines true
#include <stdlib.h>                     // Defines EXIT_FAILURE
#include "definitions.h"                // SYS function prototypes

#define RX_BUFFER_SIZE          256U
#define CPU_CLOCK_FREQ          48000000U
#define CPU_CLOCK_ERROR         5U
#define CPU_CLOCK_TEST_CYCLES   164U

// 0 - No Fault Injection, 1- Single, 2- Double
#define SRAM_FAULT_INJ_TYPE     0U
#define SRAM_FAULT_INJ_ADDR     0x20004000U

// Flash Address where data with error(s) will be stored
#define FLASH_FAULT_INJ_TYPE    0U
#define FLASH_WRITE_ADDR        0x9000U

static uint32_t sram_data = 0;
static uint32_t sram_data_read = 0;

static uint32_t data_flash [NVMCTRL_PAGE_SIZE] = {0};
static uint32_t data_read [NVMCTRL_PAGE_SIZE] = {0};

char test_status_str[4][25] = {"CLASSB_TEST_NOT_EXECUTED",
    "CLASSB_TEST_PASSED",
    "CLASSB_TEST_FAILED",
    "CLASSB_TEST_INPROGRESS"
};
char console_message[] = "\r\n Type a line of characters and press the Enter key. \r\n\
 \r\n Entered line will be echoed back, and the LED0 is toggled on the reception of each character. \r\n";
char newline[] = "\r\n ";
char error_message[] = "\r\n!!!!! USART error has occurred !!!!!r\n";
char receive_buffer[RX_BUFFER_SIZE] = {};
char data = 0;

void RAM_CallbackRoutine (RAM_ECC_STATUS status, uintptr_t context)
{
    if (status & RAM_ECC_STATUS_SERR)
    {
        printf("\r\n Result of SRAM RST ECC test is %s\r\n", test_status_str[CLASSB_TEST_FAILED]);
    }
}

void FLASH_ECC_CallbackRoutine(uint32_t status, uintptr_t context)
{
    if (status & NVMCTRL_INTFLAG_SERR_Msk)
    {
        printf("\r\n Result of Flash RST ECC test is %s\r\n", test_status_str[CLASSB_TEST_FAILED]);
    }
}

/*============================================================================
void runtimeClassBChecks(void)
------------------------------------------------------------------------------
Purpose: Execute periodic run-time self-tests
Input  : None.
Output : None.
Notes  : Insert the required self-tests into this function.
============================================================================*/
//bool runtimeClassBChecks(void)
//{
//    bool ret_val = false;
//    CLASSB_TEST_STATUS classb_rst1_status = CLASSB_TEST_NOT_EXECUTED;
//    CLASSB_TEST_STATUS classb_rst2_status = CLASSB_TEST_NOT_EXECUTED;
//    
//    classb_rst1_status = CLASSB_CPU_RegistersTest(true);
//    classb_rst2_status = CLASSB_CLOCK_Test(0);
//    
//    if ((classb_rst1_status == CLASSB_TEST_PASSED) &&
//            (classb_rst2_status == CLASSB_TEST_PASSED))
//    {
//        ret_val = true;
//    }
//    
//    return ret_val;
//}

void sram_fault_injection_routine ( uint32_t sram_address )
{
    sram_data = 0xA5A5A5A5;
    if (sram_address < 0x20000000)
        sram_address = 0x20000000 + sram_address;
    // Write RAM memory with data at address
    *((uint32_t*)sram_address) = sram_data;
    // Disable ECC for MCRAMC
    RAM_ECC_Disable();
    // Read physical value contained in SRAM memory at defined address. This should read corrupted value as ECC decoding is disabled.
    sram_data_read = *((uint32_t*)sram_address);
    // Enabling ECC for MCRAMC
    RAM_ECC_Enable();
    // Disabling fault injection
    RAM_ECC_FaultDisable();
    // Read physical value contained in SRAM memory at defined address. The should read corrected value as ECC decoding is enabled.
    sram_data_read = *((uint32_t*)sram_address);
}

void flash_fault_injection_routine(uint32_t address) {
    data_flash[0] = 0xA5A5A5A5;
    // Page Buffer is filled with data values. Only the first two Page Buffer words are non-zero values
    NVMCTRL_PageBufferWrite(data_flash, address);
    // Write filled Page Buffer at address (Flash or Data Flash address)
    NVMCTRL_PageBufferCommit(address);
    // Wait for INTFLAG.READY bit meaning NVMCTRL is ready to accept a new command
    while (NVMCTRL_IsBusy() == true) {

    }

    // Read physical value contained in Flash memory at defined address. This value is corrected on the fly as ECC feature is enabled.
    *((uint64_t*) & data_read[0]) = *(uint64_t*) address;
    NVMCTRL_ECC_MainArrayDisable();
}
// *****************************************************************************
// *****************************************************************************
// Section: Main Entry Point
// *****************************************************************************
// *****************************************************************************

int main(void) {           
    uint16_t rx_counter = 0U;

    /* Initialize all modules */
    SYS_Initialize(NULL);
    
    printf("\r\n\r\n        Class B API Usage Demo      \r\n");
    CLASSB_TEST_STATUS classb_test_status = CLASSB_TEST_NOT_EXECUTED;
    classb_test_status = CLASSB_GetTestResult(CLASSB_TEST_TYPE_SST, CLASSB_TEST_CPU);
    printf("\r\n Result of CPU SST is %s\r\n", test_status_str[classb_test_status]);
    classb_test_status = CLASSB_GetTestResult(CLASSB_TEST_TYPE_SST, CLASSB_TEST_PC);
    printf("\r\n Result of PC SST is %s\r\n", test_status_str[classb_test_status]);
    classb_test_status = CLASSB_GetTestResult(CLASSB_TEST_TYPE_SST, CLASSB_TEST_RAM);
    printf("\r\n Result of SRAM SST ECC Enable is %s\r\n", test_status_str[classb_test_status]);
    classb_test_status = CLASSB_GetTestResult(CLASSB_TEST_TYPE_SST, CLASSB_TEST_FLASH);
    printf("\r\n Result of Flash SST ECC Enable is %s\r\n", test_status_str[classb_test_status]);
    classb_test_status = CLASSB_GetTestResult(CLASSB_TEST_TYPE_SST, CLASSB_TEST_CLOCK);
    printf("\r\n Result of Clock SST is %s\r\n", test_status_str[classb_test_status]);
    classb_test_status = CLASSB_GetTestResult(CLASSB_TEST_TYPE_SST, CLASSB_TEST_INTERRUPT);
    printf("\r\n Result of Interrupt SST is %s\r\n", test_status_str[classb_test_status]);

    WDT_Clear();

    printf("\r\n\r\n Class B run-time self-tests \r\n");
    classb_test_status = CLASSB_TEST_FAILED;
    classb_test_status = CLASSB_CPU_RegistersTest(true);
    printf("\r\n Result of CPU RST is %s\r\n", test_status_str[classb_test_status]);
    classb_test_status = CLASSB_TEST_FAILED;
    classb_test_status = CLASSB_CPU_PCTest(true);
    printf("\r\n Result of PC RST is %s\r\n", test_status_str[classb_test_status]);

    // Enable SERR and DERR interrupts for RAM
    CLASSB_SRAM_EccInit (RAM_CallbackRoutine, 1);
    classb_test_status = CLASSB_TEST_INPROGRESS;
    printf("\r\n Result of SRAM RST ECC Enable is %s\r\n", test_status_str[classb_test_status]);
    
    uint32_t sram_fault_type = SRAM_FAULT_INJ_TYPE;
    if (sram_fault_type > 0U)
    {
        if (sram_fault_type == 1U)
        {
            // Activate Single bit fault injection
            RAM_ECC_SingleBitFaultInject(SRAM_FAULT_INJ_ADDR, 0);
        }
        else if (sram_fault_type == 2U)
        {
            // Activate Double bit fault injection
            RAM_ECC_DoubleBitFaultInject(SRAM_FAULT_INJ_ADDR, 0, 1);
        }
        // Launch Fault Injection routine for SRAM memory
        sram_fault_injection_routine (SRAM_FAULT_INJ_ADDR);
    }

    // Enable SERR and DERR interrupts for RAM
    CLASSB_FLASH_EccInit(FLASH_ECC_CallbackRoutine, 0);
    classb_test_status = CLASSB_TEST_INPROGRESS;
    printf("\r\n Result of Flash RST ECC Enable is %s\r\n", test_status_str[classb_test_status]);
    
    uint32_t flash_fault_type = FLASH_FAULT_INJ_TYPE;
    if (flash_fault_type > 0U)
    {
        NVMCTRL_RowErase(FLASH_WRITE_ADDR);
        if (flash_fault_type == 1U) 
        {
            NVMCTRL_ECC_SingleBitFaultInject(FLASH_WRITE_ADDR, 0x3, NVMCTRL_ECC_FLT_MODE_ON_WRITE);
        }
        else if (flash_fault_type == 2U) 
        {
            NVMCTRL_ECC_DoubleBitFaultInject(FLASH_WRITE_ADDR, 0x3, 0x4, NVMCTRL_ECC_FLT_MODE_ON_WRITE);
        }
        // Launch Fault Injection routine for Flash memory on writes
        flash_fault_injection_routine(FLASH_WRITE_ADDR);
    }
    
    WDT_Clear();
    __disable_irq();
    classb_test_status = CLASSB_ClockTest(CPU_CLOCK_FREQ, CPU_CLOCK_ERROR, CPU_CLOCK_TEST_CYCLES, true);
    __enable_irq();
    printf("\r\n Result of CPU Clock RST is %s\r\n", test_status_str[classb_test_status]);

    //Drive HIGH on the pin to be tested.
    LED_Set();

    CLASSB_IO_InputSamplingEnable(PORTC, PIN5);
    classb_test_status = CLASSB_RST_IOTest(PORTC, PIN5, PORT_PIN_HIGH);
    printf("\r\n Result of PC05 HIGH is %s\r\n", test_status_str[classb_test_status]);

    // Check HIGH on SW0 (PB19)
    classb_test_status = CLASSB_RST_IOTest(PORTB, PIN19, PORT_PIN_HIGH);
    printf("\r\n Result of PB19 HIGH is %s\r\n", test_status_str[classb_test_status]);

    printf("%s", console_message);
    while (true) {
        /* Maintain state machines of all polled MPLAB Harmony modules. */
        SYS_Tasks();
        WDT_Clear();
        /* Check if there is a received character */
        if (SERCOM4_USART_ReceiverIsReady() == true) {
            if (SERCOM4_USART_ErrorGet() == USART_ERROR_NONE) {
                SERCOM4_USART_Read(&data, 1);
                LED_Toggle();
                if ((data == '\n') || (data == '\r')) {
                    printf("\r\n Received : ");
                    SERCOM4_USART_Write(&receive_buffer[0], rx_counter);
                    printf("\r\n");
                    rx_counter = 0;
                    printf("\r\n Executing periodic run-time tests : ");
                    //                    rst_status = runtimeClassBChecks();
                    //                    if (rst_status == true)
                    //                    {
                    //                        printf(" All periodic tests passed \r\n");
                    //                    }
                    //                    else
                    //                    {
                    //                        printf(" Periodic test failure \r\n");
                    //                    }
                } else {
                    receive_buffer[rx_counter++] = data;
                }
            } else {
                SERCOM4_USART_Write(&error_message[0], sizeof (error_message));
            }
        }
    }

    /* Execution should not come here during normal operation */

    return ( EXIT_FAILURE);
}


/*******************************************************************************
 End of File
 */

