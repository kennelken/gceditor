package ru.kennel32.editor.view.forms.dialog 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import ru.kennel32.editor.Main;
	import ru.kennel32.editor.data.settings.Settings;
	import ru.kennel32.editor.view.components.buttons.BtnClose;
	import ru.kennel32.editor.view.components.CanvasSprite;
	import ru.kennel32.editor.view.components.HBox;
	import ru.kennel32.editor.view.components.buttons.LabeledButton;
	import ru.kennel32.editor.view.components.SimpleBackground;
	import ru.kennel32.editor.view.components.interfaces.IModalForm;
	import ru.kennel32.editor.view.components.windows.ModalBack;
	import ru.kennel32.editor.view.enum.Align;
	import ru.kennel32.editor.view.enum.Color;
	import ru.kennel32.editor.view.forms.BaseForm;
	import ru.kennel32.editor.view.forms.dialog.content.BaseDialogContent;
	import ru.kennel32.editor.view.interfaces.IAllowCommandsHistoryChange;
	import ru.kennel32.editor.view.interfaces.IClosableByUser;
	import ru.kennel32.editor.view.interfaces.ICustomPositionable;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	import ru.kennel32.editor.view.interfaces.IDraggable;
	import ru.kennel32.editor.view.utils.DragManager;
	import ru.kennel32.editor.view.utils.TextUtils;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class DialogForm extends BaseForm implements IModalForm
	{
		private var Y_BLOCKS_DISTANCE:int = 8;
		
		private var _params:DialogFormParams;
		
		private var _bg:SimpleBackground;
		private var _btnClose:BtnClose;
		
		private var _boxContent:CanvasSprite;
		private var _modalBack:ModalBack;
		private var _boxButtons:HBox;
		
		public function DialogForm(params:DialogFormParams) 
		{
			super();
			
			_params = params;
			
			_important = _params.important;
			
			_modalBack = new ModalBack(this);
			
			_bg = new SimpleBackground(500, 200, true);
			addChild(_bg);
			
			_boxContent = new CanvasSprite();
			addChild(_boxContent);
			
			var currentY:int = 0;
			
			if (_params.text != null)
			{
				var tfText:TextField = TextUtils.getTextCentered(_params.text, Color.FONT, _params.textSize, true, -4, _params.textAlign);
				tfText.y = currentY;
				tfText.width = 350;
				tfText.text = tfText.text;
				if (tfText.numLines > 5)
				{
					tfText.width = 450;
					tfText.text = tfText.text;
				}
				if (tfText.numLines > 7)
				{
					tfText.width = 550;
					tfText.text = tfText.text;
				}
				tfText.height = tfText.textHeight + 7;
				tfText.selectable = true;
				//tfText.x = -int(tfText.width / 2);
				tfText.x = 0;
				_boxContent.addChild(tfText);
				currentY += tfText.height + Y_BLOCKS_DISTANCE;
			}
			
			_btnClose = new BtnClose(12);
			_btnClose.y = 3;
			addChild(_btnClose);
			_btnClose.addEventListener(MouseEvent.CLICK, onBtnCloseClick);
			
			if (_params.content != null)
			{
				if (_params.content is BaseDialogContent)
				{
					(_params.content as BaseDialogContent).parentForm = this;
				}
				_boxContent.addChild(_params.content);
				
				_params.content.y = currentY;
				currentY += ViewUtils.getContentHeight(_params.content) + Y_BLOCKS_DISTANCE;
				_params.content.x = 0;
			}
			
			if (_params.buttons.length > 0)
			{
				_boxButtons = new HBox();
				for (var i:int = 0; i < _params.buttons.length; i++)
				{
					var btn:LabeledButton = new LabeledButton(_params.buttons[i].name);
					btn.addEventListener(MouseEvent.CLICK, onCustomBtnClick);
					_boxButtons.addChild(btn);
				}
				_boxButtons.resize();
				_boxButtons.x = 0;
				_boxButtons.y = currentY;
				
				currentY += _boxButtons.height + Y_BLOCKS_DISTANCE;
				_boxContent.addChild(_boxButtons);
			}
			
			resizeBg();
		}
		
		private function resizeBg():void
		{
			_boxContent.fitToContent();
			_boxContent.alignChildren(Align.H_CENTER);
			
			_bg.setSize(_boxContent.width + 10 * 2, _boxContent.height + 40);
			_boxContent.x = int((_bg.width - _boxContent.width) / 2);
			_boxContent.y = 33;
			
			_btnClose.x = _bg.width - _btnClose.width - _btnClose.y;
		}
		
		public static function show(params:DialogFormParams):DialogForm
		{
			var res:DialogForm = new DialogForm(params);
			res.show();
			return res;
		}
		
		public function get modalBack():ModalBack
		{
			return _modalBack;
		}
		
		private function onBtnCloseClick(e:Event):void
		{
			onClosedByUser();
			close();
		}
		
		override public function show():void 
		{
			Main.stage.addEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
			
			return super.show();
		}
		
		override public function close():void 
		{
			super.close();
			
			if ((_params.content as IDisposable) != null)
			{
				(_params.content as IDisposable).dispose();
			}
			_params.callCloseCallback();
			
			Main.stage.removeEventListener(KeyboardEvent.KEY_UP, onStageKeyUp);
		}
		
		private function onCustomBtnClick(e:Event):void
		{
			var btn:LabeledButton = e.currentTarget as LabeledButton;
			var index:int = _boxButtons.getChildIndex(btn);
			
			_params.buttons[index].callCallback();
			
			close();
		}
		
		override protected function onHistoryChange(e:Event):void 
		{
			if (_params.content is IAllowCommandsHistoryChange)
			{
				return;
			}
			
			super.onHistoryChange(e);
		}
		
		override protected function onClosedByUser():void 
		{
			if (_params.content is IClosableByUser)
			{
				(_params.content as IClosableByUser).onClosedByUser();
			}
		}
		
		public function get params():DialogFormParams
		{
			return _params;
		}
		
		override public function get width():Number 
		{
			return _bg.width;
		}
		
		override public function get height():Number 
		{
			return _bg.height;
		}
		
		override public function get isModal():Boolean 
		{
			return _params.content == null || !(_params.content is IModalForm) || (_params.content as IModalForm).isModal;
		}
		
		override public function onPosOffsetChanged(x:int, y:int):void 
		{
			var customPositionableContent:ICustomPositionable = _params.content as ICustomPositionable;
			if (customPositionableContent != null)
			{
				customPositionableContent.onPosOffsetChanged(x, y);
				return;
			}
			
			Settings.commonDialogOffsetX = x;
			Settings.commonDialogOffsetY = y;
		}
		override public function get posOffsetX():int 
		{
			var customPositionableContent:ICustomPositionable = _params.content as ICustomPositionable;
			if (customPositionableContent != null)
			{
				return customPositionableContent.posOffsetX;
			}
			
			return Settings.commonDialogOffsetX;
		}
		override public function get posOffsetY():int 
		{
			var customPositionableContent:ICustomPositionable = _params.content as ICustomPositionable;
			if (customPositionableContent != null)
			{
				return customPositionableContent.posOffsetY;
			}
			
			return Settings.commonDialogOffsetY;
		}
		
		private function onStageKeyUp(e:KeyboardEvent):void
		{
			for each (var button:DialogFormButtonParams in _params.buttons)
			{
				if (button.keyCode == e.keyCode)
				{
					button.callCallback();
					close();
					return;
				}
			}
		}
	}
}