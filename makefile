# Toolchain path (Windows)
TOOLCHAIN_PATH := C:/repo/stm32f407vg-bsp-template/gcc-toolchain-14.3/bin

# Tools
CC      := $(TOOLCHAIN_PATH)/arm-none-eabi-gcc.exe
LD      := $(TOOLCHAIN_PATH)/arm-none-eabi-gcc.exe
OBJCOPY := $(TOOLCHAIN_PATH)/arm-none-eabi-objcopy.exe
SIZE    := $(TOOLCHAIN_PATH)/arm-none-eabi-size.exe

# Project name
TARGET = main

# Directories
SRC_DIR := source
BUILD_DIR := build

DRIVERS_DIR := Drivers/STM32F4xx_HAL_Driver/Src
USB_DIRS := Middlewares/ST/STM32_USB_Host_Library/Core/Src \
            Middlewares/ST/STM32_USB_Host_Library/Class/CDC/Src
USBH_TARGET_DIR := USB_HOST/Target

# Source files
SRC := $(wildcard $(SRC_DIR)/*.c)
DRIVERS_SRC := $(wildcard $(DRIVERS_DIR)/*.c)
USB_SRC := $(foreach dir, $(USB_DIRS), $(wildcard $(dir)/*.c))
USBH_TARGET_SRC := $(wildcard $(USBH_TARGET_DIR)/*.c)

ALL_SRC := $(SRC) $(DRIVERS_SRC) $(USB_SRC) $(USBH_TARGET_SRC)

# Object files
OBJ := $(patsubst %.c,$(BUILD_DIR)/%.o,$(ALL_SRC))

# Include directories
INCLUDES := -IDrivers/STM32F4xx_HAL_Driver/Inc \
            -IDrivers/CMSIS/Device/ST/STM32F4xx/Include \
            -IDrivers/CMSIS/Include \
            -IMiddlewares/ST/STM32_USB_Host_Library/Core/Inc \
            -IMiddlewares/ST/STM32_USB_Host_Library/Class/CDC/Inc \
            -IUSB_HOST/App \
            -IUSB_HOST/Target \
            -Isource

# Compiler flags
CFLAGS := -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard \
          -O2 -g -Wall -fdata-sections -ffunction-sections -std=gnu11 \
          $(INCLUDES)

# Linker flags and script
LDFLAGS := -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard \
           -Wl,--gc-sections -Tstm32f407vg_flash.ld

# Default target
all: $(TARGET).elf size

# Ensure build directories exist
$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Link ELF
$(TARGET).elf: $(OBJ)
	$(LD) $(OBJ) $(LDFLAGS) -o $@

# Binary output (optional)
bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $(TARGET).bin

# Show size
size: $(TARGET).elf
	$(SIZE) $<

# Clean all
clean:
	rm -rf $(BUILD_DIR) $(TARGET).elf $(TARGET).bin

.PHONY: all clean size bin
