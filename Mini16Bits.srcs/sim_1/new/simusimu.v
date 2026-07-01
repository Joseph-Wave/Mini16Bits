`timescale 1ns / 1ps

/*
add_force {/simusimu/MAIN_clk} -radix bin {0 0ns} {1 41667ps} -repeat_every 83333ps
save_wave_config {D:/Xilinx/Projects/Mini16Bits/simusimu_behav.wcfg}


open_wave_config {D:/Xilinx/Projects/Mini16Bits/simusimu_behav.wcfg}
add_force {/simusimu/MAIN_clk} -radix bin {0 0ns} {1 500ns} -repeat_every 1000ns
run 500 us
*/

module simusimu (
    input wire MAIN_clk
);

    main DEMO (
        .clk(MAIN_clk)
    );

endmodule
