Place Azan audio files here (referenced by `adhan_audio_id` in settings), e.g.:

  default_mishary.mp3
  makkah_live_style.mp3
  short_reminder_ping.mp3

FR-43 requires ≥4 recitations to choose from. Audio files themselves are
binary assets and are not included in this source drop — add licensed or
public-domain recitations here and register them in
`lib/domain/models/app_settings.dart` (adhanAudioId) and wherever the
audio-selection UI is built out (Settings > Azan > Audio).
