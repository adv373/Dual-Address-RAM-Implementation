`include "trueport_ram.v"

module dual_port_TB();
reg clk_a, clk_b, wren_a, rden_a, wren_b, rden_b;
reg rst;
reg [9:0] address_a, address_b;
reg [7:0] data_a, data_b;
wire [7:0] q_a, q_b;

trueport_ram R1(
     .clk_a(clk_a), .clk_b(clk_b), .wren_a(wren_a), .rden_a(rden_a), .wren_b(wren_b), .rden_b(rden_b),
     .rst(rst),  
     .address_a(address_a), .address_b(address_b),
     .data_a(data_a), .data_b(data_b),
     .q_a(q_a), .q_b(q_b) );
   
// Adjusted Clock Generation
always #5 clk_a = ~clk_a;  // 10 ns period
always #6 clk_b = ~clk_b;  // 12 ns period

initial begin
    // Initialize signals
    clk_a = 0; clk_b = 0;
    wren_a = 0; rden_a = 0; wren_b = 0; rden_b = 0;
    rst = 1;
    address_a = 0; address_b = 0;
    data_a = 0; data_b = 0;

    #15 rst = 0; // Extended Reset Period for Stability
    
    // Check Initial Memory Values from the Memory Initialization File
    #20 address_a = 10'd5; rden_a = 1;
    #10 rden_a = 0;
    #20 address_b = 10'd100; rden_b = 1;
    #10 rden_b = 0;

    // Write & Read Back from Port A
    #20 address_a = 10'd10; data_a = 8'h90; wren_a = 1;
    #10 wren_a = 0;
    #15 rden_a = 1;
    #10 rden_a = 0;

    // Write & Read Back from Port B
    #20 address_b = 10'd20; data_b = 8'h50; wren_b = 1;
    #10 wren_b = 0;
    #20 rden_b = 1;
    #10 rden_b = 0;
    
    // Cross-Read Verification (Port A writes, Port B reads and vice versa)
    #20 address_b = 10'd10; rden_b = 1;
    #10 rden_b = 0;
    #20 address_a = 10'd20; rden_a = 1;
    #10 rden_a = 0;

    // Simultaneous Write Test (Both Ports Writing to Same Address)
    #20 address_a = 10'd15; data_a = 8'h10; wren_a = 1;
        address_b = 10'd15; data_b = 8'h15; wren_b = 1;
    #10 wren_a = 0; wren_b = 0;
    #20 rden_a = 1; rden_b = 1;
    #10 rden_a = 0; rden_b = 0;

    // Read & Write Conflict (Port A writes while Port B reads from the same address)
    #20 address_a = 10'd30; data_a = 8'hAA; wren_a = 1;
    #5 address_b = 10'd30; rden_b = 1;
    #10 wren_a = 0; rden_b = 0;
    
    // Out-of-Range Address Test
    #20 address_a = 10'd512; data_a = 8'h10; wren_a = 1;
    #10 wren_a = 0;
    #20 address_a = 10'd20; rden_a = 1;
    #10 rden_a = 0;

    // Both Ports Trying to Read the Same Address
    #20 address_a = 10'd40; rden_a = 1;
        address_b = 10'd40; rden_b = 1;
    #10 rden_a = 0; rden_b = 0;
    
    // Address Switching Test
    #20 address_a = 10'd50; data_a = 8'h55; wren_a = 1;
    #10 wren_a = 0;
    #20 address_a = 10'd51; data_a = 8'h66; wren_a = 1;
    #10 wren_a = 0;
    #20 address_a = 10'd52; data_a = 8'h77; wren_a = 1;
    #10 wren_a = 0;
    #20 address_a = 10'd50; rden_a = 1;
    #10 rden_a = 0;
    
    // Extra Delay to Observe Final Waveforms
    #100;
    
    // End simulation
    $finish;
end
endmodule
