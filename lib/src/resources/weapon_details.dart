// List of every weapon available in this game
// id == list index
const List<Map<String, dynamic>> weaponDetails = [
  {
    'id': 0,
    'name': 'Punch',
    'description': 'Hit the enemy in front of you.\n'
        'This is the most basic weapon. You have infite PP.\n'
        'Atk of this weapon is directly proportional to your level.',
    'prize': 0,
  },
  {
    'id': 1,
    'name': 'SnowBall',
    'description': 'Throw snowball in front of you.\n'
        'Its power increases by 2 at each level.',
    'prize': 1000,
  },
  {
    'id': 2,
    'name': 'Mine',
    'description': 'Leave explosive mine on the floor.\n'
        'A mine explodes if someone except you walks on it.\n'
        'Its power increases by 2 at each level.',
    'prize': 3000,
  },
];
