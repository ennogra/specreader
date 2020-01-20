function georocking
% Perform geometric correction for rocking scans. Called by specr

hLine = findall(gca,'Type','line');
% --- if no curve plotted, return
if isempty(hLine)
    return;
end


hFigSpecr = findall(0,'Tag','specr_Fig');
settings = getappdata(hFigSpecr,'settings');

% --- figure layout 
p0      = get(hFigSpecr,'position');    % main figure position
p1(3)   = 420;              % p1 is the setting figure position
p1(4)   = 440;
p1(1)   = p0(1)+p0(3)/2-p1(3)/2;
p1(2)   = p0(2)+p0(4)/2-p1(4)/2;
h = figure(...
    'Units','pixels',...
    'MenuBar','none',...
    'Units','pixels',...
    'Name','Geometric Correction for Rocking Scan',...
    'NumberTitle','off',...
    'IntegerHandle','off',...
    'Position',p1,...
    'HandleVisibility','callback',...
    'Tag','figSpecrRocking',...
    'Resize','off',...
    'WindowStyle','modal',...
    'UserData',[]);
instructionStr = {...
    'Instruction:';...
    ['The diffuse scattering intensity is proportional to the actual illumated area. ',...
    'In order to make the rocking scan symmetric, ',...
    'the geometric correction is performed by dividing the scan by two correction factors ',...
    'calculated as follows. Assume a uniform rectangular flux distribution of the primary beam. ',...
    'The footprint angle is th_in0 on the incident side and th_sc0 on the detector side.'];...
    ['  1) The incident side correction factor is '];,...
    ['      f_in = 1,                                               for th_in < th_in0'];...
    ['      f_in = sin(th_in0)/sin(th_in),                for th_in > th_in0'];...
    ['  2) The detector side correction factor is '];...
    ['      f_sc = 1,                                              for th_sc < ascin(sin(th_sc0)/f_in)'];...
    ['      f_sc = sin(th_sc0)/sin(th_sc)/f_in,     for th_sc > ascin(sin(th_sc0)/f_in)'];...
    ['The second correction is not necessary if the detector opening is taken into account as the instrumental resolution function ',...
    'which is convoluted with the differential scattering cross section. ',...
    'To apply the the geometric corrections, the rocking scan has to be performed in an ''hscan''.'];...
    '';...
    ['Reference: J. Daillant and A. Gibaud, X-Ray and Neutron Reflectivity: Principles and Applications, ',...
    'Chapter 4 and 7, Springer (1999)']};
hEdit0 = uicontrol(...
    'Parent',h,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'Enable','inactive',...
    'BackgroundColor',get(h,'Color'),...
    'Position',[10 p1(4)-290 p1(3)-20 280],...
    'String',instructionStr);
panelSize = [10 60 p1(3)-20 p1(4)-350];
hPanel1 = uipanel(...
    'Parent',h,...
    'BackgroundColor',get(h,'Color'),...
    'Title','Geometic Correction Parameters',...
    'Units','pixels',...
    'Position',panelSize);
hText1 = uicontrol(...
    'Parent',hPanel1,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'tag','text_str',...
    'BackgroundColor',get(h,'Color'),...
    'Position',[10 panelSize(4)-35 panelSize(3)*2/3-10 15],...
    'String','Qz at which the scan is performed: (A^{-1})');
hEdit1 = uicontrol(...
    'Parent',hPanel1,...
    'Style','edit',...
    'BackgroundColor','w',...
    'Position',[panelSize(3)*2/3 panelSize(4)-35 panelSize(3)/3-10 20],...
    'String',num2str(settings.qz4Rocking,15),...
    'HorizontalAlignment','left');
hText2 = uicontrol(...
    'Parent',hPanel1,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor',get(h,'Color'),...
    'Position',[10 panelSize(4)-58 panelSize(3)*2/3-10 15],...
    'String','Footprint Angle On the Incident Side: (Degree)');
hEdit2 = uicontrol(...
    'Parent',hPanel1,...
    'Style','edit',...
    'BackgroundColor','w',...
    'Position',[panelSize(3)*2/3 panelSize(4)-58 panelSize(3)/3-10 20],...
    'String',num2str(settings.footprintAngle,15),...
    'HorizontalAlignment','left');
hText3 = uicontrol(...
    'Parent',hPanel1,...
    'Style','text',...
    'HorizontalAlignment','left',...
    'BackgroundColor',get(h,'Color'),...
    'Position',[10 panelSize(4)-81 panelSize(3)*2/3-10 15],...
    'String','Footprint Angle On the Detector Side: (Degree)');
hEdit3 = uicontrol(...
    'Parent',hPanel1,...
    'Style','edit',...
    'BackgroundColor','w',...
    'Enable','off',...
    'tag','figgeorocking_edit3',...
    'Position',[panelSize(3)*2/3 panelSize(4)-81 panelSize(3)/3-30 20],...
    'String',num2str(settings.footprintAngleSC,15),...
    'HorizontalAlignment','left');
hCheckbox3 = uicontrol(...
    'Parent',hPanel1,...
    'Style','checkbox',...
    'Max',1,...
    'Min',0,...
    'createFcn',@checkbox_cbk,...
    'value',settings.georockingSCFlag,...
    'HorizontalAlignment','left',...
    'TooltipString','Enable/Disable Detector Side Correction',...
    'BackgroundColor',get(h,'Color'),...
    'Position',[panelSize(3)-25 panelSize(4)-81 15 15],...
    'callback',@checkbox_cbk,...
    'String','');

hPushbuttonOK = uicontrol(...
    'Parent',h,...
    'Style','pushbutton',...
    'String','Continue',...
    'Position',[p1(3)-180 20 80 25],...
    'callback',{@rocking_OKRequestFcn,hFigSpecr,hEdit1,hEdit2,hEdit3,hCheckbox3});
hPushbuttonCancel = uicontrol(...
    'Parent',h,...
    'Style','pushbutton',...
    'String','Cancel',...
    'Position',[p1(3)-90 20 80 25],...
    'Callback','delete(gcf)');


%=========================================================================
% --- callback function of the checkbox3
%=========================================================================
function checkbox_cbk(hObject,eventdata)
hEdit3 = findobj(gcf,'tag','figgeorocking_edit3');
if get(gcbo,'Value') == 0
    set(hEdit3,'Enable','off');
else
    set(hEdit3,'Enable','on');
end


%=========================================================================
% --- callback function of the OK button
%=========================================================================
function rocking_OKRequestFcn(hObject,eventdata,hFigSpecr,hEdit1,hEdit2,hEdit3,hCheckbox3)
settings = getappdata(hFigSpecr,'settings');
h = gcf;
qz = str2double(get(hEdit1,'string'));
footprintAngle = str2double(get(hEdit2,'string'));
if isnan(qz) | qz <=0
    uiwait(msgbox('Invalid Qz.','Geometirc Correction (Rocking Scan) Error','error','modal'));
    return;
end    
if isnan(footprintAngle) | footprintAngle < 0
    uiwait(msgbox('Invalid footprint angle on the incident side.','Geometirc Correction (Rocking Scan) Error','error','modal'));
    return;
end
settings.qz4Rocking     = qz;
settings.footprintAngle = footprintAngle;
settings.georockingSCFlag = get(hCheckbox3,'Value');
if settings.georockingSCFlag == 1
    footprintAngleSC = str2double(get(hEdit3,'string'));
    if isnan(footprintAngleSC) | footprintAngleSC < 0
        uiwait(msgbox('Invalid footprint angle on the detector side.','Geometirc Correction (Rocking Scan) Error','error','modal'));
        return;
    end
    settings.footprintAngleSC = footprintAngleSC;    
end
setappdata(hFigSpecr,'settings',settings);
settings = getappdata(hFigSpecr,'settings');

% --- incident corrections
footprintAngle = footprintAngle*pi/180;
k    = 2*pi/settings.wavelength;                % wave vector
th0 = asin(qz/2/k);       % th_0 value
hLine = findobj(hFigSpecr,'Type','line');
for iLine = 1:length(hLine)
    % --- get data
    xdata = get(hLine(iLine),'xdata');
    ydata = get(hLine(iLine),'ydata');
    ydataAbsError =  getappdata(hLine(iLine),'ydataError')./ydata';     % absolute error
    f_in    = ones(1,length(xdata));            % initialize incident and scattered
    f_sc    = ones(1,length(xdata));            % correction factors
    % --- convert qx to incident angle th and exit angle
    th_in = th0 + asin(xdata/(2*k*sin(th0)));
    th_sc = 2*th0 - th_in;
    % --- calculate incident correction factors
    cIndex = find(th_in>=footprintAngle);          % correction index
    f_in(cIndex) = sin(footprintAngle)./sin(th_in(cIndex));
    % --- calcuate the scattered correction factors
    if settings.georockingSCFlag == 1
        footprintAngleSC = footprintAngleSC*pi/180;
        cIndex = find(th_sc>=asin(sin(footprintAngleSC)./f_in));
        f_sc(cIndex) = sin(footprintAngleSC)./sin(th_sc(cIndex))./f_in(cIndex);
    end
    ydata = ydata./f_in./f_sc;
    set(hLine(iLine),'YData',ydata);
    setappdata(hLine(iLine),'ydataError',ydataAbsError.*ydata');
end
delete(gcf);