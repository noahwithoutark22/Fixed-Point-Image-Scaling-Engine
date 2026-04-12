`timescale 1fs / 1fs

// Number of channels = 1 (Grayscle)
// Number of channels = 3 (RGB)

module top #(
    parameter H_IN  = 4362,
    parameter W_IN  = 3490,
    parameter H_OUT = 1090,
    parameter W_OUT = 872,
    parameter NO_OF_CHANNELS = 3
)(
    input  clk,
    input  reset,
    output reg done
);

reg [7:0] input_image[0:(H_IN * W_IN * NO_OF_CHANNELS  - 1 )];
reg [7:0]updated_input_image[0:(H_IN * W_IN * NO_OF_CHANNELS  - 1 )];
reg [7:0] output_image[0:(H_OUT * W_OUT* NO_OF_CHANNELS- 1)];
reg [8:0]t;
reg [7:0]t1;
reg write_done;
reg incr;
initial begin
    done = 0;
    write_done = 0;
    $readmemh("C:/Users/yashd/Downloads/tigerc.hex", input_image);
end

// ------------------------------------
// PLACE YOUR SCALING LOGIC HERE
// When computation finishes:
// done <= 1;
// ------------------------------------
parameter Hin_S = $clog2(H_IN);
parameter Hout_S = $clog2(H_OUT);
parameter Win_S = $clog2(W_IN);
parameter Wout_S = $clog2(W_OUT);
parameter divS = (( (Hin_S > Hout_S ? Hin_S : Hout_S) > (Win_S > Wout_S ? Win_S : Wout_S) ) ? 
                     (Hin_S > Hout_S ? Hin_S : Hout_S) : (Win_S > Wout_S ? Win_S : Wout_S)) + 8;
parameter INIT=0, divW=1, divH=2,blur=3, acc1=4, acc2=5, acc3=6, acc4=7,write=8,condCheck=9,Finish=10;


wire [divS+7:0] divIFout;
reg [divS + 7:0] win_by_wout, hin_by_hout;
wire [7:0] a,b;
wire [divS-1:0] xo,yo;
assign {xo,a} = x_out*win_by_wout;
assign {yo,b} = y_out*hin_by_hout;
reg rstx,rsty,incx,incy,start_div;
wire div_done;
wire [divS-1:0] x_out, y_out;
reg [divS+7:0] divA, divB;
reg [3:0] curr_state, next_state;
reg [25:0] pixel_out;
reg [1:0] cntCh,k;
reg [15:0] temp;
wire [15:0] temp_round;
assign temp_round = temp + 16'd128;  
div # (.WIDTH(divS+8)) d(
    .clk(clk),
    .start(start_div),
    .reset(reset),
    .dividend(divA),
    .divisor(divB),
    .quotient(divIFout),
    // .remainder(divFout),
    .done(div_done));
coordgen #(.WIDTH(divS)) cg(
    .incx(incx),
    .incy(incy),
    .rstx(rstx),
    .rst(reset),
    .rsty(rsty),
    .clk(clk),
    .x_out(x_out),
    .y_out(y_out));
always @(posedge clk) begin
    if(reset) begin
        curr_state <= INIT;
    end
    else
        curr_state <= next_state;
end
always @(posedge clk) begin
    case (curr_state)
        INIT: begin
            pixel_out <= 0;
            cntCh<=0;
            k<=0;
        end
        blur:begin
                  updated_input_image[y_out*W_IN + x_out + (W_IN*H_IN*k)] <= temp_round[15:8];
                  if(incr) k<=k+1;
        end
        acc1: begin
        if(W_IN>W_OUT||H_IN>H_OUT)
         pixel_out <= pixel_out + (((1<<8)-a)*((1<<8)-b)*updated_input_image[xo + yo*W_IN+W_IN*H_IN*cntCh]);
        else
            pixel_out <= pixel_out + (((1<<8)-a)*((1<<8)-b)*input_image[xo + yo*W_IN+W_IN*H_IN*cntCh]);
        end 
        acc2: begin
            if(xo!=W_IN-1)
            begin
             if(W_IN>W_OUT||H_IN>H_OUT)
              pixel_out <= pixel_out + a*((1<<8) - b)*updated_input_image[xo+1 + yo*W_IN+W_IN*H_IN*cntCh];
             else
            pixel_out <= pixel_out + a*((1<<8) - b)*input_image[xo+1 + yo*W_IN+W_IN*H_IN*cntCh];
            end
        end
        acc3: begin
            if(yo!=H_IN-1)
            begin 
                 if(W_IN>W_OUT||H_IN>H_OUT)
                  pixel_out <= pixel_out + b*((1<<8) - a)*updated_input_image[xo + (yo+1)*W_IN+W_IN*H_IN*cntCh ];
                 else
                  pixel_out <= pixel_out + b*((1<<8) - a)*input_image[xo + (yo+1)*W_IN+W_IN*H_IN*cntCh ];
            end
        end
        acc4: begin
             if(W_IN>W_OUT||H_IN>H_OUT)
              pixel_out <= pixel_out+  ( yo==H_IN-1 || xo==W_IN-1 ? 0 : (a*b*(updated_input_image[(xo+1)+(yo+1)*W_IN +W_IN*H_IN*cntCh] )));
             else
            pixel_out <= pixel_out+  ( yo==H_IN-1 || xo==W_IN-1 ? 0 : (a*b*(input_image[(xo+1)+(yo+1)*W_IN +W_IN*H_IN*cntCh] )));
            
        end
        write: begin
            output_image[x_out + y_out*W_OUT+W_OUT*H_OUT*cntCh] <= (&t1)?8'd255:t[8:1];
            if(x_out == W_OUT - 1 && y_out == H_OUT - 1) cntCh<=cntCh+1; 
            pixel_out <= 0;
        end
    endcase
end

always @(*)
    case (curr_state)
        INIT: begin
            incx=0;
            incy=0;
            rstx=0;
            rsty=0;
            done=0;
            start_div=0;
            next_state = divW;
            incr=0;
        end
        divW: begin
            divA = (W_IN<<8);
            divB = W_OUT;
            start_div = 1;
            incx=0;
            incy=0;
            rstx=0;
            done=0;
            rsty=0;
            if(div_done) begin
                win_by_wout = divIFout;
                next_state = divH;
                start_div = 0; // Check this on debug
            end
        end
        divH: begin
            divA = (H_IN<<8);
            divB = H_OUT;
            incx=0;
            incy=0;
            rstx=0;
            done=0;
            rsty=0;
            if(div_done && start_div) begin
                hin_by_hout = divIFout;
                if(W_IN>W_OUT||H_IN>H_OUT)
                next_state=blur;
                else
                next_state = acc1;
                start_div = 0; // Check this on debug
            end
            start_div = 1;
        end
        blur:begin 
          temp =
    ( input_image[
        ((y_out>0)?y_out-1:0)*W_IN + ((x_out>0)?x_out-1:0)
        + (W_IN*H_IN*k)
      ] << 4 )

  + ( input_image[
        ((y_out>0)?y_out-1:0)*W_IN + x_out
        + (W_IN*H_IN*k)
      ] << 5 )

  + ( input_image[
        ((y_out>0)?y_out-1:0)*W_IN + ((x_out+1==W_IN)?x_out:x_out+1)
        + (W_IN*H_IN*k)
      ] << 4 )

  + ( input_image[
        y_out*W_IN + ((x_out>0)?x_out-1:0)
        + (W_IN*H_IN*k)
      ] << 5 )

  + ( input_image[
        y_out*W_IN + x_out
        + (W_IN*H_IN*k)
      ] << 6 )

  + ( input_image[
        y_out*W_IN + ((x_out+1==W_IN)?x_out:x_out+1)
        + (W_IN*H_IN*k)
      ] << 5 )

  + ( input_image[
        ((y_out+1==H_IN)?y_out:y_out+1)*W_IN + ((x_out>0)?x_out-1:0)
        + (W_IN*H_IN*k)
      ] << 4 )

  + ( input_image[
        ((y_out+1==H_IN)?y_out:y_out+1)*W_IN + x_out
        + (W_IN*H_IN*k)
      ] << 5 )

  + ( input_image[
        ((y_out+1==H_IN)?y_out:y_out+1)*W_IN
        + ((x_out+1==W_IN)?x_out:x_out+1)
        + (W_IN*H_IN*k)
      ] << 4 );
      
      if(x_out==W_IN-1&&y_out==H_IN-1&&k== NO_OF_CHANNELS-1)
      begin 
      rstx=1;
      rsty=1;
      incx=0;
      incy=0;
      incr=0;
      next_state=acc1;
      end
      else if(x_out==W_IN-1&&y_out==H_IN-1)
      begin 
      rstx=1;
      rsty=1;
      incx=0;
      incy=0;
      next_state=blur;
      incr=1;
      end
      else if(x_out == W_IN - 1) begin
                incy=1;
                rstx=1;
                rsty=0;
                incx=0;
                incr=0;
                next_state = blur;
            end
      else      begin
                incx=1;
                rstx=0;
                rsty=0;
                incy=0;
                incr=0;
                next_state = blur;
                end
        end
        acc1: begin
            incx=0;
            incy=0;
            rstx=0;
            done=0;
            rsty=0;
            next_state=acc2;
        end
        acc2: begin
            incx=0;
            incy=0;
            rstx=0;
            rsty=0;
            done=0;
            next_state=acc3;
        end
        acc3: begin
            incx=0;
            incy=0;
            rstx=0;
            rsty=0;
            done=0;
            next_state=acc4;
        end
        acc4: begin
            incx=0;
            incy=0;
            rstx=0;
            rsty=0;
            done=0;
            next_state=write;
        end
        write: begin
            incx=0;
            incy=0;
            rstx=0;
            rsty=0;
            done=0;
            next_state=condCheck;
            if(pixel_out[25])
            begin 
                 t=pixel_out[25:17]+1;
                 t1=255;
            end
            else if(pixel_out[24])
            begin t=pixel_out[24:16]+1;
                t1=pixel_out[24:17];
            end
            else 
            begin t=pixel_out[23:15]+1;
                   t1=pixel_out[23:16];
            end
        end
        condCheck: begin
            if(x_out == W_OUT - 1 && y_out == H_OUT - 1) begin
                 if(cntCh==NO_OF_CHANNELS) begin
                    incx=0;
                    incy=0;
                    rstx=0;
                    rsty=0;
                next_state = Finish;
                end
                else begin
                    incx=0;
                    incy=0;
                    rstx=1;
                    rsty=1;
                    next_state = acc1;
                end
                
            end
            else if(x_out == W_OUT - 1) begin
                incy=1;
                rstx=1;
                rsty=0;
                incx=0;
                next_state = acc1;
            end
            else begin
                incx=1;
                rstx=0;
                rsty=0;
                incy=0;
                next_state = acc1;
            end
            done=0;
        end
        Finish: begin
            next_state = Finish;
            incx=0;
            incy=0;
            rstx=0;
            rsty=0;
            done = 1;
            
        end
    endcase



always @(posedge clk) begin
    if (done && !write_done) begin
        write_done <= 1;
        $writememh("C:/Users/yashd/Downloads/I Chip/tigercshrink.hex", output_image);
    end
end

endmodule