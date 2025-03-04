import 'package:flutter/material.dart';
import 'package:golden_screenshot/src/screenshot_device.dart';

/// A builder that can add a top and bottom bar to its [child].
///
/// It should also set [MediaQueryData.padding] so that [SafeArea]s work.
typedef ScreenshotFrameBuilder = Widget Function(
    {required ScreenshotDevice device, required ScreenshotFrameColors? frameColors, required Widget child});

/// The frame's colors can be customized with this
/// to match the content of the app.
///
/// If these brightnesses aren't provided, they will be guessed from
/// the current theme's surface color.
class ScreenshotFrameColors {
  const ScreenshotFrameColors({this.topBarIconBrightness, this.gestureHintBrightness});

  /// The foreground (text and icons) brightness of the top bar.
  final Brightness? topBarIconBrightness;

  /// The foreground (gesture hint) brightness of the bottom bar.
  final Brightness? gestureHintBrightness;

  /// Sets the foregrounds (text, icons, and gesture hint) to [Brightness.light]
  static const light = ScreenshotFrameColors(topBarIconBrightness: Brightness.light, gestureHintBrightness: Brightness.light);

  /// Sets the foregrounds (text, icons, and gesture hint) to [Brightness.dark]
  static const dark = ScreenshotFrameColors(topBarIconBrightness: Brightness.dark, gestureHintBrightness: Brightness.dark);
}

/// A widget that draws a frame around its [child].
/// Each constructor creates a different frame.
class ScreenshotFrame extends StatelessWidget {
  /// Creates a frame with no top or bottom bar.
  const ScreenshotFrame.noFrame({super.key, required this.device, this.frameColors, required this.child})
      : topBarSize = null,
        topBarImage = null,
        gestureHintSize = null,
        bottomBarImage = null,
        bottomBarSize = null;

  /// Creates a frame with a status bar and a navigation bar.
  const ScreenshotFrame.android({super.key, required this.device, this.frameColors, required this.child})
      : topBarSize = const Size(1440, 145),
        topBarImage = androidTopBarImage,
        gestureHintSize = const Size(125, 4),
        bottomBarImage = null,
        bottomBarSize = null;

  /// Creates a frame with an iPhone 5.5" top bar.
  /// There is no bottom bar because the iPhone 5.5" has a home button.
  const ScreenshotFrame.olderIphone({super.key, required this.device, this.frameColors, required this.child})
      : topBarSize = const Size(1242, 60),
        topBarImage = olderIphoneTopBarImage,
        gestureHintSize = null,
        bottomBarImage = null,
        bottomBarSize = null;

  /// Creates a frame with an iPhone 6.5" top bar and a bottom bar.
  const ScreenshotFrame.newerIphone({super.key, required this.device, this.frameColors, required this.child})
      : topBarSize = const Size(1320, 186),
        topBarImage = newerIphoneTopBarImage,
        gestureHintSize = const Size(150, 5),
        bottomBarImage = null,
        bottomBarSize = null;

  /// Creates a frame with an iPad 12.9" top bar.
  /// There is no bottom bar because the iPad 12.9" has a home button.
  const ScreenshotFrame.olderIpad({super.key, required this.device, this.frameColors, required this.child})
      : topBarSize = const Size(2048, 40),
        topBarImage = olderIpadTopBarImage,
        gestureHintSize = null,
        bottomBarImage = null,
        bottomBarSize = null;

  /// Creates a frame with an iPad 13" top bar and a bottom bar.
  const ScreenshotFrame.newerIpad({super.key, required this.device, this.frameColors, required this.child})
      : topBarSize = const Size(2064, 48),
        topBarImage = newerIpadTopBarImage,
        gestureHintSize = const Size(320, 6),
        bottomBarImage = null,
        bottomBarSize = null;

  const ScreenshotFrame.androidKeyboardLight({super.key, required this.device, this.frameColors, required this.child})
      : topBarSize = const Size(1440, 145),
        topBarImage = androidTopBarImage,
        gestureHintSize = null,
        bottomBarImage = androidLightKeyboardImage,
        bottomBarSize = const Size(1440, 1022);

  const ScreenshotFrame.androidKeyboardDark({super.key, required this.device, this.frameColors, required this.child})
      : topBarSize = const Size(1440, 145),
        topBarImage = androidTopBarImage,
        gestureHintSize = null,
        bottomBarImage = androidDarkKeyboardImage,
        bottomBarSize = const Size(1440, 1022);

  /// The device that this frame will simulate.
  final ScreenshotDevice device;

  /// The colors of the top and bottom bars.
  final ScreenshotFrameColors? frameColors;

  // The size of the top bar, if any.
  final Size? topBarSize;

  final Size? bottomBarSize;

  /// The image of the top bar, if any.
  /// This will have the same size as [topBarSize].
  final ImageProvider? topBarImage;

  final ImageProvider? bottomBarImage;

  /// The size of the gesture hint in the bottom bar, if any.
  /// This is the size of the hint, not the bar itself.
  final Size? gestureHintSize;

  /// The child that will be rendered inside the frame.
  final Widget child;

  Brightness _getStatusBarIconBrightness(BuildContext context) {
    if (frameColors?.topBarIconBrightness != null) {
      return frameColors!.topBarIconBrightness!;
    }

    return _iconBrightnessForBackgroundColor(Theme.of(context).colorScheme.surface);
  }

  Brightness _getGestureHintBrightness(BuildContext context) {
    if (frameColors?.gestureHintBrightness != null) {
      return frameColors!.gestureHintBrightness!;
    }

    return _iconBrightnessForBackgroundColor(Theme.of(context).colorScheme.surface);
  }

  Brightness _iconBrightnessForBackgroundColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Brightness.dark : Brightness.light;
  }

  Color _getIconColor(BuildContext context, Brightness iconBrightness) {
    final theme = Theme.of(context);
    if (theme.brightness == iconBrightness) {
      return theme.colorScheme.surface;
    } else {
      return theme.colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final logicalTopBarHeight = topBarSize == null ? 0.0 : topBarSize!.height / topBarSize!.width * mediaQuery.size.width;
    final logicalBottomBarHeight = gestureHintSize == null
        ? 0.0
        : bottomBarSize == null
            ? 24.0
            : bottomBarSize!.height / bottomBarSize!.width * mediaQuery.size.width;

    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: EdgeInsets.only(top: logicalTopBarHeight, bottom: logicalBottomBarHeight),
        viewPadding: EdgeInsets.only(top: logicalTopBarHeight, bottom: logicalBottomBarHeight),
      ),
      child: Stack(
        children: [
          child,
          if (logicalTopBarHeight > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: logicalTopBarHeight,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(_getIconColor(context, _getStatusBarIconBrightness(context)), BlendMode.srcIn),
                child: Image(image: topBarImage!),
              ),
            ),
          if (logicalBottomBarHeight > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: logicalBottomBarHeight,
              child: bottomBarImage == null
                  ? Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _getIconColor(context, _getGestureHintBrightness(context)),
                        ),
                        child: SizedBox(width: gestureHintSize!.width, height: gestureHintSize!.height),
                      ),
                    )
                  : Image(image: bottomBarImage!),
            ),
        ],
      ),
    );
  }

  /// An image of the Android status bar.
  static const androidTopBarImage = AssetImage('assets/topbars/android_topbar.png', package: 'golden_screenshot');

  /// An image of the top bar of an older iPhone.
  static const olderIphoneTopBarImage = AssetImage('assets/topbars/older_iphone_topbar.png', package: 'golden_screenshot');

  /// An image of the top bar of a newer iPhone.
  static const newerIphoneTopBarImage = AssetImage('assets/topbars/newer_iphone_topbar.png', package: 'golden_screenshot');

  /// An image of the top bar of an older iPad.
  static const olderIpadTopBarImage = AssetImage('assets/topbars/older_ipad_topbar.png', package: 'golden_screenshot');

  /// An image of the top bar of a newer iPad.
  static const newerIpadTopBarImage = AssetImage('assets/topbars/newer_ipad_topbar.png', package: 'golden_screenshot');

  static const androidDarkKeyboardImage = AssetImage('assets/keyboards/android_dark_num_keyboard.png', package: 'golden_screenshot');

  static const androidLightKeyboardImage = AssetImage('assets/keyboards/android_light_num_keyboard.png', package: 'golden_screenshot');
}
