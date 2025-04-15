# SoundFont Files (.sf2)

The application utilizes SoundFont files to synthesize instrument sounds, specifically for piano playback. These files are located in the `assets/soundfont` directory. A third-party library, [RustySynth](https://github.com/sinshu/rustysynth), is employed to load the SoundFont files and generate the corresponding audio output.

### Sources for SoundFont files
- [Musical Artifacts](https://musical-artifacts.com/)
- [Polyphone](https://www.polyphone.io)
- [Soundfonts 4U](https://sites.google.com/site/soundfonts4u/)

### SoundFont files used in this application
- [Piano 2](https://www.polyphone.io/en/soundfonts/pianos/673-pspkvm-soundfont)
- [Electrical Piano 2](https://musical-artifacts.com/artifacts/5896)
- [Pipe Organ](https://www.polyphone.io/en/soundfonts/organs/733-pipe-organ-samples)
- [Harpsichord](https://www.polyphone.io/en/soundfonts/harpsichords/114-german8-harpsichord)

*Note: All SoundFont files incorporated in this application are public domain and license-free.*

To optimize file size and eliminate unwanted content, some SoundFont files were edited to remove extraneous instruments or sound effects. This was accomplished using [Polyphone](https://www.polyphone.io/en/software), a free and open-source tool for editing SoundFont files. Within Polyphone, you can selectively delete unnecessary `presets`, `instruments`, and `samples` to tailor the files for use in the application.
