package;

class FieryPlay
{
	public static var NAME : String = "FIERY_PLAY";
	
	private static var instance : FieryPlay;
	private static var authorized : Bool;
	
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
			throw "PlayCenter is not initialized. Use function 'InitInstance'";
		
		return instance;
	}
	
	/*
	 * Constructor
	 */
	private function new() 
	{
		#if android
		GooglePlayGames.init(false);
		#elseif ios
		try
		{
			if(GameCenter.available)
				GameCenter.authenticate();
		}
		catch(e : String)
		{
			trace e;
		}
		#end
	}
}