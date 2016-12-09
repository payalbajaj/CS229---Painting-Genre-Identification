%% Initialization
final_size_rows=32; %64;
final_size_cols=32; %64;

%% Read mapping of files
M = csvread('image_genre_list_new.csv');
class_1= 0; class_2= 1; class_3= 2; class_4= 3; class_5= 4;
data_1 = M(M(:,2)==class_1, :); 
data_1 = data_1(1:15000,:);
data_2 = M(M(:,2)==class_2, :);
data_2 = data_2(1:10000,:);
data_3 = M(M(:,2)==class_3, :);
data_3 = data_3(1:14000,:);
data_4 = M(M(:,2)==class_4, :);
data_4 = data_4(1:2400,:);
data_5 = M(M(:,2)==class_5, :);
data_5 = data_5(1:2400,:);
%Adding rotated data/Translated Data
data_6 = data_4;
data_6(:,2) = 5;
data_7 = data_4;
data_7(:,2) = 6;
data_8 = data_4;
data_8(:,2) = 7;

data_9 = data_5;
data_9(:,2) = 8;
data_10 = data_5;
data_10(:,2) = 9;
data_11 = data_5;
data_11(:,2) = 10;

data_size = 58200;
new_data = [data_1; data_2; data_3; data_4; data_5; data_6; data_7; data_8; data_9; data_10; data_11];
img_data = new_data(randperm(data_size),:);

%% Create Data Structures
batch_size = 9700;
data = zeros(batch_size,final_size_cols*final_size_rows*3);
labels = zeros(batch_size,1);
batch_names = ['batch_1.mat'; 'batch_2.mat'; 'batch_3.mat'; 'batch_4.mat'; 'batch_5.mat'; 'batch_6.mat'];
%Read all files
%genre_list = {'resized_landscape'; 'resized_genre_painting'; 'resized_portrait'; 'resized_history_painting'; 'resized_still_life'};
%genre_list = {'128_resized_landscape'; '128_resized_genre_painting'; '128_resized_portrait'; '128_resized_history_painting'; '128_resized_still_life'};
%genre_list = {'32_resized_landscape'; '32_resized_genre_painting'; '32_resized_portrait'; '32_resized_history_painting'; '32_resized_still_life'};

%genre_list = {'32_resized_landscape'; '32_resized_genre_painting'; '32_resized_portrait'; '32_resized_history_painting'; '32_resized_still_life'; '32_rotated_270_resized_history_painting';  '32_rotated_180_resized_history_painting'; '32_rotated_90_resized_history_painting'; '32_rotated_270_resized_still_life'; '32_rotated_180_resized_still_life'; '32_rotated_90_resized_still_life'};
genre_list = {'32_resized_landscape'; '32_resized_genre_painting'; '32_resized_portrait'; '32_resized_history_painting'; '32_resized_still_life'; '32_translated_8_resized_history_painting';  '32_translated_16_resized_history_painting'; '32_translated_24_resized_history_painting'; '32_translated_8_resized_still_life'; '32_translated_16_resized_still_life'; '32_translated_24_resized_still_life'};

label_names = {'landscape'; 'genre'; 'portrait'; 'history'; 'stillLife'};
batch_labels = {'Training Batch 1 of 5'; 'Training Batch 2 of 5'; 'Training Batch 3 of 5'; 'Training Batch 4 of 5'; 'Training Batch 4 of 5'; 'Testing Batch 1 of 1';};
%{
image_names = char(15000);
imagefiles = dir('landscape\*.jpg');      
nfiles = length(imagefiles);
for iter=1:nfiles
    filename = char(strcat('landscape\',imagefiles(iter).name,'.jpg'));
    image_names(iter)= filename;
end
%}
%% Loop over Data
img_iter = 0;
batch_iter = 1;
for img=1:size(img_data,1)  
    disp(img_iter);
    img_iter = img_iter + 1;
    fname = char(strcat(genre_list(img_data(img,2)+1),'\',int2str(img_data(img,1)),'.jpg'));
    img_file = imread(fname); 
    labels(img_iter) = img_data(img,2);
    %%edit for rotated data
    if((labels(img_iter) == 5)||(labels(img_iter) == 6)||(labels(img_iter) == 7))
        labels(img_iter) = 3;
    elseif((labels(img_iter) == 8)||(labels(img_iter) == 9)||(labels(img_iter) == 10))
        labels(img_iter) = 4;
    end
    bool_bw = 0;
    if(size(img_file,3) == 1)
        bool_bw = 1;
    end
    for row=1:final_size_rows
        for col=1:final_size_cols
            if(bool_bw == 1)
                w = img_file(row, col,1);
                r = w;
                g = w;
                b = w;
            else
                r = img_file(row, col, 1);
                g = img_file(row, col, 2);
                b = img_file(row, col, 3);
            end
            data(img_iter, (row-1)*final_size_cols + col) = r;
            %1024 - 32 by 32
            data(img_iter, 1024 + (row-1)*final_size_cols + col) = g;
            data(img_iter, 2*1024+ (row-1)*final_size_cols + col) = b;
            %4096 - 64 by 64
            %data(img_iter, 4096 + (row-1)*final_size_cols + col) = g;
            %data(img_iter, 2*4096+ (row-1)*final_size_cols + col) = b;
            %disp(img_data(img_iter, 2*4096+ (row-1)*final_size_cols + col));
        end
    end
    %Save batch of 3k files
    if(mod(img_iter, batch_size) == 0)
        labels = uint8(labels);
        data = uint8(data);
        batch_label = char(batch_labels(batch_iter));
        save(batch_names(batch_iter,:));
        batch_iter = batch_iter + 1;
        data = zeros(batch_size,final_size_cols*final_size_rows*3);
        labels = zeros(batch_size,1);
        img_iter = 0;
    end
end

%% Batch for lables
label_names = {'landscape'; 'genre'; 'portrait'; 'history'; 'stillLife'};
save('art_batches.meta.mat');