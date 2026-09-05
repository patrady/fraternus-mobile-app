import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/shared/models/frat_night_template.dart';

void main() {
  group('FratNightTemplate.fromJson', () {
    test('maps every field, including the optional ones when present', () {
      final template = FratNightTemplate.fromJson({
        'id': 'template-1',
        'key': 'week-1',
        'title': 'Humility',
        'description': 'Week 1',
        'reading': 'reading text',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-02T00:00:00Z',
        'video_clip_url': 'https://example.com/video.mp4',
        'field_guide_week_id': 'field-guide-week-1',
      });

      expect(template.videoClipUrl, 'https://example.com/video.mp4');
      expect(template.fieldGuideWeekId, 'field-guide-week-1');
    });

    test('optional fields parse to null when absent, e.g. a Rush Night template', () {
      final template = FratNightTemplate.fromJson({
        'id': 'template-1',
        'key': 'rush-night',
        'title': 'Rush Night',
        'description': 'Intro night',
        'reading': 'reading text',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-02T00:00:00Z',
      });

      expect(template.videoClipUrl, isNull);
      expect(template.fieldGuideWeekId, isNull);
    });
  });
}
