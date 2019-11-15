/******************************************************************************
* SPDX-License-Identifier: GPL-3.0-or-later
******************************************************************************/

#include "kconfig.h"

#include "stm32f103xb.h"
#include "stm32f1xx_hal.h"

#include "FreeRTOS.h"
#include "task.h"

void BlinkLedTask(void *parameters)
{
  for(;;)
  {
    HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_12);

    vTaskDelay(pdMS_TO_TICKS(CONFIG_APP_BLINK_LED_DELAY));
  }
  vTaskDelete(NULL);
}

void app_main()
{
  BaseType_t status = xTaskCreate(BlinkLedTask, "BlinkLed", 256, NULL, 4, NULL);
  if(status != pdPASS)
  {
    for(;;);
  }

  vTaskStartScheduler();
}

/*****************************************************************************/