module trueport_ram(
    input clk_a, clk_b, wren_a, rden_a, wren_b, rden_b,
    input rst,  // Active-high synchronous reset
    input [9:0] address_a, address_b,
    input [7:0] data_a, data_b,
    output reg [7:0] q_a, q_b );
    
    // Declare 512x8-bit RAM
    reg [7:0] ram [511:0];
    
    // Initialize RAM with memory file
    initial $readmemh("memory_init.mem", ram);
    
    // Address decoding logic
    wire valid_addr_A = (address_a < 10'd512);
    wire valid_addr_B = (address_b < 10'd512);
    
    // Port A logic
    always @(posedge clk_a) begin
        if (rst) 
            q_a <= 8'h00;
        else if (!valid_addr_A)
            $display("[ERROR] Address A is out of range: %d", address_a);
        else begin
            if (wren_a)
                ram[address_a] <= data_a;
            if (rden_a)
                q_a <= ram[address_a]; // Synchronous read
        end
    end
    
    // Port B logic
    always @(posedge clk_b) begin
        if (rst) 
            q_b <= 8'h00;
        else if (!valid_addr_B)
            $display("[ERROR] Address B is out of range: %d", address_b);
        else begin
            if (wren_b)
                ram[address_b] <= data_b;
            if (rden_b)
                q_b <= ram[address_b]; // Synchronous read
        end
    end
endmodule
