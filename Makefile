# Makefile for hello_driver - ARM FreeBSD kernel module
#
# Usage (on a FreeBSD/ARM system with kernel sources in /usr/src):
#   make
#   kldload ./hello_driver.ko
#   cat /dev/hello
#   kldunload hello_driver
#   make clean

# Module name (no .ko suffix here)
KMOD    = hello_driver

# Source files
SRCS    = hello_driver.S

# Extra CFLAGS / AFLAGS
AFLAGS += -D_KERNEL

# FreeBSD standard kernel module build infrastructure
.include <bsd.kmod.mk>
