<?php
	$configRawData = isset($_POST["config"]) ? $_POST["config"] : null;
	$key = isset($_POST["key"]) ? $_POST["key"] : null;
	$pull = isset($_POST["pull"]) ? $_POST["pull"] : null;
	
	$returnVars = array();
	$errorStatus = 0;
	$message = "";
	
	if ($key != "gIBFI653NJHf8")	//your key here
	{
		error_log("key is invalid");
		
		$message = "key is invalid";
		$errorStatus = 1;
	}
	else
	{
		$fileName = "/home/scrollshooter.server/backend/linux/scrollshooter_Data/config.json";	//your config path here
		
		if ($pull)
		{
			if (file_exists($fileName))
			{
				$returnVars['config'] = file_get_contents($fileName);
			}
			else
			{
				$errorStatus = 2;
			}
		}
		else
		{
			if (!is_null($configRawData))
			{
				$configFile = fopen($fileName, "w");
				fwrite($configFile, $configRawData);
				fclose($configFile);
			}
			else
			{
				if (file_exists($fileName))
				{
					unlink($fileName);
				}
			}
			
			$message = shell_exec('sudo sh /home/scrollshooter.server/backend/scripts/restart_server.sh');	//your restart script path here
		}
	}
	
	$returnVars["errorStatus"] = $errorStatus;
	$returnVars["message"] = $message;
	echo json_encode($returnVars);
?>