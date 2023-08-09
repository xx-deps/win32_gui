import 'dart:io';

import 'package:win32_gui/win32_gui.dart';
import 'package:win32_gui/win32_gui_logging.dart';

Future<void> main() async {
  logToConsole();

  // Some Window class colors:
  var editColors = WindowClassColors(
    textColor: RGB(0, 0, 0),
    bgColor: RGB(128, 128, 128),
  );

  // Set the colors of pre-defined Window classes (affects `RichEdit`):
  WindowClass.editColors = editColors;
  WindowClass.staticColors = editColors;

  // A custom main Window class declared bellow:
  var mainWindow = MainWindow(
    width: 640,
    height: 480,
  );

  // Creates the main Window:
  print('-- mainWindow.create...');
  await mainWindow.create();

  // Shows the main Window:
  print('-- mainWindow.show...');
  mainWindow.show();

  // When the window is closed (won't be destroyed):
  mainWindow.onClose.listen((window) {
    print('-- Main Window closed> $window');
    print('-- Main Window isMinimized> ${mainWindow.isMinimized}');

    var confirmed = mainWindow.showConfirmationDialog(
        "Exit Confirmation", "Exit Application?");

    if (confirmed) {
      mainWindow.destroy();
    } else {
      mainWindow.showMessage(
          'Application Status', 'Application window minimized.');
    }
  });

  // When the window is destroyed `exit`:
  mainWindow.onDestroyed.listen((window) {
    print('-- Main Window Destroyed> $window');
    exit(0);
  });

  // Run the Win32 Window message loop:
  print('-- Window.runMessageLoopAsync...');
  await Window.runMessageLoopAsync();
}

class MainWindow extends Window {
  // Declare the main window custom class:
  static final mainWindowClass = WindowClass.custom(
    className: 'mainWindow',
    windowProc: Pointer.fromFunction<WindowProc>(mainWindowProc, 0),
    bgColor: RGB(255, 255, 255),
    useDarkMode: true,
    titleColor: RGB(32, 32, 32),
  );

  // Redirect to default implementation [WindowClass.windowProcDefault].
  static int mainWindowProc(int hwnd, int uMsg, int wParam, int lParam) =>
      WindowClass.windowProcDefault(
          hwnd, uMsg, wParam, lParam, mainWindowClass);

  // Child elements:
  late final TextOutput textOutput;
  late final Button buttonOK;
  late final Button buttonExit;

  MainWindow({super.width, super.height})
      : super(
          defaultRepaint: false, // Tells to call the custom `repaint()` below.
          windowName: 'Win32 GUI - Example', // The Window title.
          windowClass: mainWindowClass,
          windowStyles: WS_MINIMIZEBOX | WS_SYSMENU,
        ) {
    textOutput =
        TextOutput(parent: this, x: 4, y: 160, width: 626, height: 250);

    buttonOK = Button(
        label: 'OK',
        parent: this,
        x: 4,
        y: 414,
        width: 100,
        height: 32,
        onCommand: (p) => print('** Button OK Click!'));

    // The exit button (`destroy` this Window).
    buttonExit = Button(
        label: 'Exit',
        parent: this,
        x: 106,
        y: 414,
        width: 100,
        height: 32,
        onCommand: (p) {
          print('** Button Exit Click!');
          destroy();
        });
  }

  late final String imageDartLogoPath;
  late final String iconDartLogoPath;

  // Load resources (called by `create()`):
  @override
  Future<void> load() async {
    imageDartLogoPath = await Window.resolveFilePath(
        'package:win32_gui/resources/dart-logo.bmp');

    print('-- imageDartLogoPath: $imageDartLogoPath');

    iconDartLogoPath = await Window.resolveFilePath(
        'package:win32_gui/resources/dart-icon.ico');

    print('-- iconDartLogoPath: $iconDartLogoPath');
  }

  // Called when processing a `WM_CREATE` message (generated by `create()`):
  @override
  void build(int hwnd, int hdc) {
    super.build(hwnd, hdc);

    SetTextColor(hdc, RGB(255, 255, 255));
    SetBkColor(hdc, RGB(96, 96, 96));

    // Sets the Window icon:
    setIcon(iconDartLogoPath);

    // Set Window rounding corners:
    setWindowRoundedCorners();
  }

  // Custom repaint. Called when processing a `WM_PAINT` message and `this.defaultRepaint = false`:
  @override
  void repaint(int hwnd, int hdc) {
    var hBitmap = loadImageCached(imageDartLogoPath);
    var imgDimension = getBitmapDimension(hBitmap);

    // Valid Bitmap:
    if (imgDimension != null) {
      // Loads a 24-bits Bitmap:
      var imgW = imgDimension.width;
      // Get the Bitmap dimensions:
      var imgH = imgDimension.height;

      // Center image horizontally:
      final x = (dimensionWidth - imgW) ~/ 2;
      final y = 10;

      // Draws the Bitmap copying its bytes to this Window.
      drawImage(hdc, hBitmap, x, y, imgW, imgH);
    }

    textOutput.callRepaint();
  }
}

// A custom `RichEdit`:
class TextOutput extends RichEdit {
  TextOutput({super.parent, super.x, super.y, super.width, super.height})
      : super(bgColor: RGB(32, 32, 32)) {
    print('-- `TextOutput` default font: `$defaultFont`');
  }

  @override
  void build(int hwnd, int hdc) {
    super.build(hwnd, hdc);

    setBkColor(RGB(32, 32, 32));
    setTextColor(hdc, RGB(255, 255, 255));

    // Enable automatic detection of URLs:
    setAutoURLDetect(true);
  }

  @override
  void repaint(int hwnd, int hdc) {
    // Forces full repaint of the component:
    invalidateRect();

    setBkColor(RGB(32, 32, 32));
    setTextColor(hdc, RGB(255, 255, 255));

    // Sets the `RichEdit` texts with formatted lines:
    setTextFormatted([
      TextFormatted(" -------------------------\r\n",
          color: RGB(255, 255, 255)),
      TextFormatted(" Hello", color: RGB(0, 255, 255), faceName: 'Courier New'),
      TextFormatted(" Word! \r\n", color: RGB(0, 255, 0)),
      TextFormatted(" -------------------------\r\n",
          color: RGB(255, 255, 255)),
    ]);
  }
}
