package;

#if ios
import extension.gamecenter.GameCenter;
import extension.gamecenter.GameCenterEvent;
#elseif android
import extension.gpg.GooglePlayGames;
#end
import openfl.net.SharedObject;

class FieryPlay
{
	public static var NAME : String = "FIERY_PLAY";
	
	public static var AUTHENTICATED : Bool;
	
	private static var instance : FieryPlay;
	private static var authorized : Bool;
	private static var sharedAchievements : SharedObject;
	
	public static function InitInstance(): FieryPlay
	{
		if (instance == null)
			instance = new FieryPlay();
				
		return instance;
	}
	
	/*
	 * Creates and returns a screen manager instance if it's not created yet.
	 * Returns the current instance of this class if it already exists.
	 */
	public static function GetInstance(): FieryPlay
	{
		if ( instance == null )
			throw "Fiery Play is not initialized. Use function 'InitInstance'";
		
		return instance;
	}
	
	/*
	 * Constructor
	 */
	private function new() 
	{
		sharedAchievements = SharedObject.getLocal("achievements");
		if (sharedAchievements.data.unlockedList == null)
		{
			sharedAchievements.data.unlockedList = new Array<String>();
			StorageHelper.SaveData(sharedAchievements);
		}
		
		#if android
			GooglePlayGames.init(false);
		#elseif ios
			GameCenter.addEventListener(GameCenterEvent.AUTH_SUCCESS, OnAuthEvent);
			GameCenter.addEventListener(GameCenterEvent.AUTH_FAILURE, OnAuthEvent);
			GameCenter.addEventListener(GameCenterEvent.ACHIEVEMENT_SUCCESS, OnAchievementEvent);
			GameCenter.addEventListener(GameCenterEvent.ACHIEVEMENT_FAILURE, OnAchievementEvent);
			GameCenter.addEventListener(GameCenterEvent.ACHIEVEMENT_RESET_SUCCESS, OnAchievementEvent);
			GameCenter.addEventListener(GameCenterEvent.ACHIEVEMENT_RESET_FAILURE, OnAchievementEvent);
		#end
	}
	
	public static function Init() : Void
	{
		try
		{
			#if android
			GooglePlayGames.onLoginResult = OnAuthEvent;
			GooglePlayGames.login();
			#elseif ios
				if(GameCenter.available)
					GameCenter.authenticate()
			#end
		}
		catch(e : String)
		{
			trace(e);
		}
	}
	
	#if android
	public static function OnAuthEvent(e : Int) : Void
	{
		// The possible returned values are:
        // -1 = failed login
        //  0 = trying to log in
        //  1 = logged in
        // this event is fired several times on differents situations, results vary and must be tested
        // and adapted to your game logic. for example, if you execute init() and login() but the user
        // doesn't login, cancel the operation, it will return: 0 -1 0 -1 , same as if the user is
        // not connected to the internet.
		switch(e)
		{
			//failed login
			case -1:
			//trying to log in
			case 0:
			//logged in
			case 1:
			default:
		}
	}
	#elseif ios
	public static function OnAuthEvent(e : GameCenterEvent) : Void
	{
		switch(e.type)
		{
			case GameCenterEvent.AUTH_SUCCESS:
			case GameCenterEvent.AUTH_FAILURE:
			default:
		}
	}
	#end
	
	public static function OnAchievementEvent() : Void
	{}
	
	public static function DisplayAchievements() : Void
	{
		#if android
			GooglePlayGames.displayAchievements();
		#elseif ios
			GameCenter.showAchievements();
		#end
	}
	
	public static function DisplayLeaderboard(id : String) : Void
	{
		#if android
			GooglePlayGames.displayScoreboard(id);
		#elseif ios
			GameCenter.showLeaderboard(id);
		#end
	}
	
	public static function UnlockAchievement(id : String) : Void
	{
		var achievements : Array<String>;
		var idIndex : Int;
		
		//Local storage
		achievements = sharedAchievements.data.unlockedList;
		idIndex = achievements.indexOf(id);
		
		//The achievement is not in the list
		if(idIndex == -1)
		{
			#if android
				GooglePlayGames.unlock(id);
			#elseif ios
				GameCenter.reportAchievement(id);
			#end
			achievements.push(id);
			sharedAchievements.data.unlockedList = achievements;
			StorageHelper.SaveData(sharedAchievements);
		}
	}
	
	public static function UpdateScore(id : String, score : Int) : Void
	{
		#if android
			GooglePlayGames.setScore(id, score);
		#elseif ios
			GameCenter.reportScore(id, score);
		#end
	}
	
	public static function ResetAchievements() : Void
	{
		sharedAchievements.clear();
		StorageHelper.SaveData(sharedAchievements);
		#if android
			//
		#elseif ios
			GameCenter.resetAchievements();
		#end
	}
	
	/*public static function OnGameCenterAchievementEvent(e : GameCenterEvent)
	{
		var id : String;
		var sharedObj : SharedObject;
		var flushStatus : SharedObjectFlushStatus;
		var idIndex : Int;
		var achievements : Array<String>;

		#if ios
		id = e.data1;
		switch(e.type)
		{
			case GameCenterEvent.ACHIEVEMENT_SUCCESS:
				trace("todo bien");

				//trace(e.data1);
				//trace(e.data2);
				//trace(e.data3);
				//trace(e.data4);
				sharedObj = SharedObject.getLocal("achievements");


				if (sharedObj.data.succachievements == null)
					sharedObj.data.succachievements = new Array<String>();

				sharedObj.data.succachievements.push(id);

				if (sharedObj.data.achievements != null)
				{
					achievements = sharedObj.data.achievements;
					idIndex = achievements.indexOf(id);

					if(idIndex != -1)
					{
						achievements.remove(id);
					}

					//sharedObj.data.achievements = achievements;
					flushStatus = SaveData(sharedObj);

					if ( flushStatus != null )
					{
						switch( flushStatus )
						{
							case SharedObjectFlushStatus.PENDING:
								trace('requesting permission to save');
							case SharedObjectFlushStatus.FLUSHED:
								trace('statistics saved');
						}
					}
				}

			case GameCenterEvent.ACHIEVEMENT_FAILURE:
				trace("la cagamos");
				//Store lost achievement
				//StoreAchievement(id);
				//El id esta en el data1
				//trace(e.data1);
				//trace(e.data2);
				//trace(e.data3);
				//trace(e.data4);

			case GameCenterEvent.ACHIEVEMENT_RESET_SUCCESS:


				sharedObj = SharedObject.getLocal("achievements");

				sharedObj.data.achievements = new Array<String>();
				sharedObj.data.succachievements = new Array<String>();
				sharedObj.data.clean = false;

				flushStatus = SaveData(sharedObj);

				if ( flushStatus != null )
				{
					switch( flushStatus )
					{
						case SharedObjectFlushStatus.PENDING:
							trace('requesting permission to save');
						case SharedObjectFlushStatus.FLUSHED:
							trace('statistics saved');
					}
				}
			case GameCenterEvent.ACHIEVEMENT_RESET_FAILURE:
				//StoreCleanAchievement();

			default:

		}
		#end
	}*/
}