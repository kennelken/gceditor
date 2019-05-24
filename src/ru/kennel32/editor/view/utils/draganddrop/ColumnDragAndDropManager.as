package ru.kennel32.editor.view.utils.draganddrop
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.commands.MoveColumnCommand;
	import ru.kennel32.editor.data.events.AppEvent;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.hud.table.TableColumnHeadView;
	import ru.kennel32.editor.view.mouse.MouseUtils;
	
	public class ColumnDragAndDropManager
	{
		private static const OFFSET_TO_START_DRAG:int = 7;
		private static const OFFSET_TO_CHANGE_INDEX:int = 20;
		
		private static var _instance:ColumnDragAndDropManager;
		public static function get instance():ColumnDragAndDropManager
		{
			return _instance;
		}
		
		public function ColumnDragAndDropManager()
		{
			_registeredColumns = new Vector.<RegisteredEntryData>();
			_registeredColumnsByColumn = new Dictionary();
			
			_newPositionPointer = new Shape();
			_newPositionPointer.graphics.beginFill(Color.FORM_BODY, 1);
			_newPositionPointer.graphics.lineStyle(1, Color.BORDER);
			_newPositionPointer.graphics.lineTo(10, 30);
			_newPositionPointer.graphics.lineTo(-10, 30);
			_newPositionPointer.graphics.lineTo(0, 0);
			_newPositionPointer.graphics.endFill();
		}
		
		private var _stage:Stage;
		private var _registeredColumns:Vector.<RegisteredEntryData>;
		private var _registeredColumnsByColumn:Dictionary;
		private var _columnsIndexes:Dictionary;
		
		private var _newPositionPointer:Shape;
		
		public static function init():void
		{
			_instance = new ColumnDragAndDropManager();
			_instance.init();
		}
		
		private function init():void
		{
			_stage = Main.instance.stage;
			
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			Main.instance.addEventListener(AppEvent.INTERRUPT_ACTIONS, resetCurrentDragAndDrop);
		}
		
		public function registerColumn(column:TableColumnHeadView, table:BaseTable):void
		{
			if (_registeredColumnsByColumn[column] !== undefined)
			{
				return;
			}
			
			var entry:RegisteredEntryData = new RegisteredEntryData(column, table);
			_registeredColumns.push(entry);
			_registeredColumnsByColumn[column] = entry;
		}
		
		public function unregisterColumn(column:TableColumnHeadView):void
		{
			var entry:RegisteredEntryData = _registeredColumnsByColumn[column];
			if (entry == null)
			{
				return;
			}
			
			_registeredColumns.splice(_registeredColumns.indexOf(entry), 1);
			delete _registeredColumnsByColumn[entry.column];
			
			if (_currentDragEntry != null && _currentDragEntry.column == column)
			{
				resetCurrentDragAndDrop();
			}
		}
		
		private var _currentDragEntry:RegisteredEntryData;
		
		private function onStageMouseDown(e:MouseEvent):void
		{
			if (MouseUtils.isCustomMode)
			{
				return;
			}
			
			for each (var entry:RegisteredEntryData in _registeredColumns)
			{
				if (entry.column.contains(e.target as DisplayObject))
				{
					_currentDragEntry = entry;
					_currentDragEntry.startDragMousePosition = new Point(_currentDragEntry.box.mouseX, _currentDragEntry.box.mouseY);
					_currentDragEntry.started = false;
					
					_stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
					_stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
				}
			}
		}
		
		private function onStageMouseMove(e:Event):void
		{
			if (!_currentDragEntry.started)
			{
				if (Math.abs(_currentDragEntry.box.mouseX - _currentDragEntry.startDragMousePosition.x) > OFFSET_TO_START_DRAG ||
					Math.abs(_currentDragEntry.box.mouseY - _currentDragEntry.startDragMousePosition.y) > OFFSET_TO_START_DRAG)
				{
					_currentDragEntry.startDragPosition = new Point(_currentDragEntry.column.x, _currentDragEntry.column.y);
					_currentDragEntry.startDragMousePosition = new Point(_currentDragEntry.box.mouseX, _currentDragEntry.box.mouseY);
					_currentDragEntry.startDragChildIndex = _currentDragEntry.box.getChildIndex(_currentDragEntry.column);
					_currentDragEntry.startDragAlpha = _currentDragEntry.column.alpha;
					_currentDragEntry.started = true;
					
					_columnsIndexes = new Dictionary();
					var j:int = 0;
					for (var i:int = 0; i < _currentDragEntry.box.numChildren; i++)
					{
						var child:TableColumnHeadView = _currentDragEntry.box.getChildAt(i) as TableColumnHeadView;
						if (child == null)
						{
							continue;
						}
						
						_columnsIndexes[child] = j;
						j++;
					}
					
					_currentDragEntry.box.setChildIndex(_currentDragEntry.column, _currentDragEntry.box.numChildren - 1);
					_currentDragEntry.column.alpha = 0.4;
				}
			}
			
			if (!_currentDragEntry.started)
			{
				return;
			}
			
			_currentDragEntry.column.x = _currentDragEntry.startDragPosition.x + (_currentDragEntry.box.mouseX - _currentDragEntry.startDragMousePosition.x);
			_currentDragEntry.column.y = _currentDragEntry.startDragPosition.y + (_currentDragEntry.box.mouseY - _currentDragEntry.startDragMousePosition.y);
			
			updatePointer();
		}
		
		private function updatePointer():void
		{
			var newIndex:int = getNewIndex();
			if (newIndex > -1)
			{
				var maxIndex:int = -1;
				var maxIndexChild:TableColumnHeadView;
				
				for (var entry:Object in _columnsIndexes)
				{
					var child:TableColumnHeadView = entry as TableColumnHeadView;
					
					if (_columnsIndexes[child] == newIndex)
					{
						var pos:Point = new Point(child.x, child.y + child.height);
						break;
					}
					
					if (_columnsIndexes[child] > maxIndex)
					{
						maxIndex = _columnsIndexes[child];
						maxIndexChild = child;
					}
				}
				
				if (pos == null && maxIndexChild != null)
				{
					pos = new Point(maxIndexChild.x + maxIndexChild.width, maxIndexChild.y + maxIndexChild.height);
				}
				
				if (pos != null)
				{
					pos = _currentDragEntry.box.localToGlobal(pos);
					_newPositionPointer.x = pos.x;
					_newPositionPointer.y = pos.y;
				}
			}
			
			if (pos != null && _newPositionPointer.parent == null)
			{
				_stage.addChild(_newPositionPointer);
			}
			else if (pos == null && _newPositionPointer.parent != null)
			{
				_newPositionPointer.parent.removeChild(_newPositionPointer);
			}
		}
		
		private function onStageMouseUp(e:Event):void
		{
			if (_currentDragEntry.startDragPosition != null)
			{
				var newIndex:int = e == null ? -1 : getNewIndex();
				if (newIndex > -1)
				{
					var oldIndex:int = _columnsIndexes[_currentDragEntry.column];
					if (newIndex > oldIndex)
					{
						newIndex--;
					}
					
					var command:MoveColumnCommand = new MoveColumnCommand(_currentDragEntry.table, _currentDragEntry.column.data, newIndex);
				}
				
				_currentDragEntry.column.x = _currentDragEntry.startDragPosition.x;
				_currentDragEntry.column.y = _currentDragEntry.startDragPosition.y;
				
				_currentDragEntry.box.setChildIndex(_currentDragEntry.column, _currentDragEntry.startDragChildIndex);
				_currentDragEntry.column.alpha = _currentDragEntry.startDragAlpha;
				
				if (_newPositionPointer.parent != null)
				{
					_newPositionPointer.parent.removeChild(_newPositionPointer);
				}
			}
			
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			
			_currentDragEntry = null;
			
			if (command != null)
			{
				doMoveColumnIfRequired(command);
			}
		}
		
		private function doMoveColumnIfRequired(command:MoveColumnCommand):void
		{
			if (command.check())
			{
				Main.instance.commandsHistory.addCommandAndExecute(command);
			}
		}
		
		public function resetCurrentDragAndDrop(...args):void
		{
			if (_currentDragEntry != null)
			{
				onStageMouseUp(null);
			}
		}
		
		public function getNewIndex():int
		{
			var centerX:int = _currentDragEntry.box.mouseX;
			for (var i:int = 0; i < _currentDragEntry.box.numChildren; i++)
			{
				var newIndex:int = -1;
				
				var child:TableColumnHeadView = _currentDragEntry.box.getChildAt(i) as TableColumnHeadView;
				if (child == null || child == _currentDragEntry.column)
				{
					continue;
				}
				
				if (Math.abs(centerX - child.x) < OFFSET_TO_CHANGE_INDEX)
				{
					newIndex = _columnsIndexes[child];
				}
				else if (Math.abs(centerX - (child.x + child.width)) < OFFSET_TO_CHANGE_INDEX)
				{
					newIndex = _columnsIndexes[child] + 1;
				}
				
				if (newIndex > -1)
				{
					if (newIndex != _columnsIndexes[_currentDragEntry.column] &&
						newIndex != _columnsIndexes[_currentDragEntry.column] + 1)
					{
						return newIndex;
					}
				}
			}
			
			return -1;
		}
	}
}


import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import ru.kennel32.editor.data.table.BaseTable;
import ru.kennel32.editor.view.hud.table.TableColumnHeadView;

internal class RegisteredEntryData
{
	public var column:TableColumnHeadView;
	public var table:BaseTable;
	
	public var box:DisplayObjectContainer;
	public var started:Boolean;
	public var startDragPosition:Point;
	public var startDragMousePosition:Point;
	public var startDragChildIndex:int;
	public var startDragAlpha:Number;
	
	public function RegisteredEntryData(column:TableColumnHeadView, table:BaseTable)
	{
		this.column = column;
		this.table = table;
		
		box = column.parent;
		
		if (box == null)
		{
			throw new Error('column head must have parent');
		}
	}
}