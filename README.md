# LC3 Decompiler
Sample usage:

```c
Enter LC-3 binary, then press enter.
0010010000000101
LD R2, #5
0001001010000111
ADD R1, R2, R7
0100000101000000
JSRR R5,
0001000001111101
ADD R0, R1, #29
0100111111111110
JSR #2046
1011000000000100
STI R0, #4
0110011100000010
LDR R3, R4, #2
```
## How to use

1. Make sure to have `dart` installed.

2. Copy paste the following into your terminal.

```shell
cd /tmp && git clone https://github.com/JiachenRen/lc3_decompiler.git && cd lc3_decompiler && dart bin/main.dart
```
