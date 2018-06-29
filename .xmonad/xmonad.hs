{-# LANGUAGE
     DeriveDataTypeable,
     FlexibleContexts,
     FlexibleInstances,
     MultiParamTypeClasses,
     NoMonomorphismRestriction,
     PatternGuards,
     ScopedTypeVariables,
     TypeSynonymInstances,
     UndecidableInstances
     #-}
{-# OPTIONS_GHC -W -fwarn-unused-imports -fno-warn-missing-signatures #-}

import qualified Data.Map as M
import qualified Data.List as L
import qualified XMonad.StackSet as W
import XMonad
import XMonad.Actions.Navigation2D
import XMonad.Actions.PhysicalScreens
import XMonad.Actions.UpdatePointer
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.IndependentScreens
import XMonad.Layout.MultiColumns
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.MultiToggle
import XMonad.Layout.Renamed
import XMonad.Layout.Reflect
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Util.Run
import XMonad.Util.WorkspaceCompare


main :: IO ()
main = do
  xmproc <- spawnPipe "/usr/bin/xmobar -x 1 ~/.xmobarrc"
  xmonad $ withNavigation2DConfig def . docks $ defaultConfig
    { manageHook = myManageHook <+> manageHook defaultConfig
    , layoutHook = avoidStruts  $  layoutHook defaultConfig
    , startupHook = spawn "~/.screenlayout/$(xrandr | grep ' connected' | wc -l).sh"
    , logHook = dynamicLogWithPP xmobarPP
                  { ppOutput = hPutStrLn xmproc
                  , ppTitle = xmobarColor "green" ""
                  , ppLayout = xmobarColor "orange" ""
                  , ppSort = getSortByTag
                  , ppHidden = const ""
                  } >> updatePointer (0.5,0.5) (0.2,0.2)
    , focusFollowsMouse = True
    , borderWidth = 1
    , normalBorderColor = "#ff0000"
    , focusedBorderColor = "#0088ff"
    , workspaces = myWorkspaces
    , keys = \c -> myKeys c `M.union` keys defaultConfig c
    }

myManageHook = composeAll . concat $
   [ [ fmap ( c `L.isInfixOf`) className --> doCenterFloat | c <- myMatchAnywhereFloatsClass ]
   , [ fmap ( c `L.isInfixOf`) title --> doCenterFloat | c <- myMatchAnywhereFloatsTitle ]
   , [ manageDocks ]
   ]
  where
    myMatchAnywhereFloatsClass = []
    myMatchAnywhereFloatsTitle = ["Copying", "Moving", "Deleting"]

myWorkspaces = ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "<-"]

myTabConfig = defaultTheme { inactiveBorderColor = "#ff0000"
                           , activeBorderColor = "#0088ff"
                           , activeColor = "#000000"
                           , inactiveColor = "#000000"
                           , decoHeight = 18
                           }

data TABBED = TABBED deriving (Read, Show, Eq, Typeable)
instance Transformer TABBED Window where
  transform _ x k = k (tabbed shrinkText myTabConfig) (const x)


myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList
  $ [((m .|. modm, k), windows $ onCurrentScreen f i)
     | (i, k) <- zip (workspaces' conf) [xK_grave, xK_1, xK_2, xK_3, xK_4, xK_5, xK_6, xK_7, xK_8, xK_9, xK_0, xK_minus, xK_equal, xK_BackSpace]
     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
     ]
