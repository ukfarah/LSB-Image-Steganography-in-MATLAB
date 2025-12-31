clc; clear; close all;

%% FORCE MATLAB TO USE THIS FILE'S FOLDER
thisFile = mfilename('fullpath');
projectRoot = fileparts(thisFile);
cd(projectRoot);
addpath(genpath(projectRoot));

C = config();

fprintf('\n=============================\n');
fprintf('Tomato Project - Full System\n');
fprintf('=============================\n\n');

while true
    choice = menu('Run System', ...
        '1) Train model', ...
        '2) Validate folder', ...
        '3) Detect ONE image', ...
        '4) LSB Steganography', ...
        'Exit');

    if choice == 5 || choice == 0
        disp('Exit.');
        break;
    end

    switch choice
        case 1
            core('train', C);

        case 2
            folder = C.valDir;
            if ~isfolder(folder)
                fprintf("⚠ Validation folder not found: %s\n", folder);
            else
                core('eval', C, folder);
            end

        case 3
            [fileName, filePath] = uigetfile( ...
                {'*.jpg;*.jpeg;*.png;*.bmp','Image Files'}, ...
                'Select a tomato leaf image');

            if isequal(fileName,0)
                disp("No image selected.");
            else
                imgPath = fullfile(filePath, fileName);
                core('detect', C, imgPath, true);
            end

        case 4
            if ~exist('LSB_Steganography.m','file')
                error('LSB_Steganography.m not found in the project folder.');
            end
            fprintf('Launching LSB Steganography...\n\n');
            run('LSB_Steganography.m');   % ✅ زي ما انت عايز بالظبط
            fprintf('\nLSB STEGANOGRAPHY FINISHED ✅\n');
    end
end

fprintf('\n=============================\n');
fprintf('ALL DONE ✅\n');
fprintf('=============================\n');
