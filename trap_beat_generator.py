"""
Trap Beat Generator for FL Studio
Generates MIDI files that can be imported into FL Studio
No external dependencies required!

BPM: 145 (typical trap tempo)
Time Signature: 4/4
Length: 8 bars

Files generated:
- trap_kick.mid - 808 kick pattern
- trap_hihat.mid - Hi-hat pattern with rolls
- trap_snare.mid - Snare/clap pattern
- trap_808bass.mid - 808 bass melody
- trap_melody.mid - Simple trap melody
"""

import os
import struct

# Configuration
BPM = 145
BARS = 8
BEATS_PER_BAR = 4
TICKS_PER_BEAT = 480  # Standard MIDI resolution

# Output directory
OUTPUT_DIR = "trap_beat_midi"


class MidiWriter:
    """Simple MIDI file writer without external dependencies"""

    def __init__(self, ticks_per_beat=480):
        self.ticks_per_beat = ticks_per_beat
        self.tracks = []

    def add_track(self, name=""):
        track = MidiTrack(name, self.ticks_per_beat)
        self.tracks.append(track)
        return track

    def save(self, filename):
        with open(filename, 'wb') as f:
            # MIDI Header
            f.write(b'MThd')
            f.write(struct.pack('>I', 6))  # Header length
            f.write(struct.pack('>H', 1))  # Format type 1
            f.write(struct.pack('>H', len(self.tracks)))  # Number of tracks
            f.write(struct.pack('>H', self.ticks_per_beat))  # Ticks per beat

            # Write tracks
            for track in self.tracks:
                track_data = track.get_data()
                f.write(b'MTrk')
                f.write(struct.pack('>I', len(track_data)))
                f.write(track_data)


class MidiTrack:
    """MIDI Track with events"""

    def __init__(self, name="", ticks_per_beat=480):
        self.name = name
        self.ticks_per_beat = ticks_per_beat
        self.events = []  # (absolute_tick, event_data)

    def add_note(self, channel, note, start_beat, duration_beats, velocity=100):
        """Add a note with start time in beats"""
        start_tick = int(start_beat * self.ticks_per_beat)
        duration_ticks = int(duration_beats * self.ticks_per_beat)
        end_tick = start_tick + duration_ticks

        # Note on
        note_on = bytes([0x90 | (channel & 0x0F), note & 0x7F, velocity & 0x7F])
        self.events.append((start_tick, note_on))

        # Note off
        note_off = bytes([0x80 | (channel & 0x0F), note & 0x7F, 0])
        self.events.append((end_tick, note_off))

    def add_tempo(self, bpm, tick=0):
        """Add tempo event"""
        microseconds = int(60000000 / bpm)
        tempo_data = bytes([0xFF, 0x51, 0x03,
                           (microseconds >> 16) & 0xFF,
                           (microseconds >> 8) & 0xFF,
                           microseconds & 0xFF])
        self.events.append((tick, tempo_data))

    def add_track_name(self, name, tick=0):
        """Add track name event"""
        name_bytes = name.encode('ascii', errors='ignore')
        name_data = bytes([0xFF, 0x03, len(name_bytes)]) + name_bytes
        self.events.append((tick, name_data))

    def _write_variable_length(self, value):
        """Convert value to MIDI variable-length format"""
        result = []
        result.append(value & 0x7F)
        value >>= 7
        while value:
            result.append((value & 0x7F) | 0x80)
            value >>= 7
        return bytes(reversed(result))

    def get_data(self):
        """Get track data as bytes"""
        # Sort events by time
        self.events.sort(key=lambda x: x[0])

        data = bytearray()
        last_tick = 0

        for tick, event_data in self.events:
            delta = tick - last_tick
            data.extend(self._write_variable_length(delta))
            data.extend(event_data)
            last_tick = tick

        # End of track
        data.extend(self._write_variable_length(0))
        data.extend(bytes([0xFF, 0x2F, 0x00]))

        return bytes(data)


def create_output_dir():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)


def create_kick_pattern():
    """Creates a typical trap kick pattern"""
    midi = MidiWriter(TICKS_PER_BEAT)
    track = midi.add_track()
    track.add_track_name("Trap Kick")
    track.add_tempo(BPM)

    kick_note = 36  # C1
    channel = 9     # Drum channel
    velocity = 100
    duration = 0.25

    # Syncopated trap kick pattern
    kick_pattern = [0, 0.75, 1.5, 2.25, 2.75, 3.5]

    for bar in range(BARS):
        bar_offset = bar * BEATS_PER_BAR
        for hit in kick_pattern:
            if bar % 2 == 1 and hit == 2.75:
                continue
            track.add_note(channel, kick_note, bar_offset + hit, duration, velocity)

    return midi


def create_hihat_pattern():
    """Creates hi-hat pattern with trap rolls"""
    midi = MidiWriter(TICKS_PER_BEAT)
    track = midi.add_track()
    track.add_track_name("Trap Hi-Hats")
    track.add_tempo(BPM)

    hihat_closed = 42
    hihat_open = 46
    channel = 9

    for bar in range(BARS):
        bar_offset = bar * BEATS_PER_BAR

        for beat in range(BEATS_PER_BAR):
            beat_offset = bar_offset + beat

            # Regular 8th notes
            track.add_note(channel, hihat_closed, beat_offset, 0.125, 80)
            track.add_note(channel, hihat_closed, beat_offset + 0.5, 0.125, 70)

            # Triplet rolls on beats 3 and 4
            if beat >= 2:
                for i in range(3):
                    triplet_time = beat_offset + 0.25 + (i * 0.166)
                    velocity = 90 - (i * 10)
                    track.add_note(channel, hihat_closed, triplet_time, 0.08, velocity)

            # Open hi-hat on beat 4
            if beat == 3:
                track.add_note(channel, hihat_open, beat_offset + 0.75, 0.25, 85)

    return midi


def create_snare_pattern():
    """Creates snare/clap pattern"""
    midi = MidiWriter(TICKS_PER_BEAT)
    track = midi.add_track()
    track.add_track_name("Trap Snare")
    track.add_tempo(BPM)

    snare = 38
    clap = 39
    channel = 9

    for bar in range(BARS):
        bar_offset = bar * BEATS_PER_BAR

        # Snare + clap on 2 and 4
        track.add_note(channel, snare, bar_offset + 1, 0.25, 100)
        track.add_note(channel, clap, bar_offset + 1, 0.25, 95)
        track.add_note(channel, snare, bar_offset + 3, 0.25, 100)
        track.add_note(channel, clap, bar_offset + 3, 0.25, 95)

        # Roll on last bar
        if bar == BARS - 1:
            for i in range(4):
                roll_time = bar_offset + 3.5 + (i * 0.125)
                track.add_note(channel, snare, roll_time, 0.1, 80 + (i * 5))

    return midi


def create_808_bass():
    """Creates 808 bass melody in C minor"""
    midi = MidiWriter(TICKS_PER_BEAT)
    track = midi.add_track()
    track.add_track_name("808 Bass")
    track.add_tempo(BPM)

    channel = 0
    velocity = 100

    # C minor - C2=36, Eb2=39, F2=41
    bass_pattern = [
        (36, 0, 1.5),      # C2
        (36, 1.5, 1),      # C2
        (39, 2.5, 1.5),    # Eb2
        (41, 4, 1.5),      # F2
        (39, 5.5, 1),      # Eb2
        (36, 6.5, 1.5),    # C2
    ]

    for repeat in range(BARS // 2):
        offset = repeat * 8
        for note, start, dur in bass_pattern:
            track.add_note(channel, note, offset + start, dur, velocity)

    return midi


def create_melody():
    """Creates dark trap melody in C minor"""
    midi = MidiWriter(TICKS_PER_BEAT)
    track = midi.add_track()
    track.add_track_name("Trap Melody")
    track.add_tempo(BPM)

    channel = 0

    # C minor pentatonic - C4=60, Eb4=63, F4=65, G4=67, Bb4=70, C5=72
    melody_pattern = [
        (72, 0, 0.5, 90),      # C5
        (70, 0.5, 0.5, 85),    # Bb4
        (67, 1, 1, 80),        # G4
        (63, 2.5, 0.5, 85),    # Eb4
        (65, 3, 0.75, 90),     # F4
        (67, 4, 0.5, 85),      # G4
        (70, 4.5, 1.5, 90),    # Bb4
        (72, 6, 0.5, 80),      # C5
        (70, 6.5, 0.5, 75),    # Bb4
        (67, 7, 1, 85),        # G4
        (63, 8, 1, 90),        # Eb4
        (65, 9, 0.5, 85),      # F4
        (67, 9.5, 1.5, 80),    # G4
        (65, 11, 0.5, 75),     # F4
        (63, 11.5, 0.5, 80),   # Eb4
        (60, 12, 2, 90),       # C4
        (63, 14, 1, 85),       # Eb4
        (60, 15, 1, 80),       # C4
    ]

    for repeat in range(2):
        offset = repeat * 16
        for note, start, dur, vel in melody_pattern:
            track.add_note(channel, note, offset + start, dur, vel)

    return midi


def save_midi(midi, filename):
    filepath = os.path.join(OUTPUT_DIR, filename)
    midi.save(filepath)
    print(f"  [OK] {filepath}")


def main():
    print("=" * 50)
    print("   TRAP BEAT GENERATOR FOR FL STUDIO")
    print("=" * 50)
    print(f"\n  BPM: {BPM}")
    print(f"  Length: {BARS} bars")
    print(f"  Key: C minor")
    print(f"\nGenerating MIDI files...\n")

    create_output_dir()

    save_midi(create_kick_pattern(), "trap_kick.mid")
    save_midi(create_hihat_pattern(), "trap_hihat.mid")
    save_midi(create_snare_pattern(), "trap_snare.mid")
    save_midi(create_808_bass(), "trap_808bass.mid")
    save_midi(create_melody(), "trap_melody.mid")

    print("\n" + "=" * 50)
    print("  DONE! Files in 'trap_beat_midi' folder")
    print("=" * 50)
    print("""
Come usare in FL Studio:
------------------------
1. Apri FL Studio
2. Trascina i file MIDI nella playlist o nel channel rack
3. Assegna i suoni:
   - trap_kick.mid    -> 808 Kick (es. Spinz 808, Zay 808)
   - trap_hihat.mid   -> Hi-Hat metallico
   - trap_snare.mid   -> Snare + Clap layered
   - trap_808bass.mid -> 808 Sub Bass con glide
   - trap_melody.mid  -> Synth dark (Flex, Serum, Omnisphere)

Tips:
- Aggiungi Gross Beat sul 808 per effetti slide
- Usa Fruity Limiter sul master
- Aggiungi reverb sulla melody
- Sidechain i hi-hats al kick
""")


if __name__ == "__main__":
    main()
