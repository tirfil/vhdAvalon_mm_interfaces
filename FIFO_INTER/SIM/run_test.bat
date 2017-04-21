set FLAG=-v -PALL_LIB --syn-binding --ieee=synopsys --std=93c -fexplicit
ghdl -e --work=work --workdir=ALL_LIB %FLAG% tb_fifo_inter
rem ghdl -r %FLAG% tb_fifo_inter --vcd=wave.vcd
ghdl -r --work=work --workdir=ALL_LIB %FLAG% tb_fifo_inter --wave=wave.ghw

