Red [	
	Title:   "RED Forms Generator"
	Author:  "PlanetSizeCpu"
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

; Window default values
WindowDefXsize: 1024
WindowDefYsize: 800
WindowDefSize: as-pair WindowDefXsize WindowDefYsize
WindowMinSize: 640x480

; Toolboxes default values
ToolboxDefXsize: 125
ToolboxDefYsize: 300
ToolboxBigSize: as-pair ToolboxDefXsize ToolboxDefYsize
ToolboxMidSize: as-pair ToolboxDefXsize (ToolboxDefYsize / 1.5)
ToolboxLowSize: as-pair ToolboxDefXsize (ToolboxDefYsize / 2)
ToolboxWidgetList: ["area" "base" "box" "button" "camera" "check" "drop-down" "drop-list" "field" 
			"group-box" "image" "panel" "progress" "radio" "scroller" "slider" "tab-panel" "text" "text-list"]

; Form sheet default values
FormSheetDefXorigin: 145
FormSheetDefYorigin: 10
FormSheetDefOrigin: as-pair FormSheetDefXorigin FormSheetDefYorigin
FormSheetDefXsize: WindowDefXsize - (ToolboxDefXsize * 2.3)
FormSheetDefYsize: WindowDefYsize - 20
FormSheetDefSize: as-pair FormSheetDefXsize FormSheetDefYsize
FormSheetStr: ""
FormSheetCounter: 0
FormSheetContent: []
FormSheetRecodeBlock: []
FormSheetWidgetSize: 300x250
FormSheetWidgetBackground: orange
FormSheetWidgetForeground: blue

; Font default values
FontSel: attempt [make font! [name: "Consolas" size: 12 style: "normal" color:FormSheetWidgetForeground ] ]
FontDefName: "Consolas"
FontDefStyl: "Normal"
FontDefSize: "12"

; Editor default values
EditorDefXsize: (FormSheetDefXsize / 2) - 5
EditorDefYsize: (WindowDefYsize - FormSheetDefYsize) - 20
EditorDefSize: as-pair EditorDefXsize EditorDefYsize
StaticDefOrigin: as-pair FormSheetDefXorigin (FormSheetDefYorigin + FormSheetDefYsize + 5)
DynamicDefOrigin: as-pair (FormSheetDefXorigin + EditorDefXsize + 5) (FormSheetDefYorigin + FormSheetDefYsize + 5)
DynamicCode: does copy [" "]

; Database default values
DbDefOrigin: as-pair (WindowDefXsize - (ToolboxDefXsize + 10)) FormSheetDefYorigin
DbDefXsize: FormSheetDefXsize
DbDefYsize: ToolboxDefYsize - 120
DbDefSize: as-pair DbDefXsize DbDefYsize

; Request color func by @greggirwin/@honix/@myself help while red has its own built-in
set 'request-color function [
		sz [pair!]
		titl [string!]
		actual [tuple!]
		/local palette res dn?
	][
		sz: any [sz 150x150]
		palette: make image! sz
		draw palette compose [
			pen off
			fill-pen linear red orange yellow green aqua blue purple
			box 0x0 (sz)
			fill-pen linear white transparent black 0x0 (as-pair 0 sz/y)
			box 0x0 (sz)
		]
		view/flags compose [
			title (any [ titl ""])
			image palette on-down [dn?: true] on-up [
				if dn? [
					res: pick palette event/offset
					unview
				]
			]
		][modal popup] ; no-buttons
	either none? res [actual][res]
]

;
; Main screen layout
;
mainScreen: layout [

	title "RED FORMS" 
	size WindowDefSize
	below
	style btn: button 100x20 red black bold
	
	; Toolbox info
	InfoGroup: group-box ToolboxLowSize "Form Info" [
		across
		text 30x25 left bold "Size" 
		InfoGroupFormSize: text 60x25 left bold data FormSheetDefSize
		return
		below
	]
	
	; Toolbox Widget list
	WidgetGroup: group-box ToolboxBigSize "Widgets" [
		across
		text 30x25 bold "Size"
		WidgetGroupSize: field 70x20 data FormSheetWidgetSize
		return
		across
		WidgetGroupFgn: box 25x25 FormSheetWidgetForeground [FormSheetWidgetForeground: WidgetGroupFgn/color: request-color 200x200 "Select Foreground Color" WidgetGroupFgn/color]
		WidgetGroupBgn: box 25x25 FormSheetWidgetBackground [FormSheetWidgetBackground: WidgetGroupBgn/color: request-color 200x200 "Select Background Color" WidgetGroupBgn/color]
		return
		below
		WidgetGroupList: drop-down data ToolboxWidgetList select 1
		WidgetGroupAddbtn: btn bold "Add" [FormSheetAddWidget]
	]
	
	; Toolbox Font controls
	FontGroup: group-box ToolboxLowSize "Font" [ 
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
	
	; Toolbox Source 
	SourceGroup: group-box ToolboxLowSize "Source" [
		below 
		RunButton: btn "Run" [Recode attempt [SourceRun]]
		SaveSourceButton: btn "Save" [SourceSave] 
	]
	
	; Form default design area
	at FormSheetDefOrigin
	FormSheet: panel FormSheetDefSize white blue cursor cross []
	
	; Editing area
	at StaticDefOrigin
	EditorStatic: area EditorDefSize 250.240.240 yellow
	at DynamicDefOrigin
	EditorDynamic: area EditorDefSize blue white " "

	; Database Toolbox
	at DbDefOrigin
	DbToolGroup: group-box ToolboxBigSize " " [
		below
	]
	
	; Catch window resizing and adjust form
	on-resize [mainScreenSizeAdjust]	
]

; Create actor for window on-resize
mainScreen/actors: context [on-resize: func [f e][foreach-face f [if select face/actors 'on-resize [face/actors/on-resize face e]]]]

; Disable static editor
EditorStatic/enabled?: false

;
; Actions routines
;

; Window resizing form adjust
mainScreenSizeAdjust: does [

	; Check new form minimal size and restore last window size if needed
	if FormSheet/parent/size < WindowMinSize [FormSheet/parent/size: WindowDefSize]
	
	; Get new window size
	WindowDefXsize: FormSheet/parent/size/x
	WindowDefYsize: FormSheet/parent/size/y 
	WindowDefSize: as-pair WindowDefXsize WindowDefYsize
	
	; Compute new form size leaving room for toolboxes on left & right sides
	FormSheetDefXsize: WindowDefXsize - (ToolboxDefXsize * 2) - 40
	FormSheetDefYsize: WindowDefYsize - 200
	FormSheetDefSize: as-pair FormSheetDefXsize FormSheetDefYsize

	; Compute new editor location
	EditorDefOrigin: as-pair 145 (FormSheetDefYsize + 20)
	
	; Set new form size
	FormSheet/size: FormSheetDefSize
	InfoGroupFormSize/text: to-string FormSheetDefSize
	
	; Compute new editor size
	EditorDefXsize: (FormSheetDefXsize / 2 ) - 5
	EditorDefYsize: (WindowDefYsize - FormSheetDefYsize) - 20
	EditorDefSize: as-pair EditorDefXsize EditorDefYsize
	EditorStatic/size: EditorDefSize
	EditorDynamic/size: EditorDefSize

	; Set new editor location
	StaticDefOrigin: as-pair FormSheetDefXorigin (FormSheetDefYorigin + FormSheetDefYsize + 5)
	DynamicDefOrigin: as-pair (FormSheetDefXorigin + EditorDefXsize + 5) (FormSheetDefYorigin + FormSheetDefYsize + 5)
	EditorStatic/offset: StaticDefOrigin
	EditorDynamic/offset: DynamicDefOrigin

	; Set new database toolbox location
	DbDefOrigin: as-pair (WindowDefXsize - (ToolboxDefXsize + 10)) FormSheetDefYorigin
	DbToolGroup/offset: DbDefOrigin	
	
	Recode
]

; Font change behavior
FormFontChange: does [
	FontSel: attempt [make font! request-font]
	FontSel/color: FormSheetWidgetForeground
	FontDefName: FontSel/name 
	FontDefSize: to-string FontSel/size 
	FontGroupFontName/text: FontDefName
	FontGroupFontStyl/text: FontDefStyl
	FontGroupFontSize/text: FontDefSize
]

; Form Sheet widget addition
FormSheetAddWidget: does [
	
	; Compute widget name 
	FormSheetStr: null
	FormSheetWidgetName: null
	FormSheetWidgetType: null
	FormSheetCounter: add FormSheetCounter 1
	FormSheetStr: to-string ToolboxWidgetList/(WidgetGroupList/selected)
	FormSheetWidgetType: to-word copy FormSheetStr
	append FormSheetStr to-string FormSheetCounter
	append FormSheetStr ":"
	FormSheetWidgetName: to-set-word FormSheetStr
	
	; Add widget to content list
	append FormSheetContent FormSheetStr
	
	; Set default widget filler text for each widget type (we want individual control)
	either unset? 'FormSheetWidgetFiller [] [unset 'FormSheetWidgetFiller]
	switch FormSheetWidgetType [
		area		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		base		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		box			[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		button		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
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
	
	; Make a dummy face to create the pane
	Dly: layout reduce [(FormSheetWidgetName) (FormSheetWidgetType) (WidgetGroupSize/data) (FormSheetWidgetFiller)
		'font FontSel (FormSheetWidgetBackground) (FormSheetWidgetForeground) 'loose 'on-drop [Recode show face] ]		
		
	; Create new widget into sheet using the pane from dummy layout
	append FormSheet/pane Dly/pane
	
	; Set widget editing options menu
	Wgw: get to word! FormSheetWidgetName 
	Wgw/menu: ["Size  +" Size+ "Size  -" Size- "Default Size" Defsize "Default Font" Deffont "Default Color" Defcolor
	          "Delete" Deletewt]
	
	; Create actors
	Wgw/actors: make object! [on-menu: func [face [object!] event [event!]]
		[switch event/picked [Size+  [face/size: add face/size 10 Recode]
							Size-  [face/size: subtract face/size 10 Recode]
							Defsize [face/size: WidgetGroupSize/data Recode] 
							Deffont [face/font: copy FontSel Recode]
							Defcolor [FormSheetSetDefcolor face]
							Deletewt [FormSheetDeleteWidget face]            
							]
		]
	on-drop: func [][Recode]
	]
		
	; Set widget offset
	Wgw/offset: 25x25
	
	; Re-code all widgets
	Recode
]

; Form Sheet widget deletion
FormSheetDeleteWidget: func [face [object!]][

	; Set widget name (here would help face/name attribute)
	either none? face/text [Wnm: to-string face/data] [Wnm: face/text]
	append Wnm ":"	
	
	; Delete widget from content list
	alter FormSheetContent Wnm
	
	; Delete widget from global context
	if [face? to-word Wnm] [unset to-word Wnm]
	
	; Delete widget from form sheet
	remove find face/parent/pane face
	
	; Re-code all widgets
	Recode
]

; Set widget to default color
FormSheetSetDefcolor: func [face [object!]][
	face/color: FormSheetWidgetBackground face/font/color: FormSheetWidgetForeground
	
	; Re-code all widgets
	Recode
]

; Compute static code for save
Recode: does [
	
	; Init recode block
	clear FormSheetRecodeBlock
	
	; Set window size
	Widget: copy "size "
	append Widget FormSheetDefSize
	append FormSheetRecodeBlock Widget
	
	; Compute each widget on content list
	foreach Wgt FormSheetContent [
		; Get widget values as word
		Wgw: get to word! Wgt
		
		; Set widget string
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
		
		; Append widget to code block
		append FormSheetRecodeBlock Widget
	]
	
	; Clone content in static editor area
	EditorStatic/text: copy "Red [ Needs: 'View ]" 
	append EditorStatic/text newline
	append EditorStatic/text "view/no-wait ["
	foreach Wgt FormSheetRecodeBlock [append EditorStatic/text newline append EditorStatic/text Wgt]
	append EditorStatic/text newline 
	append EditorStatic/text "]"
	append EditorStatic/text newline
	
	; Arrange global code
	Globalcode: copy EditorStatic/text
	append Globalcode newline
	append Globalcode "DynamicCode: does ["
	append Globalcode newline
	append Globalcode EditorDynamic/text
	append Globalcode "]"
	append Globalcode newline
	append Globalcode "do DynamicCode"
	append Globalcode newline
	append Globalcode "halt"
]

; Source run on screen 
SourceRun: does [
	do to-block Globalcode
]

; Source save to file
SourceSave: does [
	SourceFile: request-file 
	either none? SourceFile [][
		Recode write SourceFile Globalcode
	]
]


;
; Run code
;
view/flags/no-wait mainScreen [resize]
