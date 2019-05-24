package ru.kennel32.editor.data.commands
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import ru.kennel32.editor.data.events.CommandEvent;
	
	[Event(name="change", type="flash.events.Event")]
	[Event(name="commandexecuted", type="ru.kennel.editor.data.events.CommandEvent")]
	public class CommandsHistory extends EventDispatcher
	{
		private var _maxSize:int;
		private var _history:Vector.<BaseCommand>;
		private var _curPos:int;
		
		private var _savedPos:int;
		
		public function CommandsHistory(maxSize:int)
		{
			_maxSize = maxSize;
			
			_history = new Vector.<BaseCommand>();
			_curPos = -1;
			
			_savedPos = -1;
		}
		
		public function addCommandAndExecute(cmd:BaseCommand):void
		{
			dispatchBeforeCommandExecuted(false);
			
			addCommand(cmd);
			redo(false);
		}
		
		public function addExecutedCommand(cmd:BaseCommand):void
		{
			addCommand(cmd);
			_curPos++;
			dispatchChange();
		}
		
		private function addCommand(cmd:BaseCommand):void
		{
			_history.length = _curPos + 1;	//remove all commands ahead of curPos
			
			while (_history.length + 1 > _maxSize)
			{
				_history.shift();
				_curPos--;
				_savedPos--;
			}
			
			_history.push(cmd);
		}
		
		public function undo(dispatchBeforeCommand:Boolean = true):void
		{
			if (_curPos <= -1)
			{
				return;
			}
			
			if (dispatchBeforeCommand)
			{
				dispatchBeforeCommandExecuted(false);
			}
			
			var cmd:BaseCommand = _history[_curPos];
			
			(cmd as ICommand).undo();
			_curPos--;
			_hasUnsavedChanges = 0;
			
			dispatchChange();
			dispatchCommandExecuted(cmd, true);
		}
		
		public function redo(dispatchBeforeCommand:Boolean = true):void
		{
			if (_curPos > _history.length - 2)
			{
				return;
			}
			
			if (dispatchBeforeCommand)
			{
				dispatchBeforeCommandExecuted(true);
			}
			
			_curPos++;
			_hasUnsavedChanges = 0;
			
			var cmd:BaseCommand = _history[_curPos];
			(cmd as ICommand).redo();
			
			dispatchChange();
			dispatchCommandExecuted(cmd, false);
		}
		
		public function clear():void
		{
			_history.length = 0;
			_curPos = -1;
			_savedPos = -1;
			
			dispatchChange();
		}
		
		private function dispatchChange():void
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function dispatchBeforeCommandExecuted(undo:Boolean):void
		{
			dispatchEvent(new CommandEvent(CommandEvent.BEFORE_COMMAND_EXECUTED, null, undo));
		}
		
		private function dispatchCommandExecuted(cmd:BaseCommand, undo:Boolean):void
		{
			dispatchEvent(new CommandEvent(CommandEvent.COMMAND_EXECUTED, cmd, undo));
		}
		
		public function getNextCommand():BaseCommand
		{
			return _curPos >= _history.length - 1 ? null : _history[_curPos + 1];
		}
		
		public function getPrevCommand():BaseCommand
		{
			return _curPos <= -1 ? null : _history[_curPos];
		}
		
		public function updateSavePos():void
		{
			_savedPos = _curPos;
			_hasUnsavedChanges = 0;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private var _hasUnsavedChanges:int = 0;
		public function get hasUnsavedChanges():Boolean
		{
			if (_hasUnsavedChanges == 0)
			{
				_hasUnsavedChanges = -1;
				if (_curPos != _savedPos)
				{
					if (_curPos > _savedPos)
					{
						var changes:Vector.<BaseCommand> = _history.slice(_savedPos + 1, _curPos + 1);
					}
					else
					{
						changes = _history.slice(_curPos + 1, _savedPos + 1);
					}
					
					_hasUnsavedChanges = -1;
					for each (var cmd:BaseCommand in changes)
					{
						if (cmd.isImportant)
						{
							_hasUnsavedChanges = 1;
							break;
						}
					}
				}
			}
			return _hasUnsavedChanges == 1;
		}
	}
}