set FLAG=-v -PALL_LIB --syn-binding --ieee=synopsys --std=93c -fexplicit
ghdl -a --work=work --workdir=ALL_LIB %FLAG% ..\VHDL\fifo_inter.vhd
ghdl -a --work=work --workdir=ALL_LIB %FLAG% ..\TEST\fifo_control.vhd
ghdl -a --work=RAM_LIB --workdir=ALL_LIB %FLAG% ..\RAM\dp8x32.vhd


