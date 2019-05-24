package ru.kennel32.editor.view.components.selectbox 
{
	import flash.events.Event;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.commands.AddRowCommand;
	import ru.kennel32.editor.data.commands.InspectRowCommand;
	import ru.kennel32.editor.view.components.selectbox.SelectValueBox;
	import ru.kennel32.editor.view.forms.SelectValueForm;
	import ru.kennel32.editor.view.forms.dialog.DialogFormParams;
	import ru.kennel32.editor.view.forms.dialog.content.InspectRowDialogContent;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class SelectItemBox extends SelectValueBox 
	{
		private var _counterId:uint;
		public function SelectItemBox(width:int = -1, height:int = -1, border:Boolean = true) 
		{
			super(width, height, true, border);
			
			addEventListener(SelectBoxEvent.CREATE_NEW_ITEM, onCreateNewItem);
		}
		public function get counterId():uint
		{
			return _counterId;
		}
		public function setTableItem(id:uint, counterId:uint):void
		{
			_counterId = counterId;
			
			updateValues(id);
		}
		
		override protected function onMouseClick(e:Event):void 
		{
			if (ViewUtils.isForInspect(e))
			{
				e.preventDefault();
				e.stopImmediatePropagation();
				
				var row:TableRow = Main.instance.rootTable.cache.getRowById(uint(_currentValue.value), _counterId);
				if (row != null)
				{
					InspectRowDialogContent.showRow(row);
					return;
				}
			}
			
			super.onMouseClick(e);
		}
		
		private function updateValues(id:uint):void
		{
			var values:Vector.<SelectBoxValue> = new Vector.<SelectBoxValue>();
			values.push(new SelectBoxValue(0, Texts.textEmpty, true));
			
			var counter:Counter = Main.instance.rootTable.cache.getCounterById(_counterId);
			var counterValue:uint = counter == null ? 0 : counter.getNextIndex(0);
			for (var i:int = 1; i <= counterValue; i++)
			{
				var row:TableRow = Main.instance.rootTable.cache.getRowById(i, _counterId);
				if (row != null)
				{
					values.push(new SelectBoxValue(row.id, row.nameWithId, false, !row.allowForUseinSelectItem));
				}
			}
			
			setValue(id, values);
			
			var currentValue:SelectBoxValue = getItemByValue(id);
			_tfCurrentItem.text = currentValue == null ? (id + "(" + Texts.textMissing + ")") : currentValue.name;
		}
		
		private function onCreateNewItem(e:Event):void
		{
			var allTables:Vector.<BaseTable> = Main.instance.rootTable.cache.getTablesByCounterId(_counterId);
			allTables = allTables.filter(filterOnlyDataTables);
			chooseOneDataTable(allTables, onDataTableChoosed);
		}
		
		private function onDataTableChoosed(table:DataTable):void
		{
			if (table == null)
			{
				DialogFormParams.create()
					.setText(Texts.noDataTableForSpecifiedCounter)
					.show();
			}
			else
			{
				var newRow:TableRow = table.createNewRow(1);
				Main.instance.commandsHistory.addCommandAndExecute(new AddRowCommand(table, newRow));
				updateValues(newRow.id);
				dispatchEvent(new Event(Event.CHANGE));
				Main.instance.commandsHistory.addCommandAndExecute(new InspectRowCommand(newRow));
			}
		}
		
		private function filterOnlyDataTables(table:BaseTable, ...args):Boolean
		{
			return table is DataTable;
		}
		
		private function chooseOneDataTable(list:Vector.<BaseTable>, callback:Function):void
		{
			if (list.length > 1)
			{
				var values:Vector.<SelectBoxValue> = new Vector.<SelectBoxValue>();
				for each (var table:DataTable in list)
				{
					values.push(new SelectBoxValue(table, ViewUtils.getTableName(table.meta.id)));
				}
				SelectValueForm.show(this, values, onDataTableChoosed);
			}
			else
			{
				callback(list.length > 0 ? list[0] as DataTable : null);
			}
		}
	}
}