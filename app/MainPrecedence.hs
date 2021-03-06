{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}
-- import Simple
-- import           ExprSimple
import           ExprPrecedence
-- import ExprSimpleOrig

import           Control.Lens
import           Control.Zipper
import           Data.Tree
import           Data.Tree.Lens

main :: IO ()
main = do
-- main = getContents >>= print . calc . lexer
-- main = (print . calc . lexer) "AB"
  -- (print . calc . lexer) "1 + 2"
-- main = (print . pretty . calc . lexer) "1 + 2"
  -- let is = lexer' "1 + 2"
  -- putDoc $ pretty is
  putStr $ drawTree $ fmap show ptree

  putStrLn "--------------------------------"
  putStr $ drawTree $ fmap show newTree
  putStrLn "--------------------------------"

  let p' = calc [newTree]
  putStr $ drawTree $ fmap show p'
  return ()

ptree :: HappyInput
ptree = (calc . lexer) "1 + 2 - 3"

zipperTree :: Top :>> HappyInput
zipperTree = zipper ptree

foo :: IO ()
foo =
-- show
    -- zipperTree & downward root & view focus
    showTree newTree

{-
1 + 2 * 3
(Plus
  (Int 1)
  (Times (Int 2) (Int 3)))
-}
newTree :: Tree NodeVal
newTree =
    zipperTree
               & downward root & focus %~ setChangedChild & upward

               & downward branches
               & fromWithin traverse
               & tugs rightward 1 -- HappyAbsSyn7
               & downward root & focus %~ setChangedChild & upward

               & downward branches
               & fromWithin traverse
               & downward root & focus %~ setChangedChild & upward

               & downward branches
               & fromWithin traverse
               & tugs rightward 1
               & downward root & focus %~ setChangedChild & upward

               & downward root
               -- & view focus
               & focus %~ changeVal
               & rezip

changeVal :: NodeVal -> NodeVal
changeVal _ = Val True True (HappyErrorToken (-5)) Nothing [mkTok TokenTimes ] Nothing Nothing False False False

setChangedChild :: NodeVal -> NodeVal
setChangedChild v = v { changedChild = True}

showTree :: Show a => Tree a -> IO ()
showTree tree = putStrLn $ drawTree $ fmap show tree

bar :: IO String
bar = fmap rezip $ zipper "stale" & within traverse <&> tugs rightward 2 <&> focus .~ 'y'
