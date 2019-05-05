%%Project: Edge Detection Comparsion
%%Name: Ruotian Liu
%%Date: 04/22/2017

%%Loading image
%To correctly load the image, please relpace the address of the image inside
%the imread function if the image is not under the same folder as this
%program
testImg = imread('test.png');

%%Function calling
%%checkRGB function determines if the image is RGB
%%if the image is RGB, convert to grayscale
newIMG = checkRGB(testImg);

%%adjusting contrast of the image
adjIMG = imadjust(newIMG);

%%sobel edge detection
sobelIMG = edge(newIMG,'sobel');
%figure, imshow(sobelIMG);
%%canny edge detection
cannyIMG = edge(newIMG,'canny');
%figure, imshow(cannyIMG);

%%since the Fuzzy logic operated on double-precision numbers only in
%%matlab,
%%convert adjusted image to a double array
doubleIMG = im2double(adjIMG);

%%calcualte image gradient on x-axis and y-axis
%%gradients are needed for calculating the breaks in the image
gradientX = [-1 1];
gradientY = gradientX';
IMGx = conv2(doubleIMG,gradientX,'same');
IMGy = conv2(doubleIMG,gradientY,'same');

%%display the gradient along x-axis
%%using default colormap to display the image clear
figure
subplot(1,2,1)
image(IMGx,'CDataMapping','scaled')
colormap default
title('gradient along x-axis')
%%display the gradient along y-axis
subplot(1,2,2)
image(IMGy,'CDataMapping','scaled')
colormap default
title('gradient along y-axis')

%%Fuzzy Logic Image
%%reference to Fuzzy Logic Toolbox in the help section
%%Create new Fuzzy Inference System with newfis function
edgeDetec = newfis('newSystem');
getfis(edgeDetec);
%%add variables into the system with addvar function
edgeDetec = addvar(edgeDetec,'input','IMGx',[-1 1]);
edgeDetec = addvar(edgeDetec,'input','IMGy',[-1 1]);

X = 0.1;
Y = 0.1;
%%add membership functions to the system
edgeDetec = addmf(edgeDetec,'input',1,'zero','gaussmf',[X 0]);
edgeDetec = addmf(edgeDetec,'input',2,'zero','gaussmf',[Y 0]);

edgeDetec = addvar(edgeDetec,'output','IMGout',[0 1]);

%%function configiration
white1 = 0.1;
white2 = 1;
white3 = 1;
black1 = 0;
black2 = 0;
black3 = 0.7;
edgeDetec = addmf(edgeDetec,'output',1,'white','trimf',[white1 white2 white3]);
edgeDetec = addmf(edgeDetec,'output',1,'black','trimf',[black1 black2 black3]);

%%add rules to check if a pixel is in the uniform region
%%yes, make it white pixel; else, make it black
rule1 = 'If IMGx is zero and IMGy is zero then IMGout is white';
rule2 = 'If IMGx is not zero or IMGy is not zero then IMGout is black';
addrule = char(rule1,rule2);
edgeDetec = parsrule(edgeDetec,addrule);
showrule(edgeDetec)

%%apply the edge detector for each row of pixels to evaluate the output
OUTevaluate = zeros(size(doubleIMG));
for temp = 1:size(doubleIMG,1)
    OUTevaluate(temp,:) = evalfis([(IMGx(temp,:));(IMGy(temp,:));]',edgeDetec);
end

%%display images
%%several steps indicated
figure
subplot(3,2,1)
image(doubleIMG,'CDataMapping','scaled')
colormap('gray')
title('Original Grayscale Image after Adjustment')
subplot(3,2,2)
image(OUTevaluate,'CDataMapping','scaled')
colormap('gray')
title('FIS Edge Detection')
subplot(3,2,3)
image(sobelIMG,'CDataMapping','scaled');
colormap('gray');
title('Sobel Filter');
subplot(3,2,4)
image(cannyIMG,'CDataMapping','scaled');
colormap('gray');
title('Canny Filter');

%%our own edge detector
%%create an empty 2D matrix based on the size of original image
[x1,y1,z1] = size(testImg);
t = zeros(x1,y1);

%%locate local maxima(peaks) and record their indexes
[peakValues, indexes] = findpeaks(double(doubleIMG(:)));
tValues = indexes;

%%get size of the indexes
a = size(tValues);

%%find and mark the corresponding position of each peaks in the original image
for i=1 : a
    intPart = fix(tValues(i)/x1);
    remPart = rem(tValues(i),x1);
    x=intPart + 1;
    y=remPart;
    if y == 0
        y = 1;
    end
    t(y,x) = 1;
end

%%first filtering: sobel filter
selfIMG = edge(t,'sobel');
%%second filtering: clean method
examp = bwmorph(t, 'clean',Inf);

%%display results
subplot(3,2,5)
image(t,'CDataMapping','scaled');
colormap('gray');
title('self-built Filter');
subplot(3,2,6)
image(examp,'CDataMapping','scaled');
colormap('gray');
title('self-built after clean filte Filter');

%step images
%figure, imshow(t);
%figure, imshow(selfIMG);
%figure, imshow(examp);

%%function checkRGB
%%it checks if the image is RGB, convert to grayscale and return
%%else return original image
function isRGB = checkRGB(IMG)
    if size(IMG,3) == 3
        isRGB = rgb2gray(IMG);
    end
    if size(IMG,3) < 3
           isRGB = IMG;
    end
end
