package ru.kennel32.editor.view.forms
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.common.RectSides;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.view.components.ExpandableRegion;
	import ru.kennel32.editor.view.components.ScrollableCanvas;
	import ru.kennel32.editor.view.components.selectbox.SelectBoxEvent;
	import ru.kennel32.editor.view.components.selectbox.SelectBoxValue;
	import ru.kennel32.editor.view.components.style.ExpandableRegionStyle;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.interfaces.IDraggable;
	import ru.kennel32.editor.view.utils.TextUtils;
	
	public class SelectValueForm extends BaseForm implements IDraggable
	{
		private static const HEIGHT:int = 252;
		
		private static var BORDERS_OFFSET:int = 3;
		
		private var _target:DisplayObject;
		private var _values:Vector.<SelectBoxValue>;
		private var _callback:Function;
		
		private var _region:ExpandableRegion;
		private var _listRegion:ExpandableRegion;
		private var _tfFilter:TextField;
		
		private var _boxList:Sprite;
		private var _listCanvas:ScrollableCanvas;
		
		private var _valueByTextField:Dictionary;
		private var _itemValues:Vector.<SelectBoxValue>;
		
		private var _newValue:SelectBoxValue;
		private var _allowToCreateNewValue:Boolean;
		
		public static function show(target:DisplayObject, values:Vector.<SelectBoxValue>, callback:Function, allowToCreateNewValue:Boolean = false):SelectValueForm
		{
			var instance:SelectValueForm = new SelectValueForm();
			
			instance._allowToCreateNewValue = allowToCreateNewValue;
			
			if (allowToCreateNewValue)
			{
				instance._newValue = new SelectBoxValue(instance._newValue, Texts.createNewValue, true);
				values = values.concat();
				values.push(instance._newValue);
			}
			
			instance.scaleX = instance.scaleY = Settings.tableScale;
			
			instance._target = target;
			instance._values = values;
			instance._callback = callback;
			
			instance.show();
			instance.update();
			
			return instance;
		}
		
		public function SelectValueForm()
		{
			super();
			
			_region = new ExpandableRegion(null, null, ExpandableRegionStyle.CELL_REGULAR);
			addChild(_region);
			
			_listRegion = new ExpandableRegion(RectSides.SIDES_0000, null, ExpandableRegionStyle.SELECT_ITEM_LIST);
			_listRegion.x = BORDERS_OFFSET;
			addChild(_listRegion);
			
			_tfFilter = TextUtils.getInputText(Color.FONT, 16, width);
			_tfFilter.x = BORDERS_OFFSET;
			_tfFilter.height = 22;
			_tfFilter.addEventListener(Event.CHANGE, onFilterChange);
			addChild(_tfFilter);
			
			_boxList = new Sprite();
			_boxList.mouseEnabled = false;
			_boxList.buttonMode = true;
			
			_listCanvas = new ScrollableCanvas(false, true);
			_listCanvas.x = _listRegion.x;
			addChild(_listCanvas);
		}
		
		public function update():void
		{
			var width:int = _target.width;
			
			_region.setSize(width, HEIGHT);
			_listRegion.setSize(width - BORDERS_OFFSET * 2, HEIGHT - BORDERS_OFFSET * 2 - _tfFilter.height - BORDERS_OFFSET)
			_tfFilter.width = width - 2 * BORDERS_OFFSET;
			
			_listCanvas.setSize(_listRegion.width, _listRegion.height);
			
			var targetRect:Rectangle = _target.getBounds(Main.stage);
			var atBottom:Boolean = targetRect.bottom <= Main.stage.stageHeight - HEIGHT - 2;
			if (atBottom)
			{
				_tfFilter.y = _region.height - _tfFilter.height - BORDERS_OFFSET;
				_listRegion.y = BORDERS_OFFSET;
				y = targetRect.bottom;
			}
			else
			{
				_tfFilter.y = BORDERS_OFFSET;
				_listRegion.y = HEIGHT - BORDERS_OFFSET - _listRegion.height;
				y = targetRect.top - HEIGHT;
			}
			_listCanvas.y = _listRegion.y;
			
			x = targetRect.left;
			
			redrawList();
			
			Main.stage.focus = _tfFilter;
			_tfFilter.setSelection(_tfFilter.text.length, _tfFilter.text.length);
		}
		
		private function onMouseClick(e:Event):void
		{
			var tf:TextField = e.target as TextField;
			var value:SelectBoxValue = _valueByTextField[tf];
			
			if (value == _newValue)
			{
				dispatchEvent(new SelectBoxEvent(SelectBoxEvent.CREATE_NEW_ITEM, true));
				close();
				return;
			}
			
			if (_callback != null)
			{
				_callback(value.value);
			}
			
			close();
		}
		
		private function redrawList():void
		{
			while (_boxList.numChildren > 0)
			{
				_boxList.removeChildAt(0);
			}
			
			_itemValues = new Vector.<SelectBoxValue>();
			
			_valueByTextField = new Dictionary();
			
			var filterText:String = _tfFilter.text.toLowerCase();
			
			var currentY:int;
			
			for each (var value:SelectBoxValue in _values)
			{
				if (filterText.length > 0 && !value.alwaysShown && value.name.toLowerCase().indexOf(filterText) <= -1)
				{
					continue;
				}
				
				_itemValues.push(value);
				
				var tf:TextField = TextUtils.getText(value.name, Color.FONT, 16);
				tf.autoSize = TextFieldAutoSize.NONE;
				tf.width = _listRegion.width;
				tf.height = 20;
				tf.y = currentY;
				currentY += tf.height;
				
				_valueByTextField[tf] = value;
				_boxList.addChild(tf);
			}
			
			_boxList.addEventListener(MouseEvent.CLICK, onMouseClick);
			_listCanvas.init();
			_listCanvas.setContent(_boxList);
		}
		
		private function onFilterChange(e:Event):void
		{
			_listCanvas.setContentPosition(0, 0);
			redrawList();
		}
		
		override public function close():void 
		{
			super.close();
			
			_listCanvas.dispose();
		}
		
		public function get canDrag():Boolean { return false; };
		public function get ctrlKey():Boolean { return false; };
		public function get dragTarget():DisplayObject { return this; };
		public function get dragX():Boolean { return false; };
		public function get dragY():Boolean { return false; };
	}
}