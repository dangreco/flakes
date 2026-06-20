module LibSpec (spec) where

import Lib (add)
import Test.Hspec

spec :: Spec
spec = describe "add" $ do
  it "adds positives" $ add 2 3 `shouldBe` 5
  it "adds negatives" $ add (-2) (-3) `shouldBe` (-5)
  it "adds zero" $ add 0 0 `shouldBe` 0
