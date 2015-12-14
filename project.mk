#DEBUGFLAGS      = -Os
#USER_LDFLAGS    = --specs=nano.specs
USER_CFLAGS     = 
USE_FULL_ASSERT =
FEATURES        += FLASH
SRCS = \
	src/edison-motor-controller-bootloader.c 
SSRCS =
FLASH = 12288