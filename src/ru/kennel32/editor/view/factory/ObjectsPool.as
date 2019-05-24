package ru.kennel32.editor.view.factory
{
	import flash.utils.Dictionary;
	import ru.kennel32.editor.view.interfaces.IDisposable;
	
	public class ObjectsPool
	{
		private static var _instance:ObjectsPool;
		public static function init():void
		{
			if (_instance != null)
			{
				throw new Error('ObjectsPool is already inited.');
			}
			_instance = new ObjectsPool;
		}
		
		private var _instancesByClass:Dictionary;
		
		public function ObjectsPool()
		{
			_instancesByClass = new Dictionary();
		}
		
		public static function release(obj:Object):void
		{
			var cls:Class = obj.constructor as Class;
			
			if (obj is IDisposable)
			{
				(obj as IDisposable).dispose();
			}
			
			if (_instance._instancesByClass[cls] == null)
			{
				_instance._instancesByClass[cls] = new Vector.<Object>();
			}
			_instance._instancesByClass[cls].push(obj);
		}
		
		public static function getItem(cls:Class):Object
		{
			if (_instance._instancesByClass[cls] == null || _instance._instancesByClass[cls].length <= 0)
			{
				return new cls();
			}
			
			return _instance._instancesByClass[cls].pop();
		}
	}
}