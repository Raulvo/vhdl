.data
lol: .string "Lalalala"
wut: .int 1235
.text
movi:   movi    r2, wut    ! move wut into register. String labes are not allowed.
        movi    r2, #1     ! decimal integer
        movi    r2, 0x-5   ! negative hexa
        movi    r2, #-1    ! negative int
        movhi   r2, wut
        movhi   r2, #-1
        movhi   r2, 0x-5
        movi    r2, movi   ! address of movi label. Not allowed.
