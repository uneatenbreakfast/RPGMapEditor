package;
import flash.display.MovieClip;
import flash.display.BitmapData;
import flash.net.SharedObject;

class Omni {
	// Player
	public static var username:String = "ZELD";
	public static var money:Int = 0;
	//public static var userStats:Object = {};

	
	// System
	public static var animationBusy:Bool 	= false;// Person animation?
	public static var systemBusy:Bool 		= false;// Menu panels
	public static var cinematicBusy:Bool 	= false;// Menu Animation
	public static var MovieBusy:Bool 		= true;// Grand Stopper + battlescene

	public static var slowcomputer:Bool		= false;
	
	public static var cineEditor:Bool		= false;
	
	// Settings
	public static var SO:SharedObject;
	public static var showSpeechBubbles:Bool = true;
	public static var shownamesonhead:Bool 	= true;
	public static var auotclosechat:Bool 	= true;
	
	public inline static var RAIN:Int 					= 260;
	public inline static var RAIN_SPRITE:Int 			= 261;
	public inline static var POOF_SPRITE:Int 			= 359;
	public inline static var GRASS_TILE:Int 			= 14;
	public inline static var TALLGRASS_L_TILE:Int 		= 10;
	public inline static var TALLGRASS_TILE:Int 		= 11;
	public inline static var TALLGRASS_R_TILE:Int 		= 12;
	public inline static var TALLGRASS_U_TILE:Int 		= 2;
	
	public inline static var GRASS_SPRITE:Int 			= 544;
	public inline static var TALLGRASS_SPRITE:Int 		= 950;
	public inline static var TALLGRASSEDGE_SPRITE:Int 	= 951;
	public inline static var TALLGRASSEDGE_SPRITE_R:Int	= 952;
	public inline static var TALLGRASS_SPRITE_FR:Int	= 953;

	public inline static var BUTTERFLY:Int 				= 543;
	public inline static var REV_POOF_SPRITE:Int		= 764;
	public inline static var EXPLOSION_SPRITE:Int		= 770;
	public inline static var SUMMONSEAL_SPRITE:Int		= 771;
	public inline static var LIGHTTOTEM_SPRITE:Int		= 772;
	public inline static var FIREREVUP_SPRITE:Int		= 773;
	public inline static var FIREMAGIC_CIRCLE:Int		= 774;
	
	
	public inline static var BITSPACE:Int 				= 75;
	
	public static var FullrenderList:Array<Array<Dynamic>> = new Array<Array<Dynamic>>();	//[cliplinkage , isLoop ]
		
		

	public inline static var NULL:Int			   		= -1;
	public inline static var STAND:Int			   		= 0;
	public inline static var STAND_BACK:Int 	 		= 1;
	public inline static var WALK:Int  					= 2;
	public inline static var WALK_BACK :Int	 	   		= 3;
	public inline static var IDLE:Int  		 	  		= 4;
	public inline static var IDLE_BACK :Int	 			= 5;
	public inline static var RUN_BACK:Int  	 			= 6;
	public inline static var RUN:Int  		 			= 7;
	public inline static var BATTLESTANCE:Int  			= 8;
	public inline static var PUFFED:Int  				= 9;
	public inline static var PUFFEDFALL:Int				= 10;
	public inline static var SWORD_BATTLESTANCE:Int		= 11;
	public inline static var KNOCKEDOUT:Int				= 12;
	public inline static var SKIDSTOP:Int				= 13;
	public inline static var SKIDSTOP_BACK:Int			= 14;
	public inline static var LYDOWN:Int					= 15;
	public inline static var KNOCKEDGETUP:Int			= 16;
	public inline static var HIPPOSE:Int				= 17;
	public inline static var GETITEM:Int				= 18;
	public inline static var DROPITEM:Int				= 19;
	public inline static var CONSUMABLE:Int				= 20;
	public inline static var CHANGECLOTH:Int			= 21;
	public inline static var PRO_STAND:Int				= 22;
	public inline static var STUMP_SIT:Int				= 23;
	public inline static var KNEE_OPEN_CHEST:Int		= 24;
	public inline static var KNEEL:Int					= 25;
	public inline static var CLUTCHARM_HURT:Int			= 26;
	
	public inline static var MONST_IDLE:Int				= 27;
	public inline static var MONST_ROAR:Int				= 28;
	public inline static var MONST_ANIMOVE1:Int			= 31;
	
	public inline static var BLAST_STANCE:Int			= 29;
	public inline static var ROLL_FALL:Int				= 30;	
	//MONST_ANIMOVE1 								= 31
	public inline static var PLACESUMMON:Int			= 32;	
	public inline static var SITDOWNAGAINST:Int			= 33;	
	public inline static var CHAREPALM:Int				= 34;	
	
	public function new ():Void {
		//questlog[""] = 0;
		
		//
		FullrenderList[0] = ["stand",				true];
		FullrenderList[1] = ["stand_back",			true];
		FullrenderList[2] = ["walk",				true];
		FullrenderList[3] = ["walk_back",			true];
		FullrenderList[4] = ["idleOW",				true];
		FullrenderList[5] = ["idleBackOW",			true];
		FullrenderList[6] = ["run_BKOW",			true];
		FullrenderList[7] = ["run_Overworld",		true];
		FullrenderList[8] = ["battlestanceNorm",	true];
		FullrenderList[9] = ["puffed",				true];
		FullrenderList[10] = ["puffedfall",			false];
		FullrenderList[11] = ["sword_battlestance",	false];
		FullrenderList[12] = ["knockedout",			false];
		FullrenderList[13] = ["skidstop",			true];
		FullrenderList[14] = ["skidstopBK",			true];
		FullrenderList[15] = ["lydown",				false];
		FullrenderList[16] = ["knockedoutgetup",	false];
		FullrenderList[17] = ["standpose",			false];
		FullrenderList[18] = ["getItem",			false];
		FullrenderList[19] = ["dropitem",			false];
		FullrenderList[20] = ["consumable",			false];
		FullrenderList[21] = ["change",				false];
		FullrenderList[22] = ["prostand",			false];
		FullrenderList[23] = ["stumpsit",			false];
		FullrenderList[24] = ["kneelopenChest",		false];
		FullrenderList[25] = ["kneel",				true];
		FullrenderList[26] = ["clucharm",			true];
		FullrenderList[27] = ["idle",				true];
		FullrenderList[28] = ["roar",				false];
		FullrenderList[29] = ["blaststance",		false];
		FullrenderList[30] = ["rollfallland",		false];
		FullrenderList[31] = ["animove1",			false];
		FullrenderList[32] = ["placesummon",		false];
		FullrenderList[33] = ["downagainst",		false];
		FullrenderList[34] = ["placesummonAni",		false];
	}
	

	
	
	//
}
