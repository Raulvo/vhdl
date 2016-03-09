.data
lol: .string "Lalalala"
wut: .int 1235
.text
movi:   movi r1, wut    ! move wut address into register. 
        movi r1, #1     ! decimal integer
        movi r1, 0x-5   ! negative hexa
        movi r1, #-1    ! negative int
        movi r1, movi   ! address of movi label. Not allowed.
