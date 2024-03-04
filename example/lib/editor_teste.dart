import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class EditorTeste extends StatefulWidget {
  const EditorTeste({super.key});

  @override
  State<EditorTeste> createState() => _EditorTesteState();
}

class _EditorTesteState extends State<EditorTeste> {
  final _editor2 = GlobalKey<ProImageEditorState>();
  Uint8List? imgfundo;
  var stateImg;
  late Uint8List imgHistoricy;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    voidmfas();
  }

  

  void voidmfas() {
    var editorimg = ProImageEditor.asset(
      'assets/demo.png',
      key: _editor2,
      onImageEditingComplete: (bytes) async {
        var dataState = await _editor2.currentState!
            .exportStateHistory(
                configs: const ExportEditorConfigs(
              exportCropRotate: true,
              exportEmoji: true,
              exportFilter: true,
              exportPainting: true,
              exportSticker: true,
              exportText: true,
              historySpan: ExportHistorySpan.all,
            ))
            .toJson();

        setState(() {
          stateImg = dataState;
        });
        Navigator.pop(context);
      },
    ).byteArray;
    setState(() {
      imgfundo = editorimg!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editor Img"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imgfundo != null) ...[
            Image.memory(imgfundo!)
          ] else ...[
            Text("Nao carregado")
          ],
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProImageEditor.asset(
                              'assets/demo.png',
                              key: _editor2,
                              onImageEditingComplete: (bytes) async {
                                var dataState = await _editor2.currentState!
                                    .exportStateHistory(
                                        configs: const ExportEditorConfigs(
                                      exportCropRotate: true,
                                      exportEmoji: true,
                                      exportFilter: true,
                                      exportPainting: true,
                                      exportSticker: true,
                                      exportText: true,
                                      historySpan: ExportHistorySpan.all,
                                    ))
                                    .toJson();

                                setState(() {
                                  stateImg = dataState;
                                });
                                Navigator.pop(context);
                              },
                            )));
              },
              child: Text("Editor"))
        ],
      ),
    );
  }
}
