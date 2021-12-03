module Main where

import GPUIO

import Control.Monad.Loops
import Control.Concurrent
import System.Exit
import System.Process
import Curve

-- The monitoring logic
monitor :: IO ()
monitor = do
    temp <- getTemp

    case temp of
        Just t -> do
            putStrLn $ "Temperature: " ++ show t
            let s = lookupFanSpeed t
            putStrLn $ "Desired fan speed: " ++ show s
            setTemp s

        Nothing -> error "Could not read GPU temperature"
    
    threadDelay 1000000


main :: IO ()
main = do
    -- Enable manual fan control
    (exitCode, _, _) <- readProcessWithExitCode 
        "nvidia-settings" 
        ["-a", "GPUFanControlState=1"] ""

    case exitCode of
        ExitFailure i -> error "Failed to get control of the fan"
        ExitSuccess -> do
            -- TODO: print curve
            -- Create a loop of the monitoring logic
            whileM_ (return True) monitor

