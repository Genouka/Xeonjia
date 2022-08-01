import 'package:flutter/material.dart';
import 'package:xeonjia/game/components/common/walker.dart';
import 'package:xeonjia/game/xeonjia_game.dart';

// Group of players
class Team {
  Team(this.gameRef,
      {required this.id, this.name = 'Team', this.color = Colors.blue});

  // Current game
  final XeonjiaGame gameRef;

  // Team id
  final int id;

  // Team name
  final String name;

  // Team color
  final Color color;

  // Team members
  List<Walker> get members =>
      gameRef.players.where((player) => player.teamId == id).toList();

  // Team points acquired by friendly fire defeats
  int basisPoints = 0;

  // Team points (basePoints + players points)
  int get points => basisPoints + members.fold(0, (p, m) => p + m.points);
}
