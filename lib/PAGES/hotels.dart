import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:phptravels/PAGES/flights.dart' show TripType, DestinationSearchPage, CustomDatePickerPage;
import 'package:phptravels/THEMES/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';

class HotelsSearchPage extends StatefulWidget {
  const HotelsSearchPage({super.key});

  @override
  State<HotelsSearchPage> createState() => _HotelsSearchPageState();
}

class _HotelsSearchPageState extends State<HotelsSearchPage> {
  final TextEditingController _destinationController = TextEditingController(text: 'Karachi, Pakistan');
  DateTime? _checkInDate = DateTime.now();
  DateTime? _checkOutDate = DateTime.now().add(const Duration(days: 3));
  final List<HotelRoom> _rooms = [HotelRoom()];

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDestination() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationSearchPage(
          onDestinationSelected: (destination) {
            setState(() => _destinationController.text = destination);
          },
        ),
      ),
    );
  }

  Future<void> _selectDates() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => CustomDatePickerPage(
          isDeparture: true,
          onDateSelected: (start, end) {
            setState(() {
              _checkInDate = start;
              _checkOutDate = end ?? start?.add(const Duration(days: 1));
            });
          },
          tripType: TripType.roundTrip,
          initialDepartureDate: _checkInDate,
          initialReturnDate: _checkOutDate,
        ),
      ),
    );
  }

  Future<void> _editGuestsAndRooms() async {
    final updatedRooms = await showModalBottomSheet<List<HotelRoom>>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => HotelGuestRoomPickerBottomSheet(initialRooms: _rooms),
    );

    if (updatedRooms != null) {
      setState(() {
        _rooms
          ..clear()
          ..addAll(updatedRooms);
      });
    }
  }

  String _formatDate(AppLocalizations l10n, DateTime? date) {
    if (date == null) return '--';
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat('EEE, dd MMM', locale).format(date);
  }

  String _guestSummary(AppLocalizations l10n) {
    final totalGuests = _rooms.fold<int>(0, (sum, room) => sum + room.totalGuests);
    final roomCount = _rooms.length;
    final guestLabel = totalGuests == 1 ? l10n.guest : l10n.guests;
    final roomLabel = roomCount == 1 ? l10n.room : l10n.rooms;
    return '$totalGuests $guestLabel · $roomCount $roomLabel';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.hotelsSearchTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              child: _HighlightBanner(text: l10n.needPlaceTonight),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SearchCard(
                destinationChild: _CompactInfoTile(
                  icon: LucideIcons.search,
                  title: l10n.destination,
                  value: _destinationController.text,
                  onTap: _selectDestination,
                ),
                dateChild: _CompactDateTile(
                  checkInLabel: l10n.checkIn,
                  checkOutLabel: l10n.checkOut,
                  checkInValue: _formatDate(l10n, _checkInDate),
                  checkOutValue: _formatDate(l10n, _checkOutDate),
                  onTap: _selectDates,
                ),
                guestsChild: _CompactInfoTile(
                  icon: LucideIcons.doorOpen,
                  title: l10n.guestsAndRooms,
                  value: _guestSummary(l10n),
                  onTap: _editGuestsAndRooms,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(
                    l10n.searchHotels,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

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

class _HighlightBanner extends StatelessWidget {
  final String text;

  const _HighlightBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.zero,
      color: AppColors.primaryBlue.withOpacity(0.15),
      child: Row(
        children: [
          Icon(Icons.navigation_outlined, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryBlue),
        ],
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final Widget destinationChild;
  final Widget dateChild;
  final Widget guestsChild;

  const _SearchCard({
    required this.destinationChild,
    required this.dateChild,
    required this.guestsChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          destinationChild,
          const Divider(height: 1),
          dateChild,
          const Divider(height: 1),
          guestsChild,
        ],
      ),
    );
  }
}

class _CompactInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _CompactInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactDateTile extends StatelessWidget {
  final String checkInLabel;
  final String checkOutLabel;
  final String checkInValue;
  final String checkOutValue;
  final VoidCallback onTap;

  const _CompactDateTile({
    required this.checkInLabel,
    required this.checkOutLabel,
    required this.checkInValue,
    required this.checkOutValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(LucideIcons.calendar, size: 20, color: Theme.of(context).iconTheme.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(checkInLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      checkInValue,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1, 
                height: 32, 
                color: Theme.of(context).dividerColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(checkOutLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      checkOutValue,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class HotelGuestRoomPickerBottomSheet extends StatefulWidget {
  final List<HotelRoom> initialRooms;

  const HotelGuestRoomPickerBottomSheet({super.key, required this.initialRooms});

  @override
  State<HotelGuestRoomPickerBottomSheet> createState() => _HotelGuestRoomPickerBottomSheetState();
}

class _HotelGuestRoomPickerBottomSheetState extends State<HotelGuestRoomPickerBottomSheet> {
  late List<HotelRoom> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = widget.initialRooms.map((room) => room.copy()).toList();
  }

  void _updateAdults(int roomIndex, int newValue) {
    setState(() {
      _rooms[roomIndex].adults = newValue.clamp(1, 6);
    });
  }

  void _updateChildren(int roomIndex, int newValue) {
    setState(() {
      final room = _rooms[roomIndex];
      room.children = newValue.clamp(0, 6);
      if (room.childAges.length > room.children) {
        room.childAges.removeRange(room.children, room.childAges.length);
      } else {
        while (room.childAges.length < room.children) {
          room.childAges.add(5);
        }
      }
    });
  }

  void _updateChildAge(int roomIndex, int childIndex, int age) {
    setState(() {
      _rooms[roomIndex].childAges[childIndex] = age;
    });
  }

  void _addRoom() {
    setState(() {
      _rooms.add(HotelRoom());
    });
  }

  void _removeRoom(int index) {
    if (_rooms.length == 1) return;
    setState(() {
      _rooms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final height = MediaQuery.of(context).size.height * 0.8;
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            _BottomSheetHeader(
              title: l10n.guestsAndRooms,
              onClose: () => Navigator.pop(context),
              onApply: () => Navigator.pop(context, _rooms.map((room) => room.copy()).toList()),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: _rooms.length + 1,
                itemBuilder: (context, index) {
                  if (index < _rooms.length) {
                    return _RoomEditor(
                      room: _rooms[index],
                      index: index,
                      onAdultsChanged: (value) => _updateAdults(index, value),
                      onChildrenChanged: (value) => _updateChildren(index, value),
                      onChildAgeChanged: (childIndex, age) => _updateChildAge(index, childIndex, age),
                      onRemoveRoom: () => _removeRoom(index),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: _addRoom,
                            icon: const Icon(Icons.add),
                            label: Text(
                              l10n.addRoom,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final VoidCallback onApply;

  const _BottomSheetHeader({
    required this.title,
    required this.onClose,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: onApply,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}

class _RoomEditor extends StatelessWidget {
  final HotelRoom room;
  final int index;
  final ValueChanged<int> onAdultsChanged;
  final ValueChanged<int> onChildrenChanged;
  final void Function(int childIndex, int age) onChildAgeChanged;
  final VoidCallback onRemoveRoom;

  const _RoomEditor({
    required this.room,
    required this.index,
    required this.onAdultsChanged,
    required this.onChildrenChanged,
    required this.onChildAgeChanged,
    required this.onRemoveRoom,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canRemove = index > 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${l10n.room} ${index + 1}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            if (canRemove)
              TextButton(
                onPressed: onRemoveRoom,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.removeRoom,
                  style: const TextStyle(
                    color: Colors.red,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.person, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.adults,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '> 17 ${l10n.years}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _CircleButton(
                  icon: Icons.remove,
                  onTap: room.adults > 1 ? () => onAdultsChanged(room.adults - 1) : null,
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    room.adults.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _CircleButton(
                  icon: Icons.add,
                  onTap: room.adults < 6 ? () => onAdultsChanged(room.adults + 1) : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.person, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.children,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '≤ 17 ${l10n.years}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _CircleButton(
                  icon: Icons.remove,
                  onTap: room.children > 0 ? () => onChildrenChanged(room.children - 1) : null,
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    room.children.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _CircleButton(
                  icon: Icons.add,
                  onTap: room.children < 6 ? () => onChildrenChanged(room.children + 1) : null,
                ),
              ],
            ),
          ],
        ),
        if (room.children > 0) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(
              l10n.ageOfChildren,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: List.generate(room.children, (childIndex) {
              return SizedBox(
                width: 70,
                child: _AgeDropdown(
                  value: room.childAges[childIndex],
                  onChanged: (age) => onChildAgeChanged(childIndex, age),
                ),
              );
            }),
          ),
        ],
        const SizedBox(height: 24),
        Divider(color: Colors.grey.shade300),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: onTap == null ? Colors.grey.shade300 : Colors.grey.shade400,
          ),
          color: onTap == null ? Colors.grey.shade100 : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? Colors.grey.shade400 : Colors.black87,
        ),
      ),
    );
  }
}

class _AgeDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _AgeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      child: DropdownButton<int>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: List.generate(
          18,
          (index) => DropdownMenuItem(
            value: index,
            child: Text(index.toString()),
          ),
        ),
        onChanged: (age) {
          if (age != null) {
            onChanged(age);
          }
        },
      ),
    );
  }
}