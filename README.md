# hello_driver — ARM Assembly Character Device Driver for FreeBSD

A minimal FreeBSD kernel loadable module (KLD) written in ARM assembly. It
exposes a `/dev/hello` character device that returns `"Hello, World!\n"` when
read.

---

## Files

| File | Description |
|------|-------------|
| `hello_driver.S` | ARM assembly source for the kernel module |
| `Makefile` | FreeBSD kernel module build file |
| `README.md` | This file |

---

## Requirements

- FreeBSD running on an ARM or ARM64 machine (e.g. Raspberry Pi, BeagleBone, or a QEMU ARM VM)
- FreeBSD kernel source tree installed at `/usr/src`
- `binutils` and `make` available (standard on FreeBSD)

---

## Building

```sh
make
```

This produces `hello_driver.ko` using FreeBSD's standard `bsd.kmod.mk`
build infrastructure.

---

## Loading & Testing

```sh
# Load the module
sudo kldload ./hello_driver.ko

# Read from the device
cat /dev/hello
# Output: Hello, World!

# Check the module is loaded
kldstat | grep hello

# Unload the module
sudo kldunload hello_driver
```

---

## How It Works

The driver implements the four core components of a FreeBSD character device,
all in ARM assembly:

### 1. `hello_cdevsw` — Device Switch Table
A `cdevsw` struct populated with function pointers for `open`, `close`,
`read`, and `write`. The `d_version` field must be set to `0x20130306` to
match the current FreeBSD KLD ABI.

### 2. `hello_open` / `hello_close`
Simple stubs that return `0` (success). The return value is placed in `r0`
per the ARM AAPCS calling convention.

### 3. `hello_read`
Saves the `uio` pointer from `r1`, then calls the kernel's `uiomove()` to
safely copy `hello_msg` into userspace. The return value from `uiomove` is
passed straight back to the caller.

### 4. `hello_write`
Returns `ENODEV (19)` — writing to this device is not supported.

### 5. `hello_modevent` — Module Event Handler
Handles `MOD_LOAD` and `MOD_UNLOAD` events:
- **Load**: calls `make_dev()` to create `/dev/hello`, stores the returned
  `cdev *`, and logs a message to the kernel console.
- **Unload**: calls `destroy_dev()` to remove `/dev/hello` and logs a message.

### 6. Module Metadata
A `moduledata_t` struct (`hello_mod`) is placed into the
`set_modmetadata_set` linker set so `kldload` can discover the module
automatically — no C glue code required.

---

## ARM Calling Convention (AAPCS) Notes

- Function arguments are passed in `r0`–`r3`; additional args go on the stack.
- Return values are in `r0`.
- Callee-saved registers: `r4`–`r11`, `lr`. These are pushed/popped in
  functions that make further calls.
- `bx lr` is used for simple leaf-function returns; `pop {r4, pc}` is used
  when `lr` has been saved on the stack.

---

## License

This project is released into the public domain. Use freely.
