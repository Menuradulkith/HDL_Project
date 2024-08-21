`include "home.v"
`timescale 1ns / 1ps

module tb_SmartLightingSystem();

    // Inputs to the DUT
    reg clk;
    reg reset;
    reg motion;
    reg light_level;
    reg manual_on;
    reg manual_off;

    // Output from the DUT
    wire light;

    // Instantiate the Design Under Test (DUT)
    SmartLightingSystem uut (
        .clk(clk),
        .reset(reset),
        .motion(motion),
        .light_level(light_level),
        .manual_on(manual_on),
        .manual_off(manual_off),
        .light(light)
    );

    // Clock generation: 10ns period clock
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        reset = 0;
        motion = 0;
        light_level = 0;
        manual_on = 0;
        manual_off = 0;

        // Apply reset
        reset = 1;
        #10 reset = 0;

        // Start VCD dump
        $dumpfile("SmartLightingSystem.vcd"); // Specify the VCD file name
        $dumpvars(0, tb_SmartLightingSystem); // Dump all variables in this module

        // Scenario 1: Motion detected at night (light should turn on)
        #20 light_level = 1; // Nighttime
        motion = 1;          // Motion detected
        #30 motion = 0;      // Motion stops

        // Scenario 2: Manual switch on (light should turn on)
        #40 manual_on = 1;   // Manual switch on
        #50 manual_on = 0;   // Manual switch off

        // Scenario 3: Motion detected during the day (light should not turn on)
        #60 light_level = 0; // Daytime
        motion = 1;          // Motion detected
        #30 motion = 0;      // Motion stops

        // Scenario 4: Manual switch off (light should turn off)
        #70 manual_off = 1;  // Manual switch off
        #80 manual_off = 0;

        // Scenario 5: Motion detected at night and then goes into power-saving mode
        #90 light_level = 1; // Nighttime
        motion = 1;          // Motion detected
        #40 motion = 0;      // Motion stops (system should go into DIM state)

        // End simulation
        #100 $finish;
    end
endmodule
