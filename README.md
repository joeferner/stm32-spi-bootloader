
## Process

1. Assert CS (Low)
2. Reset chip
3. Transmit header
4. Wait for IRQ to be asserted (Low)
5. Write unsigned 32-bit address of page to be programmed
6. Wait for IRQ to be deasserted (High) - Bootloader is writing to EEPROM
7. Write page of data
8. If more data to send goto to step 4
9. Wait for IRQ to be asserted (Low) - Bootloader is verifing CRC32
10. Deassert CS (High)
11. Reset chip
