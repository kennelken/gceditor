package ru.kennel32.editor.view.enum
{
	public class Align
	{
		public static const H_LEFT:Align		= new Align('h_left');
		public static const H_CENTER:Align		= new Align('h_center');
		public static const H_RIGHT:Align		= new Align('h_right');
		public static const V_TOP:Align			= new Align('v_top' );
		public static const V_CENTER:Align		= new Align('v_center');
		public static const V_BOTTOM:Align		= new Align('v_bottom');
		
		private var _value:String;
		public function Align(value:String)
		{
			_value = value;
		}
	}
}