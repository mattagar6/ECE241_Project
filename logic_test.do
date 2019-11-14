vlib work
vlog game_logic.v
vsim hit_detector

log {/*}
add wave {/*}

force {clk} 0
force {reset_b} 1
force {go} 0 
force {stream} 000
run 5ns

force {reset_b} 0
force {clk} 1
run 5ns

force {reset_b} 1
force {clk} 0
run 5ns

force {go} 1
force {clk} 1
run 5ns

force {clk} 0
run 5ns

force {clk} 1
run 5ns

force {go} 0
force {clk} 0
run 5ns

force {clk} 1
run 5ns

force {clk} 0
run 5ns

force {clk} 1
force {stream} 001 
force {go} 1
run 5ns

force {clk} 0
run 5ns

force {clk} 1
run 5ns

force {clk} 0
force {go} 0
run 5ns

force {clk} 1
run 5ns

force {clk} 0
run 5ns

force {clk} 1
run 5ns