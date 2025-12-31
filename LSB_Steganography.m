clc;
clear;
close all;

%% ========== USER OPTIONS ==========
choice = menu('LSB Steganography System', ...
              'Embed Data', ...
              'Extract Data');

signature = 'STEGO';   % Signature for detection

%% ========== EMBED DATA ==========
if choice == 1

    [file,path] = uigetfile({'*.png;*.jpg;*.jpeg','Image Files (*.png, *.jpg, *.jpeg)'}, ...
                            'Select Cover Image');
    if isequal(file,0)
        disp('No image selected. Exiting...');
        return;
    end

    img = imread(fullfile(path,file));
    img = uint8(img);

    secretMessage = input('Enter secret message: ', 's');
    outputImage = 'stego_image.png';

    % Convert message + signature to binary
    msg = [signature secretMessage];
    msgBin = reshape(dec2bin(uint8(msg),8).' - '0', 1, []);

    [m,n,c] = size(img);
    totalBits = m*n*c;

    if length(msgBin) > totalBits
        error('Message too large for this image');
    end

    idx = 1;
    for i = 1:m
        for j = 1:n
            for k = 1:c
                if idx <= length(msgBin)
                    img(i,j,k) = bitset(img(i,j,k), 1, msgBin(idx));
                    idx = idx + 1;
                end
            end
        end
    end

    imwrite(img, outputImage);
    disp('Data embedded successfully!');
    disp(['Output Image: ' outputImage]);

%% ========== EXTRACT DATA ==========
elseif choice == 2

    [file,path] = uigetfile({'*.png;*.jpg;*.jpeg','Image Files (*.png, *.jpg, *.jpeg)'}, ...
                            'Select Stego Image');
    if isequal(file,0)
        disp('No image selected. Exiting...');
        return;
    end

    img = imread(fullfile(path,file));
    img = uint8(img);

    [m,n,c] = size(img);

    % Collect all LSB bits
    totalBits = m*n*c;
    bits = zeros(totalBits, 1, 'uint8');   % pre-allocate
    idx = 1;

    for i = 1:m
        for j = 1:n
            for k = 1:c
                bits(idx) = uint8(bitget(img(i,j,k), 1));
                idx = idx + 1;
            end
        end
    end

    % Convert bits -> bytes -> characters
    % Make length multiple of 8
    rem8 = mod(length(bits), 8);
    if rem8 ~= 0
        bits = bits(1:end-rem8);
    end

    bitChars = char(bits + '0');                 % '0'/'1'
    byteMatrix = reshape(bitChars, 8, []).';     % each row is 8 bits
    byteVals = uint8(bin2dec(byteMatrix));       % numeric bytes

    % Convert to text safely
    chars = char(byteVals(:).');                 % row char array

    % Remove trailing nulls (common in steg)
    nullPos = find(chars == char(0), 1);
    if ~isempty(nullPos)
        chars = chars(1:nullPos-1);
    end

    % --- FIX: ensure text types for contains/strfind ---
    chars_txt = string(chars);          % always text
    signature_txt = string(signature);  % always text

    % Detection
    if contains(chars_txt, signature_txt)
        disp('Hidden data detected!');

        % Find signature position
        pos = strfind(chars, signature);
        startIdx = pos(1) + length(signature);

        if startIdx > length(chars)
            disp('Signature found but no message after it.');
            return;
        end

        message = chars(startIdx:end);

        disp('Extracted Message:');
        disp(message);
    else
        disp('No hidden data detected');
    end
end
