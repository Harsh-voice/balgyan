/// Deterministic "Letter of the Day" index: same result all day on every
/// device, no network needed, rotates through all [count] items.
int dailyIndex(DateTime now, int count) {
  if (count <= 0) return 0;
  final daysSinceEpoch =
      DateTime(now.year, now.month, now.day).difference(DateTime(2020)).inDays;
  return daysSinceEpoch % count;
}
