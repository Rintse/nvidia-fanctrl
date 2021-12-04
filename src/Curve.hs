module Curve where

import Data.List
import Control.Exception
import Control.Monad

type Temperature = Int
type FanSpeed = Int


data CurvePoint = CurvePoint
    { temp :: Temperature
    , speed :: FanSpeed
    } deriving (Show)


-- Allow for vertical upwards
points :: [CurvePoint]
points =
    [ CurvePoint 0 0,
      CurvePoint 60 0,
      CurvePoint 61 0,
      CurvePoint 70 25,
      CurvePoint 80 50,
      CurvePoint 90 100
    ]


-- TODO: assert p1 is lower than p2 in both coordinates
linearInterpolant :: CurvePoint -> CurvePoint -> Temperature -> FanSpeed
linearInterpolant p1 p2 t = do
    let tempDif = fromIntegral (temp p2 - temp p1)
    let speedDif = fromIntegral (speed p2 - speed p1)
    
    let offset = speedDif * ( fromIntegral (t - temp p1) / tempDif )

    speed p1 + round offset
    
    
lookupFanSpeed :: Temperature -> FanSpeed
lookupFanSpeed t = 
    -- Find the first temperature that's higher than t
    case findIndex (\p -> temp p > t) points of
        Just idx -> if idx == 0 
            then 0 -- Lower than defined curve, min speed
            
            else do -- Temp in curve, interpolate for desired fan speed
                let lower = points !! (idx-1)
                let upper = points !! idx
                linearInterpolant lower upper t

        _ -> 100 -- Higher than defined curve, max speed.
