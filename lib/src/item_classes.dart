import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fredi/classes/toDo_class.dart';
import 'package:fredi/functions/utilities_functions.dart';

import '../screens/homeTab/createNewItem_screen.dart';

/*
Active items:
- Proposal
- Event
- Idea
- Task
- Note

Premium items:
- Ask
- Scan
- Poll

Under Development items:
- Payment
- Subscription
- Reminder
- Announcement
- Collection (list)

 */

enum FrediItemType { Proposal, Task, Event, Idea, Note }

class FrediItem {
  IconData icon;
  Color color;
  String title;
  String description;
  String authorId;
  List<String> tags;
  DateTime? date;
  String id;
  FrediItemType type;
  String groupId;
  bool pinned;
  bool terminated;
  int addedTimestamp;
  List<String> seenBy;
  Map<String, Map> images;
  Map<String, Map> files;
  Map<String, String> links;
  String? location;
  TaskImportance? importance;
  List<ToDo> todoList;
  List<String> collaboratorIds;

  //add audio recording to every item.

  @override
  bool operator ==(other) {
    return (other is FrediItem) && other.id == id;
  }

  FrediItem({
    required this.title,
    required this.color,
    required this.icon,
    required this.type,
    required this.id,
    required this.authorId,
    required this.addedTimestamp,
    required this.groupId,
    required this.seenBy,
    required this.images,
    required this.terminated,
    required this.files,
    required this.links,
    required this.todoList,
    required this.collaboratorIds,
    required this.description,
    required this.pinned,
    required this.tags,
    this.location,
    this.importance,
    this.date,
  });

  Future<Map<String, dynamic>> toJson() async => {
        'title': title,
        'id': id,
        'description': description,
        'author_id': authorId,
        'pinned': pinned,
        'group_id': groupId,
        'added_timestamp': addedTimestamp,
        'terminated': false,
        'type': type.toString(),
        if (date != null) 'date': date.toString(),
        if (location != null) 'location': location,
        if (importance != null) 'importance': importance.toString(),
        'attachments': {'links': links, 'images': images, 'files': files},
        'tags': formatTags(tags),
        'todo_list': todoToMap(todoList),
        'collaborators': collaboratorIdsToMap(collaboratorIds)
      };

  static List<String> formatLinksFromDB(Map map) {
    final List<String> links = [];

    map.forEach((key, value) {
      links.add(value);
    });

    return links;
  }

  static List<File> formatImagesFromDB(Map map) {
    final List<File> images = [];

    map.forEach((key, value) {
      images.add(value);
    });

    return images;
  }

  static List<FrediItem> itemsFromJson(Map map, String groupId) {
    List<FrediItem> items = [];

    map.forEach((key, value) {
      final itemId = key as String;
      final groupId = value['group_id'] as String;
      final title = value['title'] as String;
      final description = value['description'] as String;
      final type = value['type'] as String;
      final authorId = value['author_id'] as String;

      final pinned = value['pinned'] as bool;
      final terminated = value['terminated'] as bool;

      final addedTimestamp = value['added_timestamp'] as int;

      final date = value['date'] as String?;
      final importance = value['importance'] as String?;
      final location = value['location'] as String?;

      final tags = value['tags'] as Map?;
      final linkMap = value['attachments']?['links'] as Map?;
      final filesMap = value['attachments']?['files'] as Map?;
      final imagesMap = value['attachments']?['images'] as Map?;
      final todoMap = value['todo_list'] as Map?;
      final seenBy = value['seen_by'] as Map?;
      final collaboratorsMap = value['collaborators'] as Map?;

      FrediItem? itemToAdd = FrediItem(
        title: title,
        description: description,
        id: itemId,
        groupId: groupId,
        addedTimestamp: addedTimestamp,
        pinned: pinned,
        terminated: terminated,
        seenBy: FrediItem.seenByFromJson(seenBy ?? {}),
        todoList: FrediItem.todoFromJson(todoMap ?? {}),
        links: Map<String, String>.from(linkMap ?? {}),
        images: Map<String, Map>.from(imagesMap ?? {}),
        files: Map<String, Map>.from(filesMap ?? {}),
        date: (date == null) ? null : DateTime.parse(date),
        tags: FrediItem.tagsFromJson(tags ?? {}),
        collaboratorIds: FrediItem.collaboratorIdsFromJson(collaboratorsMap ?? {}),
        location: location,
        importance: TaskImportance.values.firstWhere((imp) => imp.toString() == importance),
        type: FrediItemType.values.firstWhere((t) => t.toString() == type),
        color: getItemColor(FrediItemType.values.firstWhere((t) => t.toString() == type)),
        icon: getItemIcon(FrediItemType.values.firstWhere((t) => t.toString() == type)),
        authorId: authorId,
      );

      items.add(itemToAdd);
    });
    return items;
  }

  static List<ToDo> todoFromJson(Map todoMap) {
    List<ToDo> todoList = [];

    todoMap.forEach((key, value) {
      String title = key;
      bool checked = value;
      todoList.add(ToDo(title: title, checkboxBool: checked));
    });

    return todoList;
  }

  static List<String> linksFromJson(Map linksMap) {
    List<String> links = [];
    linksMap.forEach((key, value) {
      links.add(value);
    });
    return links;
  }

  static formatDate(DateTime? pickedDate) {
    if (pickedDate == null) {
      return false;
    } else {
      return pickedDate.toString();
    }
  }

  static formatTags(List<String> tags) {
    Map tagsMap = {};
    for (String tag in tags) {
      tagsMap[tag] = true;
    }
    return tagsMap;
  }

  static List<String> tagsFromJson(Map tagsMap) {
    List<String> tags = [];

    tagsMap.forEach((key, value) {
      tags.add(key);
    });

    return tags;
  }

  static List<String> collaboratorIdsFromJson(Map collaboratorIdsMap) {
    List<String> collaboratorIds = [];

    collaboratorIdsMap.forEach((key, value) {
      collaboratorIds.add(key);
    });

    return collaboratorIds;
  }

  static Map collaboratorIdsToMap(List<String> collaboratorIds) {
    Map collaboratorMap = {};

    for (String id in collaboratorIds) {
      collaboratorMap[id] = true;
    }

    return collaboratorMap;
  }

  static Map todoToMap(List<ToDo> todoList) {
    Map todoMap = {};

    for (ToDo todo in todoList) {
      todoMap[todo.title] = todo.checkboxBool;
    }

    return todoMap;
  }

  static importanceFromString(String strImportance) {
    TaskImportance importance = TaskImportance.values.firstWhere((imp) => imp.toString() == strImportance);
    return importance;
  }

  static List<String> seenByFromJson(Map seenByMap) {
    List<String> seenBy = [];
    if (seenByMap.isEmpty) {
      return [];
    }

    seenByMap.forEach((id, value) {
      seenBy.add(id);
    });

    return seenBy;
  }
}

class ItemType {
  String title;
  IconData icon;
  IconData? specialButtonIcon;
  String specialButtonText;
  Color color;
  bool enabled;
  String? comingSoonText;

  @override
  bool operator ==(other) {
    return (other is ItemType) && other.title == title;
  }

  ItemType(
      {required this.title,
      this.comingSoonText,
      required this.specialButtonText,
      required this.icon,
      this.specialButtonIcon,
      required this.color,
      required this.enabled});
}
