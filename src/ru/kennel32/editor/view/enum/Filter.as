package ru.kennel32.editor.view.enum
{
	import flash.filters.ColorMatrixFilter;
	import ru.kennel32.editor.view.enum.Color;
	public class Filter
	{
		public static const TRANSPARENT_FILTER:ColorMatrixFilter = new ColorMatrixFilter( [
			1, 0, 0, 0, 0,
			0, 1, 0, 0, 0,
			0, 0, 1, 0, 0,
			0, 0, 0, 0.5, 0
		]);
		
		public static const BLACK_WHITE:ColorMatrixFilter = new ColorMatrixFilter(
			[
				0.2, 0.3, 0.2, 0, 0,
				0.2, 0.3, 0.2, 0, 0,
				0.2, 0.3, 0.2, 0, 0,
				0, 0, 0, 1, 0
			]
		);
		
		public static const BLACK_WHITE_LIGHT_WHITE:ColorMatrixFilter = new ColorMatrixFilter(
			[
				0.3, 0.3, 0.3, 0, 40,
				0.3, 0.3, 0.3, 0, 40,
				0.3, 0.3, 0.3, 0, 40,
				0, 0, 0, 1, 0
			]
		);
		
		public static const BLACK_WHITE_LIGHT_BLUE:ColorMatrixFilter = new ColorMatrixFilter(
			[
				0.3, 0.3, 0.3, 0, 0,
				0.3, 0.3, 0.3, 0, 0,
				0.3, 0.3, 0.3, 0, 20,
				0, 0, 0, 1, 0
			]
		);
		
		
		public static const INACTIVE_COLOR:ColorMatrixFilter = new ColorMatrixFilter(
			[
				0.3, 0.3, 0.3, 0, 0,
				0.3, 0.3, 0.3, 0, 0,
				0.3, 0.3, 0.3, 0, 0,
				0.0, 0.0, 0.0, 0.6, 0
			]
		);
		
		public static const INACTIVE_BLUE:ColorMatrixFilter = new ColorMatrixFilter(
			[
				0.3, 0.0, 0.0, 0, 168,
				0.0, 0.3, 0.0, 0, 175,
				0.0, 0.0, 0.3, 0, 178,
				0.0, 0.0, 0.0, 1, 0
			]
		);
		
		private static var _INACTIVE_RED:ColorMatrixFilter;
		public static function get INACTIVE_RED():ColorMatrixFilter
		{
			if (_INACTIVE_RED == null)
			{
				_INACTIVE_RED = getTintFilter(Color.RED, 0.6);
			}
			return _INACTIVE_RED;
		}
		
		//////////////////////
		//TINT FILTER
		//
		public static function getTintFilter(color:uint, value:Number):ColorMatrixFilter
		{
			var m:Number = (1 - value);
			var rOff:Number = Math.round(value * extractRed(color));
			var gOff:Number = Math.round(value * extractGreen(color));
			var bOff:Number = Math.round(value * extractBlue(color));
			return new ColorMatrixFilter(
				[
					m, 0.0, 0.0, 0, rOff,
					0.0, m, 0.0, 0, gOff,
					0.0, 0.0, m, 0, bOff,
					0.0, 0.0, 0.0, 1, 0
				]
			);
		}
		
		public static function extractRed(c:uint):uint
		{
			return (( c >> 16 ) & 0xFF);
		}
		public static function extractGreen(c:uint):uint
		{
			return ( (c >> 8) & 0xFF );
		}
		public static function extractBlue(c:uint):uint
		{
			return ( c & 0xFF );
		}
		
		
		////////////////////
		// COLOR MATRIX FILTER
		//
		public static function getBasicColorMatrixFilter(brightness:Number = 0, saturation:Number = 0, redMult:Number = 1, greenMult:Number = 1, blueMult:Number = 1):ColorMatrixFilter
		{
			brightness = brightness*(255/250);
			
			const lumaR:Number = 0.212671;
			const lumaG:Number = 0.71516;
			const lumaB:Number = 0.072169;
			
			var v:Number = (saturation/100) + 1;
			var i:Number = (1 - v);
			var r:Number = (i * lumaR);
			var g:Number = (i * lumaG);
			var b:Number = (i * lumaB);
			
			var m:Array = new Array(
				(r + v) * redMult, g * greenMult, b * blueMult, 0, brightness,
				r * redMult, (g + v) * greenMult, b * blueMult, 0, brightness,
				r * redMult, g * greenMult, (b + v) * blueMult, 0, brightness,
				0, 0, 0, 1, 0
			);
			
			return new ColorMatrixFilter(m);
		}
	}
}