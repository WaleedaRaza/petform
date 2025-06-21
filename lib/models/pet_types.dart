// Centralized pet types and their custom fields

const Map<String, List<String>> petFields = {
  'Dog': ['Favorite Park', 'Leash Source', 'Favorite Toy'],
  'Cat': ['Litter Type'],
  'Turtle': ['Tank Size', 'Water Products'],
  'Hamster': ['Cage Size', 'Wheel Type', 'Bedding Brand', 'Favorite Snack'],
  'Parrot': ['Cage Size', 'Favorite Word', 'Noise Level', 'Favorite Treat'],
  'Rabbit': ['Cage Size', 'Favorite Veggie', 'Litter Trained', 'Exercise Routine'],
  'Snake': ['Tank Size', 'Heating Source', 'Feeding Frequency', 'Handling Preference'],
  'Lizard': ['Tank Type', 'UVB Light Brand', 'Humidity Level', 'Feeding Schedule'],
  'Fish': ['Tank Size', 'Water Type', 'Filter Type', 'Feeding Schedule'],
  'Hedgehog': ['Wheel Type', 'Temperature Range', 'Hide Spot Type', 'Favorite Insect'],
  'Guinea Pig': ['Cage Liner Type', 'Pellet Brand', 'Veggie Routine', 'Social Needs'],
  'Frog': ['Humidity Source', 'Tank Setup Type', 'Feeding Time'],
  'Tarantula': ['Enclosure Type', 'Humidity Level', 'Feeding Insects'],
  'Axolotl': ['Water Temp', 'Tank Decor', 'Feeding Schedule'],
  'Mouse': ['Wheel Type', 'Nest Material', 'Feeding Schedule'],
  'Chicken': ['Outdoor Time', 'Diet Type', 'Favorite Spot'],
  'Goat': ['Enclosure Size', 'Grazing Area', 'Milking Schedule'],
};

const List<String> petTypes = [
  'Dog', 'Cat', 'Turtle', 'Hamster', 'Parrot', 'Rabbit', 'Snake', 'Lizard', 'Fish', 'Hedgehog', 'Guinea Pig', 'Frog', 'Tarantula', 'Axolotl', 'Mouse', 'Chicken', 'Goat'
];

// Map pet types to their most relevant subreddit for Reddit integration
const Map<String, String> petTypeToSubreddit = {
  'Dog': 'dogs',
  'Cat': 'cats',
  'Turtle': 'turtles',
  'Hamster': 'hamsters',
  'Parrot': 'parrots',
  'Rabbit': 'rabbits',
  'Snake': 'snakes',
  'Lizard': 'lizards',
  'Fish': 'aquariums',
  'Hedgehog': 'hedgehogs',
  'Guinea Pig': 'guineapigs',
  'Frog': 'frogs',
  'Tarantula': 'tarantulas',
  'Axolotl': 'axolotls',
  'Mouse': 'mice',
  'Chicken': 'BackyardChickens',
  'Goat': 'goats',
}; 