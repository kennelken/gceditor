package ru.kennel32.editor.view.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.BaseTable;
	import ru.kennel32.editor.data.table.Counter;
	import ru.kennel32.editor.data.table.DataTable;
	import ru.kennel32.editor.data.table.TableColumnDescription;
	import ru.kennel32.editor.data.table.TableColumnDescriptionType;
	import ru.kennel32.editor.data.utils.ParseUtils;
	import ru.kennel32.editor.view.interfaces.ICustomSizeable;
	
	public class ViewUtils
	{
		public static function getContentWidth(dobj:DisplayObject):int
		{
			if (dobj == null)
			{
				return 0;
			}
			if (dobj is ICustomSizeable)
			{
				return dobj.width;
			}
			var rect:Rectangle = dobj.getRect(dobj);
			return rect.x + rect.width;
		}
		
		public static function getContentHeight(dobj:DisplayObject):int
		{
			if (dobj == null)
			{
				return 0;
			}
			if (dobj is ICustomSizeable)
			{
				return dobj.height;
			}
			var rect:Rectangle = dobj.getRect(dobj);
			return rect.y + rect.height;
		}
		
		public static function getCustomHeight(dobj:DisplayObject):int
		{
			return getCustomHeightRecursive(dobj, -1, 0, true);
		}
		public static function getCustomWidth(dobj:DisplayObject):int
		{
			return getCustomHeightRecursive(dobj, -1, 0, false);
		}
		
		private static function getCustomHeightRecursive(dobj:DisplayObject, res:int, off:int, isY:Boolean):int
		{
			var customSizeable:ICustomSizeable = dobj as ICustomSizeable;
			if (res == -1)
			{
				res = 0;
			}
			else if (customSizeable != null)
			{
				return Math.max(res, off + (isY ? customSizeable.height : customSizeable.width));
			}
			
			var dobjc:DisplayObjectContainer = dobj as DisplayObjectContainer;
			if (dobjc != null)
			{
				for (var i:int = 0; i < dobjc.numChildren; i++)
				{
					var child:DisplayObject = dobjc.getChildAt(i);
					res = Math.max(res, getCustomHeightRecursive(child, res, off + (isY ? child.y : child.x), isY));
				}
			}
			
			return res;
		}
		
		public static function setParent(child:DisplayObject, parent:DisplayObjectContainer, value:Boolean, index:int = -1):void
		{
			if (value && child.parent != parent)
			{
				if (index == -1)
				{
					index = parent.numChildren - ((child.parent == parent) ? 1 : 0);
				}
				parent.addChildAt(child, index);
			}
			else if (!value && child.parent != null)
			{
				child.parent.removeChild(child);
			}
		}
		
		public static function getTableName(metaId:uint):String
		{
			var table:BaseTable = Main.instance.rootTable.cache.getTableById(metaId);
			return metaId + (table != null ? '.' + table.meta.name : ('(' + Texts.textMissing + ')'));
		}
		
		public static function getCounterName(counterId:uint):String
		{
			var counter:Counter = Main.instance.rootTable.cache.getCounterById(counterId);
			return counterId + (counter != null ? '.' + counter.name : ('(' + Texts.textMissing + ')'));
		}
		
		public static function removeFocusFromDobj(dobj:DisplayObject):void
		{
			if (Main.stage.focus == null)
			{
				return;
			}
			
			return
				dobj == Main.stage.focus ||
				dobj is DisplayObjectContainer && (dobj as DisplayObjectContainer).contains(Main.stage.focus) ||
				Main.stage.focus is DisplayObjectContainer && (Main.stage.focus as DisplayObjectContainer).contains(dobj);
		}
		
		public static function isForDrag(e:Event):Boolean
		{
			var mouseEvent:MouseEvent = e as MouseEvent;
			var keyboardEvent:KeyboardEvent = e as KeyboardEvent;
			
			if (mouseEvent != null)
			{
				return mouseEvent.controlKey;
			}
			if (keyboardEvent != null)
			{
				return keyboardEvent.keyCode == Keyboard.CONTROL;
			}
			return false;
		}
		
		public static function isForInspect(e:Event):Boolean
		{
			var mouseEvent:MouseEvent = e as MouseEvent;
			var keyboardEvent:KeyboardEvent = e as KeyboardEvent;
			
			if (mouseEvent != null)
			{
				return	mouseEvent.altKey ||
						mouseEvent.commandKey;
			}
			if (keyboardEvent != null)
			{
				return	keyboardEvent.keyCode == Keyboard.ALTERNATE ||
						keyboardEvent.keyCode == Keyboard.COMMAND;
			}
			return false;
		}
		
		public static function isSpecialKey(e:Event):Boolean
		{
			return isForDrag(e) || isForInspect(e);
		}
		
		public static function serializersNames(types:Vector.<int>):Vector.<String>
		{
			var res:Vector.<String> = new Vector.<String>();
			for each (var type:int in types)
			{
				res.push(Texts.serializerName(type));
			}
			return res;
		}
		
		public static function parseColumnDefaultValue(column:TableColumnDescription, text:String = null):String
		{
			text = text === null ? column.defaultValue : text;
			text = text === null ? '' : text;
			
			if (column.type == TableColumnDescriptionType.INNER_TABLE)
			{
				var dataTable:DataTable = Main.instance.rootTable.cache.getTableById(column.metaId) as DataTable;
				if (dataTable != null)
				{
					return ParseUtils.writeInnerTable(ParseUtils.readInnerTable(text, dataTable.meta.columns), dataTable.meta.columns);
				}
				else
				{
					return '';
				}
			}
			else
			{
				return ParseUtils.writeValue(ParseUtils.readValue(text, column.type), column.type);
			}
		}
		
		public static function getDepth(dobj:DisplayObject):int
		{
			var res:int = 0;
			do
			{
				res++;
				dobj = dobj.parent;
			}
			while (dobj != null)
			return res;
		}
	}
}