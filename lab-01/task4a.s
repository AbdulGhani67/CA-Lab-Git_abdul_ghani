.text
.globl main

main:
    # Initialize x10 and x11 manually
    li x10, 0x78786464
    li x11, 0xA8A81919

    #Store x10 as unsigned integer at address 0x100
    li x5, 0x100
    sw x10, 0(x5)

    #Store x11 as unsigned integer at address 0x1F0
    li x6, 0x1F0
    sw x11, 0(x6)

    #Load an unsigned short integer (two bytes) from address 0x100 in x12
    lhu x12, 0(x5)

    #Load a short integer from address 0x1F0 in register x13
    lh x13, 0(x6)

    #Load a signed character from address 0x1F0 in register x14
    lb x14, 0(x6)

end:
    j end               # Infinite loop to halt program