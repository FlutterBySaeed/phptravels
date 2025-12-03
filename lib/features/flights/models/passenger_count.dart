class PassengerCount {
  int adults;
  int children;
  int infants;

  PassengerCount({this.adults = 1, this.children = 0, this.infants = 0});

  PassengerCount copyWith({int? adults, int? children, int? infants}) {
    return PassengerCount(
        adults: adults ?? this.adults,
        children: children ?? this.children,
        infants: infants ?? this.infants);
  }

  int get total => adults + children + infants;
}
