function varargout = core(action, C, varargin)
% CORE - toolbox-free tomato ML pipeline (KNN)
% Usage:
%   core('train', C)
%   core('eval', C, folderPath)
%   core('detect', C, imgPath, showFigure)

if nargin < 2 || isempty(C)
    C = config();
end

action = lower(string(action));

switch action
    case "train"
        core_train(C);
        varargout = {};

    case "eval"
        if isempty(varargin)
            folder = C.valDir;
        else
            folder = varargin{1};
        end
        core_eval(C, folder);
        varargout = {};

    case "detect"
        if isempty(varargin)
            error("detect needs image path");
        end
        imgPath = varargin{1};
        showFigure = false;
        if numel(varargin) >= 2
            showFigure = logical(varargin{2});
        end
        [pred, conf] = core_detect(C, imgPath, showFigure);
        varargout = {pred, conf};

    otherwise
        error("Unknown action: %s", action);
end
end

% ============================================================
function core_train(C)
if ~isfolder(C.trainDir)
    error("Train folder not found: %s", C.trainDir);
end
if ~exist(C.outputsDir,'dir'), mkdir(C.outputsDir); end

fprintf("\nSTEP 1: Building features from Train...\n");
[classes, Xtrain, Ytrain] = buildDataset(C.trainDir, C.imgExts, C.maxPerClass, C.resizeTo);

if isempty(Xtrain)
    error("No training images found. Check train folder and extensions.");
end

% Standardize
mu = mean(Xtrain,1);
sigma = std(Xtrain,0,1);
sigma(sigma < 1e-9) = 1;
Xn = (Xtrain - mu) ./ sigma;

Model = struct();
Model.classes  = classes;
Model.X        = Xn;
Model.Y        = Ytrain;
Model.mu       = mu;
Model.sigma    = sigma;
Model.resizeTo = C.resizeTo;
Model.k        = C.k;
Model.imgExts  = C.imgExts;

save(C.modelFile, "Model");
fprintf("\n✅ Model saved: %s\n", C.modelFile);
end

% ============================================================
function core_eval(C, rootDir)
Model = loadModel(C);

if ~isfolder(rootDir)
    error("Validation folder not found: %s", rootDir);
end

d = dir(rootDir);
names = {d.name};
sub = d([d.isdir] & ~ismember(names,{'.','..'}));

if isempty(sub)
    error("No class subfolders in: %s", rootDir);
end

total = 0; correct = 0;

for i = 1:numel(sub)
    trueClass = string(sub(i).name);
    classDir = fullfile(rootDir, sub(i).name);

    files = dir(fullfile(classDir, "*.*"));
    files = files(~[files.isdir]);

    keep = false(size(files));
    for j = 1:numel(files)
        [~,~,ext] = fileparts(files(j).name);
        keep(j) = any(strcmpi(ext, Model.imgExts));
    end
    files = files(keep);

    fprintf("\nClass: %s (%d images)\n", trueClass, numel(files));

    for j = 1:numel(files)
        imgPath = fullfile(classDir, files(j).name);
        try
            pred = core_detect(C, imgPath, false);
            total = total + 1;
            if string(pred) == trueClass
                correct = correct + 1;
            end
        catch
            % skip unreadable image
        end
    end
end

acc = 100 * (correct / max(total,1));
fprintf("\n============================\n");
fprintf("✅ Validation Accuracy: %.2f%% (%d / %d)\n", acc, correct, total);
fprintf("============================\n");
end

% ============================================================
function [predLabel, confidence] = core_detect(C, imgPath, showFigure)
Model = loadModel(C);

imgPath = char(string(imgPath));
if ~isfile(imgPath)
    error("Image not found: %s", imgPath);
end

feat = extractFeatures_toolboxFree(imgPath, Model.resizeTo);
x = (feat - Model.mu) ./ Model.sigma;

[predLabel, confidence] = knnWeighted(Model.X, Model.Y, x, Model.k);

fprintf("\nImage: %s\n", imgPath);
fprintf("Prediction: %s | Confidence: %.2f\n", string(predLabel), confidence);

if showFigure
    try
        figure; imshow(imread(imgPath));
        title("Prediction: " + string(predLabel) + " | Conf: " + num2str(confidence,'%.2f'), 'Interpreter','none');
    catch
    end
end
end

% ============================================================
function Model = loadModel(C)
if ~isfile(C.modelFile)
    error("Model not found. Train first. Expected: %s", C.modelFile);
end
S = load(C.modelFile, "Model");
Model = S.Model;
end

% ============================================================
function [classes, X, Y] = buildDataset(rootDir, imgExts, maxPerClass, resizeTo)
d = dir(rootDir);
names = {d.name};
sub = d([d.isdir] & ~ismember(names,{'.','..'}));

if isempty(sub)
    error("No class subfolders found in: %s", rootDir);
end

classes = string({sub.name});
X = [];
Y = categorical();

for i = 1:numel(sub)
    className = sub(i).name;
    classDir = fullfile(rootDir, className);

    files = dir(fullfile(classDir, "*.*"));
    files = files(~[files.isdir]);

    keep = false(size(files));
    for j = 1:numel(files)
        [~,~,ext] = fileparts(files(j).name);
        keep(j) = any(strcmpi(ext, imgExts));
    end
    files = files(keep);

    if isempty(files)
        fprintf("Class: %-45s -> 0 images (skipped)\n", className);
        continue;
    end

    n = min(maxPerClass, numel(files));
    idx = randperm(numel(files), n);
    fprintf("Class: %-45s -> using %d/%d images\n", className, n, numel(files));

    for t = 1:n
        fp = fullfile(classDir, files(idx(t)).name);
        feat = extractFeatures_toolboxFree(fp, resizeTo);
        X = [X; feat]; %#ok<AGROW>
        Y = [Y; categorical({className})]; %#ok<AGROW>
    end
end
end

% ============================================================
function feat = extractFeatures_toolboxFree(imgPath, resizeTo)
I = imread(imgPath);

% ensure RGB
if ndims(I) == 2
    I = repmat(I,[1 1 3]);
elseif size(I,3) == 4
    I = I(:,:,1:3);
end

% to double [0,1] without im2uint8
I = double(I);
if max(I(:)) > 1.5
    I = I / 255;
end
I = min(max(I,0),1);

% resize without imresize
I = resizeBilinear(I, resizeTo(1), resizeTo(2));

% HSV (base MATLAB)
hsvI = rgb2hsv(I);
H = hsvI(:,:,1); S = hsvI(:,:,2); V = hsvI(:,:,3);

% color hist
hH = hist01(H, 16);
hS = hist01(S, 8);
hV = hist01(V, 8);

% edge mag
G  = sobelMag(V);
hG = hist01(min(G,1), 16);

% local var texture
Tv = localVar3x3(V);
hT = hist01(min(Tv,1), 16);

stats = [mean(H(:)) std(H(:)) mean(S(:)) std(S(:)) mean(V(:)) std(V(:))];

feat = [hH, hS, hV, hG, hT, stats];
feat(~isfinite(feat)) = 0;
end

% ================== helpers (toolbox-free) ==================
function out = resizeBilinear(I, outH, outW)
[h,w,c] = size(I);
ys = linspace(1, h, outH);
xs = linspace(1, w, outW);
[Xq,Yq] = meshgrid(xs, ys);

x1 = floor(Xq); x2 = min(x1+1, w);
y1 = floor(Yq); y2 = min(y1+1, h);

wx = Xq - x1;
wy = Yq - y1;

out = zeros(outH, outW, c);
for ch = 1:c
    F = I(:,:,ch);
    Ia = F(sub2ind([h,w], y1, x1));
    Ib = F(sub2ind([h,w], y1, x2));
    Ic = F(sub2ind([h,w], y2, x1));
    Id = F(sub2ind([h,w], y2, x2));
    out(:,:,ch) = (1-wx).*(1-wy).*Ia + wx.*(1-wy).*Ib + (1-wx).*wy.*Ic + wx.*wy.*Id;
end
out = min(max(out,0),1);
end

function h = hist01(A, nbins)
A = min(max(A,0),1);
edges = linspace(0,1,nbins+1);
h = zeros(1,nbins);
for i=1:nbins
    if i < nbins
        h(i) = sum(A(:) >= edges(i) & A(:) < edges(i+1));
    else
        h(i) = sum(A(:) >= edges(i) & A(:) <= edges(i+1));
    end
end
h = h / max(sum(h),1);
end

function G = sobelMag(I)
Kx = [1 0 -1; 2 0 -2; 1 0 -1] / 4;
Ky = Kx';
Ix = conv2(I, Kx, 'same');
Iy = conv2(I, Ky, 'same');
G = sqrt(Ix.^2 + Iy.^2);
end

function Vv = localVar3x3(V)
K = ones(3,3)/9;
m1 = conv2(V, K, 'same');
m2 = conv2(V.^2, K, 'same');
Vv = max(m2 - m1.^2, 0);
end

function [pred, conf] = knnWeighted(X, Y, x, k)
d = sqrt(sum((X - x).^2, 2));
[ds, idx] = sort(d, 'ascend');
k = min(k, numel(idx));
idx = idx(1:k);
ds  = ds(1:k);

labels = Y(idx);
w = 1 ./ max(ds, 1e-9);

cats = categories(Y);
score = zeros(numel(cats),1);

for i = 1:numel(labels)
    ci = find(strcmp(cats, char(labels(i))));
    score(ci) = score(ci) + w(i);
end

[best, bi] = max(score);
pred = categorical(cats(bi), cats);
conf = best / max(sum(score), 1e-9);
end
