with open('lib/features/flights/pages/flights_search_page.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

with open('lib/features/flights/pages/flights_search_page.dart', 'w', encoding='utf-8') as f:
    f.writelines(lines[:1756] + lines[2323:])

print("Successfully removed duplicate classes (lines 1757-2322)")
