import '../ids.dart';
import 'voice.dart';

/// Address and value of a single [Voice] within a [Score].
///
/// Yielded by [Score.allVoices] to let callers iterate every voice without
/// knowing the internal hierarchy shape.
final class VoiceContext {
  const VoiceContext({
    required this.partId,
    required this.staffId,
    required this.measureNumber,
    required this.voiceId,
    required this.voice,
  });

  final PartId partId;
  final StaffId staffId;
  final int measureNumber;
  final VoiceId voiceId;
  final Voice voice;
}
