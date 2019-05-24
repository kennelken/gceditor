package ru.kennel32.editor.data.helper
{
	public class UploadPathData
	{
		public var name:String;
		public var path:String;
		public var key:String;
		public var serializerType:int;
		
		public function UploadPathData(name:String, path:String, key:String, serializerType:int)
		{
			this.name = name;
			this.path = path;
			this.key = key;
			this.serializerType = serializerType;
		}
		
		public static function toRawData(src:UploadPathData):Array
		{
			return [src.name, src.path, src.key, src.serializerType];
		}
		
		public static function fromRawData(src:Array):UploadPathData
		{
			return new UploadPathData(src[0], src[1], src[2], src[3]);
		}
	}
}