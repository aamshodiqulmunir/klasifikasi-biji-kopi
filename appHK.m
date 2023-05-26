function varargout = appHK(varargin)
% APPHK MATLAB code for appHK.fig
%      APPHK, by itself, creates a new APPHK or raises the existing
%      singleton*.
%
%      H = APPHK returns the handle to a new APPHK or the handle to
%      the existing singleton*.
%
%      APPHK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in APPHK.M with the given input arguments.
%
%      APPHK('Property','Value',...) creates a new APPHK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before appHK_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to appHK_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help appHK

% Last Modified by GUIDE v2.5 25-May-2023 17:47:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @appHK_OpeningFcn, ...
                   'gui_OutputFcn',  @appHK_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before appHK is made visible.
function appHK_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to appHK (see VARARGIN)

% Choose default command line output for appHK
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes appHK wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = appHK_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile({'*.*'});

if ~isequal(filename,0)
    Info = imfinfo(fullfile(pathname,filename));
    if Info.BitDepth == 24
        Img = imread(fullfile(pathname,filename));
        axes(handles.axes1)
        cla('reset')
        imshow(Img)
        Img = imcrop(Img,[500 500 500 500]);
        axes(handles.axes2)
        cla('reset')
        imshow(Img)
    else
        msgbox('Citra masukan harus citra RGB');
        return
    end
else
    return
end

handles.Img = Img;
guidata(hObject,handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Img = handles.Img;
cform = makecform('srgb2lab');
lab = applycform(Img,cform);
axes(handles.axes3)
cla('reset')
imshow(lab)

ab = double(lab(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
 
nColors = 2;
[cluster_idx, ~] = kmeans(ab,nColors,'distance','sqEuclidean', ...
    'Replicates',3);
 
pixel_labels = reshape(cluster_idx,nrows,ncols);
RGB = label2rgb(pixel_labels);

segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);
 
for k = 1:nColors
    color = Img;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end



area_cluster1 = sum(find(pixel_labels==1));
area_cluster2 = sum(find(pixel_labels==2));
 
[~,cluster_min] = min([area_cluster1,area_cluster2]);
 
Img_bw = (pixel_labels==cluster_min);
Img_bw = imfill(Img_bw,'holes');
Img_bw = bwareaopen(Img_bw,70);
axes(handles.axes4)
cla('reset')
imshow(Img_bw);

Img_rgb = Img;
Red = Img_rgb(:,:,1);
Green = Img_rgb(:,:,2);
Blue = Img_rgb(:,:,3);
Red(~Img_bw) = 0;
Green(~Img_bw) = 0;
Blue(~Img_bw) = 0;
eRGeBe = cat(3,Red,Green,Blue);
axes(handles.axes5)
cla('reset')
imshow(eRGeBe);


handles.Red = Red;
guidata(hObject,handles);
handles.Green = Green;
guidata(hObject,handles);
handles.Blue = Blue;
guidata(hObject,handles);
handles.Img_bw = Img_bw;
guidata(hObject,handles);





% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Red = handles.Red;
Green = handles.Green;
Blue = handles.Blue;
Img = handles.Img;
img_bw = handles.Img_bw;


Red_CHANNEL = cat(3,Red,Green*0,Blue*0);
axes(handles.axes6)
cla('reset')
imshow(Red_CHANNEL);
Green_CHANNEL = cat(3,Red*0,Green,Blue*0);
axes(handles.axes7)
cla('reset')
imshow(Green_CHANNEL);
Blue_CHANNEL = cat(3,Red*0,Green*0,Blue);
axes(handles.axes8)
cla('reset')
imshow(Blue_CHANNEL);

Img_RGB = rgb2lab(Img);
R = Img_RGB(:,:,1);
G = Img_RGB(:,:,2);
B = Img_RGB(:,:,3);
R(~img_bw) = 0;
G(~img_bw) = 0;
B(~img_bw) = 0;

stats = regionprops(img_bw,'Area',"Perimeter","Eccentricity");
perimeter = [stats.Perimeter];
area = [stats.Area];
Eccentricity = [stats.Eccentricity];
Eccentricity = sum(Eccentricity);
perimeter = sum(perimeter);

area = sum(area);
metric = 4*pi*area/perimeter^2;
Img_gray = rgb2gray(Img);
Img_gray(~img_bw) = 0;

[a,b] = find(img_bw==1);
gray_level = zeros(1,numel(a),1);
R_level = zeros(1,numel(a),1);
G_level = zeros(1,numel(a),1);
B_level = zeros(1,numel(a),1);

for m = 1:numel(a)
        gray_level(m) = Img_gray(a(m),b(m));
        R_level(m) = R(a(m),b(m));
        G_level(m) = G(a(m),b(m));
        B_level(m) = B(a(m),b(m));
end


mean_R_level = mean(R_level);

mean_G_level = mean(G_level);

mean_B_level = mean(B_level);

d = 3;

offset = [0 d; -d d; -d 0; -d -d];
GLCMS = graycomatrix(Img_gray,'Offset',offset);
data = cell(21,5);
data1 = cell(5,2);

stats = GLCMFeatures(GLCMS);
AC      = stats.autoCorrelation                     ; % Autocorrelation: [2] 
CP      = stats.clusterProminence                   ; % Cluster Prominence: [2]
CS      = stats.clusterShade                        ; % Cluster Shade: [2]
CT      = stats.contrast                            ; % Contrast: matlab/[1,2]
CR      = stats.correlation                         ; % Correlation: [1,2]
DE      = stats.differenceEntropy                   ; % Difference entropy [1]
DV      = stats.differenceVariance                  ; % Difference variance [1]
DS      = stats.dissimilarity                       ; % Dissimilarity: [2]
EG      = stats.energy                              ; % Energy: matlab / [1,2]
ET      = stats.entropy                             ; % Entropy: [2]
HM      = stats.homogeneity                         ; % Homogeneity: [2] (inverse difference moment)
IMC1    = stats.informationMeasureOfCorrelation1    ; % Information measure of correlation1 [1]
IMC2    = stats.informationMeasureOfCorrelation2    ; % Informaiton measure of correlation2 [1]
ID      = stats.inverseDifference                   ; % Homogeneity in matlab
IDMN    = stats.inverseDifferenceMomentNormalized   ; % Normalized Homogeneity
IDN     = stats.inverseDifferenceNormalized         ; % Normalized inverse difference
MP      = stats.maximumProbability                  ; % Maximum probability: [2]
SA      = stats.sumAverage                          ; % Sum average [1]    
SE      = stats.sumEntropy                          ; % Sum entropy [1]
SSV     = stats.sumOfSquaresVariance                ; % Sum of sqaures: Variance [1]
SV      = stats.sumVariance                         ; % Sum variance [1]

data{1,1} = 'Auto Correlation';
data{2,1} = 'Cluster Prominence';
data{3,1} = 'Cluster Shade';
data{4,1} = 'Contrast';
data{5,1} = 'Correlation';
data{6,1} = 'Difference Entropy';
data{7,1} = 'Difference Variance';
data{8,1} = 'Dissimilarity';
data{9,1} = 'Energy';
data{10,1} = 'Entropy';
data{11,1} = 'homogeneity';
data{12,1} = 'Information Measure Of Correlation 1';
data{13,1} = 'Information Measure Of Correlation 2';
data{14,1} = 'Inverse Difference';
data{15,1} = 'Inverse Difference Moment Normalized';
data{16,1} = 'Inverse Difference Normalized';
data{17,1} = 'Maximum Probability';
data{18,1} = 'Sum Average';
data{19,1} = 'Sum Entropy';
data{20,1} = 'Sum Of Squares Variance';
data{21,1} = 'Sum Variance';


data{1,2} = num2str(AC(1));
data{2,2} = num2str(CP(1));
data{3,2} = num2str(CS(1));
data{4,2} = num2str(CT(1));
data{5,2} = num2str(CR(1));
data{6,2} = num2str(DE(1));
data{7,2} = num2str(DV(1));
data{8,2} = num2str(DS(1));
data{9,2} = num2str(EG(1));
data{10,2} = num2str(ET(1));
data{11,2} = num2str(HM(1));
data{12,2} = num2str(IMC1(1));
data{13,2} = num2str(IMC2(1));
data{14,2} = num2str(ID(1));
data{15,2} = num2str(IDMN(1));
data{16,2} = num2str(IDN(1));
data{17,2} = num2str(MP(1));
data{18,2} = num2str(SA(1));
data{19,2} = num2str(SE(1));
data{20,2} = num2str(SSV(1));
data{21,2} = num2str(SV(1));

data{1,3} = num2str(AC(2));
data{2,3} = num2str(CP(2));
data{3,3} = num2str(CS(2));
data{4,3} = num2str(CT(2));
data{5,3} = num2str(CR(2));
data{6,3} = num2str(DE(2));
data{7,3} = num2str(DV(2));
data{8,3} = num2str(DS(2));
data{9,3} = num2str(EG(2));
data{10,3} = num2str(ET(2));
data{11,3} = num2str(HM(2));
data{12,3} = num2str(IMC1(2));
data{13,3} = num2str(IMC2(2));
data{14,3} = num2str(ID(2));
data{15,3} = num2str(IDMN(2));
data{16,3} = num2str(IDN(2));
data{17,3} = num2str(MP(2));
data{18,3} = num2str(SA(2));
data{19,3} = num2str(SE(2));
data{20,3} = num2str(SSV(2));
data{21,3} = num2str(SV(2));

data{1,4} = num2str(AC(3));
data{2,4} = num2str(CP(3));
data{3,4} = num2str(CS(3));
data{4,4} = num2str(CT(3));
data{5,4} = num2str(CR(3));
data{6,4} = num2str(DE(3));
data{7,4} = num2str(DV(3));
data{8,4} = num2str(DS(3));
data{9,4} = num2str(EG(3));
data{10,4} = num2str(ET(3));
data{11,4} = num2str(HM(3));
data{12,4} = num2str(IMC1(3));
data{13,4} = num2str(IMC2(3));
data{14,4} = num2str(ID(3));
data{15,4} = num2str(IDMN(3));
data{16,4} = num2str(IDN(3));
data{17,4} = num2str(MP(3));
data{18,4} = num2str(SA(3));
data{19,4} = num2str(SE(3));
data{20,4} = num2str(SSV(3));
data{21,4} = num2str(SV(3));

data{1,5} = num2str(AC(4));
data{2,5} = num2str(CP(4));
data{3,5} = num2str(CS(4));
data{4,5} = num2str(CT(4));
data{5,5} = num2str(CR(4));
data{6,5} = num2str(DE(4));
data{7,5} = num2str(DV(4));
data{8,5} = num2str(DS(4));
data{9,5} = num2str(EG(4));
data{10,5} = num2str(ET(4));
data{11,5} = num2str(HM(4));
data{12,5} = num2str(IMC1(4));
data{13,5} = num2str(IMC2(4));
data{14,5} = num2str(ID(4));
data{15,5} = num2str(IDMN(4));
data{16,5} = num2str(IDN(4));
data{17,5} = num2str(MP(4));
data{18,5} = num2str(SA(4));
data{19,5} = num2str(SE(4));
data{20,5} = num2str(SSV(4));
data{21,5} = num2str(SV(4));

data1{1,1} = 'Mean R';
data1{2,1} = 'Mean G';
data1{3,1} = 'Mean B';
data1{4,1} = 'Eccentricity';
data1{5,1} = 'Parameter';

data1{1,2} = num2str(mean_R_level);
data1{2,2} = num2str(mean_G_level);
data1{3,2} = num2str(mean_B_level);
data1{4,2} = num2str(Eccentricity);
data1{5,2} = num2str(perimeter);

ciri_latih = [mean_R_level,mean_G_level,mean_B_level,Eccentricity,perimeter,AC,CP,CS,CT,CR,DE,DS,DV,EG,ET,HM,IMC1,IMC2,ID,IDMN,IDN,MP,SA,SE,SSV,SV];
    

set(handles.uitable1,'Data',data,'ForegroundColor',[0 0 0])
set(handles.uitable2,'Data',data1,'ForegroundColor',[0 0 0])
handles.data_uji_gabung = ciri_latih;
guidata(hObject,handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load GLCM_LAB_BENTUK_LDA.mat net_LDA_GLCM_Bentuk_LAB

data_uji_gabung = handles.data_uji_gabung;

Output = predict(net_LDA_GLCM_Bentuk_LAB,data_uji_gabung);
if isempty(Output)
    set(handles.edit1,'String','Unknown')
else
    switch Output
        case 1
            Output = 'Berlubang';
        case 2
            Output = 'Hitam Keriput';
        case 3
            Output = 'Pecah';
        case 4
            Output = 'Utuh';
    end
    set(handles.text3,'String',Output)
end
set(handles.text3,'String',Output);
