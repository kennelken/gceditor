package ru.kennel32.editor.data.commands
{
	public interface ICommand
	{
		function undo():void;
		function redo():void;
	}
}