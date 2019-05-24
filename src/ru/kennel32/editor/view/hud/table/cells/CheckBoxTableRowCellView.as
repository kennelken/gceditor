package ru.kennel32.editor.view.hud.table.cells
{
	import flash.events.Event;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.commands.ChangeBoolValueCommand;
	import ru.kennel32.editor.view.components.controls.CheckBox;
	
	public class CheckBoxTableRowCellView extends BaseTableRowCellView
	{
		private var _checkBox:CheckBox;
		
		public function CheckBoxTableRowCellView()
		{
			super();
			
			_checkBox = new CheckBox(17);
			_checkBox.addEventListener(Event.CHANGE, onChange);
			addChild(_checkBox);
			
			_type = TableColumnDescriptionType.BOOL_VALUE;
		}
		
		override public function setSize(width:int = -1, height:int = -1):void 
		{
			super.setSize(width, height);
			
			_checkBox.x = (_width - _checkBox.width) / 2;
			_checkBox.y = (_height - _checkBox.height) / 2;
		}
		
		private function onChange(e:Event):void
		{
			if (!dispatchChangeInnerTableValue(_checkBox.checked))
			{
				Main.instance.commandsHistory.addCommandAndExecute(new ChangeBoolValueCommand(_tableRow, _columnIndex, !_checkBox.checked, _checkBox.checked));
			}
		}
		
		override public function updateValue():void 
		{
			super.updateValue();
			
			_checkBox.checked = _tableRow.data[_columnIndex];
			_checkBox.enabled = !locked;
		}
	}
}