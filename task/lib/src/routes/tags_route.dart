import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import 'package:taskw/taskw.dart';

class TagsRoute extends StatefulWidget {
  TagsRoute({this.value, this.callback});

  final List<String> value;
  final void Function(List<String>) callback;

  @override
  TagsRouteState createState() => TagsRouteState();
}

class TagsRouteState extends State<TagsRoute> {
  Map<String, int> globalTags;
  List<String> draftTags;

  void _addTag(String tag) {
    if (draftTags == null) {
      draftTags = [tag];
    } else {
      draftTags.add(tag);
    }
    widget.callback(draftTags);
    setState(() {});
  }

  void _removeTag(String tag) {
    draftTags.remove(tag);
    widget.callback((draftTags.isEmpty) ? null : draftTags);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    draftTags = widget.value;
    getApplicationDocumentsDirectory().then((dir) {
      globalTags = Profiles(dir).getCurrentStorage().tags()
        ..putIfAbsent(
          'next',
          () => 0,
        );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('tags'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (draftTags != null)
                for (var tag in draftTags)
                  FilterChip(
                    onSelected: (_) => _removeTag(tag),
                    label: Text(
                      '+$tag',
                      style: GoogleFonts.firaMono(),
                    ),
                  ),
              Divider(),
              if (globalTags != null)
                for (var tag in globalTags.entries
                    .where((tag) => !(draftTags?.contains(tag.key) ?? false)))
                  FilterChip(
                    onSelected: (_) => _addTag(tag.key),
                    label: Text(
                      '-${tag.key}',
                      style: GoogleFonts.firaMono(),
                    ),
                  ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          var controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              scrollable: true,
              title: Text('Add tag'),
              content: TextField(
                autofocus: true,
                controller: controller,
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Submit'),
                  onPressed: () {
                    _addTag(controller.text);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
