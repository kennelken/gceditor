package ru.kennel32.editor.assets
{
	import flash.utils.ByteArray;
	
	public class Assets
	{
		private static var _instance:Assets;
		
		public function Assets()
		{
			_instance = this;
		}
		
		public static const FONT_FAMILY:String = 'sansMono';
		[Embed(source="../../../../../assets/fonts/DejaVuSansMono.ttf", fontFamily="sansMono", mimeType="application/x-font-truetype", advancedAntiAliasing="true", embedAsCFF="false")]
		private var courierFont:Class;
		
		[Embed(source="../../../../../assets/misc/upload_config.php", ,mimeType="application/octet-stream")]
		private static var _phpScriptExample:Class;
		public static function get phpScriptExmaple():String
		{
			return (new _phpScriptExample() as ByteArray).toString();
		}
	}
}