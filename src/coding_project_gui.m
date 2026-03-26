function projet_codage
f = figure( ...
    'Name','Projet Codage', ...
    'Color','white', ...
    'MenuBar','none', ...
    'ToolBar','none', ...
    'Units','normalized', ...
    'Position',[0.2 0.1 0.6 0.75]);
fenetre_accueil(f);
end

% =========================================================
function fenetre_accueil(f)
clf(f);
set(f,'Color','white','Name','Projet Codage');

ax = axes(f,'Units','normalized','Position',[0 0.65 1 0.35]);
imshow(imread('assets/img.png'),'Parent',ax);
axis off

uicontrol(f,'Style','text','Units','normalized', ...
    'Position',[0.3 0.58 0.4 0.05], ...
    'String','Projet de codage - Adam', ...
    'BackgroundColor','white', ...
    'FontSize',18,'FontWeight','bold');

% ================= TEXTE =================
panelTexte = uipanel(f,'Units','normalized', ...
    'Position',[0.05 0.1 0.4 0.35], ...
    'BackgroundColor',[1 0.8 0.6],'BorderType','none');

uicontrol(panelTexte,'Style','text','Units','normalized', ...
    'Position',[0.1 0.6 0.8 0.2], ...
    'String','Voulez-vous coder un texte ?', ...
    'BackgroundColor',[1 0.8 0.6], ...
    'FontSize',13,'FontWeight','bold');

uicontrol(panelTexte,'Style','pushbutton','Units','normalized', ...
    'Position',[0.15 0.25 0.25 0.15], ...
    'String','Oui','FontSize',11, ...
    'BackgroundColor',[0.2 0.4 1],'ForegroundColor','white', ...
    'Callback',@(s,e) fenetre_codage_texte(f));

uicontrol(panelTexte,'Style','pushbutton','Units','normalized', ...
    'Position',[0.6 0.25 0.25 0.15], ...
    'String','Non','FontSize',11, ...
    'BackgroundColor',[0.6 0.6 0.6],'ForegroundColor','white');

% ================= IMAGE =================
panelImage = uipanel(f,'Units','normalized', ...
    'Position',[0.55 0.1 0.4 0.35], ...
    'BackgroundColor',[1 0.7 0.7],'BorderType','none');

uicontrol(panelImage,'Style','text','Units','normalized', ...
    'Position',[0.1 0.6 0.8 0.2], ...
    'String','Voulez-vous coder une image ?', ...
    'BackgroundColor',[1 0.7 0.7], ...
    'FontSize',13,'FontWeight','bold');

uicontrol(panelImage,'Style','pushbutton','Units','normalized', ...
    'Position',[0.15 0.25 0.25 0.15], ...
    'String','Oui','FontSize',11, ...
    'BackgroundColor',[0.2 0.4 1],'ForegroundColor','white', ...
    'Callback',@(s,e) fenetre_codage_image(f));

uicontrol(panelImage,'Style','pushbutton','Units','normalized', ...
    'Position',[0.6 0.25 0.25 0.15], ...
    'String','Non','FontSize',11, ...
    'BackgroundColor',[0.6 0.6 0.6],'ForegroundColor','white');
end

% =========================================================
function fenetre_codage_texte(f)
clf(f);
set(f,'Color',[1 0.85 0.7],'Name','Codage de Texte');

uicontrol(f,'Style','text','Units','normalized', ...
    'Position',[0.05 0.88 0.9 0.08], ...
    'String','CODAGE DE TEXTE', ...
    'BackgroundColor',[1 0.85 0.7], ...
    'FontSize',18,'FontWeight','bold');

zoneTexte = uicontrol(f,'Style','edit','Units','normalized', ...
    'Position',[0.05 0.6 0.65 0.2], ...
    'Max',10,'FontSize',12);

ax = axes(f,'Units','normalized','Position',[0.1 0.25 0.8 0.25]);

res = uicontrol(f,'Style','text','Units','normalized', ...
    'Position',[0.05 0.15 0.9 0.06], ...
    'BackgroundColor',[1 0.85 0.7], ...
    'FontSize',13,'FontWeight','bold');

uicontrol(f,'Style','pushbutton','Units','normalized', ...
    'Position',[0.75 0.63 0.2 0.1], ...
    'String','Codage', ...
    'FontSize',12, ...
    'BackgroundColor',[0.2 0.4 1], ...
    'ForegroundColor','white', ...
    'Callback',@(s,e) coder_texte(zoneTexte,ax,res));

uicontrol(f,'Style','pushbutton','Units','normalized', ...
    'Position',[0.4 0.05 0.2 0.07], ...
    'String','Retour', ...
    'FontSize',11, ...
    'BackgroundColor',[0.2 0.4 1],'ForegroundColor','white', ...
    'Callback',@(s,e) fenetre_accueil(f));
end

% =========================================================
function coder_texte(zoneTexte,ax,res)
txt = zoneTexte.String;
if isempty(txt)
    res.String = 'Veuillez saisir un texte.';
    cla(ax);
    return;
end

% -------- Original --------
n_original = length(txt) * 8;

% -------- Statistiques --------
chars = unique(txt);
freq = histc(txt, chars);
freq = freq / sum(freq);
H = -sum(freq .* log2(freq));

% -------- Huffman --------
L_huffman = H + 1;
n_huffman = ceil(L_huffman * length(txt));

% -------- Shannon-Fano --------
L_sf = H + 1.5;
n_sf = ceil(L_sf * length(txt));

% -------- LZ77 / LZW --------
redundance = 1 - H / log2(length(chars));
redundance = max(0, min(redundance,1));

n_lz  = ceil(n_original * (0.7 - 0.4*redundance));
n_lzw = ceil(n_original * (0.6 - 0.4*redundance));

% -------- Taux --------
n_vals = [n_huffman n_sf n_lz n_lzw];
taux = 1 - n_vals / n_original;
taux = max(0, min(taux,1));

noms = {'Huffman','Shannon-Fano','LZ','LZW'};

bar(ax,taux);
ylim(ax,[0 1]);
set(ax,'XTickLabel',noms);
ylabel(ax,'Taux de compression');
grid on

for k=1:length(taux)
    text(k,taux(k),sprintf('%.1f %%',taux(k)*100), ...
        'HorizontalAlignment','center','FontWeight','bold');
end

[~,i] = max(taux);
res.String = ['Meilleur algorithme : ' noms{i}];
end

% =========================================================
function fenetre_codage_image(f)
clf(f);
set(f,'Color',[1 0.7 0.7],'Name','Codage des Images');

uicontrol(f,'Style','text','Units','normalized', ...
    'Position',[0.05 0.88 0.9 0.08], ...
    'String','CODAGE DES IMAGES', ...
    'BackgroundColor',[1 0.7 0.7], ...
    'FontSize',18,'FontWeight','bold');

panel = uipanel(f,'Units','normalized', ...
    'Position',[0.1 0.35 0.8 0.45],'BackgroundColor','white');

txt = uicontrol(panel,'Style','text','Units','normalized', ...
    'Position',[0.3 0.45 0.4 0.1], ...
    'String','Cliquez pour charger une image', ...
    'FontSize',14,'FontWeight','bold','BackgroundColor','white');

ax = axes(panel,'Units','normalized','Position',[0.05 0.05 0.9 0.9]);
axis off

set(panel,'UserData',struct('ax',ax,'txt',txt));
set(panel,'ButtonDownFcn',@(s,e) charger_image(panel));

uicontrol(f,'Style','pushbutton','Units','normalized', ...
    'Position',[0.4 0.25 0.2 0.07], ...
    'String','Lecture','FontSize',12, ...
    'BackgroundColor',[0.2 0.4 1],'ForegroundColor','white', ...
    'Callback',@(s,e) lecture_image(panel));

uicontrol(f,'Style','pushbutton','Units','normalized', ...
    'Position',[0.7 0.05 0.2 0.07], ...
    'String','Retour','FontSize',11, ...
    'BackgroundColor',[0.2 0.4 1],'ForegroundColor','white', ...
    'Callback',@(s,e) fenetre_accueil(f));
end

% =========================================================
function charger_image(panel)
data = get(panel,'UserData');
ax = data.ax;
txt = data.txt;

[file,path] = uigetfile({'*.jpg;*.png;*.bmp'});
if file==0, return; end

img = imread(fullfile(path,file));
if size(img,3)==3
    img = rgb2gray(img);
end
img = double(img);

imshow(img,[],'Parent',ax);
axis image off
set(txt,'Visible','off');

set(panel,'UserData',struct('img',img));
end

% =========================================================
function lecture_image(panel)
data = get(panel,'UserData');
M = data.img;

V = reshape(M,1,[]);
H = reshape(M.',1,[]);
Z = zigzag(M);

lv = max(diff(find([1 V~=0 1])));
lh = max(diff(find([1 H~=0 1])));
lz = max(diff(find([1 Z~=0 1])));

figure('Name','Suites de zéros');
bar([lv lh lz]);
set(gca,'XTickLabel',{'Verticale','Horizontale','Zigzag'});
ylabel('Longueur max');
grid on
end

% =========================================================
function Z = zigzag(M)
n = size(M,1); Z = [];
for s = 1:2*n-1
    if mod(s,2)==0
        i = max(1,s-n):min(n,s-1);
    else
        i = min(n,s-1):-1:max(1,s-n);
    end
    for k=i
        Z(end+1) = M(k,s-k);
    end
end
end
