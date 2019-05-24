package ru.kennel32.editor.view.hud.table 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextField;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.ContainerTable;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.events.SettingsEvent;
	import ru.kennel32.editor.data.events.TableEvent;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.ScrollableCanvas;
	import ru.kennel32.editor.view.components.canvas.DelegateSizeCanvas;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.hud.table.TableColumnHeadView;
	import ru.kennel32.editor.view.hud.table.TableRowView;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.draganddrop.ColumnDragAndDropManager;
	
	public class TableView extends CanvasSprite implements IDisposable
	{
		public static const CHECKBOX_COLUMN_WIDTH:int = 30;
		public static const COLUMN_HEAD_HEIGHT:int = 50;
		public static const COLUMN_MIN_WIDTH:int = 20;
		
		private static const COUNTER_WIDTH:uint = 250;
		
		private var _data:BaseTable;
		
		private var _tableNameRegion:ExpandableRegion;
		private var _tfTableName:TextField;
		
		private var _counterRegion:ExpandableRegion;
		private var _tfCounterName:TextField;
		
		private var _tableCanvas:ScrollableCanvas;
		private var _boxContent:Sprite;
		
		private var _checkboxOffset:TableColumnHeadView;
		
		private var _boxTableTop:Sprite;
		private var _columnHeads:Vector.<TableColumnHeadView>;
		private var _boxColumnHeads:Sprite;
		
		private var _rows:Vector.<TableRowView>;
		private var _boxRows:Sprite;
		
		private var _subtables:Vector.<SubtableItemView>;
		private var _boxSubtables:Sprite;
		
		private var _tableEditPanel:TableEditPanel;
		
		public function TableView()
		{
			super();
			
			_tableNameRegion = new ExpandableRegion(RectSides.SIDES_0001, null, ExpandableRegionStyle.OUT_OF_TABLE);
			_tableNameRegion.setSize(100, 30);
			addChild(_tableNameRegion);
			
			_tfTableName = TextUtils.getText('', Color.FONT, 16);
			_tfTableName.x = 3;
			_tfTableName.y = 3;
			_tfTableName.selectable = true;
			addChild(_tfTableName);
			
			_counterRegion = new ExpandableRegion(RectSides.SIDES_1000, null, ExpandableRegionStyle.MINOR);
			_counterRegion.setSize(COUNTER_WIDTH, 30);
			addChild(_counterRegion);
			
			_tfCounterName = TextUtils.getText('', Color.FONT, 16);
			_tfCounterName.y = _tfTableName.y;
			_tfCounterName.selectable = true;
			addChild(_tfCounterName);
			
			_tableEditPanel = new TableEditPanel(this);
			addChild(_tableEditPanel);
			
			_tableCanvas = new ScrollableCanvas();
			_tableCanvas.x = 0;
			_tableCanvas.y = _tableNameRegion.height;
			addChild(_tableCanvas);
			
			_boxContent = new DelegateSizeCanvas(
				function():Number { return _boxTableTop.width; },
				function():Number { return _boxRows.y + _boxRows.height; }
			);
			
			_rows = new Vector.<TableRowView>();
			
			_boxRows = new Sprite();
			_boxRows.x = 0;
			_boxRows.y = COLUMN_HEAD_HEIGHT;
			_boxContent.addChild(_boxRows);
			
			_subtables = new Vector.<SubtableItemView>();
			
			_boxSubtables = new Sprite();
			_boxSubtables.x = 0;
			_boxSubtables.y = COLUMN_HEAD_HEIGHT;
			_boxContent.addChild(_boxSubtables);
			
			_boxTableTop = new Sprite();
			_boxContent.addChild(_boxTableTop);
			
			_checkboxOffset = new TableColumnHeadView(true);
			_checkboxOffset.setSize(CHECKBOX_COLUMN_WIDTH, COLUMN_HEAD_HEIGHT);
			_boxTableTop.addChild(_checkboxOffset);
			
			_columnHeads = new Vector.<TableColumnHeadView>();
			
			_boxColumnHeads = new Sprite();
			_boxColumnHeads.x = CHECKBOX_COLUMN_WIDTH;
			_boxTableTop.addChild(_boxColumnHeads);
			
			mouseEnabled = false;
		}
		
		public function init():void
		{
			Main.instance.addEventListener(TableEvent.TABLE_SELECTION_CHANGED, onTableSelectionChanged);
			
			Settings.addEventListener(SettingsEvent.TABLE_SCALE_CHANGED, onTableScaleChanged);
			onTableScaleChanged();
			
			_checkboxOffset.initContextMenu();
			_tableCanvas.init();
			_tableEditPanel.init();
		}
		
		public function dispose():void
		{
			Main.instance.removeEventListener(TableEvent.TABLE_SELECTION_CHANGED, onTableSelectionChanged);
			
			Settings.removeEventListener(SettingsEvent.TABLE_SCALE_CHANGED, onTableScaleChanged);
			
			_tableCanvas.dispose();
			_tableEditPanel.dispose();
			_checkboxOffset.dispose();
			cleanup();
		}
		
		override public function setSize(width:int = -1, height:int = -1):void
		{
			super.setSize(width, height);
			
			_tableNameRegion.setSize(_width, -1);
			_counterRegion.x = _width - _counterRegion.width;
			_tfCounterName.x = _counterRegion.x + 3;
			
			_tableCanvas.setSize(_width - _tableCanvas.x, _height - _tableEditPanel.height - _tableCanvas.y);
			
			_tableEditPanel.setSize(_width, -1);
			_tableEditPanel.y = _height - _tableEditPanel.height;
		}
		
		public function get data():BaseTable
		{
			return _data;
		}
		
		public function set data(value:BaseTable):void
		{
			if (_data == value)
			{
				return;
			}
			
			cleanup();
			
			_data = value;
			if (_data == null)
			{
				return;
			}
			
			var isDataTable:Boolean = _data is DataTable;
			if (isDataTable)
			{
				if (_boxSubtables.parent != null)
				{
					_boxSubtables.parent.removeChild(_boxSubtables);
				}
				_boxContent.addChildAt(_boxRows, 0);
			}
			else
			{
				if (_boxRows.parent != null)
				{
					_boxRows.parent.removeChild(_boxRows);
				}
				_boxContent.addChildAt(_boxSubtables, 0);
			}
			
			addListeners();
			
			_tableCanvas.setContent(_boxContent);
			_tableCanvas.keepYConstFor = _boxTableTop;
			_tableCanvas.visible = true;
			
			updateOnMetaChanged();
			
			var currentX:int;
			for (var i:int = 0; i < _data.meta.allColumns.length; i++)
			{
				var columnDescription:TableColumnDescription = _data.meta.allColumns[i];
				var isOwnColumn:Boolean = _data.meta.columns.indexOf(columnDescription) > -1;
				
				var columnHead:TableColumnHeadView = new TableColumnHeadView(!isOwnColumn);
				columnHead.minWidth = COLUMN_MIN_WIDTH;
				columnHead.addEventListener(Event.RESIZE, onColumnHeadResized);
				
				columnHead.data = columnDescription;
				columnHead.setSize(columnDescription.width, COLUMN_HEAD_HEIGHT);
				columnHead.x = currentX;
				currentX += columnHead.width;
				
				_boxColumnHeads.addChild(columnHead);
				_columnHeads.push(columnHead);
				
				if (isOwnColumn && !columnDescription.lock)
				{
					ColumnDragAndDropManager.instance.registerColumn(columnHead, data);
				}
			}
			
			syncRows();
			syncSubtables();
			
			_tableEditPanel.onDataChanged();
		}
		
		private function updateOnMetaChanged():void
		{
			_tfTableName.text = _data.meta.id + '.' + _data.meta.name;
			_tfCounterName.text = _data.meta.counterId <= 0 ? Texts.textEmpty : (_data.meta.counterId + '.' + Main.instance.rootTable.cache.getCounterById(_data.meta.counterId).name);
			
			Main.instance.mainUI.playAttentionEffect(_tfTableName);
			Main.instance.mainUI.playAttentionEffect(_tfCounterName);
		}
		
		private function cleanup():void
		{
			_tableCanvas.visible = false;
			_tableCanvas.setContent(null);
			
			_tfTableName.text = '';
			_tfCounterName.text = '';
			
			while (_columnHeads.length > 0)
			{
				var columnHead:TableColumnHeadView = _columnHeads.pop();
				
				if (columnHead.parent != null)
				{
					columnHead.parent.removeChild(columnHead);
				}
				columnHead.data = null;
				columnHead.removeEventListener(Event.RESIZE, onColumnHeadResized);
				columnHead.dispose();
				
				ColumnDragAndDropManager.instance.unregisterColumn(columnHead);
			}
			
			while (_rows.length > 0)
			{
				deleteRow(_rows[_rows.length - 1]);
			}
			
			while (_subtables.length > 0)
			{
				deleteSubtable(_subtables[_subtables.length - 1]);
			}
			
			if (_data != null)
			{
				removeListeners();
				_data = null;
			}
		}
		
		private function addListeners():void
		{
			_data.addEventListener(TableEvent.ROWS_ADDED, onRowsAdded);
			_data.addEventListener(TableEvent.ROWS_DELETED, onRowsDeleted);
			_data.addEventListener(TableEvent.META_CHANGED, onMetaChanged);
			_data.addEventListener(TableEvent.COLUMN_ADDED, onColumnAdded);
			_data.addEventListener(TableEvent.COLUMN_REMOVED, onColumnRemoved);
			_data.addEventListener(TableEvent.COLUMN_MOVED, onColumnMoved);
			_data.addEventListener(TableEvent.COLUMN_CHANGED, onColumnChanged);
			Main.instance.addEventListener(TableEvent.TABLES_ADDED, onTableAdded);
			Main.instance.addEventListener(TableEvent.TABLES_DELETED, onTablesDeleted);
		}
		
		private function removeListeners():void
		{
			_data.removeEventListener(TableEvent.ROWS_ADDED, onRowsAdded);
			_data.removeEventListener(TableEvent.ROWS_DELETED, onRowsDeleted);
			_data.removeEventListener(TableEvent.META_CHANGED, onMetaChanged);
			_data.removeEventListener(TableEvent.COLUMN_ADDED, onColumnAdded);
			_data.removeEventListener(TableEvent.COLUMN_REMOVED, onColumnRemoved);
			_data.removeEventListener(TableEvent.COLUMN_MOVED, onColumnMoved);
			_data.removeEventListener(TableEvent.COLUMN_CHANGED, onColumnChanged);
			Main.instance.removeEventListener(TableEvent.TABLES_ADDED, onTableAdded);
			Main.instance.removeEventListener(TableEvent.TABLES_DELETED, onTablesDeleted);
		}
		
		private var _lockedResize:Boolean;
		private function onColumnHeadResized(e:Event):void
		{
			if (_lockedResize)
			{
				return;
			}
			
			var i:int = _columnHeads.indexOf(e.currentTarget as TableColumnHeadView);
			if (i <= -1)
			{
				return;
			}
			
			_lockedResize = true;
			
			var columnHead:TableColumnHeadView = _columnHeads[i];
			columnHead.setSize((e.target as CanvasSprite).width, -1);
			columnHead.data.width = columnHead.width;
			updateColumnsPositions();
			
			_tableCanvas.updateControls(false);
			
			_lockedResize = false;
		}
		
		private function onRowResized(e:Event):void
		{
			var i:int = _rows.indexOf(e.target as TableRowView);
			if (i <= -1)
			{
				return;
			}
			
			updateRowsPositions();
		}
		
		private function updateColumnsPositions():void
		{
			var currentX:int;
			for (var i:int = 0; i < _data.meta.allColumns.length; i++)
			{
				var culumnDescription:TableColumnDescription = _data.meta.allColumns[i];
				var columnHead:TableColumnHeadView = _boxColumnHeads.getChildAt(i) as TableColumnHeadView;
				columnHead.x = currentX;
				currentX += columnHead.width;
			}
			
			var dataTable:DataTable = _data as DataTable;
			if (dataTable != null)
			{
				for (i = 0; i < dataTable.rows.length; i++)
				{
					var row:TableRowView = _boxRows.getChildAt(i) as TableRowView;
					row.updateColumnsPositions();
				}
			}
		}
		
		private function updateRowsPositions():void
		{
			var dataTable:DataTable = _data as DataTable;
			var currentY:int;
			if (dataTable != null)
			{
				for (var i:int = 0; i < dataTable.rows.length; i++)
				{
					var row:TableRowView = _boxRows.getChildAt(i) as TableRowView;
					row.y = currentY;
					currentY += row.height;
				}
			}
			
			_tableCanvas.updateControls(false);
		}
		
		private function updateSubtablesPositions():void
		{
			var containerTable:ContainerTable = _data as ContainerTable;
			var currentY:int;
			if (containerTable != null)
			{
				for (var i:int = 0; i < containerTable.children.length; i++)
				{
					var subtable:SubtableItemView = _boxSubtables.getChildAt(i) as SubtableItemView;
					subtable.y = currentY;
					currentY += subtable.height;
				}
			}
			
			_tableCanvas.updateControls(false);
		}
		
		private function onTableSelectionChanged(e:Event):void
		{
			data = Main.instance.selectedTable;
		}
		
		private function onRowCheckedChanged(e:Event):void
		{
			_tableEditPanel.onRowsSelectedChanged();
		}
		
		internal function getCheckedRows():Vector.<TableRowView>
		{
			var res:Vector.<TableRowView> = new Vector.<TableRowView>();
			
			for each (var row:TableRowView in _rows)
			{
				if (row.checked)
				{
					res.push(row);
				}
			}
			
			return res;
		}
		
		private function onRowsAdded(e:TableEvent):void
		{
			syncRows();
			_tableEditPanel.onDataChanged();
			
			scrollToRow(e.rows[e.rows.length - 1]);
		}
		
		private function onRowsDeleted(e:Event):void
		{
			syncRows();
			_tableEditPanel.onDataChanged();
		}
		
		private function onTableAdded(e:TableEvent):void
		{
			if (e.table == _data)
			{
				syncSubtables();
				_tableEditPanel.onDataChanged();
			}
		}
		
		private function onTablesDeleted(e:TableEvent):void
		{
			if (e.table == _data)
			{
				syncSubtables();
				_tableEditPanel.onDataChanged();
			}
		}
		
		private function syncRows():void
		{
			var dataTable:DataTable = _data as DataTable;
			if (dataTable != null)
			{
				for (var i:int = 0; i < dataTable.rows.length; i++)
				{
					if (i > _rows.length - 1)
					{
						var row:TableRowView = new TableRowView();
						row.data = dataTable.rows[i];
						row.data.addEventListener(TableEvent.ROW_CHECKED_CHANGED, onRowCheckedChanged);
						row.addEventListener(Event.RESIZE, onRowResized);
						
						_boxRows.addChild(row);
						_rows.push(row);
					}
					else
					{
						if (_rows[i].data != dataTable.rows[i])
						{
							deleteRow(_rows[i]);
							i--;
						}
					}
				}
			}
			
			var dataLength:int = dataTable == null ? 0 : dataTable.rows.length;
			while (_rows.length > dataLength)
			{
				deleteRow(_rows[_rows.length - 1]);
			}
			
			updateRowsPositions();
		}
		
		private function deleteRow(row:TableRowView):void
		{
			if (row.parent != null)
			{
				row.parent.removeChild(row);
			}
			row.data.removeEventListener(TableEvent.ROW_CHECKED_CHANGED, onRowCheckedChanged);
			row.removeEventListener(Event.RESIZE, onRowResized);
			row.data = null;
			row.dispose();
			
			_rows.splice(_rows.indexOf(row), 1);
		}
		
		internal function getCheckedSubtables():Vector.<SubtableItemView>
		{
			var res:Vector.<SubtableItemView> = new Vector.<SubtableItemView>();
			
			for each (var subtable:SubtableItemView in _subtables)
			{
				if (subtable.checked)
				{
					res.push(subtable);
				}
			}
			
			return res;
		}
		
		private function onSubtableCheckedChanged(e:Event):void
		{
			_tableEditPanel.onRowsSelectedChanged();
		}
		
		internal function get rows():Vector.<TableRowView>
		{
			return _rows;
		}
		
		internal function get subtables():Vector.<SubtableItemView>
		{
			return _subtables;
		}
		
		private function onSubtableAdded(e:Event):void
		{
			syncSubtables();
			_tableEditPanel.onDataChanged();
		}
		
		private function onSubtablesRemoved(e:Event):void
		{
			syncSubtables();
			_tableEditPanel.onDataChanged();
		}
		
		private function syncSubtables():void
		{
			var containerTable:ContainerTable = _data as ContainerTable;
			if (containerTable != null)
			{
				for (var i:int = 0; i < containerTable.children.length; i++)
				{
					if (i > _subtables.length - 1)
					{
						var subtable:SubtableItemView = new SubtableItemView(i == 0);
						subtable.data = containerTable.children[i];
						subtable.data.addEventListener(TableEvent.TABLE_CHECKED_CHANGED, onSubtableCheckedChanged);
						
						_boxSubtables.addChild(subtable);
						_subtables.push(subtable);
					}
					else
					{
						if (_subtables[i].data != containerTable.children[i])
						{
							deleteSubtable(_subtables[i]);
							i--;
						}
					}
				}
			}
			
			var dataLength:int = containerTable == null ? 0 : containerTable.children.length;
			while (_subtables.length > dataLength)
			{
				deleteSubtable(_subtables[_subtables.length - 1]);
			}
			
			updateSubtablesPositions();
		}
		
		private function deleteSubtable(subtable:SubtableItemView):void
		{
			if (subtable.parent != null)
			{
				subtable.parent.removeChild(subtable);
			}
			subtable.data.removeEventListener(TableEvent.TABLE_CHECKED_CHANGED, onSubtableCheckedChanged);
			subtable.data = null;
			subtable.dispose();
			
			_subtables.splice(_subtables.indexOf(subtable), 1);
		}
		
		private function onMetaChanged(e:Event):void
		{
			updateOnMetaChanged();
		}
		
		private function onColumnAdded(e:Event):void
		{
			onColumnChanged(null);
		}
		
		private function onColumnRemoved(e:Event):void
		{
			onColumnChanged(null);
		}
		
		private function onColumnMoved(e:Event):void
		{
			onColumnChanged(null);
		}
		
		private function onColumnChanged(e:Event):void
		{
			var contentX:int = _boxContent.x;
			var contentY:int = _boxContent.y;
			
			var oldData:BaseTable = _data;
			cleanup();
			data = oldData;
			
			Main.instance.mainUI.playAttentionEffect(_boxTableTop);
			
			_tableCanvas.setContentPosition(contentX, contentY);
		}
		
		private function scrollToRow(row:TableRow):void
		{
			for each (var rowView:TableRowView in _rows)
			{
				if (rowView.data == row)
				{
					_tableCanvas.focusOn(rowView);
					return;
				}
			}
		}
		
		public function get currentScrollPosition():Point
		{
			return new Point(_boxContent.x, _boxContent.y);
		}
		public function setScrollPosition(pos:Point):void
		{
			_boxContent.x = pos.x;
			_boxContent.y = pos.y;
			_tableCanvas.updateControls(false);
		}
		
		public function focusOn(row:TableRow):void
		{
			for (var i:int = 0; i < _boxRows.numChildren; i++)
			{
				var rowView:TableRowView = _boxRows.getChildAt(i) as TableRowView;
				if (rowView.data == row)
				{
					_tableCanvas.focusOn(rowView);
				}
			}
		}
		
		private function onTableScaleChanged(e:Event = null):void
		{
			_boxContent.scaleX = _boxContent.scaleY = Settings.tableScale;
			_tableCanvas.updateControls(false);
		}
	}
}