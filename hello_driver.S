/*
 * hello_driver.S - Simple ARM character device driver for FreeBSD
 *
 * Implements a basic /dev/hello device that returns "Hello, World!\n"
 * when read. Written in ARM assembly using the FreeBSD kernel module ABI.
 *
 * Build:
 *   as -o hello_driver.o hello_driver.S
 *   ld -shared -o hello_driver.ko hello_driver.o
 *   -- OR use the provided Makefile --
 *
 * Load:
 *   kldload ./hello_driver.ko
 *   cat /dev/hello
 *   kldunload hello_driver
 */

#include <machine/asm.h>          /* ARM asm macros (ENTRY, END, etc.)   */
#include <sys/syscall.h>          /* Syscall numbers (not needed in KLD)  */

/* -----------------------------------------------------------------------
 * Read-only data section
 * --------------------------------------------------------------------- */
    .section .rodata
    .align  2

hello_msg:
    .ascii  "Hello, World!\n"
hello_msg_end:
    .set    HELLO_MSG_LEN, (hello_msg_end - hello_msg)

driver_name:
    .asciz  "hello"               /* device name: /dev/hello              */

module_name:
    .asciz  "hello_driver"        /* kld module name                      */

/* -----------------------------------------------------------------------
 * Data section - mutable state
 * --------------------------------------------------------------------- */
    .section .data
    .align  2

/* Pointer to the cdev struct returned by make_dev() */
hello_cdev:
    .word   0

/* -----------------------------------------------------------------------
 * BSS section
 * --------------------------------------------------------------------- */
    .section .bss
    .align  2

/* -----------------------------------------------------------------------
 * Text section
 * --------------------------------------------------------------------- */
    .text
    .align  2

/* =======================================================================
 * hello_open(struct cdev *dev, int oflags, int devtype, struct thread *td)
 *
 * Called when a process opens /dev/hello. We simply return 0 (success).
 * ARM AAPCS: args in r0-r3, return value in r0.
 * ===================================================================== */
ENTRY(hello_open)
    mov     r0, #0              /* return 0 = success                    */
    bx      lr
END(hello_open)

/* =======================================================================
 * hello_close(struct cdev *dev, int fflag, int devtype, struct thread *td)
 *
 * Called when the device file descriptor is closed. Return 0.
 * ===================================================================== */
ENTRY(hello_close)
    mov     r0, #0
    bx      lr
END(hello_close)

/* =======================================================================
 * hello_read(struct cdev *dev, struct uio *uio, int ioflag)
 *
 * Copies HELLO_MSG_LEN bytes from hello_msg into userspace via uiomove().
 *
 * Prototype (kernel):
 *   int hello_read(struct cdev *dev, struct uio *uio, int ioflag);
 *
 * r0 = dev  (unused)
 * r1 = uio  (struct uio *)
 * r2 = ioflag (unused)
 *
 * We call:
 *   uiomove(hello_msg, HELLO_MSG_LEN, uio)
 *   -> r0 = (char *)hello_msg
 *   -> r1 = HELLO_MSG_LEN
 *   -> r2 = uio
 * ===================================================================== */
ENTRY(hello_read)
    /* Save lr (return address) and r4 (callee-saved scratch) */
    push    {r4, lr}

    mov     r4, r1              /* save uio pointer                      */

    /* Set up args for uiomove(buf, len, uio) */
    ldr     r0, =hello_msg      /* r0 = pointer to message               */
    mov     r1, #HELLO_MSG_LEN  /* r1 = length                           */
    mov     r2, r4              /* r2 = uio                              */

    /* Call kernel uiomove() */
    bl      uiomove

    /* r0 now holds return value from uiomove (0 on success, errno on err) */
    pop     {r4, pc}            /* restore r4, return                    */
END(hello_read)

/* =======================================================================
 * hello_write(struct cdev *dev, struct uio *uio, int ioflag)
 *
 * Writing to this device is not supported; return ENODEV (19).
 * ===================================================================== */
ENTRY(hello_write)
    mov     r0, #19             /* ENODEV                                */
    bx      lr
END(hello_write)

/* =======================================================================
 * Cdevsw (character device switch table)
 *
 * struct cdevsw {
 *   int         d_version;    // offset 0  - must be D_VERSION (0x20130306)
 *   u_int       d_flags;      // offset 4
 *   const char *d_name;       // offset 8
 *   d_open_t   *d_open;       // offset 12
 *   d_close_t  *d_close;      // offset 16
 *   d_read_t   *d_read;       // offset 20
 *   d_write_t  *d_write;      // offset 24
 *   ... (remaining fields NULL) ...
 * };
 *
 * D_VERSION = 0x20130306
 * ===================================================================== */
    .section .data
    .align  2
    .global hello_cdevsw

hello_cdevsw:
    .word   0x20130306          /* d_version = D_VERSION                 */
    .word   0                   /* d_flags   = 0                         */
    .word   driver_name         /* d_name                                */
    .word   hello_open          /* d_open                                */
    .word   hello_close         /* d_close                               */
    .word   hello_read          /* d_read                                */
    .word   hello_write         /* d_write                               */
    .word   0                   /* d_ioctl  = NULL                       */
    .word   0                   /* d_poll   = NULL                       */
    .word   0                   /* d_mmap   = NULL                       */
    .word   0                   /* d_strategy = NULL                     */
    .word   0                   /* d_dump   = NULL                       */
    .word   0                   /* d_psize  = NULL                       */
    .word   0                   /* d_spare0 = 0                          */
    .word   0                   /* d_kqfilter = NULL                     */
    .word   0                   /* d_spare1 = 0                          */

/* =======================================================================
 * hello_modevent(module_t mod, int cmd, void *arg)
 *
 * Module event handler, called on load (MOD_LOAD=1) and unload
 * (MOD_UNLOAD=2).
 *
 * r0 = mod  (module_t, unused)
 * r1 = cmd  (int)
 * r2 = arg  (void *, unused)
 * ===================================================================== */
    .text
    .align  2

ENTRY(hello_modevent)
    push    {r4, r5, lr}

    mov     r4, r1              /* save cmd                              */

    cmp     r4, #1              /* MOD_LOAD == 1 ?                       */
    beq     .Lmod_load

    cmp     r4, #2              /* MOD_UNLOAD == 2 ?                     */
    beq     .Lmod_unload

    /* Unknown event - return EOPNOTSUPP (45) */
    mov     r0, #45
    b       .Lmodevent_done

/* --- MOD_LOAD --------------------------------------------------------- */
.Lmod_load:
    /*
     * make_dev(&hello_cdevsw, 0, UID_ROOT, GID_WHEEL, 0444, "hello")
     * Returns struct cdev * in r0.
     *
     * ARM AAPCS calling convention:
     *   r0 = &hello_cdevsw
     *   r1 = unit (0)
     *   r2 = uid  (0 = UID_ROOT)
     *   r3 = gid  (0 = GID_WHEEL)
     *   [sp]   = mode (0444 = 0x124)
     *   [sp+4] = fmt  = "hello"
     */
    ldr     r0, =hello_cdevsw   /* &hello_cdevsw                        */
    mov     r1, #0              /* unit = 0                              */
    mov     r2, #0              /* UID_ROOT                              */
    mov     r3, #0              /* GID_WHEEL                             */
    /* Push extra args onto stack (right-to-left beyond 4th) */
    ldr     r5, =driver_name
    push    {r5}                /* fmt = "hello"                        */
    mov     r5, #0x124          /* 0444 octal = 0x124                   */
    push    {r5}                /* mode = 0444                          */
    bl      make_dev
    add     sp, sp, #8          /* clean stack args                     */

    /* Store returned cdev pointer */
    ldr     r5, =hello_cdev
    str     r0, [r5]

    /* Print load message via uprintf / printf */
    /* (In a real driver use device_printf; here we use printf for simplicity) */
    ldr     r0, =load_msg
    bl      printf

    mov     r0, #0              /* return 0 = success                   */
    b       .Lmodevent_done

/* --- MOD_UNLOAD ------------------------------------------------------- */
.Lmod_unload:
    /* destroy_dev(hello_cdev) */
    ldr     r0, =hello_cdev
    ldr     r0, [r0]            /* dereference to get cdev *            */
    bl      destroy_dev

    ldr     r0, =unload_msg
    bl      printf

    mov     r0, #0

.Lmodevent_done:
    pop     {r4, r5, pc}
END(hello_modevent)

/* =======================================================================
 * Module metadata
 *
 * FreeBSD uses a linker set (set_modmetadata_set) to register modules.
 * The moduledata_t struct and DECLARE_MODULE macro expand to the
 * following layout (simplified):
 *
 * struct moduledata {
 *   const char   *name;   // module name string
 *   modeventhand_t evhand; // event handler
 *   void         *priv;   // private data (NULL here)
 * };
 * ===================================================================== */
    .section .data
    .align  2

    .global hello_mod
hello_mod:
    .word   module_name         /* name    = "hello_driver"              */
    .word   hello_modevent      /* evhand  = hello_modevent              */
    .word   0                   /* priv    = NULL                        */

/*
 * Place hello_mod into the linker set "modmetadata_set" so the kernel
 * module loader discovers it automatically.
 */
    .section set_modmetadata_set, "aw", %progbits
    .align  2
    .word   hello_mod

/* =======================================================================
 * String literals (kept in .rodata for safety)
 * ===================================================================== */
    .section .rodata
    .align  2

load_msg:
    .asciz  "hello_driver: loaded, /dev/hello is available\n"

unload_msg:
    .asciz  "hello_driver: unloaded\n"
