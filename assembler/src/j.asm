.data
lol: .string "Lalalala"
wut: .int 1235
.text
jump:   jmp 0x256   ! constant integer instruction offset
        jmp 0x-1    ! negative constant
        jmp jump    ! testing label
        jmp lol     ! throws invalid label exception
