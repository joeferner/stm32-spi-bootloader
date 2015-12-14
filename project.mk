#DEBUGFLAGS      = -Os
#USER_LDFLAGS    = --specs=nano.specs
USER_CFLAGS     = 
USE_FULL_ASSERT =
FEATURES        += FLASH FLASHEX
SRCS = \
	src/spi-bootloader.c 
SSRCS =
FLASH = 12288