Red [	
	Title:   "RED Forms Generator"
	Author:  "PlanetSizeCpu"
	File: 	 %forms.red
	Version: Under Development see below
	Needs:	 'View
	Usage:  {
		Use for form scripts generation, save result then copy&paste code
	}
	History: [
		0.1.0 "22-08-2017"	"Start of work."
		0.1.1 "25-08-2017"	"Help of @rebolek to add form behavior on window resizing"
		0.1.2 "28-08-2017"	"FontGroup upgrade to request-font, added resize flag"
		0.1.3 "29-08-2017"	"Insert widget button, recode list button & actions"
		0.1.4 "01-08-2017"	"Widget insertion process start"
		0.1.5 "04-08-2017"	"Added color to widgets while wait for request-colour dialog"
		0.1.6 "06-09-2017"	"Added recode routine & save button, help of @rebolek on get values"
		0.1.7 "07-09-2017"	"Added some widgets to list, save function enhanced with 'at' "
		0.1.8 "11-09-2017"	"Added font definition to recode routine"
		0.1.9 "12-09-2017"	"Added widget name as text and recode routine"
		0.2.0 "13-09-2017"	"Initial font set to consolas"
		0.2.1 "14-09-2017"	"Help of @dockimbel to add widget editing menu"
	]
]

; Window default values
WindowDefXsize: 1024
WindowDefYsize: 768
WindowDefSize: as-pair WindowDefXsize WindowDefYsize
WindowMinSize: 200x200

; Toolboxes default values
ToolboxDefXsize: 125
ToolboxDefYsize: 300
ToolboxBigSize: as-pair ToolboxDefXsize ToolboxDefYsize
ToolboxMidSize: as-pair ToolboxDefXsize (ToolboxDefYsize / 1.5)
ToolboxLowSize: as-pair ToolboxDefXsize (ToolboxDefYsize / 2)
ToolboxWidgetList: ["area" "base" "box" "button" "camera" "check" "drop-down" "drop-list" "field" 
					"group-box" "image" "panel" "progress" "radio" "slider" "tab-panel" "text" "text-list"]

; Font default values
FontSel: attempt [make font! [name: "Consolas" size: 10 style: "normal"] ]
FontDefName: "Consolas"
FontDefStyl: "Normal"
FontDefSize: "12"

; Form sheet default values
FormSheetDefOrigin: 145x10
FormSheetDefXsize: WindowDefXsize - (ToolboxDefXsize + 25)
FormSheetDefYsize: WindowDefYsize - 25
FormSheetDefSize: as-pair FormSheetDefXsize FormSheetDefYsize
FormSheetStr: ""
FormSheetCounter: 0
FormSheetContent: []
FormSheetRecodeBlock: []
FormSheetWidgetSize: 100x25
FormSheetWidgetBackground: beige
FormSheetWidgetForeground: blue

; Widget re-code screen layout
recodeScreen: layout [ 
	title "Form Code Screen" 
	size 700x200
	below
	text 680x15 left brick white "origin: name: type: size: bgcolor: fgcolor: text: font: "
	RecodeList: text-list 680x250 data FormSheetRecodeBlock
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
		ContentButton: btn "Content/Recode" [Recode view recodeScreen]
	]
	
	; Toolbox Widget list
	WidgetGroup: group-box ToolboxBigSize "Widgets" [
		across
		text 30x25 bold "Size"
		WidgetGroupSize: field 70x20 data FormSheetWidgetSize
		return
		across
		WidgetGroupFgn: box 25x25 FormSheetWidgetForeground
		WidgetGroupBgn: box 25x25 FormSheetWidgetBackground
		return
		below
		WidgetGroupList: text-list data ToolboxWidgetList select 1
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
		FontGroupFontBtn: btn bold "Font" [FormFontChange]
		return
	]
	
	; Save button
	button 120x20 red black bold "SAVE" [Recode write/lines request-file FormSheetRecodeBlock]
	
	; Form default design area
	at FormSheetDefOrigin
	FormSheet: panel FormSheetDefSize white blue cursor cross []
	
	; Catch window resizing and adjust form
	on-resize [mainScreenSizeAdjust]	
]

; Create actor for window on-resize
mainScreen/actors: context [on-resize: func [f e][foreach-face f [if select face/actors 'on-resize [face/actors/on-resize face e]]]]

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
	
	; Compute new form size
	FormSheetDefXsize: WindowDefXsize - 150
	FormSheetDefYsize: WindowDefYsize - 20
	FormSheetDefSize: as-pair FormSheetDefXsize FormSheetDefYsize

	; Set new form size
	FormSheet/size: FormSheetDefSize
	InfoGroupFormSize/text: to-string FormSheetDefSize
]

; Font change behavior
FormFontChange: does [
	FontSel: attempt [make font! request-font]
	FontDefName: FontSel/name 
	FontDefSize: to-string FontSel/size 
	FontGroupFontName/text: FontDefName
	FontGroupFontStyl/text: FontDefStyl
	FontGroupFontSize/text: FontDefSize
]

; Form Sheet widget adition process
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
	
	; Set default widget filler
	either unset? 'FormSheetWidgetFiller [] [unset 'FormSheetWidgetFiller]
	switch FormSheetWidgetType [
		area		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		base		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		box			[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		button		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		camera		[FormSheetWidgetFiller: ""] 
		check		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		drop-down	[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		drop-list	[FormSheetWidgetFiller: ""] 
		field		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		group-box	[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		image		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		panel		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		progress	[FormSheetWidgetFiller: ""] 
		radio		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		slider		[FormSheetWidgetFiller: ""] 
		tab-panel	[FormSheetWidgetFiller: to-block mold to-string FormSheetWidgetName] 
		text		[FormSheetWidgetFiller: to-string FormSheetWidgetName] 
		text-list	[FormSheetWidgetFiller: ""] 
	]	
	
	; Make a dummy face to copy the pane from, and append to form sheet. Can't find other documented method
	Dly: layout reduce [(FormSheetWidgetName) (FormSheetWidgetType) (WidgetGroupSize/data) (FormSheetWidgetFiller)
		'font FontSel (FormSheetWidgetBackground) (FormSheetWidgetForeground) 'loose] 		
		
	; Create new widget into sheet by copying pane from dummy layout
	append FormSheet/pane Dly/pane
	
	; Set widget editing options menu
	Wgw: get to word! FormSheetWidgetName 
	Wgw/menu: ["Size +" Size+ "Size -" Size- "Default" Default "Delete" Delete ]
	Wgw/actors: make object! [
	on-menu: func [face [object!] event [event!]][ 
	switch event/picked [ Size+  [Wgw/size: add Wgw/size 10]
                          Size-  [Wgw/size: subtract Wgw/size 10]
                          Default [Wgw/size: WidgetGroupSize/data] 
                          Delete [FormSheetDeleteWidget Wgw]            
						  ]]]
		
	; Re-code all widgets
	do Recode
]

; Form Sheet widget modification process
FormSheetDeleteWidget: func [Wgw] [
	prin "TO BE DELETED: "
	print Wgw
]

; Compute code block for save
Recode: does [
	
	; Init recode block
	clear FormSheetRecodeBlock
	
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
				Wfiller: copy mold Wgw/data
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
]

;
; Run code
;
view/flags mainScreen [resize]
