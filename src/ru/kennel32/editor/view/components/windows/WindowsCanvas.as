package ru.kennel32.editor.view.components.windows 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import ru.kennel32.editor.view.components.interfaces.IModalForm;
	import ru.kennel32.editor.view.forms.BaseForm;
	import ru.kennel32.editor.view.interfaces.IDraggable;
	import ru.kennel32.editor.view.utils.DragManager;
	
	public class WindowsCanvas extends Sprite 
	{
		private static const MIN_EDGE_OFFSET:int = 5;
		
		private static var _instance:WindowsCanvas;
		public static function get instance():WindowsCanvas
		{
			return _instance;
		}
		
		public function WindowsCanvas() 
		{
			super();
			_instance = this;
		}
		
		public function showForm(form:BaseForm):void
		{
			var modalForm:IModalForm = form as IModalForm;
			if (modalForm != null && modalForm.isModal && modalForm.modalBack != null)
			{
				addChild(modalForm.modalBack);
			}
			addChild(form);
			
			centerForm(form);
			
			DragManager.register(form, onFormDrag);
			
			setActiveForm(form);
		}
		
		public function removeForm(form:BaseForm):void
		{
			form.onClose();
			
			var modalForm:IModalForm = form as IModalForm;
			if (modalForm != null && modalForm.modalBack != null && modalForm.modalBack.parent != null)
			{
				modalForm.modalBack.parent.removeChild(modalForm.modalBack);
			}
			if (form.parent != null)
			{
				form.parent.removeChild(form);
			}
			
			DragManager.unregister(form);
			
			for (var i:int = numChildren - 1; i >= 0; i--)
			{
				if (getChildAt(i) is BaseForm)
				{
					setActiveForm(getChildAt(i) as BaseForm);
					break;
				}
			}
		}
		
		public function removeFormByClass(cls:Class):void
		{
			for each (var form:BaseForm in getFormsByClass())
			{
				removeForm(form);
			}
		}
		
		private function centerForm(form:BaseForm):void
		{
			form.x = getDefaultX(form) + form.posOffsetX;
			form.y = getDefaultY(form) + form.posOffsetY;
			
			var modalBack:ModalBack = (form is IModalForm) ? (form as IModalForm).modalBack : null;
			if (modalBack != null)
			{
				modalBack.redraw();
			}
			
			form.x = Math.max(MIN_EDGE_OFFSET, Math.min(_width - form.width - MIN_EDGE_OFFSET, form.x));
			form.y = Math.max(MIN_EDGE_OFFSET, Math.min(_height - form.height - MIN_EDGE_OFFSET, form.y));
		}
		
		private function getDefaultX(form:BaseForm):int
		{
			return (_width - form.width) / 2;
		}
		
		private function getDefaultY(form:BaseForm):int
		{
			return (_height - form.height) / 2;
		}
		
		private var _width:int;
		private var _height:int;
		public function setSize(width:int, height:int):void
		{
			_width = width;
			_height = height;
			
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				
				var childForm:BaseForm = child as BaseForm;
				if (childForm != null)
				{
					centerForm(childForm);
				}
			}
		}
		
		public function setActiveForm(form:BaseForm):void
		{
			var children:Vector.<BaseForm> = new Vector.<BaseForm>();
			
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:DisplayObject = getChildAt(i);
				
				var childForm:BaseForm = child as BaseForm;
				if (childForm != null)
				{
					children.push(childForm);
				}
			}
			
			for each (childForm in children)
			{
				childForm.setInFocus(childForm == form);
			}
		}
		
		override public function get width():Number
		{
			return _width;
		}
		override public function get height():Number 
		{
			return _height;
		}
		
		public function getFormsByClass(cls:Class = null):Vector.<BaseForm>
		{
			var res:Vector.<BaseForm> = new Vector.<BaseForm>();
			for (var i:int = 0; i < numChildren; i++)
			{
				var child:BaseForm = getChildAt(i) as BaseForm;
				if (child != null && (cls == null || child is cls))
				{
					res.push(child);
				}
			}
			
			return res;
		}
		
		private function onFormDrag(draggable:IDraggable):void
		{
			var form:BaseForm = draggable.dragTarget as BaseForm;
			
			var offX:int = form.x - getDefaultX(form);
			var offY:int = form.y - getDefaultY(form);
			
			form.onPosOffsetChanged(offX, offY);
			centerForm(form);
		}
	}
}