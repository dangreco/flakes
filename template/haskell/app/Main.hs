module Main (main) where

import Lib (add)

main :: IO ()
main = putStrLn ("2 + 3 = " <> show (add 2 3))
