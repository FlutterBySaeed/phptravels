class HotelRoom {
  int adults;
  int children;
  final List<int> childAges;

  HotelRoom({
    this.adults = 2,
    this.children = 0,
    List<int>? childAges,
  }) : childAges = childAges ?? [];

  int get totalGuests => adults + children;

  HotelRoom copy() => HotelRoom(
        adults: adults,
        children: children,
        childAges: List<int>.from(childAges),
      );
}
