import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/utils/design_mode.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

import '../models/custom_widgets.dart';
import '../models/editor_configs/text_editor_configs.dart';
import '../models/theme/theme.dart';
import '../models/i18n/i18n.dart';
import '../models/icons/icons.dart';
import '../models/layer.dart';
import '../widgets/color_picker/bar_color_picker.dart';
import '../widgets/color_picker/color_picker_configs.dart';
import '../widgets/layer_widget.dart';
import '../widgets/platform_popup_menu.dart';
import '../widgets/pro_image_editor_desktop_mode.dart';

/// A StatefulWidget that provides a text editing interface for adding and editing text layers.
class TextEditor extends StatefulWidget {
  /// Configuration settings for the text editor.
  ///
  /// This parameter allows you to customize the behavior and appearance of the TextEditor.
  final TextEditorConfigs configs;

  /// A unique hero tag for the image.
  final String? heroTag;

  /// The text layer data to be edited, if any.
  final TextLayerData? layer;

  /// Internationalization (i18n) settings for the text editor.
  final I18n i18n;

  /// Custom widgets to be used in the text editor.
  final ImageEditorCustomWidgets customWidgets;

  /// Icons used in the text editor.
  final ImageEditorIcons icons;

  /// The theme settings for the text editor.
  final ImageEditorTheme imageEditorTheme;

  /// The theme configuration for the editor.
  final ThemeData theme;

  final TextStyle? fontStyle;

  /// The design mode of the editor.
  final ImageEditorDesignModeE designMode;

  /// A callback function that can be used to update the UI from custom widgets.
  final Function? onUpdateUI;

  /// Creates a `TextEditor` widget.
  ///
  /// The [heroTag], [layer], [i18n], [customWidgets], and [imageEditorTheme] parameters are required.
  const TextEditor({
    super.key,
    required this.designMode,
    this.heroTag,
    this.layer,
    this.onUpdateUI,
    this.fontStyle,
    this.configs = const TextEditorConfigs(),
    this.icons = const ImageEditorIcons(),
    this.i18n = const I18n(),
    this.customWidgets = const ImageEditorCustomWidgets(),
    this.imageEditorTheme = const ImageEditorTheme(),
    required this.theme,
  });

  @override
  createState() => TextEditorState();
}

/// The state class for the `TextEditor` widget.
class TextEditorState extends State<TextEditor> {
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  Color _primaryColor = Colors.black;
  late TextAlign align;
  late TextStyle fontStyle;
  late LayerBackgroundColorModeE backgroundColorMode;
  int _numLines = 0;
  double _colorPosition = 0;
  String _selectedFont = "Roboto";
  TextStyle _selectedFontTextStyle = GoogleFonts.roboto();

  @override
  void initState() {
    super.initState();
    align = widget.configs.initialTextAlign;
    backgroundColorMode = widget.configs.initialBackgroundColorMode;

    _initializeFromLayer();
    _setupTextControllerListener();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Initializes the text editor from the provided text layer data.
  void _initializeFromLayer() {
    if (widget.layer != null) {
      _textCtrl.text = widget.layer!.text;
      align = widget.layer!.align;
      _selectedFontTextStyle = widget.layer!.fontStyle;
      backgroundColorMode = widget.layer!.colorMode!;
      _primaryColor =
          backgroundColorMode == LayerBackgroundColorModeE.background
              ? widget.layer!.background
              : widget.layer!.color;
      _numLines = '\n'.allMatches(_textCtrl.text).length + 1;
      _colorPosition = widget.layer!.colorPickerPosition ?? 0;
    }
  }

  /// Sets up a listener to update the number of lines when text changes.
  void _setupTextControllerListener() {
    _textCtrl.addListener(() {
      setState(() {
        _numLines = '\n'.allMatches(_textCtrl.text).length + 1;
      });
      widget.onUpdateUI?.call();
    });
  }

  /// Calculates the contrast color for a given color.
  Color _getContrastColor(Color color) {
    int d = color.computeLuminance() > 0.5 ? 0 : 255;

    return Color.fromARGB(color.alpha, d, d, d);
  }

  /// Gets the text color based on the selected color mode.
  Color get _getTextColor {
    return backgroundColorMode == LayerBackgroundColorModeE.onlyColor
        ? _primaryColor
        : backgroundColorMode == LayerBackgroundColorModeE.backgroundAndColor
            ? _primaryColor
            : backgroundColorMode == LayerBackgroundColorModeE.background
                ? _getContrastColor(_primaryColor)
                : _primaryColor;
  }

  /// Gets the background color based on the selected color mode.
  Color get _getBackgroundColor {
    return backgroundColorMode == LayerBackgroundColorModeE.onlyColor
        ? Colors.transparent
        : backgroundColorMode == LayerBackgroundColorModeE.backgroundAndColor
            ? _getContrastColor(_primaryColor)
            : backgroundColorMode == LayerBackgroundColorModeE.background
                ? _primaryColor
                : _getContrastColor(_primaryColor).withOpacity(0.5);
  }

  /// Toggles the text alignment between left, center, and right.
  void toggleTextAlign() {
    setState(() {
      align = align == TextAlign.left
          ? TextAlign.center
          : align == TextAlign.center
              ? TextAlign.right
              : TextAlign.left;
    });
    widget.onUpdateUI?.call();
  }

  /// Toggles the background mode between various color modes.
  void toggleBackgroundMode() {
    setState(() {
      backgroundColorMode = backgroundColorMode ==
              LayerBackgroundColorModeE.onlyColor
          ? LayerBackgroundColorModeE.backgroundAndColor
          : backgroundColorMode == LayerBackgroundColorModeE.backgroundAndColor
              ? LayerBackgroundColorModeE.background
              : backgroundColorMode == LayerBackgroundColorModeE.background
                  ? LayerBackgroundColorModeE.backgroundAndColorWithOpacity
                  : LayerBackgroundColorModeE.onlyColor;
    });
    widget.onUpdateUI?.call();
  }

  void seletedFontStyle() {
    final List<String> _myGoogleFonts = [
      "Abril Fatface",
      "Aclonica",
      "Alegreya Sans",
      "Architects Daughter",
      "Archivo",
      "Archivo Narrow",
      "Bebas Neue",
      "Bitter",
      "Bree Serif",
      "Bungee",
      "Cabin",
      "Cairo",
      "Coda",
      "Comfortaa",
      "Comic Neue",
      "Cousine",
      "Croissant One",
      "Faster One",
      "Forum",
      'Permanent Marker',
      "Great Vibes",
      "Heebo",
      "Inconsolata",
      "Josefin Slab",
      "Lato",
      "Libre Baskerville",
      "Lobster",
      "Lora",
      "Merriweather",
      "Montserrat",
      "Mukta",
      "Nunito",
      "Offside",
      "Open Sans",
      "Oswald",
      "Overlock",
      "Pacifico",
      "Playfair Display",
      "Poppins",
      "Raleway",
      "Roboto",
      "Roboto Mono",
      "Source Sans Pro",
      "Space Mono",
      "Spicy Rice",
      "Squada One",
      "Sue Ellen Francisco",
      "Trade Winds",
      "Ubuntu",
      "Varela",
      "Vollkorn",
      "Work Sans",
      "Zilla Slab",
      'M PLUS Rounded 1c',
      'Almarai',
      'Tajawal',
      'Oleo Script',
      'Viga',
      'Homemade Apple',
      'Fredoka',
      'Oleo Script Swash Caps',
      'Magra',
      'Kaisei Decol',
      'DotGothic16',
      'Fresca',
      'Potta One',
      'Mochiy Pop One',
      'Cherry Cream Soda',
      'Cute Font',
      'Shippori Antique',
      'Mochiy Pop One',
      'Train One',
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: FontPicker(
                showFontInfo: true,
                showFontVariants: true,
                recentsCount: 5,
                lang: 'pt',
                showInDialog: true,
                initialFontFamily: _selectedFont,
                onFontChanged: (font) {
                  setState(() {
                    _selectedFont = font.fontFamily;
                    _selectedFontTextStyle = font.toTextStyle();
                  });
                },
                googleFonts: _myGoogleFonts,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  /// Handles the "Done" action, either by applying changes or closing the editor.
  void done(TextStyle fontStyle) {
    if (_textCtrl.text.trim().isNotEmpty) {
      Navigator.of(context).pop(
        TextLayerData(
          text: _textCtrl.text.trim(),
          background: _getBackgroundColor,
          color: _getTextColor,
          fontStyle: fontStyle,
          align: align,
          colorMode: backgroundColorMode,
          colorPickerPosition: _colorPosition,
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  TextStyle getTextStyle(Color getTextColor, double initFontSize) {
    TextStyle newSelectedTextStyle = _selectedFontTextStyle.copyWith(
        color: getTextColor,
        fontSize: initFontSize,
        height: 1.35,
        letterSpacing: 1);
    return newSelectedTextStyle;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Theme(
          data: widget.theme.copyWith(
              tooltipTheme:
                  widget.theme.tooltipTheme.copyWith(preferBelow: true)),
          child: Scaffold(
            backgroundColor: widget.imageEditorTheme.textEditor.background,
            appBar: _buildAppBar(constraints),
            body: _buildBody(),
            // For desktop devices where there is no physical keyboard, we can center it as we do in the editor.
            bottomNavigationBar: isDesktop
                ? const SizedBox(height: kBottomNavigationBarHeight)
                : null,
          ),
        );
      },
    );
  }

  /// Builds the app bar for the text editor.
  PreferredSizeWidget _buildAppBar(BoxConstraints constraints) {
    return widget.customWidgets.appBarTextEditor ??
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor:
              widget.imageEditorTheme.textEditor.appBarBackgroundColor,
          foregroundColor:
              widget.imageEditorTheme.textEditor.appBarForegroundColor,
          actions: [
            IconButton(
              tooltip: widget.i18n.textEditor.back,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(widget.icons.backButton),
              onPressed: close,
            ),
            const Spacer(),
            if (constraints.maxWidth >= 300) ...[
              if (widget.configs.canToggleTextAlign)
                IconButton(
                  key: const ValueKey('TextAlignIconButton'),
                  tooltip: widget.i18n.textEditor.textAlign,
                  onPressed: toggleTextAlign,
                  icon: Icon(align == TextAlign.left
                      ? widget.icons.textEditor.alignLeft
                      : align == TextAlign.right
                          ? widget.icons.textEditor.alignRight
                          : widget.icons.textEditor.alignCenter),
                ),
              if (widget.configs.canToggleBackgroundMode)
                IconButton(
                  key: const ValueKey('BackgroundModeColorIconButton'),
                  tooltip: widget.i18n.textEditor.backgroundMode,
                  onPressed: toggleBackgroundMode,
                  icon: Icon(widget.icons.textEditor.backgroundMode),
                ),
              IconButton(
                tooltip: "Selecionar Fonte",
                onPressed: seletedFontStyle,
                icon: const Icon(Icons.font_download),
              ),
              const Spacer(),
              _buildDoneBtn(),
            ] else ...[
              const Spacer(),
              _buildDoneBtn(),
              PlatformPopupBtn(
                designMode: widget.designMode,
                title: widget.i18n.textEditor.smallScreenMoreTooltip,
                options: [
                  if (widget.configs.canToggleTextAlign)
                    PopupMenuOption(
                      label: widget.i18n.textEditor.textAlign,
                      icon: Icon(align == TextAlign.left
                          ? widget.icons.textEditor.alignLeft
                          : align == TextAlign.right
                              ? widget.icons.textEditor.alignRight
                              : widget.icons.textEditor.alignCenter),
                      onTap: () {
                        toggleTextAlign();
                        if (widget.designMode ==
                            ImageEditorDesignModeE.cupertino) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  if (widget.configs.canToggleBackgroundMode)
                    PopupMenuOption(
                      label: widget.i18n.textEditor.backgroundMode,
                      icon: Icon(widget.icons.textEditor.backgroundMode),
                      onTap: () {
                        toggleBackgroundMode();
                        if (widget.designMode ==
                            ImageEditorDesignModeE.cupertino) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  PopupMenuOption(
                    label: "Selecionar Fonte",
                    icon: const Icon(Icons.font_download),
                    onTap: () {
                      seletedFontStyle();
                      if (widget.designMode ==
                          ImageEditorDesignModeE.cupertino) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ],
        );
  }

  /// Builds and returns an IconButton for applying changes.
  Widget _buildDoneBtn() {
    return IconButton(
      key: const ValueKey('TextEditorDoneButton'),
      tooltip: widget.i18n.textEditor.done,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: Icon(widget.icons.applyChanges),
      iconSize: 28,
      onPressed: () =>
          done(getTextStyle(_getTextColor, widget.configs.initFontSize)),
    );
  }

  /// Builds the body of the text editor.
  Widget _buildBody() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () =>
          done(getTextStyle(_getTextColor, widget.configs.initFontSize)),
      child: Stack(
        children: [
          _buildTextField(),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: BarColorPicker(
                length: min(
                  350,
                  MediaQuery.of(context).size.height -
                      MediaQuery.of(context).viewInsets.bottom -
                      kToolbarHeight -
                      MediaQuery.of(context).padding.top -
                      30,
                ),
                onPositionChange: (value) {
                  _colorPosition = value;
                },
                initPosition: _colorPosition,
                initialColor: _primaryColor,
                horizontal: false,
                thumbColor: Colors.white,
                cornerRadius: 10,
                pickMode: PickMode.color,
                colorListener: (int value) {
                  setState(() {
                    _primaryColor = Color(value);
                  });
                  widget.onUpdateUI?.call();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the text field for text input.
  Widget _buildTextField() {
    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: widget.configs.initFontSize * _numLines * 1.35 + 15,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: widget.heroTag ?? 'Text-Image-Editor-Empty-Hero',
                    createRectTween: (begin, end) =>
                        RectTween(begin: begin, end: end),
                    child: RoundedBackgroundText(_textCtrl.text,
                        backgroundColor: _getBackgroundColor,
                        textAlign: align,
                        style: getTextStyle(
                          _getTextColor,
                          widget.configs.initFontSize,
                        )),
                  ),
                  IntrinsicWidth(
                    child: TextField(
                      controller: _textCtrl,
                      focusNode: _focus,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
                      textAlign:
                          _textCtrl.text.isEmpty ? TextAlign.center : align,
                      maxLines: null,
                      cursorColor:
                          widget.imageEditorTheme.textEditor.inputCursorColor,
                      cursorHeight: widget.configs.initFontSize * 1.2,
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(
                              12, _numLines <= 1 ? 4 : 0, 12, 0),
                          hintText: _textCtrl.text.isEmpty
                              ? widget.i18n.textEditor.inputHintText
                              : '',
                          hintStyle: TextStyle(
                            color: widget
                                .imageEditorTheme.textEditor.inputHintColor,
                            fontSize: widget.configs.initFontSize,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          )),
                      style: GoogleFonts.roboto(
                        color: Colors.transparent,
                        fontSize: widget.configs.initFontSize,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        letterSpacing: 0.5,
                      ),
                      autofocus: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
