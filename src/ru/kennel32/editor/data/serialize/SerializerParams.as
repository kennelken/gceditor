package ru.kennel32.editor.data.serialize
{
	import ru.kennel32.editor.data.table.BaseTable;
	
	public class SerializerParams
	{
		public var serializerType:int = -1;
		public var basicSerializerType:int = -1;
		public var table:BaseTable;
		public var rawData:Object;
		public var source:String;
		
		public function SerializerParams(source:String = null, rawData:Object = null):void
		{
			this.source = source;
			this.rawData = rawData;
		}
	}
}