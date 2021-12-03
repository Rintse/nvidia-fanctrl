module GPUIO where

import Text.Read
import System.Process
import System.Exit

readTemp :: IO String
readTemp = readProcess
    "nvidia-smi" -- NVIDIA System Management Interface
    [ "--query-gpu=temperature.gpu", "--format=csv,noheader" ]
    "" -- empty stdin

getTemp :: IO (Maybe Int)
getTemp = readTemp >>= toInt where
    toInt = return . readMaybe :: String -> IO (Maybe Int)

setTemp :: Int -> IO ()
setTemp t = do
    (exitCode, _, _) <- readProcessWithExitCode
        "nvidia-settings"
        ["-a", "GPUTargetFanSpeed=" ++ show t] ""

    case exitCode of
        ExitFailure i -> error "Failed to set fan speed"
        ExitSuccess -> return ()
