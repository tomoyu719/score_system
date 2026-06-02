import 'dart:typed_data';

import 'package:score_core/score_core.dart';

import 'json/score_json_file.dart';
import 'json/score_serializer.dart';
import 'midi/midi_encoder.dart';
import 'midi/midi_json_dump.dart';
import 'musicxml/musicxml_exporter.dart';
import 'musicxml/musicxml_parser.dart';

/// Entry point for all score_io file format operations.
final class ScoreIo {
  ScoreIo._();

  static const _serializer = ScoreSerializer();
  static const _xmlParser = MusicXmlParser();
  static const _xmlExporter = MusicXmlExporter();
  static const _midiEncoder = MidiEncoder();
  static const _midiDump = MidiJsonDump();

  // ── Native JSON ────────────────────────────────────────────────────────────

  static Future<Score> loadJson(String path) => ScoreJsonFile.load(path);

  static Future<void> saveJson(Score score, String path) =>
      ScoreJsonFile.save(score, path);

  static Score fromJsonString(String json) => _serializer.fromJson(json);

  static String toJsonString(Score score) => _serializer.toJson(score);

  // ── MusicXML ───────────────────────────────────────────────────────────────

  static Score parseMusicXml(String xml) => _xmlParser.parse(xml);

  static String exportMusicXml(Score score) => _xmlExporter.export(score);

  // ── MIDI ───────────────────────────────────────────────────────────────────

  static Uint8List encodeMidi(Score score) => _midiEncoder.encode(score);

  static Map<String, Object?> dumpMidi(Score score) => _midiDump.dump(score);
}
