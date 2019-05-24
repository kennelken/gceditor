package ru.kennel32.editor.view.hud.table.cells
{
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.commands.AddRowCommand;
	import ru.kennel32.editor.data.commands.ChangeStringValueCommand;
	import ru.kennel32.editor.data.utils.LocalizationUtils;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.forms.dialog.content.InspectRowDialogContent;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class TextPatternTableRowCellView extends BaseTableRowCellView
	{
		private var _tf:TextField;
		
		public function TextPatternTableRowCellView()
		{
			super();
			
			_tf = TextUtils.getText('', Color.FONT, 16, null, true, -3);
			_tf.selectable = true;
			_tf.autoSize = TextFieldAutoSize.NONE;
			_tf.height = DEFAULT_TF_HEIGHT;
			
			addChild(_tf);
			
			_type = TableColumnDescriptionType.TEXT_PATTERN;
			
			addEventListener(MouseEvent.CLICK, onMouseClick, false, int.MAX_VALUE);
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_tf.x = 3;
			_tf.y = (_height - _tf.height) / 2 - 1;
			_tf.width = _width - _tf.x * 2 - 1;
		}
		
		override public function updateValue():void 
		{
			super.updateValue();
			
			_tf.text = Main.instance.rootTable.cache.getLocalization(LocalizationUtils.getKey(_columnData.textPattern, _tableRow.id));
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			if (!ViewUtils.isForInspect(e))
			{
				return;
			}
			
			e.preventDefault();
			e.stopImmediatePropagation();
			
			var localizationKey:String = LocalizationUtils.getKey(_columnData.textPattern, _tableRow.id);
			
			var tagIndex:int = 1;
			
			var table:DataTable = Main.instance.rootTable.cache.localizationTable as DataTable;
			for each (var localizationRow:TableRow in table.rows)
			{
				if (localizationRow.data[tagIndex] == localizationKey)
				{
					var row:TableRow = localizationRow;
					break;
				}
			}
			
			if (row == null)
			{
				row = table.createNewRow(1);
				
				Main.instance.commandsHistory.addCommandAndExecute(new AddRowCommand(table, row));
				
				Main.instance.commandsHistory.addCommandAndExecute(new ChangeStringValueCommand(row, tagIndex, row.data[tagIndex], localizationKey));
			}
			
			InspectRowDialogContent.showRow(row);
		}
	}
}