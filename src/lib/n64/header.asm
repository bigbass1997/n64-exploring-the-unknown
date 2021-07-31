//Code written by PeterLemon https://github.com/PeterLemon/N64
//
// N64 Header

//dw $AA3FDDDD
//db $00
//db $3F
//db $FF
//db $FF

db $80
db $37
db $12
db $40

// Clock Rate
dw $0000000F

dw Start
dw $1444
db "CRC1"
db "CRC2"

dd 0

db   "Exploring The Unknown      "
//   "123456789012345678901234567"

db $00 // Dev Id
db $00 // Cart Id
db $00 
db $00
db $00