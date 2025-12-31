function C = config()
C = struct();

% ===== Dataset paths (EDIT THESE) =====
C.trainDir = 'C:\Users\farah\Downloads\archive\tomato\train';
C.valDir   = 'C:\Users\farah\Downloads\archive\tomato\val';
C.testDir  = 'C:\Users\farah\Downloads\archive\tomato\test'; % optional

% ===== Feature + model settings =====
C.imgExts     = {'.jpg','.jpeg','.png','.bmp'};
C.maxPerClass = 500;
C.resizeTo    = [128 128];
C.k           = 7; % KNN neighbors

% ===== Outputs =====
C.projectRoot = fileparts(mfilename('fullpath'));
C.outputsDir  = fullfile(C.projectRoot, 'outputs');
C.modelFile   = fullfile(C.outputsDir, 'Model.mat');

% ===== LSB outputs =====
C.stegoOutFile = fullfile(C.outputsDir, 'stego_image.png'); % ALWAYS png output
end
