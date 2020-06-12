`timescale 1ns/1ps
`include "subseq_sum.v"
module subseq_sum_tb;

real CYCLE=1000;

// Input signals
reg clk;
reg valid_in;
reg signed [7:0] data_input;
reg rst;
// Output signals
wire valid_out;
wire [11:0] max_sum_out;

// other
reg [11:0] correct_data;
reg error_occur;
integer i,lat;
reg signed [7:0] data_seq [0:7];
// Instantiate the Unit Under Test (UUT)
subseq_sum uut (
    .rst(rst),
    .clk(clk),
    .valid_in(valid_in),
    .data_in(data_input),
    .valid_out(valid_out),
.max_sum(max_sum_out));

initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

initial begin
    // Setup the signal dump file.
    // see https://iverilog.fandom.com/wiki/Verilog_Portability_Notes for more information
    $dumpfile("subseq_sum.vcd"); // Set the name of the dump file.
    $dumpvars;                   // Save all signals to the dump file.
    $dumpvars(0, uut);           // It dumps all the variables of module uut and
                                 // all the variables in all lower level modules instantiated
                                 // by top module uut.
    for (i = 0; i < 8; i = i + 1) begin
        // You can dump the array signals by this way
        // uut.data_array means the data_array signal in module uut
        // data_seq is an array in this testbench
        // Howeverm it cause warning , which you can ignore it
        $dumpvars(1, uut.data_array[i]);
        $dumpvars(1, data_seq[i]);
    end

    // Display the signal values whenever there is a change.
    $monitor("valid_in = %b,data_in = %d,valid_out = %b,max_sum = %d",
                valid_in, data_input, valid_out, max_sum_out);

    // Initialize the input signals

    error_occur = 0;
    data_input = 0;
    valid_in = 0;
    clk = 0;
    rst = 0;
    @(posedge clk); //Initialize reset
    #1; //Simulate flip-flop delay
    rst = 1;
    @(posedge clk); //Initialize reset
    #1; //Simulate flip-flop delay
    rst = 0;
    //valid_out and max_sum should be zero after reset
    //You should make sure that when valid_out high , max_sum contains correct data.

    if (valid_out !== 0) begin
        $display("Error: max_sum or valid_out should be reset");
        error_occur = 1;
    end
    @(posedge clk);
    #1; //Simulate flip-flop delay

    testcase_generate;

    for (i = 0 ; i < 8 ; i = i + 1) begin
        @(posedge clk);
        #1; //Simulate flip-flop delay
        valid_in = 1;
        data_input = data_seq[i];
    end
    @(posedge clk);
    #1; //Simulate flip-flop delay
    valid_in = 0;
    data_input = 0;
    wait_out_valid;
    if (valid_out) begin
        if (max_sum_out !== correct_data ) begin
            $display("Error:result failed");
            $display("Correct = %d , max_sum = %d",correct_data,max_sum_out);
            error_occur = 1;
        end
    end else begin
        $display("Error: no output");
        error_occur = 1;
    end

    @(posedge clk);//Raising the valid_out signal by "only" one clock cycle
    //Please write some testing code for this error case;

    #1; //Simulate flip-flop delay
    @(posedge clk);//Raising the valid_out signal by "only" one clock cycle
    //Please write some testing code for this error case;

    if (error_occur === 0) begin
        $display("=========================");
        $display("Congratulations!!!");
        $display("=========================");
    end else begin
        $display("some error happened!!!");
    end
    @(posedge clk);
    $finish;
end



task testcase_generate; begin
    // You can try to use $random function and for-loop to replace this section.
    // You can change input pattern by hands and make sure you test corner case
    data_seq[0] = -7;
    data_seq[1] = 1;
    data_seq[2] = -3;
    data_seq[3] = 2;
    data_seq[4] = -1;
    data_seq[5] = 1;
    data_seq[6] = 3;
    data_seq[7] = -5;

    correct_data = 12'd5;
end endtask

task wait_out_valid; begin
    lat=-1;
    while(valid_out!==1) begin
        lat=lat+1;
        if(lat==200)begin
            $display("********************************************************");
            $display("*  The execution latency are over 200 cycles  at %8t   *",$time);//over max
            $display("********************************************************");
            repeat(2)@(posedge clk);
            $finish;
        end
        @(posedge clk);
    end
end endtask
endmodule


