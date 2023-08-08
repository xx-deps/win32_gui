import 'package:logging/logging.dart' as logging;
import 'package:win32/win32.dart';

import '../win32_gui_base.dart';

final _log = logging.Logger('Win32:Button');

/// A [ChildWindow] of class `button`.
class Button extends ChildWindow {
  static final buttonWindowClass = WindowClass.predefined(
    className: 'button',
  );

  /// The command of this button when clicked.
  final void Function(int lParam)? onCommand;

  Button(
      {super.id,
      super.parent,
      required String label,
      int windowStyles = WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
      int x = CW_USEDEFAULT,
      int y = CW_USEDEFAULT,
      int width = CW_USEDEFAULT,
      int height = CW_USEDEFAULT,
      super.bgColor,
      this.onCommand})
      : super(
          windowClass: buttonWindowClass,
          windowName: label,
          windowStyles: windowStyles,
          x: x,
          y: y,
          width: width,
          height: height,
        );

  /// Calls [onCommand].
  /// See [super.processCommand].
  @override
  void processCommand(int hwnd, int hdc, int lParam) {
    _log.info('[hwnd: $hwnd, hdc: $hdc] processCommand> lParam: $lParam');

    final onCommand = this.onCommand;

    if (onCommand != null) {
      onCommand(lParam);
    }
  }

  @override
  String toString() {
    return 'Button#$hwndIfCreated{id: $id}';
  }
}
