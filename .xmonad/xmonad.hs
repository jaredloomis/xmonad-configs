{-# LANGUAGE NoMonomorphismRestriction #-}
import XMonad hiding ((|||))
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.ResizableTile
import XMonad.Layout.TwoPane
import XMonad.Layout.Renamed
import XMonad.Layout.ComboP
import XMonad.Layout.Master
import XMonad.Layout.LayoutBuilder
import XMonad.Layout.Combo
import XMonad.Layout.Tabbed
import qualified XMonad.StackSet as W
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig
    (additionalKeys, additionalMouseBindings)
import System.IO (Handle, hPutStrLn, hPutStr)
import Data.Monoid (Endo, All)
--import Data.Char (isDigit)
--import Data.List

--------------------
-- Basic Settings --
--------------------

homeDir :: String
homeDir = "/home/fiendfan1"

myTerminal :: String
myTerminal = "xterm"

myBorderWidth :: Dimension
myBorderWidth = 1

myModMask :: KeyMask
myModMask = mod4Mask

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
 
myWorkspaces :: [String]
myWorkspaces =
    clickable . map dzenEscape $ ["Main", "Web", "Misc"]
  where
    clickable :: [String] -> [String]
    clickable labels =
        [
        "^ca(1,xdotool key alt+"++show i++")"++label++"^ca()"
            | (i, label) <- zip [(1::Int)..] labels
        ]

myNormalBorderColor :: String
myNormalBorderColor = "#DDDDDD"
myFocusedBorderColor :: String
myFocusedBorderColor = "#FF0000"

wallpaperImage :: FilePath
wallpaperImage = "/home/fiendfan1/Theme Assets/haskell_pink.png"

--------------------
-- Keymap configs --
--------------------

myKeys :: [((KeyMask, KeySym), X ())]
myKeys =
    [
    -- Toggle the status bar gap.
    ((myModMask, xK_b ), sendMessage ToggleStruts),

    -- Volume control.
    ((myModMask, xK_u), spawn "amixer set Master 2+"),
    ((myModMask, xK_y), spawn "amixer set Master 2-"),

    -- Vertical Resize ResizableTall windows.
    -- !!! These Override default keys !!!
    ((myModMask, xK_j), sendMessage MirrorShrink),
    ((myModMask, xK_k), sendMessage MirrorExpand),

    -- Set the keys 'i' and 'o' to the default actions of
    -- 'j' and 'k', respectively.
    ((myModMask, xK_i), windows W.focusDown),
    ((myModMask, xK_o), windows W.focusUp)
    ]

-- | Mouse bindings.
myMouseBindings :: [((KeyMask, Button), Window -> X ())]
myMouseBindings = []

------------
-- Layout --
------------

-- !!!!!!!!!!!!!!
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
-- !!!!!!!!!!!!!!
myLayout = avoidStruts $ tallLayout ||| hybridLayout ||| Full

-- | A tall layout where all windows on right
--   side can be resized vertically.
tallLayout :: ResizableTall a
tallLayout = ResizableTall 1 0.03 0.5 []

-- | Tabbed layout.
tabLayout = tabbed shrinkText tabTheme
-- | Theme applied to tabbed layout.
tabTheme :: Theme
tabTheme = def {
    inactiveBorderColor = "#FF0000",
    activeTextColor = "#00FF00"
    }

-- | A layout that puts the master window on the
--   left side, and all other windows on the
--   right, in a tabbed layout.
hybridLayout = mastered 0.03 0.5 tabLayout

------------------
-- Window rules --
------------------

-- | Execute arbitrary actions and WindowSet manipulations when managing
--   a new window. You can use this to, for example, always float a
--   particular program, or have a client always appear on a particular
--   workspace.
--
--   To find the property name associated with a program, use
--   > xprop | grep WM_CLASS
--   and click on the client you're interested in.
myManageHook :: Query (Endo WindowSet)
myManageHook = composeAll [
    className =? "lotroclient.exe" --> doFloat,
    className =? "Wine" --> doFloat,
--    className =? "MPlayer"        --> doFloat,
--    className =? "Gimp"           --> doFloat,
--    resource  =? "desktop_window" --> doIgnore,
--    resource  =? "kdesktop"       --> doIgnore,
    manageDocks
    ]

-----------------------
-- Handle Event Hook --
-----------------------

myHandleEventHook :: Event -> X All
myHandleEventHook =
    handleEventHook def <+> docksEventHook

----------------
-- XMonad Bar --
----------------

-- | Base dzen command.
dzenBaseCommand :: String
dzenBaseCommand = "dzen2 -fg '" ++ dzenForeground ++
                "' -bg '" ++ dzenBackground ++
                "' -fn \"" ++ dzenFont ++ "\""

-- | Command to launch the left bar.
dzenBar :: String
dzenBar = dzenBaseCommand ++ " -w '"++dzenSize++"' -x '0'"

-- | Width of left dzen bar.
dzenSizei :: Int
dzenSizei = 900
dzenSize :: String
dzenSize = show dzenSizei

-- | Font used on entire bar.
dzenFont :: String
dzenFont = "Ubuntu:size=13:antialias=true"

-- Colors --

dzenBackground :: String
dzenBackground = "#000000"
dzenForeground :: String
dzenForeground = "#FFFFFF"

dzenNormal :: String -> String
dzenNormal = dzenColor dzenForeground dzenBackground . pad

dzenFocus :: String -> String
dzenFocus = dzenColor "#DEDEDE" "#121212" . pad

dzenUnfocus :: String -> String
dzenUnfocus = dzenColor "#393939" dzenBackground . pad

dzenHidden :: String -> String
dzenHidden = dzenColor "#6D9CBE" dzenBackground . pad

dzenUrgent :: String -> String
dzenUrgent = dzenColor "#FF0000" dzenBackground . pad

dzenLayout :: String -> String
dzenLayout = dzenHidden

dzenOutput :: Handle -> String -> IO ()
dzenOutput outHandle xmonadLog = do
    hPutStr outHandle
        "^i(/home/fiendfan1/.xmonad/icons/images/arch_logo_mine.xbm)  |  "
    hPutStrLn outHandle xmonadLog

-- | A hook to transform log information.
myLogHook :: Handle -> X ()
myLogHook handle =
    dynamicLogWithPP $ def {
        ppCurrent         = dzenFocus,
        ppVisible         = dzenNormal,
        ppHidden          = dzenHidden,
        ppHiddenNoWindows = dzenUnfocus,
        ppUrgent          = dzenUrgent,
        ppLayout          = dzenLayout,
        ppTitle           = (" " ++) .
                            dzenNormal .
                            dzenEscape,
        ppWsSep           = " ",
        ppSep             = "  |  ",
        ppOutput          = dzenOutput handle
    }

---------------
-- Conky Bar --
---------------

-- | Start the conky bar with conkyConfig.
startConkyBar :: IO ()
startConkyBar = do
    writeFile "/home/fiendfan1/.xmonad/.conky_dzen" conkyConfig
    spawn conkyBar

-- | Base conky command.
conkyCommand :: String
conkyCommand = "conky -c /home/fiendfan1/.xmonad/.conky_dzen"

-- | Command to start conky with output being
--   directed to a new dzen bar.
conkyBar :: String
conkyBar = conkyCommand ++ " | " ++
           dzenBaseCommand ++ " -w '"++conkySize++"' -x '"++dzenSize++"'"

-- | My screen is 1600px wide.
conkySize :: String
conkySize = show $ 1600 - dzenSizei

conkyConfig :: String
conkyConfig =
    -- Conky settings.
    "background yes\nout_to_console yes\nout_to_x no\n" ++
    "update_interval 1.0\ncpu_avg_samples 2\n" ++

    -- Begin content.
    "TEXT\n" ++
    "^i(/home/fiendfan1/.xmonad/icons/images/spkr_01.xbm)  " ++

    -- Volume display.
    "^fg(\\#0055FF)${exec amixer get Master " ++
    "| grep \"Mono: Playback\" | egrep -o \"[0-9]+%\"}  " ++

    -- CPU usage display.
    "^fg()|  ^i(/home/fiendfan1/.xmonad/icons/images/cpu.xbm)  " ++
    "^fg(\\#FF0055)${cpu cpu1}% ${cpu cpu2}% " ++
    "${cpu cpu3}% ${cpu cpu4}%^fg()  |  " ++

    -- RAM usage display.
    "^i(/home/fiendfan1/.xmonad/icons/images/mem.xbm)  " ++
    "^fg(\\#55FF00)${mem} ^fg()  |  " ++

    -- GPU usage display. I am using an AMD GPU.
    "^i(/home/fiendfan1/.xmonad/icons/images/pacman.xbm)  " ++
    "^fg(\\#D4FF00)${exec aticonfig --odgc --adapter=0" ++
    " | grep \"GPU load\" | egrep -o \"[0-9]+%\"}" ++

    -- Time display.
    "^fg()  |  ^i(/home/fiendfan1/.xmonad/icons/stlarch/clock1.xbm)  " ++
    "^fg(\\#0055FF)${time %l:%M %p}" ++
    "\n"

------------------
-- Startup hook --
------------------
 
-- | Perform an arbitrary action each time xmonad starts or is restarted
--   with mod-q.
myStartupHook :: X ()
myStartupHook = do
    io $ setWallpaper wallpaperImage
    io comptonStart

-- | Start compton with config file.
comptonStart :: IO ()
comptonStart = spawn $ "compton --config /home/fiendfan1/.compton.conf"

-- | Set wallpaper.
setWallpaper :: FilePath -> IO ()
setWallpaper file =
        spawn $ "feh --bg-fill \""++file++"\""

----------
-- Main --
----------

main :: IO ()
main = do
    dzenHandle <- spawnPipe dzenBar
    startConkyBar
    xmonad $ myConfig dzenHandle

myConfig barHandle = def {
    -- Simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,
 
    -- Hooks, layouts...
    layoutHook         = myLayout,
    manageHook         = myManageHook,
    logHook            = myLogHook barHandle,
    startupHook        = myStartupHook,
    handleEventHook    = docksEventHook
    } `additionalKeys` myKeys
      `additionalMouseBindings` myMouseBindings
