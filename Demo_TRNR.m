% =========================================================================
% Simple demo codes for face hallucination via TRNR
%
% Reference
%   J. Jiang et al. Noise Robust Position-Patch based Face Super-Resolution 
%   Via Tikhonov Regularized Neighbor Representation, Information Sciences,
%   vol. 367-368, pp. 354-372, 2016.
% Junjun Jiang
% School of Computer Science, China University of Geosciences
% For any questions, send email to junjun0595@163.com
% =========================================================================

clc;close all;
clear all;
addpath('.\utilities');

% set parameters
nrow        = 120;        % rows of HR face image
ncol        = 100;        % cols of LR face image
nTraining   = 360;        % number of training sample
nTest       = 40;         % number of ptest sample
upscale     = 4;          % upscaling factor 
BlurWindow  = 4;          % size of an averaging filter 
patch_size  = 16;         % image patch size
overlap     = 12;          % the overlap between neighborhood patches
method      = 'THMS';     

% construct the HR and LR training pairs from the FEI face database
load('fei.mat','XH','XL');

K         = [150];
lambda    = [0.01];
vnoise    = [0];


for TestImgIndex = 1:nTest

    %% face SR for each test image
    fprintf('\n>>>Processing  %d _test.jpg', TestImgIndex);

    % read ground truth of one test face image
    strh = strcat('.\testFaces\',num2str(TestImgIndex),'_test.jpg');
    im_h = imread(strh);

    % generate the input LR face image by smooth and down-sampleing
    w=fspecial('average',[BlurWindow BlurWindow]);
    im_s = imfilter(im_h,w);
    im_l = imresize(im_s,1/upscale,'bicubic');
%     figure,imshow(im_l,[]);title('input LR face');    
    
    % add noise to the LR face image (Optional)
    v    =  vnoise;seed   =  0;randn( 'state', seed );
    noise      =   randn(size( im_l ));
    noise      =   noise/sqrt(mean2(noise.^2));
    im_l       =   double(im_l) + v*noise;  

    % face hallucination via TRNR
    [im_SR] = TRNRSR(im_l,XH,XL,upscale,patch_size,overlap,K,lambda);
    im_SR = uint8(im_SR);
    
    % bicubic interpolation for reference
    im_b = imresize(im_l, [nrow, ncol], 'bicubic');
    
    % compute PSNR and SSIM for Bicubic and our method
    bb_psnr(TestImgIndex) = psnr(im_b,im_h);
    bb_ssim(TestImgIndex) = ssim(im_b,im_h);
    sr_psnr(TestImgIndex) = psnr(im_SR,im_h);
    sr_ssim(TestImgIndex) = ssim(im_SR,im_h);

    % display the objective results (PSNR and SSIM)
    fprintf('\nPSNR for Bicubic Interpolation: %f dB\n', bb_psnr(TestImgIndex));
    fprintf(['PSNR for ',method,' Recovery: %f dB\n'], sr_psnr(TestImgIndex));
    fprintf('SSIM for Bicubic Interpolation: %f dB\n', bb_ssim(TestImgIndex));
    fprintf(['SSIM for ',method,' Recovery: %f dB\n'], sr_ssim(TestImgIndex));

    % show the images
%     figure, imshow(im_b);
%     title('Bicubic Interpolation');
%     figure, imshow(uint8(im_SR));
%     title('LcR Recovery');

    % save the result
    strw = strcat('./results/', char(method),'-',num2str(TestImgIndex),'_lambda-',num2str(lambda),'_K-',num2str(K),'_v-',num2str(vnoise),'_SR-16-12.bmp');
    imwrite(uint8(im_SR),strw,'bmp');
end

fprintf('===============================================\n');
fprintf('Average PSNR of Bicubic Interpolation: %f\n', sum(bb_psnr)/nTest);
fprintf(['Average PSNR of' method,' Recovery: %f dB\n'], sum(sr_psnr)/nTest);
fprintf('Average SSIM of Bicubic Interpolation: %f\n', sum(bb_ssim)/nTest);
fprintf(['SSIM for ',method,' Recovery: %f dB\n'], sum(sr_ssim)/nTest);
fprintf('===============================================\n');

