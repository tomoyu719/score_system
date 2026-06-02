import 'package:score_core/score_core.dart';
import 'package:score_io/score_io.dart';
import 'package:test/test.dart';

String _wrap(String inner, {String title = '', String composer = '', String partListEntry = '', String partId = 'P1'}) {
  final partList = partListEntry.isEmpty
      ? '<part-list><score-part id="$partId"><part-name>Piano</part-name></score-part></part-list>'
      : partListEntry;
  final titleEl = title.isEmpty ? '' : '<movement-title>$title</movement-title>';
  final composerEl = composer.isEmpty
      ? ''
      : '<identification><creator type="composer">$composer</creator></identification>';
  return '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise version="3.1">
  $titleEl
  $composerEl
  $partList
  <part id="$partId">
    $inner
  </part>
</score-partwise>''';
}

String _measure(String inner, {int number = 1}) =>
    '<measure number="$number">$inner</measure>';

const _attrs4_4 = '''<attributes>
  <divisions>4</divisions>
  <key><fifths>0</fifths><mode>major</mode></key>
  <time><beats>4</beats><beat-type>4</beat-type></time>
  <clef><sign>G</sign><line>2</line></clef>
</attributes>''';

void main() {
  group('MusicXmlParser', () {
    test('parses empty score with title and composer', () {
      final xml = _wrap(
        _measure(_attrs4_4),
        title: 'My Song',
        composer: 'Jane Doe',
      );
      final score = ScoreIo.parseMusicXml(xml);

      expect(score.title, equals('My Song'));
      expect(score.composer, equals('Jane Doe'));
    });

    test('parses time signature and key signature', () {
      final xml = _wrap(_measure('''
        <attributes>
          <divisions>4</divisions>
          <key><fifths>2</fifths><mode>major</mode></key>
          <time><beats>3</beats><beat-type>4</beat-type></time>
        </attributes>
      '''));
      final score = ScoreIo.parseMusicXml(xml);

      expect(score.measureHeaders, hasLength(1));
      final h = score.measureHeaders[0];
      expect(h.timeSignature.beats, equals(3));
      expect(h.timeSignature.beatType, equals(4));
      expect(h.keySignature.fifths, equals(2));
      expect(h.keySignature.mode, equals(Mode.major));
    });

    test('parses single quarter note', () {
      final xml = _wrap(_measure('''
        $_attrs4_4
        <note>
          <pitch><step>C</step><octave>4</octave></pitch>
          <duration>4</duration>
          <type>quarter</type>
          <voice>1</voice>
          <staff>1</staff>
        </note>
      '''));
      final score = ScoreIo.parseMusicXml(xml);

      final part = score.parts[0];
      final staff = part.staves[0];
      final measure = staff.measures[1]!;
      final voice = measure.voices[const VoiceId('1')]!;
      expect(voice.events, hasLength(1));
      final event = voice.events[0] as NoteEvent;
      expect(event.pitch.step, equals(Step.c));
      expect(event.pitch.octave, equals(4));
      expect(event.noteValue.noteType, equals(NoteType.quarter));
      expect(event.noteValue.dots, equals(0));
      expect(event.offset, equals(Fraction.zero));
    });

    test('parses rest', () {
      final xml = _wrap(_measure('''
        $_attrs4_4
        <note>
          <rest/>
          <duration>4</duration>
          <type>quarter</type>
          <voice>1</voice>
          <staff>1</staff>
        </note>
      '''));
      final score = ScoreIo.parseMusicXml(xml);

      final voice = score.parts[0].staves[0].measures[1]!.voices[const VoiceId('1')]!;
      expect(voice.events, hasLength(1));
      expect(voice.events[0], isA<RestEvent>());
      final rest = voice.events[0] as RestEvent;
      expect(rest.noteValue.noteType, equals(NoteType.quarter));
    });

    test('parses dotted note', () {
      final xml = _wrap(_measure('''
        $_attrs4_4
        <note>
          <pitch><step>G</step><octave>4</octave></pitch>
          <duration>6</duration>
          <dot/>
          <type>quarter</type>
          <voice>1</voice>
          <staff>1</staff>
        </note>
      '''));
      final score = ScoreIo.parseMusicXml(xml);

      final voice = score.parts[0].staves[0].measures[1]!.voices[const VoiceId('1')]!;
      final event = voice.events[0] as NoteEvent;
      expect(event.noteValue.noteType, equals(NoteType.quarter));
      expect(event.noteValue.dots, equals(1));
    });

    test('parses chord (two simultaneous notes)', () {
      final xml = _wrap(_measure('''
        $_attrs4_4
        <note>
          <pitch><step>C</step><octave>4</octave></pitch>
          <duration>4</duration>
          <type>quarter</type>
          <voice>1</voice>
          <staff>1</staff>
        </note>
        <note>
          <chord/>
          <pitch><step>E</step><octave>4</octave></pitch>
          <duration>4</duration>
          <type>quarter</type>
          <voice>1</voice>
          <staff>1</staff>
        </note>
      '''));
      final score = ScoreIo.parseMusicXml(xml);

      final voice = score.parts[0].staves[0].measures[1]!.voices[const VoiceId('1')]!;
      expect(voice.events, hasLength(1));
      final chord = voice.events[0] as ChordEvent;
      expect(chord.notes, hasLength(2));
      expect(chord.notes[0].pitch.step, equals(Step.c));
      expect(chord.notes[1].pitch.step, equals(Step.e));
    });

    test('parses dynamics direction', () {
      final xml = _wrap(_measure('''
        $_attrs4_4
        <note>
          <pitch><step>D</step><octave>4</octave></pitch>
          <duration>4</duration>
          <type>quarter</type>
          <voice>1</voice>
          <staff>1</staff>
        </note>
        <direction placement="above">
          <direction-type>
            <dynamics><ff/></dynamics>
          </direction-type>
        </direction>
      '''));
      final score = ScoreIo.parseMusicXml(xml);

      final voice = score.parts[0].staves[0].measures[1]!.voices[const VoiceId('1')]!;
      expect(voice.events, hasLength(1));
      final note = voice.events[0] as NoteEvent;
      expect(note.dynamics, hasLength(1));
      expect(note.dynamics[0].type, equals(DynamicType.ff));
      expect(note.dynamics[0].placement, equals(Placement.above));
    });

    test('parses tempo direction', () {
      final xml = _wrap(_measure('''
        $_attrs4_4
        <direction>
          <direction-type>
            <metronome parentheses="no">
              <beat-unit>quarter</beat-unit>
              <per-minute>120</per-minute>
            </metronome>
          </direction-type>
        </direction>
      '''));
      final score = ScoreIo.parseMusicXml(xml);

      expect(score.measureHeaders, hasLength(1));
      final h = score.measureHeaders[0];
      expect(h.tempo, isNotNull);
      expect(h.tempo!.bpm, equals(120.0));
      expect(h.tempo!.beatUnit, equals(NoteType.quarter));
    });

    test('parses final barline', () {
      final xml = _wrap(_measure('''
        $_attrs4_4
        <barline location="right">
          <bar-style>light-heavy</bar-style>
        </barline>
      '''));
      final score = ScoreIo.parseMusicXml(xml);

      final h = score.measureHeaders[0];
      expect(h.barlineEnd, equals(BarlineType.finalBar));
    });

    test('parses multiple measures', () {
      final xml = _wrap('''
        ${_measure('''
          $_attrs4_4
          <note>
            <pitch><step>C</step><octave>4</octave></pitch>
            <duration>16</duration>
            <type>whole</type>
            <voice>1</voice>
            <staff>1</staff>
          </note>
        ''', number: 1)}
        ${_measure('''
          <note>
            <pitch><step>D</step><octave>4</octave></pitch>
            <duration>16</duration>
            <type>whole</type>
            <voice>1</voice>
            <staff>1</staff>
          </note>
        ''', number: 2)}
      ''');
      final score = ScoreIo.parseMusicXml(xml);

      expect(score.measureHeaders, hasLength(2));
      final staff = score.parts[0].staves[0];
      expect(staff.measures.length, equals(2));
      final m1voice = staff.measures[1]!.voices[const VoiceId('1')]!;
      final m2voice = staff.measures[2]!.voices[const VoiceId('1')]!;
      expect((m1voice.events[0] as NoteEvent).pitch.step, equals(Step.c));
      expect((m2voice.events[0] as NoteEvent).pitch.step, equals(Step.d));
    });

    test('parses multiple parts', () {
      final xml = '''<?xml version="1.0" encoding="UTF-8"?>
<score-partwise version="3.1">
  <part-list>
    <score-part id="P1"><part-name>Violin</part-name></score-part>
    <score-part id="P2"><part-name>Cello</part-name></score-part>
  </part-list>
  <part id="P1">
    <measure number="1">
      $_attrs4_4
    </measure>
  </part>
  <part id="P2">
    <measure number="1">
      <attributes>
        <divisions>4</divisions>
        <key><fifths>0</fifths><mode>major</mode></key>
        <time><beats>4</beats><beat-type>4</beat-type></time>
      </attributes>
    </measure>
  </part>
</score-partwise>''';

      final score = ScoreIo.parseMusicXml(xml);

      expect(score.parts, hasLength(2));
      expect(score.parts[0].name, equals('Violin'));
      expect(score.parts[1].name, equals('Cello'));
    });
  });
}
