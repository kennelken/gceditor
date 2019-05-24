package ru.kennel32.editor.data.commands
{
	import flash.geom.Point;
	import ru.kennel32.editor.assets.Texts;
	import ru.kennel32.editor.data.table.TableRow;
	import ru.kennel32.editor.view.forms.dialog.DialogForm;
	import ru.kennel32.editor.view.forms.dialog.DialogFormParams;
	import ru.kennel32.editor.view.forms.dialog.content.InspectRowDialogContent;
	import ru.kennel32.editor.view.utils.ViewUtils;
	
	public class InspectRowCommand extends BaseCommand implements ICommand
	{
		public var row:TableRow;
		
		private var _content:InspectRowDialogContent;
		private var _contentScrollPosition:Point;
		private var _form:DialogForm;
		
		private var _formPosition:Point;
		
		public function InspectRowCommand(row:TableRow)
		{
			super();
			
			this.row = row;
			
			description = Texts.commandInspectRow;
		}
		
		public function redo():void
		{
			_content = new InspectRowDialogContent(this);
			_content.setData(row);
			
			if (_contentScrollPosition != null)
			{
				_content.scrollPosition = _contentScrollPosition;
			}
			
			_form = DialogFormParams.create().setContent(_content).setText(Texts.textTable + ' ' + ViewUtils.getTableName(row.parent.meta.id)).show();
			if (_formPosition != null)
			{
				_form.x = _formPosition.x;
				_form.y = _formPosition.y;
			}
		}
		
		public function undo():void
		{
			_contentScrollPosition = _content.scrollPosition;
			_formPosition = new Point(_form.x, _form.y);
			_form.close();
		}
		
		override public function get isImportant():Boolean
		{
			return false;
		}
	}
}