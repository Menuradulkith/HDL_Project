module SmartLightingSystem (
    input wire clk,         // System clock
    input wire reset,       // System reset
    input wire motion,      // Motion detected (1: detected, 0: not detected)
    input wire light_level, // Light sensor (1: night, 0: day)
    input wire manual_on,   // Manual switch to turn lights on
    input wire manual_off,  // Manual switch to turn lights off
    output reg light        // Light control (1: on, 0: off)
);

    // Internal states
    reg [2:0] state;
    reg [2:0] next_state;

    // Define states
    localparam IDLE       = 3'b000;
    localparam MOTION_ON  = 3'b001;
    localparam NIGHT_ON   = 3'b010;
    localparam MANUAL_ON  = 3'b011;
    localparam DIM        = 3'b100;
    
    // State transition based on inputs
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (motion && light_level) begin
                    next_state = MOTION_ON;
                end else if (manual_on) begin
                    next_state = MANUAL_ON;
                end else begin
                    next_state = IDLE;
                end
            end

            MOTION_ON: begin
                if (!motion) begin
                    next_state = DIM;
                end else if (manual_off) begin
                    next_state = IDLE;
                end else begin
                    next_state = MOTION_ON;
                end
            end

            NIGHT_ON: begin
                if (!light_level) begin
                    next_state = IDLE;
                end else begin
                    next_state = NIGHT_ON;
                end
            end

            MANUAL_ON: begin
                if (manual_off) begin
                    next_state = IDLE;
                end else begin
                    next_state = MANUAL_ON;
                end
            end
            
            DIM: begin
                if (!motion) begin
                    next_state = IDLE;
                end else begin
                    next_state = MOTION_ON;
                end
            end

            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            light <= 1'b0;
        end else begin
            case (next_state)
                IDLE: light <= 1'b0;
                MOTION_ON: light <= 1'b1;
                NIGHT_ON: light <= 1'b1;
                MANUAL_ON: light <= 1'b1;
                DIM: light <= 1'b0; // Dimming lights can be represented by another output in real hardware
                default: light <= 1'b0;
            endcase
        end
    end

endmodule