package ru.kennel32.editor.view.components.interfaces
{
	import ru.kennel32.editor.view.components.windows.ModalBack;
	
	public interface IModalForm 
	{
		function get modalBack():ModalBack;
		function get isModal():Boolean;
	}
}