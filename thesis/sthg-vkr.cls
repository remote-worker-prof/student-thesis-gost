\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sthg-vkr}[2026/05/20 v0.1 Student VKR template (GOST + RGPU profile)]

% Базовая проверка движка: шаблон рассчитан на LuaLaTeX.
\RequirePackage{iftex}
\ifluatex\else
  \ClassError{sthg-vkr}{This template requires LuaLaTeX}{Run with lualatex.}
\fi

% Публичные параметры класса.
% degree: bachelor|specialist
% profile: пока поддерживается только rgpu-herzen
% language: ru
\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=sthg,prefix=sthg@}
\DeclareStringOption[bachelor]{degree}
\DeclareStringOption[rgpu-herzen]{profile}
\DeclareStringOption[ru]{language}
\ProcessKeyvalOptions*

% Используем extreport 14pt как базу оформления.
\LoadClass[14pt,a4paper,oneside]{extreport}

% Пакеты макета, типографики и библиографии.
\RequirePackage{etoolbox}
\RequirePackage{geometry}
\RequirePackage{setspace}
\RequirePackage{indentfirst}
\RequirePackage{polyglossia}
\RequirePackage{fontspec}
\RequirePackage{amsmath}
\RequirePackage{unicode-math}
\RequirePackage{microtype}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{tikz}
\RequirePackage{pgfplots}
\RequirePackage{booktabs}
\RequirePackage{array}
\RequirePackage{titlesec}
\RequirePackage{tocloft}
\RequirePackage[labelsep=period]{caption}
\RequirePackage{fancyhdr}
\RequirePackage{listings}
\RequirePackage{csquotes}
\RequirePackage[hidelinks,pdflang={ru-RU}]{hyperref}
% URL-гиперссылки (в т.ч. в библиографии) набираем тем же шрифтом, что и текст.
\urlstyle{same}
\RequirePackage[
  backend=biber,
  style=gost-numeric,
  sorting=none,
  language=auto,
  autolang=other,
  bibencoding=utf8,
  maxbibnames=99,
  maxcitenames=2,
  isbn=true,
  url=true,
  doi=true
]{biblatex}

% Библиотеки TikZ/PGFPlots для встроенных диаграмм в тексте диплома.
\usetikzlibrary{
  arrows.meta,
  calc,
  fit,
  positioning,
  shapes.geometric,
  shapes.misc
}
\pgfplotsset{compat=1.18}

\edef\sthg@profileexpanded{\sthg@profile}
\edef\sthg@languageexpanded{\sthg@language}
\edef\sthg@degreeexpanded{\sthg@degree}
\newcommand{\VkrDegree}{\sthg@degreeexpanded}

% Валидация публичных параметров.
\ifdefstring{\sthg@profileexpanded}{rgpu-herzen}{}{%
  \ClassError{sthg-vkr}{Unsupported profile '\sthg@profile'}{Only profile=rgpu-herzen is currently supported.}%
}
\ifdefstring{\sthg@languageexpanded}{ru}{}{%
  \ClassError{sthg-vkr}{Unsupported language '\sthg@language'}{Only language=ru is currently supported.}%
}
\ifdefstring{\sthg@degreeexpanded}{bachelor}{}{%
  \ifdefstring{\sthg@degreeexpanded}{specialist}{}{%
  \ClassError{sthg-vkr}{Unsupported degree '\sthg@degree'}{Use degree=bachelor or degree=specialist.}%
  }%
}

% Базовые параметры страницы и абзацев по профилю шаблона.
\geometry{left=30mm,right=15mm,top=20mm,bottom=20mm,headheight=0pt,headsep=0pt,footskip=12mm}
\setstretch{1.5}
\setlength{\parindent}{1.25cm}
\setlength{\parskip}{0pt}
\setlength{\emergencystretch}{2em}

\setmainlanguage{russian}
\setotherlanguage{english}
\defaultfontfeatures{Ligatures=TeX}

% Strict-local политика шрифтов:
% сборка должна использовать только шрифты из репозитория.
\newcommand{\sthg@requirefontfile}[1]{%
  \IfFileExists{#1}{}{%
    \ClassError{sthg-vkr}{Missing required local font file '#1'}{%
      This template uses strict-local bundled fonts only. Ensure required files exist in the repository under fonts/.%
    }%
  }%
}

\sthg@requirefontfile{fonts/paratype/pt-astra-serif_regular.ttf}
\sthg@requirefontfile{fonts/paratype/pt-astra-serif_bold.ttf}
\sthg@requirefontfile{fonts/paratype/pt-astra-serif_italic.ttf}
\sthg@requirefontfile{fonts/paratype/pt-astra-serif_bold-italic.ttf}
\sthg@requirefontfile{fonts/paratype/pt-astra-sans_regular.ttf}
\sthg@requirefontfile{fonts/paratype/pt-astra-sans_bold.ttf}
\sthg@requirefontfile{fonts/paratype/pt-astra-sans_italic.ttf}
\sthg@requirefontfile{fonts/paratype/pt-astra-sans_bold-italic.ttf}
\sthg@requirefontfile{fonts/firacode/FiraCode-Regular.ttf}
\sthg@requirefontfile{fonts/firacode/FiraCode-Bold.ttf}
\sthg@requirefontfile{fonts/stix/STIXTwoMath-Regular.otf}

% Основной текст диплома: PT Astra Serif.
\setmainfont{pt-astra-serif_regular.ttf}[
  Path=fonts/paratype/,
  BoldFont=pt-astra-serif_bold.ttf,
  ItalicFont=pt-astra-serif_italic.ttf,
  BoldItalicFont=pt-astra-serif_bold-italic.ttf
]

% Дополнительная sans-family (по требованию вуза/кафедры можно использовать точечно).
\setsansfont{pt-astra-sans_regular.ttf}[
  Path=fonts/paratype/,
  BoldFont=pt-astra-sans_bold.ttf,
  ItalicFont=pt-astra-sans_italic.ttf,
  BoldItalicFont=pt-astra-sans_bold-italic.ttf
]

\newfontfamily\ParatypeSans{pt-astra-sans_regular.ttf}[
  Path=fonts/paratype/,
  BoldFont=pt-astra-sans_bold.ttf,
  ItalicFont=pt-astra-sans_italic.ttf,
  BoldItalicFont=pt-astra-sans_bold-italic.ttf
]

% Листинги кода: Fira Code.
\setmonofont{FiraCode-Regular.ttf}[
  Path=fonts/firacode/,
  BoldFont=FiraCode-Bold.ttf,
  Scale=MatchLowercase
]

% Формулы: STIX Two Math.
\setmathfont{STIXTwoMath-Regular.otf}[Path=fonts/stix/]
\numberwithin{equation}{chapter}

% Нумерация страницы внизу по центру.
\pagestyle{fancy}
\fancyhf{}
\fancyfoot[C]{\thepage}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}

% В caption по умолчанию есть endash, но для русского шаблона удобнее явный emdash.
\DeclareCaptionLabelSeparator{emdash}{\space\textemdash\space}
% Все подписи (рисунки/таблицы/листинги) набираем тем же кеглем, что основной текст.
\captionsetup{font={normalsize,rm},labelfont={rm},textfont={rm},justification=centering}
% По ГОСТ наименование таблицы размещают над таблицей и выравнивают влево.
\captionsetup[table]{position=top,labelsep=emdash,justification=raggedright,singlelinecheck=false}
\captionsetup[figure]{position=bottom,labelsep=emdash}
% Подписи листингов держим в том же типографическом режиме, что figure/table.
\captionsetup[lstlisting]{font={normalsize,rm},labelfont={rm},textfont={rm},justification=centering,labelsep=emdash}
\AtBeginDocument{%
  % Polyglossia/Babel могут повторно выставлять "Рис." для русской локали.
  % Фиксируем полное имя подписи рисунка и для текущего документа, и для
  % локализованных caption-переключателей.
  \renewcommand{\figurename}{Рисунок}%
  \ifcsdef{captionsrussian}{%
    \gappto\captionsrussian{\renewcommand{\figurename}{Рисунок}}%
  }{}%
}
\renewcommand{\lstlistingname}{Листинг}
\renewcommand{\lstlistlistingname}{Список листингов}

% Языковые определения для листингов.
% Rust/Kotlin задаем явно, чтобы было стабильное подсвечивание.
\lstdefinelanguage{Rust}{
  sensitive=true,
  morekeywords={
    as,break,const,continue,crate,else,enum,extern,false,fn,for,if,impl,in,let,loop,
    match,mod,move,mut,pub,ref,return,self,Self,static,struct,super,trait,true,type,
    unsafe,use,where,while,async,await,dyn
  },
  morecomment=[l]{//},
  morecomment=[s]{/*}{*/},
  morestring=[b]"
}

\lstdefinelanguage{Kotlin}{
  sensitive=true,
  morekeywords={
    as,break,class,continue,do,else,false,for,fun,if,in,interface,is,null,object,
    package,return,super,this,throw,true,try,typealias,val,var,when,while,by,companion,
    data,enum,import,init,open,operator,out,override,private,protected,public,sealed,suspend
  },
  morecomment=[l]{//},
  morecomment=[s]{/*}{*/},
  morestring=[b]"
}

% Базовый стиль листингов и производные стили по языкам.
\lstdefinestyle{sthgcode-base}{
  basicstyle=\ttfamily\small,
  numbers=left,
  numberstyle=\tiny,
  stepnumber=1,
  numbersep=7pt,
  frame=single,
  framerule=0.4pt,
  breaklines=true,
  tabsize=2,
  captionpos=b,
  showstringspaces=false,
  keywordstyle=\bfseries\color{blue!50!black},
  commentstyle=\itshape\color{green!30!black},
  stringstyle=\color{red!45!black}
}
\lstdefinestyle{sthgcode-python}{style=sthgcode-base,language=Python}
\lstdefinestyle{sthgcode-c}{style=sthgcode-base,language=C}
\lstdefinestyle{sthgcode-rust}{style=sthgcode-base,language=Rust}
\lstdefinestyle{sthgcode-java}{style=sthgcode-base,language=Java}
\lstdefinestyle{sthgcode-kotlin}{style=sthgcode-base,language=Kotlin}
% По умолчанию листинги считаем Python-кодом.
\lstset{style=sthgcode-python}

% Оформление заголовков и оглавления.
\titleformat{\chapter}[block]{\bfseries\centering}{Глава \thechapter.}{0.75em}{}
\titlespacing*{\chapter}{0pt}{0pt}{12pt}
\titleformat{\section}[block]{\bfseries}{\thesection}{0.75em}{}
\titlespacing*{\section}{\parindent}{12pt}{6pt}
\titleformat{\subsection}[block]{\bfseries}{\thesubsection}{0.75em}{}
\titlespacing*{\subsection}{\parindent}{10pt}{4pt}

\renewcommand{\contentsname}{Оглавление}
\setcounter{tocdepth}{2}
\setcounter{secnumdepth}{3}
\renewcommand{\cftchapfont}{\normalfont}
\renewcommand{\cftchappagefont}{\normalfont}
\renewcommand{\cftchapleader}{\cftdotfill{\cftdotsep}}
\renewcommand{\cftchappresnum}{Глава~}
\renewcommand{\cftchapaftersnum}{.\ }
\settowidth{\cftchapnumwidth}{Глава 10.\ }
\renewcommand{\cftdotsep}{1}

% После \appendix включаем отдельный режим заголовков и оглавления приложений.
% Формат на странице: "Приложение А" + на следующей строке название.
% Формат в оглавлении: "Приложение А --- Название".
\newcommand{\sthg@setupappendixheading}{%
  \titleformat{\chapter}[block]{\bfseries\centering}{\appendixname~\thechapter}{0pt}{\\[0.3\baselineskip]}%
  \titlespacing*{\chapter}{0pt}{0pt}{12pt}%
}
\newcommand{\sthg@setuptocforappendix}{%
  \addtocontents{toc}{\protect\renewcommand{\protect\cftchappresnum}{\appendixname~}}%
  \addtocontents{toc}{\protect\renewcommand{\protect\cftchapaftersnum}{\space---\space}}%
  \addtocontents{toc}{\protect\settowidth{\protect\cftchapnumwidth}{\appendixname~Я\space---\space}}%
}
\let\sthg@origappendix\appendix
\renewcommand{\appendix}{%
  \sthg@origappendix
  \renewcommand{\thechapter}{\Asbuk{chapter}}%
  \sthg@setupappendixheading
  \sthg@setuptocforappendix
}

% Дефолтные метаданные титула.
% Практически всегда переопределяются в config/metadata.tex.
\providecommand{\VkrMinistry}{МИНИСТЕРСТВО ПРОСВЕЩЕНИЯ РОССИЙСКОЙ ФЕДЕРАЦИИ}
\providecommand{\VkrUniversity}{ФЕДЕРАЛЬНОЕ ГОСУДАРСТВЕННОЕ БЮДЖЕТНОЕ ОБРАЗОВАТЕЛЬНОЕ УЧРЕЖДЕНИЕ ВЫСШЕГО ОБРАЗОВАНИЯ\\«РОССИЙСКИЙ ГОСУДАРСТВЕННЫЙ\\ПЕДАГОГИЧЕСКИЙ УНИВЕРСИТЕТ им.~А.~И.~ГЕРЦЕНА»}
\providecommand{\VkrDirectionCode}{09.03.01}
\providecommand{\VkrDirectionName}{Информатика и вычислительная техника}
\providecommand{\VkrProfileName}{Технологии разработки программного обеспечения}
\providecommand{\VkrWorkKind}{%
  \ifdefstring{\sthg@degreeexpanded}{specialist}{%
    Выпускная квалификационная работа специалиста%
  }{%
    Выпускная квалификационная работа%
  }%
}
\providecommand{\VkrTheme}{Разработка адаптивной системы обучения с использованием алгоритмов машинного обучения для персонализации учебного процесса}
\providecommand{\VkrStudentCourse}{4}
\providecommand{\VkrStudyForm}{очной}
\providecommand{\VkrStudentName}{Клементьева Алексея Александровича}
% Должность руководителя по умолчанию задается со строчной буквы
% (после двоеточия в блоке титула).
\providecommand{\VkrSupervisorPost}{кандидат физико-математических наук, доцент, доцент кафедры ИТиЭО}
\providecommand{\VkrSupervisorName}{Власов Дмитрий Викторович}
\providecommand{\VkrCity}{Санкт-Петербург}
\providecommand{\VkrYear}{2026}
\providecommand{\VkrLogoPath}{assets/logo-rgpu-herzen.png}
\providecommand{\VkrRightBlockWidth}{95mm}
% Тонкая настройка: отступ перед правым блоком (студент + руководитель).
% Немного увеличен для более гармоничной вертикальной композиции титула.
\providecommand{\VkrRightBlockTopSkip}{1.25\baselineskip}
\providecommand{\VkrLogoWidth}{34mm}
\providecommand{\VkrThemeWidth}{0.9\textwidth}
% Метаданные PDF (можно переопределить в config/metadata.tex).
\providecommand{\VkrPdfTitle}{\VkrWorkKind}
\providecommand{\VkrPdfAuthor}{\VkrStudentName}
\providecommand{\VkrPdfSubject}{\VkrDirectionCode\space\VkrDirectionName}
\providecommand{\VkrPdfKeywords}{ВКР, ГОСТ, LuaLaTeX}
\providecommand{\VkrPdfCreator}{sthg-vkr class}

\AtBeginDocument{%
  \hypersetup{%
    pdftitle={\VkrPdfTitle},
    pdfauthor={\VkrPdfAuthor},
    pdfsubject={\VkrPdfSubject},
    pdfkeywords={\VkrPdfKeywords},
    pdfcreator={\VkrPdfCreator}
  }%
}

% Служебная команда для ненумеруемых глав (введение/заключение).
\newcommand{\VkrUnnumberedChapter}[1]{
  \chapter*{#1}
  \addcontentsline{toc}{chapter}{#1}
}

% Титульный лист.
% Геометрия ориентирована на эталонный DOCX и проверяется отдельным скриптом.
\newcommand{\makesthgtitle}{%
  \begin{titlepage}
    \thispagestyle{empty}
    \begingroup
    \setstretch{1}
      \begin{center}
        {\normalsize \MakeUppercase{\VkrMinistry}\par}
        \vspace{0.2\baselineskip}
        {\normalsize \MakeUppercase{\VkrUniversity}\par}
        \vspace{0.35\baselineskip}
        \IfFileExists{\VkrLogoPath}{\includegraphics[width=\VkrLogoWidth]{\VkrLogoPath}\par}{\vspace{30mm}}
        \vspace{0.35\baselineskip}
        {\normalsize Направление подготовки\par}
        {\normalsize \VkrDirectionCode\ \VkrDirectionName\par}
        \vspace{0.15\baselineskip}
        {\normalsize Направленность (профиль)\par}
        {\normalsize «\VkrProfileName»\par}
        \vspace{0.45\baselineskip}
        {\large\bfseries \VkrWorkKind\par}
        \vspace{0.35\baselineskip}
        {\normalsize\parbox{\VkrThemeWidth}{\centering \VkrTheme}\par}
      \end{center}

      \vspace{\VkrRightBlockTopSkip}

      \noindent\hfill
      \begin{minipage}[t]{\VkrRightBlockWidth}
        \raggedright
        Обучающегося \underline{\hspace{1.2em}\VkrStudentCourse\hspace{1.2em}} курса\\
        \VkrStudyForm\ формы обучения\\
        \textit{\VkrStudentName}

        \vspace{0.6\baselineskip}
        Руководитель выпускной квалификационной работы:\\
        \VkrSupervisorPost\\
        \VkrSupervisorName
      \end{minipage}

      \vfill

      \begin{center}
        \VkrCity\\
        \VkrYear
      \end{center}
    \endgroup
  \end{titlepage}
  \setcounter{page}{2}
}
