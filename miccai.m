
clc,close all,clear all,
img = im2double(imread('C:\Users\AK PUJITHA\Desktop\CVIT\diaretdb1_v_1_1\diaretdb1_v_1_1\resources\images\ddb1_fundusimages\image042.png')); % Read the original image
mask = im2double(imread('C:\Users\AK PUJITHA\Desktop\CVIT\diaretdb1_v_1_1\diaretdb1_v_1_1\resources\images\ddb1_fundusmask\fmask.tif')); % Read the mask 
% mask = mask(:,:,2); 

mask = imresize(mask,[1000 1000]); % Resize to standard size 
mask = logical(mask); 
img = imresize(img,[1000 1000]);
img = img(:,:,2);

block_r = 200; % Block height
block_c = 200; % Block width
[sz_r ,sz_c] = size(img);
mean_sub = zeros(sz_r/block_r,sz_c/block_c); % Preallocate mean and std_dev matrices
std_sub = zeros(size(mean_sub));
for counter_row = 1 : sz_r/block_r
    for counter_col = 1 : sz_c/block_c
        % Next four lines compute coordinates for defining the patch
        top_left_r = block_r * (counter_row-1) + 1;
        height = block_r * counter_row;
        top_left_c = block_c * (counter_col -1) + 1;
        width = block_c * counter_col;
        temp = img(top_left_r : height , top_left_c : width);
        temp = temp(:);
        mean_sub(counter_row, counter_col) = mean(temp); % Computation of mean and std 
        std_sub(counter_row, counter_col) = sqrt(var(temp));
    end
end

mean_full = imresize(mean_sub,size(img)); % Interpolate the mean_dev
mean_full = mean_full .*  mask; % Multiply by mask
std_full = imresize(std_sub,size(img)); % Interpolate the std_dev
std_full = std_full .* mask;
figure(1);
subplot(2,2,1), imshow(img,[]);
subplot(2,2,2), imshow(mean_full,[]);
subplot(2,2,3), imshow(std_full,[]);

pcm_dist = (img - mean_full)./std_full;        % compute the PC Mahalanobis's distance
pcm_dist = abs(pcm_dist); % Compute the absolute value of the distance as it should be positive
pcm_dist = pcm_dist .* mask;
pcm_dist(pcm_dist<1)= 1; % choose the threshold globally as 1 
pcm_dist(pcm_dist~=1) = 0;
subplot(2,2,4), imshow(pcm_dist,[]);

for counter_row = 1 : sz_r/block_r
    for counter_col = 1 : sz_c/block_c
        
        top_left_r = block_r * (counter_row-1) + 1;
        height = block_r * counter_row;
        top_left_c = block_c * (counter_col -1) + 1;
        width = block_c * counter_col;
        temp = img(top_left_r : height , top_left_c : width);
        temp = temp(:);
        I = find(pcm_dist(top_left_r : height , top_left_c : width)); % Find the non-zero pixels in the background
        mean_sub(counter_row, counter_col) = mean(temp(I)); % Compute the mean and std_dev for the corresponding intensitities
        std_sub(counter_row, counter_col) = sqrt(var(temp(I)));
    end
end

mean_full = imresize(mean_sub,size(img)); % Interpolate to find the luminosity
mean_full = mean_full .*  mask;
std_full = imresize(std_sub,size(img)); % Interpolate to find the contrast
std_full = std_full .* mask;

corrected = (img - mean_full)./std_full; % Compute the corrected image
corrected = corrected .* mask;
figure(2);
subplot(2,2,1), imshow(img,[]);
subplot(2,2,2), imshow(mean_full,[]);
subplot(2,2,3), imshow(std_full,[]);
subplot(2,2,4), imshow(corrected,[]);
