Red [	
	Title:   "RED Forms Generator"
	Author:  "PlanetSizeCpu"
	Contributor: "YKProg"
	File: 	 %forms_dynamic.red
	Version: Under Development see below
	Needs:	 'View
	Usage:  {
		Use for form scripts generation, save result then copy&paste or load code
	}
	History: [
		0.1.0 "22-08-2017"	"Start of work."
		0.3.4 "26-03-2018"	"Source editor split"
		0.3.5 "30-04-2018"	"Dynamic code arrangement"
		0.3.6 "30-07-2018"	"Fixed font size typo"
		0.3.7 "27-08-2018"	"Fixed on-drop issue"
		0.3.8 "05-10-2018"	"Fixed widgets toolbox issue"
	]
]

WindowDefXsize: 800
WindowDefYsize: 650
WindowDefSize: as-pair WindowDefXsize WindowDefYsize
WindowMinXSize: 800
WindowMinYSize: 650

FormSheetDefXorigin: 145
FormSheetDefYorigin: 17
FormSheetDefOrigin: as-pair FormSheetDefXorigin FormSheetDefYorigin
FormSheetDefXsize: WindowDefXsize - FormSheetDefXorigin
FormSheetDefYsize: WindowDefYsize - 135
FormSheetDefSize: as-pair FormSheetDefXsize FormSheetDefYsize
FormSheetStr: ""
FormSheetCounter: 0
FormSheetContent: []
FormSheetRecodeBlock: []
FormSheetWidgetSize: 200x150
FormSheetWidgetBackground: gray
FormSheetWidgetForeground: black

str: make string! FormSheetDefSize
ToolboxDefXsize: 125
ToolboxFileSize: as-pair ToolboxDefXsize 90
ToolboxFontSize: as-pair ToolboxDefXsize 140
ToolboxWidgetsSize: as-pair ToolboxDefXsize 200
ToolboxFormSheetSize: as-pair ToolboxDefXsize 60
ToolboxWidgetList: ["area" "base" "box" "button" "calendar" "camera" "check" "drop-down" "drop-list" "field" "group-box" "image" "panel" "progress" "radio" "scroller" "slider" "tab-panel" "text" "text-list"]

DynamicEditorDefXsize: (WindowDefXsize / 3)
StaticEditorDefXsize: (WindowDefXsize / 3 * 2)
EditorDefYsize: 114
DynamicEditorDefSize: as-pair DynamicEditorDefXsize EditorDefYsize
staticEditorDefSize: as-pair StaticEditorDefXsize EditorDefYsize
StaticDefOrigin: as-pair 0 (FormSheetDefYorigin + FormSheetDefYsize + 5)
DynamicDefOrigin: as-pair StaticEditorDefXsize (FormSheetDefYorigin + FormSheetDefYsize + 5)
DynamicCode: does copy [" "]

FontSel: attempt [make font! [name: "Arial" size: 14 style: "normal" color:FormSheetWidgetForeground ] ]
FontDefName: "Arial"
FontDefStyl: "Normal"
FontDefSize: "14"

forg: func[
    clr [tuple!]
][
    FormSheetWidgetForeground: clr
    unview
    WidgetGroupFgn/color: clr
]

bacg: func[
    clr [tuple!]
][
    FormSheetWidgetBackground: clr
    unview
    WidgetGroupBgn/color: clr
]

specified-color-f: function [][

	to-color: function [r g b][0
        color: 0.0.0
        if r [color/1: to integer! 256 * r]
        if g [color/2: to integer! 256 * g]
        if b [color/3: to integer! 256 * b]
        color
    ]

    to-text: function [val][form to integer! 0.5 + 255 * any [val 0]]

    view [
        title "Color sliders"
        style txt: text 40 right
        style value: text "0" 30 right bold
	
        across
        txt "Red:"   R: slider 256 value react [face/text: to-text R/data] return
        txt "Green:" G: slider 256 value react [face/text: to-text G/data] return
        txt "Blue:"  B: slider 256 value react [face/text: to-text B/data]
	
        pad 0x-65 box: base react [face/color: to-color R/data G/data B/data] return

        pad 0x20 text "The new color"
            font  [size: 14]
            react [face/font/color: box/color]
        button "Done!" [do forg box/color]
    ]
]

specified-color-b: function [][

	to-color: function [r g b][0
        color: 0.0.0
        if r [color/1: to integer! 256 * r]
        if g [color/2: to integer! 256 * g]
        if b [color/3: to integer! 256 * b]
        color
    ]

    to-text: function [val][form to integer! 0.5 + 255 * any [val 0]]

    view [
        title "Color sliders"
        style txt: text 40 right
        style value: text "0" 30 right bold
	
        across
        txt "Red:"   R: slider 256 value react [face/text: to-text R/data] return
        txt "Green:" G: slider 256 value react [face/text: to-text G/data] return
        txt "Blue:"  B: slider 256 value react [face/text: to-text B/data]
	
        pad 0x-65 box: base react [face/color: to-color R/data G/data B/data] return

        pad 0x20 text "The new color"
            font  [size: 14]
            react [face/font/color: box/color]
        button "Done!" [do bacg box/color]
    ]
]

mainScreen: layout [

	title "RED FORMS" 
	size WindowDefSize
	below center
	style btn: button 100x20 red black bold

	InfoGroup: group-box ToolboxFormSheetSize "Form-sheet size" [
		InfoGroupFormSize: text 100x25 center bold font-size 14 str
	]

	WidgetGroup: group-box ToolboxWidgetsSize "Widgets" [
		below center
		text center 100x15 bold "Size:"
        WidgetGroupSize: field 100x20 data FormSheetWidgetSize
		across middle
        text 70x20 left "Foreground:"
		WidgetGroupFgn: box 20x20 FormSheetWidgetForeground [specified-color-f]
        return
        text 70x20 left "Background:"
		WidgetGroupBgn: box 20x20 FormSheetWidgetBackground [specified-color-b]
		return below center
		WidgetGroupList: drop-down data ToolboxWidgetList select 1
		WidgetGroupAddbtn: btn bold "Add" [FormSheetAddWidget]
	]

	FontGroup: group-box ToolboxFontSize "Font" [ 
		below
		FontGroupFontName: text bold 90x15 FontDefName
		FontGroupFontStyl: text bold 90x15 FontDefStyl
		across
		text 30x25 bold "Size:"
		FontGroupFontSize: text bold 30x15 FontDefSize
		return
		below
		FontGroupFontBtn: btn bold "Font" [attempt [FormFontChange]]
		return
	]

	SourceGroup: group-box ToolboxFileSize "File" [
		below center
		RunButton: btn "Run" [Recode attempt [SourceRun]]
		SaveSourceButton: btn "Save" [SourceSave] 
	]
	
	at FormSheetDefOrigin
	FormSheet: panel FormSheetDefSize white blue cursor cross []

	at StaticDefOrigin
	EditorStatic: area StaticEditorDefSize 250.240.240 yellow

	at DynamicDefOrigin
	EditorDynamic: area DynamicEditorDefSize black green

	on-resize [mainScreenSizeAdjust2]
	on-detect [mainScreenSizeAdjust1]
]

system/view/capturing?: yes

mainScreen/actors: context [
    on-detect: func [f e][
        foreach-face f[
            if select face/actors 'on-detect [
                face/actors/on-detect face e
            ]
        ]
    ]
    on-resize: func [f e][
        foreach-face f[
            if select face/actors 'on-resize [
                face/actors/on-resize face e
            ]
        ]
    ]
]

EditorStatic/enabled?: false

mainScreenSizeAdjust2: does [

    if FormSheet/Parent/size/x < WindowMinXSize [
        FormSheet/Parent/size/x: WindowMinXSize
        mainScreenSizeAdjust1
    ]

    if FormSheet/Parent/size/y < WindowMinYSize [
        FormSheet/Parent/size/y: WindowMinYSize
        mainScreenSizeAdjust1
    ]

    str: make string! FormSheetDefSize
    InfoGroupFormSize/text: str

    Recode
]

mainScreenSizeAdjust1: does [

    WindowDefXsize: FormSheet/Parent/size/x
    WindowDefYsize: FormSheet/Parent/size/y
    WindowDefsize: as-pair WindowDefXsize WindowDefYsize

    FormSheetDefXorigin: 145
    FormSheetDefYorigin: 17
    FormSheetDefOrigin: as-pair FormSheetDefXorigin FormSheetDefYorigin
    FormSheetDefXsize: WindowDefXsize - FormSheetDefXorigin
    FormSheetDefYsize: WindowDefYsize - 135
    FormSheetDefSize: as-pair FormSheetDefXsize FormSheetDefYsize

    FormSheet/offset: FormSheetDefOrigin
    FormSheet/size: FormSheetDefSize

    DynamicEditorDefXsize: (WindowDefXsize / 3)
    StaticEditorDefXsize: (WindowDefXsize / 3 * 2)
    EditorDefYsize: 114
    DynamicEditorDefSize: as-pair DynamicEditorDefXsize EditorDefYsize
    staticEditorDefSize: as-pair StaticEditorDefXsize EditorDefYsize
    StaticDefOrigin: as-pair 0 (FormSheetDefYorigin + FormSheetDefYsize + 5)
    DynamicDefOrigin: as-pair StaticEditorDefXsize (FormSheetDefYorigin + FormSheetDefYsize + 5)

    EditorStatic/offset: StaticDefOrigin
    EditorStatic/size: staticEditorDefSize
    EditorDynamic/offset: DynamicDefOrigin
    EditorDynamic/size: DynamicEditorDefSize

]

FormFontChange: does [
	FontSel: attempt [make font! request-font]
	FontSel/color: FormSheetWidgetForeground
	FontDefName: FontSel/name 
	FontDefSize: to-string FontSel/size 
	FontGroupFontName/text: FontDefName
	FontGroupFontStyl/text: FontDefStyl
	FontGroupFontSize/text: FontDefSize
]

FormSheetAddWidget: does [
	
	FormSheetStr: null
	FormSheetWidgetName: null
	FormSheetWidgetType: null
	FormSheetCounter: add FormSheetCounter 1
	FormSheetStr: to-string ToolboxWidgetList/(WidgetGroupList/selected)
	FormSheetWidgetType: to-word copy FormSheetStr
	append FormSheetStr to-string FormSheetCounter
	append FormSheetStr ":"
	FormSheetWidgetName: to-set-word FormSheetStr
	append FormSheetContent FormSheetStr
	either unset? 'FormSheetWidgetFiller [] [unset 'FormSheetWidgetFiller]
	switch FormSheetWidgetType [
		area		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		base		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		box		    [FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		button		[FormSheetWidgetFiller: to-string FormSheetWidgetName]
		calendar	[FormSheetWidgetFiller: to-string FormSheetWidgetName] 		
		camera		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		check		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		drop-down	[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		drop-list	[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		field		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		group-box	[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		image		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		panel		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		progress	[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		radio		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		slider		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		scroller	[FormSheetWidgetFiller: to-string FormSheetWidgetName] 		
		tab-panel	[FormSheetWidgetFiller: reduce [ to-string (FormSheetWidgetName) [] ] ] 
		text		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		text-list	[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
	]	
	
	Dly: layout reduce [(FormSheetWidgetName) (FormSheetWidgetType) (WidgetGroupSize/data) (FormSheetWidgetFiller)
		'font FontSel (FormSheetWidgetBackground) (FormSheetWidgetForeground) 'loose 'on-drop [Recode show face] ]		

    append FormSheet/pane Dly/pane

	Wgw: get to word! FormSheetWidgetName 
	Wgw/menu: ["Size  +" Size+ "Size  -" Size- "Change Size" Defsize "Change Font" Deffont "Change Color" Defcolor "Delete" Deletewt]
	Wgw/actors: make object! [on-menu: func [face [object!] event [event!]][
        switch event/picked [
            Size+  [face/size: add face/size 10 Recode]
			Size-  [face/size: subtract face/size 10 Recode]
			Defsize [face/size: WidgetGroupSize/data Recode] 
			Deffont [face/font: copy FontSel Recode]
			Defcolor [FormSheetSetDefcolor face]
			Deletewt [FormSheetDeleteWidget face]            
        ]
    ]
    on-drop: func [][Recode]]
	Wgw/offset: 25x25
	Recode
]

FormSheetDeleteWidget: func [face [object!]][

	either none? face/text [Wnm: to-string face/data] [Wnm: face/text]
	append Wnm ":"	
	alter FormSheetContent Wnm
	if [face? to-word Wnm] [unset to-word Wnm]
	remove find face/parent/pane face
	Recode
]

FormSheetSetDefcolor: func [face [object!]][
	face/color: FormSheetWidgetBackground face/font/color: FormSheetWidgetForeground
	Recode
]

Recode: does [
	
	clear FormSheetRecodeBlock
	Widget: copy "size "
	append Widget FormSheetDefSize
	append FormSheetRecodeBlock Widget
	foreach Wgt FormSheetContent [

		Wgw: get to word! Wgt
		
		Widget: copy "at "
		
		Woffset: Wgw/offset
		append Widget Woffset
		append Widget " "
		
		append Widget Wgt
		append Widget " "
		
		Wtype: Wgw/type
		append Widget Wtype
		append Widget " "
		
		Wsize: Wgw/size
		append Widget Wsize
		append Widget " "		
		
		Wcolor: Wgw/color
		append Widget Wcolor
		append Widget " "
		
		Wcolor: Wgw/font/color
		append Widget Wcolor
		append Widget " "
		
		Wfiller: copy ""
		switch/default Wtype [
			tab-panel [
				Wfiller: copy mold reduce [ Wgt [] ]
				append Widget Wfiller]
			text [Wfiller: copy Wgw/text append Widget mold Wfiller
					Wfiller: " para [align: 'center v-align: 'middle]"	
					append Widget Wfiller]
		][
			Wfiller: copy Wgw/text	
			append Widget mold Wfiller
		] 

        append Widget " "
		Wft: copy "font ["
		append Wft "name: " 
		append Wft dbl-quote
		append Wft Wgw/font/name
		append Wft dbl-quote
		append Wft " "
		append Wft "size: "
		append Wft Wgw/font/size
		append Wft " "
		append Wft "style: '"
		append Wft Wgw/font/style
		append Wft "]"
		append Widget Wft
		append FormSheetRecodeBlock Widget
	]
	
	EditorStatic/text: copy "Red [ Needs: 'View ]" 
	append EditorStatic/text newline
	append EditorStatic/text "view ["
	foreach Wgt FormSheetRecodeBlock [append EditorStatic/text newline append EditorStatic/text Wgt]
	append EditorStatic/text newline 
	append EditorStatic/text "]"
	append EditorStatic/text newline
	
	Globalcode: copy EditorStatic/text
	append Globalcode newline
	append Globalcode "DynamicCode: does ["
	append Globalcode newline
	append Globalcode EditorDynamic/text
	append Globalcode "]"
	append Globalcode newline
	append Globalcode "do DynamicCode"
]

SourceRun: does [
	do to-block Globalcode
]

SourceSave: does [
	SourceFile: request-file 
	either none? SourceFile [][
		Recode write SourceFile Globalcode
	]
]

view/flags mainScreen [resize]
