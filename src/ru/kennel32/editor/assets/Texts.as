package ru.kennel32.editor.assets 
{
	import ru.kennel32.editor.data.helper.warning.WarningType;
	import ru.kennel32.editor.data.serialize.SerializerType;
	public class Texts 
	{
		public static function get menuFile():String
		{
			return "File";
		}
		
		public static function get menuEdit():String
		{
			return "Edit";
		}
		
		public static function get menuSearch():String
		{
			return "Search";
		}
		
		public static function get menuFind():String
		{
			return "Find";
		}
		
		public static function get menuFindInProject():String
		{
			return "Find in project";
		}
		
		public static function get menuTools():String
		{
			return "Tools";
		}
		
		public static function get menuExportConfig():String
		{
			return "Export config";
		}
		
		public static function get menuUploadConfig():String
		{
			return "Upload config";
		}
		
		public static function get menuRemoveConfig():String
		{
			return "Remove config";
		}
		
		public static function get menuPullConfig():String
		{
			return "Pull config";
		}
		
		public static function get menuSettings():String
		{
			return "Settings";
		}
		
		public static function get menuNewFile():String
		{
			return "New";
		}
		
		public static function get menuOpen():String
		{
			return "Open...";
		}
		
		public static function get menuSave():String
		{
			return "Save";
		}
		
		public static function get menuSaveAs():String
		{
			return "Save As...";
		}
		
		public static function get menuUndo():String
		{
			return "Undo";
		}
		
		public static function get menuRedo():String
		{
			return "Redo";
		}
		
		public static function get textOpenTable():String
		{
			return "Open table...";
		}
		
		public static function get textSaveAs():String
		{
			return "Save table as...";
		}
		
		public static function get textConfig():String
		{
			return "Config file";
		}
		
		public static function get textNewProject():String
		{
			return "New Project";
		}
		
		public static function get commandDefault():String
		{
			return "Action";
		}
		
		public static function get commandChangeBoolValue():String
		{
			return "Change boolean";
		}
		
		public static function get commandChangeIntValue():String
		{
			return "Change integer";
		}
		
		public static function get commandChangeNumberValue():String
		{
			return "Change float";
		}
		
		public static function get commandAddInnerTableRow():String
		{
			return "Add inner row";
		}
		
		public static function get commandEditInnerTableRow():String
		{
			return "Edit inner row";
		}
		
		public static function get commandDeleteInnerTableRow():String
		{
			return "Delete inner row";
		}
		
		public static function get commandChangeStringValue():String
		{
			return "Change string";
		}
		
		public static function get commandChangeItem():String
		{
			return "Change item";
		}
		
		public static function get commandSelectRow():String
		{
			return "Select row";
		}
		
		public static function get commandDeselectRow():String
		{
			return "Deselect row";
		}
		
		public static function get commandSelectTable():String
		{
			return "Select table";
		}
		
		public static function get commandInspectRow():String
		{
			return "Inspect row";
		}
		
		public static function get commandCloseInspectRow():String
		{
			return "Cancel inspect row";
		}
		
		public static function get commandExpandTree():String
		{
			return "Expand tree";
		}
		
		public static function get commandCollapseTree():String
		{
			return "Collapse tree";
		}
		
		public static function get commandAddRow():String
		{
			return "Add row";
		}
		
		public static function get commandDeleteRows():String
		{
			return "Delete rows";
		}
		
		public static function get commandDuplicateRows():String
		{
			return "Duplicate rows";
		}
		
		public static function get commandAddColumn():String
		{
			return "Add column";
		}
		
		public static function get commandEditColumn():String
		{
			return "Edit column";
		}
		
		public static function get commandDeleteColumn():String
		{
			return "Delete column";
		}
		
		public static function get commandMoveColumn():String
		{
			return "Move column";
		}
		
		public static function get commandCreateTable():String
		{
			return "Create table";
		}
		
		public static function get commandDeleteTables():String
		{
			return "Delete tables";
		}
		
		public static function get commandEditTable():String
		{
			return "Edit table props";
		}
		
		public static function get textNumEntries():String
		{
			return "Num entries:";
		}
		
		public static function get textNumSelectedEntries():String
		{
			return "Selected:";
		}
		
		public static function get textCannotDeleteRows():String
		{
			return "Can not delete locked rows with ids:";
		}
		
		public static function get textCannotDuplicateRows():String
		{
			return "Can not duplicate locked rows with ids:";
		}
		
		public static function get textNothingSelected():String
		{
			return "Nothing selected";
		}
		
		public static function get textName():String
		{
			return "Name";
		}
		
		public static function get textType():String
		{
			return "Type";
		}
		
		public static function get textContainer():String
		{
			return "Container";
		}
		
		public static function get textForInnerTable():String
		{
			return "For inner table";
		}
		
		public static function get textDefaultValue():String
		{
			return "Default value";
		}
		
		public static function get textDefault():String
		{
			return "<Default>";
		}
		
		public static function get textLock():String
		{
			return "Lock";
		}
		
		public static function get textMustBeNonEmpty():String
		{
			return "Not empty";
		}
		
		public static function get textUseAsName():String
		{
			return "Use as name";
		}
		
		public static function get textTextPattern():String
		{
			return "Text pattern";
		}
		
		public static function get textFilePath():String
		{
			return "File path";
		}
		
		public static function get textFileExtension():String
		{
			return "File extension";
		}
		
		public static function get textFileImageSize():String
		{
			return "Image size";
		}
		
		public static function get textSelectMeta():String
		{
			return "Table meta";
		}
		
		public static function get textTag():String
		{
			return "Tag";
		}
		
		public static function get textDescription():String
		{
			return "Description";
		}
		
		public static function get textMeta():String
		{
			return "Meta";
		}
		public static function get textCounter():String
		{
			return "Counter";
		}
		
		public static function get textCreateNewTable():String
		{
			return "Create new table";
		}
		public static function get textAddNewColumn():String
		{
			return "Add new column";
		}
		
		public static function get textEditTable():String
		{
			return "Edit table";
		}
		
		public static function get textEditColumn():String
		{
			return "Edit column";
		}
		
		public static function get textEmpty():String
		{
			return "--empty--";
		}
		
		public static function get createNewValue():String
		{
			return "--new--";
		}
		
		public static function get textMissing():String
		{
			return "missing";
		}
		
		public static function get textCanNotDeleteNotEmptyTable():String
		{
			return "Can not delete not empty tables with ids:";
		}
		
		public static function get textConfirmOpenFile():String
		{
			return "Are you sure want to open file? All unsaved changes will be lost.";
		}
		
		public static function get textConfirmCloseApp():String
		{
			return "Are you sure want to close application? All unsaved changes will be lost.";
		}
		
		public static function get textConfirmNewFile():String
		{
			return "Are you sure want to create new file? All unsaved changes will be lost.";
		}
		
		public static function get textEditLocalization():String
		{
			return "Edit localiztion";
		}
		
		public static function get textAdd():String
		{
			return "Add";
		}
		
		public static function get textDelete():String
		{
			return "Delete";
		}
		
		public static function get textEdit():String
		{
			return "Edit";
		}
		
		public static function get textEditProps():String
		{
			return "Edit props";
		}
		
		public static function get textAddSubtable():String
		{
			return "Add subtable";
		}
		
		public static function get textConfirmResetSettings():String
		{
			return "Are you sure want to reset all settings?";
		}
		
		public static function get textUploadPathName():String
		{
			return "Name";
		}
		
		public static function get textUploadPathUrl():String
		{
			return "Url";
		}
		
		public static function get textUploadPathKey():String
		{
			return "Key";
		}
		
		public static function get textUploadPathSerializerType():String
		{
			return "Serializer";
		}
		
		public static function get exportOnSave():String
		{
			return "Export on save";
		}
		
		public static function get textUploadPaths():String
		{
			return "Upload paths:";
		}
		
		public static function get textExportSettings():String
		{
			return "Export settings:";
		}
		
		public static function get textPleaseWait():String
		{
			return "Please wait...";
		}
		
		public static function get textUploadConfigComplete():String
		{
			return "Upload complete";
		}
		
		public static function get textUploadConfigError():String
		{
			return "Upload error";
		}
		
		public static function get textConfirmRemoveConfig():String
		{
			return "Are you sure want to remove remote config?";
		}
		
		public static function get textRemoveConfigComplete():String
		{
			return "Remove config complete";
		}
		
		public static function get textRemoveConfigError():String
		{
			return "Remove config error";
		}
		
		public static function get textPullConfigComplete():String
		{
			return "Pull config complete";
		}
		
		public static function get textConfirmPullConfig():String
		{
			return "Are you sure want to pull remote config?\nAll unsaved changes will be lost!";
		}
		
		public static function get textConfirmUploadConfig():String
		{
			return "Are you sure want to upload config to remote server? This will override remote config!";
		}
		
		public static function get errorInvalidKey():String
		{
			return "Error: invalid key";
		}
		
		public static function get errorUnexpectedError():String
		{
			return "Error: unexpected error";
		}
		
		public static function get errorConfigDoesNotExist():String
		{
			return "Error: remote config does not exist";
		}
		
		public static function get textPullConfigError():String
		{
			return "Pull config error";
		}
		
		public static function get btnCreate():String
		{
			return "Create";
		}
		
		public static function get btnApply():String
		{
			return "Apply";
		}
		
		public static function get btnCancel():String
		{
			return "Cancel";
		}
		
		public static function get btnYes():String
		{
			return "Yes";
		}
		
		public static function get btnOk():String
		{
			return "Ok";
		}
		
		public static function get btnResetSettings():String
		{
			return "Reset all settings";
		}
		
		public static function get textTableScale():String
		{
			return "Table scale:";
		}
		
		public static function get textFilesRoot():String
		{
			return "Files root:";
		}
		
		public static function get textTimezone():String
		{
			return "Timezone:";
		}
		
		public static function get textConfigUnmodified():String
		{
			return "Config is unmodified";
		}
		
		public static function get textNumAddedEntries():String
		{
			return "Num added entries:";
		}
		
		public static function get textNumDeletedEntries():String
		{
			return "Num deleted entries:";
		}
		
		public static function get textNumChangedEntries():String
		{
			return "Num changed entries:";
		}
		
		public static function get errorOccured():String
		{
			return "Error occured";
		}
		
		public static function get remoteConfigMissing():String
		{
			return "Remote config is missing. Continue?";
		}
		
		public static function get currentConfigIsEmprty():String
		{
			return "Current config is empty. Continue?";
		}
		
		public static function get textTable():String
		{
			return "Table:";
		}
		
		public static function get showInTable():String
		{
			return "Show in a table";
		}
		
		public static function get findUsage():String
		{
			return "Find usage";
		}
		
		public static function get chooseFilesRootDirectory():String
		{
			return "Choose files root directory";
		}
		
		public static function confirmDeleteFile(fileName:String):String
		{
			return "Are you sure want to delete a file: " + fileName + "?";
		}
		
		public static function get chooseFileForUpload():String
		{
			return "Choose a file to upload";
		}
		
		public static function get incorrectImageSize():String
		{
			return "Uploaded file has incorrect image size!";
		}
		
		public static function get errorOpeningFile():String
		{
			return "Can not open the file. Probably no default application associated with file.";
		}
		
		public static function get wholeProject():String
		{
			return "Find in the whole project"
		}
		
		public static function get tabMeta():String
		{
			return "Meta"
		}
		
		public static function get tabRows():String
		{
			return "Rows"
		}
		
		public static function get tabUsage():String
		{
			return "Usage"
		}
		
		public static function get tabLocalizations():String
		{
			return "Localizations"
		}
		
		public static function foundIn(ms:int):String
		{
			return "Found in " + ms + "ms";
		}
		
		public static function get inspect():String
		{
			return "Inspect"
		}
		
		public static function serializerName(type:int):String
		{
			switch (type)
			{
				case SerializerType.JSON_INDEXED_BEAUTIFIED:
					return "Json indexed beautified";
					
				case SerializerType.JSON_INDEXED:
					return "Json indexed";
				
				case SerializerType.JSON_ASSOCIATIVE:
					return "Json associative";
				
				case SerializerType.JSON_ASSOCIATIVE_REDUCED:
					return "Json associative reduced";
			}
			return "";
		}
		
		public static function get parsingError():String
		{
			return "Can not parse table";
		}
		
		public static function configHasDifferentSerializerType(serializerName:String, expectedSerializerName:String):String
		{
			return 'Remote config has serializer type "' + serializerName + '" but serializer type "' + expectedSerializerName + '" expected';
		}
		
		public static function get textSuffix():String
		{
			return "File suffix";
		}
		
		public static function get noDataTableForSpecifiedCounter():String
		{
			return "There are no tables that can add a new row with specified counter id.";
		}
		
		public static function get phpCodeExample():String
		{
			return "server-side php script example";
		}
		
		public static function get copy():String
		{
			return "Copy";
		}
		
		public static function get copiedToClipboard():String
		{
			return "Copied to clipboard";
		}
		
		public static function getWarningMessage(type:WarningType):String
		{
			switch (type)
			{
				case WarningType.CHECKING_EXCEPTION:
					return "Exception occurred during a check";
				
				case WarningType.MISSING_REFERENCE:
					return "Missing reference";
				
				case WarningType.MISSING_TAG:
					return "Missing tag";
				
				case WarningType.DUPLICATING_TAG:
					return "Duplicating tag";
				
				case WarningType.EMPTY_REFERENCE:
					return "Empty reference";
				
				case WarningType.MULTIPLE_USE_AS_NAME:
					return "Multiple name columns";
				
				case WarningType.MUST_BE_NON_EMPTY:
					return "Value must be not empty";
				
				case WarningType.MISSING_LOCALIZATION:
					return "Missing localization";
				
				case WarningType.MISSING_USE_AS_NAME:
					return "Missing name columns";
			}
			return "Validation error";
		}
	}
}