VLOG = ncverilog
Test = Test_Bench.v
CPU = Simulator.v

all:
	$(VLOG) $(CPU) $(Test)