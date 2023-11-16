%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Arin Can Ulku
%%% arin.ulku@epfl.ch
%%% EPFL, 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modified by Siavash for contineous measurement determined by x1 (line 15)
clear all
clc
close all
currentFolder=pwd;

delete([currentFolder '/raw_data/*.mat'])
delete([currentFolder '/output_images/*.tiff'])

for x1=1:5; % number of data acquisition sequence  
% BEGIN NOTES
% Shutter Mode: Global shutter
% Laser Trigger Type: 20 MHz internal trigger. Low Voltage: 0, High Voltage: Max. 5 V
% END NOTES

% BEGIN user parameters

bits_10 = 1; % 1: 10-bit images, 0: 8-bit images
gate_offset = 31*56; % *number of gates to skip before data acquisition (default: 0): now defined as part of config_array
no_gate_pos = 200; % number of gate positions per gate set
exp_no_seq = 50; % (exposure=400ns*exp_no_seq-50ns)
gs_no_shift = 1; % *gate shift between 2 subsequent gate positions (x 17.857 ps)

gs_psincdec_0 = 1; % direction of the gate wrt the laser (0: backward, 1: forward)
gs_no_shift_adj_1 = 65; % gate window adjustment
gs_no_shift_adj_2 = 90; % gate window adjustment
gs_no_shift_adj_3 = 55; % gate window adjustment: now defined as part of config_array
gs_psincdec_1 = 0; % gate window adjustment
gs_psincdec_2 = 0; % gate window adjustment
gs_psincdec_3 = 1; % gate window adjustment: now defined as part of config_array

% con 4 
% gs_psincdec_0 = 1; % direction of the gate wrt the laser (0: backward, 1: forward)
% gs_no_shift_adj_1 = 65; % gate window adjustment
% gs_no_shift_adj_2 = 90; % gate window adjustment
% gs_no_shift_adj_3 = 195; % gate window adjustment: now defined as part of config_array
% gs_psincdec_1 = 0; % gate window adjustment
% gs_psincdec_2 = 0; % gate window adjustment
% gs_psincdec_3 = 1; % gate window adjustment: now defined as part of config_array
%

% END user parameters

offset_time_seconds=0.001; %% min: 1E-6, max: 9
offset_clk_cycles=floor(offset_time_seconds/(5E-9));
fifo_th=16384/1;
if bits_10==1
    no_gate_pos_m=(no_gate_pos*4);
else
    no_gate_pos_m=no_gate_pos;
end

setenv('MW_MINGW32_LOC','C:\TDM-GCC-32')
dev = openFPGA();
bitfile = [currentFolder '\bit_file\ss2_top.bit'];
z_status=configureFPGA(dev, bitfile);

wire_in_0=gs_psincdec_0+gs_psincdec_1*2^1+gs_psincdec_2*2^2+gs_psincdec_3*2^3+gs_no_shift_adj_1*2^4+bits_10*2^19;
setwireinvalue(dev,int32(hex2dec('00')),wire_in_0,wire_in_0)
updatewireins(dev)
wire_in_1=gs_no_shift_adj_2+gs_no_shift_adj_3*2^15;
setwireinvalue(dev,int32(hex2dec('01')),wire_in_1,wire_in_1)
updatewireins(dev)
wire_in_2=no_gate_pos_m*2^8;
setwireinvalue(dev,int32(hex2dec('10')),wire_in_2,wire_in_2)
updatewireins(dev)
wire_in_3=exp_no_seq+gate_offset*2^16;
setwireinvalue(dev,int32(hex2dec('11')),wire_in_3,wire_in_3)
updatewireins(dev)
wire_in_4=gs_no_shift;
setwireinvalue(dev,int32(hex2dec('12')),wire_in_4,wire_in_4)
updatewireins(dev)
wire_in_5=fifo_th;
setwireinvalue(dev,int32(hex2dec('13')),wire_in_5,wire_in_5)
updatewireins(dev)
wire_in_6=offset_clk_cycles;
setwireinvalue(dev,int32(hex2dec('14')),wire_in_6,wire_in_6)
updatewireins(dev)

% BEGIN SAVE

[SS2_DATA,daq_time]=ss2_daq_hdf5(dev,int32(hex2dec('A0')),16384,(512*256)*no_gate_pos_m);

disp(['Elapsed DAQ time: ' num2str(daq_time) ' sec']);

updatewireouts(dev);
fsm_state = dec2hex(getwireoutvalue(dev,int32(hex2dec('20'))));    
updatewireouts(dev);
fsm_state_2 = dec2hex(getwireoutvalue(dev,int32(hex2dec('21'))));

beep

disp([10 'ACQUISITION COMPLETED. YOU CAN TURN OFF THE LASER NOW.' 10])
fsm_state_int=str2double(fsm_state_2);
if fsm_state_int==2
    disp('USB DATA TRANSFER SUCCESSFUL!')
else
    disp('USB DATA TRANSFER FAILED!')
end
        
closeFPGA(dev);
    
disp([10 'SAVING .MAT RAW DATA...' 10])

% tic

% modified by siavash for contineous measurements 
% mkdir(currentFolder, '\raw_data\')
mkdir(strcat(currentFolder, '\raw_data',int2str(x1),'\')) 

% save([currentFolder '\raw_data\raw_data.mat'],'SS2_DATA', '-v7.3');
save([currentFolder '\raw_data',int2str(x1),'\raw_data.mat'] ,'SS2_DATA', '-v7.3');
% toc
pause (0.5) % pause in s (0.5 == 500 ms)
beep
end 

disp([10 'DONE.'])

beep