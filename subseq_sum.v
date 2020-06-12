module subseq_sum(input clk,
                  input rst,
                  input valid_in,
                  input signed [7:0] data_in, output valid_out,
                  output unsigned [11:0] max_sum);

parameter IDLE = 3'b001, READ = 3'b010, INIT = 3'b011, ALG = 3'b100, OUTP = 3'b111;
reg [2:0] state;
reg unsigned [3:0] count;
reg signed [7:0] data_array [7:0];
reg signed [11:0] par_sum;
reg unsigned [11:0] max_sum;
reg valid_out;

always @ (posedge clk)
begin
  if (rst == 1'b1) begin
    state <=  #1 READ;
    count <=  0;
    valid_out <= 0;
    max_sum <= 0;
    par_sum <= 0;
  end
  else begin
    case (state)
        READ:
          if (valid_in == 1'b1) begin
                state <= #1 READ;
                data_array[count] = data_in;
                //$display("  data_array[%d] = %d , data_in = %d",count, data_array[count], data_in);
                count += 1;
              if (count == 8) begin
                state <= #1 INIT;
              end
          end
          else begin
            state <=  #1 READ;
            count <=  0;
            valid_out <= 0;
            max_sum <= 0;
            par_sum <= 0;
          end   
        INIT:
            begin
                count <= 0;
                par_sum <= 0;
                max_sum <= 0;
                state <= #1 ALG;
            end
            
        ALG:
            if (count < 8) begin
                par_sum += data_array[count];
                if (par_sum < 0) begin
                    par_sum = 0;
                end
                if (max_sum < par_sum) begin
                    max_sum = par_sum;
                end
                state <= #1 ALG;
                count += 1;
            end
            else begin
              count <= 0;
              state <= #1 OUTP;
            end
        OUTP:
            begin
              valid_out <= 1;
              state <= #1 READ;
            end
            
        default: 
            state <= #1 READ;
    endcase
  end
end
endmodule