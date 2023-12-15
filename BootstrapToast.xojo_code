#tag Class
Protected Class BootstrapToast
Inherits WebSDKControl
	#tag Event
		Function ExecuteEvent(name As string, parameters As JSONItem) As Boolean
		  // We won't use this event in this example.
		End Function
	#tag EndEvent

	#tag Event
		Function HandleRequest(request As WebRequest, response As WebResponse) As Boolean
		  // We won't use this event in this example.
		End Function
	#tag EndEvent

	#tag Event
		Function JavaScriptClassName() As String
		  // This string must match your JavaScript class name.
		  // Please check kJSCode constant content.
		  Return "RC.Toast"
		End Function
	#tag EndEvent

	#tag Event
		Sub Serialize(js As JSONItem)
		  // Every time we call UpdateControl, the WebSDK will call this
		  // event, where you can pass data to your JavaScript control.
		  //
		  // This data will be received by your frontend component
		  // updateControl() method.
		  Var commands As New JSONItem
		  For Each command As Dictionary In mCommands
		    commands.Add(command)
		  Next command
		  mCommands.RemoveAll
		  
		  // This type of encoding supports UTF-8 and emojis.
		  js.Value("commands") = EncodeBase64(EncodeURLComponent(commands.ToString), 0)
		End Sub
	#tag EndEvent

	#tag Event
		Function SessionHead(session As WebSession) As String
		  // We won't use this event in this example.
		End Function
	#tag EndEvent

	#tag Event
		Function SessionJavascriptURLs(session As WebSession) As String()
		  // It is easier to develop without having to copy and paste
		  // the dist file into BootstrapToast.kJS constant every time
		  // do some changes on your TypeScript. If you have a build
		  // step that copies this file automatically, you can turn on
		  // this constant.
		  //
		  // Remember to change it to False to make it easier to share!
		  Const UseRealFile = False
		  
		  If SharedJSFile = Nil Then
		    #If UseRealFile
		      Var f As FolderItem = SpecialFolder.Resources.Child("Toast.js")
		      SharedJSFile = WebFile.Open(f)
		    #Else
		      SharedJSFile = New WebFile(False)
		      SharedJSFile.Data = kJSCode
		    #EndIf
		    
		    SharedJSFile.Filename = "rc-toast.js"
		    SharedJSFile.MIMEType = "application/javascript"
		  End If
		  
		  Return Array(SharedJSFile.URL)
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub HideAll()
		  Var command As New Dictionary
		  command.Value("type") = "hide-all"
		  mCommands.Add(command)
		  
		  UpdateControl
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HideAt(index As Integer)
		  Var command As New Dictionary
		  command.Value("type") = "hide-at"
		  command.Value("index") = index
		  mCommands.Add(command)
		  
		  UpdateControl
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Toast(title As String, timeAgo As String, body As String, autohide As Boolean = True, hideDelay As Integer = 2000, indicator As WebUIControl.Indicators = WebUIControl.Indicators.Default)
		  Var command As New Dictionary
		  command.Value("type") = "toast"
		  command.Value("title") = title.ReplaceAll(EndOfLine, "<br>")
		  command.Value("time_ago") = timeAgo.ReplaceAll(EndOfLine, "<br>")
		  command.Value("body") = body.ReplaceAll(EndOfLine, "<br>")
		  command.Value("auto_hide") = autoHide
		  command.Value("hide_delay") = hideDelay
		  command.Value("indicator") = CType(indicator, Integer)
		  mCommands.Add(command)
		  
		  UpdateControl
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mCommands() As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared SharedJSFile As WebFile
	#tag EndProperty


	#tag Constant, Name = kJSCode, Type = String, Dynamic = False, Default = \"\"use strict\";\nvar RC;\n(function (RC) {\n    class Toast extends XojoWeb.XojoControl {\n        constructor() {\n            super(...arguments);\n            this.mWrapperElementID \x3D \'bs-toast-wrapper\';\n            this.mToastWrapper \x3D null;\n        }\n        updateControl(data) {\n            const js \x3D JSON.parse(data);\n            const commands \x3D JSON.parse(Toast.decode(js.commands));\n            if (typeof commands \x3D\x3D\x3D \'object\' && commands.length > 0) {\n                commands.forEach((command) \x3D> this.parseCommand(command));\n            }\n        }\n        toast(title\x2C timeAgo\x2C body\x2C autoHide \x3D true\x2C hideDelay \x3D 500\x2C indicator \x3D 0) {\n            var _a\x2C _b\x2C _c;\n            this.createWrapperIfNeeded();\n            const element \x3D document.createElement(\'div\');\n            (_a \x3D this.mToastWrapper) \x3D\x3D\x3D null || _a \x3D\x3D\x3D void 0 \? void 0 : _a.appendChild(element);\n            const toastId \x3D \'bs-toast-\' + Date.now();\n            const indicators \x3D [\'light\'\x2C \'primary\'\x2C \'secondary\'\x2C \'success\'\x2C \'danger\'\x2C \'warning\'\x2C \'info\'\x2C \'dark\'\x2C \'light\'];\n            if (XojoWeb.session.isDarkModeEnabled) {\n                indicators[0] \x3D \'dark\';\n            }\n            const indicatorString \x3D `text-bg-${indicators[indicator]}`;\n            if (title !\x3D\x3D \"\" || timeAgo !\x3D\x3D \"\") {\n                element.outerHTML \x3D `\n                <div id\x3D\"${toastId}\" class\x3D\"toast ${indicatorString}\" role\x3D\"alert\" aria-live\x3D\"assertive\" aria-atomic\x3D\"true\"\n                    data-bs-animation\x3D\"true\" data-bs-autohide\x3D\"${autoHide}\" data-bs-delay\x3D\"${hideDelay}\">\n                    <div class\x3D\"toast-header\">\n                        <strong class\x3D\"me-auto\">${title}</strong>\n                        <small class\x3D\"text-body-secondary\">${timeAgo}</small>\n                        <button type\x3D\"button\" class\x3D\"btn-close\" data-bs-dismiss\x3D\"toast\" aria-label\x3D\"Close\"></button>\n                    </div>\n                    <div class\x3D\"toast-body\">${body}</div>\n                </div>`.trim();\n            }\n            else {\n                let closeBtnStyle \x3D \'filter: none\';\n                if ([\'light\'\x2C \'warning\'\x2C \'info\'].indexOf(indicators[indicator]) \x3D\x3D\x3D -1) {\n                    closeBtnStyle \x3D \'\';\n                }\n                element.outerHTML \x3D `\n                <div id\x3D\"${toastId}\" class\x3D\"toast align-items-center ${indicatorString} border-0\" role\x3D\"alert\" aria-live\x3D\"assertive\" aria-atomic\x3D\"true\"\n                    data-bs-animation\x3D\"true\" data-bs-autohide\x3D\"${autoHide}\" data-bs-delay\x3D\"${hideDelay}\">\n                    <div class\x3D\"d-flex\">\n                        <div class\x3D\"toast-body\">${body}</div>\n                        <button type\x3D\"button\" class\x3D\"btn-close me-2 m-auto\" data-bs-dismiss\x3D\"toast\" aria-label\x3D\"Close\" style\x3D\"${closeBtnStyle}\"></button>\n                    </div>\n                </div>`.trim();\n            }\n            if (!autoHide) {\n                (_b \x3D document.getElementById(toastId)) \x3D\x3D\x3D null || _b \x3D\x3D\x3D void 0 \? void 0 : _b.removeAttribute(\'data-bs-delay\');\n            }\n            (_c \x3D document.getElementById(toastId)) \x3D\x3D\x3D null || _c \x3D\x3D\x3D void 0 \? void 0 : _c.addEventListener(\'hidden.bs.toast\'\x2C (ev) \x3D> {\n                var _a;\n                (_a \x3D this.getToastById(toastId)) \x3D\x3D\x3D null || _a \x3D\x3D\x3D void 0 \? void 0 : _a.dispose();\n                const target \x3D ev.target;\n                target.remove();\n            });\n            bootstrap.Toast.getOrCreateInstance(`#${toastId}`).show();\n        }\n        hideAt(index) {\n            var _a;\n            const elements \x3D document.querySelectorAll(`#${this.mWrapperElementID} .toast`);\n            if (index < elements.length) {\n                (_a \x3D bootstrap.Toast.getInstance(elements[index])) \x3D\x3D\x3D null || _a \x3D\x3D\x3D void 0 \? void 0 : _a.hide();\n            }\n        }\n        hideAll() {\n            document.querySelectorAll(`#${this.mWrapperElementID} .toast`)\n                .forEach((element) \x3D> {\n                var _a;\n                (_a \x3D bootstrap.Toast.getInstance(element)) \x3D\x3D\x3D null || _a \x3D\x3D\x3D void 0 \? void 0 : _a.hide();\n            });\n        }\n        parseCommand(command) {\n            switch (command.type) {\n                case \'toast\':\n                    const title \x3D command.title || \'\';\n                    const timeAgo \x3D command.time_ago || \'\';\n                    const body \x3D command.body || \'\';\n                    let autoHide \x3D true;\n                    if (typeof command.auto_hide \x3D\x3D\x3D \'boolean\') {\n                        autoHide \x3D command.auto_hide;\n                    }\n                    const hideDelay \x3D command.hide_delay || 2500;\n                    const indicator \x3D command.indicator || 0;\n                    this.toast(title\x2C timeAgo\x2C body\x2C autoHide\x2C hideDelay\x2C indicator);\n                    break;\n                case \'hide-at\':\n                    command.index && this.hideAt(command.index);\n                    break;\n                case \'hide-all\':\n                    this.hideAll();\n                    break;\n            }\n        }\n        createWrapperIfNeeded() {\n            var _a;\n            this.mToastWrapper \x3D document.getElementById(this.mWrapperElementID);\n            if (this.mToastWrapper) {\n                return;\n            }\n            this.mToastWrapper \x3D document.createElement(\'div\');\n            this.mToastWrapper.id \x3D this.mWrapperElementID;\n            this.mToastWrapper.classList.add(\'toast-container\'\x2C \'top-0\'\x2C \'end-0\'\x2C \'p-3\');\n            (_a \x3D document.getElementById(\'XojoSession\')) \x3D\x3D\x3D null || _a \x3D\x3D\x3D void 0 \? void 0 : _a.appendChild(this.mToastWrapper);\n        }\n        static decode(str) {\n            return decodeURIComponent(atob(str));\n        }\n        getToastById(id) {\n            return bootstrap.Toast.getInstance(id);\n        }\n    }\n    RC.Toast \x3D Toast;\n})(RC || (RC \x3D {}));\n", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="_mPanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ControlID"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
