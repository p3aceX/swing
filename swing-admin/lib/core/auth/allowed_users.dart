class AllowedUser {
  const AllowedUser({required this.email, required this.displayName});
  final String email;
  final String displayName;
}

const kSharedPassword = 'Swing#123';

const kAllowedUsers = <AllowedUser>[
  AllowedUser(email: 'adi@swingcricketapp.com', displayName: 'Adi'),
  AllowedUser(email: 'sangwan@swingcricketapp.com', displayName: 'Sangwan'),
  AllowedUser(email: 'parth@swingcricketapp.com', displayName: 'Parth'),
  AllowedUser(email: 'anupam@swingcricketapp.com', displayName: 'Anupam'),
  AllowedUser(email: 'vishwa@swingcricketapp.com', displayName: 'Vishwa'),
];
