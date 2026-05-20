\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sthg-vkr}[2026/05/20 v0.1 Student VKR template (GOST + RGPU profile)]

\RequirePackage{iftex}
\ifluatex\else
  \ClassError{sthg-vkr}{This template requires LuaLaTeX}{Run with lualatex.}
\fi

\RequirePackage{kvoptions}
\SetupKeyvalOptions{family=sthg,prefix=sthg@}
\DeclareStringOption[bachelor]{degree}
\DeclareStringOption[rgpu-herzen]{profile}
\DeclareStringOption[ru]{language}
\ProcessKeyvalOptions*

\LoadClass[14pt,a4paper,oneside]{extreport}

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
\RequirePackage{booktabs}
\RequirePackage{array}
\RequirePackage{titlesec}
\RequirePackage{tocloft}
\RequirePackage[labelsep=period]{caption}
\RequirePackage{fancyhdr}
\RequirePackage{listings}
\RequirePackage{csquotes}
\RequirePackage[hidelinks]{hyperref}
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

\edef\sthg@profileexpanded{\sthg@profile}
\edef\sthg@languageexpanded{\sthg@language}
\edef\sthg@degreeexpanded{\sthg@degree}
\newcommand{\VkrDegree}{\sthg@degreeexpanded}

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

\geometry{left=30mm,right=15mm,top=20mm,bottom=20mm,headheight=0pt,headsep=0pt,footskip=12mm}
\setstretch{1.5}
\setlength{\parindent}{1.25cm}
\setlength{\parskip}{0pt}
\setlength{\emergencystretch}{2em}

\setmainlanguage{russian}
\setotherlanguage{english}
\defaultfontfeatures{Ligatures=TeX}

% Font stack: bundled open-source first, then system fallback.
\IfFileExists{fonts/libertinus/LibertinusSerif-Regular.otf}{%
  \setmainfont{LibertinusSerif-Regular.otf}[
    Path=fonts/libertinus/,
    BoldFont=LibertinusSerif-Bold.otf,
    ItalicFont=LibertinusSerif-Italic.otf,
    BoldItalicFont=LibertinusSerif-BoldItalic.otf
  ]
}{%
  \IfFileExists{fonts/texgyre/texgyretermes-regular.otf}{%
    \setmainfont{texgyretermes-regular.otf}[
      Path=fonts/texgyre/,
      BoldFont=texgyretermes-bold.otf,
      ItalicFont=texgyretermes-italic.otf,
      BoldItalicFont=texgyretermes-bolditalic.otf
    ]
  }{%
    \IfFontExistsTF{Libertinus Serif}{\setmainfont{Libertinus Serif}}{\setmainfont{TeX Gyre Termes}}%
  }%
}

\IfFileExists{fonts/firacode/FiraCode-Regular.ttf}{%
  \setmonofont{FiraCode-Regular.ttf}[
    Path=fonts/firacode/,
    BoldFont=FiraCode-Bold.ttf,
    Scale=MatchLowercase
  ]
}{%
  \IfFontExistsTF{Fira Code}{\setmonofont{Fira Code}[Scale=MatchLowercase]}{\setmonofont{Latin Modern Mono}[Scale=MatchLowercase]}
}

\IfFileExists{fonts/stix/STIXTwoMath-Regular.otf}{%
  \setmathfont{STIXTwoMath-Regular.otf}[Path=fonts/stix/]
}{%
  \IfFontExistsTF{STIX Two Math}{\setmathfont{STIX Two Math}}{\setmathfont{Latin Modern Math}}
}
\numberwithin{equation}{chapter}

\pagestyle{fancy}
\fancyhf{}
\fancyfoot[C]{\thepage}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}

\captionsetup{font=small,justification=centering}
\captionsetup[table]{position=top}
\captionsetup[figure]{position=bottom}
\captionsetup[lstlisting]{font=small,justification=centering}
\renewcommand{\lstlistingname}{Листинг}
\renewcommand{\lstlistlistingname}{Список листингов}

\lstdefinestyle{sthgcode}{
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
\lstset{style=sthgcode}

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

\hypersetup{pdflang={ru-RU},pdfauthor={Student Thesis GOST Project}}

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
\providecommand{\VkrSupervisorPost}{Кандидат физико-математических наук, доцент, доцент кафедры ИТиЭО}
\providecommand{\VkrSupervisorName}{Власов Дмитрий Викторович}
\providecommand{\VkrCity}{Санкт-Петербург}
\providecommand{\VkrYear}{2025}
\providecommand{\VkrLogoPath}{assets/logo-rgpu-herzen.png}
\providecommand{\VkrRightBlockWidth}{95mm}
\providecommand{\VkrLogoWidth}{34mm}
\providecommand{\VkrThemeWidth}{0.9\textwidth}

\newcommand{\VkrUnnumberedChapter}[1]{
  \chapter*{#1}
  \addcontentsline{toc}{chapter}{#1}
}

% Title page geometry follows the provided reference DOCX layout.
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

      \vspace{0.6\baselineskip}

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
